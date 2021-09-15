// ログイン画面
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geolocator/geolocator.dart';

import 'package:polesearcherapp/models/company.dart';
import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
//北陸
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';
import 'package:polesearcherapp/services/hokuriku/geofencing.dart';
//中国
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chugoku/event.dart';
import 'package:polesearcherapp/services/chugoku/geofencing.dart';
//中部
import 'package:polesearcherapp/models/chuden/chuden.dart';
import 'package:polesearcherapp/models/chuden/event.dart';
import 'package:polesearcherapp/services/chuden/geofencing.dart';


//共通
import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/permission.dart';


class LoginPage extends StatefulWidget {
  LoginPage(this.auth,
      this.userDatahokuriku, this.hokuriku, this.hrevent,
      this.userDatachugoku,this.chugoku, this.cgevent,
      this.userDatachuden, this.chuden,this .chevent);

  final Auth auth;
  //北陸
  final UserDataHokuriku userDatahokuriku;
  final Hokuriku hokuriku;
  final HrEvent hrevent;
  //中国
  final UserDataChugoku userDatachugoku;
  final Chugoku chugoku;
  final CgEvent cgevent;
  //中部
  final UserDataChuden userDatachuden;
  final Chuden chuden;
  final ChEvent chevent;





  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  GeofencingHokuriku geofencingHokuriku = GeofencingHokuriku(notify: true);
  GeofencingChugoku geofencingChugoku = GeofencingChugoku(notify: true);
  GeofencingChuden geofencingChuden = GeofencingChuden(notify: true);

  final _userFocus = FocusNode();
  final _passFocus = FocusNode();

  Map _versions;
  String _email;
  String _pw;
  bool _canLogin;
  bool _hidePw;

  @override
  void initState() {
    _email = '';
    _pw = '';
    _canLogin = false;
    _hidePw = true;
    super.initState();

    getVersions().then((version){
      setState(() {
        _versions = version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget> [
                SliverAppBar(
                  centerTitle: true,
                  title: const Text('ログイン'),
                  actions: [
                    Center(
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: _versions != null ? Text('v${_versions['version']}') : const SizedBox.shrink(),
                        )
                    ),
                  ],
                ),
              ];
            },

            body: SingleChildScrollView(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          children: <Widget>[
                            addPadding(2),

                            showUsernameInput('ログインID', _userFocus, checkValidateEmail, _cbEmail),
                            showPasswordInput('パスワード', _passFocus, _hidePw, _cbPw, _cbHidePw),

                            showSubmit(_formKey, 'ログイン', const Size(210,50), 22, Colors.indigo,
                                _canLogin ? _cbLogin : null),


                          ],
                        ),
                      ),
                    ),
                  ],
                )
            )
        )
    );
  }

  // _checkCanLogin は、ログインボタンが押せる状態かどうかを返します。
  // ログインボタンが押せる状態とは、Eメールとパスワードの両方が有効な入力になっている状態です。
  bool _checkCanLogin() {
    return minimumPWLength <= _pw.length && validateEmail(_email);
  }

  // _cbHidePw は、パスワードを表示するかしないかをトグルするコールバックです
  void _cbHidePw(bool b) {
    setState(() {
      _hidePw = b;
    });
  }

  // cbPw は、入力欄が変化する度に呼ばれるコールバックです。
  // ログインボタンが押せる状態かどうかを判断し、状態を更新します。
  void _cbPw(String pw) {
    setState(() {
      _pw = pw;
      _canLogin = _checkCanLogin();
    });
  }

  // cbEmail は、入力欄が変化する度に呼ばれるコールバックです。
  // ログインボタンが押せる状態かどうかを判断し、状態を更新します。
  void _cbEmail(String email) {
    print('cb');
    setState(() {
      _email = email;
      _canLogin = _checkCanLogin();
    });
  }

  // _cbLogin は、ログインンボタンが押されたときのコールバックです。
  Future<void> _cbLogin() async {

    FocusScope.of(context).requestFocus(_userFocus);
    await Future<void>.delayed(const Duration(microseconds: 100));

    FocusScope.of(context).requestFocus(_passFocus);
    await Future<void>.delayed(const Duration(microseconds: 100));

    TextInput.finishAutofillContext(shouldSave: true);
    FocusScope.of(context).unfocus();

    // プログレスインジケータ表示
    showProgressIndicator(context);
    debugPrint('attempt: $_email / $_pw');
    try {
      final user = await widget.auth.signIn(_email, _pw);
      // プログレスインジケータ消去
      if (user.validated) {
        // Eメール確認済み
        final cid = user.getPowerCompanyID();

        if (cid == PowerCompanyIDs.Hokuriku || cid == PowerCompanyIDs.HokurikuDebug) {

          geofencingHokuriku.geofenceInitialize();

          await getUserInfoHokuriku(user);
          await getEventSettingHokuriku(user);

          Navigator.pop(context);
          gotoHrSelectPolePage(context);

          return;
        }

        if (cid == PowerCompanyIDs.Chugoku || cid == PowerCompanyIDs.ChugokuDebug) {

          geofencingChugoku.geofenceInitialize();

          await getUserInfoChugoku(user);
          await getEventSettingChugoku(user);

          Navigator.pop(context);
          gotoCgSelectPolePage(context);

          return;
        }

        if (cid == PowerCompanyIDs.Chubu || cid == PowerCompanyIDs.ChubuDebug) {

          geofencingChuden.geofenceInitialize();

          await getUserInfoChuden(user);
          await getEventSettingChuden(user);

          Navigator.pop(context);
          gotoChSelectPolePage(context);

          return;
        }

        debugPrint('goto unsupport.');
        Navigator.pop(context);
        gotoUnSupportedPage(context);
        return;
      }
      // Eメール未確認
      Navigator.pop(context);
      gotoUnAuthPage(context);
    } on FirebaseAuthException catch (e) {
      // プログレスインジケータ消去
      Navigator.pop(context);
      // Firebase が返したエラー
      if (e.code == 'invalid-email' ||
          e.code == 'user-disabled' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        // メールアドレス間違いもパスワード間違いも同じエラーメッセージにしておく。
        showPopup('メールアドレスまたはパスワードが違います', context);
        return;
      }
      showError(e, context);
    } on Exception catch (error) {
      // プログレスインジケータ消去
      Navigator.pop(context);
      // その他のエラー
      showError(error, context);
    }
  }

  Future<void> getUserInfoHokuriku(LoginUser user) async {
    UserDataHokuriku data;

    await getUserDataHokuriku(user).then((u){
      data = u;
    }).catchError((Object error){
      data = UserDataHokuriku()
        ..area = '０１６２';
    });

    widget.userDatahokuriku.area = data.area; //管理区をセット
    widget.userDatahokuriku.locationEnable = data.locationEnable; //位置情報の真偽をセット

    if (widget.userDatahokuriku.locationEnable) {

      await locationPermissionRequest();
      await notificationPermissionRequest();

      if (await isLocationStatusDisabled() || await isLocationStatusDenied()) {
        setUserLocation(user, null, null);
        widget.userDatahokuriku.locationEnable = false;
      }
      else {
        getLocationStream(
                (Position position){
              if (position != null){
                setUserLocation(user, position.latitude, position.longitude);
              }
              else {
                setUserLocation(user, null, null);
                widget.userDatahokuriku.locationEnable = false;
              }
            }
        );
      }
    }
    setUserDataHokuriku(user, widget.userDatahokuriku);
  }

  Future<void> getEventSettingHokuriku(LoginUser user) async {

    await getEventSettingsHokuriku(user.uid).then((eventSetting) {
      // 初回ログイン時（設定がnull）
      if (eventSetting == null) {
        eventSetting = EventSettingHokuriku();
        getEventWorksHokuriku(user, eventSetting.notNotificationStatus)
            .then((eventList) {
          for (final eventData in eventList) {
            geofencingHokuriku.addGeoRegist(
                user, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
          }
        }
        ).catchError((Object error) => print(error.toString()));
        setEventSettingHokuriku(user.uid, eventSetting);
      }
      else {
        getEventWorksHokuriku(user, eventSetting.notNotificationStatus)
            .then((eventList) {
          for (final eventData in eventList) {
            if (eventData.notification != false) {
              geofencingHokuriku.addGeoRegist(
                  user, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
            }
          }
        }
        ).catchError((Object error) => print(error.toString()));
      }
      widget.hrevent.setting = eventSetting;
    });
  }

  Future<void> getUserInfoChugoku(LoginUser user) async {
    UserDataChugoku data;

    await getUserDataChugoku(user).then((u){
      data = u;
    }).catchError((Object error){
      data = UserDataChugoku()
        ..company = 'energia'
        ..office = '広島ネットワークセンター';
    });

    widget.userDatachugoku.company = data.company;
    widget.userDatachugoku.office = data.office;
    widget.userDatachugoku.locationEnable = data.locationEnable;

    if (widget.userDatachugoku.locationEnable) {

      await locationPermissionRequest();
      await notificationPermissionRequest();

      if (await isLocationStatusDisabled() || await isLocationStatusDenied()) {
        setUserLocation(user, null, null);
        widget.userDatachugoku.locationEnable = false;
      }
      else {
        getLocationStream(
                (Position position){
              if (position != null){
                setUserLocation(user, position.latitude, position.longitude);
              }
              else {
                setUserLocation(user, null, null);
                widget.userDatachugoku.locationEnable = false;
              }
            }
        );
      }
    }
    setUserDataChugoku(user, widget.userDatachugoku);

  }

  Future<void> getEventSettingChugoku(LoginUser user) async {

    await getEventSettingsChugoku(user.uid).then((eventSetting) {
      ////初回ログイン時（設定がnull）

      if (eventSetting == null) {
        eventSetting = EventSettingChugoku();
        getEventWorksChugoku(user, widget.chugoku, eventSetting.notNotificationStatus)
            .then((eventList) {
          for (final eventData in eventList) {
            geofencingChugoku.addGeoRegist(
                user, widget.chugoku, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
          }
        }
        ).catchError((Object error) => print(error.toString()));
        setEventSettingChugoku(user.uid, eventSetting);
      }


      else {
        final geofencing = GeofencingChugoku(notify: true);
        geofencing.geofenceInitialize();

        getEventWorksChugoku(user, widget.chugoku, eventSetting.notNotificationStatus)
            .then((eventList) {
          for (final eventData in eventList) {
            if (eventData.notification != false) {
              geofencing.addGeoRegist(
                  user, widget.chugoku, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
            }
          }
        }
        ).catchError((Object error) => print(error.toString()));
      }
      widget.cgevent.setting = eventSetting;
    });
  }




  Future<void> getUserInfoChuden(LoginUser user) async {
    UserDataChuden data;

    await getUserDataChuden(user).then((u){
      data = u;
    }).catchError((Object error){
      data = UserDataChuden()
        ..branch = '名古屋支店'
        ..office = '熱田営業所';
    });


    widget.userDatachuden.branch = data.branch;
    widget.userDatachuden.office = data.office;
    widget.userDatachuden.locationEnable = data.locationEnable;

    if (widget.userDatachuden.locationEnable) {

      await locationPermissionRequest();
      await notificationPermissionRequest();

      if (await isLocationStatusDisabled() || await isLocationStatusDenied()) {
        setUserLocation(user, null, null);
        widget.userDatachuden.locationEnable = false;
      }
      else {
        getLocationStream(
                (Position position){
              if (position != null){
                setUserLocation(user, position.latitude, position.longitude);
              }
              else {
                setUserLocation(user, null, null);
                widget.userDatachuden.locationEnable = false;
              }
            }
        );
      }
    }
    setUserDataChuden(user, widget.userDatachuden);

    try {
      final branch = await getBrancheChuden(data.branch);
      final office = await getOfficeChuden(branch, data.office);

      setState(() {
        widget.chuden.office = office;
      });

    } on Exception catch (error) {
      showError(error, context);
    }
  }

  Future<void> getEventSettingChuden(LoginUser user) async {

    await getEventSettings(user.uid).then((eventSetting) {
      ////初回ログイン時（設定がnull）
      if (eventSetting == null) {
        eventSetting = EventSetting();
        getEventWorks(user, widget.chuden, eventSetting.notNotificationStatus)
            .then((eventList) {
          for (final eventData in eventList) {
            geofencingChuden.addGeoRegist(
                user, widget.chuden, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
          }
        }
        ).catchError((Object error) => print(error.toString()));
        setEventSetting(user.uid, eventSetting);
      }
      else {
        final geofencing = GeofencingChuden(notify: true);
        geofencing.geofenceInitialize();

        getEventWorks(user, widget.chuden, eventSetting.notNotificationStatus)
            .then((eventList) {
          for (final eventData in eventList) {
            if (eventData.notification != false) {

              geofencing.addGeoRegist(
                  user, widget.chuden, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
            }
          }
        }
        ).catchError((Object error) => print(error.toString()));
      }
      widget.chevent.setting = eventSetting;
    });
  }


}

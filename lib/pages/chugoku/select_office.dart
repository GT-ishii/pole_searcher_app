// ネットワークセンター選択画面
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chugoku/event.dart';


import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/chugoku/geofencing.dart';

class CgSelectOfficePage extends StatefulWidget {
  CgSelectOfficePage(this.auth, this.userData, this.chugoku, this.event);

  final Auth auth;
  final UserDataChugoku userData;
  final Chugoku chugoku;
  final CgEvent event;

  @override
  State<StatefulWidget> createState() => _SelectOfficePageState();
}

class _SelectOfficePageState extends State<CgSelectOfficePage> {
  final _formKey = GlobalKey<FormState>();

  // ネットワークセンター
  List<ChugokuOffice> _offices;
  List<String> _officeNames; // ネットワークセンターピッカで使うネットワークセンター名リスト
  ChugokuOffice _currentOffice;
  List<int> _officeSelected = [0];
  List<int> _oldOfficeSelected = [0];

  // ログインユーザ
  LoginUser _user = LoginUser();

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCg, CgNavigationMenuItem.setting.index, CgSelectOfficePath);

    // ログインユーザ取得
    widget.auth
        .getUser()
        .then((user) => setState(() {
          _user = user;
        }))
        .catchError((Object error) => showError(error, context));

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });*/

    // ネットワークセンター一覧取得
    getOffices()
        .then(_setupOffices) // ネットワークセンター一覧取得処理)
        .catchError((Object error) => showError(error, context));

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          gotoCgSettingPage(context);
          return Future.value(false);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('事業所設定'),
            centerTitle: true,
            actions: [
              showLogoutButton(context, widget.auth, _user)
            ],
          ),
          body: SingleChildScrollView(
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      addPadding(4),
                      _showOfficeButton(),
                      addPadding(4),
                      showSubmit(_formKey, '決定', const Size(210,50), 22, Colors.indigo, (_canSubmit()) ? _submit : null),
                      addPadding(1),
                    ],
                  )
              )
          ),
          bottomNavigationBar: cgBottomNavigationBar(context, widget.auth, CgNavigationMenuItem.setting.index, belongToCg, widget.chugoku),
        )
    );
  }

// _setupOffices は、ネットワークセンター一覧受信時の処理です。
  void _setupOffices(List<ChugokuOffice> offices) {
    final names = <String>[];

    // 名前リスト構築と営業所一覧を取得
    for (final office in offices) {
      names.add(office.name);
      //_officeSelected = [office.order];
    }

  // ネットワークセンターピッカボタンを表示させる。
    setState(() {
      _offices = offices;
      _officeNames = names;
      _officeSelected = [widget.chugoku.office.order];
      _oldOfficeSelected = _officeSelected;
      _currentOffice = widget.chugoku.office;
    });    //debugPrint('1_offices : $_offices / $_officeNames / $_currentOffice/ $_oldOfficeSelected');
  }

// ネットワークセンターピッカ表示処理
  Widget _showOfficeButton() {
    var name = '';
    VoidCallback callback;

    // これらは _setupBranches で同時に setState するので、
    // どれか一つだけ null チェックすれば良いはずだが、ここでは全部見ている。
    // debugPrint('2_offices : $_offices / $_officeNames / $_currentOffice');
    if (_offices != null && _officeNames != null && _currentOffice != null) {
      name = _currentOffice.name;
      callback = () {
        _officeSelected = List.from(_oldOfficeSelected);
        debugPrint('_officeSelected : $_officeSelected');
        debugPrint('_oldOfficeSelected : $_oldOfficeSelected');

        // ボタンを押されたらピッカを表示する。
        showPicker(context, [_officeNames], _officeSelected, null, null,
                (Picker picker, List<int> value) {
              ChugokuOffice selected;
              final idx = value[0];
              for (final o in _offices) {
                if (o.name == _officeNames[idx]) {
                  selected = o;
                  break;
                }
              }
              setState(() {
                _currentOffice = selected;
                _officeSelected = [idx];
                _oldOfficeSelected = _officeSelected;
              });
        });
      };
    }
    return showSubmitBox(_formKey, name, const Size(400,50), 22, Colors.black, callback);
  }

// _canSubmit は、決定ボタンが押せる状態かどうかを返します。
// 決定ボタンが押せる状態とは、ネットワークセンター一覧が取得完了している状態です。
  bool _canSubmit()
  {
    return _offices != null && _officeNames != null && _currentOffice != null
        && widget.chugoku.office.name != _currentOffice.name;
  }

// _submit は決定ボタン押下時のコールバックです。
// 選択されたネットワークセンターをセットして電柱選択画面に遷移します。
  void _submit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);

    setState(() {
      widget.chugoku.office = _currentOffice;
      widget.chugoku.line = null;
      widget.chugoku.pole = null;
      widget.event.data = null;


      widget.userData.office = widget.chugoku.office.name;
    });

    //firebase更新
    setUserDataChugoku(_user, widget.userData);
    //eventSetting取得
    getEventSetting();

    // プログレスインジケータ消去
    Navigator.pop(context);
    setBeforePage(belongToCg, CgNavigationMenuItem.search.index, CgSelectPolePath);
    setBeforePage(belongToCg, CgNavigationMenuItem.event.index, CgEventSelectPath);
    showPopup('事業所を\n変更しました', context);
  }

  void getEventSetting(){
    getEventSettingsChugoku(_user.uid).then((eventSetting){

      final geofencing = GeofencingChugoku(notify: true);
      geofencing.geofenceInitialize();

      getEventWorksChugoku(_user, widget.chugoku, eventSetting.notNotificationStatus).then((eventList){
        for (final eventData in eventList){
          if(eventData.notification != false) {
            geofencing.addGeoRegist(_user, widget.chugoku, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
          }
        }
      }).catchError((Object error) => print(error.toString()));
      widget.event.setting = eventSetting;
      setEventSettingChugoku(_user.uid, eventSetting);
    });
  }

}

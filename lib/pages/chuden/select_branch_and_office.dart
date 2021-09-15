// 支店・営業所選択画面
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';
import 'package:polesearcherapp/models/chuden/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/chuden/geofencing.dart';

class ChSelectBranchAndOfficePage extends StatefulWidget {
  ChSelectBranchAndOfficePage(this.auth, this.userData, this.chuden, this.event);

  final Auth auth;
  final UserDataChuden userData;
  final Chuden chuden;
  final ChEvent event;

  @override
  State<StatefulWidget> createState() => _ChSelectBranchAndOfficePageState();
}

class _ChSelectBranchAndOfficePageState extends State<ChSelectBranchAndOfficePage> {
  final _formKey = GlobalKey<FormState>();

  // 支店
  List<ChudenBranch> _branches;
  List<String> _branchNames; // 支店ピッカで使う支店名リスト
  ChudenBranch _currentBranch;
  List<int> _branchSelected = [0];
  List<int> _oldBranchSelected = [0];

  // 営業所ピック
  Map<String, List<ChudenOffice>> _offices;
  List<String> _officeNames; // 営業所ピッカで使う営業所名リスト
  ChudenOffice _currentOffice;
  List<int> _officeSelected = [0];
  List<int> _oldOfficeSelected = [0];

  // ログインユーザ
  LoginUser _user = LoginUser();

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCh, ChNavigationMenuItem.setting.index, ChSelectBranchPath);

    // ログインユーザ取得
    widget.auth
        .getUser()
        .then((user) => setState(() {
              _user = user;
            }))
        .catchError((Object error) => showError(error, context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });

    // 支店一覧取得
    getBranches()
        .then(_setupBranches) // 支店一覧取得処理
        .catchError((Object error) => showError(error, context));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        gotoChSettingPage(context);
        return Future.value(false);
      },
      child: Scaffold(
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
                    _showBranchButton(),
                    addPadding(2),
                    _showOfficeButton(),
                    addPadding(4),
                    showSubmit(_formKey, '決定', const Size(210,50), 22, Colors.indigo, (_canSubmit()) ? _submit : null),
                    addPadding(1),
                  ],
                )
            )
        ),
        bottomNavigationBar: chBottomNavigationBar(context, widget.auth, ChNavigationMenuItem.setting.index, belongToCh, widget.chuden),
      ),
    );
  }

// _setupOffices は営業所一覧受信時の処理です。
  void _setupOffices(ChudenBranch branch, List<ChudenOffice> offices) {
    if (_offices == null) {
      //_offices = <String, List<ChudenOffice>>{};
      _offices = {};
    }

    _offices[branch.name] = offices;
    if (_offices.length == _branches.length) {
      // 全支店の営業所一覧が揃ったら、営業所ピッカを表示させる。
      Navigator.pop(context);
      _updateOfficePicker(widget.chuden.office.branch);
      setState(() {
        _currentOffice = widget.chuden.office;
        _officeSelected = [widget.chuden.office.order];
        _oldOfficeSelected = [widget.chuden.office.order];
      });
    }
  }

// _setupBranches は、支店一覧受信時の処理です。
// 営業所一覧の取得を行い(非同期)、支店ピッカを表示させるため setState します。
  void _setupBranches(List<ChudenBranch> branches) {
    final names = <String>[];

    // 名前リスト構築と営業所一覧を取得
    for (final branch in branches) {
      names.add(branch.name);
      getOffices(branch).then((offices) {
        _setupOffices(branch, offices); // 営業所一覧取得処理
      }).catchError((Object error) {
        Navigator.pop(context);
        showError(error, context);
      });
    }

    // 支店ピッカボタンを表示させる。
    setState(() {
      _branches = branches;
      _branchNames = names;
      _currentBranch = widget.chuden.office.branch;
    });
  }

// 支店ピッカ表示処理
  Widget _showBranchButton() {
    var name = '';
    VoidCallback callback;

    // これらは _setupBranches で同時に setState するので、
    // どれか一つだけ null チェックすれば良いはずだが、ここでは全部見ている。
    if (_branches != null && _branchNames != null && _currentBranch != null) {
      name = _currentBranch.name;
      callback = () {
        _branchSelected = List.from(_oldBranchSelected);

        // ボタンを押されたらピッカを表示する。
        showPicker(context, [_branchNames], _branchSelected, null, null,
            (Picker picker, List<int> value) {
          // 選択時のコールバック処理
          _updateOfficePicker(_branches[value[0]]);
        });
      };
    }
    return showSubmitBox(_formKey, name, const Size(400,50), 22, Colors.black, callback);
  }

// 営業所ピッカ表示処理
  Widget _showOfficeButton() {
    var name = '';
    VoidCallback callback;

    // これらは _setupOffices で同時に setState するので、
    // どれか一つだけ null チェックすれば良いはずだが、ここでは全部見ている。
    if (_offices != null && _officeNames != null && _currentOffice != null) {
      name = _currentOffice.name;
      callback = _showOfficePicker; // ボタンを押されたらピッカを表示する。
    }
    return showSubmitBox(_formKey, name, const Size(400,50), 22, Colors.black, callback);
  }

// _updateOfficePicker は、営業所ピッカを更新します。
  void _updateOfficePicker(ChudenBranch branch) {
    final names = <String>[];
    for (final office in _offices[branch.name]) {
      names.add(office.name);
    }

    setState(() {
      _branchSelected = [branch.order];
      _oldBranchSelected = _branchSelected;
      _currentBranch = branch;
      _officeNames = names;
      _currentOffice = _offices[_currentBranch.name][0];
      _oldOfficeSelected = [0];
      _officeSelected = [0];
    });
  }

// _showOfficePicker は、営業所選択ピッカを表示します。
  void _showOfficePicker() {
    _officeSelected = List.from(_oldOfficeSelected);
    showPicker(context, [_officeNames], _officeSelected, null, null,
        (Picker picker, List<int> value) {
      // 決定時のコールバック処理。
      // 選択された名前を取り出し、その名前の営業所を検索する。
      ChudenOffice selected;
      final idx = value[0];
      for (final o in _offices[_currentBranch.name]) {
        if (o.name == _officeNames[idx]) {
          selected = o;
          break;
        }
      }
      // 見つけた営業所を _currentOffice にセットして再描画
      setState(() {
        _currentOffice = selected;
        _officeSelected = [idx];
        _oldOfficeSelected = _officeSelected;
      });
    });
  }

  // _canSubmit は、決定ボタンが押せる状態かどうかを返します。
  // 決定ボタンが押せる状態とは、支店、営業所一覧が取得完了している状態です。
  bool _canSubmit()
  {
    return _branches != null && _branchNames != null && _currentBranch != null
        && _offices != null && _officeNames != null && _currentOffice != null
        && widget.chuden.office.name != _currentOffice.name;
  }

  // _submit は決定ボタン押下時のコールバックです。
  // 選択された支店と営業所をセットして電柱選択画面に遷移します。
  void _submit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);

    setState(() {
      widget.chuden.office = _currentOffice;
      widget.chuden.pole = null;
      widget.event.data = null;

      widget.userData.branch = widget.chuden.office.branch.name;
      widget.userData.office = widget.chuden.office.name;
    });

    //firebase更新
    setUserDataChuden(_user, widget.userData);
    //eventSetting取得
    getEventSetting();

    // プログレスインジケータ消去
    Navigator.pop(context);
    setBeforePage(belongToCh, ChNavigationMenuItem.search.index, ChSelectPolePath);
    setBeforePage(belongToCh, ChNavigationMenuItem.event.index, ChEventSelectPath);
    showPopup('事業所を\n変更しました', context);
  }

  void getEventSetting(){

    getEventSettings(_user.uid).then((eventSetting){

      final geofencing = GeofencingChuden(notify: true);
      geofencing.geofenceInitialize();

      getEventWorks(_user, widget.chuden, eventSetting.notNotificationStatus).then((eventList){
        for (final eventData in eventList){
          if(eventData.notification != false) {
            geofencing.addGeoRegist(_user, widget.chuden, eventData.id, eventData.latitude, eventData.longitude, eventNotificationRadius);
          }
        }
      }).catchError((Object error) => print(error.toString()));
      widget.event.setting = eventSetting;
      setEventSetting(_user.uid, eventSetting);
    });
  }

}

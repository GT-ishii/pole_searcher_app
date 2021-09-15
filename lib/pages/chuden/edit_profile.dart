// プロフィール編集画面
import 'package:flutter/material.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

class ChEditProfilePage extends StatefulWidget {
  ChEditProfilePage(this.auth, this.chuden);

  final Auth auth;
  final Chuden chuden;

  @override
  _ChEditProfilePageState createState() => _ChEditProfilePageState();
}

class _ChEditProfilePageState extends State<ChEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  String _oldPw = '';
  String _newPw = '';
  bool _canSubmit = false;
  bool _hideOld = true;
  bool _hideNew = true;
  LoginUser _user = LoginUser();
  String _email = '';

  @override
  void initState() {
    super.initState();

    setBeforePage(
        belongToCh, CgNavigationMenuItem.setting.index, ChEditProfilePath);

    // ユーザ情報を取得
    widget.auth.getUser().then((user) =>
        setState(() {
          _user = user;
        }))
        .catchError((Object error) =>
          showError(error, context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスワード変更'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              addPadding(2),
              showPasswordChange(
                '現在のパスワード', FocusNode(), _hideOld, _cbOldPw, _cbHideOldPw),
              showPasswordChange(
                '新しいパスワード', FocusNode(), _hideNew, _cbNewPw, _cbHideNewPw),
              addPadding(1),
              showSubmit(
                _formKey, '変更', const Size(210,50), 22, Colors.indigo,
                  _canSubmit ? _chPw : null),
            ],
          ),
        )
      ),
      bottomNavigationBar: chBottomNavigationBar(
        context, widget.auth, ChNavigationMenuItem.setting.index, belongToCh, widget.chuden)
    );
  }

  void _cbOldPw(String pw) {
    setState(() {
      _oldPw = pw;
      _canSubmit = _checkCanSubmit();
    });
  }

  void _cbNewPw(String pw) {
    setState(() {
      _newPw = pw;
      _canSubmit = _checkCanSubmit();
    });
  }

  void _cbHideOldPw(bool b) {
    setState(() {
      _hideOld = b;
    });
  }

  void _cbHideNewPw(bool b) {
    setState(() {
      _hideNew = b;
    });
  }

  bool _checkCanSubmit() {
    return minimumPWLength <= _oldPw.length && minimumPWLength <= _newPw.length;
  }

  void _chPw() {
    debugPrint(_oldPw);
    debugPrint(_newPw);
    _email = _user.email;

    // パスワード変更処理
    showProgressIndicator(context);
    widget.auth.reauthenticateWithCredential(_email, _oldPw).then((_){
      widget.auth.updatePassword(_newPw).then((_){
        Navigator.pop(context);
        gotoLoginPage(context);
        debugPrint('Successful change Password');
        showPopup('パスワード変更完了', context);
      }).catchError((Object error) {
        Navigator.pop(context);
        debugPrint('Password change error : ${error.toString()}');
        showPopup('パスワード変更失敗', context);
      });
    }).catchError((Object error){
      Navigator.pop(context);
      debugPrint('Authenticate error : ${error.toString()}');
      showPopup('パスワード変更失敗', context);
    });
  }
}

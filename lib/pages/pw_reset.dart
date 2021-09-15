// パスワード再発行画面
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

class PwResetPage extends StatefulWidget {
  PwResetPage(this.auth);

  final Auth auth;

  @override
  State<StatefulWidget> createState() => _PwResetPageState();
}

class _PwResetPageState extends State<PwResetPage> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  bool _canPwReset;

  @override
  void initState() {
    _email = '';
    _canPwReset = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('パスワード再発行'),
        ),
        body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      showTextInput(TextInputType.emailAddress, 'メールアドレス',
                          Icons.mail, checkValidateEmail, _cbEmail),
                      addPadding(2),
                      showSubmit(_formKey, 'メール送信', const Size(210,50), 20, Colors.indigo,
                          _canPwReset ? _sendPwResetMail : null),
                    ],
                  ),
                ),
              ],
            )));
  }

  // _checkCanPwReset は、入力されたメールアドレスが有効か確認します。
  bool _checkCanPwReset() {
    return validateEmail(_email);
  }

  // cbEmail は、入力欄が変化する度に呼ばれるコールバックです。
  // パスワード再発行ボタンが押せる状態かどうかを判断し、状態を更新します。
  void _cbEmail(String email) {
    setState(() {
      _email = email;
      _canPwReset = _checkCanPwReset();
    });
  }

// _sendPwResetMail は、パスワード再発行ボタンが押されたときのコールバックです。
  void _sendPwResetMail() {
    widget.auth.sendPasswordResetEmail(_email).then((_){
      showPopup('$_email 宛にメールを送信しました。', context);
    }).catchError((Object error) {
      showPopup('$_email 宛にメールを送信できませんでした。', context);
    });
  }
}

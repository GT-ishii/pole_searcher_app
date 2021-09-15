// 未承認ユーザ画面
import 'package:flutter/material.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/services/auth.dart';

class UnAuthPage extends StatefulWidget {
  UnAuthPage(this.auth);

  final Auth auth;

  @override
  _UnAuthPageState createState() => _UnAuthPageState();
}

class _UnAuthPageState extends State<UnAuthPage> {
  final _formKey = GlobalKey<FormState>();
  LoginUser _user = LoginUser();
  bool _canGoNext = false;

  @override
  void initState() {
    super.initState();
    widget.auth.getUser().then((user) => setState(() {
          _user = user;
          debugPrint(user.toString());
        })).catchError((Object error) => showError(error, context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー認証'),
      ),
      body: SingleChildScrollView(
          child: Form(
            key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  showHeader('${_user.name} 様'),
                  showText('メールアドレスの確認がまだ完了していません。下のボタンを押すと、確認 URL を記載したメールが送られます。'),
                  addPadding(1),
                  showSubmit(
                      _formKey, '確認メール送信', const Size(210,50), 20, Colors.indigo, _showVerifyEmailSentDialog),
                  addPadding(1),
                  showText('''
      メールを送信したら、左上の「＜」ボタンでログイン画面に戻ってください。
      
      メールを受信して、本文にある URL にアクセスしたら確認完了ですので、もう一度ログインしてください。
      '''),
                ],
              ),
          )
      ),
    );
  }

  void _showVerifyEmailSentDialog() {
    widget.auth.sendEmailVerification().then((_) {
      showPopup('認証ページへのリンクをメールで送りました', context);
      setState(() {
        _canGoNext = true;
      });
    });
  }
}

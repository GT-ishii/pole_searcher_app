// 未実装画面
import 'package:flutter/material.dart';
import 'package:polesearcherapp/pages/parts.dart';

class UnSupportedPage extends StatelessWidget {
  UnSupportedPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showText('未実装の機能です。左上の「<」ボタンで前のページに戻ってください'),
          ],
        ),
      ),
    );
  }
}

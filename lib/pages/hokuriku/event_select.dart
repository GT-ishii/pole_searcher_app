// 事象管理画面
import 'package:flutter/material.dart';

import 'package:polesearcherapp/services/auth.dart';

import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/page_list.dart';

class HrEventSelectPage extends StatefulWidget {
  HrEventSelectPage(this.auth, this.hokuriku);

  final Auth auth;
  final Hokuriku hokuriku;

  @override
  _HrEventSelectPageState createState() => _HrEventSelectPageState();
}

class _HrEventSelectPageState extends State<HrEventSelectPage> {
  final _formKey = GlobalKey<FormState>();

  LoginUser _user = LoginUser();

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToHr, HrNavigationMenuItem.event.index, HrEventSelectPath);

    // ログインユーザ取得
    widget.auth
        .getUser()
        .then((user) => setState(() {
          _user = user;
       })
      ).catchError((Object error) => showError(error, context));
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('事象管理'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            showLogoutButton(context, widget.auth, _user)
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
              child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[

                          addPadding(2),

                          showSubmit(_formKey, '事象登録', const Size(210, 50), 22, Colors.indigo, _addEvent),
                          addPadding(3),

                          showSubmit(_formKey, '事象一覧', const Size(210, 50), 22, Colors.indigo, _eventList),
                          addPadding(3),

                          showSubmit(_formKey, '作業一覧', const Size(210, 50), 22, Colors.indigo, _eventListWork),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      )
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.event.index, belongToHr, widget.hokuriku),
      )
    );
  }

  //メモ
  void _addEvent() {
    gotoHrEventAddPage(context);
  }

  void _eventList(){
    gotoHrEventListPage(context);
  }

  void _eventListWork(){
    gotoHrEventListWorkPage(context);
  }

}

// チャット画面
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/pages/chat_parts/chatModel.dart';


import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

enum ChatListTypeChugoku {
  oneLine,
  twoLine,
}

class CgChatListPage extends StatefulWidget {
  CgChatListPage(this.auth, this.chugoku, this.chatList, this.type);


  final ChatListTypeChugoku type;
  final Auth auth;
  final Chugoku chugoku;
  final List<ChatModel> chatList;


  @override
  _CgChatListPageState createState() => _CgChatListPageState();
}

class _CgChatListPageState extends State<CgChatListPage> {
  LoginUser _user = LoginUser();


  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCg, CgNavigationMenuItem.chat.index, CgChatListPath);

    //ログインユーザ取得
    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('トークリスト(中国)'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            showLogoutButton(context, widget.auth, _user)
          ],
        ),

        body: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (int index = 0; index < widget.chatList.length; index++)
                ListTile(
                  leading: ExcludeSemantics(
                    child: CircleAvatar(
                        backgroundImage:  NetworkImage(widget.chatList[index].avatarUrl)),
                  ),
                  title: Text(
                    widget.chatList[index].name,
                  ),
                  subtitle: widget.type == ChatListTypeChugoku.twoLine
                      ? Text(
                    widget.chatList[index].message,
                    maxLines: 2,
                  )
                      : null,
                  onTap: () {
                    Future<void>.delayed(const Duration(milliseconds: 200)).then((value){
                      gotoCgChatPage(context);
                    });
                  },
                ),
            ],
          ),
        ),


        bottomNavigationBar: cgBottomNavigationBar(
            context, widget.auth, CgNavigationMenuItem.chat.index, belongToCg,
            widget.chugoku),
      ),
    );
  }
}

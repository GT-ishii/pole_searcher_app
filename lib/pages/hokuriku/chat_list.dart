// チャット画面
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/pages/chat_parts/chatModel.dart';


import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

enum ChatListTypeHokuriku {
  oneLine,
  twoLine,
}

class HrChatListPage extends StatefulWidget {
  HrChatListPage(this.auth, this.hokuriku, this.chatList, this.type);


  final ChatListTypeHokuriku type;
  final Auth auth;
  final Hokuriku hokuriku;
  final List<ChatModel> chatList;


  @override
  _HrChatListPageState createState() => _HrChatListPageState();
}

class _HrChatListPageState extends State<HrChatListPage> {
  LoginUser _user = LoginUser();


  @override
  void initState() {
    super.initState();

    setBeforePage(belongToHr, HrNavigationMenuItem.chat.index, HrChatListPath);

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
          title: const Text('トークリスト'),
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
                  subtitle: widget.type == ChatListTypeHokuriku.twoLine
                      ? Text(
                    widget.chatList[index].message,
                    maxLines: 2,
                  )
                      : null,
                  onTap: () {
                    Future<void>.delayed(const Duration(milliseconds: 200)).then((value){
                      gotoHrChatPage(context);
                    });
                  },
                ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){

            getUserList();
            return;
          },
        ),


        bottomNavigationBar: hrBottomNavigationBar(
            context, widget.auth, HrNavigationMenuItem.chat.index, belongToHr,
            widget.hokuriku),
      ),
    );
  }

  Future<void> getUserList()async{
    //UserDataHokuriku data;
    final ds = await FirebaseFirestore.instance
        .collection('users')
        .where('leaduid' '==' 'hrd').where('leaduid' '==' 'hrr')
        .get();

    List<DocumentSnapshot>documents = ds.docs;
    print(documents.length);
    print(documents[0].data());

  }
}

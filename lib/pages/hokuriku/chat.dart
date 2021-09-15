// チャット画面
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/pages/chat_parts/chat_message.dart';
import 'package:polesearcherapp/pages/chat_parts/chat_user.dart';
import 'package:polesearcherapp/services/auth.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/chat_parts/chatModel.dart';

import 'package:polesearcherapp/services/auth.dart';

class HrChatPage extends StatefulWidget {
  HrChatPage(this.auth, this.hokuriku);
  final Auth auth;
  final Hokuriku hokuriku;

  @override
  _HrChatPageState createState() => _HrChatPageState();
}

class _HrChatPageState extends State<HrChatPage> {
  LoginUser _user = LoginUser();
  Map<String, dynamic> _chatUser;
  Map<String, dynamic> _chatMessage;
  ChatMessage chatMessage = ChatMessage();
  String _inputMessage;
  String _beforeDate = null;

  final messageTextInputCtl = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState(){
    super.initState();

    _inputMessage = '';
    setBeforePage(belongToHr, HrNavigationMenuItem.chat.index, HrChatPath);

    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('チャット'),
        ),

        body: Stack(
            alignment: Alignment.bottomCenter,
            children : <Widget> [

              GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child:StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('company')
                        .doc(HokurikuID)
                        .collection('rooms')
                        .doc('room1')
                        .collection('messages')
                        .orderBy('date', descending: true) //降順
                        .snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        final List<DocumentSnapshot>documents = snapshot.data.docs;

                        return ListView(
                          reverse: true,//リスト反転
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 10.0, right: 5.0, bottom: 150.0, left: 5.0),
                          children: [

                            for (int index = 0; index < documents.length; index++)

                            showMessage(documents, index),

                          ],
                        );
                      }
                      return Center(
                        child: Text('読み込み中…'),
                      );
                  },
                  )
              ),
              //入力カーソル
              showInputMessage()
            ]
        ),
      );
    }

  Widget showInputMessage(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Container(
            color: Colors.white,
            child: Column(
                children: <Widget>[
                  new Form(
                      key: _formKey,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            new Flexible(
                                child: new TextFormField(
                                  controller: messageTextInputCtl,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  minLines: 1,
                                  onChanged: (value){
                                    setState(() {
                                      _inputMessage = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'メッセージを入力',
                                      //未実装のカメラ機能アイコン
                                      prefixIcon: Icon(Icons.camera_alt_outlined),
                                      suffixIcon: _inputMessage == '' || _inputMessage == null || _inputMessage == '\n'
                                          ?IconButton(
                                            icon: Icon(Icons.send),
                                            color: Colors.grey,
                                            onPressed: (){
                                              Timer(
                                                Duration(milliseconds: 200),
                                                _scrollToBottom,
                                              );
                                            },
                                          )
                                          :IconButton(
                                            icon: Icon(Icons.send),
                                            color: Colors.indigo,
                                            onPressed: (){
                                              Timer(
                                                Duration(milliseconds: 200),
                                                _scrollToBottom,
                                              );
                                              //ボタン押下で入力した文字を送信（改行対応）
                                              //入力文字を関数へ渡す
                                              _addMessage(messageTextInputCtl.text);
                                              //FocusScope.of(context).unfocus();
                                              messageTextInputCtl.clear();
                                              setState(() {
                                                _inputMessage = '';
                                              });
                                            },
                                          )
                                  ),
                                )),
                          ]
                      )
                  ),
                ]
            )
        ),
      ],
    );
  }

  Widget showMessage(List<DocumentSnapshot> documents, int index){
    String uid = documents[index]['user']['uid'];
    String date =   documents[index]['date'];
    String message =  documents[index]['message'];
    String name = documents[index]['user']['name'];

    if( index == 0 ){
      _beforeDate = date.substring(0,10);
    }
    //リストの最後は必ず表示
    if( index == documents.length - 1 ) {
      //最後と一個前が違う日付なら一個前の日付も表示
      if(_beforeDate != date.substring(0,10)){
        return Center(
          child: Column(
            children: [
              addPadding(2),
              Text(date.substring(0, 10)),
              addPadding(2),

              uid == _user.uid
                  ? SendMessage(message, date)
                  : ReceivedMessage(message, date, name),

              addPadding(2),
              Text(_beforeDate),
              addPadding(2),
            ],
          ),
        );
      }
      else{
        return Center(
          child: Column(
            children: [
              addPadding(2),
              Text(date.substring(0, 10)),
              addPadding(2),

              uid == _user.uid
                  ? SendMessage(message, date)
                  : ReceivedMessage(message, date, name),
            ],
          ),
        );
      }
    }
    //一個前と日付が違う時日付を表示
    if(_beforeDate.substring(0,10) != date.substring(0,10) ){

      Widget messagedate = Center(
        child: Column(
          children: [

            uid == _user.uid
                ? SendMessage(message,date)
                : ReceivedMessage(message,date,name),

            addPadding(2),
            Text(_beforeDate.substring(0,10)),
            addPadding(2),
          ],
        ),
      );
      _beforeDate = date.substring(0,10);
      return messagedate;
    }
    else{
      _beforeDate = date.substring(0,10);
      return uid == _user.uid
          ? SendMessage(message,date)
          : ReceivedMessage(message,date,name);
    }
  }

  //自分が送ったメッセージ
  Widget SendMessage(String message, String date){

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            date.substring(10,16),//投稿時間 時分
            style: const TextStyle(fontSize: 10),
          ),

          const SizedBox(width: 5),
          Column(
            children: [
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  message,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //相手から送られてきたメッセージ
  Widget ReceivedMessage(String message,String date,String userName){

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //アイコンの画像(現在はサンプル)
        CircleAvatar(
          backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/hokuriku-test.appspot.com/o/icon.jpeg?alt=media&token=e65b8fed-fd1d-4451-b8d5-08c6892ea298'),
        ),
        const SizedBox(width: 5),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,//名前
                  style: const TextStyle(fontSize: 10),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 15,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(100, 221, 238, 255),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Text(
                    message,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 5),

            Text(
              date.substring(10,16),//投稿時間 時分
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
  }

  //メッセージ追加
  Future<void> _addMessage(String message) async{
    Map<String, dynamic>chatMessage = {
      'date': dateTimeToString(DateTime.now(),true),
      'image': null,
      'video': null,
      'message': message,
      'user':_chatUser,
      'isMine':true
    };
    setState(() {
      _chatMessage = chatMessage;
    });

    await FirebaseFirestore.instance
        .collection("company")
        .doc(HokurikuID)
        .collection("rooms")
    //room名は今後指定できるようにする
        .doc('room1')
        .collection('messages')
        .doc()
        .set(_chatMessage);
  }

  //下までスクロール
  void _scrollToBottom(){
    _scrollController.animateTo(
      0.0,
      //_scrollController.position.maxScrollExtent + MediaQuery.of(context).viewInsets.bottom,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
    );
  }

  //ログインユーザのデータをマップに変換
  void getUserInfo(){
    widget.auth.getUser().then((user)
    {
      setState(() {
        _user = user;
      });
      Map<String, dynamic> chatUser = {
        'uid': _user.uid as String,
        'name': _user.name as String,
        'email': _user.email as String,
      };
      setState(() {
        _chatUser = chatUser;
      });
    });
    return;
  }

  ChatMessage getMessageClass(Map <String, dynamic> chatMessage){
    return ChatMessage.fromJson(chatMessage);
  }
}





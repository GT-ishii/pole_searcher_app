import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polesearcherapp/models/specification.dart';

class ChatUser {
  ChatUser()
      : uid = '',
        name = '',
        email = '',
        avatar = '';

  ChatUser.fromJson(Map<String,dynamic> chatUser)
      : uid = chatUser['uid'] as String,
        name = chatUser['name'] as String,
        email = chatUser['email'] as String;

  String uid;
  String name;
  String email;
  String avatar;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    try {
      data['uid'] = uid;
      data['name'] = name;
      data['avatar'] = avatar;
    } catch (e) {
      print(e);
    }

    return data;
  }
}


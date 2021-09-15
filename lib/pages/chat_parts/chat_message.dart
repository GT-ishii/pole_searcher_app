import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polesearcherapp/pages/chat_parts/chat_user.dart';
import 'package:polesearcherapp/models/specification.dart';

class ChatMessage {
  ChatMessage()
       :
        date = '',
        message = '',
        user = null,
        image = '',
        video = '',
        isMine = 'true';

  String isMine;
  String date;
  String message;
  ChatUser user;
  String image;
  String video;

  final List<ChatMessage> Data = [];

  ChatMessage.fromJson(Map <String, dynamic> chatMessage)
      : date = chatMessage['date'] as String,
        message = chatMessage['message'] as String,
        user = ChatUser.fromJson(chatMessage['user']),
        image = chatMessage['image'] as String,
        video = chatMessage['video'] as String;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    try {
      data['date'] = this.date;
      data['message'] = this.message;
      data['image'] = this.image;
      data['video'] = this.video;
      data['user'] = user.toJson();
    } catch (e, stack) {
      print('ERROR caught when trying to convert ChatMessage to JSON:');
      print(e);
      print(stack);
    }
    return data;
  }
}



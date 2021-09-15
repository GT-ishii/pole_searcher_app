import 'package:intl/intl.dart';



class ChatModel {
  final String avatarUrl;
  final String name;
  final DateFormat datetime;
  final String message;

  ChatModel({this.avatarUrl, this.name, this.datetime, this.message});

  static final List<ChatModel> dummyData = [
    ChatModel(
      //アイコンはテスト用
      avatarUrl: "https://firebasestorage.googleapis.com/v0/b/hokuriku-test.appspot.com/o/icon.jpeg?alt=media&token=e65b8fed-fd1d-4451-b8d5-08c6892ea298",
      name: "全体チャット",
      datetime: DateFormat('HH:mm'),
      message: "全体チャットルームです",
    ),
  ];
}
/*
class ChatMessageModel {
  final String avatarUrl;
  final String name;
  final String datetime;
  final String message;
  final bool isMine;

  ChatMessageModel({this.avatarUrl, this.name, this.datetime, this.message, this.isMine});

  static final List<ChatMessageModel> dummyData = [
/*
    ChatMessageModel(
      avatarUrl: "https://randomuser.me/api/portraits/men/83.jpg",
      name: "モーフィアス",
      datetime: DateFormat('HH:mm').format(DateTime.now()),
      message: "これが最後のチャンスだ。後戻りはできない",
      isMine: false,
    ),
    ChatMessageModel(
      avatarUrl: "https://randomuser.me/api/portraits/men/49.jpg",
      name: "自分",
      datetime: DateFormat('HH:mm').format(DateTime.now()),
      message: "どういうことだ？",
      isMine: true,
    ),

 */
  ];
}

 */
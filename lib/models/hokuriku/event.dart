// 北陸電力専用モデル
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:polesearcherapp/pages/common.dart';

import 'package:polesearcherapp/models/company.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';

import 'package:polesearcherapp/services/permission.dart';
import 'package:polesearcherapp/models/specification.dart';


class HrEvent {
  // 空インスタンス生成
  HrEvent() :
        data = EventData(),
        setting = EventSettingHokuriku();

  EventData data; // イベント情報
  EventSettingHokuriku setting;
}
//事象管理に使うステータスクラス
class EventData {
  EventData()
      : id = '',
        type = [],
        title = '',
        memo = '',
        image = [],
        updatedAt = '',
        status = '',
        latitude = 0,
        longitude = 0,
        distance = 0,
        worker = '',
        poleSearch = false,
        notification = false;

  EventData.fromDocument(DocumentSnapshot ds)
      : id = ds.id,
        type = ds.data()['type'].cast<String>() as List<String>,
        title = ds.data()['title'] as String,
        memo = ds.data()['memo'] as String,
        image = ds.data()['image'].cast<String>() as List<String>,
        updatedAt = ds.data()['updated_at'] as String,
        status = ds.data()['status'] as String,
        eventPole = ds.data()['event_pole'] as Map,
        latitude = ds.data()['located_at'].latitude as double,
        longitude = ds.data()['located_at'].longitude as double,
        worker = ds.data()['worker'] as String;

  String id;
  List<String> type;
  Map eventPole;
  String title;
  String memo;
  List<String> image;
  String updatedAt;
  String status;
  double latitude; // 緯度
  double longitude; // 経度
  double distance;
  String worker;
  bool poleSearch;
  bool notification;
}

class EventSettingHokuriku {
  EventSettingHokuriku()
      : notNotificationStatus = ['新規', '完了'];

  EventSettingHokuriku.fromDocument(DocumentSnapshot ds)
      : notNotificationStatus =
  ds.data()['not_notification_status'].cast<String>() as List<String>;

  List<String> notNotificationStatus;
}

Future<List<EventData>> getEvents(
    LoginUser user, Hokuriku hokuriku, String ID, {bool offline}) async {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  final qs = await FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .orderBy('updated_at', descending: true)
      .get();

  if (qs == null || qs.docs == null ||
      (qs.metadata.isFromCache && offline == false)) {
    throw ArgumentError('事象を取得できませんでした');
  }

  final ds = qs.docs;
  final ret = <EventData>[];

  for (final event in ds) {
    ret.add(EventData.fromDocument(event));
  }

  final isNotLocation =
      await isLocationStatusDisabled() || await isLocationStatusDenied();
  if (isNotLocation != true){
    await getDistances(ret);
  }

  ret.sort((a, b){
    if (a.status == b.status) {
      return 0;
    }
    if (a.status == '完了') {
      return 1;
    }
    return -1;
  });

  return ret;
}

Future<List<EventData>> getEventWorksHokuriku(
    LoginUser user, List<String> notNotificationStatus) async {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  final qs = await FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .orderBy('updated_at', descending: true)
      .get();

  if (qs == null || qs.docs == null) {
    throw ArgumentError('作業一覧を取得できませんでした');
  }

  final ds = qs.docs;
  final ret = <EventData>[];

  for (final event in ds) {
    if (event.data()['worker'] == user.email) {
      ret.add(EventData.fromDocument(event));
    }
  }

  await getSetting(ret, notNotificationStatus);

  final isNotLocation =
      await isLocationStatusDisabled() || await isLocationStatusDenied();
  if (isNotLocation != true){
    await getDistances(ret);
  }

  ret.sort((a, b){
    if (a.status == b.status) {
      return 0;
    }
    if (a.status == '完了') {
      return 1;
    }
    return -1;
  });

  return ret;
}

Future<EventData> getEventFromId(
    String uid, String area, String id, String companyID) async {

  String collectionID;

  final cid = uid.substring(0, 3); // 前3文字が電力会社ID
  if (!Abbrev2CompanyID.containsKey(cid)) {
    return null;
  }

  if (Abbrev2CompanyID[cid] == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (Abbrev2CompanyID[cid] == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  final ds = await FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .doc(id)
      .get();

  if (ds == null || ds.data == null) {
    return null;
  }

  return EventData.fromDocument(ds);
}

Future<void> getDistances(List<EventData> datas) async {
  final pos = await getLocation();
  for(final data in datas) {
    data.distance =
    await getDistance(pos.latitude, pos.longitude, data.latitude, data.longitude);
  }
}

Future<void> getSetting(
    List<EventData> datas, List<String> notNotificationStatus) async {

  for(final data in datas) {
    if (notNotificationStatus.contains(data.status)) {
      data.notification = false;
    } else {
      data.notification = true;
    }
  }
}

Future<List<String>> setEventImage(List<String> images) async {
  final profileUrls = <String>[];

  for (final imagePath in images) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final _storage = FirebaseStorage.instance;
    final reference = _storage.ref().child(timestamp);
    await reference.putFile(File(imagePath));
    final profileUrl = await reference.getDownloadURL()
        .catchError((Object error) =>
    throw ArgumentError('事象を登録できませんでした'));
    profileUrls.add(profileUrl);
  }
  return profileUrls;
}

Future<void> removeEventImage(List<String> downloadURLs)  async{
  for (final url in downloadURLs) {
    await FirebaseStorage.instance.refFromURL(url).delete()
        .catchError((Object error) => '');
  }
}

void setEvent(LoginUser user, Hokuriku hokuriku, String ID, EventData addData) {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  final documentReference = FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .doc();

  documentReference
      .set(<String, dynamic>{
    'id': documentReference.id,
    'type': addData.type,
    'event_pole': addData.eventPole,
    'title': addData.title,
    'memo': addData.memo,
    'image': addData.image,
    'located_at': GeoPoint(
        addData.latitude, addData.longitude),
    'updated_at': addData.updatedAt,
    'status': '新規',
  });
}

void updateEvent(
    LoginUser user, Hokuriku hokuriku, String ID, EventData addData) {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .doc(addData.id)
      .update(<String, dynamic>{
    'type' : addData.type,
    'event_pole': addData.eventPole,
    'title': addData.title,
    'memo': addData.memo,
    'image': addData.image,
    'updated_at': addData.updatedAt,
  });
}

void updateEventStatus(
    LoginUser user, Hokuriku hokuriku, String id, String status, String companyID) {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .doc(id)
      .update(<String, dynamic>{
    'status': status,
  });
}

void setEventWorker(LoginUser user, Hokuriku hokuriku, String id, String companyID)  {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .doc(id)
      .update(<String, dynamic>{
    'worker': user.email,
  });
}

void deleteEvent (LoginUser user, Hokuriku hokuriku, String id,String companyID) {

  String collectionID;

  if (user.getPowerCompanyID() == PowerCompanyIDs.Hokuriku) {
    collectionID = 'event';
  }
  else if (user.getPowerCompanyID() == PowerCompanyIDs.HokurikuDebug) {
    collectionID = 'debug_event';
  }

  FirebaseFirestore.instance
      .collection('event')
      .doc(HokurikuID)
      .collection(collectionID)
      .doc(id)
      .delete();
}

Future<EventSettingHokuriku> getEventSettingsHokuriku(String uid) async {

  final ds = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('event_settings')
      .doc('event_settings')
      .get();

  bool tf = ds.data() == null || ds == null;
  print(tf);
  if (tf) {
    return null;
  }

  return EventSettingHokuriku.fromDocument(ds);
}

void setEventSettingHokuriku(String uid, EventSettingHokuriku eventSetting){
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('event_settings')
      .doc('event_settings')
      .set(<String, dynamic>{
    'not_notification_status' : eventSetting.notNotificationStatus
  }, SetOptions(merge: true));
}

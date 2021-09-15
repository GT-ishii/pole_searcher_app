import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:package_info/package_info.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sprintf/sprintf.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/page_list.dart';

// タブ画面一覧
List<String> hrBeforePages = [
  HrSelectBranchPath,
  HrSelectPolePath,
  HrEventSelectPath,
  HrSettingPath,
  HrChatListPath,
];

List<String> cgBeforePages = [
  CgSelectOfficePath,
  CgSelectPolePath,
  CgEventSelectPath,
  CgSettingPath,
  CgChatListPath,
];

List<String> chBeforePages = [
  ChSelectBranchPath,
  ChSelectPolePath,
  ChEventSelectPath,
  ChSettingPath,
  ChChatListPath,
];

//所属会社(belongToで判断)によってリストの中身を書き換える(ページパスを更新する)
void setBeforePage(int belongTo, int menuIndex, String pagePath){
  switch (belongTo) {
    case 1:
      //hkBeforePages[menuIndex] = pagePath;
      break;
    case 2:
      //thBeforePages[menuIndex] = pagePath;
      break;
    case 3:
      //tkBeforePages[menuIndex] = pagePath;
      break;
    case 4:
      hrBeforePages[menuIndex] = pagePath;
      break;
    case 5:
      chBeforePages[menuIndex] = pagePath;
      break;
    case 6:
      //ksBeforePages[menuIndex] = pagePath;
      break;
    case 7:
      cgBeforePages[menuIndex] = pagePath;
      break;
    case 8:
      //skBeforePages[menuIndex] = pagePath;
      break;
    case 9:
      //kyBeforePages[menuIndex] = pagePath;
      break;
    case 10:
      //okBeforePages[menuIndex] = pagePath;
      break;
  }
}

void initBeforePages(){
  hrBeforePages = [
    HrSelectBranchPath,
    HrSelectPolePath,
    HrEventSelectPath,
    HrSettingPath,
    HrChatListPath,
  ];
  cgBeforePages = [
    CgSelectOfficePath,
    CgSelectPolePath,
    CgEventSelectPath,
    CgSettingPath,
    CgChatListPath,
  ];
  chBeforePages = [
    ChSelectBranchPath,
    ChSelectPolePath,
    ChEventSelectPath,
    ChSettingPath,
    ChChatListPath,
  ];
}
//所属会社によってそれぞれのタブ画面のページパスを返す
List<String> getBeforePages (int belongTo){
  switch (belongTo) {
    case 1:
      //return hkBeforePages;
      break;
    case 2:
      //return thBeforePages;
      break;
    case 3:
      //return tkBeforePages;
      break;
    case 4:
      return hrBeforePages;
      break;
    case 5:
      return chBeforePages;
      break;
    case 6:
    //return ksBeforePages;return
      break;
    case 7:
      return cgBeforePages;
      break;
    case 8:
      //return skBeforePages;
      break;
    case 9:
      //return kyBeforePages;
      break;
    case 10:
      //return okBeforePages;
      break;
  }
}

StreamSubscription<Position> streamSubscription;

// アプリバージョンを取得
Future<Map> getVersions() async{
  Map<String, String> versions;
  final packageInfo = await PackageInfo.fromPlatform();
  versions = {'version': packageInfo.version, 'date': releaseDate};
  print(packageInfo.buildNumber);
  return versions;
}

String getAddressParts(String str){
  if (str.contains('Unnamed Road')) {
    return '';
  }
  return str;
}

// 日付→文字列 変換
String dateToString(DateTime date, bool time){
  initializeDateFormatting('ja_JP');

  String string;
  if (time)
    string = DateFormat('yyyy/MM/dd HH:mm').format(date);
  else
    string = DateFormat('yyyy/MM/dd').format(date);
  return string;
}

String dateTimeToString(DateTime date,bool time){
  initializeDateFormatting('ja_JP');

  String string;
  if (time)
    string = DateFormat('yyyy/MM/dd HH:mm:ss').format(date);
  else
    string = DateFormat('HH:mm').format(date);

  return string;
}


String checkValidateEmail(String email) {
  return validateEmail(email) ? 'OK' : '有効なメールアドレスを入力してください';
}

String checkValidateLine(String line) {
  return validateLineAndPole(line) ? 'OK' : '有効な線路を入力してください';
}

String checkValidatePole(String pole) {
  return validateLineAndPole(pole) ? 'OK' : '有効な電柱を入力してください';
}

// 現在地から目的地への誘導
//　GoogleMap起動
Future<void> goToNavigationMap(double latitude, double longitude) async {

  if (await MapLauncher.isMapAvailable(MapType.google)) {
    await MapLauncher.showDirections(
      mapType: MapType.google,
      destination: Coords(latitude, longitude),
      directionsMode: DirectionsMode.driving
    );
    return;
  }

  final ll = sprintf('%f,%f', [latitude, longitude]);
  final gmUrl = 'https://www.google.com/maps/dir/?api=1&destination=$ll&travelmode=driving';
  print('try to google');
  if (await canLaunch(gmUrl)) {
    // google map 起動
    await launch(gmUrl, universalLinksOnly: true);
    print('google map URL: $gmUrl');
    return;
  }

  final aUrl = 'https://maps.apple.com/maps?daddr=$ll&dirflg=d';
  if (await canLaunch(aUrl)) {
    // apple map 起動
    await launch(aUrl);
    print('apple map URL: $aUrl');
    return;
  }
  BuildContext context;
  showError('マップアプリの起動ができませんでした', context);
}

// 定期位置情報送信 開始
void getLocationStream (Function(Position) callback) {
  streamSubscription = Geolocator.getPositionStream(
      intervalDuration: const Duration(seconds: 60)).listen(callback);
}

// 定期位置情報送信 停止
void getLocationStreamCancel(){
  if (streamSubscription != null){
    streamSubscription.cancel();
  }
}

Future<Position> getLocation () async {
  final _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return _currentPosition;
}

Future<double> getDistance(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) async{

  final distanceInMeters = Geolocator.distanceBetween(
      startLatitude, startLongitude, endLatitude, endLongitude);

  final d = (distanceInMeters / 1000).toStringAsFixed(1);
  return double.parse(d);
}
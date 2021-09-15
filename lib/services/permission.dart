import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as location;


// 位置情報
Future<bool> isLocationStatusDisabled() async{
  return Permission.location.serviceStatus.isDisabled;
}

Future<bool> isLocationStatusDenied() async{
  return await Permission.location.request().isPermanentlyDenied || await Permission.location.status.isDenied;
}

Future<void> locationServiceRequest() async {
  await location.Geolocator.openLocationSettings();
}

Future<void> locationPermissionRequest() async{
  await Permission.location.request();
}

// 通知
Future<void> notificationPermissionRequest() async{
  await Permission.notification.request();
}

// カメラ
Future<bool> isCameraStatusDenied() async{
  final status = await Permission.camera.status;
  return status.isDenied;
}


// ファイル
// iOS
Future<bool> isPhotosStatusDenied() async{
  final status = await Permission.photos.status;
  return status.isDenied || status.isPermanentlyDenied;
}

// Android
Future<bool> isStorageStatusDenied() async{
  return Permission.storage.request().isPermanentlyDenied;
}

// アプリ設定ページへ遷移
void openAppSettingsPage(){
  openAppSettings();
}

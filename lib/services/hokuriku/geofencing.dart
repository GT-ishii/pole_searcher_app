
import 'dart:async';
import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';

import 'package:polesearcherapp/models/user.dart';

import 'package:polesearcherapp/models//hokuriku/hokuriku.dart';
import 'package:polesearcherapp/services/hokuriku/local_notification.dart';

class GeofencingHokuriku {
  GeofencingHokuriku({this.notify});

  bool notify;
  // コールバック確認用
  String cbTargetID;
  Geolocation cbTargetlocation;

  // ジオフェンス初期化
  void geofenceInitialize() {
    Geofence.initialize();
    Geofence.requestPermissions();
    Geofence.removeAllGeolocations();
    print('Geofence Initialize done');
  }

  Future<void> addGeoRegist(LoginUser user, String id, double latitude, double longitude, double radius) async{

    id = '${user.uid}/$id';

    final location = Geolocation(latitude: latitude, longitude: longitude, radius: radius, id: id);
    print('$id, (${location.latitude}, ${location.longitude})');

    try {
      await Geofence.addGeolocation(location, GeolocationEvent.entry);
    } on Exception catch (error) {
      throw ArgumentError(error);
    }
    Geofence.startListening(GeolocationEvent.entry, geofenceCallback);
  }

  // ジオフェンスコールバック
  void geofenceCallback(Geolocation value) {

    cbTargetID = value.id;
    cbTargetlocation = Geolocation(
        latitude: value.latitude, longitude: value.longitude, radius: value.radius);

    if (notify != false) {
      final localNotification = LocalNotification();
      localNotification.init();
      localNotification.callback(value);
    }
  }
}


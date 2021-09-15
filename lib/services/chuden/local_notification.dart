import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_geofence/Geolocation.dart';

import 'package:polesearcherapp/models/chuden/event.dart';

class LocalNotification {
  factory LocalNotification(){
    return _instance;
  }
  LocalNotification._();

  static LocalNotification _instance = LocalNotification._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Future<void> init() async {

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid = new AndroidInitializationSettings('ic_action_search');
    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocationLocation);
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);

  }

  Future<void> callback(Geolocation value) async {

    final geoID = value.id.split('/');
    final uid = geoID[0];
    final branch = geoID[1];
    final office = geoID[2];
    final id = geoID[3];

    var type = '';
    var pole = '';

    final data = await getEventFromId(uid, branch, office, id);
    if (data != null) {
      type = data.type.reduce((a, b){
        return '$a/$b';
      });
      if (data.eventPole != null) {
        pole = data.eventPole['pole'] as String;
      }
    }

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High,
        style: AndroidNotificationStyle.BigText, styleInformation: BigTextStyleInformation(''));
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond.toInt(), '種別: $type', '電柱: $pole', platformChannelSpecifics,
        payload: 'item x');

  }

  Future onDidReceiveLocationLocation(
      int id, String title, String body, String payload) async {
    BuildContext context;
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content:  Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text(payload),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }


}
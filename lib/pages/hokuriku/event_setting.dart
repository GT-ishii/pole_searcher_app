
// お知らせ設定画面
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/hokuriku/geofencing.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/page_list.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';

class HrEventSettingPage extends StatefulWidget{
  HrEventSettingPage(this.auth, this.hokuriku, this.event);

  final Auth auth;
  final Hokuriku hokuriku;
  final HrEvent event;

  @override
  _HrEventSettingPageState createState() => _HrEventSettingPageState();
}

class _HrEventSettingPageState extends State<HrEventSettingPage> {
  LoginUser _user = LoginUser();

  List<EventData> _eventList = [];
  List<String> _notNotificationStatus = [];

  final _status = List.filled(4, true);

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToHr, HrNavigationMenuItem.setting.index, HrEventSettingPath);

    widget.auth.getUser()
        .then((user) {
          setState(() {
            _user = user;
          });
          getEventWorksHokuriku(_user, _notNotificationStatus)
            .then((eventList) {
              setState(() {
                _eventList = List.from(eventList);
              });
              Navigator.pop(context);
            }).catchError((Object error) {
            Navigator.pop(context);
            showError(error, context);
          });
        }).catchError((Object error) => showError(error, context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });

    setState(() {
      _notNotificationStatus = widget.event.setting.notNotificationStatus;
      for(var index = 0; index < statusList.length; index++){
        if (_notNotificationStatus.contains(statusList[index])) {
          _status[index] = false;
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        gotoHrSettingPage(context);
        return Future.value(false);
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: const Text('お知らせ設定'),
                centerTitle: true,
                actions: [
                  showLogoutButton(context, widget.auth, _user)
                ],
              ),
            ];
          },

          body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _showStatusList(),
                  ],
                ),
              )
          ),
        ),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.setting.index, belongToHr, widget.hokuriku),
      )
    );
  }

  Widget _showStatusList(){

    final list = <Widget>[];
    for(var i = 0; i < statusList.length; i++){

      list.add(const Divider(color: Colors.black12, thickness: 2, height: 0));
      list.add(

        showSwitchTile(statusList[i], _status[i],
          (value){
            setState(() {
              _status[i] = value;
              if (value == true) {
                _notNotificationStatus.remove(statusList[i]);
                _addGeofence(statusList[i]);
              }
              else if (value == false) {

                _notNotificationStatus.add(statusList[i]);
                _removeGeofence(statusList[i]);
              }
              setEventSettingHokuriku(_user.uid, widget.event.setting);
            });
          }
        ),
      );
    }
    list.add(const Divider(color: Colors.black12, thickness: 2, height: 0));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: list,
    );
  }

  void _addGeofence(String status) {

    for (final data in _eventList) {
      if (data.status == status) {

          final id = data.id;
          final latitude = data.latitude;
          final longitude = data.longitude;

          GeofencingHokuriku(notify: true).addGeoRegist(_user, id, latitude, longitude, eventNotificationRadius);
          data.notification = true;
      }
    }
  }

  void _removeGeofence(String status) {

    for (final data in _eventList) {
      if (data.status == status) {
        if (data.notification == true){

          final eventId = data.id;
          final latitude = data.latitude;
          final longitude = data.longitude;
          final id = '${_user.uid}/${widget.hokuriku.rikuden.ID}/${widget.hokuriku.area.name}/$eventId';

          final location = Geolocation(latitude: latitude, longitude: longitude, radius: eventNotificationRadius, id: id);

          Geofence.removeGeolocation(location, GeolocationEvent.entry).then((onValue){
            print('remove');
          }).catchError((Object error){
            print('err');
          });

          data.notification = false;

        }
      }
    }
  }
}

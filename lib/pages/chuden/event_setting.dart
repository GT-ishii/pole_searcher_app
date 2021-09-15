
// お知らせ設定画面
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/chuden/geofencing.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';
import 'package:polesearcherapp/models/chuden/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/page_list.dart';

class ChEventSettingPage extends StatefulWidget{
  ChEventSettingPage(this.auth, this.chuden, this.event);

  final Auth auth;
  final Chuden chuden;
  final ChEvent event;

  @override
  _ChEventSettingPageState createState() => _ChEventSettingPageState();
}

class _ChEventSettingPageState extends State<ChEventSettingPage> {
  LoginUser _user = LoginUser();

  List<EventData> _eventList = [];
  List<String> _notNotificationStatus = [];

  final _status = List.filled(4, true);

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCh, ChNavigationMenuItem.setting.index, ChEventSettingPath);

    widget.auth.getUser()
        .then((user) {
          setState(() {
            _user = user;
          });
          getEventWorks(_user, widget.chuden, _notNotificationStatus)
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
        gotoChSettingPage(context);
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
        bottomNavigationBar: chBottomNavigationBar(context, widget.auth, ChNavigationMenuItem.setting.index, belongToCh, widget.chuden),
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
              setEventSetting(_user.uid, widget.event.setting);
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

          GeofencingChuden(notify: true).addGeoRegist(_user, widget.chuden, id, latitude, longitude, eventNotificationRadius);
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
          final id = '${_user.uid}/${widget.chuden.office.branch.name}/${widget.chuden.office.name}/$eventId';

          final location = Geolocation(latitude: latitude, longitude: longitude, radius: eventNotificationRadius, id: id);

          Geofence.removeGeolocation(location, GeolocationEvent.entry).then((onValue){
            print('remove');
          }).catchError((Object error){
            print('error');
          });

          data.notification = false;

        }
      }
    }
  }
}

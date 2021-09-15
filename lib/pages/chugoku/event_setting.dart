// お知らせ設定画面
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/chugoku/geofencing.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/page_list.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chugoku/event.dart';

class CgEventSettingPage extends StatefulWidget{
  CgEventSettingPage(this.auth, this.chugoku, this.event);

  final Auth auth;
  final Chugoku chugoku;
  final CgEvent event;

  @override
  _EventSettingPageState createState() => _EventSettingPageState();
}

class _EventSettingPageState extends State<CgEventSettingPage> {
  LoginUser _user = LoginUser();

  List<EventData> _eventList = [];
  List<String> _notNotificationStatus = [];

  final _status = List.filled(4, true);

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCg, CgNavigationMenuItem.setting.index, CgEventSettingPath);

    widget.auth.getUser()
        .then((user) {
      setState(() {
        _user = user;
      });
      getEventWorksChugoku(_user, widget.chugoku, _notNotificationStatus)
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
          gotoCgSettingPage(context);
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
          bottomNavigationBar: cgBottomNavigationBar(context, widget.auth, CgNavigationMenuItem.setting.index, belongToCg, widget.chugoku),
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
                setEventSettingChugoku(_user.uid, widget.event.setting);
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

        GeofencingChugoku(notify: true).addGeoRegist(_user, widget.chugoku, id, latitude, longitude, eventNotificationRadius);
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
          final id = '${_user.uid}/${widget.chugoku.office.name}/$eventId';

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

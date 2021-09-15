// 事象詳細画面
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofence/geofence.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/image_viewer.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/permission.dart';

class HrEventDetailPage extends StatefulWidget {
  HrEventDetailPage(this.auth, this.hokuriku, this.event);

  final Auth auth;
  final Hokuriku hokuriku;
  final HrEvent event;

  @override
  _HrEventDetailPageState createState() => _HrEventDetailPageState();
}

class _HrEventDetailPageState extends State<HrEventDetailPage> {
  final _formKey = GlobalKey<FormState>();
  LoginUser _user = LoginUser();

  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  List<String> itemList = [];

  int _oldIndex;
  final _status = List.filled(4, false);

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToHr, HrNavigationMenuItem.event.index, HrEventDetailPath);

    // ユーザ情報を取得
    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));

    setState(() {
      final index = statusList.indexOf(widget.event.data.status);

      if (index == -1) {
        return;
      }
      _oldIndex = index;
      _status[index] = true;
    });
  }

 Future<void> getDistanceEvent() async{
    if (await isLocationStatusDisabled() || await isLocationStatusDenied()) {
      return;
    }
    final pos = await getLocation();
    final d = await getDistance(pos.latitude, pos.longitude, widget.event.data.latitude, widget.event.data.longitude);
    setState(() {
      widget.event.data.distance = d;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.clear();

      final marker = Marker(
        markerId: MarkerId(widget.event.data.id),
        position:
        LatLng(widget.event.data.latitude, widget.event.data.longitude),
        infoWindow: InfoWindow(
          title: widget.event.data.id,
        ),
      );
      _markers[widget.event.data.id] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _event = widget.event.data;
    final width = MediaQuery.of(context).size.width * 0.85;
    print(MediaQuery.of(context).size.width);

    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, ModalRoute.withName(HrEventListPath));
        setBeforePage(belongToHr, HrNavigationMenuItem.event.index, HrEventListPath);
        return Future.value(false);
      },
      child:Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                title: const Text('事象詳細'),
                centerTitle: true,

                actions: [
                  showLogoutButton(context, widget.auth, _user)
                ],
              ),
            ];
          },
          body: RefreshIndicator(
              color: Colors.blue,
              onRefresh: () async {
                await getDistanceEvent();
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: SizedBox(
                          width: width,
                          child: Column (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              showTextCustom('種別 : ${_event.type.reduce((a, b){
                                return '$a/$b';
                              })}', 22, Colors.black, null, 1),

                              showTextCustom(
                                  _event.title != null && _event.title.isNotEmpty
                                      ? '事象 : ${_event.title}' : '事象 :',
                                  22, Colors.black, null, null),

                              showTextCustom(
                                  _event.eventPole != null
                                      ? '${_event.eventPole['area']}  ${_event.eventPole['pole']}' : '電柱 :',
                                    22, Colors.black, TextOverflow.ellipsis, 1),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  showTextCustom('ステータス :', 22, Colors.black, null, 1),
                                  _showCheckboxList(),
                                ],
                              ),

                              showTextCustom('日付 : ${_event.updatedAt}', 22, Colors.black, null, 1),
                              showTextCustom(
                                  _event.distance != null
                                      ? '距離 : ${_event.distance}km' : '距離 :', 22, Colors.black, null, 1),
                              _event.memo != null && _event.memo.isNotEmpty ?
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    showTextCustom('メモ :', 22, Colors.black, null, null),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 20),
                                      child: showTextCustom('${_event.memo}', 22, Colors.black, null, null),
                                    ),
                                  ],
                                ) : showTextCustom('メモ :', 22, Colors.black, null, null),
                            ]
                          )
                        )
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            showSubmit(_formKey, '変更', const Size(125, 50), 20, Colors.indigo, (){
                              gotoHrEventUpdatePage(context);
                            }),
                            addPadding(1),
                            showSubmit(_formKey, '削除', const Size(125, 50), 20, Colors.indigo, _cbDelete),

                            addPadding(1),
                            showSubmit(_formKey, '作業追加', const Size(125, 50), 20, Colors.indigo, _cbWork),
                          ],
                        )
                      ),

                      _event.image.isNotEmpty ?
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                              width: width,
                              height: 200,
                              child: showSwiperImage(_event.image, (index){

                                // タップして拡大
                                Navigator.push(context, PageRouteBuilder<void>(
                                  opaque: false,
                                  transitionDuration: const Duration(milliseconds: 100),
                                  reverseTransitionDuration: const Duration(milliseconds: 50),
                                  barrierColor: Colors.black.withOpacity(1),
                                  barrierDismissible: true,
                                  fullscreenDialog: true,
                                  pageBuilder: (_, animation, ___) {
                                    return ImageViewerPage(_event.image[index]);
                                  } ,
                                  transitionsBuilder: (context, animation, secondaryAnimation, child){
                                    return ScaleTransition(
                                      scale: animation,
                                    child: child,
                                  );
                                },
                              ));
                            })
                        )
                    ): const SizedBox.shrink(),

                    addPadding(1),

                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            onMapCreated: _onMapCreated,
                            markers: _markers.values.toSet(),
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            rotateGesturesEnabled: true,
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(_event.latitude, _event.longitude),
                              zoom: defaultMapZoom,
                            ),
                          ),
                        ),

                        showGuidButton(_event.latitude, _event.longitude)
                      ],
                    ),

                  ],
                ),
              ),
            )
        ),
      ),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.event.index, belongToHr, widget.hokuriku),
      )
    );
  }

  Widget _showCheckboxList(){

    final list = <Widget>[];
    for(var i = 0; i < statusList.length; i++){
      list.add(showCheckBox(statusList[i], _status[i], (value){
        setState(() {
          if (_oldIndex != i) {
            if (_oldIndex != null) {
              _status[_oldIndex] = false;
            }

            _status[i] = true;
            updateEventStatus(_user, widget.hokuriku, widget.event.data.id, statusList[i], HokurikuID);

            _oldIndex = i;
          }
        });
      }));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: list,
    );
  }

  void _cbDelete(){

    showPopupConfirm(
        '削除しますか？', context,
        (){
          final eventId = widget.event.data.id;
          final latitude = widget.event.data.latitude;
          final longitude = widget.event.data.longitude;
          final id = '${_user.uid}/${widget.hokuriku.area.name}/$eventId';
          final location = Geolocation(latitude: latitude, longitude: longitude, id: id, radius: eventNotificationRadius);
          Geofence.removeGeolocation(location, GeolocationEvent.entry).then((onValue){
            print('remove');
          }).catchError((Object error){
            print('err');
          });
          deleteEvent(_user, widget.hokuriku, widget.event.data.id,HokurikuID);
          removeEventImage(widget.event.data.image);

          Navigator.pop(context);
          setBeforePage(belongToHr, HrNavigationMenuItem.event.index, HrEventListPath);
          showPopup('事象を削除しました', context);
        }
    );
  }

  void _cbWork(){

    showPopup('作業を追加しました', context);
    setEventWorker(_user, widget.hokuriku, widget.event.data.id, HokurikuID);
    widget.event.data.notification = true;
  }

}

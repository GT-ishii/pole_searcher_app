// 電柱詳細画面
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/specification.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';


import 'package:polesearcherapp/services/auth.dart';

class HrShowPolePage extends StatefulWidget {
  HrShowPolePage(this.auth, this.hokuriku);

  //final String title;
  final Auth auth;
  final Hokuriku hokuriku;

  @override
  _HrShowPolePageState createState() => _HrShowPolePageState();
}

class _HrShowPolePageState extends State<HrShowPolePage> {
  GoogleMapController mapController;

  // ログインユーザ
  LoginUser _user = LoginUser();

  final Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId(widget.hokuriku.pole.name),
        position:
            LatLng(widget.hokuriku.pole.latitude, widget.hokuriku.pole.longitude),
        infoWindow: InfoWindow(
          title: widget.hokuriku.pole.name,
          snippet: widget.hokuriku.pole.address,
        ),
      );
      _markers[widget.hokuriku.pole.name] = marker;
    });
  }

  @override
  void initState() {
    super.initState();
    setBeforePage(belongToHr, HrNavigationMenuItem.search.index, HrShowPolePath);

    // ログインユーザ取得
    widget.auth
        .getUser()
        .then((user) => setState(() {
      _user = user;
    })
    ).catchError((Object error) => showError(error, context));
  }

  @override
  Widget build(BuildContext context) {
    final _pole = widget.hokuriku.pole;
    return WillPopScope(
      onWillPop: (){
        gotoHrSelectPolePage(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.hokuriku.area.name}  ${widget.hokuriku.pole.name}' ,style: TextStyle(fontSize: 18)),
          centerTitle: true,
          actions: [
            showLogoutButton(context, widget.auth, _user)
          ],
        ),


        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _pole.address.isNotEmpty
              ? Padding (
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    _pole.address,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        onMapCreated: _onMapCreated,
                        markers: _markers.values.toSet(),
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        rotateGesturesEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_pole.latitude, _pole.longitude),
                          zoom: defaultMapZoom,
                        ),
                      ),
                    ),

                    showGuidButton(widget.hokuriku.pole.latitude, widget.hokuriku.pole.longitude),
                  ],
                ),
              ),
            ),

          ],
        ),

        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.search.index, belongToHr, widget.hokuriku),
      ),
    );
  }
}

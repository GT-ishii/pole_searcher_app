// 電柱詳細画面
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/specification.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';


import 'package:polesearcherapp/services/auth.dart';

class CgShowPolePage extends StatefulWidget {
  CgShowPolePage(this.auth, this.chugoku);

  final Auth auth;
  final Chugoku chugoku;

  @override
  _CgShowPolePageState createState() => _CgShowPolePageState();
}

class _CgShowPolePageState extends State<CgShowPolePage> {
  GoogleMapController mapController;

  // ログインユーザ
  LoginUser _user = LoginUser();

  final Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId(widget.chugoku.pole.name),
        position:
        LatLng(widget.chugoku.pole.latitude, widget.chugoku.pole.longitude),
        infoWindow: InfoWindow(
          title: widget.chugoku.pole.name,
          snippet: widget.chugoku.pole.address,
        ),
      );
      _markers[widget.chugoku.pole.name] = marker;
    });
  }

  @override
  void initState() {
    super.initState();
    setBeforePage(belongToCg, CgNavigationMenuItem.search.index, CgShowPolePath);

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
    final _pole = widget.chugoku.pole;
    return WillPopScope(
      onWillPop: (){
        gotoCgSelectPolePage(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            child: Column(
              children:[
                Text('${widget.chugoku.line != null ? widget.chugoku.line.name : ''}',style: TextStyle(fontSize: 20)),
                Text('${widget.chugoku.pole != null ? widget.chugoku.pole.name : ''}',style: TextStyle(fontSize: 20, height: 1.0))
              ]
            )
          ),
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

                    showGuidButton(widget.chugoku.pole.latitude, widget.chugoku.pole.longitude),
                  ],
                ),
              ),
            ),

          ],
        ),

        bottomNavigationBar: cgBottomNavigationBar(context, widget.auth, CgNavigationMenuItem.search.index, belongToCg, widget.chugoku),
      ),
    );
  }
}

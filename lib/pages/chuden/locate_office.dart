// 事象マッップ画面
import 'dart:async';
import 'dart:typed_data';
import 'Dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';


class ChLocateOfficePage extends StatefulWidget {
  ChLocateOfficePage(this.auth, this.chuden);

  final Auth auth;
  final Chuden chuden;

  @override
  _ChLocateOfficePageState createState() => _ChLocateOfficePageState();
}

class _ChLocateOfficePageState extends State<ChLocateOfficePage> {
  LoginUser _user = LoginUser();

  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCh, ChNavigationMenuItem.locate.index, ChLocateOfficePagePath);

    // ユーザ情報を取得
    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _markers.clear();

    final markerIcon = await getBytesFromCanvas(widget.chuden.office.name, 500, 200);
    setState(() {
      _markers[widget.chuden.office.name] = Marker(
        markerId: MarkerId(widget.chuden.office.name),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: LatLng(widget.chuden.office.latitude, widget.chuden.office.longitude),
      );
    });

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.chuden.office.branch.name} ${widget.chuden.office.name}',
            style: const TextStyle(fontSize: 18)
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            showLogoutButton(context, widget.auth, _user)
          ],
        ),
        body:
        Stack(
          children: <Widget>[
            SizedBox(
              //width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height - 100,

              child: GoogleMap(
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                markers: _markers.values.toSet(),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.chuden.office.latitude, widget.chuden.office.longitude),
                  zoom: 16,
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: showGuidButton(widget.chuden.office.latitude, widget.chuden.office.longitude),
            ),

          ],
        ),

        bottomNavigationBar: chBottomNavigationBar(context, widget.auth, ChNavigationMenuItem.locate.index, belongToCh, widget.chuden),
      ),
    );
  }

  Future<Uint8List> getBytesFromCanvas(String name, int width, int height) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final paintFill = Paint()
      ..color = const Color(0xdfffffff)
      ..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = const Color(0xdf000000)
      ..style = PaintingStyle.stroke;
    final painter = TextPainter(textDirection: TextDirection.ltr);

    // マーカー描画
    final icon = Icons.location_pin;
    painter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
          fontSize: 112, color: Colors.red,
          fontFamily: icon.fontFamily),
    );

    painter.layout();
    painter.paint(canvas, Offset((width * 0.5) - painter.width * 0.5, 0));

    const ratio = 70.0;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(center: Offset(width.toDouble() / 2, height * 0.8), width: ratio * (name.length), height: 78),
        ),
        paintFill
    );

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(center: Offset(width.toDouble() / 2, height * 0.8), width: ratio * (name.length), height: 78),
        ),
        paintStroke
    );

    painter.text = TextSpan(
      text: name,
      style: const TextStyle(
        fontSize: 58, color: Colors.black,
      ),
    );

    painter.layout();
    painter.paint(canvas, Offset((width * 0.5) - painter.width * 0.5, (height * 0.8) - painter.height * 0.5));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

}
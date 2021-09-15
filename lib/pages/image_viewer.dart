import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerPage extends StatefulWidget {
  ImageViewerPage(this.assetName);

  final String assetName;

  @override
  _ImageViewerPageState createState() => _ImageViewerPageState();
}


class _ImageViewerPageState extends State<ImageViewerPage> {

  Offset beginningDragPosition = Offset.zero;
  Offset currentDragPosition = Offset.zero;
  PhotoViewScaleState scaleState = PhotoViewScaleState.initial;
  int photoViewAnimationDurationMilliSec = 0;
  double barsOpacity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildImage(context),
          _buildTopBar(context),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {

    print(widget.assetName);

    return GestureDetector(
     /* onTap: onTapPhotoView,
      onVerticalDragStart: scaleState == PhotoViewScaleState.initial
          ? onVerticalDragStart
          : null,
      onVerticalDragUpdate: scaleState == PhotoViewScaleState.initial
          ? onVerticalDragUpdate
          : null,
      onVerticalDragEnd:
      scaleState == PhotoViewScaleState.initial ? onVerticalDragEnd : null,*/

      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          //curve: Curves.fastOutSlowIn,
          child: PhotoView(
            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
            imageProvider: widget.assetName.contains('https://firebasestorage.googleapis.com')
                ? CachedNetworkImageProvider(widget.assetName) as ImageProvider
                : FileImage(File(widget.assetName)),
            minScale: PhotoViewComputedScale.contained * 0.5,
          ),
        ),
      ),
    );
  }



  Widget _buildTopBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const topBarHeight = 64.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: barsOpacity,
      child: SizedBox(
        height: topBarHeight,
        child: Column(
          children: [
            Container(height: statusBarHeight),
            SizedBox(
              height: topBarHeight - statusBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapPhotoView() {
    setState(() {
      barsOpacity = (barsOpacity <= 0.0) ? 1.0 : 0.0;
    });
  }

  void onVerticalDragStart(DragStartDetails details) {
    setState(() {
      barsOpacity = 0.0;
      photoViewAnimationDurationMilliSec = 0;
    });
    beginningDragPosition = details.globalPosition;
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      barsOpacity = (currentDragPosition.distance < 20.0) ? 1.0 : 0.0;
      currentDragPosition = Offset(
        details.globalPosition.dx - beginningDragPosition.dx,
        details.globalPosition.dy - beginningDragPosition.dy,
      );
    });
  }

  void onVerticalDragEnd(DragEndDetails details) {
    if (currentDragPosition.distance < 100.0) {
      setState(() {
        photoViewAnimationDurationMilliSec = 0;
        currentDragPosition = Offset.zero;
        barsOpacity = 1.0;
      });
    } else {
      Navigator.of(context).pop();
    }
  }
}

// 事象登録画面
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/image_viewer.dart';

import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';

import 'package:polesearcherapp/services/permission.dart';
import 'package:polesearcherapp/services/auth.dart';

class HrEventAddPage extends StatefulWidget {
  HrEventAddPage(this.auth, this.hokuriku, this.event);

  final Auth auth;
  final Hokuriku hokuriku;
  final HrEvent event;

  @override
  _HrEventAddPageState createState() => _HrEventAddPageState();
}

class _HrEventAddPageState extends State<HrEventAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final _poleController = TextEditingController();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();

  LoginUser _user = LoginUser();
  List<String> _imageFile = <String>[];
  final _addData = EventData();

  final _eventType = List.filled(4, false);
  String _title;
  String _text;

  @override
  void initState() {
    super.initState();
    setBeforePage(
        belongToHr, HrNavigationMenuItem.event.index, HrEventAddPath);

    // ユーザ情報を取得
    widget.auth.getUser()
        .then((user) => setState(() {
          _user = user;
    })).catchError((Object error) => showError(error, context));

    if (widget.event.data != null && widget.event.data.poleSearch == true) {
      _addData.eventPole = <String, dynamic>{
        'area': widget.hokuriku.area.name,
        'pole': widget.hokuriku.pole.name,
        'located_at' : GeoPoint(
            widget.hokuriku.pole.latitude, widget.hokuriku.pole.longitude)
      };
      widget.event.data = EventData();
      _poleController.text = '${_addData.eventPole['area']} ${_addData.eventPole['pole']}';
    }

    if (widget.event.data != null && widget.event.data.eventPole != null) {
      _addData.eventPole = widget.event.data.eventPole;
    }
    widget.event.data = EventData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        gotoHrEventSelectPage(context);
        setBeforePage(
            belongToHr, HrNavigationMenuItem.event.index, HrEventSelectPath);
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: NestedScrollView(
          headerSliverBuilder: (
            BuildContext context, bool innerBoxIsScrolled) {
              return <Widget> [
                SliverAppBar(
                  title: const Text('事象登録'),
                  centerTitle: true,
                  actions: [
                    showLogoutButton(context, widget.auth, _user)
                  ],
                ),
              ];
            },

            body: GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _showCheckboxList(),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 40, right: 40),
                      child: SizedBox(
                        child: TextFormField(
                          focusNode: _focusNode,
                          controller: _poleController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            filled: true,
                            hintText: '管理区と電柱を登録してください',
                            hintStyle: const TextStyle(
                                fontSize: 18
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: (){
                                setState(() {
                                  _focusNode.canRequestFocus = false;
                                  _poleController.clear();
                                  _addData.eventPole = null;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide()
                            ),
                          ),
                          style: const TextStyle(
                              fontSize: 20
                          ),
                          showCursor: false,
                          readOnly: true,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (_focusNode.canRequestFocus == false) {
                              return;
                            }
                            Navigator.pushNamed(context, HrEventPolePath)
                              .then((eventPole){
                                setState(() {
                                  setBeforePage(
                                    belongToHr, HrNavigationMenuItem.event.index, HrEventAddPath);
                                  if(eventPole != null) {
                                    _addData.eventPole = eventPole as Map<String, dynamic>;
                                    _poleController.text = '${_addData.eventPole['area']}  ${_addData.eventPole['pole']}';
                                  }
                                });
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5, left: 40, right: 40),
                      child: SizedBox(
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            filled: true,
                            hintText: '事象20文字以内を入力してください',
                            hintStyle: TextStyle(
                              fontSize: 18
                            ),
                            suffixIcon: Icon(Icons.mic),
                            border: OutlineInputBorder(
                                borderSide: BorderSide()
                            ),
                          ),
                          maxLength: 20,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 20
                          ),
                          onChanged: (value) => _cbTitle(value.trim()),
                        ),
                      ),
                    ),

                    Padding (
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                      child: SizedBox(
                        height: 100,
                        child: TextFormField(
                          controller: _memoController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            filled: true,
                            hintText: 'メモを入力してください',
                            hintStyle: TextStyle(
                                fontSize: 18
                            ),
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 30),
                                child: Icon(Icons.mic)
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide()
                            ),
                          ),
                          maxLines: 3,
                          maxLength: 50,
                          //textInputAction: TextInputAction.done,
                          style: const TextStyle(
                              fontSize: 20
                          ),
                          onChanged: (value) => _cbMemo(value.trim()),
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 180,
                      child: showSwiperImageUpdate(List.from(_imageFile), _cbAdd, _cbViewer, _cbRemove),
                    ),

                    addPadding(1),
                    showSubmit(_formKey, '登録', const Size(210, 50), 20, Colors.indigo, (_canUpload()) ? _checkUpload : null),
                    addPadding(4),
                  ],
                ),
              ),
            ),
          ),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.event.index, belongToHr, widget.hokuriku),
      )
    );
  }

  Widget _showCheckboxList(){
    final list = <Widget>[];

    for(var i = 0; i < eventType.length; i++){

      list.add(showCheckBox(eventType[i], _eventType[i], (bool value){
        FocusScope.of(context).unfocus();

        setState(() {
          _eventType[i] = value;
        });
      }));

    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: list,
    );
  }

  //タイトル
  void _cbTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  //メモ
  void _cbMemo(String text) {
    setState(() {
      _text = text;
    });
  }

  //カメラ起動
  Future<void> _cbCamera() async{
    FocusScope.of(context).unfocus();

    if (await isCameraStatusDenied()){
      showPopupSelect('カメラへのアクセスを許可してください', context,
          'キャンセル', '設定', (){}, openAppSettingsPage
      );
      return;
    }

    final _picker = ImagePicker();
    PickedFile image;
    try {
      image = await _picker.getImage(
          maxHeight:1280,
          maxWidth:720,
          source: ImageSource.camera
      );
    } on PlatformException catch (error) {
      if (error.code == 'camera_access_denied') {
        return;
      }
      showError(error, context);
    }
    if (image == null) {
      return;
    }

    await image.readAsBytes().then(print);
    setState(() {
      _imageFile.add(image.path);
    });
  }

  //ギャラリー起動
  Future<void> _cbGallery() async{
    FocusScope.of(context).unfocus();

    // iOS
    if (await isPhotosStatusDenied()){
      showPopupSelect('写真へのアクセスを許可してください', context,
          'キャンセル', '設定', (){}, openAppSettingsPage
      );
      return;
    }

    // Android
    if (await isStorageStatusDenied()){
      showPopupSelect('ストレージへのアクセスを許可してください', context,
          'キャンセル', '設定', (){}, openAppSettingsPage
      );
      return;
    }

    final _picker = ImagePicker();
    PickedFile image;
    try {
      image = await _picker.getImage(
          maxHeight:1280,
          maxWidth:720,
          source: ImageSource.gallery
      );
    } on PlatformException catch (error) {
      if (error.code == 'photo_access_denied') {
        return;
      }
      showError(error, context);
    }
    if (image == null) {
      return;
    }

    setState(() {
      _imageFile.add(image.path);
    });
  }

  void _cbAdd(int index) {
    FocusScope.of(context).unfocus();
    showPopupSelect('追加方法を選択してください', context,
        'カメラ', 'ファイル', _cbCamera, _cbGallery);
  }

  void _cbViewer(int index) {
    // タップして拡大
    Navigator.push(context, PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 50),
      barrierColor: Colors.black.withOpacity(1),
      barrierDismissible: true,
      fullscreenDialog: true,
      pageBuilder: (_, animation, ___) {
        return ImageViewerPage(_imageFile[index]);
      } ,
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    ));
  }

  void _cbRemove(int index) {
    FocusScope.of(context).unfocus();

    showPopupConfirm(
        '削除しますか？', context,
        (){
          setState(() {
            _imageFile.removeAt(index);
          });
        });
  }

  bool _canUpload(){
    return _eventType.contains(true);
  }

  void _checkUpload(){
    FocusScope.of(context).unfocus();
    showPopupConfirm('登録しますか？', context, _upload);
  }

  Future<void> _upload() async{
    if (await showPopupLocationService(context) != false) {

      showProgressIndicator(context);

      try {
        final url = await setEventImage(_imageFile);
        final currentPosition = await getLocation();

        final type = <String>[];
        for (var i = 0; i <  _eventType.length; i++) {
          if (_eventType[i] == true) {
            type.add(eventType[i]);
          }
        }
        final time = dateToString(DateTime.now(), true);

        _addData
          ..type = type
          ..title = _title
          ..memo = _text
          ..image = url
          ..latitude = currentPosition.latitude
          ..longitude = currentPosition.longitude
          ..updatedAt = time
          ..worker = _user.name;

        setEvent(_user, widget.hokuriku, HokurikuID, _addData);

        setState(() {
          _poleController.clear();
          _titleController.clear();
          _memoController.clear();

          _eventType.fillRange(0, 4, false);
          _imageFile = [];
        });

        Navigator.pop(context);
        gotoHrEventListPage(context);
        setBeforePage(belongToHr, HrNavigationMenuItem.event.index, HrEventListPath);
        showPopup('事象を登録しました', context);

      } on Exception catch(_) {
        Navigator.pop(context);
        showPopup('事象を登録できませんでした', context);
      }
    }


  }
}

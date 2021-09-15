// 事象変更画面
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';
import 'package:polesearcherapp/models/chuden/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/image_viewer.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/permission.dart';

class ChEventUpdatePage extends StatefulWidget {
  ChEventUpdatePage(this.auth, this.chuden, this.event);

  final Auth auth;
  final Chuden chuden;
  final ChEvent event;

  @override
  _ChEventUpdatePageState createState() => _ChEventUpdatePageState();
}

class _ChEventUpdatePageState extends State<ChEventUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final _poleController = TextEditingController();
  LoginUser _user = LoginUser();
  final _imageFile = <String>[];
  var _imageData = <String>[];
  final _removeImageData = <String>[];
  EventData _updateData;

  final _eventType = List.filled(4, false);

  @override
  void initState() {
    super.initState();

    setBeforePage(5, ChNavigationMenuItem.event.index, ChEventUpdatePath);

    // ユーザ情報を取得
    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));

    setState(() {
      _updateData = widget.event.data;

      for (var i = 0; i < _updateData.type.length; i++){
        final index = eventType.indexOf(_updateData.type[i]);
        if (index != -1) {
          _eventType[index] = true;
        }
      }
      if (_updateData.eventPole != null){
        _poleController.text = '${_updateData.eventPole['pole']}';
      }
      _imageData = List.from(_updateData.image);
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, ModalRoute.withName(ChEventDetailPath));
        setBeforePage(belongToCh, ChNavigationMenuItem.event.index, ChEventDetailPath);
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget> [
                SliverAppBar(
                  title: const Text('事象変更'),
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
                      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 40, right: 40),
                      child: SizedBox(
                        child: TextFormField(
                          focusNode: _focusNode,
                          controller: _poleController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            filled: true,
                            hintText: '電柱を登録してください',
                            hintStyle: const TextStyle(
                                fontSize: 18
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: (){
                                setState(() {
                                  _focusNode.canRequestFocus = false;
                                  _poleController.clear();
                                  _updateData.eventPole = null;
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

                            Navigator.pushNamed(context, ChEventPolePath).then((eventPole){
                              setState(() {
                                setBeforePage(5, ChNavigationMenuItem.event.index, ChEventUpdatePath);
                                if(eventPole != null) {
                                  _updateData.eventPole = eventPole as Map<String, dynamic>;
                                  _poleController.text = '${_updateData.eventPole['pole']}';
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
                          initialValue: _updateData.title,
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
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      child: Container(
                        height: 100,
                        decoration: const BoxDecoration(
                          //border: Border.all(),
                        ),
                        child: TextFormField(
                          initialValue: _updateData.memo,
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
                      child: showSwiperImageUpdate(List.from(_imageData + _imageFile), _cbAdd, _cbViewer, _cbRemove),
                    ),

                    addPadding(1),
                    showSubmit(_formKey, '変更', const Size(210, 50), 20, Colors.indigo, (_canUpload()) ? _checkUpload : null),
                    addPadding(4),
                  ],
                ),
              ),
            ),
          ),
        bottomNavigationBar: chBottomNavigationBar(context, widget.auth, ChNavigationMenuItem.event.index, belongToCh, widget.chuden),
      )
    );
  }

  Widget _showCheckboxList(){

    final list = <Widget>[];
    for(var i = 0; i < eventType.length; i++){

      list.add(showCheckBox(eventType[i], _eventType[i], (value){
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
      _updateData.title = title;
    });
  }

  //メモ
  void _cbMemo(String memo) {
    setState(() {
      _updateData.memo = memo;
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
    showPopupSelect('追加方法を選択してください', context, 'カメラ', 'ファイル',
        _cbCamera, _cbGallery);
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
        if (_imageData.length < index + 1) {
          return ImageViewerPage(_imageFile[index - _imageData.length]);
        }
        else {
          return ImageViewerPage(_imageData[index]);
        }
      } ,
      transitionsBuilder: (context, animation, secondaryAnimation, child){
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      // を渡す
    ));
  }

  void _cbRemove(int index) {
    FocusScope.of(context).unfocus();

    showPopupConfirm(
        '削除しますか？', context,
        (){
          setState(() {
            if (_imageData.length < index + 1) {
              _imageFile.removeAt(index - _imageData.length);
            }
            else {
              _removeImageData.add(_imageData[index]);
              _imageData.removeAt(index);
            }
          });
        });
  }

  bool _canUpload(){
    return _eventType.contains(true);
  }

  void _checkUpload(){
    FocusScope.of(context).unfocus();
    showPopupConfirm('変更しますか？', context, _upload);
  }

  Future<void> _upload() async{
    showProgressIndicator(context);

    try {

     final url = await setEventImage(_imageFile);

      final type = <String>[];
      for (var i = 0; i < _eventType.length; i++) {
        if (_eventType[i] == true) {
          type.add(eventType[i]);
        }
      }
      final time = dateToString(DateTime.now(), true);

      _updateData
        ..type = type
        ..image = _imageData + url
        ..updatedAt = time
        ..worker = _user.name;
      
      updateEvent(_user, widget.chuden, _updateData);
      await removeEventImage(_removeImageData);

      Navigator.pop(context);

      setState(() {
        widget.event.data = _updateData;
      });

      //gotoEventListPage(context);
      Navigator.popUntil(context, ModalRoute.withName(ChEventListPath));
      setBeforePage(5, ChNavigationMenuItem.event.index, ChEventListPath);
      showPopup('事象を変更しました', context);

    } on Exception catch(_) {
        Navigator.pop(context);
        showPopup('事象を変更できませんでした', context);
    }
  }
}

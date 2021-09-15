// プロフィール編集画面
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/page_list.dart';

import 'package:polesearcherapp/services/auth.dart';

class HrSettingPage extends StatefulWidget {
  HrSettingPage(this.auth, this.userData, this.hokuriku);

  final Auth auth;
  final UserDataHokuriku userData;
  final Hokuriku hokuriku;

  @override
  _HrSettingPageState createState() => _HrSettingPageState();
}

class _HrSettingPageState extends State<HrSettingPage> {
  LoginUser _user = LoginUser();
  Map _versions;

  bool _geoTag = true;

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToHr, HrNavigationMenuItem.setting.index, HrSettingPath);

    // ユーザ情報を取得
    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));

    getVersions().then((version){
      setState(() {
        _versions = version;
      });
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
          title: const Text('各種設定'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            showLogoutButton(context, widget.auth, _user)
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.black12, thickness: 2, height: 1),

                //トーンダウン
                showCategoryTile_gray(context, '事業所設定',
                        (){
                      Future<void>.delayed(const Duration(milliseconds: 200)).then((value){
                        gotoHrSelectBranchPage(context);
                      });
                    }),

                const Divider(color: Colors.black12, thickness: 2, height: 1),

                showCategoryTile(context, 'パスワード変更',
                  (){
                    Future<void>.delayed(const Duration(milliseconds: 200)).then((value){
                    gotoHrEditProfilePage(context);
                  });
                }),
                const Divider(color: Colors.black12, thickness: 2, height: 0),
                
                showCategoryTile(context, 'お知らせ設定',
                      (){
                        Future<void>.delayed(const Duration(milliseconds: 200)).then((value){
                        gotoHrEventSettingPage(context);
                      });
                    }),
                const Divider(color: Colors.black12, thickness: 2, height: 0),


                showSwitchTile('写真に位置情報を登録', _geoTag,
                  (value){
                    setState(() {
                      _geoTag = value;
                    });
                  }
                ),
                const Divider(color: Colors.black12, thickness: 2, height: 0),

                showSwitchTile('現在地を利用', widget.userData.locationEnable,
                    (ret) async {
                      //現在地を利用
                      if (ret == true){
                        if (await showPopupLocationService(context) == false) {
                          return;
                        }
                        getLocationStream(
                          (Position position){
                            if (position != null){
                              setUserLocation(_user, position.latitude, position.longitude);
                            }
                          }
                        );
                      }
                      else {
                        getLocationStreamCancel();
                        setUserLocation(_user, null, null);
                      }

                      setState(() {
                        widget.userData.locationEnable = ret;
                        setUserDataHokuriku(_user, widget.userData);
                      });
                    }
                ),
                const Divider(color: Colors.black12, thickness: 2, height: 0),

                Center(
                  child: showInfo(_user, _versions),
                ),

              ],
            ),
          )

          ),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.setting.index, belongToHr, widget.hokuriku),
      )
    );
  }
}

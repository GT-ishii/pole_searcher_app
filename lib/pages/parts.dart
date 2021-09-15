import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_picker/Picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';

import 'package:polesearcherapp/pages/hokuriku/chat_list.dart';
import 'package:polesearcherapp/pages/hokuriku/select_pole.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/permission.dart';

Widget showLogoutButton(BuildContext context, Auth auth, LoginUser user){
  return GestureDetector(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Icon(Icons.exit_to_app),
        Text('ログアウト'),
        Padding(
            padding: EdgeInsets.only(right: 80)
        )
      ],
    ),
    onTap: (){
      _showLogoutDialog(context, auth, user);
    },
  );
}

//チャット画面からチャットリスト画面へ戻る
Widget showBackButton(BuildContext context, Auth auth, LoginUser user){
  return GestureDetector(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Icon(Icons.arrow_back_ios),
        Padding(
            padding: EdgeInsets.only(right: 80)
        )
      ],
    ),
    onTap: (){
      gotoHrChatListPage(context);
    },
  );
}

void _showLogoutDialog(BuildContext context, Auth auth, LoginUser user) {
  showDialog<CupertinoAlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Container(
            margin: const EdgeInsets.only(top: 15, bottom: 10),
            child: const Text(
              'ログアウトしますか？',
              style: TextStyle(
                  fontSize: 19,
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'もどる',
                style: TextStyle(
                    fontSize: 20
                )
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                setUserLocation(user, null, null);
                auth
                  .signOut()
                  .then((_){
                    gotoLoginPage(context);
                  })
                  .catchError((Object error) => showError('ログアウトに失敗しました', context));
              },
              child: const Text('ログアウト',
                  style: TextStyle(
                      fontSize: 20
                  )
              ),
            ),
          ],
        );
      });
}

// 北陸:ページ下部に並べるナビゲーションメニューの一覧
List<BottomNavigationBarItem> _hrBottomNavBarItems() {
  return const [
    BottomNavigationBarItem(
      icon: Icon(Icons.business),
      label: '帰所',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '電柱検索',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storage),
      label: '事象管理',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '各種設定',
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.textsms),
        label: 'チャット',
    ),
  ];
}

// ページ下部に並べるボトムナビゲーションバー
BottomNavigationBar hrBottomNavigationBar(
    BuildContext context, Auth auth, int idx,int belongTo, Hokuriku hokuriku) {
  final baseIndex = idx;
  return BottomNavigationBar(
    currentIndex: idx,
    onTap: (index) {

      //電力会社ごとのページをpagesリスト取得
      final pages = getBeforePages(belongTo);


      if (index == HrNavigationMenuItem.locate.index) {
        // 帰所画面へ。
        if (baseIndex == index)
          return;
        if (hokuriku.area.latitude == null || hokuriku.area.longitude == null) {

          return;
        }
        gotoHrLocateOfficePage(context);
      }


      if (index == HrNavigationMenuItem.search.index) {
        if (pages[index] == HrSelectPolePath){
          if (baseIndex == index) {
            return;
          }
          //各種設定ページへ遷移
          gotoHrSelectPolePage(context);
          return;
        }
        if (pages[index] == HrShowPolePath){
          if (baseIndex == index) {
            gotoHrSelectPolePage(context);
            return;
          }
          //電柱詳細画へ遷移
          gotoHrShowPolePage(context);
          return;
        }
      }

      if (index == HrNavigationMenuItem.event.index) {

        if (pages[index] == HrEventSelectPath){
          if (baseIndex == index) {
            return;
          }
          //事象選択画面へ遷移
          gotoHrEventSelectPage(context);
          return;
        }

        if (pages[index] == HrEventAddPath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(HrEventSelectPath));
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(HrEventAddPath));
          return;
        }
        if (pages[index] == HrEventPolePath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(HrEventSelectPath));
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(HrEventPolePath));
          return;
        }
        if (pages[index] == HrEventListPath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(HrEventSelectPath));
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(HrEventListPath));
          return;
        }

        if (pages[index] == HrEventListWorkPath){
          if (baseIndex == index) {
            gotoHrEventSelectPage(context);
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoHrEventListWorkPage(context);
          return;
        }

        if (pages[index] == HrEventDetailPath){
          if (baseIndex == index) {
            gotoHrEventSelectPage(context);
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          gotoHrEventDetailPage(context);
          return;
        }

        if (pages[index] == HrEventDetailWorkPath){
          if (baseIndex == index) {
            gotoHrEventSelectPage(context);
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoHrEventDetailWorkPage(context);
          return;
        }

        if (pages[index] == HrEventUpdatePath){
          if (baseIndex == index) {
            gotoHrEventSelectPage(context);
            setBeforePage(belongTo, index, HrEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoHrEventUpdatePage(context);
          return;
        }

        // 事象管理画面へ
        gotoHrEventSelectPage(context);
        return;
      }
      //各種設定画面へ
      if (index == HrNavigationMenuItem.setting.index) {

        if (pages[index] == HrSettingPath){
          if (baseIndex == index) {
            return;
          }
          //各種設定
          gotoHrSettingPage(context);
          return;
        }
        //パスワード設定
        if (pages[index] == HrEditProfilePath){
          if (baseIndex == index) {
            gotoHrSettingPage(context);
            return;
          }
          gotoHrSettingPage(context);
          gotoHrEditProfilePage(context);
          return;
        }

        if (pages[index] == HrEventSettingPath){
          if (baseIndex == index) {
            gotoHrSettingPage(context);
            return;
          }
          gotoHrEventSettingPage(context);
          return;
        }
/*  事業所設定 北陸は無し
        if (pages[index] == HrSelectBranchPath){
          if (baseIndex == index) {
            gotoHrSettingPage(context);
            return;
          }
          gotoHrSelectBranchPage(context);
          return;
        }

 */

        // 各種設定画面へ
        gotoHrSettingPage(context);
        return;
      }

      if (index == HrNavigationMenuItem.chat.index) {
        if (pages[index] == HrChatListPath){
          if (baseIndex == index) {
            return;
          }
          //チャットリストページへ遷移
          gotoHrChatListPage(context);
          return;
        }

        if (pages[index] == HrChatPath){
          if (baseIndex == index) {
            return;
          }
          gotoHrChatListPage(context);
          return;
        }
      }
    },

    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.indigo,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
    items: _hrBottomNavBarItems(),

  );
}
// 中国のパーツ

// ページ下部に並べるナビゲーションメニューの一覧
List<BottomNavigationBarItem> _cgBottomNavBarItems() {
  return const [
    BottomNavigationBarItem(
      icon: Icon(Icons.business),
      label: '帰所',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '電柱検索',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storage),
      label: '事象管理',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '各種設定',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.textsms),
      label: 'チャット',
    ),
  ];
}

// ページ下部に並べるボトムナビゲーションバー
BottomNavigationBar cgBottomNavigationBar(
    BuildContext context, Auth auth, int idx, int belongTo,Chugoku chugoku) {
  final baseIndex = idx;
  return BottomNavigationBar(
    currentIndex: idx,
    onTap: (index) {

      final pages = getBeforePages(belongTo);

      if (index == CgNavigationMenuItem.locate.index) {
        if (baseIndex == index)
          return;
        if (chugoku.office.latitude == null ||
            chugoku.office.longitude == null) {
          return;
        }
        gotoCgLocateOfficePage(context);
      }

      if (index == CgNavigationMenuItem.search.index) {

        if (pages[index] == CgSelectPolePath){
          if (baseIndex == index)
            return;
          gotoCgSelectPolePage(context);
          return;
        }
        if (pages[index] == CgShowPolePath){
          if (baseIndex == index) {
            gotoCgSelectPolePage(context);
            return;
          }
          gotoCgShowPolePage(context);
          return;
        }
        return;
      }

      if (index == CgNavigationMenuItem.event.index) {

        if (pages[index] == CgEventSelectPath){
          if (baseIndex == index) {
            return;
          }
          gotoCgEventSelectPage(context);
          return;
        }
        if (pages[index] == CgEventAddPath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(CgEventSelectPath));
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(CgEventAddPath));
          return;
        }
        if (pages[index] == CgEventPolePath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(CgEventSelectPath));
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(CgEventPolePath));
          return;
        }
        if (pages[index] == CgEventListPath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(CgEventSelectPath));
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(CgEventListPath));
          return;
        }

        if (pages[index] == CgEventListWorkPath){
          if (baseIndex == index) {
            gotoCgEventSelectPage(context);
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoCgEventListWorkPage(context);
          return;
        }

        if (pages[index] == CgEventDetailPath){
          if (baseIndex == index) {
            gotoCgEventSelectPage(context);
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          gotoCgEventDetailPage(context);
          return;
        }

        if (pages[index] == CgEventDetailWorkPath){
          if (baseIndex == index) {
            gotoCgEventSelectPage(context);
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoCgEventDetailWorkPage(context);
          return;
        }

        if (pages[index] == CgEventUpdatePath){
          if (baseIndex == index) {
            gotoCgEventSelectPage(context);
            setBeforePage(belongTo, index, CgEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoCgEventUpdatePage(context);
          return;
        }

        // 事象管理画面へ
        gotoCgEventSelectPage(context);
        return;
      }

      if (index == CgNavigationMenuItem.setting.index) {

        if (pages[index] == CgSettingPath){
          if (baseIndex == index) {
            return;
          }
          gotoCgSettingPage(context);
          return;
        }
        if (pages[index] == CgEditProfilePath){
          if (baseIndex == index) {
            gotoCgSettingPage(context);
            return;
          }
          gotoCgSettingPage(context);
          gotoCgEditProfilePage(context);
          return;
        }
        if (pages[index] == CgEventSettingPath){
          if (baseIndex == index) {
            gotoCgSettingPage(context);
            return;
          }
          gotoCgEventSettingPage(context);
          return;
        }

        if (pages[index] == CgSelectOfficePath){
          if (baseIndex == index) {
            gotoCgSettingPage(context);
            return;
          }
          gotoCgSelectOfficePage(context);
          return;
        }

        // 各種設定画面へ
        //gotoSettingPage(context);
        return;
      }

      if (index == CgNavigationMenuItem.chat.index) {
        if (pages[index] == CgChatListPath){
          if (baseIndex == index) {
            return;
          }
          //チャットページへ遷移
          gotoCgChatListPage(context);
          return;
        }

        if (pages[index] == CgChatPath){
          if (baseIndex == index) {
            return;
          }

          gotoCgChatListPage(context);
          return;
        }
      }
    },

    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.indigo,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
    items: _cgBottomNavBarItems(),
  );
}




List<BottomNavigationBarItem> _chBottomNavBarItems() {
  return const [
    BottomNavigationBarItem(
      icon: Icon(Icons.business),
      label: '帰所',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '電柱検索',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storage),
      label: '事象管理',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '各種設定',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.textsms),
      label: 'チャット',
    ),
  ];
}

BottomNavigationBar chBottomNavigationBar(
    BuildContext context, Auth auth, int idx, int belongTo,Chuden chuden) {
  final baseIndex = idx;
  return BottomNavigationBar(
    currentIndex: idx,
    onTap: (index) {

      final pages = getBeforePages(belongTo);

      if (index == ChNavigationMenuItem.locate.index) {
        if (baseIndex == index)
          return;
        if (chuden.office.latitude == null ||
            chuden.office.longitude == null) {
          return;
        }
        gotoChLocateOfficePage(context);
      }

      if (index == ChNavigationMenuItem.search.index) {

        if (pages[index] == ChSelectPolePath){
          if (baseIndex == index)
            return;
          gotoChSelectPolePage(context);
          return;
        }
        if (pages[index] == ChShowPolePath){
          if (baseIndex == index) {
            gotoChSelectPolePage(context);
            return;
          }
          gotoChShowPolePage(context);
          return;
        }
        return;
      }

      if (index == ChNavigationMenuItem.event.index) {

        if (pages[index] == ChEventSelectPath){
          if (baseIndex == index) {
            return;
          }
          gotoChEventSelectPage(context);
          return;
        }
        if (pages[index] == ChEventAddPath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(ChEventSelectPath));
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(ChEventAddPath));
          return;
        }
        if (pages[index] == ChEventPolePath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(ChEventSelectPath));
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(ChEventPolePath));
          return;
        }
        if (pages[index] == ChEventListPath){
          if (baseIndex == index) {
            Navigator.popUntil(context, ModalRoute.withName(ChEventSelectPath));
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          Navigator.popUntil(context, ModalRoute.withName(ChEventListPath));
          return;
        }

        if (pages[index] == ChEventListWorkPath){
          if (baseIndex == index) {
            gotoChEventSelectPage(context);
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoChEventListWorkPage(context);
          return;
        }

        if (pages[index] == ChEventDetailPath){
          if (baseIndex == index) {
            gotoChEventSelectPage(context);
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          gotoChEventDetailPage(context);
          return;
        }

        if (pages[index] == ChEventDetailWorkPath){
          if (baseIndex == index) {
            gotoChEventSelectPage(context);
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoChEventDetailWorkPage(context);
          return;
        }

        if (pages[index] == ChEventUpdatePath){
          if (baseIndex == index) {
            gotoChEventSelectPage(context);
            setBeforePage(belongTo, index, ChEventSelectPath);
            return;
          }
          //Navigator.popUntil(context, ModalRoute.withName(EventUpdatePath));
          gotoChEventUpdatePage(context);
          return;
        }

        // 事象管理画面へ
        gotoChEventSelectPage(context);
        return;
      }

      if (index == ChNavigationMenuItem.setting.index) {

        if (pages[index] == ChSettingPath){
          if (baseIndex == index) {
            return;
          }
          gotoChSettingPage(context);
          return;
        }
        if (pages[index] == ChEditProfilePath){
          if (baseIndex == index) {
            gotoChSettingPage(context);
            return;
          }
          gotoChSettingPage(context);
          gotoChEditProfilePage(context);
          return;
        }
        if (pages[index] == ChEventSettingPath){
          if (baseIndex == index) {
            gotoChSettingPage(context);
            return;
          }
          gotoChEventSettingPage(context);
          return;
        }

        if (pages[index] == ChSelectBranchPath){
          if (baseIndex == index) {
            gotoChSettingPage(context);
            return;
          }
          gotoChSelectBranchPage(context);
          return;
        }

        // 各種設定画面へ
        //gotoSettingPage(context);
        return;
      }

      if (index == ChNavigationMenuItem.chat.index) {
        if (pages[index] == ChChatListPath){
          if (baseIndex == index) {
            return;
          }
          //チャットページへ遷移
          gotoChChatListPage(context);
          return;
        }

        if (pages[index] == ChChatPath){
          if (baseIndex == index) {

            return;
          }

          gotoChChatListPage(context);
          return;
        }
      }
    },

    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.indigo,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
    items: _chBottomNavBarItems(),
  );
}

// showHeader は一般的な見出しを表示します。
Widget showHeader(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
    child: Text(
      title,
      style: const TextStyle(fontSize: 26),
      textAlign: TextAlign.center,
    ),
  );
}

// showText は、説明・注意書きなど、一般的なテキストを表示します。
Widget showText(String msg) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
    child: showTextCustom(msg, 22, Colors.black, null, null)
  );
}

Widget showTextCustom(String msg, double fontSize, Color color, TextOverflow overflow, int maxLines){
  return Text(
    msg,
    style: TextStyle(
      color: color,
      fontSize: fontSize,
    ),
    maxLines: maxLines,
    overflow: overflow,
  );
}

// showTextInput は、テキスト入力ボックスを表示します。
Widget showTextInput(TextInputType type, String hint, IconData icon,
    FormFieldValidator<String> validator, ValueChanged<String> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: TextFormField(
      maxLines: 1,
      keyboardType: type,
      autofocus: false,
      style: const TextStyle(
        fontSize: 22
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        filled: true,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
            borderSide: BorderSide(
            )

        ),
      ),
      validator: (value) => validator(value.trim()),
      onChanged: (value) => onChanged(value.trim()),
    ),
  );
}

// showUsernameInput は、ログインID入力ウィジェットを表示します。
Widget showUsernameInput(String hint, FocusNode focus,
    FormFieldValidator<String> validator, ValueChanged<String> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: TextFormField(
      focusNode: focus,
      maxLines: 1,
      autofillHints: const [AutofillHints.username],
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      style: const TextStyle(
          fontSize: 22
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        filled: true,
        hintText: hint,
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
            borderSide: BorderSide(
        )
        ),
      ),
      validator: (value) => validator(value.trim()),
      onChanged: (value) => onChanged(value.trim()),
    ),
  );
}

// showPasswordInput は、パスワード入力ウィジェットを表示します。
Widget showPasswordInput(String hint, FocusNode focus, bool hide, ValueChanged<String> onChange,
    ValueChanged<bool> onCheck) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(children: <Widget>[
        TextFormField(
          focusNode: focus,
          maxLines: 1,
          autofillHints: const [AutofillHints.password],
          obscureText: hide,
          autofocus: false,
          style: const TextStyle(
              fontSize: 22
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            hintText: hint,
              filled: true,
              prefixIcon: const Icon(
                Icons.lock,
                color: Colors.grey,
              ),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(
                  )
              ),
          ),
          validator: (value) => value.length < minimumPWLength
              ? 'パスワードは$minimumPWLength文字以上です'
              : null,
          onChanged: (value) => onChange(value.trim()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Checkbox(
              activeColor: Colors.blue,
              onChanged: (value) => onCheck(!value),
              value: !hide,
            ),
            const Text('パスワード表示'),
          ],
        )
      ]));
}

// showPasswordChange は、パスワード入力ウィジェットを表示します。
Widget showPasswordChange(String hint, FocusNode focus, bool hide, ValueChanged<String> onChange,
    ValueChanged<bool> onCheck) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(children: <Widget>[
        TextFormField(
          focusNode: focus,
          maxLines: 1,
          obscureText: hide,
          autofocus: false,
          style: const TextStyle(
              fontSize: 22
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            hintText: hint,
            filled: true,
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.grey,
            ),
            border: const OutlineInputBorder(
                borderSide: BorderSide(
                )
            ),
          ),
          validator: (value) => value.length < minimumPWLength
              ? 'パスワードは$minimumPWLength文字以上です'
              : null,
          onChanged: (value) => onChange(value.trim()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Checkbox(
              activeColor: Colors.blue,
              onChanged: (value) => onCheck(!value),
              value: !hide,
            ),
            const Text('パスワード表示'),
          ],
        )
      ]));
}

// showSubmit は、ボタンを返します。
Widget showSubmit(GlobalKey<FormState> formKey, String title, Size size, double fontSize, Color bgColor,
    VoidCallback onPressed) {
  return SizedBox(
      width: size.width,
      height: size.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            primary: bgColor,
        ),
        child: Text(
            title,
            style: TextStyle(
                fontSize: fontSize,
                color: Colors.white
            )
        ),
      ));
}

// showSubmitBox は、選択ボックスボタンを返します。
Widget showSubmitBox(GlobalKey<FormState> formKey, String title, Size size, double fontSize, Color color,
    VoidCallback onPressed) {
  return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFFEEEEEE),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          child: Text(
              title,
              style: TextStyle(
                  fontSize: fontSize,
                  color: color,
              )
          ),
        )
      )
  );
}

// showGuidButton は、誘導、防災情報ボタンを返します。
Widget showGuidButton(double latitude, double longitude){
  return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: showIconButton(
                '誘導', Icons.directions, () => goToNavigationMap(latitude, longitude))
        ),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: showIconButton(
                '防災情報', null, null)
        )
      ]
  );
}

// showIconButton は、アイコンボタンを返します。
Widget showIconButton(String text, IconData icon, VoidCallback callback) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
        ),
        elevation: 15,
      ),
      child: SizedBox(
        width:110,
        height: 40,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            icon != null ?
              Icon(icon, size: 30) : const SizedBox.shrink(),
            showTextCustom(text, 20, null, null, 1),
          ]
        ),
      ),
      //icon: Icon(icon),
      onPressed: callback
  );
}

Widget showCheckBox(String text, bool value, Function(bool) onChanged){
  return Row(
    children: [
      SizedBox(
          height: 40,
          width:25,
          child: Checkbox(
            activeColor: Colors.blue,
            value: value,
            onChanged: onChanged,
          )
      ),
      GestureDetector(
        child: Container(
          decoration: const BoxDecoration(
              //color: Colors.blue,
            border: Border(
              //bottom: BorderSide(color: Colors.red)
            )
          ),
          child: showTextCustom(text, 22, Colors.black, null, 1)
        ),
        onTap: (){
          onChanged(!value);
        },
      ),
    ],
  );
}

Widget showSwitch(bool show, Function(bool) onChanged){
  return Transform.scale(
    scale: 2,
    child: Switch(
      value: show,
      activeColor: Colors.white,
      activeTrackColor: Colors.indigo,
      inactiveThumbColor: Colors.white,
      onChanged: onChanged,
    ),
  );
}

Widget showSwitchTile(String title, bool show, Function(bool) onChanged){
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: showTextCustom(title, 22, Colors.black, null, 1),
            ),
            Container(
              child: showSwitch(show, onChanged),
            ),
          ],
        )
    ),
  );
}

Widget showCategoryTile(BuildContext context, String title, VoidCallback tapEvent, {Color color=Colors.black}){
  return InkWell(
    child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showTextCustom(title, 22, color, null, 1),
            const Icon(Icons.chevron_right, size: 40, color: Colors.indigo,)
          ],
        )
    ),
    onTap: tapEvent,
  );
}
//トーンダウン用
Widget showCategoryTile_gray(BuildContext context, String title, VoidCallback tapEvent, {Color color=Colors.grey}){
  return InkWell(
    child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showTextCustom(title, 22, color, null, 1),
            const Icon(Icons.chevron_right, size: 40, color: Colors.grey,)
          ],
        )
    ),
    onTap: tapEvent,
  );
}

// showPopup は、メッセージをポップアップ表示します。
void showPopup(String msg, BuildContext context) {
  showDialog<CupertinoAlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Container(
            margin: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 20,
                )
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: showTextCustom('確認', 16, popButtonColor, null, 1),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      });
}

// showPopup は、確認ダイアログをポップアップ表示します。
void showPopupConfirm(String msg, BuildContext context, VoidCallback onConfirm) {
  showDialog<CupertinoAlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Container(
            margin: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
                msg,
                style: const TextStyle(
                    fontSize: 20,
                )
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text(
                  'キャンセル',
                  style: TextStyle(
                    //color: popButtonColor
                  )
              ),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text(
                '決定',
              ),
              isDestructiveAction: true,
              onPressed: (){
                Navigator.pop(context);
                onConfirm();
              },
            ),
          ],
        );
      });
}

// showPopupSelect は、選択肢ダイアログをポップアップ表示します。
void showPopupSelect(String msg, BuildContext context, String select1, String select2,
    VoidCallback onSelect1, VoidCallback onSelect2) {
  showDialog<CupertinoAlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Container(
            margin: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
              msg,
              style: const TextStyle(
                  fontSize: 20
              )
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                  select1,
                  style: const TextStyle(
                      fontSize: 20
                  )
              ),
              onPressed: (){
                Navigator.pop(context);
                onSelect1();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                select2,
                style: const TextStyle(
                    fontSize: 20
                )
              ),
              isDestructiveAction: true,
              onPressed: (){
                Navigator.pop(context);
                onSelect2();
              },
            ),
          ],
        );
      });
}

Future<bool> showPopupLocationService(BuildContext context) async{
  if (await isLocationStatusDisabled()) {
    if (Platform.isIOS) {
      showPopup('位置情報を有効にしてください', context);
    } else {
      showPopupSelect('位置情報を有効にしてください', context,
          'キャンセル', '設定', () {}, () => locationServiceRequest);
    }
    return false;
  }
  else if (await isLocationStatusDenied()) {
    showPopupSelect('位置情報へのアクセスを許可してください', context,
        'キャンセル', '設定', (){}, () => openAppSettingsPage);
    return false;
  }
  return true;
}


// showNetworkError は、接続失敗メッセージをポップアップ表示します。
void showNetworkError(BuildContext context) {
  showPopup('サーバ接続に失敗しました。電波状況の良いところで再度お試しください', context);
}

// showError は、与えられたエラーをポップアップ表示します。
void showError(Object err, BuildContext context) {
  showPopup('$err', context);
}

// showUserProfile は、ユーザプロフィールを表示します。
Widget showUserProfile(LoginUser user) {
  return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          //showTextCustom('ログインユーザー：${user.name}', 16, Colors.black, null, 1),
          showTextCustom('所属：${user.getPowerCompany()}', 16, Colors.black, null, 1),
        ],
      ));
}

// showInfo は、バージョン情報を表示します。
Widget showInfo(LoginUser user, Map versions) {
  return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        children: <Widget>[
          versions != null ?
          Padding(
            padding: const EdgeInsets.only(top: 5),
              child: showTextCustom(
                '${versions['date']} : v${versions['version']} ', 18, Colors.black, null, 1)
          )
          : const SizedBox.shrink(),
        ],
      )
  );
}

// 決定ボタンの前に入れる隙間
Widget addPadding(int magnification) {
  return Padding(
    padding: EdgeInsets.all(5.0 * magnification),
  );
}

Widget showSwiperImage(List<String> image, SwiperOnTap callback){
  return Swiper(
    itemBuilder: (BuildContext context, int index) {
      return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child:CachedNetworkImage(
              imageUrl: image[index],
              fit: BoxFit.fill,
              placeholder: (context, url) =>
                  const Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  )
          )
      );
    },
    itemCount: image.length,
    loop: false,
    control: image.length > 1
        ? const SwiperControl(
      color: Colors.black,
      size: 40,
      padding: EdgeInsets.all(0),
    ) : null,
    pagination: image.length > 1
        ? const SwiperPagination(
        builder: DotSwiperPaginationBuilder(
          color: Colors.black12,
          size: 5,
        ),
        margin: EdgeInsets.only(top: 10),
    ) : null,
    viewportFraction: 0.4,
    scale: 0.5,
    onTap: (index) => callback(index),
  );
}

Widget showSwiperImageUpdate(List<String> imagePath, SwiperOnTap addImage, SwiperOnTap viewerImage, SwiperOnTap removeImage){
  if (imagePath.isEmpty || (imagePath.length < 5 && imagePath.last != null)) {
    imagePath.add(null);
  }
  return Swiper(
    itemBuilder: (BuildContext context, int index) {
      if (imagePath[index] == null){
        print('debug');
        return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              border: Border.all(),
              color: const Color(0x0D000000),
            ),
            child: Center(
                child: showTextCustom('画像追加', 20, Colors.grey, null, 1)
            )
        );
      }
      else {
        return GestureDetector(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: imagePath[index].startsWith('https://firebasestorage.googleapis.com') ?
                  CachedNetworkImage(
                      imageUrl: imagePath[index],
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          const Center(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          )
                  ) :
                    Container(
                      width: 1100,
                      height: 1100,
                      child:Image.file(
                        File(imagePath[index]),
                        fit: BoxFit.fill,
                      ),

                    )

              ),

              //削除ボタン
              Align(
                alignment: Alignment(-1.45,-1.18),
                child: ElevatedButton(
                  child: Icon(
                    Icons.clear,
                    color : Colors.black,
                    size: 24,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(222, 222, 222,100),
                    onPrimary: Colors.black,
                    minimumSize: Size(1, 1),
                    shape: const CircleBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  onPressed: () {removeImage(index);},
                ),
              ),

            ],
          ),
            onTap: (){
              if (imagePath[index] == null) {
                addImage(index);
              }
              else {
                viewerImage(index);
              }
            },
            onLongPress: (){
              removeImage(index);
            },
        );
      }
    },
    itemCount: imagePath.length,
    loop: false,
    control: imagePath.length > 1
        ? const SwiperControl(
      color: Colors.black,
      size: 40,
      padding: EdgeInsets.all(0),
    ) : null,
    pagination: imagePath.length > 1
        ? const SwiperPagination(
      builder: DotSwiperPaginationBuilder(
        color: Colors.black12,
        size: 5,
      ),
      margin: EdgeInsets.only(top:10),
    ) : null,
    viewportFraction: 0.4,
    scale: 0.5,
    onTap: (index){
      if (imagePath[index] == null){
        addImage(index);
      } else {
        removeImage(index);
      }
    },
  );
}



const popButtonColor = Colors.blue;

bool validateEmail(String value) {
  // https://medium.com/@nitishk72/form-validation-in-flutter-d762fbc9212c
  const emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final emailRegexp = RegExp(emailPattern);
  return validateWithRegex(emailRegexp, value);
}

bool validateNumber(String value) {
  // https://medium.com/@nitishk72/form-validation-in-flutter-d762fbc9212c
  const number = '[0-9]+';
  final numberRegexp = RegExp(number);
  return validateWithRegex(numberRegexp, value);
}

bool validateLineAndPole(String value) {
  const lineandpole = r'^[ぁ-んァ-ン一-龥]|/^[0-9０-９]+$/| /^[a-zA-Z]+$/';
  final lineandpoleRegexp = RegExp(lineandpole);
  return validateWithRegex(lineandpoleRegexp, value);
}

bool keydataline(String key) {
  const linekey = r'/^[ぁ-んァ-ン]+$/';
  final linekeyRegexp = RegExp(linekey);
  return validateWithRegex(linekeyRegexp, key);
}


bool validateWithRegex(RegExp regex, String value) {
  try {
    final matches = regex.allMatches(value);
    for (final match in matches) {
      if (match.start == 0 && match.end == value.length) {
        return true;
      }
    }
    return false;
  } on Exception catch (e) {
    assert(false, e.toString());
    return true;
  }
}
// showPickerAreaは、管理区ピッカを表示します
void showAreaPicker(
    BuildContext context,
    List<List<String>> data,
    List<int> selected,
    PickerConfirmCallback cbConfirm) {

  Picker picker;
  picker = Picker(
      adapter: PickerDataAdapter<String>(
        pickerdata: data,
        isArray: true,
      ),
      height: MediaQuery.of(context).copyWith().size.height / 3,
      itemExtent: 50,
      hideHeader: false,
      selecteds: selected,

      selectedTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.blueAccent
      ),

      cancelText: 'キャンセル',
      cancelTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.blue
      ),

      confirmText: '決定',
      confirmTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.blue
      ),

      onSelect: (picker,index,select){
        for (var i = 0; i < data.length; i++) {
          if (data[i][selected[i]] == '*') {
            for (var j = i; j < data.length; j++){
              picker.state.scrollController[j].jumpToItem(0);
            }
            return;
          }
        }
      },
      onConfirm: cbConfirm
  );
  picker.showModal<void>(context);
}

// showPickerPole は、電柱番号ピッカを表示します。
void showPolePicker(
    BuildContext context,
    List<List<String>> data,
    List<int> selected,
    PickerConfirmCallback cbConfirm) {

  Picker picker;
   picker = Picker(
      adapter: PickerDataAdapter<String>(
        pickerdata: data,
        isArray: true,
      ),
       height: MediaQuery.of(context).copyWith().size.height / 3,
      itemExtent: 50,
      hideHeader: false,
      selecteds: selected,

       selectedTextStyle: const TextStyle(
           fontSize: 22,
           color: Colors.blueAccent
       ),

       cancelText: 'キャンセル',
       cancelTextStyle: const TextStyle(
           fontSize: 22,
           color: Colors.blue
       ),

       confirmText: '決定',
       confirmTextStyle: const TextStyle(
           fontSize: 22,
           color: Colors.blue
       ),

      onSelect: (picker,index,select){
        for (var i = 0; i < data.length; i++) {
          if (data[i][selected[i]] == '*') {
            for (var j = i; j < data.length; j++){
              picker.state.scrollController[j].jumpToItem(0);
            }
            return;
          }
        }
      },
      onConfirm: cbConfirm
  );
  picker.showModal<void>(context);
}

// showPicker は、ピッカを表示します。
void showPicker(
    BuildContext context,
    List<List<String>> data,
    List<int> selected,
    String footerText,
    PickerSelectedCallback cbSelect,
    PickerConfirmCallback cbConfirm) {
  Picker(
    adapter: PickerDataAdapter<String>(
      pickerdata: data,
      isArray: true,
    ),
    height: MediaQuery.of(context).copyWith().size.height / 3,
    itemExtent: 50,
    hideHeader: false,
    selecteds: selected,

    selectedTextStyle: const TextStyle(
        fontSize: 22,
        color: Colors.blueAccent
    ),

    cancelText: 'キャンセル',
    cancelTextStyle: const TextStyle(
        fontSize: 22,
        color: Colors.blue
    ),

    confirmText: '決定',
    confirmTextStyle: const TextStyle(
        fontSize: 22,
        color: Colors.blue
    ),

    footer: footerText != null ?
    Container(
        margin: const EdgeInsets.only(bottom:5),
        alignment: Alignment.center,
        color: Colors.white,
        child: Text(
          footerText,
          style: const TextStyle(
            fontSize: 20,
          ),
        )
    ): null,
    onSelect: cbSelect,
    onConfirm: cbConfirm,
  ).showModal<void>(context);
}

// showProgressIndicator は、プログレスインジケータを表示します。
void showProgressIndicator(BuildContext context) {
    showDialog<Column>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                ),
              ],
            );
        });
}

List<String> omoji = [
  'ア', 'イ', 'ウ', 'エ', 'オ',
  'カ', 'キ', 'ク', 'ケ', 'コ',
  'サ', 'シ', 'ス', 'セ', 'ソ',
  'タ', 'チ', 'ツ', 'テ', 'ト',
  'ナ', 'ニ', 'ヌ', 'ネ', 'ノ',
  'ハ', 'ヒ', 'フ', 'ヘ', 'ホ',
  'マ', 'ミ', 'ム', 'メ', 'モ',
  'ヤ', 'ユ', 'ヨ',
  'ラ', 'リ', 'ル', 'レ', 'ロ',
  'ワ', 'ヲ', 'ン',
  'ァ', 'ィ', 'ゥ', 'ェ', 'ォ',
  'ャ', 'ュ', 'ョ',
  'ッ',
  'ー',
  'ガ', 'ギ', 'グ', 'ゲ', 'ゴ',
  'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ',
  'ダ', 'ヂ', 'ヅ', 'デ', 'ド',
  'バ', 'ビ', 'ブ', 'ベ', 'ボ',
  'パ', 'ピ', 'プ', 'ペ', 'ポ',
  'Ａ', 'Ｂ', 'Ｃ', 'Ｄ', 'Ｅ',
  'Ｆ', 'Ｇ', 'Ｈ', 'Ｉ', 'Ｊ',
  'Ｋ', 'Ｌ', 'Ｍ', 'Ｎ', 'Ｏ',
  'Ｐ', 'Ｑ', 'Ｒ', 'Ｓ', 'Ｔ',
  'Ｕ', 'Ｖ', 'Ｗ', 'Ｘ', 'Ｙ', 'Ｚ',
  'ａ', 'ｂ', 'ｃ', 'ｄ', 'ｅ',
  'ｆ', 'ｇ', 'ｈ', 'ｉ', 'ｊ',
  'ｋ', 'ｌ', 'ｍ', 'ｎ', 'ｏ',
  'ｐ', 'ｑ', 'ｒ', 'ｓ', 'ｔ',
  'ｕ', 'ｖ', 'ｗ', 'ｘ', 'ｙ', 'ｚ',
  '０', '１', '２', '３', '４', '５', '６', '７', '８', '９'
];

List<String> komoji = [
  'ｱ', 'ｲ', 'ｳ', 'ｴ', 'ｵ',
  'ｶ', 'ｷ', 'ｸ', 'ｹ', 'ｺ',
  'ｻ', 'ｼ', 'ｽ', 'ｾ', 'ｿ',
  'ﾀ', 'ﾁ', 'ﾂ', 'ﾃ', 'ﾄ',
  'ﾅ', 'ﾆ', 'ﾇ', 'ﾈ', 'ﾉ',
  'ﾊ', 'ﾋ', 'ﾌ', 'ﾍ', 'ﾎ',
  'ﾏ', 'ﾐ', 'ﾑ', 'ﾒ', 'ﾓ',
  'ﾔ', 'ﾕ', 'ﾖ',
  'ﾗ', 'ﾘ', 'ﾙ', 'ﾚ', 'ﾛ',
  'ﾜ', 'ｦ', 'ﾝ',
  'ｧ', 'ｨ', 'ｩ', 'ｪ', 'ｫ',
  'ｬ', 'ｭ', 'ｮ',
  'ﾂ',
  '-',
  'ｶﾞ', 'ｷﾞ', 'ｸﾞ', 'ｹﾞ', 'ｺﾞ',
  'ｻﾞ', 'ｼﾞ', 'ｽﾞ', 'ｾﾞ', 'ｿﾞ',
  'ﾀﾞ', 'ﾁﾞ', 'ﾂﾞ', 'ﾃﾞ', 'ﾄﾞ',
  'ﾊﾞ', 'ﾋﾞ', 'ﾌﾞ', 'ﾍﾞ', 'ﾎﾞ',
  'ﾊﾟ', 'ﾋﾟ', 'ﾌﾟ', 'ﾍﾟ', 'ﾎﾟ',
  'a', 'b', 'c', 'd', 'e', 'f',
  'g', 'h', 'i', 'j', 'k', 'l',
  'm', 'n', 'o', 'p', 'q', 'r',
  's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  'A', 'B', 'C', 'D', 'E', 'F',
  'G', 'H', 'I', 'J', 'K', 'L',
  'M', 'N', 'O', 'P', 'Q', 'R',
  'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
];
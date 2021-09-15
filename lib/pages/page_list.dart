// Page List
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polesearcherapp/pages/common.dart';

// 元のページに戻る
void previous(BuildContext context) {
  Navigator.pop(context);
}

// 電力会社共通
const LoginPagePath = '/'; // ログイン
const UnAuthPagePath = '/unAuth'; // メールアドレス未認証ログイン
const UnSupportedPath = '/unSupported'; // 未実装画面
const PwResetPath = '/pwReset'; // パスワード再発行画面

// gotoLoginPage は、ログインページに戻ります。
void gotoLoginPage(BuildContext context) {
//  Navigator.popUntil(context, ModalRoute.withName(LoginPagePath));
  initBeforePages();
  getLocationStreamCancel();
  Navigator.popUntil(context, ModalRoute.withName(LoginPagePath));
}

// gotoUnAuthPageは、未認証ページを表示します。
void gotoUnAuthPage(BuildContext context) {
  Navigator.pushNamed(context, UnAuthPagePath);
}

// gotoUnSupportedPageは、未実装ページを表示します。
void gotoUnSupportedPage(BuildContext context) {
  Navigator.pushNamed(context, UnSupportedPath);
}

//gotoPwResetPageは、パスワード再発行ページを表示します。
void gotoPwResetPage(BuildContext context) {
  Navigator.pushNamed(context, PwResetPath);
}

// 　北陸電力
const HrSettingPath = '/hrSetting'; // 各種設定画面
const HrEditProfilePath = '/hrEditProfile';// ユーザ作成画面

const HrSelectBranchPath = '/hrSelectBranch'; // 管理区？選択画面　多分使わない
const HrSelectPolePath = '/hrSelectPole'; // 電柱選択画面
const HrShowPolePath = '/hrShowPole'; // 電柱詳細画面
const HrLocateOfficePagePath = '/hrLocateOffice';//帰所画面

const HrChatPath = '/hrChat';
const HrChatListPath = '/hrChatList';

// gotoSettingPageは、各種設定ページを表示します。
void gotoHrSettingPage(BuildContext context) {
  Navigator.pushNamed(context, HrSettingPath);
}

// gotoUnEditProfilePageは、設定ページを表示します。
void gotoHrEditProfilePage(BuildContext context) {
  Navigator.pushNamed(context, HrEditProfilePath);
}


//事業所設定画面を表示 北陸では使わない
void gotoHrSelectBranchPage(BuildContext context) {
  //Navigator.pushNamed(context, HrSelectBranchPath);
}

//電柱選択画面を表示
void gotoHrSelectPolePage(BuildContext context) {
  Navigator.pushNamed(context, HrSelectPolePath);
}

//電柱詳細画面を表示
void gotoHrShowPolePage(BuildContext context) {
  Navigator.pushNamed(context, HrShowPolePath);
}
//帰所画面を表示
void gotoHrLocateOfficePage(BuildContext context) {
  Navigator.pushNamed(context, HrLocateOfficePagePath);
}

//チャット画面を表示
void gotoHrChatPage(BuildContext context){
  Navigator.pushNamed(context, HrChatPath);
}

void gotoHrChatListPage(BuildContext context){
  Navigator.pushNamed(context, HrChatListPath);
}

//北陸事象管理
const HrEventSelectPath = '/hrEventSelect';
const HrEventAddPath = '/hrEventAdd';
const HrEventPolePath = '/hrEventPole';
const HrEventListPath = '/hrEventList';
const HrEventListWorkPath = '/hrEventListWork';
const HrEventDetailPath = '/hrEventDetail';
const HrEventDetailWorkPath = '/hrEventDetailWork';
const HrEventUpdatePath = '/hrEventUpdate';
const HrEventSettingPath = '/hrEventSetting';


void gotoHrEventSelectPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventSelectPath);
}

void gotoHrEventAddPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventAddPath);
}

void gotoHrEventListPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventListPath);
}

void gotoHrEventListWorkPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventListWorkPath);
}

void gotoHrEventDetailPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventDetailPath);
}

void gotoHrEventDetailWorkPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventDetailWorkPath);
}

void gotoHrEventUpdatePage(BuildContext context) {
  Navigator.pushNamed(context, HrEventUpdatePath);
}

void gotoHrEventSettingPage(BuildContext context) {
  Navigator.pushNamed(context, HrEventSettingPath);
}


// 中国電力
const CgSettingPath = '/cgSetting'; // 各種設定画面
const CgEditProfilePath = '/cgEditProfile'; // プロフィール編集画面

const CgSelectOfficePath = '/cgSelectOffice'; // 支社電力センター選択
const CgSelectPolePath = '/cgSearchPole'; // 電柱選択画面
const CgShowPolePath = '/cgShowPole'; // 電柱詳細画面

const CgLocateOfficePagePath = '/cgLocateOffice';

const CgChatPath = '/cgChat';
const CgChatListPath = '/cgChatList';

// gotoUnEditProfilePageは、設定ページを表示します。
void gotoCgEditProfilePage(BuildContext context) {
  Navigator.pushNamed(context, CgEditProfilePath);
}

// gotoSettingPageは、各種設定ページを表示します。
void gotoCgSettingPage(BuildContext context) {
  Navigator.pushNamed(context, CgSettingPath);
}

void gotoCgSelectOfficePage(BuildContext context) {
  Navigator.pushNamed(context, CgSelectOfficePath);
}

void gotoCgSelectPolePage(BuildContext context) {
  Navigator.pushNamed(context, CgSelectPolePath);
}

void gotoCgShowPolePage(BuildContext context) {
  Navigator.pushNamed(context, CgShowPolePath);
}

void gotoCgLocateOfficePage(BuildContext context) {
  Navigator.pushNamed(context, CgLocateOfficePagePath);
}
//チャット画面を表示
void gotoCgChatPage(BuildContext context){
  Navigator.pushNamed(context, CgChatPath);
}

void gotoCgChatListPage(BuildContext context){
  Navigator.pushNamed(context, CgChatListPath);
}

//中国事象管理
const CgEventSelectPath = '/cgEventSelect';
const CgEventAddPath = '/cgEventAdd';
const CgEventPolePath = '/cgEventPole';
const CgEventListPath = '/cgEventList';
const CgEventListWorkPath = '/cgEventListWork';
const CgEventDetailPath = '/cgEventDetail';
const CgEventDetailWorkPath = '/cgEventDetailWork';
const CgEventUpdatePath = '/cgEventUpdate';
const CgEventSettingPath = '/cgEventSetting';

void gotoCgEventSelectPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventSelectPath);
}

void gotoCgEventAddPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventAddPath);
}

void gotoCgEventListPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventListPath);
}

void gotoCgEventListWorkPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventListWorkPath);
}

void gotoCgEventDetailPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventDetailPath);
}

void gotoCgEventDetailWorkPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventDetailWorkPath);
}

void gotoCgEventUpdatePage(BuildContext context) {
  Navigator.pushNamed(context, CgEventUpdatePath);
}

void gotoCgEventSettingPage(BuildContext context) {
  Navigator.pushNamed(context, CgEventSettingPath);
}

//中部ページ一覧

const ChSettingPath = '/chSetting'; // 各種設定画面
const ChEditProfilePath = '/chEditProfile';

const ChSelectBranchPath = '/chSelectBranch'; // 支店営業所選択
const ChSelectPolePath = '/chSelectPole'; // 電柱選択画面
const ChShowPolePath = '/chShowPole'; // 電柱詳細画面

const ChLocateOfficePagePath = '/chLocateOffice';

const ChChatPath = '/chChat';
const ChChatListPath = '/chChatList';

//チャット画面を表示
void gotoChChatPage(BuildContext context){
  Navigator.pushNamed(context, ChChatPath);
}

void gotoChChatListPage(BuildContext context){
  Navigator.pushNamed(context, ChChatListPath);
}

// gotoSettingPageは、各種設定ページを表示します。
void gotoChSettingPage(BuildContext context) {
  Navigator.pushNamed(context, ChSettingPath);
}

// gotoUnEditProfilePageは、設定ページを表示します。
void gotoChEditProfilePage(BuildContext context) {
  Navigator.pushNamed(context, ChEditProfilePath);
}

void gotoChSelectBranchPage(BuildContext context) {
  Navigator.pushNamed(context, ChSelectBranchPath);
}

void gotoChSelectPolePage(BuildContext context) {
  Navigator.pushNamed(context, ChSelectPolePath);
}

void gotoChShowPolePage(BuildContext context) {
  Navigator.pushNamed(context, ChShowPolePath);
}

void gotoChLocateOfficePage(BuildContext context) {
  Navigator.pushNamed(context, ChLocateOfficePagePath);
}

//中部事象管理
const ChEventSelectPath = '/chEventSelect';
const ChEventAddPath = '/chEventAdd';
const ChEventPolePath = '/chEventPole';
const ChEventListPath = '/chEventList';
const ChEventListWorkPath = '/chEventListWork';
const ChEventDetailPath = '/chEventDetail';
const ChEventDetailWorkPath = '/chEventDetailWork';
const ChEventUpdatePath = '/chEventUpdate';
const ChEventSettingPath = '/chEventSetting';

void gotoChEventSelectPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventSelectPath);
}

void gotoChEventAddPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventAddPath);
}

void gotoChEventListPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventListPath);
}

void gotoChEventListWorkPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventListWorkPath);
}

void gotoChEventDetailPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventDetailPath);
}

void gotoChEventDetailWorkPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventDetailWorkPath);
}

void gotoChEventUpdatePage(BuildContext context) {
  Navigator.pushNamed(context, ChEventUpdatePath);
}

void gotoChEventSettingPage(BuildContext context) {
  Navigator.pushNamed(context, ChEventSettingPath);
}

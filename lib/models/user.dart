// ユーザモデル
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polesearcherapp/models/company.dart';

class LoginUser {
  // 空コンストラクタ
  LoginUser();

  // User.fromFirebaseUser は与えられた Firebase User インスタンスからユーザを作成するコンストラクタです。
  LoginUser.fromFirebaseUser(User u)
      : name = u.displayName,
        email = u.email,
        uid = u.uid,
        belongTo = CompanyNumber[Abbrev2CompanyID[u.uid.substring(0, 3)]],
        validated = u.emailVerified;

  String name;
  String email;
  String uid;
  int belongTo; //どこの電力会社に属するか hk=0,th=1...
  bool validated;

  @override
  String toString() => '$uid $name $email $validated';

  // 所属電力会社IDを返す
  PowerCompanyIDs getPowerCompanyID() {

    if (uid == null || uid.isEmpty) {
      return null;
    }

    final id = uid.substring(0, 3); // 前2文字が電力会社ID
    //idが電力会社のキーとして存在しない場合
    if (!Abbrev2CompanyID.containsKey(id)) {
      return null;
    }
    //先頭3文字を渡すとPowerCompanyIDs.xxxxを返す
    return Abbrev2CompanyID[id];
  }

  // 所属電力会社を返す
  String getPowerCompany() {
    if (uid == null || uid.isEmpty) {
      return '';
    }
    final id = getPowerCompanyID();
    if (id == null) {
      return '';
    }
    return PowerCompanies[id];
  }
}
//北陸ユーザデータ
class UserDataHokuriku{
  UserDataHokuriku()
      : area = '',
        locationEnable = true;

  UserDataHokuriku.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        area = ds.data()['area'] as String,
        locationEnable = ds.data()['upload_location_enable'] as bool;

  String name;
  String area = '';
  double latitude; // 緯度
  double longitude; // 経度
  bool locationEnable;
  String leaduid;
}

Future<UserDataHokuriku> getUserDataHokuriku(LoginUser user) async {

  final ds = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (ds == null || ds.data == null
      || ds.data()['area'] == null
      || ds.data()['name'] == null || ds.data()['upload_location_enable'] == null) {
        throw ArgumentError('情報の取得に失敗しました');
      }
  return UserDataHokuriku.fromDocument(ds);
}
//FireStoreのusersにデータをアップ
void setUserDataHokuriku(LoginUser user, UserDataHokuriku userDatahokuriku) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(<String, dynamic>{
        'area': userDatahokuriku.area,
        'upload_location_enable': userDatahokuriku.locationEnable,
        'name': user.email,
        'leaduid':user.uid.substring(0,3),
      }, SetOptions(merge: true));
}

void setUserLocation(LoginUser user, double latitude, double longitude){

  GeoPoint geoPoint;
  if (latitude != null && longitude != null) {
    geoPoint = GeoPoint(latitude, longitude);
  }

  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(<String, dynamic>{
        'updated_at': DateTime.now(),
        'location': geoPoint,
      }, SetOptions(merge: true));
}

//中国ユーザデータ
class UserDataChugoku{
  UserDataChugoku()
      : company = '',
        office = '',
        locationEnable = true;

  UserDataChugoku.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        company = ds.data()['company'] as String,
        office = ds.data()['office'] as String,
        locationEnable = ds.data()['upload_location_enable'] as bool;

  String name;
  String leaduid;
  String company = '';
  String office = '';
  double latitude; // 緯度
  double longitude; // 経度
  bool locationEnable;
}

Future<UserDataChugoku> getUserDataChugoku(LoginUser user) async {

  final ds = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (ds == null || ds.data == null
      || ds.data()['company'] == null || ds.data()['office'] == null
      || ds.data()['name'] == null || ds.data()['upload_location_enable'] == null) {
    throw ArgumentError('情報の取得に失敗しました');
  }
  return UserDataChugoku.fromDocument(ds);
}

void setUserDataChugoku(LoginUser user, UserDataChugoku userData) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(<String, dynamic>{
    'company': userData.company,
    'office': userData.office,
    'upload_location_enable': userData.locationEnable,
    'name': user.email,
    'leaduid':user.uid.substring(0,3),
  }, SetOptions(merge: true));
}

//中部ユーザーデータ
class UserDataChuden{
  UserDataChuden()
      : branch = '',
        office = '',
        locationEnable = true;

  UserDataChuden.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        branch = ds.data()['branch'] as String,
        office = ds.data()['office'] as String,
        locationEnable = ds.data()['upload_location_enable'] as bool;

  String name;
  String leaduid;
  String branch = '';
  String office = '';
  double latitude; // 緯度
  double longitude; // 経度
  bool locationEnable;
}

Future<UserDataChuden> getUserDataChuden(LoginUser user) async {

  final ds = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (ds == null || ds.data == null
      || ds.data()['branch'] == null || ds.data()['office'] == null
      || ds.data()['name'] == null || ds.data()['upload_location_enable'] == null) {
    throw ArgumentError('情報の取得に失敗しました');
  }
  return UserDataChuden.fromDocument(ds);
}

void setUserDataChuden(LoginUser user, UserDataChuden userData) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(<String, dynamic>{
    'branch': userData.branch,
    'office': userData.office,
    'upload_location_enable': userData.locationEnable,
    'name': user.email,
    'leaduid':user.uid.substring(0,3),
  }, SetOptions(merge: true));
}

void setUserLocationChuden(LoginUser user, double latitude, double longitude){

  GeoPoint geoPoint;
  if (latitude != null && longitude != null) {
    geoPoint = GeoPoint(latitude, longitude);
  }

  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(<String, dynamic>{
    'updated_at': DateTime.now(),
    'location': geoPoint,
  }, SetOptions(merge: true));
}
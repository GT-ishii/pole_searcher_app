// 北陸電力専用モデル
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:polesearcherapp/models/company.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:sprintf/sprintf.dart';
import 'package:polesearcherapp/models/specification.dart';

import 'package:polesearcherapp/pages/common.dart';


// 北陸電力仕様定義
const hokurikuAreaNameLength = 4; //管理区の長さ
const hokurikuPoleNameLength = 5; // 電柱名の長さ


// 北陸電力電柱情報
class Hokuriku {
  // 空インスタンス生成
  //Hokuriku() : area = HokurikuArea();
  Rikuden rikuden;
  HokurikuArea area; // 管理区
  HokurikuPole pole; // 電柱

  @override
  String toString() =>
      '${pole.toString()} belongs to ${area.name}';
}

// 電柱
class HokurikuPole {
  HokurikuPole.fromDocument(HokurikuArea area, DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        geoHash = ds.data()['geo_hash_8'] as String,
        address = '',
        latitude = ds.data()['located_at'].latitude as double,
        longitude = ds.data()['located_at'].longitude as double,
        display_order = ds.data()['display_order'] as int,
        scrollkey = ds.data()['scrollkey'] as String;


  String name; // 電柱名
  String address;
  String geoHash; // ジオハッシュ
  double latitude; // 緯度
  double longitude; // 経度
  int display_order;
  String scrollkey;


  @override
  String toString() => '$name: [$latitude,$longitude]($geoHash)';
}

// 管理区
class HokurikuArea {
  // 空インスタンス生成
  HokurikuArea()
      : rikuden = null,
        name = '',
        order = 0,
        latitude = null,
        longitude = null;

  // Firestore のデータベースから生成するコンストラクタ
  HokurikuArea.fromDocument(Rikuden rikuden , DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        order = ds.data()['display_order'] as int,
        latitude = ds.data()['located_at'] != null ? null : null,
        longitude = ds.data()['located_at'] != null ? null : null,
        rikuden = rikuden {
            characterList = <List<String>>[];

            for (var i = 0; i < hokurikuPoleNameLength; i++) {
            final cls = ds.data()[sprintf('cl%d', [i + 1])].cast<String>() as List<String>;
            final sl = <String>['*'];

            cls.forEach(sl.add);
            characterList.add(sl);
            }
          }

  final Rikuden rikuden;//所属会社
  final String name; // 管理区名
  final int order; // 表示順
  final double latitude; // 緯度
  final double longitude; // 経度
  List<List<String>> characterList;//ワイルドカード
}

class  Rikuden {
  // 空インスタンス生成
  Rikuden()
      : company = null,
        ID = '';

  // Firestore のデータベースから生成するコンストラクタ
  Rikuden.fromDocument(PowerCompany company, DocumentSnapshot ds)
      : ID = ds.data()['ID'] as String,
        company = company {
        characterList = <List<String>>[];

        for (var i = 0; i < hokurikuAreaNameLength; i++) {
        final cls = ds.data()[sprintf('CharacterList%d', [i + 1])].cast<String>() as List<String>;
        final sl = <String>['*'];

        cls.forEach(sl.add);
        characterList.add(sl);
        }
      }

final PowerCompany company;
final String ID; // ID
List<List<String>> characterList;
}

class PowerCompany{
  PowerCompany()
  : companyIDs = '';

  PowerCompany.fromDocument(ds)
  :companyIDs = ds.data()[HokurikuID];

  final companyIDs;
}

Future<PowerCompany> getCompany() async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(HokurikuID)
      .get();

  if (ds == null) {
    throw ArgumentError('電力会社の取得に失敗しました');
  }

  return PowerCompany.fromDocument(ds);
}

//FireStoreから電力会社のIDに基づくデータを取得
Future<Rikuden>
getRikuden(PowerCompany company) async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(HokurikuID)
      .get();

  if (ds == null) {
    throw ArgumentError('電力会社の取得に失敗しました');
  }

  return Rikuden.fromDocument(company, ds);
}

//FireStoreから指定の管理区データを取得
Future<HokurikuArea> getArea(Rikuden hokuriku,String areaName) async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(HokurikuID)
      .collection('areas')
      .doc(areaName)
      .get();

  if (ds == null) {
    throw ArgumentError('管理区の取得に失敗しました');
  }

  return HokurikuArea.fromDocument(hokuriku, ds);
}

// getPole は、指定された支店の、指定された営業所の、指定された電柱番号の電柱を返します。
Future<HokurikuPole> getPole(HokurikuArea area, String areaName, String name) async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(HokurikuID)
      .collection('areas')
      .doc(areaName)
      .collection('poles')
      .doc(name)
      .get();

  if (ds == null || ds.data == null) {
    throw ArgumentError('電柱番号が違います');
  }
  print(ds.data()['name']);
  final pole = HokurikuPole.fromDocument(area, ds);
  pole.address = await getAddress(pole)
      .catchError((Object error){});
  return pole;
}


// getAddressは住所取得(逆ジオコーディネート)
Future<String> getAddress(HokurikuPole pole) async {
  final place = await placemarkFromCoordinates(
      pole.latitude, pole.longitude,localeIdentifier: 'jp_JP');
  var address = '';
  if (place != null && place.isNotEmpty) {
    final postCode = getAddressParts(place[0].postalCode);
    if (postCode.isNotEmpty) {
      address = '〒${place[0].postalCode}  ';
    }

    if (Platform.isIOS) {
      address +=
          getAddressParts(place[0].administrativeArea) +
              getAddressParts(place[0].locality) +
              getAddressParts(place[0].name);
    } else {
      address +=
          getAddressParts(place[0].administrativeArea) +
              getAddressParts(place[0].locality) +
              getAddressParts(place[0].subLocality) +
              getAddressParts(place[0].thoroughfare) +
              getAddressParts(place[0].subThoroughfare) +
              getAddressParts(place[0].name);
    }
  }
  print(address);
  return address;
}

// getBranches は、管理区一覧取得(表示順に並び換えて返す)
Future<List<HokurikuArea>> getAreas(Rikuden rikuden) async {
  final qs =
  await FirebaseFirestore.instance
      .collection('company')
      .doc(HokurikuID)
      .collection('areas')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('管理区一覧の取得に失敗しました');
  }

  // 管理区一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <HokurikuArea>[];

  ds.sort((a, b) =>
  a.data()['display_order'].compareTo(b.data()['display_order']) as int);
  for (final d in ds){
    ret.add(HokurikuArea.fromDocument(rikuden, d));
  }
  return ret;
}

Future<List<HokurikuPole>> getPoles(HokurikuArea area, String areaName) async {
  final qs = await FirebaseFirestore.instance
      .collection('company')
      .doc(HokurikuID)
      .collection('areas')
      .doc(areaName)
      .collection('poles')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('電柱を取得できませんでした');
  }
  // 電柱一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <HokurikuPole>[];

  for (final pole in ds) {
    ret.add(HokurikuPole.fromDocument(area, pole));
  }
  return ret;
}
// 中国電力専用モデル
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:polesearcherapp/models/specification.dart';

import 'package:polesearcherapp/pages/common.dart';

// 中国電力電柱情報
class Chugoku {
  ChugokuOffice office; // 所属ネットワークセンター
  ChugokuLine line;   // 線路
  ChugokuPole pole; // 電柱

  // 空インスタンス生成
  //Chugoku() : this.line = ChugokuLine();
}

// 電柱
class ChugokuPole {
  ChugokuPole.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        filterstring = ds.data()['filterstring'] as String,
        geoHash = ds.data()['geo_hash_8'] as String,
        address = '',
        latitude = ds.data()['located_at'].latitude as double,
        longitude = ds.data()['located_at'].longitude as double,
        order = ds.data()['display_order'] as int;


  String name; // 電柱名
  String filterstring; // 絞り込み文字列
  String address; // 電柱住所
  String geoHash; // ジオハッシュ
  double latitude; // 緯度
  double longitude; // 経度
  int order; // 表示順

  @override
  String toString() => '$name: [$latitude,$longitude]($geoHash)';
}

// 線路
class ChugokuLine {
  // Firestore のデータベースから生成するコンストラクタ
  ChugokuLine.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        filterstring = ds.data()['filterstring'] as String,
        order = ds.data()['display_order'] as int;

  final String name; // 線路名
  final String filterstring; // 絞り込み文字列
  final int order; // 表示順
}

// ネットワークセンター
class ChugokuOffice {
  // 空インスタンス生成
  ChugokuOffice()
      : name = '',
        order = 0,
        latitude = null,
        longitude = null;

  // Firestore のデータベースから生成するコンストラクタ
  ChugokuOffice.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        order = ds.data()['display_order'] as int,
        latitude = ds.data()['located_at'] != null ? ds.data()['located_at'].latitude as double : null,
        longitude = ds.data()['located_at'] != null ? ds.data()['located_at'].longitude as double : null;

  final String name; // ネットワークセンター名
  final int order; // 表示順
  final double latitude; // 緯度
  final double longitude; // 経度
}

// 電力会社
class ChugokuCompany {
  // 空インスタンス生成
  //ChugokuCompany()
     // : company = '';

  ChugokuCompany.fromDocument(DocumentSnapshot ds)
      : company = ds.data()['company'] as String;

  final String company; // 電力会社名
}

// getPole は、指定されたネットワークセンターの、指定された電柱番号の電柱を返します。
Future<ChugokuPole> getPole(String office, String line, String name) async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(ChugokuID)
      .collection('offices')
      .doc(office)
      .collection('lines')
      .doc(line)
      .collection('poles')
      .doc(name)
      .get();

  if (ds == null || ds.data == null) {
    throw ArgumentError('電柱番号が違います');
  }
  final pole = ChugokuPole.fromDocument(ds);
  pole.address = await getAddress(pole)
      .catchError((Object error){});
  return pole;
}

// getAddressは住所取得(逆ジオコーディネート)
Future<String> getAddress(ChugokuPole pole) async {
  final place = await placemarkFromCoordinates(
      pole.latitude, pole.longitude,localeIdentifier:'jp_JP');
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
  return address;
}

// getOffices は、ネットワークセンター一覧取得(表示順に並び換えて返す)
Future<List<ChugokuOffice>> getOffices() async {
  final qs = await FirebaseFirestore.instance
      .collection('company')
      .doc(ChugokuID)
      .collection('offices')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('ネットワークセンター一覧の取得に失敗しました');
  }

  // ネットワークセンター一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <ChugokuOffice>[];

  ds.sort((a, b) =>
  a.data()['display_order'].compareTo(b.data()['display_order']) as int);
  for (final office in ds) {
    ret.add(ChugokuOffice.fromDocument(office));
  }
  return ret;
}

// getCompany は、指定された電力会社名のIDを返します。
Future<ChugokuCompany> getCompany() async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(ChugokuID)
      .get();

  if (ds == null) {
    throw ArgumentError('電力会社の取得に失敗しました');
  }
  return ChugokuCompany.fromDocument(ds);
}

// getOfficeは指定されたネットワークセンターの名前を返します。
Future<ChugokuOffice> getOffice(String officeName) async {
  final ds = await FirebaseFirestore.instance
      .collection('company')
      .doc(ChugokuID)
      .collection('offices')
      .doc(officeName)
      .get();

  if (ds == null) {
    throw ArgumentError('ネットワークセンターの取得に失敗しました');
  }
  return ChugokuOffice.fromDocument(ds);
}

// getLines は、線路一覧を取得し、表示順に並べ替えたリストを返します。
Future<List<ChugokuLine>> getLines(String office) async {
  final qs = await FirebaseFirestore.instance
      .collection('company')
      .doc(ChugokuID)
      .collection('offices')
      .doc(office)
      .collection('lines')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('線路の取得に失敗しました');
  }

  // 線路一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <ChugokuLine>[];

  ds.sort((a, b) =>
  a.data()['display_order'].compareTo(b.data()['display_order']) as int);
  for (final line in ds) {
    ret.add(ChugokuLine.fromDocument(line));
  }
  return ret;
}

// getPoles は、電柱一覧を取得し、表示順に並べ替えたリストを返します。
Future<List<ChugokuPole>> getPoles(String office, String line) async {
  final qs = await FirebaseFirestore.instance
      .collection('company')
      .doc(ChugokuID)
      .collection('offices')
      .doc(office)
      .collection('lines')
      .doc(line)
      .collection('poles')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('電柱を取得できません');
  }

  // 電柱一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <ChugokuPole>[];

  ds.sort((a, b) =>
  a.data()['display_order'].compareTo(b.data()['display_order']) as int);
  for (final pole in ds) {
    ret.add(ChugokuPole.fromDocument(pole));
  }
  return ret;
}
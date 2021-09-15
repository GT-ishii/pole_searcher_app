// 中部電力専用モデル
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sprintf/sprintf.dart';

import 'package:polesearcherapp/pages/common.dart';

// 中部電力仕様定義
const chugokuPoleNameLength = 6; // 電柱名の長さ

// 中部電力電柱情報
class Chugoku {
  // 空インスタンス生成
  Chugoku() : office = ChugokuOffice();

  ChugokuOffice office; // 所属営業所
  ChugokuPole pole; // 電柱

  @override
  String toString() =>
      '${pole.toString()} belongs to ${office.branch}${office.name}';
}

// 電柱
class ChugokuPole {
  ChugokuPole.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        geoHash = ds.data()['geo_hash_8'] as String,
        address = '',
        latitude = ds.data()['located_at'].latitude as double,
        longitude = ds.data()['located_at'].longitude as double;

  String name; // 電柱名
  String address; // 電柱住所
  String geoHash; // ジオハッシュ
  double latitude; // 緯度
  double longitude; // 経度

  @override
  String toString() => '$name: [$latitude,$longitude]($geoHash)';
}

// 営業所
class ChugokuOffice {
  // 空インスタンス生成
  ChugokuOffice()
      : branch = null,
        name = '',
        order = 0,
        latitude = null,
        longitude = null;

  // Firestore のデータベースから生成するコンストラクタ
  ChugokuOffice.fromDocument(ChugokuBranch branch, DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        order = ds.data()['display_order'] as int,
        latitude = ds.data()['located_at'] != null ? null : null,
        longitude = ds.data()['located_at'] != null ? null : null,
        branch = branch {
    characterList = <List<String>>[];

    for (var i = 0; i < chugokuPoleNameLength; i++) {
      final cls = ds.data()[sprintf('cl%d', [i + 1])].cast<String>() as List<String>;
      final sl = <String>['*'];

      cls.forEach(sl.add);
      characterList.add(sl);
    }
  }

  final ChugokuBranch branch; // 所属支店
  final String name;
  final int order;
  final double latitude; // 緯度
  final double longitude; // 経度
  List<List<String>> characterList;
}

// 支店
class ChugokuBranch {
  // 空インスタンス生成
  ChugokuBranch()
      : name = '',
        order = 0;

  // Firestore のデータベースから生成するコンストラクタ
  ChugokuBranch.fromDocument(DocumentSnapshot ds)
      : name = ds.data()['name'] as String,
        order = ds.data()['display_order'] as int;

  final String name; // 支店名
  final int order; // 表示順
}

Future<ChugokuBranch> getBranche(String branchName) async {
  final ds = await FirebaseFirestore.instance
      .collection('branches')
      .doc(branchName)
      .get();

  if (ds == null) {
    throw ArgumentError('支社の取得に失敗しました');
  }

  return ChugokuBranch.fromDocument(ds);
}

Future<ChugokuOffice> getOffice(ChugokuBranch branch, String officeName) async {
  final ds = await FirebaseFirestore.instance
      .collection('branches')
      .doc(branch.name)
      .collection('offices')
      .doc(officeName)
      .get();

  if (ds == null) {
    throw ArgumentError('支社の取得に失敗しました');
  }
  return ChugokuOffice.fromDocument(branch, ds);
}

// getPole は、指定された支店の、指定された営業所の、指定された電柱番号の電柱を返します。
Future<ChugokuPole> getPole(String branch, String office, String name) async {
  final ds = await FirebaseFirestore.instance
      .collection('branches')
      .doc(branch)
      .collection('offices')
      .doc(office)
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
  return address;
}

// getBranches は、支店一覧取得(表示順に並び換えて返す)
Future<List<ChugokuBranch>> getBranches() async {
  final qs =
  await FirebaseFirestore.instance.collection('branches').get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('支店一覧の取得に失敗しました');
  }

  // 支店一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <ChugokuBranch>[];

  ds.sort((a, b) =>
  a.data()['display_order'].compareTo(b.data()['display_order']) as int);
  for (final d in ds){
    ret.add(ChugokuBranch.fromDocument(d));
  }
  return ret;
}

// getOffices は、営業所一覧を取得し、表示順に並べ替えたリストを返します。
Future<List<ChugokuOffice>> getOffices(ChugokuBranch branch) async {
  final qs = await FirebaseFirestore.instance
      .collection('branches')
      .doc(branch.name)
      .collection('offices')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('営業所一覧の取得に失敗しました');
  }

  // 営業所一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <ChugokuOffice>[];

  ds.sort((a, b) =>
  a.data()['display_order'].compareTo(b.data()['display_order']) as int);
  for (final office in ds) {
    ret.add(ChugokuOffice.fromDocument(branch, office));
  }
  return ret;
}

Future<List<ChugokuPole>> getPoles(String branch, String office) async {
  final qs = await FirebaseFirestore.instance
      .collection('branches')
      .doc(branch)
      .collection('offices')
      .doc(office)
      .collection('poles')
      .get();

  if (qs.docs.isEmpty) {
    throw ArgumentError('電柱を取得できませんでした');
  }
  // 電柱一覧を表示順に並び換え
  final ds = qs.docs;
  final ret = <ChugokuPole>[];

  for (final pole in ds) {
    ret.add(ChugokuPole.fromDocument(pole));
  }
  return ret;
}
// 電柱選択画面
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';
import 'package:polesearcherapp/pages/hokuriku/select_pole.dart';


import 'package:polesearcherapp/services/auth.dart';

class HrEventPolePage extends StatefulWidget {
  HrEventPolePage(this.auth, this.hokuriku, this.event);

  final Auth auth;
  final Hokuriku hokuriku;
  final HrEvent event;

  @override
  State<StatefulWidget> createState() => _HrEventPolePageState();
}

class _HrEventPolePageState extends State<HrEventPolePage> {
  final _formKey = GlobalKey<FormState>();
  LoginUser _user = LoginUser();

  String _areaName;
  String _poleName;
  List<int> _selectedArea = [1, 1, 1, 1];
  List<int> _currentSelectedArea = [1, 1, 1, 1];

  List<int> _selectedPole = [1, 1, 1, 1, 1];
  List<int> _currentSelectedPole = [1, 1, 1, 1, 1];

  List<HokurikuArea>  _areas;
  List<HokurikuPole>  _poles;
  List<String> _areaNames;
  List<String> _poleNames;

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToHr, HrNavigationMenuItem.search.index, HrSelectPolePath);

    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));

    if (widget.hokuriku.rikuden != null) {
      _areaName = widget.hokuriku.area.name;
      // 管理区名称 → 選択ドラムインデックスのリスト
      var i = 0;
      for (final r in widget.hokuriku.area.name.runes.toList()){
        var j = 0;
        for (final c in widget.hokuriku.rikuden.characterList[i]){

          if (c.runes.first == r) {
            _currentSelectedArea[i] = j;
            _selectedArea[i] = j;
          }
          j++;
        }
        i++;
      }
    }
    else{
      getUserinfo(_user);
    }
    // 電柱の名前を初期化
    if (widget.hokuriku.pole != null) {
      _poleName = widget.hokuriku.pole.name;

      // 電柱番号 → 選択ドラムインデックスのリスト
      var i = 0;
      for (final r in _poleName.runes.toList()){
        var j = 0;
        for (final c in widget.hokuriku.area.characterList[i]){

          if (c.runes.first == r) {
            _currentSelectedPole[i] = j;
            _selectedPole[i] = j;
          }
          j++;
        }
        i++;
      }
    }else{
      _areaName = null;
      _poleName = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });

    //管理区取得
    getAreas(widget.hokuriku.rikuden).then((areas){
      _setupAreas(areas);

      if(widget.hokuriku.pole != null){
        //電柱取得
        getPoles(widget.hokuriku.area, widget.hokuriku.area.name).then((poles){
          _setupPoles(poles);
        }).catchError((Object error) {
          showError(error, context);
        });
      }
      Navigator.pop(context);
    }).catchError((Object error) {
      showError(error, context);
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('電柱検索（事象）'),
          centerTitle: true,
          actions: [
            showLogoutButton(context, widget.auth, _user)
          ],
        ),
        body: SingleChildScrollView(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    addPadding(2),

                    _showAreaListButton(),

                    addPadding(3),

                    _showPoleListButton(),

                    addPadding(3),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        showSubmit(_formKey, '決定', const Size(220,50), 20, Colors.indigo, (_canSubmit()) ? _poleSubmit : null),
                        addPadding(2),
                        showSubmit(_formKey, '事象', const Size(160,50), 20, Colors.indigo, null),
                      ],
                    ),
                    addPadding(4),
                  ]),
            )),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.event.index, belongToHr, widget.hokuriku),
      ),
    );
  }

  Widget _showAreaListButton() {
    VoidCallback callback = (){};

    callback = () async {
      _selectedArea = List.from(_currentSelectedArea);
      // ボタンを押されたらピッカを表示する。
      showAreaPicker(
          context, widget.hokuriku.rikuden.characterList,
          _selectedArea, _selectArea);
    };

    return showSubmitBox(_formKey, _areaName ?? '管理区を選択してください',
        const Size(400, 50), 22, _areaName != null ? Colors.black : Colors.grey, callback);
  }

  Widget _showPoleListButton() {
    VoidCallback callback = (){};

    callback = () async {

      if(_areaName == null){
        showPopup('管理区を選択してください', context);
      }

      else{
        _selectedPole = List.from(_currentSelectedPole);
        // ボタンを押されたらピッカを表示する。
        showPolePicker(
            context, widget.hokuriku.area.characterList,
            _selectedPole, _selectPole);
      }
    };

    return showSubmitBox(_formKey, _poleName ?? '電柱を選択してください',
        const Size(400, 50), 22, _poleName != null ? Colors.black : Colors.grey, callback);
  }

  void _setupAreas(List<HokurikuArea> areas) {
    final names = <String>[];

    for (final area in areas) {
      names.add(area.name);
    }

    setState(() {
      _areas = areas;
      _areaNames = names;
    });
  }



  void _setupPoles(List<HokurikuPole> poles) {
    final names = <String>[];

    for (final pole in poles) {
      names.add(pole.name);
    }

    setState(() {
      _poles = poles;
      _poleNames = names;
    });
  }

  void _selectArea(Picker picker, List<int> value) {
    var a = '';
    var i = 0;
    //showProgressIndicator(context);
    for (final x in value) {
      final s = widget.hokuriku.rikuden.characterList[i++][x];
      //*を選択した場合の処理
      if(s == '*') {

        Future<void>.delayed(const Duration()).then((value){
          //管理区の一覧と表示件数をドラムで表示
          _selectAreaStartWith(a);
        });
        setState(() {
          _selectedArea = value;
          _currentSelectedArea = value;
        });
        return;
      }
      a = a.toString() + s;
    }

    setState(() {
      _areaName = a;
      _selectedArea = value;
      _currentSelectedArea = value;
    });
//管理区を選択して決定を押すと更新
    _updateArea(_areaName);
  }
//管理区の一覧と表示件数をドラムで表示
  void _selectAreaStartWith(String keyword) {
    //リスト作成
    final selectAreaNameList = <String>[];
    for (var i = 0; i < _areaNames.length; i++) {
      if (_areaNames[i].startsWith(keyword)) {
        selectAreaNameList.add(_areaNames[i]);
      }
    }

    //検索結果が空の場合
    if (selectAreaNameList.isEmpty) {
      showPopup('$keywordで始まる管理区はありませんでした', context);
      print('err');
    } else {
      print(keyword);

      showPicker(context, [selectAreaNameList], [0],
          '${selectAreaNameList.length}件の検索結果', null,
              (Picker picker, List<int> value) {
            final idx = value[0];
            for (final a in _areas) {
              if (a.name == selectAreaNameList[idx]) {
                break;
              }
            }
            setState(() {
              _areaName = selectAreaNameList[idx];
              final selectList = <int>[];
              for (var i = 0; i < _areaName.length; i++) {
                selectList.add(
                    widget.hokuriku.rikuden.characterList[i].indexWhere((
                        element) => element == _areaName[i]));
              }
              _selectedArea = selectList;
              _currentSelectedArea = selectList;

              _updateArea(_areaName);
            });
          });
    }
  }

  Future<void> _updateArea(String _areaName) async {

    showProgressIndicator(context);

    final company = await getCompany();
    final rikuden = await getRikuden(company); //FireStoreから電力会社のIDに基づくデータを取得
    final area = await getArea(rikuden, _areaName);

    setState(() {
      widget.hokuriku.area = area;
    });

    getPoles(widget.hokuriku.area, widget.hokuriku.area.name).then((poles){
      _setupPoles(poles);
      Navigator.pop(context);
    }).catchError((Object error) {
      showError(error, context);
      Navigator.pop(context);
    });
  }

  void _selectPole(Picker picker, List<int> value) {
    var p = '';
    var i = 0;
    for (final x in value) {
      final s = widget.hokuriku.area.characterList[i++][x];
      if(s == '*') {
        Future<void>.delayed(const Duration()).then((_){
          _selectPoleStartWith(p);
        });
        setState(() {
          _selectedPole = value;
          _currentSelectedPole = value;
        });
        return;
      }
      p = p.toString() + s;
    }
    setState(() {
      _poleName = p;
      _selectedPole = value;
      _currentSelectedPole = value;
    });
  }

  void _selectPoleStartWith(String keyword) {
    //リスト作成
    final selectPoleNameList = <String>[];
    for (var i = 0; i < _poleNames.length; i++) {
      if (_poleNames[i].startsWith(keyword)) {
        selectPoleNameList.add(_poleNames[i]);
      }
    }

    //検索結果が空の場合
    if (selectPoleNameList.isEmpty) {
      showPopup('$keywordで始まる電柱はありませんでした', context);
      print('err');
    } else {
      print(keyword);
      showPicker(context, [selectPoleNameList], [0], '${selectPoleNameList.length}件の検索結果', null,
              (Picker picker, List<int> value) {
                final idx = value[0];
                for (final p in _poles) {
                  if (p.name == selectPoleNameList[idx]) {
                    break;
                  }
                }
                setState(() {
                  _poleName = selectPoleNameList[idx];
                  final selectList = <int>[];
                  for(var i = 0; i < _poleName.length; i++){
                    selectList.add(
                        widget.hokuriku.area.characterList[i].indexWhere((element) => element == _poleName[i]));
                  }
                  _selectedPole = selectList;
                  _currentSelectedPole = selectList;
                });
              });
    }
  }

  void _poleSubmit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);

    getArea(widget.hokuriku.rikuden, _areaName)
        .then((area){
      getPole(widget.hokuriku.area, widget.hokuriku.area.name, _poleName)
          .then((pole) {

        // プログレスインジケータ消去
        Navigator.pop(context);

        final eventPole = <String, dynamic>{
          'area':_areaName,
          'pole': pole.name,
          'located_at' : GeoPoint(pole.latitude, pole.longitude)
        };
        Navigator.pop(context, eventPole);

      }).catchError((Object error) {
        // プログレスインジケータ消去
        Navigator.pop(context);

        showPopup(error.toString(), context);
      });

    }).catchError((Object error) {
      // プログレスインジケータ消去
      Navigator.pop(context);

      showPopup(error.toString(), context);
    });
  }

  // _canSubmit は、決定ボタンが押せる状態かどうかを返します。
  // 決定ボタンが押せる状態とは、電柱選択が完了している状態です。
  bool _canSubmit()
  {
    return _poleName != null;
  }

  Future<String> getUserinfo(LoginUser user) async {
    UserDataHokuriku data;

    await getUserDataHokuriku(user).then((u){
      data = u;
    }).catchError((Object error){
      data = UserDataHokuriku()
        ..area = '０１６２';
    });

    try {
      final company = await getCompany();
      final rikuden = await getRikuden(company); //FireStoreから電力会社のIDに基づくデータを取得
      final area = await getArea(rikuden, data.area);

      setState(() {
        widget.hokuriku.rikuden = rikuden;
        widget.hokuriku.area = area;
      });
    } on Exception catch (error) {
      showError(error, context);
    }
    return widget.hokuriku.area.name;
  }

}


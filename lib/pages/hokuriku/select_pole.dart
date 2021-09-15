// 電柱選択画面
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/services.dart';
//import 'package:polesearcherapp/models/company.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

import 'package:toggle_switch/toggle_switch.dart';

class HrSelectPolePage extends StatefulWidget {
  HrSelectPolePage(this.auth, this.hokuriku, this.event);

  final Auth auth;
  final Hokuriku hokuriku;
  final HrEvent event;

  @override
  _HrSelectPolePageState createState() => _HrSelectPolePageState();
}

class _HrSelectPolePageState extends State<HrSelectPolePage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _poleController = TextEditingController();

  String _areaName;
  String _poleName;
  String _inputMethod = 'キーボード';
  int initialIndex = 0;
  List<int> _selectedArea = [1, 1, 1, 1];
  List<int> _currentSelectedArea = [1, 1, 1, 1];
  List<String> _input = ['キーボード', 'ドラム'];
  HokurikuArea _currentArea;
  List<int> _areaSelected = [0];
  List<int> _oldAreaSelected = [0];
  HokurikuPole _currentPole;
  List<int> _poleSelected = [0];
  List<int> _oldPoleSelected = [0];
  List<int> _selectedPole = [1, 1, 1, 1, 1];
  List<int> _currentSelectedPole = [1, 1, 1, 1, 1];

  List<HokurikuArea>  _areas;
  List<HokurikuPole>  _poles;
  List<String> _areaNames;
  List<String> _poleNames;

  LoginUser _user = LoginUser();

  @override
  void initState(){
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
      print('_poleName');
      print(_poleName);
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
        setState(() {
          _areaController.text = widget.hokuriku.area.name;
          _poleController.text = widget.hokuriku.pole.name;
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
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('電柱検索'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            showLogoutButton(context, widget.auth, _user)
          ],
        ),
        body: GestureDetector(
          child: SingleChildScrollView(
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      addPadding(2),

                      (_keyordrum()) ?
                      showAreaSearchButton(
                          TextInputType.numberWithOptions(signed: true, decimal: true),
                          '管理区を選択してください',
                          checkValidatePole, _updateAreaPicker,
                          _showAreaPicker)
                          :_showAreaListButton(),

                      addPadding(3),

                      (_keyordrum()) ?
                      showPoleSearchButton(
                          TextInputType.numberWithOptions(signed: true, decimal: true),
                          '電柱を選択してください',
                          checkValidatePole, _updatePolePicker,
                          _showPolePicker)
                          :_showPoleListButton(),

                      addPadding(3),


                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          showSubmit(_formKey, '決定', const Size(220,50), 20, Colors.indigo, (_canSubmit()) ? _poleSubmit : null),
                          addPadding(2),
                          showSubmit(_formKey, '事象', const Size(160,50), 20, Colors.indigo, (_canSubmit()) ? _eventSubmit : null),
                        ],
                      ),
                      addPadding(4),
                      ToggleSwitch(
                        minWidth: 130.0,
                        cornerRadius: 20.0,
                        activeBgColors: [[Colors.indigo], [Colors.indigo]],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        initialLabelIndex: initialIndex,
                        totalSwitches: 2,
                        labels: ['キーボード', 'ドラム'],
                        radiusStyle: false,
                        onToggle: (index) {
                          setState(() {
                            initialIndex = index;
                            _inputMethod = _input[index];
                          });
                          print('switched to: $index');
                        },
                      ),
                    ]),
              )),
          behavior: HitTestBehavior.opaque,
          onTap: (){
            FocusScope.of(context).unfocus();
          },),
        bottomNavigationBar: hrBottomNavigationBar(context, widget.auth, HrNavigationMenuItem.search.index, belongToHr, widget.hokuriku),
      ),
    );
  }

  bool _keyordrum () {
    if (_inputMethod == 'キーボード') {
      return true;
    }
    return false;
  }

  void setDrum() {
    setState(() {
      _inputMethod = _input[1];
    });
  }

  void setKeyboard() {
    setState(() {
      _inputMethod = _input[0];
    });
  }

  // _convertStringはひらがなを半角のカタカナに変換します。
  String _convertString(String key) {

    key = key.replaceAllMapped(new RegExp("[ぁ-ゔ]"), (Match m) => String.fromCharCode(m.group(0).codeUnitAt(0) + 0x60));
    for (int i = 0; i < omoji.length; i++) {
      key = key.replaceAll(komoji[i], omoji[i]);
    }
    return key;
  }

  void _updateAreaPicker(String key){
    final list = <String>[];
    key = key.toUpperCase();
    key = _convertString(key);
    for (final a in _areas) {
      /*if (p.name.startsWith(key)) { //前方一致*/
      if (a.name.contains(key)) { //部分一致
        list.add(a.name);
      }
    }
    setState(() {
      _areaNames = list;
      _areaName = null;
    });
  }

  // _updatePoles は電柱一覧受信時の処理です。
  void _updatePoles(List<HokurikuPole> poles) {
    final names = <String>[];

    for (final pole in poles) {
      names.add(pole.name);
    }

    setState(() {
      _poleName = null;
      _poles = poles;
      _poleNames = names;

      _poleSelected = [0];
      _oldPoleSelected = _poleSelected;
    });
  }

  void _updatePolePicker(String key){
    final list = <String>[];
    //key = key.toUpperCase();
    key = _convertString(key);
    for (final p in _poles) {
      print('_poles');
      print(_poles);
      /*if (p.name.startsWith(key)) { //前方一致*/
      if (p.name.contains(key)) { //部分一致
        list.add(p.name);
      }
    }
    setState(() {
      _poleNames = list;
      _poleName = null;
    });
  }

  void _showPolePicker(){
    _poleSelected = List.from(_oldPoleSelected);
    showPicker(context, [_poleNames], _poleSelected, '${_poleNames.length}件の表示', null,
            (Picker picker, List<int> value) {
          // 選択時のコールバック処理
          HokurikuPole selected;
          final idx = value[0];
          for (final p in _poles) {
            if (p.name == _poleNames[idx]) {
              selected = p;
              break;
            }
          }
          final poleIndex = [idx];

          // 見つけた線路を _currentLine にセットして再描画
          setState(() {
            _currentPole = selected;
            _poleName = _poleNames[idx];
            _poleController.text = _poleName;
            _poleSelected = poleIndex;
            _oldPoleSelected = _poleSelected;
          });
        });
  }

  void _showAreaPicker(){
    _areaSelected = List.from(_oldAreaSelected);
    showPicker(context, [_areaNames], _areaSelected, '${_areaNames.length}件の表示', null,
            (Picker picker, List<int> value) {
          // 選択時のコールバック処理
          HokurikuArea selected;
          final idx = value[0];
          for (final a in _areas) {
            if (a.name == _areaNames[idx]) {
              selected = a;
              break;
            }
          }
          final areaIndex = [idx];

          // 見つけた線路を _currentArea にセットして再描画
          setState(() {
            _currentArea = selected;
            _areaName = _areaNames[idx];
            _areaController.text = _areaName;
            _areaSelected = areaIndex;
            _oldAreaSelected = _areaSelected;
          });
          _updateArea(_areaName);
        });
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
      _currentArea = _areas[0];

      if (widget.hokuriku.area != null) {
        _areaName = widget.hokuriku.area.name;
        _currentArea = widget.hokuriku.area;
        _areaSelected = [_areaNames.indexOf(_areaName)];
        _oldAreaSelected = [_areaNames.indexOf(_areaName)];
      }
    });
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
      _updatePoles(poles);
      Navigator.pop(context);
    }).catchError((Object error) {
      showError(error, context);
      Navigator.pop(context);
    });
  }

  void _setupPoles(List<HokurikuPole> poles) {
    final names = <String>[];

    for (final pole in poles) {
      names.add(pole.name);
    }

    setState(() {
      _poleName =widget.hokuriku.pole.name;
      _poles = poles;
      _poleNames = names;

      _currentPole = widget.hokuriku.pole;
      _poleSelected = [_poleNames.indexOf(_poleName)];
      _oldPoleSelected = [_poleNames.indexOf(_poleName)];
    });
  }

  void _selectArea(Picker picker, List<int> value) {
    var a = '';
    var i = 0;
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
              //絞り込みリストの決定ボタン押下で更新
              _updateArea(_areaName);
            });
          });
    }
  }

  void _selectPole(Picker picker, List<int> value) {
    var p = '';
    var i = 0;

    for (final x in value) {
      final s = widget.hokuriku.area.characterList[i++][x];
      if(s == '*') {

        Future<void>.delayed(const Duration()).then((value){
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
  // _eventSubmit は決定ボタン押下時のコールバックです。
  // 選択された電柱をセットして電柱詳細画面に遷移します。
  void _poleSubmit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);
    getPole(widget.hokuriku.area, widget.hokuriku.area.name, _poleName)
        .then((pole) {
      widget.hokuriku.pole = pole;
      // プログレスインジケータ消去
      Navigator.pop(context);
      //電柱詳細画面を表示
      gotoHrShowPolePage(context);
    }).catchError((Object error) {
      // プログレスインジケータ消去
      Navigator.pop(context);
      showPopup(error.toString(), context);
    });
  }

  // _eventSubmit は事象ボタン押下時のコールバックです。
  // 選択された電柱をセットして事象登録画面に遷移します。
  void _eventSubmit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);

    getPole(widget.hokuriku.area, widget.hokuriku.area.name, _poleName)
        .then((pole) {
      widget.hokuriku.pole = pole;
      widget.event.data.poleSearch = true;

      Navigator.pop(context);
      setBeforePage(belongToHr, HrNavigationMenuItem.event.index, HrEventAddPath);
      gotoHrEventAddPage(context);
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
  // showPoleSearch は、電柱検索入力ウィジェットを表示します。
  Widget showAreaSearchButton(TextInputType type, String hint,
      FormFieldValidator<String> validator, ValueChanged<String> onChanged, dynamic onEditingComplete) {
    return SizedBox(
      width: 400,
      height: 50,
      child: TextFormField(
        controller: _areaController,
        maxLines: 1,
        keyboardType: type,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofocus: false,
        style: const TextStyle(
          fontSize: 22,
        ),

        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(5),
          filled: true,
          hintText: hint,
          border: const OutlineInputBorder(
              borderSide: BorderSide()

          ),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _areaController.clear();
                _poleController.clear();
                setState(() {
                  _areaName = null;
                  _areaSelected = [0];
                  _oldAreaSelected = [0];

                  _poleName = null;
                  _poles = null;
                  _poleNames = null;

                  _currentPole = null;
                  _poleSelected = [0];
                  _oldPoleSelected = [0];
                });
              }),
        ),
        validator: (value) => validator(value.trim()),
        onChanged: (value) => onChanged(value.trim()),
        onEditingComplete: () => onEditingComplete(),
      ),
    );
  }

  // showPoleSearch は、電柱検索入力ウィジェットを表示します。
  Widget showPoleSearchButton(TextInputType type, String hint,
      FormFieldValidator<String> validator, ValueChanged<String> onChanged, dynamic onEditingComplete) {
    return SizedBox(
      width: 400,
      height: 50,
      child: TextFormField(
        controller: _poleController,
        maxLines: 1,
        keyboardType: type,
        autofocus: false,
        style: const TextStyle(
          fontSize: 22,
        ),

        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(5),
          filled: true,
          hintText: hint,
          border: const OutlineInputBorder(
              borderSide: BorderSide()

          ),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _poleController.clear();
                setState(() {
                  _poleName = null;
                  _poleSelected = [0];
                  _oldPoleSelected = [0];
                });
              }),
        ),
        validator: (value) => validator(value.trim()),
        onChanged: (value) => onChanged(value.trim()),
        onEditingComplete: () => onEditingComplete(),
      ),
    );
  }


}

// 電柱選択画面
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chuden/chuden.dart';
import 'package:polesearcherapp/models/chuden/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

import 'package:toggle_switch/toggle_switch.dart';

class ChEventPolePage extends StatefulWidget {
  ChEventPolePage(this.auth, this.chuden, this.event);

  final Auth auth;
  final Chuden chuden;
  final ChEvent event;

  @override
  State<StatefulWidget> createState() => _ChEventPolePageState();
}

class _ChEventPolePageState extends State<ChEventPolePage> {
  final _formKey = GlobalKey<FormState>();
  LoginUser _user = LoginUser();

  String _poleName;
  String _inputMethod = 'キーボード';
  int initialIndex = 0;
  List<int> _selected = [1, 1, 1, 1, 1, 1];
  List<int> _currentSelected = [1, 1, 1, 1, 1, 1];
  List<String> _input = ['キーボード', 'ドラム'];
  List<int> _inputSelected = [0];
  List<int> _poleSelected = [0];
  List<int> _oldPoleSelected = [0];
  ChudenPole _currentPole;
  final _poleController = TextEditingController();

  List<ChudenPole> _poles;
  List<String> _poleNames;

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCh, ChNavigationMenuItem.search.index, ChSelectPolePath);

    if (widget.event.data != null && widget.event.data.eventPole != null) {
      _poleName = widget.event.data.eventPole['pole'] as String;
      // 電柱番号 → 選択ドラムインデックスのリスト
      var i = 0;
      for (final r in _poleName.runes.toList()){
        var j = 0;
        for (final c in widget.chuden.office.characterList[i]){

          if (c.runes.first == r) {
            _currentSelected[i] = j;
            _selected[i] = j;
          }
          j++;
        }
        i++;
      }
    }
    widget.auth.getUser()
        .then((user) => setState(() {
      _user = user;
    })).catchError((Object error) => showError(error, context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });

    getPoles(widget.chuden.office.branch.name, widget.chuden.office.name).then((poles){
      _setupPoles(poles);
      Navigator.pop(context);
    }).catchError((Object error) {
      Navigator.pop(context);
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
                    showTextCustom('${widget.chuden.office.branch.name} ${widget.chuden.office.name}', 22, Colors.black, null, 1),
                    addPadding(1),
                    (_keyordrum()) ?
                    showPoleSearchButton(
                        TextInputType.text,
                        '電柱を選択してください',
                        checkValidatePole, _updatePolePicker,
                        _showPolePicker)
                        : showSubmitBox(_formKey, _poleName ?? '電柱を選択してください', const Size(400,50), 22,
                        _poleName != null ? Colors.black : Colors.grey, () {
                          _selected = List.from(_currentSelected);
                          showPolePicker(context, widget.chuden.office.characterList, _selected, _selectPole);
                        }),
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
        bottomNavigationBar: chBottomNavigationBar(context, widget.auth, ChNavigationMenuItem.event.index, belongToCh, widget.chuden),
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

  void _setupPoles(List<ChudenPole> poles) {
    final names = <String>[];

    for (final pole in poles) {
      names.add(pole.name);
    }

    setState(() {
      _poles = poles;
      _poleNames = names;
    });
  }
  // _convertStringはひらがなを半角のカタカナに変換します。
  String _convertString(String key) {

    key = key.replaceAllMapped(new RegExp("[ぁ-ゔ]"), (Match m) => String.fromCharCode(m.group(0).codeUnitAt(0) + 0x60));
    for (int i = 0; i < omoji.length; i++) {
      key = key.replaceAll(omoji[i], komoji[i]);
    }
    return key;
  }


  void _updatePolePicker(String key){
    final list = <String>[];
    key = key.toUpperCase();
    key = _convertString(key);
    for (final p in _poles) {
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
          ChudenPole selected;
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

  void _selectPole(Picker picker, List<int> value) {
    var p = '';
    var i = 0;
    for (final x in value) {
      final s = widget.chuden.office.characterList[i++][x];
      if(s == '*') {
        Future<void>.delayed(const Duration()).then((_){
          _selectPoleStartWith(p);
        });
        setState(() {
          _selected = value;
          _currentSelected = value;
        });
        return;
      }
      p = p.toString() + s;
    }
    setState(() {
      _poleName = p;
      _selected = value;
      _currentSelected = value;
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
                    widget.chuden.office.characterList[i].indexWhere((element) => element == _poleName[i]));
              }
              _selected = selectList;
              _currentSelected = selectList;
            });
          });
    }
  }

  void _poleSubmit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);

    getPole(widget.chuden.office.branch.name, widget.chuden.office.name, _poleName)
        .then((pole) {

      // プログレスインジケータ消去
      Navigator.pop(context);

      final eventPole = <String, dynamic>{
        'pole': pole.name,
        'located_at' : GeoPoint(pole.latitude, pole.longitude)
      };
      Navigator.pop(context, eventPole);

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
            fontSize: 22
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

}


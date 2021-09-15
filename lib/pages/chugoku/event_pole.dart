// 事象電柱検索画面
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chugoku/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';

class CgEventPolePage extends StatefulWidget {
  CgEventPolePage(this.auth, this.chugoku, this.event, this.userDatachugoku);

  final Auth auth;
  final Chugoku chugoku;
  final CgEvent event;
  final UserDataChugoku userDatachugoku;

  @override
  State<StatefulWidget> createState() => _EventPolePageState();
}

class _EventPolePageState extends State<CgEventPolePage> {
  final _formKey = GlobalKey<FormState>();
  final _poleController = TextEditingController();
  final _lineController = TextEditingController();
  double boxWidth;

  String _lineName;
  String _poleName;
  String bkey;

  //線路
  List<ChugokuLine> _lines;
  List<String> _lineNames;
  List<String> _pickList;
  ChugokuLine _currentLine;
  List<int> _lineSelected = [0];
  List<int> _oldLineSelected = [0];

  //電柱
  List<ChugokuPole> _poles;
  List<String> _poleNames;
  ChugokuPole _currentPole;
  List<int> _poleSelected = [0];
  List<int> _oldPoleSelected = [0];

  // ログインユーザ
  LoginUser _user = LoginUser();

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCg, CgNavigationMenuItem.search.index, CgSelectPolePath);

    // ログインユーザ取得
    widget.auth
        .getUser()
        .then((user) => setState(() {
      _user = user;
    }))
        .catchError((Object error) => showError(error, context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });

    getOffice(widget.userDatachugoku.office)
        .then((office) {
      widget.chugoku.office = office;

      // 線路一覧取得
      getLines(widget.chugoku.office.name).then((lines) {
        _setupLines(lines); // 線路一覧取得処理

        if (widget.chugoku.pole != null) {
          getPoles(widget.chugoku.office.name, _lineName)
              .then(_setupPoles)
              .catchError((Object error) {
            showError(error, context);
          });
        }
        Navigator.pop(context);
      }).catchError((Object error) {
        Navigator.pop(context);
        showError(error, context);
      });

      setState(() {
        _lineController.text = null;
        _poleController.text = null;
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
            title: const Text('電柱検索（事象）'),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        /*showHeader('線路選択'),*/
                        addPadding(2),
                        showTextCustom(
                            widget.chugoku.office != null
                                ? '${widget.chugoku.office.name}'
                                : '',
                            22, Colors.black, null, 1),
                        addPadding(1),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            showLineSearchButton(
                                TextInputType.text,
                                '線路を選択してください',
                                checkValidateLine, _updateLinePicker,
                                _showLinePicker),
                            //_showLineListButton(),
                            addPadding(2),
                            showPoleSearchButton(
                                TextInputType.text,
                                '電柱を選択してください',
                                checkValidatePole, _updatePolePicker,
                                _showPolePicker),
                            //_showPoleButton(),
                            addPadding(3),

                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                              children: [
                                showSubmit(
                                    _formKey, '決定', const Size(200, 50), 20,
                                    Colors.indigo,
                                    (_canSubmit()) ? _submit : null),
                                //addPadding(2),
                                showSubmit(
                                    _formKey, '事象', const Size(160, 50), 20,
                                    Colors.indigo,
                                    null),
                              ],
                            ),

                          ],
                        ),

                        addPadding(1),
                      ],
                    )
                )
            ),
            behavior: HitTestBehavior.opaque,
            onTap: (){
              FocusScope.of(context).unfocus();
            },
          ),
          bottomNavigationBar: cgBottomNavigationBar(
              context, widget.auth, CgNavigationMenuItem.event.index, belongToCg,
              widget.chugoku),
        )
    );
  }


  Future<void> initPoles() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    showProgressIndicator(context);
    await getPoles(widget.chugoku.office.name, _lineName)
        .then((poles) {
      _updatePoles(poles);
      Navigator.pop(context);
    }).catchError((Object error) {
      Navigator.pop(context);
      showError(error, context);
      setState(() {
        _poleName = null;
        _poles = null;
        _poleNames = null;

        _currentPole = null;
        _poleSelected = [0];
        _oldPoleSelected = [0];
      });
    });
  }


  // _setupLines は線路一覧受信時の処理です。
  void _setupLines(List<ChugokuLine> lines) {
    final names = <String>[];
    for (final line in lines) {
      names.add(line.name);
    }

    //線路ピッカボタンを表示させる。
    setState(() {
      _lines = lines;
      _lineNames = names;
      _currentLine = _lines[0];
      _pickList = _lineNames;

      if (widget.chugoku.line != null) {
        _lineName = widget.chugoku.line.name;
        _currentLine = widget.chugoku.line;
        _lineSelected = [_lineNames.indexOf(_lineName)];
        _oldLineSelected = [_lineNames.indexOf(_lineName)];
      }
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
  void _updateLinePicker(String key) {
    final list = <String>[];

    // toUpperCase();で小文字を大文字に変換します。
    key = key.toUpperCase();
    key = _convertString(key);
    for (final l in _lines) {
      /*if (l.filterstring.startsWith(key)) { //前方一致*/
      if (l.filterstring.contains(key)) { //部分一致
        list.add(l.name);
      }
    }
    setState(() {
      _pickList = list;
      _lineName = null;
      _poleName = null;
    });
  }

  void _showLinePicker() {
    _lineSelected = List.from(_oldLineSelected);
    showPicker(context, [_pickList], [0], '${_pickList.length}件の表示', null,
            (Picker picker, List<int> value) {
          // 選択時のコールバック処理
          ChugokuLine selected;
          final idx = value[0];
          for (final l in _lines) {
            if (l.name == _pickList[idx]) {
              selected = l;
              break;
            }
          }
          final lineIndex = _lineNames.indexOf(_pickList[idx]);

          // 見つけた線路を _currentLine にセットして再描画
          setState(() {
            _currentLine = selected;
            _lineName = _pickList[idx];
            _lineController.text = _lineName;
            _lineSelected = [lineIndex];
            _oldLineSelected = _lineSelected;
          });

          initPoles();
        });
  }

  // showLineSearch は、線路検索入力ウィジェットを表示します。
  Widget showLineSearchButton(TextInputType type, String hint,
      FormFieldValidator<String> validator, ValueChanged<String> onChanged, onEditingComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        controller: _lineController,
        textInputAction: TextInputAction.done,
        //inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'ー'), replacementString:'－')],
        //inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0–9]'))],
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
          border: const OutlineInputBorder(
              borderSide: BorderSide(
              )
          ),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _lineController.clear();
                _poleController.clear();
                setState(() {
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

  // _setupPoles は電柱一覧受信時の処理です。
  void _setupPoles(List<ChugokuPole> poles) {
    final names = <String>[];

    for (final pole in poles) {
      names.add(pole.name);
    }

    setState(() {
      //_poleName = widget.chugoku.pole.name;
      _poles = poles;
      _poleNames = names;

      _currentPole = widget.chugoku.pole;
      _poleSelected = [_poleNames.indexOf(_poleName)];
      _oldPoleSelected = [_poleNames.indexOf(_poleName)];

    });
  }

  // _updatePoles は電柱一覧受信時の処理です。
  void _updatePoles(List<ChugokuPole> poles) {
    final names = <String>[];

    for (final pole in poles) {
      names.add(pole.name);
    }

    setState(() {
      _poleName = null;
      _poles = poles;
      _poleNames = names;

      _currentPole = _poles[0];
      _poleSelected = [0];
      _oldPoleSelected = _poleSelected;
    });
  }

  void _updatePolePicker(String key){
    final list = <String>[];
    for (int i = 0; i < omoji.length; i++) {
      key = key.replaceAll(omoji[i], komoji[i]);
    }
    for (final p in _poles) {
      //if (l.contains(key)) {
      /*if (p.filterstring.startsWith(key)) { //前方一致*/
      if (p.filterstring.contains(key)) { //部分一致
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
          ChugokuPole selected;
          final idx = value[0];
          for (final p in _poles) {
            if (p.name == _poleNames[idx]) {
              selected = p;
              break;
            }
          }
          final poleIndex = _lineNames.indexOf(_poleNames[idx]);

          // 見つけた線路を _currentLine にセットして再描画
          setState(() {
            _currentPole = selected;
            _poleName = _poleNames[idx];
            _poleController.text = _poleName;
            _poleSelected = [poleIndex];
            _oldPoleSelected = _poleSelected;
          });
        });
  }

  // showPoleSearch は、線路検索入力ウィジェットを表示します。
  Widget showPoleSearchButton(TextInputType type, String hint,
      FormFieldValidator<String> validator, ValueChanged<String> onChanged, onEditingComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        controller: _poleController,
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
          border: const OutlineInputBorder(
              borderSide: BorderSide(
              )

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



// _submit は決定ボタン押下時のコールバックです。
// 選択された線路をセットして電柱選択画面に遷移します。
  void _submit() {
    // プログレスインジケータ表示
    showProgressIndicator(context);

    getPole(widget.chugoku.office.name, _lineName, _poleName)
        .then((pole) {

      // プログレスインジケータ消去
      Navigator.pop(context);

      final eventPole = <String, dynamic>{
        'line' : _lineName,
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
  // 決定ボタンが押せる状態とは、線路選択が完了している状態です。
  bool _canSubmit()
  {
    debugPrint('polename : $_poleName');
    return _poleName != null;
  }
}



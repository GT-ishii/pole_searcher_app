// 作業一覧
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:polesearcherapp/models/specification.dart';
import 'package:polesearcherapp/models/user.dart';
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chugoku/event.dart';

import 'package:polesearcherapp/pages/common.dart';
import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/parts.dart';

import 'package:polesearcherapp/services/auth.dart';
import 'package:polesearcherapp/services/permission.dart';

class CgEventListWorkPage extends StatefulWidget {
  CgEventListWorkPage(this.auth, this.chugoku, this.event);

  final Auth auth;
  final Chugoku chugoku;
  final CgEvent event;

  @override
  _CgEventListWorkPageState createState() => _CgEventListWorkPageState();
}

class _CgEventListWorkPageState extends State<CgEventListWorkPage> {
  LoginUser _user = LoginUser();

  List<EventData> _eventList = [];
  List<EventData> _searchList = [];

  @override
  void initState() {
    super.initState();

    setBeforePage(belongToCg, CgNavigationMenuItem.event.index, CgEventListWorkPath);

    // ユーザ情報を取得
    widget.auth.getUser()
        .then((user) {
      setState(() {
        _user = user;
      });

      locationPermissionRequest();
      getEventWorksChugoku(_user, widget.chugoku, widget.event.setting.notNotificationStatus).then((eventList) {
        setState(() {
          _eventList = List.from(eventList);
          _searchList = List.from(eventList);
        });
        Navigator.pop(context);
        if (eventList.isEmpty) {
          showPopup('作業が存在しません', context);
          return;
        }

      }).catchError((Object error) {
        Navigator.pop(context);
        showError(error, context);
      });
    }).catchError((Object error) => showError(error, context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProgressIndicator(context);
    });
  }

  Future<void> _refleshList() async{

    await getEventWorksChugoku(_user, widget.chugoku, widget.event.setting.notNotificationStatus).then((eventlist) {
      setState(() {
        _eventList = List.from(eventlist);
        _searchList = List.from(_eventList);
      });
      if (eventlist.isEmpty) {
        return;
      }
    }).catchError((Object error) {
      showError(error, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.popUntil(context, ModalRoute.withName(CgEventSelectPath));
          setBeforePage(belongToCg, CgNavigationMenuItem.event.index, CgEventSelectPath);
          return Future.value(false);
        },
        child:Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget> [
                SliverAppBar(
                  title: Text('作業一覧（${_eventList.length}件）'),
                  centerTitle: true,
                  actions: [
                    showLogoutButton(context, widget.auth, _user)
                  ],
                ),
              ];
            },
            body: Center(
                child: Column(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: RefreshIndicator(
                              color: Colors.blue,
                              onRefresh: _refleshList,
                              child:ListView.builder(
                                  padding: const EdgeInsets.only(top:0),
                                  itemBuilder: (BuildContext context, int index) {
                                    return _menuItem(index);
                                  },
                                  itemCount: _searchList.length
                              )
                          )
                      )
                    ]
                )
            ),
          ),
          bottomNavigationBar: cgBottomNavigationBar(context, widget.auth, CgNavigationMenuItem.event.index, belongToCg, widget.chugoku),
        )
    );
  }

  Widget _menuItem(int index) {
    Color statusColor;
    final status = _searchList[index].status;

    if (status == statusList[0]) {
      statusColor = const Color(0x8A00BFff);
    } else if (status == statusList[1]) {
      statusColor = const Color(0x8Aff0033);
    } else if (status == statusList[2]) {
      statusColor = const Color(0x8Affa500);
    } else if (status == statusList[3]) {
      statusColor = Colors.black45;
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
          border: Border.all(
              width: 0.5, color: Colors.black
          )
      ),
      child: GestureDetector(
        onTap: () => _goNext(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
            child: Row(
                children: <Widget>[
                  Container(
                    width: 12,
                    color: statusColor,
                  ),
                  _searchList[index].image.isNotEmpty
                      ? Container(
                      width: 80,
                      height: 120,
                      decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(),
                            right: BorderSide()
                        ),
                      ),
                      child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: _searchList[index].image[0],
                          placeholder: (context, url) =>
                          const Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          )
                      )
                  )
                      : Container(
                      width: 80,
                      height: 120,
                      decoration: const BoxDecoration(
                          border: Border(
                              left: BorderSide(),
                              right: BorderSide()
                          ),

                          color: Color(0x0D000000)
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.image),
                            Text('No Image', style: TextStyle(fontSize: 14))
                          ]
                      )
                  ),

                  addPadding(1),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(

                              child: showTextCustom(
                                  '種別 : ${_searchList[index].type.reduce((a, b){
                                    return '$a/$b';
                                  })}',
                                  18, Colors.black, TextOverflow.ellipsis, 1)
                          ),

                          showTextCustom(
                              _searchList[index].eventPole != null
                                  ? '電柱 : ${_searchList[index].eventPole['pole']}' : '電柱 : ' ,
                              18, Colors.black, TextOverflow.ellipsis, 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                children: [
                                  showTextCustom('日付 : ${_searchList[index].updatedAt.substring(5)}', 18, Colors.black, null, 1),
                                  addPadding(1),
                                  showTextCustom(_eventList[index].status.substring(0,2), 18, Colors.black, null, 1),
                                ],
                              ),
                              _searchList[index].distance != null ?
                              showTextCustom('${_searchList[index].distance.toString()}km', 18, Colors.black, null, 1)
                                  : const SizedBox.shrink(),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),

                ]
            )
        ),

      ),
    );
  }

  Future<void> _goNext(int index) async{

    widget.event.data = _searchList[index];
    await Navigator.pushNamed(context, CgEventDetailWorkPath)
        .whenComplete(() async{
      showProgressIndicator(context);
      await _refleshList();
      Navigator.pop(context);
    }
    );
  }
}

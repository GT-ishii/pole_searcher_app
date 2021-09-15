import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:polesearcherapp/models/specification.dart';

//チャット画面
import 'package:polesearcherapp/pages/hokuriku/chat.dart';
import 'package:polesearcherapp/pages/hokuriku/chat_list.dart';
import 'package:polesearcherapp/pages/chugoku/chat.dart';
import 'package:polesearcherapp/pages/chugoku/chat_list.dart';
import 'package:polesearcherapp/pages/chuden/chat.dart';
import 'package:polesearcherapp/pages/chuden/chat_list.dart';
import 'package:polesearcherapp/pages/chat_parts/chatModel.dart';
import 'package:polesearcherapp/pages/chat_parts/chat_message.dart';

import 'package:polesearcherapp/pages/login.dart';

import 'package:provider/provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:polesearcherapp/models/user.dart';

import 'package:polesearcherapp/pages/page_list.dart';
import 'package:polesearcherapp/pages/pw_reset.dart';

//北陸パッケージ一覧
import 'package:polesearcherapp/models/hokuriku/hokuriku.dart';
import 'package:polesearcherapp/models/hokuriku/event.dart';
import 'package:polesearcherapp/pages/hokuriku/select_pole.dart';
import 'package:polesearcherapp/pages/hokuriku/show_pole.dart';
import 'package:polesearcherapp/pages/hokuriku/setting.dart';
import 'package:polesearcherapp/pages/hokuriku/edit_profile.dart';
//北陸事象パッケージ一覧
import 'package:polesearcherapp/pages/hokuriku/event_setting.dart';
import 'package:polesearcherapp/pages/hokuriku/event_add.dart';
import 'package:polesearcherapp/pages/hokuriku/event_list.dart';
import 'package:polesearcherapp/pages/hokuriku/event_list_work.dart';
import 'package:polesearcherapp/pages/hokuriku/event_detail.dart';
import 'package:polesearcherapp/pages/hokuriku/event_detail_work.dart';
import 'package:polesearcherapp/pages/hokuriku/event_pole.dart';
import 'package:polesearcherapp/pages/hokuriku/event_select.dart';
import 'package:polesearcherapp/pages/hokuriku/locate_office.dart';
import 'package:polesearcherapp/pages/hokuriku/event_update.dart';

//中国パッケージ一覧
import 'package:polesearcherapp/models/chugoku/chugoku.dart';
import 'package:polesearcherapp/models/chugoku/event.dart';

import 'package:polesearcherapp/pages/chugoku/select_pole.dart';
import 'package:polesearcherapp/pages/chugoku/show_pole.dart';
import 'package:polesearcherapp/pages/chugoku/select_office.dart';
import 'package:polesearcherapp/pages/chugoku/setting.dart';
import 'package:polesearcherapp/pages/chugoku/locate_office.dart';
import 'package:polesearcherapp/pages/chugoku/event_select.dart';
import 'package:polesearcherapp/pages/chugoku/event_add.dart';
import 'package:polesearcherapp/pages/chugoku/event_list.dart';
import 'package:polesearcherapp/pages/chugoku/event_list_work.dart';
import 'package:polesearcherapp/pages/chugoku/event_detail.dart';
import 'package:polesearcherapp/pages/chugoku/event_detail_work.dart';
import 'package:polesearcherapp/pages/chugoku/event_update.dart';
import 'package:polesearcherapp/pages/chugoku/event_pole.dart';
import 'package:polesearcherapp/pages/chugoku/event_setting.dart';
import 'package:polesearcherapp/pages/chugoku/edit_profile.dart';

//中部パッケージ
import 'package:polesearcherapp/models/chuden/chuden.dart';
import 'package:polesearcherapp/models/chuden/event.dart';

import 'package:polesearcherapp/pages/chuden/setting.dart';
import 'package:polesearcherapp/pages/chuden/edit_profile.dart';

import 'package:polesearcherapp/pages/chuden/select_branch_and_office.dart';
import 'package:polesearcherapp/pages/chuden/select_pole.dart';
import 'package:polesearcherapp/pages/chuden/show_pole.dart';
import 'package:polesearcherapp/pages/chuden/locate_office.dart';

import 'package:polesearcherapp/pages/chuden/event_select.dart';
import 'package:polesearcherapp/pages/chuden/event_add.dart';
import 'package:polesearcherapp/pages/chuden/event_pole.dart';
import 'package:polesearcherapp/pages/chuden/event_list.dart';
import 'package:polesearcherapp/pages/chuden/event_list_work.dart';
import 'package:polesearcherapp/pages/chuden/event_detail.dart';
import 'package:polesearcherapp/pages/chuden/event_detail_work.dart';
import 'package:polesearcherapp/pages/chuden/event_update.dart';
import 'package:polesearcherapp/pages/chuden/event_setting.dart';


import 'package:polesearcherapp/pages/unauth.dart';
import 'package:polesearcherapp/pages/unsupported.dart';
import 'package:polesearcherapp/services/auth.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MyApp()
  );
}

class MyApp extends StatelessWidget {
  final Auth _auth = Auth();

  final UserDataHokuriku _userDatahokuriku = UserDataHokuriku();
  final Hokuriku _hokuriku = Hokuriku();
  final HrEvent _hrEvent = HrEvent();

  final UserDataChugoku _userDatachugoku = UserDataChugoku();
  final Chugoku _chugoku = Chugoku();
  final CgEvent _cgEvent = CgEvent();

  final UserDataChuden _userDatachuden = UserDataChuden();
  final Chuden _chuden = Chuden();
  final ChEvent _chEvent = ChEvent();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP')
      ],
      builder: (context, widget){
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        print(AppBar().preferredSize.height);
        debugPrint('Width: $width, Height: $height');

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.2
          ),
          child: ResponsiveWrapper.builder(
              BouncingScrollWrapper.builder(context, widget),

              maxWidth: width,
              defaultScale: height / width > 1 ? false: true,
              defaultScaleFactor: height / width > 1 ? height / 750 : (width < 1080 ? 1 : 0.92),
              breakpoints:
              [
                height / width > 1
                    ? (height < 1080 ? (ResponsiveBreakpoint.resize(width, name: MOBILE, scaleFactor: height / 750))
                    : (const ResponsiveBreakpoint.resize(1080, name: MOBILE, scaleFactor: 1.35) ))
                    : (width < 1080 ? (ResponsiveBreakpoint.resize(width, name: MOBILE, scaleFactor: width / 750))
                    : (const ResponsiveBreakpoint.resize(1080, name: MOBILE, scaleFactor: 1.35) ))
              ],
              background: Container(color: const Color(0xFFF5F5F5))
          ),
        );
      },

      theme: ThemeData(
          primarySwatch: Colors.indigo,
          hintColor: Colors.grey,
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Color(0x0D000000),
          ),
          splashFactory: InkRipple.splashFactory,
          splashColor: Colors.black12,
          buttonTheme: const ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                          (states){
                        if (states.contains(MaterialState.disabled)){
                          return Colors.grey;
                        }
                        return null;
                      })
              )
          )

      ),
      //navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        // 共通

        LoginPagePath: (context) => LoginPage(_auth,
            _userDatahokuriku, _hokuriku, _hrEvent,
            _userDatachugoku, _chugoku, _cgEvent,
            _userDatachuden, _chuden, _chEvent),

        UnAuthPagePath: (context) => UnAuthPage(_auth),
        UnSupportedPath: (context) => UnSupportedPage(),
        PwResetPath: (context) => PwResetPage(_auth),

        //北陸
        HrSelectPolePath: (context) => HrSelectPolePage(_auth, _hokuriku, _hrEvent),
        HrShowPolePath: (context) => HrShowPolePage(_auth, _hokuriku),
        HrSettingPath: (context) => HrSettingPage(_auth, _userDatahokuriku, _hokuriku),
        HrEditProfilePath: (context) => HrEditProfilePage(_auth, _hokuriku),
        HrChatPath: (context) => HrChatPage(_auth, _hokuriku),
        HrChatListPath: (context) => HrChatListPage(_auth, _hokuriku, ChatModel.dummyData, ChatListTypeHokuriku.twoLine),
        //HrSelectBranchPath: (context) => HrSelectBranchAndOfficePage(_auth, _userData, _hokuriku, _hrEvent),
        HrLocateOfficePagePath: (context) => HrLocateOfficePage(_auth, _hokuriku),
        // 北陸 事象管理
        HrEventSelectPath: (context) => HrEventSelectPage(_auth, _hokuriku),
        HrEventPolePath: (context) => HrEventPolePage(_auth, _hokuriku, _hrEvent),
        HrEventListPath: (context) => HrEventListPage(_auth, _hokuriku, _hrEvent),
        HrEventListWorkPath: (context) => HrEventListWorkPage(_auth, _hokuriku, _hrEvent),
        HrEventDetailPath: (context) => HrEventDetailPage(_auth, _hokuriku, _hrEvent),
        HrEventDetailWorkPath: (context) => HrEventDetailWorkPage(_auth, _hokuriku, _hrEvent),
        HrEventUpdatePath: (context) => HrEventUpdatePage(_auth, _hokuriku, _hrEvent),
        HrEventSettingPath: (context) => HrEventSettingPage(_auth,  _hokuriku, _hrEvent),
        HrEventAddPath: (context) => HrEventAddPage(_auth, _hokuriku, _hrEvent),


        // 中国
        CgSelectPolePath: (context) => CgPoleSelectPage(_auth, _chugoku, _cgEvent, _userDatachugoku),
        CgShowPolePath: (context) => CgShowPolePage(_auth, _chugoku),
        CgSettingPath: (context) => CgSettingPage(_auth, _userDatachugoku, _chugoku),
        CgLocateOfficePagePath: (context) => CgLocateOfficePage(_auth, _chugoku),
        CgEditProfilePath: (context) => CgEditProfilePage(_chugoku, _auth),
        CgChatPath: (context) => CgChatPage(_auth, _chugoku),
        CgChatListPath: (context) => CgChatListPage(_auth, _chugoku, ChatModel.dummyData, ChatListTypeChugoku.twoLine),
        // 中国 事象管理
        CgEventSelectPath: (context) => CgEventSelectPage(_auth, _chugoku),
        CgEventAddPath: (context) => CgEventAddPage(_auth, _chugoku, _cgEvent),
        CgSelectOfficePath: (context) => CgSelectOfficePage(_auth, _userDatachugoku, _chugoku, _cgEvent),
        CgEventListPath: (context) => CgEventListPage(_auth, _chugoku, _cgEvent),
        CgEventListWorkPath: (context) => CgEventListWorkPage(_auth, _chugoku, _cgEvent),
        CgEventDetailPath: (context) => CgEventDetailPage(_auth, _chugoku, _cgEvent),
        CgEventDetailWorkPath: (context) => CgEventDetailWorkPage(_auth, _chugoku, _cgEvent),
        CgEventUpdatePath: (context) => CgEventUpdatePage(_auth, _chugoku, _cgEvent),
        CgEventPolePath: (context) => CgEventPolePage(_auth, _chugoku, _cgEvent, _userDatachugoku),
        CgEventSettingPath: (context) => CgEventSettingPage(_auth,  _chugoku, _cgEvent),

        //中部
        ChSettingPath: (context) => ChSettingPage(_auth, _userDatachuden, _chuden),
        ChEditProfilePath: (context) => ChEditProfilePage(_auth, _chuden),
        ChSelectBranchPath: (context) => ChSelectBranchAndOfficePage(_auth, _userDatachuden, _chuden, _chEvent),
        ChSelectPolePath: (context) => ChSelectPolePage(_auth, _chuden, _chEvent),
        ChShowPolePath: (context) => ChShowPolePage(_auth, _chuden),
        ChChatPath: (context) => ChChatPage(_auth, _chuden),
        ChChatListPath: (context) => ChChatListPage(_auth, _chuden, ChatModel.dummyData, ChatListTypeChuden.twoLine),
        ChLocateOfficePagePath: (context) => ChLocateOfficePage(_auth, _chuden),
        // 中部 事象管理
        ChEventSelectPath: (context) => ChEventSelectPage(_auth, _chuden),
        ChEventAddPath: (context) => ChEventAddPage(_auth, _chuden, _chEvent),
        ChEventPolePath: (context) => ChEventPolePage(_auth, _chuden, _chEvent),
        ChEventListPath: (context) => ChEventListPage(_auth, _chuden, _chEvent),
        ChEventListWorkPath: (context) => ChEventListWorkPage(_auth, _chuden, _chEvent),
        ChEventDetailPath: (context) => ChEventDetailPage(_auth, _chuden, _chEvent),
        ChEventDetailWorkPath: (context) => ChEventDetailWorkPage(_auth, _chuden, _chEvent),
        ChEventUpdatePath: (context) => ChEventUpdatePage(_auth, _chuden, _chEvent),
        ChEventSettingPath: (context) => ChEventSettingPage(_auth,  _chuden, _chEvent),

      },
    );
  }
}

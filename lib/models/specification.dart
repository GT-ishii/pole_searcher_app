// 仕様的な定義
const releaseDate = '2021/02/17';
const releaseVersion = '2.3.20';
const minimumPWLength = 8; // 最低パスワード文字数
const defaultMapZoom = 13.0; // 地図のデフォルトズーム値
const eventNotificationRadius = 25.0; //通知距離

const List<String> statusList = ['着手','作業中', '保留', '完了'];
const List<String> eventType = ['営巣', '樹木', 'つるつた', 'その他'];

//電力会社ID一覧
const HokurikuID = 'rikuden';
const ChugokuID = 'energia';
const ChudenID = 'chuden';
//const TohokuID = '';

const belongToHk = 1;
const belongToTh = 2;
const belongToTk = 3;
const belongToHr = 4;
const belongToCh = 5;
const belongToKs = 6;
const belongToCg = 7;
const belongToSk = 8;
const belongToKy = 9;
const belongToOk = 10;

enum HrNavigationMenuItem{
  locate,
  search,
  event,
  setting,
  chat
}

enum CgNavigationMenuItem{
  locate,
  search,
  event,
  setting,
  chat
}

enum ChNavigationMenuItem{
  locate,
  search,
  event,
  setting,
  chat
}


// 電力会社データ
// pole-searcher-server/common/data/basedata.go の内容と合わせてください。

// 電力会社略号
enum PowerCompanyIDs {
  Hokkaido,
  Tohoku,
  Tokyo,
  Hokuriku,
  Chugoku,
  Chubu,
  Kansai,
  Shikoku,
  Kyusyu,
  Okinawa,

  TohokuDebug,
  ChubuDebug,
  HokurikuDebug,
  ChugokuDebug,
}

// PowerCompanies は 電力会社の名称一覧です。
const Map<PowerCompanyIDs, String> PowerCompanies = {
  PowerCompanyIDs.Hokkaido: '北海道電力',
  PowerCompanyIDs.Tohoku: '東北電力',
  PowerCompanyIDs.Tokyo: '東京電力',
  PowerCompanyIDs.Hokuriku: '北陸電力',
  PowerCompanyIDs.Chugoku: '中国電力',
  PowerCompanyIDs.Chubu: '中部電力',
  PowerCompanyIDs.Kansai: '関西電力',
  PowerCompanyIDs.Shikoku: '四国電力',
  PowerCompanyIDs.Kyusyu: '九州電力',
  PowerCompanyIDs.Okinawa: '沖縄電力',

  PowerCompanyIDs.TohokuDebug: '東北電力',
  PowerCompanyIDs.ChubuDebug: '中部電力',
  PowerCompanyIDs.HokurikuDebug:'北陸電力',
  PowerCompanyIDs.ChugokuDebug:'中国電力',
};

// CompanyAbbrevs は 電力会社の略称一覧です。
const Map<PowerCompanyIDs, String> CompanyAbbrevs = {
  PowerCompanyIDs.Hokkaido: 'hk',
  PowerCompanyIDs.Tohoku: 'th',
  PowerCompanyIDs.Tokyo: 'tk',
  PowerCompanyIDs.Hokuriku: 'hrr',
  PowerCompanyIDs.Chugoku: 'cgr',
  PowerCompanyIDs.Chubu: 'chr',
  PowerCompanyIDs.Kansai: 'ks',
  PowerCompanyIDs.Shikoku: 'sk',
  PowerCompanyIDs.Kyusyu: 'ky',
  PowerCompanyIDs.Okinawa: 'ok',

  PowerCompanyIDs.TohokuDebug: 'td',
  PowerCompanyIDs.ChubuDebug: 'cd',
  PowerCompanyIDs.HokurikuDebug:'hrd',
  PowerCompanyIDs.ChugokuDebug:'cgd',
};

// Abbrev2CompanyID は 略称->電力会社の逆引き辞書です。
const Map<String, PowerCompanyIDs> Abbrev2CompanyID = {
  'hkr': PowerCompanyIDs.Hokkaido,
  'thr': PowerCompanyIDs.Tohoku,
  'tkr': PowerCompanyIDs.Tokyo,
  'hrr': PowerCompanyIDs.Hokuriku,
  'cgr': PowerCompanyIDs.Chugoku,
  'chr': PowerCompanyIDs.Chubu,
  'ksr': PowerCompanyIDs.Kansai,
  'skr': PowerCompanyIDs.Shikoku,
  'kyr': PowerCompanyIDs.Kyusyu,
  'okr': PowerCompanyIDs.Okinawa,

  'hrd':PowerCompanyIDs.HokurikuDebug,
  'cgd':PowerCompanyIDs.ChugokuDebug,
  'chd':PowerCompanyIDs.ChubuDebug
};

const Map<PowerCompanyIDs, int>CompanyNumber = {
  PowerCompanyIDs.Hokkaido: 1,
  PowerCompanyIDs.Tohoku: 2,
  PowerCompanyIDs.Tokyo: 3,
  PowerCompanyIDs.Hokuriku: 4,
  PowerCompanyIDs.Chubu: 5,
  PowerCompanyIDs.Kansai: 6,
  PowerCompanyIDs.Chugoku: 7,
  PowerCompanyIDs.Shikoku: 8,
  PowerCompanyIDs.Kyusyu: 9,
  PowerCompanyIDs.Okinawa: 10,

  PowerCompanyIDs.TohokuDebug: 2,
  PowerCompanyIDs.HokurikuDebug:4,
  PowerCompanyIDs.ChubuDebug: 5,
  PowerCompanyIDs.ChugokuDebug:7,
};
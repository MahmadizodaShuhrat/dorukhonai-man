// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tajik (`tg`).
class AppLocalizationsTg extends AppLocalizations {
  AppLocalizationsTg([String locale = 'tg']) : super(locale);

  @override
  String get appTitle => 'Дорухона';

  @override
  String get commonSave => 'Нигоҳ доштан';

  @override
  String get commonCancel => 'Бекор';

  @override
  String get commonConfirm => 'Тасдиқ';

  @override
  String get commonDelete => 'Ҳазф';

  @override
  String get commonEdit => 'Таҳрир';

  @override
  String get commonAdd => 'Илова';

  @override
  String get commonClose => 'Пӯшидан';

  @override
  String get commonRetry => 'Аз нав';

  @override
  String get commonRefresh => 'Навсозӣ';

  @override
  String get commonSearch => 'Ҷустуҷӯ';

  @override
  String get commonNo => 'Не';

  @override
  String get commonYes => 'Ҳа';

  @override
  String get commonOpen => 'Кушодан';

  @override
  String get commonRequired => 'Ҳатмист';

  @override
  String get commonError => 'Хатогӣ';

  @override
  String get commonLoadFailed => 'Боркунӣ ноком шуд.';

  @override
  String get commonNoData => 'Маълумот нест';

  @override
  String get commonDash => '—';

  @override
  String get commonNew => 'Нав';

  @override
  String get commonRestore => 'Барқарор';

  @override
  String get commonApply => 'Татбиқ';

  @override
  String get commonExpand => 'Васеъ кардан';

  @override
  String get commonCollapse => 'Печондан';

  @override
  String get commonPrevious => 'Қаблӣ';

  @override
  String get commonNext => 'Баъдӣ';

  @override
  String commonTotalCount(int count) {
    return 'Ҳамагӣ: $count';
  }

  @override
  String commonPageOf(int page, int pageCount) {
    return '$page / $pageCount';
  }

  @override
  String get commonLoadDataFailed => 'Маълумотро бор карда нашуд.';

  @override
  String get validationEnterNumber => 'Рақами дуруст ворид кунед';

  @override
  String get validationNotNegative => 'Манфӣ шуда наметавонад';

  @override
  String get failureNetwork => 'Хатои шабака. Пайвастро санҷед.';

  @override
  String get failureAuth => 'Иҷозат рад шуд. Дубора ворид шавед.';

  @override
  String get failureUnknown => 'Хатои номаълум рух дод.';

  @override
  String get failureEmptyResponse => 'Ҷавоби холӣ аз сервер.';

  @override
  String failureServer(String status) {
    return 'Хатои сервер ($status).';
  }

  @override
  String get failureInvalidState => 'Амалиёт иҷро нашуд (вазъи нодуруст).';

  @override
  String get failureNotFound => 'Ёфт нашуд.';

  @override
  String get navDashboard => 'Дашборд';

  @override
  String get navPos => 'Касса';

  @override
  String get navStock => 'Анбор';

  @override
  String get navReceipts => 'Приход';

  @override
  String get navWriteOffs => 'Списание';

  @override
  String get navInventory => 'Инвентаризатсия';

  @override
  String get navSupplierReturns => 'Бозгашт';

  @override
  String get navSupplierReturnsLong => 'Бозгашт ба таъминкунанда';

  @override
  String get navProducts => 'Доруҳо';

  @override
  String get navDrugGroups => 'Гурӯҳҳо';

  @override
  String get navSuppliers => 'Таъминкунандагон';

  @override
  String get navManufacturers => 'Истеҳсолкунандагон';

  @override
  String get navUnits => 'Воҳидҳо';

  @override
  String get navReports => 'Ҳисоботҳо';

  @override
  String get navSettings => 'Танзимот';

  @override
  String get navSectionStockOps => 'АМАЛИЁТИ АНБОР';

  @override
  String get navSectionReference => 'МАЪЛУМОТНОМАҲО';

  @override
  String get shellThemeLight => 'Темаи равшан';

  @override
  String get shellThemeDark => 'Темаи торик';

  @override
  String get shellLanguageTajik => 'Тоҷикӣ';

  @override
  String get shellLanguageRussian => 'Русӣ';

  @override
  String get shellLanguageTajikShort => 'ТҶ';

  @override
  String get shellLanguageRussianShort => 'РУ';

  @override
  String get shellLanguageTooltip => 'Забон';

  @override
  String get shellBranchFallback => 'Филиал';

  @override
  String shellShiftOpenAt(String time) {
    return 'Кушода · $time';
  }

  @override
  String get shellShiftClosed => 'Смена баста';

  @override
  String get shellOnline => 'Онлайн';

  @override
  String get shellOffline => 'Офлайн';

  @override
  String shellQueueSuffix(String base, int count) {
    return '$base · $count навбат';
  }

  @override
  String get shellServerReachable => 'Сервер дастрас';

  @override
  String get shellServerUnreachable => 'Сервер дастнорас';

  @override
  String shellLastOnline(String time) {
    return 'Охирин: $time';
  }

  @override
  String shellPendingSyncCount(int count) {
    return '$count фурӯш дар навбати синхрон';
  }

  @override
  String get shellSearchHint => 'Ҷустуҷӯ ё фармон…';

  @override
  String get shellUserFallback => 'Корбар';

  @override
  String get shellLogout => 'Баромад';

  @override
  String get commandSearchHint => 'Фармон ё бахшро ҷустуҷӯ кунед…';

  @override
  String get commandNothingFound => 'Чизе ёфт нашуд';

  @override
  String get commandFooterHint => '↑↓ интихоб · Enter кушодан · Esc пӯшидан';

  @override
  String get dashTitle => 'Дашборд';

  @override
  String dashSubtitleToday(String date) {
    return 'Имрӯз, $date';
  }

  @override
  String get dashKpiTodaySales => 'ФУРӮШИ ИМРӮЗ';

  @override
  String dashKpiReceiptsCount(int count) {
    return '$count чек';
  }

  @override
  String dashKpiExpiringSoon(int days) {
    return 'МӮҲЛАТАШ НАЗДИК ($daysр)';
  }

  @override
  String get dashKpiDrugUnit => 'дору';

  @override
  String get dashKpiLowStock => 'КАМШУДА (зери мин.)';

  @override
  String get dashKpiShift => 'СМЕНА';

  @override
  String get dashShiftOpen => 'Кушода';

  @override
  String get dashShiftClosed => 'Баста';

  @override
  String get dashShiftNotOpen => 'Смена кушода нашуда';

  @override
  String get dashKpiErrorShort => '— хато';

  @override
  String get dashExpiringTitle => 'Мӯҳлаташ наздик';

  @override
  String get dashSeeAllStock => 'Ҳамаро дидан → Анбор';

  @override
  String get dashNoExpiring => 'Дорумӯҳлаташ наздик нест.';

  @override
  String get dashColDrug => 'Дору';

  @override
  String get dashColSeries => 'Серия';

  @override
  String get dashColExpiry => 'Мӯҳлат';

  @override
  String get dashColRemaining => 'Бақия';

  @override
  String get dashLowStockTitle => 'Камшуда';

  @override
  String get dashNoLowStock => 'Дорумкамшуда нест.';

  @override
  String get dashQuickActions => 'Амалҳои зуд';

  @override
  String get dashQuickNewReceipt => 'Приходи нав';

  @override
  String get dashQuickCloseShift => 'Бастани смена';

  @override
  String get dashQuickOpenShift => 'Кушодани смена';

  @override
  String get dashQuickSale => 'Фурӯш';

  @override
  String get dashQuickSearchDrug => 'Ҷустуҷӯи дору';

  @override
  String get dashSalesTrendTitle => 'Фурӯш — 7 рӯзи охир';

  @override
  String get dashNoSalesTrend => 'Дар 7 рӯзи охир фурӯш сабт нашудааст.';

  @override
  String get dashExpiryGone => 'гузашта';

  @override
  String dashExpiryDays(int days) {
    return '$daysр';
  }

  @override
  String get dowMon => 'Дш';

  @override
  String get dowTue => 'Сш';

  @override
  String get dowWed => 'Чш';

  @override
  String get dowThu => 'Пш';

  @override
  String get dowFri => 'Ҷм';

  @override
  String get dowSat => 'Шб';

  @override
  String get dowSun => 'Яш';

  @override
  String get posCartEmpty => 'Сабад холӣ аст';

  @override
  String get posRxTitle => 'Доруи ретсептӣ';

  @override
  String get posRxTooltip => 'Доруи ретсептӣ';

  @override
  String posRxBody(String name) {
    return '«$name» доруи ретсептӣ (℞) аст. Илова кардан ба сабадро тасдиқ мекунед?';
  }

  @override
  String get posOfflineSaleQueued =>
      'Офлайн: фурӯш дар навбати синхрон сабт шуд (чоп шуд).';

  @override
  String get posCartEmptyHint =>
      'Сабад холӣ. Штрих-кодро скан кунед ё ҷустуҷӯ кунед.';

  @override
  String get posColDrug => 'Дору';

  @override
  String get posColQty => 'Миқдор';

  @override
  String get posColPrice => 'Нарх';

  @override
  String get posColSum => 'Ҷамъ';

  @override
  String get posRemove => 'Ҳазф';

  @override
  String get posShiftOpen => 'Смена кушода';

  @override
  String posShiftOpenedAt(String time) {
    return 'Кушода шуд: $time';
  }

  @override
  String posShiftSales(String amount) {
    return 'Фурӯши смена: $amount';
  }

  @override
  String get posReturnsTooltip => 'Бозгашти фурӯш (F7)';

  @override
  String get posCloseShiftTooltip => 'Бастани смена (F10)';

  @override
  String get posScanHint => 'Штрих-кодро скан кунед ё ном ворид кунед…  (F2)';

  @override
  String get posQtyDecrease => 'Кам';

  @override
  String get posQtyIncrease => 'Зиёд';

  @override
  String get posCheck => 'ҲИСОБ';

  @override
  String get posSubtotal => 'Зерҷамъ';

  @override
  String get posDiscountField => 'Тахфиф (F4)';

  @override
  String get posTotalAll => 'ҲАМАГӢ';

  @override
  String get posPaymentMethod => 'Тарзи пардохт';

  @override
  String get posMethodCash => 'Нақд';

  @override
  String get posMethodCard => 'Корт';

  @override
  String get posMethodCredit => 'Қарз';

  @override
  String get posPay => 'Пардохт (F9)';

  @override
  String get posHintSearch => 'Ҷустуҷӯ';

  @override
  String get posHintDiscount => 'Тахфиф';

  @override
  String get posHintPay => 'Пардохт';

  @override
  String get posHintRemove => 'Ҳазф';

  @override
  String get posHintQty => 'Миқдор';

  @override
  String get posHintReturn => 'Бозгашт';

  @override
  String get posHintCloseShift => 'Бастани смена';

  @override
  String get posNoShiftTitle => 'Смена кушода нашудааст';

  @override
  String get posNoShiftBody => 'Барои оғози фурӯш сменаро кушоед.';

  @override
  String get posOpenShift => 'Кушодани смена';

  @override
  String get posOpeningCash => 'Нақди ибтидоӣ *';

  @override
  String get posDiscountTitle => 'Тахфиф';

  @override
  String get posDiscountAmount => 'Маблағи тахфиф';

  @override
  String get stockTitle => 'Анбор';

  @override
  String get stockUnitItems => 'ададҳо';

  @override
  String get stockUnitExpiring => 'мӯҳлаташ наздик';

  @override
  String get stockUnitLow => 'камшуда';

  @override
  String get stockTabOnHand => 'Бақия';

  @override
  String get stockTabExpiring => 'Мӯҳлати наздик';

  @override
  String get stockTabLow => 'Камшуда';

  @override
  String get stockEmptyOnHand => 'Бақия нест';

  @override
  String get stockColName => 'Ном';

  @override
  String get stockColBarcode => 'Штрих-код';

  @override
  String get stockColSeries => 'Серия';

  @override
  String get stockColExpiry => 'Мӯҳлат';

  @override
  String get stockColRemaining => 'Бақия';

  @override
  String get stockColPrice => 'Нарх';

  @override
  String get stockExpiryLabel => 'Мӯҳлат:';

  @override
  String stockDaysOption(int days) {
    return '$days рӯз';
  }

  @override
  String get stockEmptyExpiring => 'Доруи мӯҳлаташ наздик нест';

  @override
  String get stockColRemainingDays => 'Боқимонда (рӯз)';

  @override
  String get stockEmptyLow => 'Доруи камшуда нест';

  @override
  String get stockColTotalRemaining => 'Бақияи ҷамъ';

  @override
  String get stockColMinimum => 'Минимум';

  @override
  String get stockColShortfall => 'Норасоӣ';

  @override
  String get stockSearchHint => 'Ҷустуҷӯ (ном ё штрих-код)…';

  @override
  String get stockExpired => 'Гузашта';

  @override
  String stockExpiryDaysShort(int days) {
    return '$days р';
  }

  @override
  String get stockLegendNear => '≤30 рӯз';

  @override
  String get stockLegendSoon => '≤90 рӯз';

  @override
  String get reportsTitle => 'Ҳисоботҳо';

  @override
  String get reportViewSales => 'Фурӯш';

  @override
  String get reportViewProfit => 'Фоида';

  @override
  String get reportViewStockValue => 'Арзиши анбор';

  @override
  String get reportViewExpiring => 'Мӯҳлаташ наздик';

  @override
  String get reportViewZReport => 'Z-ҳисобот';

  @override
  String get reportGroupByDay => 'Аз рӯи рӯз';

  @override
  String get reportGroupByProduct => 'Аз рӯи дору';

  @override
  String get reportGroupBySeller => 'Аз рӯи фурӯшанда';

  @override
  String get reportsNoExportData => 'Барои содирот маълумот нест.';

  @override
  String reportsCsvSaved(String path) {
    return 'CSV нигоҳ дошта шуд: $path';
  }

  @override
  String reportsExportFailed(String error) {
    return 'Содирот ноком шуд: $error';
  }

  @override
  String reportsTitleSales(String groupBy) {
    return 'Ҳисоботи фурӯш ($groupBy)';
  }

  @override
  String get reportColGroup => 'Гурӯҳ';

  @override
  String get reportColReceipt => 'Чек';

  @override
  String get reportColQty => 'Миқдор';

  @override
  String get reportColSubtotal => 'Зерҷамъ';

  @override
  String get reportColDiscount => 'Тахфиф';

  @override
  String get reportColTotal => 'Ҳамагӣ';

  @override
  String get reportsTitleProfit => 'Ҳисоботи фоида';

  @override
  String get reportColMetric => 'Нишондиҳанда';

  @override
  String get reportColAmount => 'Маблағ';

  @override
  String get reportRevenue => 'Даромад';

  @override
  String get reportCost => 'Арзиши аслӣ';

  @override
  String get reportProfit => 'Фоида';

  @override
  String get reportMargin => 'Маржа';

  @override
  String get reportsTitleStockValue => 'Арзиши анбор';

  @override
  String get reportColDrug => 'Дору';

  @override
  String get reportColPurchaseValue => 'Арзиши харид';

  @override
  String get reportColSaleValue => 'Арзиши фурӯш';

  @override
  String get reportsTitleExpiring => 'Доруҳои мӯҳлаташ наздик';

  @override
  String get reportColSeries => 'Серия';

  @override
  String get reportColExpiry => 'Мӯҳлат';

  @override
  String get reportColDays => 'Рӯз';

  @override
  String get reportColRemaining => 'Бақия';

  @override
  String reportsTitleZReport(String shiftId) {
    return 'Z-ҳисобот · $shiftId';
  }

  @override
  String get reportZOpened => 'Кушодашуда';

  @override
  String get reportZClosed => 'Басташуда';

  @override
  String get reportZOpeningCash => 'Маблағи аввал';

  @override
  String get reportZSalesCount => 'Шумораи фурӯш';

  @override
  String get reportZTotalSales => 'Фурӯши умумӣ';

  @override
  String get reportZReturns => 'Бозгашт';

  @override
  String get reportZNet => 'Софӣ';

  @override
  String get reportZCash => 'Нақд';

  @override
  String get reportZCard => 'Корт';

  @override
  String get reportZCredit => 'Қарз';

  @override
  String get reportZExpectedCash => 'Нақди интизорӣ';

  @override
  String get reportZActualCash => 'Нақди ҳақиқӣ';

  @override
  String get reportDateFrom => 'Аз';

  @override
  String get reportDateTo => 'То';

  @override
  String get reportPresetToday => 'Имрӯз';

  @override
  String get reportPreset7Days => '7 рӯз';

  @override
  String get reportPresetThisMonth => 'Ин моҳ';

  @override
  String get reportNoChartData => 'Барои график маълумот нест';

  @override
  String get reportPositive => 'Мусбат';

  @override
  String get reportNegative => 'Манфӣ';

  @override
  String get reportShiftIdField => 'ID-и смена';

  @override
  String get reportEnterShiftId => 'ID-и смена ворид кунед.';

  @override
  String get settingsTitle => 'Танзимот';

  @override
  String get settingsSubtitle =>
      'Намуд · сервер · огоҳӣ · нарх · принтер · корбар';

  @override
  String get settingsAppearance => 'Намуди намоиш';

  @override
  String get settingsThemeLabel => 'Намуди тема:';

  @override
  String get settingsThemeSystem => 'Системавӣ';

  @override
  String get settingsThemeLight => 'Равшан';

  @override
  String get settingsThemeDark => 'Торик';

  @override
  String get settingsThemeHint =>
      '«Системавӣ» аз танзими Windows пайравӣ мекунад. Интихоб нигоҳ дошта мешавад.';

  @override
  String get settingsLanguage => 'Забон';

  @override
  String get settingsLanguageLabel => 'Забони барнома:';

  @override
  String get settingsLanguageTajik => 'Тоҷикӣ';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageHint =>
      'Интихоб нигоҳ дошта мешавад ва ба тамоми барнома татбиқ мегардад.';

  @override
  String get settingsServer => 'Сервер';

  @override
  String get settingsServerCurrentUrl => 'URL-и ҷорӣ: ';

  @override
  String get settingsServerField =>
      'Суроғаи сервер (scheme://host:port/api/v1)';

  @override
  String get settingsServerLocked =>
      'Аз --dart-define муайян шуда — таҳрир мумкин нест.';

  @override
  String get settingsServerExample => 'Мисол: http://192.168.1.10:5000/api/v1';

  @override
  String get settingsTestConnection => 'Санҷиши пайваст';

  @override
  String get settingsConnected => 'Пайваст шуд';

  @override
  String get settingsNotConnected => 'Пайваст нашуд';

  @override
  String get settingsInvalidUrl =>
      'Суроғаи нодуруст. http(s)://host… ворид кунед.';

  @override
  String get settingsUrlSaved => 'Суроғаи сервер нигоҳ дошта шуд.';

  @override
  String get settingsUrlReset => 'Ба суроғаи пешфарз баргардонида шуд.';

  @override
  String get settingsAlert => 'Огоҳӣ';

  @override
  String get settingsAlertHorizon => 'Уфуқи огоҳии мӯҳлат (рӯз):';

  @override
  String settingsAlertDays(int days) {
    return '$days рӯз';
  }

  @override
  String get settingsMarkup => 'Нарх';

  @override
  String get settingsMarkupLabel =>
      'Наценкаи пешфарз (барои модули нархгузорӣ):';

  @override
  String get settingsMarkupField => 'Наценка %';

  @override
  String get settingsMarkupSaved => 'Наценка нигоҳ дошта шуд.';

  @override
  String get settingsMarkupHint =>
      'Эзоҳ: дар сервер нигоҳ дошта мешавад ва ҳамчун наценкаи пешфарзи нархи фурӯш ҳангоми приход истифода мешавад.';

  @override
  String get settingsPrinter => 'Принтер';

  @override
  String get settingsPrinterHint =>
      'Чопи чек тавассути диалоги системавии чоп (printing). Интихоби принтери пешфарз дар нусхаи минбаъда илова мешавад.';

  @override
  String get settingsSystem => 'Системавӣ';

  @override
  String get settingsUser => 'Корбар';

  @override
  String get settingsLogout => 'Баромадан';

  @override
  String get settingsUsers => 'Корбарон';

  @override
  String get settingsUserAdded => 'Корбар илова шуд.';

  @override
  String get settingsUserUpdated => 'Корбар таҳрир шуд.';

  @override
  String get settingsDeactivateTitle => 'Ғайрифаъол кардан';

  @override
  String settingsDeactivateBody(String name) {
    return '«$name»-ро ғайрифаъол мекунед?';
  }

  @override
  String get settingsUserDeactivated => 'Корбар ғайрифаъол шуд.';

  @override
  String get settingsNewUser => 'Корбари нав';

  @override
  String get settingsNoUsers => 'Корбар нест';

  @override
  String get settingsEditTooltip => 'Таҳрир';

  @override
  String get settingsDeactivateTooltip => 'Ғайрифаъол';

  @override
  String get settingsEditUser => 'Таҳрири корбар';

  @override
  String get settingsFullName => 'Ному насаб *';

  @override
  String get settingsUserName => 'Номи корбар (login) *';

  @override
  String get settingsPassword => 'Парол *';

  @override
  String get settingsPasswordMin => 'Камаш 4 аломат';

  @override
  String get settingsRole => 'Нақш *';

  @override
  String get settingsAbout => 'Дар бораи';

  @override
  String get settingsAboutText => 'Дорухона — Касса/Анбор · v1.0.0';

  @override
  String get loginTitle => 'Дорухона — Касса';

  @override
  String get loginUsername => 'Логин';

  @override
  String get loginUsernameRequired => 'Логинро ворид кунед';

  @override
  String get loginPassword => 'Парол';

  @override
  String get loginPasswordRequired => 'Паролро ворид кунед';

  @override
  String get loginSubmit => 'Воридшавӣ';

  @override
  String get receiptsTitle => 'Приход';

  @override
  String get receiptsRefresh => 'Навсозӣ';

  @override
  String get receiptsNew => 'Приход нав';

  @override
  String get receiptsEmpty => 'Приход ёфт нашуд';

  @override
  String get receiptColNumber => '№';

  @override
  String get receiptColDate => 'Сана';

  @override
  String get receiptColSupplier => 'Таъминкунанда';

  @override
  String get receiptColStatus => 'Статус';

  @override
  String get receiptColTotal => 'Ҷамъ';

  @override
  String get receiptFilterAll => 'Ҳама';

  @override
  String get receiptDateFilter => 'Сана';

  @override
  String get receiptClearDate => 'Санаро тоза кардан';

  @override
  String get receiptStatusDraft => 'Лоиҳа';

  @override
  String get receiptStatusPosted => 'Тасдиқшуда';

  @override
  String get receiptStatusCancelled => 'Бекоршуда';

  @override
  String receiptPageOf(int page, int pageCount) {
    return 'Саҳ. $page аз $pageCount';
  }

  @override
  String receiptEditTitle(String number) {
    return 'Приход $number';
  }

  @override
  String get receiptNewTitle => 'Приход нав';

  @override
  String get receiptValSupplier => 'Таъминкунандаро интихоб кунед';

  @override
  String get receiptValBranch => 'Филиалро ворид кунед';

  @override
  String get receiptValAtLeastOneLine => 'Ҳадди ақал як сатр илова кунед';

  @override
  String receiptValLine(int index, String problem) {
    return 'Сатри $index: $problem';
  }

  @override
  String get receiptSavedDraft => 'Приход ҳамчун лоиҳа нигоҳ дошта шуд';

  @override
  String get receiptSaveFirst => 'Аввал приходро нигоҳ доред';

  @override
  String get receiptPostTitle => 'Тасдиқи приход';

  @override
  String get receiptPostBody =>
      'Приход тасдиқ карда шавад? Баъди тасдиқ бақия нав мешавад.';

  @override
  String get receiptPosted => 'Приход тасдиқ шуд';

  @override
  String get receiptCancelTitle => 'Бекор кардани приход';

  @override
  String get receiptCancelBody => 'Приход бекор карда шавад?';

  @override
  String get receiptCancelConfirm => 'Бекор кардан';

  @override
  String get receiptCancelled => 'Приход бекор шуд';

  @override
  String receiptLinesCount(int count) {
    return 'Сатрҳо ($count)';
  }

  @override
  String get receiptAddLine => 'Илова сатр / скан штрих-код';

  @override
  String get receiptNoLinesEditable =>
      'Сатр нест. «Илова сатр»-ро пахш кунед ё штрих-код скан кунед.';

  @override
  String get receiptNoLinesReadonly => 'Дар ин приход сатр нест.';

  @override
  String get receiptColDrug => 'Дору';

  @override
  String get receiptColQty => 'Миқдор';

  @override
  String get receiptColSeries => 'Серия';

  @override
  String get receiptColExpiry => 'Мӯҳлат';

  @override
  String get receiptColPurchasePrice => 'Нархи харид';

  @override
  String get receiptColSalePrice => 'Нархи фурӯш';

  @override
  String get receiptColLineTotal => 'Ҷамъ';

  @override
  String get receiptDeleteLine => 'Ҳазфи сатр';

  @override
  String get receiptValQty => 'миқдори дуруст ворид кунед';

  @override
  String get receiptValSeries => 'серияро ворид кунед';

  @override
  String get receiptValPurchasePrice => 'нархи харидро ворид кунед';

  @override
  String get receiptValSalePrice => 'нархи фурӯшро ворид кунед';

  @override
  String get receiptSupplier => 'Таъминкунанда';

  @override
  String get receiptBranch => 'Филиал *';

  @override
  String get receiptNumber => 'Рақам';

  @override
  String get receiptNumberNew => '— нав —';

  @override
  String receiptPurchaseTotal(String amount) {
    return 'Ҷамъи харид: $amount';
  }

  @override
  String receiptLinesLabel(int count) {
    return 'Сатрҳо: $count';
  }

  @override
  String get receiptSaveDraftBtn => 'Нигоҳ доштан (Лоиҳа)';

  @override
  String get receiptShopName => 'Дорухонаи Ман';

  @override
  String get receiptCheck => 'Чек';

  @override
  String receiptCheckNumber(String number) {
    return 'Чек № $number';
  }

  @override
  String get receiptViewSubtotal => 'Зерҷамъ';

  @override
  String get receiptViewDiscount => 'Тахфиф';

  @override
  String get receiptViewTotal => 'ҲАМАГӢ';

  @override
  String get receiptViewChange => 'Қайтарма';

  @override
  String get receiptThanks => 'Ташаккур барои харид!';

  @override
  String get receiptPrint => 'Чоп';

  @override
  String receiptSeries(String series) {
    return 'Серия: $series';
  }

  @override
  String get paymentMethodCash => 'Нақд';

  @override
  String get paymentMethodCard => 'Корт';

  @override
  String get paymentMethodCredit => 'Қарз';

  @override
  String get payTitle => 'Пардохт';

  @override
  String payForPayment(String amount) {
    return 'Барои пардохт: $amount';
  }

  @override
  String get payAmountGiven => 'Маблағи додашуда';

  @override
  String get payChange => 'Қайтарма:';

  @override
  String get closeShiftTitle => 'Бастани смена';

  @override
  String closeShiftOpenedAt(String time) {
    return 'Кушода шуд: $time';
  }

  @override
  String closeShiftOpeningCash(String amount) {
    return 'Нақди ибтидоӣ: $amount';
  }

  @override
  String closeShiftSales(String amount) {
    return 'Фурӯш: $amount';
  }

  @override
  String get closeShiftClosingCash => 'Нақди ниҳоӣ (ҳисобшуда) *';

  @override
  String get closeShiftClose => 'Бастан';

  @override
  String get zReportTitle => 'Z-ҳисобот';

  @override
  String get zReportOpened => 'Кушода шуд';

  @override
  String get zReportClosed => 'Баста шуд';

  @override
  String get zReportOpeningCash => 'Нақди ибтидоӣ';

  @override
  String get zReportSalesCount => 'Шумораи фурӯш';

  @override
  String get zReportSalesTotal => 'Фурӯш (ҷамъ)';

  @override
  String get zReportReturnsTotal => 'Бозгашт (ҷамъ)';

  @override
  String get zReportNet => 'Софи фурӯш';

  @override
  String get zReportExpectedCash => 'Нақди интизорӣ';

  @override
  String get zReportCountedCash => 'Нақди ҳисобшуда';

  @override
  String get zReportDiff => 'Фарқият';

  @override
  String get returnsPickTitle => 'Интихоби чек барои бозгашт';

  @override
  String get returnsNoSales => 'Фурӯш ёфт нашуд';

  @override
  String get returnsLinesTitle => 'Сатрҳои бозгашт';

  @override
  String get returnsBack => 'Бозгашт';

  @override
  String get returnsNoLines => 'Сатр нест';

  @override
  String returnsLineSubtitle(String series, String qty, String price) {
    return 'Серия: $series • Фурӯхта: $qty • $price';
  }

  @override
  String get returnsSubmit => 'Бозгашт';

  @override
  String get returnsSelectAtLeastOne => 'Ҳадди ақал як сатрро интихоб кунед';

  @override
  String get returnsOfflineUnsupported => 'Бозгашт офлайн дастгирӣ намешавад.';

  @override
  String get productsTitle => 'Доруҳо';

  @override
  String get productsNew => 'Дору нав';

  @override
  String get productsSearchHint => 'Ҷустуҷӯ (ном ё штрих-код)…';

  @override
  String get productsEmpty => 'Дору ёфт нашуд';

  @override
  String get productColName => 'Ном';

  @override
  String get productColBarcode => 'Штрих-код';

  @override
  String get productColGroup => 'Гурӯҳ';

  @override
  String get productColUnit => 'Воҳид';

  @override
  String get productColRx => 'Ретсептӣ';

  @override
  String get productColActive => 'Фаъол';

  @override
  String get productActive => 'Фаъол';

  @override
  String get productInactive => 'Ғайрифаъол';

  @override
  String get productEditTitle => 'Таҳрири дору';

  @override
  String get productNewTitle => 'Дору нав';

  @override
  String get productName => 'Ном *';

  @override
  String get productValName => 'Номи доруро ворид кунед';

  @override
  String get productBarcode => 'Штрих-код';

  @override
  String get productGroup => 'Гурӯҳи дору';

  @override
  String get productManufacturer => 'Истеҳсолкунанда';

  @override
  String get productUnit => 'Воҳиди ченак';

  @override
  String get productMinStock => 'Минималии бақия';

  @override
  String get productMinStockHelper => 'Зери ин — «камшуда»';

  @override
  String get productRx => 'Доруи ретсептӣ';

  @override
  String get productRxSubtitle => 'Фурӯш бо ретсепт';

  @override
  String get productActiveLabel => 'Фаъол';

  @override
  String get productCreate => 'Сохтан';

  @override
  String get productDeactivateDelete => 'Ғайрифаъол кардан / Ҳазф';

  @override
  String get productUpdated => 'Дору навсозӣ шуд';

  @override
  String get productCreated => 'Дору сохта шуд';

  @override
  String get productDeleteTitle => 'Ҳазфи дору';

  @override
  String productDeleteBody(String name) {
    return '«$name» ҳазф карда шавад?';
  }

  @override
  String get productDeleted => 'Дору ҳазф шуд';

  @override
  String get productPickerTitle => 'Интихоби дору';

  @override
  String get productPickerSearchHint => 'Ҷустуҷӯ ё скани штрих-код…';

  @override
  String get productPickerCreateNew => 'Дору нав сохтан';

  @override
  String get quickCreateTitle => 'Дору нав сохтан';

  @override
  String get quickCreateName => 'Номи дору *';

  @override
  String get quickCreateNameHint => 'мас. Парацетамол 500мг №10';

  @override
  String get quickCreateNameRequired => 'Ном ҳатмист';

  @override
  String get quickCreateGroup => 'Гурӯҳ';

  @override
  String get quickCreateUnit => 'Воҳид';

  @override
  String get quickCreateMinStock => 'Минималии бақия (ихтиёрӣ)';

  @override
  String get quickCreateRx => 'Бо ретсепт';

  @override
  String get quickCreateSubmit => 'Сохтан ва илова';

  @override
  String get refSuppliersTitle => 'Таъминкунандагон';

  @override
  String get refSupplierNew => 'Таъминкунандаи нав';

  @override
  String get refSupplierSearchHint => 'Ҷустуҷӯи таъминкунанда…';

  @override
  String get refSupplierEmpty => 'Таъминкунанда ёфт нашуд';

  @override
  String get refSupplierEntity => 'таъминкунанда';

  @override
  String get refColInn => 'ИНН';

  @override
  String get refColPhone => 'Телефон';

  @override
  String get refSupplierValName => 'Номи таъминкунандаро ворид кунед';

  @override
  String get refSupplierUpdated => 'Таъминкунанда навсозӣ шуд';

  @override
  String get refSupplierCreated => 'Таъминкунанда сохта шуд';

  @override
  String get refSupplierDeleted => 'Таъминкунанда ҳазф шуд';

  @override
  String get refFieldAddress => 'Суроға';

  @override
  String get refManufacturersTitle => 'Истеҳсолкунандагон';

  @override
  String get refManufacturerNew => 'Истеҳсолкунандаи нав';

  @override
  String get refManufacturerSearchHint => 'Ҷустуҷӯи истеҳсолкунанда…';

  @override
  String get refManufacturerEmpty => 'Истеҳсолкунанда ёфт нашуд';

  @override
  String get refManufacturerEntity => 'истеҳсолкунанда';

  @override
  String get refColCountry => 'Кишвар';

  @override
  String get refManufacturerValName => 'Номи истеҳсолкунандаро ворид кунед';

  @override
  String get refManufacturerUpdated => 'Истеҳсолкунанда навсозӣ шуд';

  @override
  String get refManufacturerCreated => 'Истеҳсолкунанда сохта шуд';

  @override
  String get refManufacturerDeleted => 'Истеҳсолкунанда ҳазф шуд';

  @override
  String get refGroupsTitle => 'Гурӯҳҳо';

  @override
  String get refGroupNew => 'Гурӯҳи нав';

  @override
  String get refGroupSearchHint => 'Ҷустуҷӯи гурӯҳ…';

  @override
  String get refGroupEmpty => 'Гурӯҳ ёфт нашуд';

  @override
  String get refGroupEntity => 'гурӯҳ';

  @override
  String get refGroupValName => 'Номи гурӯҳро ворид кунед';

  @override
  String get refGroupUpdated => 'Гурӯҳ навсозӣ шуд';

  @override
  String get refGroupCreated => 'Гурӯҳ сохта шуд';

  @override
  String get refGroupDeleted => 'Гурӯҳ ҳазф шуд';

  @override
  String get refUnitsTitle => 'Воҳидҳо';

  @override
  String get refUnitNew => 'Воҳиди нав';

  @override
  String get refUnitSearchHint => 'Ҷустуҷӯи воҳид…';

  @override
  String get refUnitEmpty => 'Воҳид ёфт нашуд';

  @override
  String get refUnitEntity => 'воҳид';

  @override
  String get refUnitValName => 'Номи воҳидро ворид кунед';

  @override
  String get refUnitUpdated => 'Воҳид навсозӣ шуд';

  @override
  String get refUnitCreated => 'Воҳид сохта шуд';

  @override
  String get refUnitDeleted => 'Воҳид ҳазф шуд';

  @override
  String get refColName => 'Ном';

  @override
  String get refFieldName => 'Ном *';

  @override
  String refEntityNew(String entity) {
    return '$entity нав';
  }

  @override
  String refEntityEdit(String entity) {
    return 'Таҳрири $entity';
  }

  @override
  String get refSearchHint => 'Ҷустуҷӯ…';

  @override
  String refPickerSelect(String label) {
    return '$label-ро интихоб кунед';
  }

  @override
  String get refLoadError => 'Хатои боркунӣ';

  @override
  String get writeOffTitle => 'Списание';

  @override
  String get writeOffSubtitle =>
      'Аз бақия баровардан (мӯҳлат гузашта, вайроншуда…)';

  @override
  String get writeOffSubmit => 'Сабт кардан';

  @override
  String get writeOffReason => 'Сабаб *';

  @override
  String get writeOffNote => 'Эзоҳ';

  @override
  String get writeOffAddBatch => 'Партия илова';

  @override
  String get writeOffSaved => 'Списание сабт шуд.';

  @override
  String get writeOffEmptyDraft => 'Партия илова кунед барои списание.';

  @override
  String get writeOffHistoryTitle => 'Списанияҳои охирин';

  @override
  String get writeOffHistoryEmpty => 'Ҳоло списание сабт нашудааст.';

  @override
  String get writeOffReasonExpired => 'Мӯҳлат гузашта';

  @override
  String get writeOffReasonDamaged => 'Вайроншуда';

  @override
  String get writeOffReasonLost => 'Гумшуда';

  @override
  String get writeOffReasonOther => 'Дигар';

  @override
  String get supplierReturnTitle => 'Бозгашт ба таъминкунанда';

  @override
  String get supplierReturnSubtitle =>
      'Баргардонидани партияҳо ба таъминкунанда';

  @override
  String get supplierReturnSubmit => 'Сабт кардан';

  @override
  String get supplierReturnSupplier => 'Таъминкунанда';

  @override
  String get supplierReturnSelectSupplier => 'Таъминкунандаро интихоб кунед.';

  @override
  String get supplierReturnSaved => 'Бозгашт ба таъминкунанда сабт шуд.';

  @override
  String get supplierReturnEmptyDraft => 'Партия илова кунед барои бозгашт.';

  @override
  String get supplierReturnHistoryTitle => 'Бозгаштҳои охирин';

  @override
  String get supplierReturnHistoryEmpty => 'Ҳоло бозгашт сабт нашудааст.';

  @override
  String get inventoryTitle => 'Инвентаризатсия';

  @override
  String get inventorySubtitle => 'Ҳисоб кардани бақия ва танзими фарқият';

  @override
  String get inventorySubmit => 'Сабт кардан';

  @override
  String get inventoryNote => 'Эзоҳ';

  @override
  String get inventoryAddBatch => 'Партия илова';

  @override
  String get inventorySavedNoDiff => 'Инвентаризатсия сабт шуд (фарқият нест).';

  @override
  String get inventoryDiscrepanciesTitle => 'Фарқиятҳои инвентаризатсия';

  @override
  String get inventoryColExpected => 'Интизор';

  @override
  String get inventoryColCounted => 'Ҳисобшуда';

  @override
  String get inventoryColDiff => 'Фарқият';

  @override
  String get inventoryOk => 'Хуб';

  @override
  String get inventoryEmptyDraft => 'Партия илова кунед барои ҳисоб.';

  @override
  String get inventoryCountedLabel => 'Ҳисобшуда';

  @override
  String get inventoryHistoryTitle => 'Инвентаризатсияҳои охирин';

  @override
  String get inventoryHistoryEmpty => 'Ҳоло инвентаризатсия сабт нашудааст.';

  @override
  String get opColDate => 'Сана';

  @override
  String get opColNumber => 'Рақам';

  @override
  String get opColLines => 'Сатрҳо';

  @override
  String get opColSupplier => 'Таъминкунанда';

  @override
  String get opColReason => 'Сабаб';

  @override
  String get opValBranchUnresolved =>
      'Филиал ҳанӯз муайян нашуд. Лутфан дубора кӯшиш кунед.';

  @override
  String get opValAtLeastOneBatch => 'Ҳадди ақал як партия илова кунед.';

  @override
  String opValQtyPositive(String name) {
    return 'Миқдори «$name» бояд аз сифр зиёд бошад.';
  }

  @override
  String opValQtyMax(String name, String onHand) {
    return 'Миқдори «$name» аз бақия ($onHand) зиёд аст.';
  }

  @override
  String get opColDrug => 'Дору';

  @override
  String get opColSeries => 'Серия';

  @override
  String get opColRemaining => 'Бақия';

  @override
  String get opColDiscrepancy => 'Фарқият';

  @override
  String get opEmptyDefault => 'Партия илова кунед.';

  @override
  String get opColQty => 'Миқдор';

  @override
  String get batchPickerTitle => 'Интихоби партия';

  @override
  String get batchPickerSearchHint => 'Ҷустуҷӯи дору ё штрих-код…';

  @override
  String get batchPickerEmpty => 'Партия ёфт нашуд';

  @override
  String batchPickerSubtitle(String series, String date) {
    return 'Серия: $series · то $date';
  }

  @override
  String batchPickerRemaining(String qty) {
    return 'Бақия: $qty';
  }

  @override
  String stockBatchesCount(int count) {
    return 'Партияҳо ($count)';
  }

  @override
  String get stockNoBatchesOnPage => 'Дар саҳифаи ҷорӣ партия нест.';

  @override
  String get stockMovementsTitle => 'Ҳаракати дору';

  @override
  String get stockNoMovements => 'Ҳаракат нест';

  @override
  String get movementReceipt => 'Приход';

  @override
  String get movementSale => 'Фурӯш';

  @override
  String get movementReturn => 'Бозгашт';

  @override
  String get movementWriteOff => 'Списание';

  @override
  String get movementAdjustment => 'Тасҳеҳ';

  @override
  String get movementTransfer => 'Интиқол';

  @override
  String get syncTitle => 'Синхронизатсия';

  @override
  String get syncOnline => 'Онлайн';

  @override
  String get syncOffline => 'Офлайн';

  @override
  String syncInQueue(int count) {
    return '$count дар навбат';
  }

  @override
  String get syncNow => 'Синхрон кардан';

  @override
  String get syncConflictsTitle => 'Низоъҳо (conflict)';

  @override
  String syncError(String error) {
    return 'Хато: $error';
  }

  @override
  String get syncNoConflictsTitle => 'Низоъ нест';

  @override
  String get syncNoConflictsBody =>
      'Ҳама фурӯшҳои офлайн бомуваффақият синхрон шуданд.';

  @override
  String syncResult(int pushed, int conflicts, int failed) {
    return 'Синхрон: $pushed қабул, $conflicts низоъ, $failed нашуд.';
  }

  @override
  String syncSaleAt(String time) {
    return 'Фурӯш $time';
  }

  @override
  String get syncConflictFallback => 'Бақия дар сервер нарасид.';

  @override
  String get syncDismiss => 'Рад кардан';

  @override
  String get syncDismissed => 'Низоъ рад карда шуд.';
}

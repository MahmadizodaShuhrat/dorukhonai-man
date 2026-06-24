import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('tg'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tg, this message translates to:
  /// **'Дорухона'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In tg, this message translates to:
  /// **'Нигоҳ доштан'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In tg, this message translates to:
  /// **'Бекор'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In tg, this message translates to:
  /// **'Тасдиқ'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In tg, this message translates to:
  /// **'Ҳазф'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In tg, this message translates to:
  /// **'Таҳрир'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In tg, this message translates to:
  /// **'Илова'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In tg, this message translates to:
  /// **'Пӯшидан'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In tg, this message translates to:
  /// **'Аз нав'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In tg, this message translates to:
  /// **'Навсозӣ'**
  String get commonRefresh;

  /// No description provided for @commonSearch.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ'**
  String get commonSearch;

  /// No description provided for @commonNo.
  ///
  /// In tg, this message translates to:
  /// **'Не'**
  String get commonNo;

  /// No description provided for @commonYes.
  ///
  /// In tg, this message translates to:
  /// **'Ҳа'**
  String get commonYes;

  /// No description provided for @commonOpen.
  ///
  /// In tg, this message translates to:
  /// **'Кушодан'**
  String get commonOpen;

  /// No description provided for @commonRequired.
  ///
  /// In tg, this message translates to:
  /// **'Ҳатмист'**
  String get commonRequired;

  /// No description provided for @commonError.
  ///
  /// In tg, this message translates to:
  /// **'Хатогӣ'**
  String get commonError;

  /// No description provided for @commonLoadFailed.
  ///
  /// In tg, this message translates to:
  /// **'Боркунӣ ноком шуд.'**
  String get commonLoadFailed;

  /// No description provided for @commonNoData.
  ///
  /// In tg, this message translates to:
  /// **'Маълумот нест'**
  String get commonNoData;

  /// No description provided for @commonDash.
  ///
  /// In tg, this message translates to:
  /// **'—'**
  String get commonDash;

  /// No description provided for @commonNew.
  ///
  /// In tg, this message translates to:
  /// **'Нав'**
  String get commonNew;

  /// No description provided for @commonRestore.
  ///
  /// In tg, this message translates to:
  /// **'Барқарор'**
  String get commonRestore;

  /// No description provided for @commonApply.
  ///
  /// In tg, this message translates to:
  /// **'Татбиқ'**
  String get commonApply;

  /// No description provided for @commonExpand.
  ///
  /// In tg, this message translates to:
  /// **'Васеъ кардан'**
  String get commonExpand;

  /// No description provided for @commonCollapse.
  ///
  /// In tg, this message translates to:
  /// **'Печондан'**
  String get commonCollapse;

  /// No description provided for @commonPrevious.
  ///
  /// In tg, this message translates to:
  /// **'Қаблӣ'**
  String get commonPrevious;

  /// No description provided for @commonNext.
  ///
  /// In tg, this message translates to:
  /// **'Баъдӣ'**
  String get commonNext;

  /// No description provided for @commonTotalCount.
  ///
  /// In tg, this message translates to:
  /// **'Ҳамагӣ: {count}'**
  String commonTotalCount(int count);

  /// No description provided for @commonPageOf.
  ///
  /// In tg, this message translates to:
  /// **'{page} / {pageCount}'**
  String commonPageOf(int page, int pageCount);

  /// No description provided for @commonLoadDataFailed.
  ///
  /// In tg, this message translates to:
  /// **'Маълумотро бор карда нашуд.'**
  String get commonLoadDataFailed;

  /// No description provided for @validationEnterNumber.
  ///
  /// In tg, this message translates to:
  /// **'Рақами дуруст ворид кунед'**
  String get validationEnterNumber;

  /// No description provided for @validationNotNegative.
  ///
  /// In tg, this message translates to:
  /// **'Манфӣ шуда наметавонад'**
  String get validationNotNegative;

  /// No description provided for @failureNetwork.
  ///
  /// In tg, this message translates to:
  /// **'Хатои шабака. Пайвастро санҷед.'**
  String get failureNetwork;

  /// No description provided for @failureAuth.
  ///
  /// In tg, this message translates to:
  /// **'Иҷозат рад шуд. Дубора ворид шавед.'**
  String get failureAuth;

  /// No description provided for @failureUnknown.
  ///
  /// In tg, this message translates to:
  /// **'Хатои номаълум рух дод.'**
  String get failureUnknown;

  /// No description provided for @failureEmptyResponse.
  ///
  /// In tg, this message translates to:
  /// **'Ҷавоби холӣ аз сервер.'**
  String get failureEmptyResponse;

  /// No description provided for @failureServer.
  ///
  /// In tg, this message translates to:
  /// **'Хатои сервер ({status}).'**
  String failureServer(String status);

  /// No description provided for @failureInvalidState.
  ///
  /// In tg, this message translates to:
  /// **'Амалиёт иҷро нашуд (вазъи нодуруст).'**
  String get failureInvalidState;

  /// No description provided for @failureNotFound.
  ///
  /// In tg, this message translates to:
  /// **'Ёфт нашуд.'**
  String get failureNotFound;

  /// No description provided for @navDashboard.
  ///
  /// In tg, this message translates to:
  /// **'Дашборд'**
  String get navDashboard;

  /// No description provided for @navPos.
  ///
  /// In tg, this message translates to:
  /// **'Касса'**
  String get navPos;

  /// No description provided for @navStock.
  ///
  /// In tg, this message translates to:
  /// **'Анбор'**
  String get navStock;

  /// No description provided for @navReceipts.
  ///
  /// In tg, this message translates to:
  /// **'Приход'**
  String get navReceipts;

  /// No description provided for @navWriteOffs.
  ///
  /// In tg, this message translates to:
  /// **'Списание'**
  String get navWriteOffs;

  /// No description provided for @navInventory.
  ///
  /// In tg, this message translates to:
  /// **'Инвентаризатсия'**
  String get navInventory;

  /// No description provided for @navSupplierReturns.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get navSupplierReturns;

  /// No description provided for @navSupplierReturnsLong.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт ба таъминкунанда'**
  String get navSupplierReturnsLong;

  /// No description provided for @navProducts.
  ///
  /// In tg, this message translates to:
  /// **'Доруҳо'**
  String get navProducts;

  /// No description provided for @navDrugGroups.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳҳо'**
  String get navDrugGroups;

  /// No description provided for @navSuppliers.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунандагон'**
  String get navSuppliers;

  /// No description provided for @navManufacturers.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунандагон'**
  String get navManufacturers;

  /// No description provided for @navUnits.
  ///
  /// In tg, this message translates to:
  /// **'Воҳидҳо'**
  String get navUnits;

  /// No description provided for @navReports.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисоботҳо'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In tg, this message translates to:
  /// **'Танзимот'**
  String get navSettings;

  /// No description provided for @navSectionStockOps.
  ///
  /// In tg, this message translates to:
  /// **'АМАЛИЁТИ АНБОР'**
  String get navSectionStockOps;

  /// No description provided for @navSectionReference.
  ///
  /// In tg, this message translates to:
  /// **'МАЪЛУМОТНОМАҲО'**
  String get navSectionReference;

  /// No description provided for @shellThemeLight.
  ///
  /// In tg, this message translates to:
  /// **'Темаи равшан'**
  String get shellThemeLight;

  /// No description provided for @shellThemeDark.
  ///
  /// In tg, this message translates to:
  /// **'Темаи торик'**
  String get shellThemeDark;

  /// No description provided for @shellLanguageTajik.
  ///
  /// In tg, this message translates to:
  /// **'Тоҷикӣ'**
  String get shellLanguageTajik;

  /// No description provided for @shellLanguageRussian.
  ///
  /// In tg, this message translates to:
  /// **'Русӣ'**
  String get shellLanguageRussian;

  /// No description provided for @shellLanguageTajikShort.
  ///
  /// In tg, this message translates to:
  /// **'ТҶ'**
  String get shellLanguageTajikShort;

  /// No description provided for @shellLanguageRussianShort.
  ///
  /// In tg, this message translates to:
  /// **'РУ'**
  String get shellLanguageRussianShort;

  /// No description provided for @shellLanguageTooltip.
  ///
  /// In tg, this message translates to:
  /// **'Забон'**
  String get shellLanguageTooltip;

  /// No description provided for @shellBranchFallback.
  ///
  /// In tg, this message translates to:
  /// **'Филиал'**
  String get shellBranchFallback;

  /// No description provided for @shellShiftOpenAt.
  ///
  /// In tg, this message translates to:
  /// **'Кушода · {time}'**
  String shellShiftOpenAt(String time);

  /// No description provided for @shellShiftClosed.
  ///
  /// In tg, this message translates to:
  /// **'Смена баста'**
  String get shellShiftClosed;

  /// No description provided for @shellOnline.
  ///
  /// In tg, this message translates to:
  /// **'Онлайн'**
  String get shellOnline;

  /// No description provided for @shellOffline.
  ///
  /// In tg, this message translates to:
  /// **'Офлайн'**
  String get shellOffline;

  /// No description provided for @shellQueueSuffix.
  ///
  /// In tg, this message translates to:
  /// **'{base} · {count} навбат'**
  String shellQueueSuffix(String base, int count);

  /// No description provided for @shellServerReachable.
  ///
  /// In tg, this message translates to:
  /// **'Сервер дастрас'**
  String get shellServerReachable;

  /// No description provided for @shellServerUnreachable.
  ///
  /// In tg, this message translates to:
  /// **'Сервер дастнорас'**
  String get shellServerUnreachable;

  /// No description provided for @shellLastOnline.
  ///
  /// In tg, this message translates to:
  /// **'Охирин: {time}'**
  String shellLastOnline(String time);

  /// No description provided for @shellPendingSyncCount.
  ///
  /// In tg, this message translates to:
  /// **'{count} фурӯш дар навбати синхрон'**
  String shellPendingSyncCount(int count);

  /// No description provided for @shellSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ ё фармон…'**
  String get shellSearchHint;

  /// No description provided for @shellUserFallback.
  ///
  /// In tg, this message translates to:
  /// **'Корбар'**
  String get shellUserFallback;

  /// No description provided for @shellLogout.
  ///
  /// In tg, this message translates to:
  /// **'Баромад'**
  String get shellLogout;

  /// No description provided for @commandSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Фармон ё бахшро ҷустуҷӯ кунед…'**
  String get commandSearchHint;

  /// No description provided for @commandNothingFound.
  ///
  /// In tg, this message translates to:
  /// **'Чизе ёфт нашуд'**
  String get commandNothingFound;

  /// No description provided for @commandFooterHint.
  ///
  /// In tg, this message translates to:
  /// **'↑↓ интихоб · Enter кушодан · Esc пӯшидан'**
  String get commandFooterHint;

  /// No description provided for @dashTitle.
  ///
  /// In tg, this message translates to:
  /// **'Дашборд'**
  String get dashTitle;

  /// No description provided for @dashSubtitleToday.
  ///
  /// In tg, this message translates to:
  /// **'Имрӯз, {date}'**
  String dashSubtitleToday(String date);

  /// No description provided for @dashKpiTodaySales.
  ///
  /// In tg, this message translates to:
  /// **'ФУРӮШИ ИМРӮЗ'**
  String get dashKpiTodaySales;

  /// No description provided for @dashKpiReceiptsCount.
  ///
  /// In tg, this message translates to:
  /// **'{count} чек'**
  String dashKpiReceiptsCount(int count);

  /// No description provided for @dashKpiExpiringSoon.
  ///
  /// In tg, this message translates to:
  /// **'МӮҲЛАТАШ НАЗДИК ({days}р)'**
  String dashKpiExpiringSoon(int days);

  /// No description provided for @dashKpiDrugUnit.
  ///
  /// In tg, this message translates to:
  /// **'дору'**
  String get dashKpiDrugUnit;

  /// No description provided for @dashKpiLowStock.
  ///
  /// In tg, this message translates to:
  /// **'КАМШУДА (зери мин.)'**
  String get dashKpiLowStock;

  /// No description provided for @dashKpiShift.
  ///
  /// In tg, this message translates to:
  /// **'СМЕНА'**
  String get dashKpiShift;

  /// No description provided for @dashShiftOpen.
  ///
  /// In tg, this message translates to:
  /// **'Кушода'**
  String get dashShiftOpen;

  /// No description provided for @dashShiftClosed.
  ///
  /// In tg, this message translates to:
  /// **'Баста'**
  String get dashShiftClosed;

  /// No description provided for @dashShiftNotOpen.
  ///
  /// In tg, this message translates to:
  /// **'Смена кушода нашуда'**
  String get dashShiftNotOpen;

  /// No description provided for @dashKpiErrorShort.
  ///
  /// In tg, this message translates to:
  /// **'— хато'**
  String get dashKpiErrorShort;

  /// No description provided for @dashExpiringTitle.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлаташ наздик'**
  String get dashExpiringTitle;

  /// No description provided for @dashSeeAllStock.
  ///
  /// In tg, this message translates to:
  /// **'Ҳамаро дидан → Анбор'**
  String get dashSeeAllStock;

  /// No description provided for @dashNoExpiring.
  ///
  /// In tg, this message translates to:
  /// **'Дорумӯҳлаташ наздик нест.'**
  String get dashNoExpiring;

  /// No description provided for @dashColDrug.
  ///
  /// In tg, this message translates to:
  /// **'Дору'**
  String get dashColDrug;

  /// No description provided for @dashColSeries.
  ///
  /// In tg, this message translates to:
  /// **'Серия'**
  String get dashColSeries;

  /// No description provided for @dashColExpiry.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлат'**
  String get dashColExpiry;

  /// No description provided for @dashColRemaining.
  ///
  /// In tg, this message translates to:
  /// **'Бақия'**
  String get dashColRemaining;

  /// No description provided for @dashLowStockTitle.
  ///
  /// In tg, this message translates to:
  /// **'Камшуда'**
  String get dashLowStockTitle;

  /// No description provided for @dashNoLowStock.
  ///
  /// In tg, this message translates to:
  /// **'Дорумкамшуда нест.'**
  String get dashNoLowStock;

  /// No description provided for @dashQuickActions.
  ///
  /// In tg, this message translates to:
  /// **'Амалҳои зуд'**
  String get dashQuickActions;

  /// No description provided for @dashQuickNewReceipt.
  ///
  /// In tg, this message translates to:
  /// **'Приходи нав'**
  String get dashQuickNewReceipt;

  /// No description provided for @dashQuickCloseShift.
  ///
  /// In tg, this message translates to:
  /// **'Бастани смена'**
  String get dashQuickCloseShift;

  /// No description provided for @dashQuickOpenShift.
  ///
  /// In tg, this message translates to:
  /// **'Кушодани смена'**
  String get dashQuickOpenShift;

  /// No description provided for @dashQuickSale.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш'**
  String get dashQuickSale;

  /// No description provided for @dashQuickSearchDrug.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯи дору'**
  String get dashQuickSearchDrug;

  /// No description provided for @dashSalesTrendTitle.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш — 7 рӯзи охир'**
  String get dashSalesTrendTitle;

  /// No description provided for @dashNoSalesTrend.
  ///
  /// In tg, this message translates to:
  /// **'Дар 7 рӯзи охир фурӯш сабт нашудааст.'**
  String get dashNoSalesTrend;

  /// No description provided for @dashExpiryGone.
  ///
  /// In tg, this message translates to:
  /// **'гузашта'**
  String get dashExpiryGone;

  /// No description provided for @dashExpiryDays.
  ///
  /// In tg, this message translates to:
  /// **'{days}р'**
  String dashExpiryDays(int days);

  /// No description provided for @dowMon.
  ///
  /// In tg, this message translates to:
  /// **'Дш'**
  String get dowMon;

  /// No description provided for @dowTue.
  ///
  /// In tg, this message translates to:
  /// **'Сш'**
  String get dowTue;

  /// No description provided for @dowWed.
  ///
  /// In tg, this message translates to:
  /// **'Чш'**
  String get dowWed;

  /// No description provided for @dowThu.
  ///
  /// In tg, this message translates to:
  /// **'Пш'**
  String get dowThu;

  /// No description provided for @dowFri.
  ///
  /// In tg, this message translates to:
  /// **'Ҷм'**
  String get dowFri;

  /// No description provided for @dowSat.
  ///
  /// In tg, this message translates to:
  /// **'Шб'**
  String get dowSat;

  /// No description provided for @dowSun.
  ///
  /// In tg, this message translates to:
  /// **'Яш'**
  String get dowSun;

  /// No description provided for @posCartEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Сабад холӣ аст'**
  String get posCartEmpty;

  /// No description provided for @posRxTitle.
  ///
  /// In tg, this message translates to:
  /// **'Доруи ретсептӣ'**
  String get posRxTitle;

  /// No description provided for @posRxTooltip.
  ///
  /// In tg, this message translates to:
  /// **'Доруи ретсептӣ'**
  String get posRxTooltip;

  /// No description provided for @posRxBody.
  ///
  /// In tg, this message translates to:
  /// **'«{name}» доруи ретсептӣ (℞) аст. Илова кардан ба сабадро тасдиқ мекунед?'**
  String posRxBody(String name);

  /// No description provided for @posOfflineSaleQueued.
  ///
  /// In tg, this message translates to:
  /// **'Офлайн: фурӯш дар навбати синхрон сабт шуд (чоп шуд).'**
  String get posOfflineSaleQueued;

  /// No description provided for @posCartEmptyHint.
  ///
  /// In tg, this message translates to:
  /// **'Сабад холӣ. Штрих-кодро скан кунед ё ҷустуҷӯ кунед.'**
  String get posCartEmptyHint;

  /// No description provided for @posColDrug.
  ///
  /// In tg, this message translates to:
  /// **'Дору'**
  String get posColDrug;

  /// No description provided for @posColQty.
  ///
  /// In tg, this message translates to:
  /// **'Миқдор'**
  String get posColQty;

  /// No description provided for @posColPrice.
  ///
  /// In tg, this message translates to:
  /// **'Нарх'**
  String get posColPrice;

  /// No description provided for @posColSum.
  ///
  /// In tg, this message translates to:
  /// **'Ҷамъ'**
  String get posColSum;

  /// No description provided for @posRemove.
  ///
  /// In tg, this message translates to:
  /// **'Ҳазф'**
  String get posRemove;

  /// No description provided for @posShiftOpen.
  ///
  /// In tg, this message translates to:
  /// **'Смена кушода'**
  String get posShiftOpen;

  /// No description provided for @posShiftOpenedAt.
  ///
  /// In tg, this message translates to:
  /// **'Кушода шуд: {time}'**
  String posShiftOpenedAt(String time);

  /// No description provided for @posShiftSales.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯши смена: {amount}'**
  String posShiftSales(String amount);

  /// No description provided for @posReturnsTooltip.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашти фурӯш (F7)'**
  String get posReturnsTooltip;

  /// No description provided for @posCloseShiftTooltip.
  ///
  /// In tg, this message translates to:
  /// **'Бастани смена (F10)'**
  String get posCloseShiftTooltip;

  /// No description provided for @posScanHint.
  ///
  /// In tg, this message translates to:
  /// **'Штрих-кодро скан кунед ё ном ворид кунед…  (F2)'**
  String get posScanHint;

  /// No description provided for @posQtyDecrease.
  ///
  /// In tg, this message translates to:
  /// **'Кам'**
  String get posQtyDecrease;

  /// No description provided for @posQtyIncrease.
  ///
  /// In tg, this message translates to:
  /// **'Зиёд'**
  String get posQtyIncrease;

  /// No description provided for @posCheck.
  ///
  /// In tg, this message translates to:
  /// **'ҲИСОБ'**
  String get posCheck;

  /// No description provided for @posSubtotal.
  ///
  /// In tg, this message translates to:
  /// **'Зерҷамъ'**
  String get posSubtotal;

  /// No description provided for @posDiscountField.
  ///
  /// In tg, this message translates to:
  /// **'Тахфиф (F4)'**
  String get posDiscountField;

  /// No description provided for @posTotalAll.
  ///
  /// In tg, this message translates to:
  /// **'ҲАМАГӢ'**
  String get posTotalAll;

  /// No description provided for @posPaymentMethod.
  ///
  /// In tg, this message translates to:
  /// **'Тарзи пардохт'**
  String get posPaymentMethod;

  /// No description provided for @posMethodCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақд'**
  String get posMethodCash;

  /// No description provided for @posMethodCard.
  ///
  /// In tg, this message translates to:
  /// **'Корт'**
  String get posMethodCard;

  /// No description provided for @posMethodCredit.
  ///
  /// In tg, this message translates to:
  /// **'Қарз'**
  String get posMethodCredit;

  /// No description provided for @posPay.
  ///
  /// In tg, this message translates to:
  /// **'Пардохт (F9)'**
  String get posPay;

  /// No description provided for @posHintSearch.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ'**
  String get posHintSearch;

  /// No description provided for @posHintDiscount.
  ///
  /// In tg, this message translates to:
  /// **'Тахфиф'**
  String get posHintDiscount;

  /// No description provided for @posHintPay.
  ///
  /// In tg, this message translates to:
  /// **'Пардохт'**
  String get posHintPay;

  /// No description provided for @posHintRemove.
  ///
  /// In tg, this message translates to:
  /// **'Ҳазф'**
  String get posHintRemove;

  /// No description provided for @posHintQty.
  ///
  /// In tg, this message translates to:
  /// **'Миқдор'**
  String get posHintQty;

  /// No description provided for @posHintReturn.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get posHintReturn;

  /// No description provided for @posHintCloseShift.
  ///
  /// In tg, this message translates to:
  /// **'Бастани смена'**
  String get posHintCloseShift;

  /// No description provided for @posNoShiftTitle.
  ///
  /// In tg, this message translates to:
  /// **'Смена кушода нашудааст'**
  String get posNoShiftTitle;

  /// No description provided for @posNoShiftBody.
  ///
  /// In tg, this message translates to:
  /// **'Барои оғози фурӯш сменаро кушоед.'**
  String get posNoShiftBody;

  /// No description provided for @posOpenShift.
  ///
  /// In tg, this message translates to:
  /// **'Кушодани смена'**
  String get posOpenShift;

  /// No description provided for @posOpeningCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди ибтидоӣ *'**
  String get posOpeningCash;

  /// No description provided for @posDiscountTitle.
  ///
  /// In tg, this message translates to:
  /// **'Тахфиф'**
  String get posDiscountTitle;

  /// No description provided for @posDiscountAmount.
  ///
  /// In tg, this message translates to:
  /// **'Маблағи тахфиф'**
  String get posDiscountAmount;

  /// No description provided for @stockTitle.
  ///
  /// In tg, this message translates to:
  /// **'Анбор'**
  String get stockTitle;

  /// No description provided for @stockUnitItems.
  ///
  /// In tg, this message translates to:
  /// **'ададҳо'**
  String get stockUnitItems;

  /// No description provided for @stockUnitExpiring.
  ///
  /// In tg, this message translates to:
  /// **'мӯҳлаташ наздик'**
  String get stockUnitExpiring;

  /// No description provided for @stockUnitLow.
  ///
  /// In tg, this message translates to:
  /// **'камшуда'**
  String get stockUnitLow;

  /// No description provided for @stockTabOnHand.
  ///
  /// In tg, this message translates to:
  /// **'Бақия'**
  String get stockTabOnHand;

  /// No description provided for @stockTabExpiring.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлати наздик'**
  String get stockTabExpiring;

  /// No description provided for @stockTabLow.
  ///
  /// In tg, this message translates to:
  /// **'Камшуда'**
  String get stockTabLow;

  /// No description provided for @stockEmptyOnHand.
  ///
  /// In tg, this message translates to:
  /// **'Бақия нест'**
  String get stockEmptyOnHand;

  /// No description provided for @stockColName.
  ///
  /// In tg, this message translates to:
  /// **'Ном'**
  String get stockColName;

  /// No description provided for @stockColBarcode.
  ///
  /// In tg, this message translates to:
  /// **'Штрих-код'**
  String get stockColBarcode;

  /// No description provided for @stockColSeries.
  ///
  /// In tg, this message translates to:
  /// **'Серия'**
  String get stockColSeries;

  /// No description provided for @stockColExpiry.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлат'**
  String get stockColExpiry;

  /// No description provided for @stockColRemaining.
  ///
  /// In tg, this message translates to:
  /// **'Бақия'**
  String get stockColRemaining;

  /// No description provided for @stockColPrice.
  ///
  /// In tg, this message translates to:
  /// **'Нарх'**
  String get stockColPrice;

  /// No description provided for @stockExpiryLabel.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлат:'**
  String get stockExpiryLabel;

  /// No description provided for @stockDaysOption.
  ///
  /// In tg, this message translates to:
  /// **'{days} рӯз'**
  String stockDaysOption(int days);

  /// No description provided for @stockEmptyExpiring.
  ///
  /// In tg, this message translates to:
  /// **'Доруи мӯҳлаташ наздик нест'**
  String get stockEmptyExpiring;

  /// No description provided for @stockColRemainingDays.
  ///
  /// In tg, this message translates to:
  /// **'Боқимонда (рӯз)'**
  String get stockColRemainingDays;

  /// No description provided for @stockEmptyLow.
  ///
  /// In tg, this message translates to:
  /// **'Доруи камшуда нест'**
  String get stockEmptyLow;

  /// No description provided for @stockColTotalRemaining.
  ///
  /// In tg, this message translates to:
  /// **'Бақияи ҷамъ'**
  String get stockColTotalRemaining;

  /// No description provided for @stockColMinimum.
  ///
  /// In tg, this message translates to:
  /// **'Минимум'**
  String get stockColMinimum;

  /// No description provided for @stockColShortfall.
  ///
  /// In tg, this message translates to:
  /// **'Норасоӣ'**
  String get stockColShortfall;

  /// No description provided for @stockSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ (ном ё штрих-код)…'**
  String get stockSearchHint;

  /// No description provided for @stockExpired.
  ///
  /// In tg, this message translates to:
  /// **'Гузашта'**
  String get stockExpired;

  /// No description provided for @stockExpiryDaysShort.
  ///
  /// In tg, this message translates to:
  /// **'{days} р'**
  String stockExpiryDaysShort(int days);

  /// No description provided for @stockLegendNear.
  ///
  /// In tg, this message translates to:
  /// **'≤30 рӯз'**
  String get stockLegendNear;

  /// No description provided for @stockLegendSoon.
  ///
  /// In tg, this message translates to:
  /// **'≤90 рӯз'**
  String get stockLegendSoon;

  /// No description provided for @reportsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисоботҳо'**
  String get reportsTitle;

  /// No description provided for @reportViewSales.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш'**
  String get reportViewSales;

  /// No description provided for @reportViewProfit.
  ///
  /// In tg, this message translates to:
  /// **'Фоида'**
  String get reportViewProfit;

  /// No description provided for @reportViewStockValue.
  ///
  /// In tg, this message translates to:
  /// **'Арзиши анбор'**
  String get reportViewStockValue;

  /// No description provided for @reportViewExpiring.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлаташ наздик'**
  String get reportViewExpiring;

  /// No description provided for @reportViewZReport.
  ///
  /// In tg, this message translates to:
  /// **'Z-ҳисобот'**
  String get reportViewZReport;

  /// No description provided for @reportGroupByDay.
  ///
  /// In tg, this message translates to:
  /// **'Аз рӯи рӯз'**
  String get reportGroupByDay;

  /// No description provided for @reportGroupByProduct.
  ///
  /// In tg, this message translates to:
  /// **'Аз рӯи дору'**
  String get reportGroupByProduct;

  /// No description provided for @reportGroupBySeller.
  ///
  /// In tg, this message translates to:
  /// **'Аз рӯи фурӯшанда'**
  String get reportGroupBySeller;

  /// No description provided for @reportsNoExportData.
  ///
  /// In tg, this message translates to:
  /// **'Барои содирот маълумот нест.'**
  String get reportsNoExportData;

  /// No description provided for @reportsCsvSaved.
  ///
  /// In tg, this message translates to:
  /// **'CSV нигоҳ дошта шуд: {path}'**
  String reportsCsvSaved(String path);

  /// No description provided for @reportsExportFailed.
  ///
  /// In tg, this message translates to:
  /// **'Содирот ноком шуд: {error}'**
  String reportsExportFailed(String error);

  /// No description provided for @reportsTitleSales.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисоботи фурӯш ({groupBy})'**
  String reportsTitleSales(String groupBy);

  /// No description provided for @reportColGroup.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ'**
  String get reportColGroup;

  /// No description provided for @reportColReceipt.
  ///
  /// In tg, this message translates to:
  /// **'Чек'**
  String get reportColReceipt;

  /// No description provided for @reportColQty.
  ///
  /// In tg, this message translates to:
  /// **'Миқдор'**
  String get reportColQty;

  /// No description provided for @reportColSubtotal.
  ///
  /// In tg, this message translates to:
  /// **'Зерҷамъ'**
  String get reportColSubtotal;

  /// No description provided for @reportColDiscount.
  ///
  /// In tg, this message translates to:
  /// **'Тахфиф'**
  String get reportColDiscount;

  /// No description provided for @reportColTotal.
  ///
  /// In tg, this message translates to:
  /// **'Ҳамагӣ'**
  String get reportColTotal;

  /// No description provided for @reportsTitleProfit.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисоботи фоида'**
  String get reportsTitleProfit;

  /// No description provided for @reportColMetric.
  ///
  /// In tg, this message translates to:
  /// **'Нишондиҳанда'**
  String get reportColMetric;

  /// No description provided for @reportColAmount.
  ///
  /// In tg, this message translates to:
  /// **'Маблағ'**
  String get reportColAmount;

  /// No description provided for @reportRevenue.
  ///
  /// In tg, this message translates to:
  /// **'Даромад'**
  String get reportRevenue;

  /// No description provided for @reportCost.
  ///
  /// In tg, this message translates to:
  /// **'Арзиши аслӣ'**
  String get reportCost;

  /// No description provided for @reportProfit.
  ///
  /// In tg, this message translates to:
  /// **'Фоида'**
  String get reportProfit;

  /// No description provided for @reportMargin.
  ///
  /// In tg, this message translates to:
  /// **'Маржа'**
  String get reportMargin;

  /// No description provided for @reportsTitleStockValue.
  ///
  /// In tg, this message translates to:
  /// **'Арзиши анбор'**
  String get reportsTitleStockValue;

  /// No description provided for @reportColDrug.
  ///
  /// In tg, this message translates to:
  /// **'Дору'**
  String get reportColDrug;

  /// No description provided for @reportColPurchaseValue.
  ///
  /// In tg, this message translates to:
  /// **'Арзиши харид'**
  String get reportColPurchaseValue;

  /// No description provided for @reportColSaleValue.
  ///
  /// In tg, this message translates to:
  /// **'Арзиши фурӯш'**
  String get reportColSaleValue;

  /// No description provided for @reportsTitleExpiring.
  ///
  /// In tg, this message translates to:
  /// **'Доруҳои мӯҳлаташ наздик'**
  String get reportsTitleExpiring;

  /// No description provided for @reportColSeries.
  ///
  /// In tg, this message translates to:
  /// **'Серия'**
  String get reportColSeries;

  /// No description provided for @reportColExpiry.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлат'**
  String get reportColExpiry;

  /// No description provided for @reportColDays.
  ///
  /// In tg, this message translates to:
  /// **'Рӯз'**
  String get reportColDays;

  /// No description provided for @reportColRemaining.
  ///
  /// In tg, this message translates to:
  /// **'Бақия'**
  String get reportColRemaining;

  /// No description provided for @reportsTitleZReport.
  ///
  /// In tg, this message translates to:
  /// **'Z-ҳисобот · {shiftId}'**
  String reportsTitleZReport(String shiftId);

  /// No description provided for @reportZOpened.
  ///
  /// In tg, this message translates to:
  /// **'Кушодашуда'**
  String get reportZOpened;

  /// No description provided for @reportZClosed.
  ///
  /// In tg, this message translates to:
  /// **'Басташуда'**
  String get reportZClosed;

  /// No description provided for @reportZOpeningCash.
  ///
  /// In tg, this message translates to:
  /// **'Маблағи аввал'**
  String get reportZOpeningCash;

  /// No description provided for @reportZSalesCount.
  ///
  /// In tg, this message translates to:
  /// **'Шумораи фурӯш'**
  String get reportZSalesCount;

  /// No description provided for @reportZTotalSales.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯши умумӣ'**
  String get reportZTotalSales;

  /// No description provided for @reportZReturns.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get reportZReturns;

  /// No description provided for @reportZNet.
  ///
  /// In tg, this message translates to:
  /// **'Софӣ'**
  String get reportZNet;

  /// No description provided for @reportZCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақд'**
  String get reportZCash;

  /// No description provided for @reportZCard.
  ///
  /// In tg, this message translates to:
  /// **'Корт'**
  String get reportZCard;

  /// No description provided for @reportZCredit.
  ///
  /// In tg, this message translates to:
  /// **'Қарз'**
  String get reportZCredit;

  /// No description provided for @reportZExpectedCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди интизорӣ'**
  String get reportZExpectedCash;

  /// No description provided for @reportZActualCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди ҳақиқӣ'**
  String get reportZActualCash;

  /// No description provided for @reportDateFrom.
  ///
  /// In tg, this message translates to:
  /// **'Аз'**
  String get reportDateFrom;

  /// No description provided for @reportDateTo.
  ///
  /// In tg, this message translates to:
  /// **'То'**
  String get reportDateTo;

  /// No description provided for @reportPresetToday.
  ///
  /// In tg, this message translates to:
  /// **'Имрӯз'**
  String get reportPresetToday;

  /// No description provided for @reportPreset7Days.
  ///
  /// In tg, this message translates to:
  /// **'7 рӯз'**
  String get reportPreset7Days;

  /// No description provided for @reportPresetThisMonth.
  ///
  /// In tg, this message translates to:
  /// **'Ин моҳ'**
  String get reportPresetThisMonth;

  /// No description provided for @reportNoChartData.
  ///
  /// In tg, this message translates to:
  /// **'Барои график маълумот нест'**
  String get reportNoChartData;

  /// No description provided for @reportPositive.
  ///
  /// In tg, this message translates to:
  /// **'Мусбат'**
  String get reportPositive;

  /// No description provided for @reportNegative.
  ///
  /// In tg, this message translates to:
  /// **'Манфӣ'**
  String get reportNegative;

  /// No description provided for @reportShiftIdField.
  ///
  /// In tg, this message translates to:
  /// **'ID-и смена'**
  String get reportShiftIdField;

  /// No description provided for @reportEnterShiftId.
  ///
  /// In tg, this message translates to:
  /// **'ID-и смена ворид кунед.'**
  String get reportEnterShiftId;

  /// No description provided for @settingsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Танзимот'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Намуд · сервер · огоҳӣ · нарх · принтер · корбар'**
  String get settingsSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In tg, this message translates to:
  /// **'Намуди намоиш'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In tg, this message translates to:
  /// **'Намуди тема:'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In tg, this message translates to:
  /// **'Системавӣ'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tg, this message translates to:
  /// **'Равшан'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tg, this message translates to:
  /// **'Торик'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeHint.
  ///
  /// In tg, this message translates to:
  /// **'«Системавӣ» аз танзими Windows пайравӣ мекунад. Интихоб нигоҳ дошта мешавад.'**
  String get settingsThemeHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In tg, this message translates to:
  /// **'Забон'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In tg, this message translates to:
  /// **'Забони барнома:'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageTajik.
  ///
  /// In tg, this message translates to:
  /// **'Тоҷикӣ'**
  String get settingsLanguageTajik;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In tg, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In tg, this message translates to:
  /// **'Интихоб нигоҳ дошта мешавад ва ба тамоми барнома татбиқ мегардад.'**
  String get settingsLanguageHint;

  /// No description provided for @settingsServer.
  ///
  /// In tg, this message translates to:
  /// **'Сервер'**
  String get settingsServer;

  /// No description provided for @settingsServerCurrentUrl.
  ///
  /// In tg, this message translates to:
  /// **'URL-и ҷорӣ: '**
  String get settingsServerCurrentUrl;

  /// No description provided for @settingsServerField.
  ///
  /// In tg, this message translates to:
  /// **'Суроғаи сервер (scheme://host:port/api/v1)'**
  String get settingsServerField;

  /// No description provided for @settingsServerLocked.
  ///
  /// In tg, this message translates to:
  /// **'Аз --dart-define муайян шуда — таҳрир мумкин нест.'**
  String get settingsServerLocked;

  /// No description provided for @settingsServerExample.
  ///
  /// In tg, this message translates to:
  /// **'Мисол: http://192.168.1.10:5000/api/v1'**
  String get settingsServerExample;

  /// No description provided for @settingsTestConnection.
  ///
  /// In tg, this message translates to:
  /// **'Санҷиши пайваст'**
  String get settingsTestConnection;

  /// No description provided for @settingsConnected.
  ///
  /// In tg, this message translates to:
  /// **'Пайваст шуд'**
  String get settingsConnected;

  /// No description provided for @settingsNotConnected.
  ///
  /// In tg, this message translates to:
  /// **'Пайваст нашуд'**
  String get settingsNotConnected;

  /// No description provided for @settingsInvalidUrl.
  ///
  /// In tg, this message translates to:
  /// **'Суроғаи нодуруст. http(s)://host… ворид кунед.'**
  String get settingsInvalidUrl;

  /// No description provided for @settingsUrlSaved.
  ///
  /// In tg, this message translates to:
  /// **'Суроғаи сервер нигоҳ дошта шуд.'**
  String get settingsUrlSaved;

  /// No description provided for @settingsUrlReset.
  ///
  /// In tg, this message translates to:
  /// **'Ба суроғаи пешфарз баргардонида шуд.'**
  String get settingsUrlReset;

  /// No description provided for @settingsAlert.
  ///
  /// In tg, this message translates to:
  /// **'Огоҳӣ'**
  String get settingsAlert;

  /// No description provided for @settingsAlertHorizon.
  ///
  /// In tg, this message translates to:
  /// **'Уфуқи огоҳии мӯҳлат (рӯз):'**
  String get settingsAlertHorizon;

  /// No description provided for @settingsAlertDays.
  ///
  /// In tg, this message translates to:
  /// **'{days} рӯз'**
  String settingsAlertDays(int days);

  /// No description provided for @settingsMarkup.
  ///
  /// In tg, this message translates to:
  /// **'Нарх'**
  String get settingsMarkup;

  /// No description provided for @settingsMarkupLabel.
  ///
  /// In tg, this message translates to:
  /// **'Наценкаи пешфарз (барои модули нархгузорӣ):'**
  String get settingsMarkupLabel;

  /// No description provided for @settingsMarkupField.
  ///
  /// In tg, this message translates to:
  /// **'Наценка %'**
  String get settingsMarkupField;

  /// No description provided for @settingsMarkupSaved.
  ///
  /// In tg, this message translates to:
  /// **'Наценка нигоҳ дошта шуд.'**
  String get settingsMarkupSaved;

  /// No description provided for @settingsMarkupHint.
  ///
  /// In tg, this message translates to:
  /// **'Эзоҳ: дар сервер нигоҳ дошта мешавад ва ҳамчун наценкаи пешфарзи нархи фурӯш ҳангоми приход истифода мешавад.'**
  String get settingsMarkupHint;

  /// No description provided for @settingsPrinter.
  ///
  /// In tg, this message translates to:
  /// **'Принтер'**
  String get settingsPrinter;

  /// No description provided for @settingsPrinterHint.
  ///
  /// In tg, this message translates to:
  /// **'Чопи чек тавассути диалоги системавии чоп (printing). Интихоби принтери пешфарз дар нусхаи минбаъда илова мешавад.'**
  String get settingsPrinterHint;

  /// No description provided for @settingsSystem.
  ///
  /// In tg, this message translates to:
  /// **'Системавӣ'**
  String get settingsSystem;

  /// No description provided for @settingsUser.
  ///
  /// In tg, this message translates to:
  /// **'Корбар'**
  String get settingsUser;

  /// No description provided for @settingsLogout.
  ///
  /// In tg, this message translates to:
  /// **'Баромадан'**
  String get settingsLogout;

  /// No description provided for @settingsUsers.
  ///
  /// In tg, this message translates to:
  /// **'Корбарон'**
  String get settingsUsers;

  /// No description provided for @settingsUserAdded.
  ///
  /// In tg, this message translates to:
  /// **'Корбар илова шуд.'**
  String get settingsUserAdded;

  /// No description provided for @settingsUserUpdated.
  ///
  /// In tg, this message translates to:
  /// **'Корбар таҳрир шуд.'**
  String get settingsUserUpdated;

  /// No description provided for @settingsDeactivateTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ғайрифаъол кардан'**
  String get settingsDeactivateTitle;

  /// No description provided for @settingsDeactivateBody.
  ///
  /// In tg, this message translates to:
  /// **'«{name}»-ро ғайрифаъол мекунед?'**
  String settingsDeactivateBody(String name);

  /// No description provided for @settingsUserDeactivated.
  ///
  /// In tg, this message translates to:
  /// **'Корбар ғайрифаъол шуд.'**
  String get settingsUserDeactivated;

  /// No description provided for @settingsNewUser.
  ///
  /// In tg, this message translates to:
  /// **'Корбари нав'**
  String get settingsNewUser;

  /// No description provided for @settingsNoUsers.
  ///
  /// In tg, this message translates to:
  /// **'Корбар нест'**
  String get settingsNoUsers;

  /// No description provided for @settingsEditTooltip.
  ///
  /// In tg, this message translates to:
  /// **'Таҳрир'**
  String get settingsEditTooltip;

  /// No description provided for @settingsDeactivateTooltip.
  ///
  /// In tg, this message translates to:
  /// **'Ғайрифаъол'**
  String get settingsDeactivateTooltip;

  /// No description provided for @settingsEditUser.
  ///
  /// In tg, this message translates to:
  /// **'Таҳрири корбар'**
  String get settingsEditUser;

  /// No description provided for @settingsFullName.
  ///
  /// In tg, this message translates to:
  /// **'Ному насаб *'**
  String get settingsFullName;

  /// No description provided for @settingsUserName.
  ///
  /// In tg, this message translates to:
  /// **'Номи корбар (login) *'**
  String get settingsUserName;

  /// No description provided for @settingsPassword.
  ///
  /// In tg, this message translates to:
  /// **'Парол *'**
  String get settingsPassword;

  /// No description provided for @settingsPasswordMin.
  ///
  /// In tg, this message translates to:
  /// **'Камаш 4 аломат'**
  String get settingsPasswordMin;

  /// No description provided for @settingsRole.
  ///
  /// In tg, this message translates to:
  /// **'Нақш *'**
  String get settingsRole;

  /// No description provided for @settingsAbout.
  ///
  /// In tg, this message translates to:
  /// **'Дар бораи'**
  String get settingsAbout;

  /// No description provided for @settingsAboutText.
  ///
  /// In tg, this message translates to:
  /// **'Дорухона — Касса/Анбор · v1.0.0'**
  String get settingsAboutText;

  /// No description provided for @loginTitle.
  ///
  /// In tg, this message translates to:
  /// **'Дорухона — Касса'**
  String get loginTitle;

  /// No description provided for @loginUsername.
  ///
  /// In tg, this message translates to:
  /// **'Логин'**
  String get loginUsername;

  /// No description provided for @loginUsernameRequired.
  ///
  /// In tg, this message translates to:
  /// **'Логинро ворид кунед'**
  String get loginUsernameRequired;

  /// No description provided for @loginPassword.
  ///
  /// In tg, this message translates to:
  /// **'Парол'**
  String get loginPassword;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In tg, this message translates to:
  /// **'Паролро ворид кунед'**
  String get loginPasswordRequired;

  /// No description provided for @loginSubmit.
  ///
  /// In tg, this message translates to:
  /// **'Воридшавӣ'**
  String get loginSubmit;

  /// No description provided for @receiptsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Приход'**
  String get receiptsTitle;

  /// No description provided for @receiptsRefresh.
  ///
  /// In tg, this message translates to:
  /// **'Навсозӣ'**
  String get receiptsRefresh;

  /// No description provided for @receiptsNew.
  ///
  /// In tg, this message translates to:
  /// **'Приход нав'**
  String get receiptsNew;

  /// No description provided for @receiptsEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Приход ёфт нашуд'**
  String get receiptsEmpty;

  /// No description provided for @receiptColNumber.
  ///
  /// In tg, this message translates to:
  /// **'№'**
  String get receiptColNumber;

  /// No description provided for @receiptColDate.
  ///
  /// In tg, this message translates to:
  /// **'Сана'**
  String get receiptColDate;

  /// No description provided for @receiptColSupplier.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда'**
  String get receiptColSupplier;

  /// No description provided for @receiptColStatus.
  ///
  /// In tg, this message translates to:
  /// **'Статус'**
  String get receiptColStatus;

  /// No description provided for @receiptColTotal.
  ///
  /// In tg, this message translates to:
  /// **'Ҷамъ'**
  String get receiptColTotal;

  /// No description provided for @receiptFilterAll.
  ///
  /// In tg, this message translates to:
  /// **'Ҳама'**
  String get receiptFilterAll;

  /// No description provided for @receiptDateFilter.
  ///
  /// In tg, this message translates to:
  /// **'Сана'**
  String get receiptDateFilter;

  /// No description provided for @receiptClearDate.
  ///
  /// In tg, this message translates to:
  /// **'Санаро тоза кардан'**
  String get receiptClearDate;

  /// No description provided for @receiptStatusDraft.
  ///
  /// In tg, this message translates to:
  /// **'Лоиҳа'**
  String get receiptStatusDraft;

  /// No description provided for @receiptStatusPosted.
  ///
  /// In tg, this message translates to:
  /// **'Тасдиқшуда'**
  String get receiptStatusPosted;

  /// No description provided for @receiptStatusCancelled.
  ///
  /// In tg, this message translates to:
  /// **'Бекоршуда'**
  String get receiptStatusCancelled;

  /// No description provided for @receiptPageOf.
  ///
  /// In tg, this message translates to:
  /// **'Саҳ. {page} аз {pageCount}'**
  String receiptPageOf(int page, int pageCount);

  /// No description provided for @receiptEditTitle.
  ///
  /// In tg, this message translates to:
  /// **'Приход {number}'**
  String receiptEditTitle(String number);

  /// No description provided for @receiptNewTitle.
  ///
  /// In tg, this message translates to:
  /// **'Приход нав'**
  String get receiptNewTitle;

  /// No description provided for @receiptValSupplier.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунандаро интихоб кунед'**
  String get receiptValSupplier;

  /// No description provided for @receiptValBranch.
  ///
  /// In tg, this message translates to:
  /// **'Филиалро ворид кунед'**
  String get receiptValBranch;

  /// No description provided for @receiptValAtLeastOneLine.
  ///
  /// In tg, this message translates to:
  /// **'Ҳадди ақал як сатр илова кунед'**
  String get receiptValAtLeastOneLine;

  /// No description provided for @receiptValLine.
  ///
  /// In tg, this message translates to:
  /// **'Сатри {index}: {problem}'**
  String receiptValLine(int index, String problem);

  /// No description provided for @receiptSavedDraft.
  ///
  /// In tg, this message translates to:
  /// **'Приход ҳамчун лоиҳа нигоҳ дошта шуд'**
  String get receiptSavedDraft;

  /// No description provided for @receiptSaveFirst.
  ///
  /// In tg, this message translates to:
  /// **'Аввал приходро нигоҳ доред'**
  String get receiptSaveFirst;

  /// No description provided for @receiptPostTitle.
  ///
  /// In tg, this message translates to:
  /// **'Тасдиқи приход'**
  String get receiptPostTitle;

  /// No description provided for @receiptPostBody.
  ///
  /// In tg, this message translates to:
  /// **'Приход тасдиқ карда шавад? Баъди тасдиқ бақия нав мешавад.'**
  String get receiptPostBody;

  /// No description provided for @receiptPosted.
  ///
  /// In tg, this message translates to:
  /// **'Приход тасдиқ шуд'**
  String get receiptPosted;

  /// No description provided for @receiptCancelTitle.
  ///
  /// In tg, this message translates to:
  /// **'Бекор кардани приход'**
  String get receiptCancelTitle;

  /// No description provided for @receiptCancelBody.
  ///
  /// In tg, this message translates to:
  /// **'Приход бекор карда шавад?'**
  String get receiptCancelBody;

  /// No description provided for @receiptCancelConfirm.
  ///
  /// In tg, this message translates to:
  /// **'Бекор кардан'**
  String get receiptCancelConfirm;

  /// No description provided for @receiptCancelled.
  ///
  /// In tg, this message translates to:
  /// **'Приход бекор шуд'**
  String get receiptCancelled;

  /// No description provided for @receiptLinesCount.
  ///
  /// In tg, this message translates to:
  /// **'Сатрҳо ({count})'**
  String receiptLinesCount(int count);

  /// No description provided for @receiptAddLine.
  ///
  /// In tg, this message translates to:
  /// **'Илова сатр / скан штрих-код'**
  String get receiptAddLine;

  /// No description provided for @receiptNoLinesEditable.
  ///
  /// In tg, this message translates to:
  /// **'Сатр нест. «Илова сатр»-ро пахш кунед ё штрих-код скан кунед.'**
  String get receiptNoLinesEditable;

  /// No description provided for @receiptNoLinesReadonly.
  ///
  /// In tg, this message translates to:
  /// **'Дар ин приход сатр нест.'**
  String get receiptNoLinesReadonly;

  /// No description provided for @receiptColDrug.
  ///
  /// In tg, this message translates to:
  /// **'Дору'**
  String get receiptColDrug;

  /// No description provided for @receiptColQty.
  ///
  /// In tg, this message translates to:
  /// **'Миқдор'**
  String get receiptColQty;

  /// No description provided for @receiptColSeries.
  ///
  /// In tg, this message translates to:
  /// **'Серия'**
  String get receiptColSeries;

  /// No description provided for @receiptColExpiry.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлат'**
  String get receiptColExpiry;

  /// No description provided for @receiptColPurchasePrice.
  ///
  /// In tg, this message translates to:
  /// **'Нархи харид'**
  String get receiptColPurchasePrice;

  /// No description provided for @receiptColSalePrice.
  ///
  /// In tg, this message translates to:
  /// **'Нархи фурӯш'**
  String get receiptColSalePrice;

  /// No description provided for @receiptColLineTotal.
  ///
  /// In tg, this message translates to:
  /// **'Ҷамъ'**
  String get receiptColLineTotal;

  /// No description provided for @receiptDeleteLine.
  ///
  /// In tg, this message translates to:
  /// **'Ҳазфи сатр'**
  String get receiptDeleteLine;

  /// No description provided for @receiptValQty.
  ///
  /// In tg, this message translates to:
  /// **'миқдори дуруст ворид кунед'**
  String get receiptValQty;

  /// No description provided for @receiptValSeries.
  ///
  /// In tg, this message translates to:
  /// **'серияро ворид кунед'**
  String get receiptValSeries;

  /// No description provided for @receiptValPurchasePrice.
  ///
  /// In tg, this message translates to:
  /// **'нархи харидро ворид кунед'**
  String get receiptValPurchasePrice;

  /// No description provided for @receiptValSalePrice.
  ///
  /// In tg, this message translates to:
  /// **'нархи фурӯшро ворид кунед'**
  String get receiptValSalePrice;

  /// No description provided for @receiptSupplier.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда'**
  String get receiptSupplier;

  /// No description provided for @receiptBranch.
  ///
  /// In tg, this message translates to:
  /// **'Филиал *'**
  String get receiptBranch;

  /// No description provided for @receiptNumber.
  ///
  /// In tg, this message translates to:
  /// **'Рақам'**
  String get receiptNumber;

  /// No description provided for @receiptNumberNew.
  ///
  /// In tg, this message translates to:
  /// **'— нав —'**
  String get receiptNumberNew;

  /// No description provided for @receiptPurchaseTotal.
  ///
  /// In tg, this message translates to:
  /// **'Ҷамъи харид: {amount}'**
  String receiptPurchaseTotal(String amount);

  /// No description provided for @receiptLinesLabel.
  ///
  /// In tg, this message translates to:
  /// **'Сатрҳо: {count}'**
  String receiptLinesLabel(int count);

  /// No description provided for @receiptSaveDraftBtn.
  ///
  /// In tg, this message translates to:
  /// **'Нигоҳ доштан (Лоиҳа)'**
  String get receiptSaveDraftBtn;

  /// No description provided for @receiptShopName.
  ///
  /// In tg, this message translates to:
  /// **'Дорухонаи Ман'**
  String get receiptShopName;

  /// No description provided for @receiptCheck.
  ///
  /// In tg, this message translates to:
  /// **'Чек'**
  String get receiptCheck;

  /// No description provided for @receiptCheckNumber.
  ///
  /// In tg, this message translates to:
  /// **'Чек № {number}'**
  String receiptCheckNumber(String number);

  /// No description provided for @receiptViewSubtotal.
  ///
  /// In tg, this message translates to:
  /// **'Зерҷамъ'**
  String get receiptViewSubtotal;

  /// No description provided for @receiptViewDiscount.
  ///
  /// In tg, this message translates to:
  /// **'Тахфиф'**
  String get receiptViewDiscount;

  /// No description provided for @receiptViewTotal.
  ///
  /// In tg, this message translates to:
  /// **'ҲАМАГӢ'**
  String get receiptViewTotal;

  /// No description provided for @receiptViewChange.
  ///
  /// In tg, this message translates to:
  /// **'Қайтарма'**
  String get receiptViewChange;

  /// No description provided for @receiptThanks.
  ///
  /// In tg, this message translates to:
  /// **'Ташаккур барои харид!'**
  String get receiptThanks;

  /// No description provided for @receiptPrint.
  ///
  /// In tg, this message translates to:
  /// **'Чоп'**
  String get receiptPrint;

  /// No description provided for @receiptSeries.
  ///
  /// In tg, this message translates to:
  /// **'Серия: {series}'**
  String receiptSeries(String series);

  /// No description provided for @paymentMethodCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақд'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In tg, this message translates to:
  /// **'Корт'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodCredit.
  ///
  /// In tg, this message translates to:
  /// **'Қарз'**
  String get paymentMethodCredit;

  /// No description provided for @payTitle.
  ///
  /// In tg, this message translates to:
  /// **'Пардохт'**
  String get payTitle;

  /// No description provided for @payForPayment.
  ///
  /// In tg, this message translates to:
  /// **'Барои пардохт: {amount}'**
  String payForPayment(String amount);

  /// No description provided for @payAmountGiven.
  ///
  /// In tg, this message translates to:
  /// **'Маблағи додашуда'**
  String get payAmountGiven;

  /// No description provided for @payChange.
  ///
  /// In tg, this message translates to:
  /// **'Қайтарма:'**
  String get payChange;

  /// No description provided for @closeShiftTitle.
  ///
  /// In tg, this message translates to:
  /// **'Бастани смена'**
  String get closeShiftTitle;

  /// No description provided for @closeShiftOpenedAt.
  ///
  /// In tg, this message translates to:
  /// **'Кушода шуд: {time}'**
  String closeShiftOpenedAt(String time);

  /// No description provided for @closeShiftOpeningCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди ибтидоӣ: {amount}'**
  String closeShiftOpeningCash(String amount);

  /// No description provided for @closeShiftSales.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш: {amount}'**
  String closeShiftSales(String amount);

  /// No description provided for @closeShiftClosingCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди ниҳоӣ (ҳисобшуда) *'**
  String get closeShiftClosingCash;

  /// No description provided for @closeShiftClose.
  ///
  /// In tg, this message translates to:
  /// **'Бастан'**
  String get closeShiftClose;

  /// No description provided for @zReportTitle.
  ///
  /// In tg, this message translates to:
  /// **'Z-ҳисобот'**
  String get zReportTitle;

  /// No description provided for @zReportOpened.
  ///
  /// In tg, this message translates to:
  /// **'Кушода шуд'**
  String get zReportOpened;

  /// No description provided for @zReportClosed.
  ///
  /// In tg, this message translates to:
  /// **'Баста шуд'**
  String get zReportClosed;

  /// No description provided for @zReportOpeningCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди ибтидоӣ'**
  String get zReportOpeningCash;

  /// No description provided for @zReportSalesCount.
  ///
  /// In tg, this message translates to:
  /// **'Шумораи фурӯш'**
  String get zReportSalesCount;

  /// No description provided for @zReportSalesTotal.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш (ҷамъ)'**
  String get zReportSalesTotal;

  /// No description provided for @zReportReturnsTotal.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт (ҷамъ)'**
  String get zReportReturnsTotal;

  /// No description provided for @zReportNet.
  ///
  /// In tg, this message translates to:
  /// **'Софи фурӯш'**
  String get zReportNet;

  /// No description provided for @zReportExpectedCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди интизорӣ'**
  String get zReportExpectedCash;

  /// No description provided for @zReportCountedCash.
  ///
  /// In tg, this message translates to:
  /// **'Нақди ҳисобшуда'**
  String get zReportCountedCash;

  /// No description provided for @zReportDiff.
  ///
  /// In tg, this message translates to:
  /// **'Фарқият'**
  String get zReportDiff;

  /// No description provided for @returnsPickTitle.
  ///
  /// In tg, this message translates to:
  /// **'Интихоби чек барои бозгашт'**
  String get returnsPickTitle;

  /// No description provided for @returnsNoSales.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш ёфт нашуд'**
  String get returnsNoSales;

  /// No description provided for @returnsLinesTitle.
  ///
  /// In tg, this message translates to:
  /// **'Сатрҳои бозгашт'**
  String get returnsLinesTitle;

  /// No description provided for @returnsBack.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get returnsBack;

  /// No description provided for @returnsNoLines.
  ///
  /// In tg, this message translates to:
  /// **'Сатр нест'**
  String get returnsNoLines;

  /// No description provided for @returnsLineSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Серия: {series} • Фурӯхта: {qty} • {price}'**
  String returnsLineSubtitle(String series, String qty, String price);

  /// No description provided for @returnsSubmit.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get returnsSubmit;

  /// No description provided for @returnsSelectAtLeastOne.
  ///
  /// In tg, this message translates to:
  /// **'Ҳадди ақал як сатрро интихоб кунед'**
  String get returnsSelectAtLeastOne;

  /// No description provided for @returnsOfflineUnsupported.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт офлайн дастгирӣ намешавад.'**
  String get returnsOfflineUnsupported;

  /// No description provided for @productsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Доруҳо'**
  String get productsTitle;

  /// No description provided for @productsNew.
  ///
  /// In tg, this message translates to:
  /// **'Дору нав'**
  String get productsNew;

  /// No description provided for @productsSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ (ном ё штрих-код)…'**
  String get productsSearchHint;

  /// No description provided for @productsEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Дору ёфт нашуд'**
  String get productsEmpty;

  /// No description provided for @productColName.
  ///
  /// In tg, this message translates to:
  /// **'Ном'**
  String get productColName;

  /// No description provided for @productColBarcode.
  ///
  /// In tg, this message translates to:
  /// **'Штрих-код'**
  String get productColBarcode;

  /// No description provided for @productColGroup.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ'**
  String get productColGroup;

  /// No description provided for @productColUnit.
  ///
  /// In tg, this message translates to:
  /// **'Воҳид'**
  String get productColUnit;

  /// No description provided for @productColRx.
  ///
  /// In tg, this message translates to:
  /// **'Ретсептӣ'**
  String get productColRx;

  /// No description provided for @productColActive.
  ///
  /// In tg, this message translates to:
  /// **'Фаъол'**
  String get productColActive;

  /// No description provided for @productActive.
  ///
  /// In tg, this message translates to:
  /// **'Фаъол'**
  String get productActive;

  /// No description provided for @productInactive.
  ///
  /// In tg, this message translates to:
  /// **'Ғайрифаъол'**
  String get productInactive;

  /// No description provided for @productEditTitle.
  ///
  /// In tg, this message translates to:
  /// **'Таҳрири дору'**
  String get productEditTitle;

  /// No description provided for @productNewTitle.
  ///
  /// In tg, this message translates to:
  /// **'Дору нав'**
  String get productNewTitle;

  /// No description provided for @productName.
  ///
  /// In tg, this message translates to:
  /// **'Ном *'**
  String get productName;

  /// No description provided for @productValName.
  ///
  /// In tg, this message translates to:
  /// **'Номи доруро ворид кунед'**
  String get productValName;

  /// No description provided for @productBarcode.
  ///
  /// In tg, this message translates to:
  /// **'Штрих-код'**
  String get productBarcode;

  /// No description provided for @productGroup.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳи дору'**
  String get productGroup;

  /// No description provided for @productManufacturer.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунанда'**
  String get productManufacturer;

  /// No description provided for @productUnit.
  ///
  /// In tg, this message translates to:
  /// **'Воҳиди ченак'**
  String get productUnit;

  /// No description provided for @productMinStock.
  ///
  /// In tg, this message translates to:
  /// **'Минималии бақия'**
  String get productMinStock;

  /// No description provided for @productMinStockHelper.
  ///
  /// In tg, this message translates to:
  /// **'Зери ин — «камшуда»'**
  String get productMinStockHelper;

  /// No description provided for @productRx.
  ///
  /// In tg, this message translates to:
  /// **'Доруи ретсептӣ'**
  String get productRx;

  /// No description provided for @productRxSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш бо ретсепт'**
  String get productRxSubtitle;

  /// No description provided for @productActiveLabel.
  ///
  /// In tg, this message translates to:
  /// **'Фаъол'**
  String get productActiveLabel;

  /// No description provided for @productCreate.
  ///
  /// In tg, this message translates to:
  /// **'Сохтан'**
  String get productCreate;

  /// No description provided for @productDeactivateDelete.
  ///
  /// In tg, this message translates to:
  /// **'Ғайрифаъол кардан / Ҳазф'**
  String get productDeactivateDelete;

  /// No description provided for @productUpdated.
  ///
  /// In tg, this message translates to:
  /// **'Дору навсозӣ шуд'**
  String get productUpdated;

  /// No description provided for @productCreated.
  ///
  /// In tg, this message translates to:
  /// **'Дору сохта шуд'**
  String get productCreated;

  /// No description provided for @productDeleteTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҳазфи дору'**
  String get productDeleteTitle;

  /// No description provided for @productDeleteBody.
  ///
  /// In tg, this message translates to:
  /// **'«{name}» ҳазф карда шавад?'**
  String productDeleteBody(String name);

  /// No description provided for @productDeleted.
  ///
  /// In tg, this message translates to:
  /// **'Дору ҳазф шуд'**
  String get productDeleted;

  /// No description provided for @productPickerTitle.
  ///
  /// In tg, this message translates to:
  /// **'Интихоби дору'**
  String get productPickerTitle;

  /// No description provided for @productPickerSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ ё скани штрих-код…'**
  String get productPickerSearchHint;

  /// No description provided for @productPickerCreateNew.
  ///
  /// In tg, this message translates to:
  /// **'Дору нав сохтан'**
  String get productPickerCreateNew;

  /// No description provided for @quickCreateTitle.
  ///
  /// In tg, this message translates to:
  /// **'Дору нав сохтан'**
  String get quickCreateTitle;

  /// No description provided for @quickCreateName.
  ///
  /// In tg, this message translates to:
  /// **'Номи дору *'**
  String get quickCreateName;

  /// No description provided for @quickCreateNameHint.
  ///
  /// In tg, this message translates to:
  /// **'мас. Парацетамол 500мг №10'**
  String get quickCreateNameHint;

  /// No description provided for @quickCreateNameRequired.
  ///
  /// In tg, this message translates to:
  /// **'Ном ҳатмист'**
  String get quickCreateNameRequired;

  /// No description provided for @quickCreateGroup.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ'**
  String get quickCreateGroup;

  /// No description provided for @quickCreateUnit.
  ///
  /// In tg, this message translates to:
  /// **'Воҳид'**
  String get quickCreateUnit;

  /// No description provided for @quickCreateMinStock.
  ///
  /// In tg, this message translates to:
  /// **'Минималии бақия (ихтиёрӣ)'**
  String get quickCreateMinStock;

  /// No description provided for @quickCreateRx.
  ///
  /// In tg, this message translates to:
  /// **'Бо ретсепт'**
  String get quickCreateRx;

  /// No description provided for @quickCreateSubmit.
  ///
  /// In tg, this message translates to:
  /// **'Сохтан ва илова'**
  String get quickCreateSubmit;

  /// No description provided for @refSuppliersTitle.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунандагон'**
  String get refSuppliersTitle;

  /// No description provided for @refSupplierNew.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунандаи нав'**
  String get refSupplierNew;

  /// No description provided for @refSupplierSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯи таъминкунанда…'**
  String get refSupplierSearchHint;

  /// No description provided for @refSupplierEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда ёфт нашуд'**
  String get refSupplierEmpty;

  /// No description provided for @refSupplierEntity.
  ///
  /// In tg, this message translates to:
  /// **'таъминкунанда'**
  String get refSupplierEntity;

  /// No description provided for @refColInn.
  ///
  /// In tg, this message translates to:
  /// **'ИНН'**
  String get refColInn;

  /// No description provided for @refColPhone.
  ///
  /// In tg, this message translates to:
  /// **'Телефон'**
  String get refColPhone;

  /// No description provided for @refSupplierValName.
  ///
  /// In tg, this message translates to:
  /// **'Номи таъминкунандаро ворид кунед'**
  String get refSupplierValName;

  /// No description provided for @refSupplierUpdated.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда навсозӣ шуд'**
  String get refSupplierUpdated;

  /// No description provided for @refSupplierCreated.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда сохта шуд'**
  String get refSupplierCreated;

  /// No description provided for @refSupplierDeleted.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда ҳазф шуд'**
  String get refSupplierDeleted;

  /// No description provided for @refFieldAddress.
  ///
  /// In tg, this message translates to:
  /// **'Суроға'**
  String get refFieldAddress;

  /// No description provided for @refManufacturersTitle.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунандагон'**
  String get refManufacturersTitle;

  /// No description provided for @refManufacturerNew.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунандаи нав'**
  String get refManufacturerNew;

  /// No description provided for @refManufacturerSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯи истеҳсолкунанда…'**
  String get refManufacturerSearchHint;

  /// No description provided for @refManufacturerEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунанда ёфт нашуд'**
  String get refManufacturerEmpty;

  /// No description provided for @refManufacturerEntity.
  ///
  /// In tg, this message translates to:
  /// **'истеҳсолкунанда'**
  String get refManufacturerEntity;

  /// No description provided for @refColCountry.
  ///
  /// In tg, this message translates to:
  /// **'Кишвар'**
  String get refColCountry;

  /// No description provided for @refManufacturerValName.
  ///
  /// In tg, this message translates to:
  /// **'Номи истеҳсолкунандаро ворид кунед'**
  String get refManufacturerValName;

  /// No description provided for @refManufacturerUpdated.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунанда навсозӣ шуд'**
  String get refManufacturerUpdated;

  /// No description provided for @refManufacturerCreated.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунанда сохта шуд'**
  String get refManufacturerCreated;

  /// No description provided for @refManufacturerDeleted.
  ///
  /// In tg, this message translates to:
  /// **'Истеҳсолкунанда ҳазф шуд'**
  String get refManufacturerDeleted;

  /// No description provided for @refGroupsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳҳо'**
  String get refGroupsTitle;

  /// No description provided for @refGroupNew.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳи нав'**
  String get refGroupNew;

  /// No description provided for @refGroupSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯи гурӯҳ…'**
  String get refGroupSearchHint;

  /// No description provided for @refGroupEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ ёфт нашуд'**
  String get refGroupEmpty;

  /// No description provided for @refGroupEntity.
  ///
  /// In tg, this message translates to:
  /// **'гурӯҳ'**
  String get refGroupEntity;

  /// No description provided for @refGroupValName.
  ///
  /// In tg, this message translates to:
  /// **'Номи гурӯҳро ворид кунед'**
  String get refGroupValName;

  /// No description provided for @refGroupUpdated.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ навсозӣ шуд'**
  String get refGroupUpdated;

  /// No description provided for @refGroupCreated.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ сохта шуд'**
  String get refGroupCreated;

  /// No description provided for @refGroupDeleted.
  ///
  /// In tg, this message translates to:
  /// **'Гурӯҳ ҳазф шуд'**
  String get refGroupDeleted;

  /// No description provided for @refUnitsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Воҳидҳо'**
  String get refUnitsTitle;

  /// No description provided for @refUnitNew.
  ///
  /// In tg, this message translates to:
  /// **'Воҳиди нав'**
  String get refUnitNew;

  /// No description provided for @refUnitSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯи воҳид…'**
  String get refUnitSearchHint;

  /// No description provided for @refUnitEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Воҳид ёфт нашуд'**
  String get refUnitEmpty;

  /// No description provided for @refUnitEntity.
  ///
  /// In tg, this message translates to:
  /// **'воҳид'**
  String get refUnitEntity;

  /// No description provided for @refUnitValName.
  ///
  /// In tg, this message translates to:
  /// **'Номи воҳидро ворид кунед'**
  String get refUnitValName;

  /// No description provided for @refUnitUpdated.
  ///
  /// In tg, this message translates to:
  /// **'Воҳид навсозӣ шуд'**
  String get refUnitUpdated;

  /// No description provided for @refUnitCreated.
  ///
  /// In tg, this message translates to:
  /// **'Воҳид сохта шуд'**
  String get refUnitCreated;

  /// No description provided for @refUnitDeleted.
  ///
  /// In tg, this message translates to:
  /// **'Воҳид ҳазф шуд'**
  String get refUnitDeleted;

  /// No description provided for @refColName.
  ///
  /// In tg, this message translates to:
  /// **'Ном'**
  String get refColName;

  /// No description provided for @refFieldName.
  ///
  /// In tg, this message translates to:
  /// **'Ном *'**
  String get refFieldName;

  /// No description provided for @refEntityNew.
  ///
  /// In tg, this message translates to:
  /// **'{entity} нав'**
  String refEntityNew(String entity);

  /// No description provided for @refEntityEdit.
  ///
  /// In tg, this message translates to:
  /// **'Таҳрири {entity}'**
  String refEntityEdit(String entity);

  /// No description provided for @refSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯ…'**
  String get refSearchHint;

  /// No description provided for @refPickerSelect.
  ///
  /// In tg, this message translates to:
  /// **'{label}-ро интихоб кунед'**
  String refPickerSelect(String label);

  /// No description provided for @refLoadError.
  ///
  /// In tg, this message translates to:
  /// **'Хатои боркунӣ'**
  String get refLoadError;

  /// No description provided for @writeOffTitle.
  ///
  /// In tg, this message translates to:
  /// **'Списание'**
  String get writeOffTitle;

  /// No description provided for @writeOffSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Аз бақия баровардан (мӯҳлат гузашта, вайроншуда…)'**
  String get writeOffSubtitle;

  /// No description provided for @writeOffSubmit.
  ///
  /// In tg, this message translates to:
  /// **'Сабт кардан'**
  String get writeOffSubmit;

  /// No description provided for @writeOffReason.
  ///
  /// In tg, this message translates to:
  /// **'Сабаб *'**
  String get writeOffReason;

  /// No description provided for @writeOffNote.
  ///
  /// In tg, this message translates to:
  /// **'Эзоҳ'**
  String get writeOffNote;

  /// No description provided for @writeOffAddBatch.
  ///
  /// In tg, this message translates to:
  /// **'Партия илова'**
  String get writeOffAddBatch;

  /// No description provided for @writeOffSaved.
  ///
  /// In tg, this message translates to:
  /// **'Списание сабт шуд.'**
  String get writeOffSaved;

  /// No description provided for @writeOffEmptyDraft.
  ///
  /// In tg, this message translates to:
  /// **'Партия илова кунед барои списание.'**
  String get writeOffEmptyDraft;

  /// No description provided for @writeOffHistoryTitle.
  ///
  /// In tg, this message translates to:
  /// **'Списанияҳои охирин'**
  String get writeOffHistoryTitle;

  /// No description provided for @writeOffHistoryEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Ҳоло списание сабт нашудааст.'**
  String get writeOffHistoryEmpty;

  /// No description provided for @writeOffReasonExpired.
  ///
  /// In tg, this message translates to:
  /// **'Мӯҳлат гузашта'**
  String get writeOffReasonExpired;

  /// No description provided for @writeOffReasonDamaged.
  ///
  /// In tg, this message translates to:
  /// **'Вайроншуда'**
  String get writeOffReasonDamaged;

  /// No description provided for @writeOffReasonLost.
  ///
  /// In tg, this message translates to:
  /// **'Гумшуда'**
  String get writeOffReasonLost;

  /// No description provided for @writeOffReasonOther.
  ///
  /// In tg, this message translates to:
  /// **'Дигар'**
  String get writeOffReasonOther;

  /// No description provided for @supplierReturnTitle.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт ба таъминкунанда'**
  String get supplierReturnTitle;

  /// No description provided for @supplierReturnSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Баргардонидани партияҳо ба таъминкунанда'**
  String get supplierReturnSubtitle;

  /// No description provided for @supplierReturnSubmit.
  ///
  /// In tg, this message translates to:
  /// **'Сабт кардан'**
  String get supplierReturnSubmit;

  /// No description provided for @supplierReturnSupplier.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда'**
  String get supplierReturnSupplier;

  /// No description provided for @supplierReturnSelectSupplier.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунандаро интихоб кунед.'**
  String get supplierReturnSelectSupplier;

  /// No description provided for @supplierReturnSaved.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт ба таъминкунанда сабт шуд.'**
  String get supplierReturnSaved;

  /// No description provided for @supplierReturnEmptyDraft.
  ///
  /// In tg, this message translates to:
  /// **'Партия илова кунед барои бозгашт.'**
  String get supplierReturnEmptyDraft;

  /// No description provided for @supplierReturnHistoryTitle.
  ///
  /// In tg, this message translates to:
  /// **'Бозгаштҳои охирин'**
  String get supplierReturnHistoryTitle;

  /// No description provided for @supplierReturnHistoryEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Ҳоло бозгашт сабт нашудааст.'**
  String get supplierReturnHistoryEmpty;

  /// No description provided for @inventoryTitle.
  ///
  /// In tg, this message translates to:
  /// **'Инвентаризатсия'**
  String get inventoryTitle;

  /// No description provided for @inventorySubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисоб кардани бақия ва танзими фарқият'**
  String get inventorySubtitle;

  /// No description provided for @inventorySubmit.
  ///
  /// In tg, this message translates to:
  /// **'Сабт кардан'**
  String get inventorySubmit;

  /// No description provided for @inventoryNote.
  ///
  /// In tg, this message translates to:
  /// **'Эзоҳ'**
  String get inventoryNote;

  /// No description provided for @inventoryAddBatch.
  ///
  /// In tg, this message translates to:
  /// **'Партия илова'**
  String get inventoryAddBatch;

  /// No description provided for @inventorySavedNoDiff.
  ///
  /// In tg, this message translates to:
  /// **'Инвентаризатсия сабт шуд (фарқият нест).'**
  String get inventorySavedNoDiff;

  /// No description provided for @inventoryDiscrepanciesTitle.
  ///
  /// In tg, this message translates to:
  /// **'Фарқиятҳои инвентаризатсия'**
  String get inventoryDiscrepanciesTitle;

  /// No description provided for @inventoryColExpected.
  ///
  /// In tg, this message translates to:
  /// **'Интизор'**
  String get inventoryColExpected;

  /// No description provided for @inventoryColCounted.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисобшуда'**
  String get inventoryColCounted;

  /// No description provided for @inventoryColDiff.
  ///
  /// In tg, this message translates to:
  /// **'Фарқият'**
  String get inventoryColDiff;

  /// No description provided for @inventoryOk.
  ///
  /// In tg, this message translates to:
  /// **'Хуб'**
  String get inventoryOk;

  /// No description provided for @inventoryEmptyDraft.
  ///
  /// In tg, this message translates to:
  /// **'Партия илова кунед барои ҳисоб.'**
  String get inventoryEmptyDraft;

  /// No description provided for @inventoryCountedLabel.
  ///
  /// In tg, this message translates to:
  /// **'Ҳисобшуда'**
  String get inventoryCountedLabel;

  /// No description provided for @inventoryHistoryTitle.
  ///
  /// In tg, this message translates to:
  /// **'Инвентаризатсияҳои охирин'**
  String get inventoryHistoryTitle;

  /// No description provided for @inventoryHistoryEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Ҳоло инвентаризатсия сабт нашудааст.'**
  String get inventoryHistoryEmpty;

  /// No description provided for @opColDate.
  ///
  /// In tg, this message translates to:
  /// **'Сана'**
  String get opColDate;

  /// No description provided for @opColNumber.
  ///
  /// In tg, this message translates to:
  /// **'Рақам'**
  String get opColNumber;

  /// No description provided for @opColLines.
  ///
  /// In tg, this message translates to:
  /// **'Сатрҳо'**
  String get opColLines;

  /// No description provided for @opColSupplier.
  ///
  /// In tg, this message translates to:
  /// **'Таъминкунанда'**
  String get opColSupplier;

  /// No description provided for @opColReason.
  ///
  /// In tg, this message translates to:
  /// **'Сабаб'**
  String get opColReason;

  /// No description provided for @opValBranchUnresolved.
  ///
  /// In tg, this message translates to:
  /// **'Филиал ҳанӯз муайян нашуд. Лутфан дубора кӯшиш кунед.'**
  String get opValBranchUnresolved;

  /// No description provided for @opValAtLeastOneBatch.
  ///
  /// In tg, this message translates to:
  /// **'Ҳадди ақал як партия илова кунед.'**
  String get opValAtLeastOneBatch;

  /// No description provided for @opValQtyPositive.
  ///
  /// In tg, this message translates to:
  /// **'Миқдори «{name}» бояд аз сифр зиёд бошад.'**
  String opValQtyPositive(String name);

  /// No description provided for @opValQtyMax.
  ///
  /// In tg, this message translates to:
  /// **'Миқдори «{name}» аз бақия ({onHand}) зиёд аст.'**
  String opValQtyMax(String name, String onHand);

  /// No description provided for @opColDrug.
  ///
  /// In tg, this message translates to:
  /// **'Дору'**
  String get opColDrug;

  /// No description provided for @opColSeries.
  ///
  /// In tg, this message translates to:
  /// **'Серия'**
  String get opColSeries;

  /// No description provided for @opColRemaining.
  ///
  /// In tg, this message translates to:
  /// **'Бақия'**
  String get opColRemaining;

  /// No description provided for @opColDiscrepancy.
  ///
  /// In tg, this message translates to:
  /// **'Фарқият'**
  String get opColDiscrepancy;

  /// No description provided for @opEmptyDefault.
  ///
  /// In tg, this message translates to:
  /// **'Партия илова кунед.'**
  String get opEmptyDefault;

  /// No description provided for @opColQty.
  ///
  /// In tg, this message translates to:
  /// **'Миқдор'**
  String get opColQty;

  /// No description provided for @batchPickerTitle.
  ///
  /// In tg, this message translates to:
  /// **'Интихоби партия'**
  String get batchPickerTitle;

  /// No description provided for @batchPickerSearchHint.
  ///
  /// In tg, this message translates to:
  /// **'Ҷустуҷӯи дору ё штрих-код…'**
  String get batchPickerSearchHint;

  /// No description provided for @batchPickerEmpty.
  ///
  /// In tg, this message translates to:
  /// **'Партия ёфт нашуд'**
  String get batchPickerEmpty;

  /// No description provided for @batchPickerSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Серия: {series} · то {date}'**
  String batchPickerSubtitle(String series, String date);

  /// No description provided for @batchPickerRemaining.
  ///
  /// In tg, this message translates to:
  /// **'Бақия: {qty}'**
  String batchPickerRemaining(String qty);

  /// No description provided for @stockBatchesCount.
  ///
  /// In tg, this message translates to:
  /// **'Партияҳо ({count})'**
  String stockBatchesCount(int count);

  /// No description provided for @stockNoBatchesOnPage.
  ///
  /// In tg, this message translates to:
  /// **'Дар саҳифаи ҷорӣ партия нест.'**
  String get stockNoBatchesOnPage;

  /// No description provided for @stockMovementsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҳаракати дору'**
  String get stockMovementsTitle;

  /// No description provided for @stockNoMovements.
  ///
  /// In tg, this message translates to:
  /// **'Ҳаракат нест'**
  String get stockNoMovements;

  /// No description provided for @movementReceipt.
  ///
  /// In tg, this message translates to:
  /// **'Приход'**
  String get movementReceipt;

  /// No description provided for @movementSale.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш'**
  String get movementSale;

  /// No description provided for @movementReturn.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get movementReturn;

  /// No description provided for @movementWriteOff.
  ///
  /// In tg, this message translates to:
  /// **'Списание'**
  String get movementWriteOff;

  /// No description provided for @movementAdjustment.
  ///
  /// In tg, this message translates to:
  /// **'Тасҳеҳ'**
  String get movementAdjustment;

  /// No description provided for @movementTransfer.
  ///
  /// In tg, this message translates to:
  /// **'Интиқол'**
  String get movementTransfer;

  /// No description provided for @syncTitle.
  ///
  /// In tg, this message translates to:
  /// **'Синхронизатсия'**
  String get syncTitle;

  /// No description provided for @syncOnline.
  ///
  /// In tg, this message translates to:
  /// **'Онлайн'**
  String get syncOnline;

  /// No description provided for @syncOffline.
  ///
  /// In tg, this message translates to:
  /// **'Офлайн'**
  String get syncOffline;

  /// No description provided for @syncInQueue.
  ///
  /// In tg, this message translates to:
  /// **'{count} дар навбат'**
  String syncInQueue(int count);

  /// No description provided for @syncNow.
  ///
  /// In tg, this message translates to:
  /// **'Синхрон кардан'**
  String get syncNow;

  /// No description provided for @syncConflictsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Низоъҳо (conflict)'**
  String get syncConflictsTitle;

  /// No description provided for @syncError.
  ///
  /// In tg, this message translates to:
  /// **'Хато: {error}'**
  String syncError(String error);

  /// No description provided for @syncNoConflictsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Низоъ нест'**
  String get syncNoConflictsTitle;

  /// No description provided for @syncNoConflictsBody.
  ///
  /// In tg, this message translates to:
  /// **'Ҳама фурӯшҳои офлайн бомуваффақият синхрон шуданд.'**
  String get syncNoConflictsBody;

  /// No description provided for @syncResult.
  ///
  /// In tg, this message translates to:
  /// **'Синхрон: {pushed} қабул, {conflicts} низоъ, {failed} нашуд.'**
  String syncResult(int pushed, int conflicts, int failed);

  /// No description provided for @syncSaleAt.
  ///
  /// In tg, this message translates to:
  /// **'Фурӯш {time}'**
  String syncSaleAt(String time);

  /// No description provided for @syncConflictFallback.
  ///
  /// In tg, this message translates to:
  /// **'Бақия дар сервер нарасид.'**
  String get syncConflictFallback;

  /// No description provided for @syncDismiss.
  ///
  /// In tg, this message translates to:
  /// **'Рад кардан'**
  String get syncDismiss;

  /// No description provided for @syncDismissed.
  ///
  /// In tg, this message translates to:
  /// **'Низоъ рад карда шуд.'**
  String get syncDismissed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'tg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'tg':
      return AppLocalizationsTg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

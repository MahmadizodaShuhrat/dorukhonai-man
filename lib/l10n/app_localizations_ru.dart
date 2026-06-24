// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Аптека';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonRefresh => 'Обновить';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonYes => 'Да';

  @override
  String get commonOpen => 'Открыть';

  @override
  String get commonRequired => 'Обязательно';

  @override
  String get commonError => 'Ошибка';

  @override
  String get commonLoadFailed => 'Не удалось загрузить.';

  @override
  String get commonNoData => 'Нет данных';

  @override
  String get commonDash => '—';

  @override
  String get commonNew => 'Новый';

  @override
  String get commonRestore => 'Сбросить';

  @override
  String get commonApply => 'Применить';

  @override
  String get commonExpand => 'Развернуть';

  @override
  String get commonCollapse => 'Свернуть';

  @override
  String get commonPrevious => 'Назад';

  @override
  String get commonNext => 'Вперёд';

  @override
  String commonTotalCount(int count) {
    return 'Всего: $count';
  }

  @override
  String commonPageOf(int page, int pageCount) {
    return '$page / $pageCount';
  }

  @override
  String get commonLoadDataFailed => 'Не удалось загрузить данные.';

  @override
  String get validationEnterNumber => 'Введите корректное число';

  @override
  String get validationNotNegative => 'Не может быть отрицательным';

  @override
  String get failureNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get failureAuth => 'Доступ запрещён. Войдите снова.';

  @override
  String get failureUnknown => 'Произошла неизвестная ошибка.';

  @override
  String get failureEmptyResponse => 'Пустой ответ от сервера.';

  @override
  String failureServer(String status) {
    return 'Ошибка сервера ($status).';
  }

  @override
  String get failureInvalidState =>
      'Операция не выполнена (неверное состояние).';

  @override
  String get failureNotFound => 'Не найдено.';

  @override
  String get navDashboard => 'Дашборд';

  @override
  String get navPos => 'Касса';

  @override
  String get navStock => 'Склад';

  @override
  String get navReceipts => 'Приход';

  @override
  String get navWriteOffs => 'Списание';

  @override
  String get navInventory => 'Инвентаризация';

  @override
  String get navSupplierReturns => 'Возврат';

  @override
  String get navSupplierReturnsLong => 'Возврат поставщику';

  @override
  String get navProducts => 'Товары';

  @override
  String get navDrugGroups => 'Группы';

  @override
  String get navSuppliers => 'Поставщики';

  @override
  String get navManufacturers => 'Производители';

  @override
  String get navUnits => 'Единицы';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navSectionStockOps => 'ОПЕРАЦИИ СКЛАДА';

  @override
  String get navSectionReference => 'СПРАВОЧНИКИ';

  @override
  String get shellThemeLight => 'Светлая тема';

  @override
  String get shellThemeDark => 'Тёмная тема';

  @override
  String get shellLanguageTajik => 'Таджикский';

  @override
  String get shellLanguageRussian => 'Русский';

  @override
  String get shellLanguageTajikShort => 'ТҶ';

  @override
  String get shellLanguageRussianShort => 'РУ';

  @override
  String get shellLanguageTooltip => 'Язык';

  @override
  String get shellBranchFallback => 'Филиал';

  @override
  String shellShiftOpenAt(String time) {
    return 'Открыта · $time';
  }

  @override
  String get shellShiftClosed => 'Смена закрыта';

  @override
  String get shellOnline => 'Онлайн';

  @override
  String get shellOffline => 'Офлайн';

  @override
  String shellQueueSuffix(String base, int count) {
    return '$base · $count в очереди';
  }

  @override
  String get shellServerReachable => 'Сервер доступен';

  @override
  String get shellServerUnreachable => 'Сервер недоступен';

  @override
  String shellLastOnline(String time) {
    return 'Последний: $time';
  }

  @override
  String shellPendingSyncCount(int count) {
    return '$count продаж в очереди синхронизации';
  }

  @override
  String get shellSearchHint => 'Поиск или команда…';

  @override
  String get shellUserFallback => 'Пользователь';

  @override
  String get shellLogout => 'Выход';

  @override
  String get commandSearchHint => 'Найдите команду или раздел…';

  @override
  String get commandNothingFound => 'Ничего не найдено';

  @override
  String get commandFooterHint => '↑↓ выбор · Enter открыть · Esc закрыть';

  @override
  String get dashTitle => 'Дашборд';

  @override
  String dashSubtitleToday(String date) {
    return 'Сегодня, $date';
  }

  @override
  String get dashKpiTodaySales => 'ПРОДАЖИ СЕГОДНЯ';

  @override
  String dashKpiReceiptsCount(int count) {
    return '$count чек(ов)';
  }

  @override
  String dashKpiExpiringSoon(int days) {
    return 'СКОРО ИСТЕКАЕТ ($daysд)';
  }

  @override
  String get dashKpiDrugUnit => 'товаров';

  @override
  String get dashKpiLowStock => 'ЗАКАНЧИВАЕТСЯ (ниже мин.)';

  @override
  String get dashKpiShift => 'СМЕНА';

  @override
  String get dashShiftOpen => 'Открыта';

  @override
  String get dashShiftClosed => 'Закрыта';

  @override
  String get dashShiftNotOpen => 'Смена не открыта';

  @override
  String get dashKpiErrorShort => '— ошибка';

  @override
  String get dashExpiringTitle => 'Скоро истекает';

  @override
  String get dashSeeAllStock => 'Смотреть всё → Склад';

  @override
  String get dashNoExpiring => 'Нет товаров с истекающим сроком.';

  @override
  String get dashColDrug => 'Товар';

  @override
  String get dashColSeries => 'Серия';

  @override
  String get dashColExpiry => 'Срок';

  @override
  String get dashColRemaining => 'Остаток';

  @override
  String get dashLowStockTitle => 'Заканчивается';

  @override
  String get dashNoLowStock => 'Нет заканчивающихся товаров.';

  @override
  String get dashQuickActions => 'Быстрые действия';

  @override
  String get dashQuickNewReceipt => 'Новый приход';

  @override
  String get dashQuickCloseShift => 'Закрыть смену';

  @override
  String get dashQuickOpenShift => 'Открыть смену';

  @override
  String get dashQuickSale => 'Продажа';

  @override
  String get dashQuickSearchDrug => 'Поиск товара';

  @override
  String get dashSalesTrendTitle => 'Продажи — последние 7 дней';

  @override
  String get dashNoSalesTrend => 'За последние 7 дней продаж не было.';

  @override
  String get dashExpiryGone => 'истёк';

  @override
  String dashExpiryDays(int days) {
    return '$daysд';
  }

  @override
  String get dowMon => 'Пн';

  @override
  String get dowTue => 'Вт';

  @override
  String get dowWed => 'Ср';

  @override
  String get dowThu => 'Чт';

  @override
  String get dowFri => 'Пт';

  @override
  String get dowSat => 'Сб';

  @override
  String get dowSun => 'Вс';

  @override
  String get posCartEmpty => 'Корзина пуста';

  @override
  String get posRxTitle => 'Рецептурный препарат';

  @override
  String get posRxTooltip => 'Рецептурный препарат';

  @override
  String posRxBody(String name) {
    return '«$name» — рецептурный препарат (℞). Подтвердить добавление в корзину?';
  }

  @override
  String get posOfflineSaleQueued =>
      'Офлайн: продажа сохранена в очереди синхронизации (напечатано).';

  @override
  String get posCartEmptyHint =>
      'Корзина пуста. Отсканируйте штрих-код или найдите товар.';

  @override
  String get posColDrug => 'Товар';

  @override
  String get posColQty => 'Кол-во';

  @override
  String get posColPrice => 'Цена';

  @override
  String get posColSum => 'Сумма';

  @override
  String get posRemove => 'Удалить';

  @override
  String get posShiftOpen => 'Смена открыта';

  @override
  String posShiftOpenedAt(String time) {
    return 'Открыта: $time';
  }

  @override
  String posShiftSales(String amount) {
    return 'Продажи смены: $amount';
  }

  @override
  String get posReturnsTooltip => 'Возврат продажи (F7)';

  @override
  String get posCloseShiftTooltip => 'Закрыть смену (F10)';

  @override
  String get posScanHint =>
      'Отсканируйте штрих-код или введите название…  (F2)';

  @override
  String get posQtyDecrease => 'Меньше';

  @override
  String get posQtyIncrease => 'Больше';

  @override
  String get posCheck => 'СЧЁТ';

  @override
  String get posSubtotal => 'Подытог';

  @override
  String get posDiscountField => 'Скидка (F4)';

  @override
  String get posTotalAll => 'ИТОГО';

  @override
  String get posPaymentMethod => 'Способ оплаты';

  @override
  String get posMethodCash => 'Наличные';

  @override
  String get posMethodCard => 'Карта';

  @override
  String get posMethodCredit => 'Кредит';

  @override
  String get posPay => 'Оплата (F9)';

  @override
  String get posHintSearch => 'Поиск';

  @override
  String get posHintDiscount => 'Скидка';

  @override
  String get posHintPay => 'Оплата';

  @override
  String get posHintRemove => 'Удалить';

  @override
  String get posHintQty => 'Кол-во';

  @override
  String get posHintReturn => 'Возврат';

  @override
  String get posHintCloseShift => 'Закрыть смену';

  @override
  String get posNoShiftTitle => 'Смена не открыта';

  @override
  String get posNoShiftBody => 'Чтобы начать продажи, откройте смену.';

  @override
  String get posOpenShift => 'Открыть смену';

  @override
  String get posOpeningCash => 'Начальная наличность *';

  @override
  String get posDiscountTitle => 'Скидка';

  @override
  String get posDiscountAmount => 'Сумма скидки';

  @override
  String get stockTitle => 'Склад';

  @override
  String get stockUnitItems => 'позиций';

  @override
  String get stockUnitExpiring => 'истекают';

  @override
  String get stockUnitLow => 'заканчиваются';

  @override
  String get stockTabOnHand => 'Остаток';

  @override
  String get stockTabExpiring => 'Скоро истекает';

  @override
  String get stockTabLow => 'Заканчивается';

  @override
  String get stockEmptyOnHand => 'Нет остатков';

  @override
  String get stockColName => 'Название';

  @override
  String get stockColBarcode => 'Штрих-код';

  @override
  String get stockColSeries => 'Серия';

  @override
  String get stockColExpiry => 'Срок';

  @override
  String get stockColRemaining => 'Остаток';

  @override
  String get stockColPrice => 'Цена';

  @override
  String get stockExpiryLabel => 'Срок:';

  @override
  String stockDaysOption(int days) {
    return '$days дн.';
  }

  @override
  String get stockEmptyExpiring => 'Нет товаров с истекающим сроком';

  @override
  String get stockColRemainingDays => 'Осталось (дн.)';

  @override
  String get stockEmptyLow => 'Нет заканчивающихся товаров';

  @override
  String get stockColTotalRemaining => 'Общий остаток';

  @override
  String get stockColMinimum => 'Минимум';

  @override
  String get stockColShortfall => 'Нехватка';

  @override
  String get stockSearchHint => 'Поиск (название или штрих-код)…';

  @override
  String get stockExpired => 'Истёк';

  @override
  String stockExpiryDaysShort(int days) {
    return '$days д';
  }

  @override
  String get stockLegendNear => '≤30 дн.';

  @override
  String get stockLegendSoon => '≤90 дн.';

  @override
  String get reportsTitle => 'Отчёты';

  @override
  String get reportViewSales => 'Продажи';

  @override
  String get reportViewProfit => 'Прибыль';

  @override
  String get reportViewStockValue => 'Стоимость склада';

  @override
  String get reportViewExpiring => 'Скоро истекает';

  @override
  String get reportViewZReport => 'Z-отчёт';

  @override
  String get reportGroupByDay => 'По дням';

  @override
  String get reportGroupByProduct => 'По товарам';

  @override
  String get reportGroupBySeller => 'По продавцам';

  @override
  String get reportsNoExportData => 'Нет данных для экспорта.';

  @override
  String reportsCsvSaved(String path) {
    return 'CSV сохранён: $path';
  }

  @override
  String reportsExportFailed(String error) {
    return 'Экспорт не выполнен: $error';
  }

  @override
  String reportsTitleSales(String groupBy) {
    return 'Отчёт о продажах ($groupBy)';
  }

  @override
  String get reportColGroup => 'Группа';

  @override
  String get reportColReceipt => 'Чек';

  @override
  String get reportColQty => 'Кол-во';

  @override
  String get reportColSubtotal => 'Подытог';

  @override
  String get reportColDiscount => 'Скидка';

  @override
  String get reportColTotal => 'Итого';

  @override
  String get reportsTitleProfit => 'Отчёт о прибыли';

  @override
  String get reportColMetric => 'Показатель';

  @override
  String get reportColAmount => 'Сумма';

  @override
  String get reportRevenue => 'Выручка';

  @override
  String get reportCost => 'Себестоимость';

  @override
  String get reportProfit => 'Прибыль';

  @override
  String get reportMargin => 'Маржа';

  @override
  String get reportsTitleStockValue => 'Стоимость склада';

  @override
  String get reportColDrug => 'Товар';

  @override
  String get reportColPurchaseValue => 'Закупочная стоимость';

  @override
  String get reportColSaleValue => 'Стоимость продажи';

  @override
  String get reportsTitleExpiring => 'Товары с истекающим сроком';

  @override
  String get reportColSeries => 'Серия';

  @override
  String get reportColExpiry => 'Срок';

  @override
  String get reportColDays => 'Дней';

  @override
  String get reportColRemaining => 'Остаток';

  @override
  String reportsTitleZReport(String shiftId) {
    return 'Z-отчёт · $shiftId';
  }

  @override
  String get reportZOpened => 'Открыта';

  @override
  String get reportZClosed => 'Закрыта';

  @override
  String get reportZOpeningCash => 'Начальная сумма';

  @override
  String get reportZSalesCount => 'Кол-во продаж';

  @override
  String get reportZTotalSales => 'Всего продаж';

  @override
  String get reportZReturns => 'Возвраты';

  @override
  String get reportZNet => 'Чистая сумма';

  @override
  String get reportZCash => 'Наличные';

  @override
  String get reportZCard => 'Карта';

  @override
  String get reportZCredit => 'Кредит';

  @override
  String get reportZExpectedCash => 'Ожидаемая наличность';

  @override
  String get reportZActualCash => 'Фактическая наличность';

  @override
  String get reportDateFrom => 'С';

  @override
  String get reportDateTo => 'По';

  @override
  String get reportPresetToday => 'Сегодня';

  @override
  String get reportPreset7Days => '7 дней';

  @override
  String get reportPresetThisMonth => 'Этот месяц';

  @override
  String get reportNoChartData => 'Нет данных для графика';

  @override
  String get reportPositive => 'Положительно';

  @override
  String get reportNegative => 'Отрицательно';

  @override
  String get reportShiftIdField => 'ID смены';

  @override
  String get reportEnterShiftId => 'Введите ID смены.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSubtitle =>
      'Вид · сервер · уведомления · цена · принтер · пользователь';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsThemeLabel => 'Тип темы:';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeHint =>
      '«Системная» следует настройке Windows. Выбор сохраняется.';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageLabel => 'Язык программы:';

  @override
  String get settingsLanguageTajik => 'Тоҷикӣ';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageHint =>
      'Выбор сохраняется и применяется ко всей программе.';

  @override
  String get settingsServer => 'Сервер';

  @override
  String get settingsServerCurrentUrl => 'Текущий URL: ';

  @override
  String get settingsServerField => 'Адрес сервера (scheme://host:port/api/v1)';

  @override
  String get settingsServerLocked =>
      'Задан через --dart-define — редактирование невозможно.';

  @override
  String get settingsServerExample => 'Пример: http://192.168.1.10:5000/api/v1';

  @override
  String get settingsTestConnection => 'Проверка соединения';

  @override
  String get settingsConnected => 'Подключено';

  @override
  String get settingsNotConnected => 'Нет подключения';

  @override
  String get settingsInvalidUrl => 'Неверный адрес. Введите http(s)://host…';

  @override
  String get settingsUrlSaved => 'Адрес сервера сохранён.';

  @override
  String get settingsUrlReset => 'Возвращено к адресу по умолчанию.';

  @override
  String get settingsAlert => 'Уведомления';

  @override
  String get settingsAlertHorizon => 'Горизонт уведомления о сроке (дн.):';

  @override
  String settingsAlertDays(int days) {
    return '$days дн.';
  }

  @override
  String get settingsMarkup => 'Цена';

  @override
  String get settingsMarkupLabel =>
      'Наценка по умолчанию (для модуля ценообразования):';

  @override
  String get settingsMarkupField => 'Наценка %';

  @override
  String get settingsMarkupSaved => 'Наценка сохранена.';

  @override
  String get settingsMarkupHint =>
      'Примечание: сохраняется на сервере и используется как наценка по умолчанию для цены продажи при приходе.';

  @override
  String get settingsPrinter => 'Принтер';

  @override
  String get settingsPrinterHint =>
      'Печать чека через системный диалог печати (printing). Выбор принтера по умолчанию будет добавлен в следующей версии.';

  @override
  String get settingsSystem => 'Системный';

  @override
  String get settingsUser => 'Пользователь';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsUsers => 'Пользователи';

  @override
  String get settingsUserAdded => 'Пользователь добавлен.';

  @override
  String get settingsUserUpdated => 'Пользователь изменён.';

  @override
  String get settingsDeactivateTitle => 'Деактивировать';

  @override
  String settingsDeactivateBody(String name) {
    return 'Деактивировать «$name»?';
  }

  @override
  String get settingsUserDeactivated => 'Пользователь деактивирован.';

  @override
  String get settingsNewUser => 'Новый пользователь';

  @override
  String get settingsNoUsers => 'Нет пользователей';

  @override
  String get settingsEditTooltip => 'Изменить';

  @override
  String get settingsDeactivateTooltip => 'Деактивировать';

  @override
  String get settingsEditUser => 'Изменить пользователя';

  @override
  String get settingsFullName => 'ФИО *';

  @override
  String get settingsUserName => 'Имя пользователя (login) *';

  @override
  String get settingsPassword => 'Пароль *';

  @override
  String get settingsPasswordMin => 'Минимум 4 символа';

  @override
  String get settingsRole => 'Роль *';

  @override
  String get settingsAbout => 'О программе';

  @override
  String get settingsAboutText => 'Аптека — Касса/Склад · v1.0.0';

  @override
  String get loginTitle => 'Аптека — Касса';

  @override
  String get loginUsername => 'Логин';

  @override
  String get loginUsernameRequired => 'Введите логин';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginPasswordRequired => 'Введите пароль';

  @override
  String get loginSubmit => 'Войти';

  @override
  String get receiptsTitle => 'Приход';

  @override
  String get receiptsRefresh => 'Обновить';

  @override
  String get receiptsNew => 'Новый приход';

  @override
  String get receiptsEmpty => 'Приход не найден';

  @override
  String get receiptColNumber => '№';

  @override
  String get receiptColDate => 'Дата';

  @override
  String get receiptColSupplier => 'Поставщик';

  @override
  String get receiptColStatus => 'Статус';

  @override
  String get receiptColTotal => 'Сумма';

  @override
  String get receiptFilterAll => 'Все';

  @override
  String get receiptDateFilter => 'Дата';

  @override
  String get receiptClearDate => 'Очистить дату';

  @override
  String get receiptStatusDraft => 'Черновик';

  @override
  String get receiptStatusPosted => 'Проведён';

  @override
  String get receiptStatusCancelled => 'Отменён';

  @override
  String receiptPageOf(int page, int pageCount) {
    return 'Стр. $page из $pageCount';
  }

  @override
  String receiptEditTitle(String number) {
    return 'Приход $number';
  }

  @override
  String get receiptNewTitle => 'Новый приход';

  @override
  String get receiptValSupplier => 'Выберите поставщика';

  @override
  String get receiptValBranch => 'Введите филиал';

  @override
  String get receiptValAtLeastOneLine => 'Добавьте хотя бы одну строку';

  @override
  String receiptValLine(int index, String problem) {
    return 'Строка $index: $problem';
  }

  @override
  String get receiptSavedDraft => 'Приход сохранён как черновик';

  @override
  String get receiptSaveFirst => 'Сначала сохраните приход';

  @override
  String get receiptPostTitle => 'Проведение прихода';

  @override
  String get receiptPostBody =>
      'Провести приход? После проведения остаток обновится.';

  @override
  String get receiptPosted => 'Приход проведён';

  @override
  String get receiptCancelTitle => 'Отмена прихода';

  @override
  String get receiptCancelBody => 'Отменить приход?';

  @override
  String get receiptCancelConfirm => 'Отменить';

  @override
  String get receiptCancelled => 'Приход отменён';

  @override
  String receiptLinesCount(int count) {
    return 'Строки ($count)';
  }

  @override
  String get receiptAddLine => 'Добавить строку / скан штрих-кода';

  @override
  String get receiptNoLinesEditable =>
      'Строк нет. Нажмите «Добавить строку» или отсканируйте штрих-код.';

  @override
  String get receiptNoLinesReadonly => 'В этом приходе нет строк.';

  @override
  String get receiptColDrug => 'Товар';

  @override
  String get receiptColQty => 'Кол-во';

  @override
  String get receiptColSeries => 'Серия';

  @override
  String get receiptColExpiry => 'Срок';

  @override
  String get receiptColPurchasePrice => 'Цена закупки';

  @override
  String get receiptColSalePrice => 'Цена продажи';

  @override
  String get receiptColLineTotal => 'Сумма';

  @override
  String get receiptDeleteLine => 'Удалить строку';

  @override
  String get receiptValQty => 'введите корректное кол-во';

  @override
  String get receiptValSeries => 'введите серию';

  @override
  String get receiptValPurchasePrice => 'введите цену закупки';

  @override
  String get receiptValSalePrice => 'введите цену продажи';

  @override
  String get receiptSupplier => 'Поставщик';

  @override
  String get receiptBranch => 'Филиал *';

  @override
  String get receiptNumber => 'Номер';

  @override
  String get receiptNumberNew => '— новый —';

  @override
  String receiptPurchaseTotal(String amount) {
    return 'Сумма закупки: $amount';
  }

  @override
  String receiptLinesLabel(int count) {
    return 'Строки: $count';
  }

  @override
  String get receiptSaveDraftBtn => 'Сохранить (Черновик)';

  @override
  String get receiptShopName => 'Моя Аптека';

  @override
  String get receiptCheck => 'Чек';

  @override
  String receiptCheckNumber(String number) {
    return 'Чек № $number';
  }

  @override
  String get receiptViewSubtotal => 'Подытог';

  @override
  String get receiptViewDiscount => 'Скидка';

  @override
  String get receiptViewTotal => 'ИТОГО';

  @override
  String get receiptViewChange => 'Сдача';

  @override
  String get receiptThanks => 'Спасибо за покупку!';

  @override
  String get receiptPrint => 'Печать';

  @override
  String receiptSeries(String series) {
    return 'Серия: $series';
  }

  @override
  String get paymentMethodCash => 'Наличные';

  @override
  String get paymentMethodCard => 'Карта';

  @override
  String get paymentMethodCredit => 'Кредит';

  @override
  String get payTitle => 'Оплата';

  @override
  String payForPayment(String amount) {
    return 'К оплате: $amount';
  }

  @override
  String get payAmountGiven => 'Внесённая сумма';

  @override
  String get payChange => 'Сдача:';

  @override
  String get closeShiftTitle => 'Закрытие смены';

  @override
  String closeShiftOpenedAt(String time) {
    return 'Открыта: $time';
  }

  @override
  String closeShiftOpeningCash(String amount) {
    return 'Начальная наличность: $amount';
  }

  @override
  String closeShiftSales(String amount) {
    return 'Продажи: $amount';
  }

  @override
  String get closeShiftClosingCash => 'Конечная наличность (фактическая) *';

  @override
  String get closeShiftClose => 'Закрыть';

  @override
  String get zReportTitle => 'Z-отчёт';

  @override
  String get zReportOpened => 'Открыта';

  @override
  String get zReportClosed => 'Закрыта';

  @override
  String get zReportOpeningCash => 'Начальная наличность';

  @override
  String get zReportSalesCount => 'Кол-во продаж';

  @override
  String get zReportSalesTotal => 'Продажи (всего)';

  @override
  String get zReportReturnsTotal => 'Возвраты (всего)';

  @override
  String get zReportNet => 'Чистые продажи';

  @override
  String get zReportExpectedCash => 'Ожидаемая наличность';

  @override
  String get zReportCountedCash => 'Фактическая наличность';

  @override
  String get zReportDiff => 'Разница';

  @override
  String get returnsPickTitle => 'Выбор чека для возврата';

  @override
  String get returnsNoSales => 'Продажи не найдены';

  @override
  String get returnsLinesTitle => 'Строки возврата';

  @override
  String get returnsBack => 'Назад';

  @override
  String get returnsNoLines => 'Нет строк';

  @override
  String returnsLineSubtitle(String series, String qty, String price) {
    return 'Серия: $series • Продано: $qty • $price';
  }

  @override
  String get returnsSubmit => 'Возврат';

  @override
  String get returnsSelectAtLeastOne => 'Выберите хотя бы одну строку';

  @override
  String get returnsOfflineUnsupported => 'Возврат не поддерживается офлайн.';

  @override
  String get productsTitle => 'Товары';

  @override
  String get productsNew => 'Новый товар';

  @override
  String get productsSearchHint => 'Поиск (название или штрих-код)…';

  @override
  String get productsEmpty => 'Товар не найден';

  @override
  String get productColName => 'Название';

  @override
  String get productColBarcode => 'Штрих-код';

  @override
  String get productColGroup => 'Группа';

  @override
  String get productColUnit => 'Ед.';

  @override
  String get productColRx => 'Рецепт';

  @override
  String get productColActive => 'Активен';

  @override
  String get productActive => 'Активен';

  @override
  String get productInactive => 'Неактивен';

  @override
  String get productEditTitle => 'Изменить товар';

  @override
  String get productNewTitle => 'Новый товар';

  @override
  String get productName => 'Название *';

  @override
  String get productValName => 'Введите название товара';

  @override
  String get productBarcode => 'Штрих-код';

  @override
  String get productGroup => 'Группа товара';

  @override
  String get productManufacturer => 'Производитель';

  @override
  String get productUnit => 'Единица измерения';

  @override
  String get productMinStock => 'Минимальный остаток';

  @override
  String get productMinStockHelper => 'Ниже этого — «заканчивается»';

  @override
  String get productRx => 'Рецептурный препарат';

  @override
  String get productRxSubtitle => 'Продажа по рецепту';

  @override
  String get productActiveLabel => 'Активен';

  @override
  String get productCreate => 'Создать';

  @override
  String get productDeactivateDelete => 'Деактивировать / Удалить';

  @override
  String get productUpdated => 'Товар обновлён';

  @override
  String get productCreated => 'Товар создан';

  @override
  String get productDeleteTitle => 'Удаление товара';

  @override
  String productDeleteBody(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get productDeleted => 'Товар удалён';

  @override
  String get productPickerTitle => 'Выбор товара';

  @override
  String get productPickerSearchHint => 'Поиск или скан штрих-кода…';

  @override
  String get productPickerCreateNew => 'Создать новый товар';

  @override
  String get quickCreateTitle => 'Создать новый товар';

  @override
  String get quickCreateName => 'Название товара *';

  @override
  String get quickCreateNameHint => 'напр. Парацетамол 500мг №10';

  @override
  String get quickCreateNameRequired => 'Название обязательно';

  @override
  String get quickCreateGroup => 'Группа';

  @override
  String get quickCreateUnit => 'Единица';

  @override
  String get quickCreateMinStock => 'Минимальный остаток (необязательно)';

  @override
  String get quickCreateRx => 'По рецепту';

  @override
  String get quickCreateSubmit => 'Создать и добавить';

  @override
  String get refSuppliersTitle => 'Поставщики';

  @override
  String get refSupplierNew => 'Новый поставщик';

  @override
  String get refSupplierSearchHint => 'Поиск поставщика…';

  @override
  String get refSupplierEmpty => 'Поставщик не найден';

  @override
  String get refSupplierEntity => 'поставщик';

  @override
  String get refColInn => 'ИНН';

  @override
  String get refColPhone => 'Телефон';

  @override
  String get refSupplierValName => 'Введите название поставщика';

  @override
  String get refSupplierUpdated => 'Поставщик обновлён';

  @override
  String get refSupplierCreated => 'Поставщик создан';

  @override
  String get refSupplierDeleted => 'Поставщик удалён';

  @override
  String get refFieldAddress => 'Адрес';

  @override
  String get refManufacturersTitle => 'Производители';

  @override
  String get refManufacturerNew => 'Новый производитель';

  @override
  String get refManufacturerSearchHint => 'Поиск производителя…';

  @override
  String get refManufacturerEmpty => 'Производитель не найден';

  @override
  String get refManufacturerEntity => 'производитель';

  @override
  String get refColCountry => 'Страна';

  @override
  String get refManufacturerValName => 'Введите название производителя';

  @override
  String get refManufacturerUpdated => 'Производитель обновлён';

  @override
  String get refManufacturerCreated => 'Производитель создан';

  @override
  String get refManufacturerDeleted => 'Производитель удалён';

  @override
  String get refGroupsTitle => 'Группы';

  @override
  String get refGroupNew => 'Новая группа';

  @override
  String get refGroupSearchHint => 'Поиск группы…';

  @override
  String get refGroupEmpty => 'Группа не найдена';

  @override
  String get refGroupEntity => 'группа';

  @override
  String get refGroupValName => 'Введите название группы';

  @override
  String get refGroupUpdated => 'Группа обновлена';

  @override
  String get refGroupCreated => 'Группа создана';

  @override
  String get refGroupDeleted => 'Группа удалена';

  @override
  String get refUnitsTitle => 'Единицы';

  @override
  String get refUnitNew => 'Новая единица';

  @override
  String get refUnitSearchHint => 'Поиск единицы…';

  @override
  String get refUnitEmpty => 'Единица не найдена';

  @override
  String get refUnitEntity => 'единица';

  @override
  String get refUnitValName => 'Введите название единицы';

  @override
  String get refUnitUpdated => 'Единица обновлена';

  @override
  String get refUnitCreated => 'Единица создана';

  @override
  String get refUnitDeleted => 'Единица удалена';

  @override
  String get refColName => 'Название';

  @override
  String get refFieldName => 'Название *';

  @override
  String refEntityNew(String entity) {
    return 'Новый: $entity';
  }

  @override
  String refEntityEdit(String entity) {
    return 'Изменить: $entity';
  }

  @override
  String get refSearchHint => 'Поиск…';

  @override
  String refPickerSelect(String label) {
    return 'Выберите: $label';
  }

  @override
  String get refLoadError => 'Ошибка загрузки';

  @override
  String get writeOffTitle => 'Списание';

  @override
  String get writeOffSubtitle => 'Списание с остатка (истёк срок, повреждено…)';

  @override
  String get writeOffSubmit => 'Записать';

  @override
  String get writeOffReason => 'Причина *';

  @override
  String get writeOffNote => 'Примечание';

  @override
  String get writeOffAddBatch => 'Добавить партию';

  @override
  String get writeOffSaved => 'Списание записано.';

  @override
  String get writeOffEmptyDraft => 'Добавьте партию для списания.';

  @override
  String get writeOffHistoryTitle => 'Последние списания';

  @override
  String get writeOffHistoryEmpty => 'Списаний пока нет.';

  @override
  String get writeOffReasonExpired => 'Истёк срок';

  @override
  String get writeOffReasonDamaged => 'Повреждено';

  @override
  String get writeOffReasonLost => 'Утеряно';

  @override
  String get writeOffReasonOther => 'Другое';

  @override
  String get supplierReturnTitle => 'Возврат поставщику';

  @override
  String get supplierReturnSubtitle => 'Возврат партий поставщику';

  @override
  String get supplierReturnSubmit => 'Записать';

  @override
  String get supplierReturnSupplier => 'Поставщик';

  @override
  String get supplierReturnSelectSupplier => 'Выберите поставщика.';

  @override
  String get supplierReturnSaved => 'Возврат поставщику записан.';

  @override
  String get supplierReturnEmptyDraft => 'Добавьте партию для возврата.';

  @override
  String get supplierReturnHistoryTitle => 'Последние возвраты';

  @override
  String get supplierReturnHistoryEmpty => 'Возвратов пока нет.';

  @override
  String get inventoryTitle => 'Инвентаризация';

  @override
  String get inventorySubtitle => 'Подсчёт остатков и корректировка разницы';

  @override
  String get inventorySubmit => 'Записать';

  @override
  String get inventoryNote => 'Примечание';

  @override
  String get inventoryAddBatch => 'Добавить партию';

  @override
  String get inventorySavedNoDiff =>
      'Инвентаризация записана (расхождений нет).';

  @override
  String get inventoryDiscrepanciesTitle => 'Расхождения инвентаризации';

  @override
  String get inventoryColExpected => 'Ожидается';

  @override
  String get inventoryColCounted => 'Подсчитано';

  @override
  String get inventoryColDiff => 'Разница';

  @override
  String get inventoryOk => 'ОК';

  @override
  String get inventoryEmptyDraft => 'Добавьте партию для подсчёта.';

  @override
  String get inventoryCountedLabel => 'Подсчитано';

  @override
  String get inventoryHistoryTitle => 'Последние инвентаризации';

  @override
  String get inventoryHistoryEmpty => 'Инвентаризаций пока нет.';

  @override
  String get opColDate => 'Дата';

  @override
  String get opColNumber => 'Номер';

  @override
  String get opColLines => 'Строки';

  @override
  String get opColSupplier => 'Поставщик';

  @override
  String get opColReason => 'Причина';

  @override
  String get opValBranchUnresolved =>
      'Филиал ещё не определён. Попробуйте снова.';

  @override
  String get opValAtLeastOneBatch => 'Добавьте хотя бы одну партию.';

  @override
  String opValQtyPositive(String name) {
    return 'Кол-во «$name» должно быть больше нуля.';
  }

  @override
  String opValQtyMax(String name, String onHand) {
    return 'Кол-во «$name» превышает остаток ($onHand).';
  }

  @override
  String get opColDrug => 'Товар';

  @override
  String get opColSeries => 'Серия';

  @override
  String get opColRemaining => 'Остаток';

  @override
  String get opColDiscrepancy => 'Разница';

  @override
  String get opEmptyDefault => 'Добавьте партию.';

  @override
  String get opColQty => 'Кол-во';

  @override
  String get batchPickerTitle => 'Выбор партии';

  @override
  String get batchPickerSearchHint => 'Поиск товара или штрих-кода…';

  @override
  String get batchPickerEmpty => 'Партия не найдена';

  @override
  String batchPickerSubtitle(String series, String date) {
    return 'Серия: $series · до $date';
  }

  @override
  String batchPickerRemaining(String qty) {
    return 'Остаток: $qty';
  }

  @override
  String stockBatchesCount(int count) {
    return 'Партии ($count)';
  }

  @override
  String get stockNoBatchesOnPage => 'На текущей странице партий нет.';

  @override
  String get stockMovementsTitle => 'Движение товара';

  @override
  String get stockNoMovements => 'Движений нет';

  @override
  String get movementReceipt => 'Приход';

  @override
  String get movementSale => 'Продажа';

  @override
  String get movementReturn => 'Возврат';

  @override
  String get movementWriteOff => 'Списание';

  @override
  String get movementAdjustment => 'Корректировка';

  @override
  String get movementTransfer => 'Перемещение';

  @override
  String get syncTitle => 'Синхронизация';

  @override
  String get syncOnline => 'Онлайн';

  @override
  String get syncOffline => 'Офлайн';

  @override
  String syncInQueue(int count) {
    return '$count в очереди';
  }

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncConflictsTitle => 'Конфликты (conflict)';

  @override
  String syncError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get syncNoConflictsTitle => 'Конфликтов нет';

  @override
  String get syncNoConflictsBody =>
      'Все офлайн-продажи успешно синхронизированы.';

  @override
  String syncResult(int pushed, int conflicts, int failed) {
    return 'Синхрон.: $pushed принято, $conflicts конфликт, $failed не удалось.';
  }

  @override
  String syncSaleAt(String time) {
    return 'Продажа $time';
  }

  @override
  String get syncConflictFallback => 'Недостаточно остатка на сервере.';

  @override
  String get syncDismiss => 'Отклонить';

  @override
  String get syncDismissed => 'Конфликт отклонён.';
}

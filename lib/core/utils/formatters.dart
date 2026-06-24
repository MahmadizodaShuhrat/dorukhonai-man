import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Money/date formatting helpers backed by `intl` (TZ §6: somoni format).
///
/// The numeric/date locale follows the app's active UI language so digit
/// grouping and date rendering match the chosen language. [setLocale] is called
/// from `LocaleController` whenever the user switches language; the call sites
/// stay simple (`Formatters.money(x)`), no `BuildContext` needed.
class Formatters {
  Formatters._();

  /// Active intl locale. Both Tajik (`tg`) and Russian (`ru`) use the same
  /// `1 234,56` grouping; `ru` is used for `tg` because intl ships no `tg`
  /// number/date data (mirrors the tg→ru Material fallback).
  static String _intlLocale = 'ru';

  static NumberFormat _money = _buildMoney(_intlLocale);
  // The date patterns are fully explicit (numeric `dd.MM.yyyy`), so they render
  // identically for tg/ru without needing locale-specific symbol data loaded.
  static final DateFormat _date = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy HH:mm');

  static NumberFormat _buildMoney(String locale) => NumberFormat.currency(
    locale: locale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.moneyFractionDigits,
  );

  /// Switches the numeric formatting locale to match the active UI language.
  /// `tg` (and any unknown code) maps onto `ru`'s number data, since intl ships
  /// no `tg` locale data (mirrors the tg→ru Material fallback). Both languages
  /// use the same `1 234,56` grouping, so display is consistent either way.
  static void setLocale(String languageCode) {
    const resolved = 'ru';
    if (resolved == _intlLocale) return;
    _intlLocale = resolved;
    _money = _buildMoney(resolved);
  }

  /// Formats an amount as somoni, e.g. `12.50 сом.`.
  static String money(num amount) => _money.format(amount);

  /// Formats a date as `dd.MM.yyyy`.
  static String date(DateTime value) => _date.format(value);

  /// Formats a date-time as `dd.MM.yyyy HH:mm`.
  static String dateTime(DateTime value) => _dateTime.format(value);
}

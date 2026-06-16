import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Money/date formatting helpers backed by `intl` (TZ §6: somoni format).
class Formatters {
  Formatters._();

  static final NumberFormat _money = NumberFormat.currency(
    locale: 'ru',
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.moneyFractionDigits,
  );

  static final DateFormat _date = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy HH:mm');

  /// Formats an amount as somoni, e.g. `12.50 сом.`.
  static String money(num amount) => _money.format(amount);

  /// Formats a date as `dd.MM.yyyy`.
  static String date(DateTime value) => _date.format(value);

  /// Formats a date-time as `dd.MM.yyyy HH:mm`.
  static String dateTime(DateTime value) => _dateTime.format(value);
}

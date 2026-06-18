import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final NumberFormat _kesFormat = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KSh ',
    decimalDigits: 0,
  );

  static final NumberFormat _kesFormatDetailed = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KSh ',
    decimalDigits: 2,
  );

  static String formatKes(double amount) {
    return _kesFormat.format(amount);
  }

  static String formatKesDetailed(double amount) {
    return _kesFormatDetailed.format(amount);
  }

  static String formatPricePerHour(double hourlyRate) {
    return '${_kesFormat.format(hourlyRate)}/hr';
  }

  static String formatPricePerDay(double dailyRate) {
    return '${_kesFormat.format(dailyRate)}/day';
  }

  static String formatPriceRange(double min, double max) {
    return '${_kesFormat.format(min)} - ${_kesFormat.format(max)}';
  }

  static double? parseKes(String value) {
    final cleaned = value.replaceAll(RegExp(r'[KSh,\s]'), '');
    return double.tryParse(cleaned);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'KSh ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'KSh ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return _kesFormat.format(amount);
  }

  static String getCurrencyCode() {
    return AppConstants.defaultCurrency;
  }

  static String getCurrencySymbol() {
    return 'KSh';
  }
}

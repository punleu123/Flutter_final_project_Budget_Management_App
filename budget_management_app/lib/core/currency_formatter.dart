import 'package:intl/intl.dart';

/// Currency formatter for displaying amounts with exchange rate conversion
class CurrencyFormatter {
  static String usdFormatter = '\$';
  static String khrFormatter = '៛';

  /// Exchange rate: 1 USD = 4000 KHR
  static const double exchangeRate = 4000.0;

  /// Format amount with currency symbol and exchange rate conversion
  ///
  /// [amount] - The amount in USD (base currency)
  /// [currency] - Currency to display in ('USD' or 'KHR')
  static String format(double amount, {required String currency}) {
    // Convert amount based on currency
    final displayAmount = currency == 'USD' ? amount : amount * exchangeRate;

    final formatter = NumberFormat.currency(
      symbol: currency == 'USD' ? usdFormatter : khrFormatter,
      decimalDigits: currency == 'USD' ? 2 : 0,
    );
    return formatter.format(displayAmount);
  }

  /// Format amount without currency symbol
  static String formatAmount(double amount, {required String currency}) {
    // Convert amount based on currency
    final displayAmount = currency == 'USD' ? amount : amount * exchangeRate;

    final decimalDigits = currency == 'USD' ? 2 : 0;
    return displayAmount.toStringAsFixed(decimalDigits);
  }

  /// Parse formatted string back to double (in base USD)
  static double parse(String formattedAmount) {
    // Remove currency symbols and whitespace
    final cleaned = formattedAmount
        .replaceAll(RegExp(r'[^\d.\-]'), '')
        .replaceAll(' ', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Get currency symbol
  static String getSymbol(String currency) {
    return currency == 'USD' ? usdFormatter : khrFormatter;
  }

  /// Format percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Convert USD to KHR
  static double usdToKhr(double usd) {
    return usd * exchangeRate;
  }

  /// Convert KHR to USD
  static double khrToUsd(double khr) {
    return khr / exchangeRate;
  }
}

import 'package:intl/intl.dart';

String formatCurrency(
    double value, {
      required String symbol,
      required String locale,
      int decimalDigits = 0,
    }) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: decimalDigits,
  );

  return formatter.format(value);
}

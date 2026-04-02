import 'currency_helper.dart';
import '../models/market_hub.dart';
import '../services/exchange_rate_service.dart';

String formatMoneyByHub(
    double value, {
      required MarketHub hub,
      bool showConverted = true,
    }) {
  final rate = ExchangeRateService.usdToBrl;

  // --- Florida (USD base) ---
  if (hub.isUsd) {
    final usdText = formatCurrency(
      value,
      symbol: '\$ ',
      locale: 'en_US',
      decimalDigits: 0,
    );

    if (!showConverted || rate <= 0) return usdText;

    final brl = value * rate;
    final brlText = formatCurrency(
      brl,
      symbol: 'R\$ ',
      locale: 'pt_BR',
      decimalDigits: 0,
    );

    return '$usdText ($brlText)';
  }

  // --- São Paulo (BRL base) ---
  final brlText = formatCurrency(
    value,
    symbol: 'R\$ ',
    locale: 'pt_BR',
    decimalDigits: 0,
  );

  if (!showConverted || rate <= 0) return brlText;

  final usd = value / rate;
  final usdText = formatCurrency(
    usd,
    symbol: '\$ ',
    locale: 'en_US',
    decimalDigits: 0,
  );

  return '$brlText ($usdText)';
}

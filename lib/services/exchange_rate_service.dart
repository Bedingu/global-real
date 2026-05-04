import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static double _usdToBrl = 5.0; // fallback seguro
  static double get usdToBrl => _usdToBrl;

  static Future<void> fetchUsdToBrl() async {
    // Tenta a API principal (Banco Central do Brasil)
    try {
      final res = await http.get(Uri.parse(
        'https://economia.awesomeapi.com.br/json/last/USD-BRL',
      ));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final bid = data['USDBRL']?['bid'];
        if (bid != null) {
          _usdToBrl = double.parse(bid.toString());
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro na API principal de câmbio: $e');
    }

    // Fallback: API alternativa
    try {
      final res = await http.get(Uri.parse(
        'https://open.er-api.com/v6/latest/USD',
      ));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final brl = data['rates']?['BRL'];
        if (brl != null) {
          _usdToBrl = (brl as num).toDouble();
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro na API fallback de câmbio: $e');
    }

    debugPrint('⚠️ Usando câmbio fallback: $_usdToBrl');
  }
}

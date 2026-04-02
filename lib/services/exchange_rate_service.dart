import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static double _usdToBrl = 5.0; // fallback seguro
  static double get usdToBrl => _usdToBrl;

  static Future<void> fetchUsdToBrl() async {
    try {
      final res = await http.get(Uri.parse(
        'https://api.exchangerate.host/latest?base=USD&symbols=BRL',
      ));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _usdToBrl = (data['rates']['BRL'] as num).toDouble();
      }
    } catch (err) {
      print('Erro ao buscar taxa USD/BRL → fallback: $_usdToBrl');
    }
  }
}

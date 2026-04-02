import '../../models/private/FII_IPO.dart';

class FiiRepository {

  /// 🔹 Simulação de busca externa (mock)
  Future<List<FiiModel>> fetchFiis() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final List<Map<String, dynamic>> response = [
      {
        "ticker": "HGLG11",
        "name": "CSHG Logística",
        "type": "tijolo",
        "segment": "Logística",
        "price": 164.20,
        "dividend_yield": 0.85,
      },
      {
        "ticker": "VISC11",
        "name": "Vinci Shopping Centers",
        "type": "tijolo",
        "segment": "Shoppings",
        "price": 118.40,
        "dividend_yield": 0.92,
      },
      {
        "ticker": "KNCR11",
        "name": "Kinea Rendimentos",
        "type": "papel",
        "segment": "CDI",
        "price": 102.15,
        "dividend_yield": 1.10,
      },
    ];

    return response
        .map((json) => FiiModel.fromJson(json))
        .toList();
  }
}
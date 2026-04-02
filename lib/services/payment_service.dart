import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<void> startCheckout(String priceId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final session = supabase.auth.currentSession;

    if (user == null || session == null) {
      throw Exception("Usuário não logado");
    }

    final accessToken = session.accessToken;

    final uri = Uri.parse(
      'https://pcbwbndrnnqptxdbrqnm.functions.supabase.co/create-checkout-session',
    );

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({
        "priceId": priceId,
        "successUrl": kIsWeb
            ? "https://app.globalrealestate.com.br/sucesso"
            : "myapp://checkout-success",
        "cancelUrl": kIsWeb
            ? "https://app.globalrealestate.com.br/cancelado"
            : "myapp://checkout-cancel",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("[STRIPE ERROR] ${response.statusCode}: ${response.body}");
    }

    final data = jsonDecode(response.body);

    if (data['url'] == null) {
      throw Exception("[STRIPE] Resposta inválida: ${response.body}");
    }

    final checkoutUrl = data['url'];
    final url = Uri.parse(checkoutUrl);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir o checkout");
    }
  }
}

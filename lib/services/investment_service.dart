import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/investment.dart';

class InvestmentService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Investment>> fetchInvestments() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final response = await _supabase
        .from('investments')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response
        .map<Investment>((json) => Investment.fromJson(json))
        .toList();
  }
}

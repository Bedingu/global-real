import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/investment.dart';

class InvestmentService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Investment>> fetchInvestments() async {
    final response = await _supabase
        .from('investments')
        .select('id, name, city, country, amount, currency')
        .order('created_at');

    return response.map<Investment>((json) {
      return Investment.fromJson(json);
    }).toList();
  }
}

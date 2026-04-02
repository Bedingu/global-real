import 'package:supabase_flutter/supabase_flutter.dart';

class FractionRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchFractionsByDevelopment(
      String developmentId) async {
    final response = await _client
        .from('fractions')
        .select()
        .eq('development_id', developmentId);

    return response;
  }

  Future<List<Map<String, dynamic>>> fetchWeeks(String developmentId) async {
    final response = await _client
        .from('fraction_weeks')
        .select()
        .eq('development_id', developmentId);

    return response;
  }

  Future<void> reserveWeek({
    required String investmentId,
    required DateTime weekStart,
  }) async {
    await _client.from('fraction_reservations').insert({
      'fraction_investment_id': investmentId,
      'week_start_date': weekStart.toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchReservations() {
    return _client
        .from('fraction_reservations')
        .stream(primaryKey: ['id']);
  }
}
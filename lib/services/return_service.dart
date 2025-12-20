import 'package:supabase_flutter/supabase_flutter.dart';

class ReturnPoint {
  final DateTime month;
  final double total;

  ReturnPoint(this.month, this.total);
}

class ReturnService {
  static final _supabase = Supabase.instance.client;

  static Future<List<ReturnPoint>> fetchMonthlyReturns() async {
    final List<dynamic> res =
    await _supabase.rpc('monthly_returns');

    return res.map<ReturnPoint>((row) {
      return ReturnPoint(
        DateTime.parse(row['month']),
        (row['total'] as num).toDouble(),
      );
    }).toList();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/private/stock_item.dart';

class StockService {
  static final _supabase = Supabase.instance.client;

  static Future<List<StockItem>> fetchStockItems() async {
    final data = await _supabase
        .from('stock_items')
        .select()
        .gt('available_units', 0)
        .order('created_at', ascending: false);

    return (data as List).map((j) => StockItem.fromJson(j)).toList();
  }
}

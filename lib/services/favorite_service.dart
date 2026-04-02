import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  static final _supabase = Supabase.instance.client;

  static Future<Set<String>> fetchFavoriteIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    final res = await _supabase
        .from('favorites')
        .select('development_id')
        .eq('user_id', user.id);

    return res
        .map<String>((e) => e['development_id'].toString())
        .toSet();
  }

  static Future<bool> isFavorite(String developmentId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final res = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', user.id)
        .eq('development_id', developmentId)
        .maybeSingle();

    return res != null;
  }

  static Future<void> addFavorite(String developmentId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('favorites').insert({
      'user_id': user.id,
      'development_id': developmentId,
    });
  }

  static Future<void> removeFavorite(String developmentId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('development_id', developmentId);
  }
}

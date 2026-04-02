import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // =============================
  // AUTH
  // =============================

  /// LOGIN
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Falha no login');
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// USUÁRIO LOGADO? (compatível com FutureBuilder)
  static Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  /// ID DO USUÁRIO ATUAL
  static String? currentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // =============================
  // PREMIUM (SUPABASE)
  // =============================

  /// VERIFICA SE O USUÁRIO É PREMIUM
  static Future<bool> isPremiumUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final data = await _supabase
        .from('profiles')
        .select('is_premium, subscription_status')
        .eq('id', user.id)
        .single();

    return data['is_premium'] == true &&
        data['subscription_status'] == 'active';
  }
}

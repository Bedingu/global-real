import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// LOGIN REAL
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

  /// AUTO-LOGIN
  static Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  /// USUÁRIO ATUAL
  static String? currentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}

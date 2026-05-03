import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handler para mensagens em background (precisa ser top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 Background message: ${message.notification?.title}');
}

class PushNotificationService {
  static final _supabase = Supabase.instance.client;

  /// Inicializa o serviço de push notifications.
  static Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Registrar handler de background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Solicitar permissão no iOS
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ Push notifications autorizadas');

        // Obter token
        final token = await messaging.getToken();
        if (token != null) {
          debugPrint('📱 Push token: ${token.substring(0, 20)}...');
          await _saveToken(token);
        }

        // Escutar mudanças de token
        messaging.onTokenRefresh.listen(_saveToken);

        // Handler para mensagens em foreground
        FirebaseMessaging.onMessage.listen((message) {
          debugPrint('📩 Foreground: ${message.notification?.title}');
        });

        // Handler quando app é aberto via notificação
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          debugPrint('📩 Opened app: ${message.data}');
        });
      } else {
        debugPrint('⚠️ Push notifications não autorizadas');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao inicializar push notifications: $e');
    }
  }

  /// Salva o token do device no Supabase
  static Future<void> _saveToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('push_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');

      debugPrint('✅ Push token salvo no Supabase');
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar push token: $e');
    }
  }
}

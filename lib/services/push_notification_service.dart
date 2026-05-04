import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  /// Chave do navigator — deve ser setada pelo MyApp
  static GlobalKey<NavigatorState>? navigatorKey;

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
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Verificar se o app foi aberto por uma notificação (cold start)
        final initialMessage = await messaging.getInitialMessage();
        if (initialMessage != null) {
          // Delay pra garantir que o navigator está pronto
          Future.delayed(const Duration(milliseconds: 500), () {
            _handleNotificationTap(initialMessage);
          });
        }
      } else {
        debugPrint('⚠️ Push notifications não autorizadas');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao inicializar push notifications: $e');
    }
  }

  /// Navega pra tela correta baseado nos dados da notificação.
  ///
  /// Dados esperados no payload da notificação:
  /// - `route`: rota pra navegar (ex: "/leads", "/dashboard")
  /// - `lead_id`: ID do lead pra abrir o chat
  /// - `development_id`: ID do empreendimento pra abrir detalhes
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String?;

    debugPrint('📩 Deep link: $data');

    final navigator = navigatorKey?.currentState;
    if (navigator == null) {
      debugPrint('⚠️ Navigator não disponível pra deep link');
      return;
    }

    if (route != null && route.isNotEmpty) {
      navigator.pushNamed(route);
    } else {
      // Fallback: abre o dashboard
      navigator.pushNamed('/dashboard');
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

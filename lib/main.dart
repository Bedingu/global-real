import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'theme.dart';
import 'pages/public_home_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/success_page.dart';
import 'pages/cancel_page.dart';
import 'pages/login_page.dart';
import 'pages/delete_account_page.dart';
import 'pages/leads/leads_page.dart';
import 'pages/crm/crm_dashboard_page.dart';
import 'generated/app_localizations.dart';

import 'services/auth_service.dart';
import 'services/exchange_rate_service.dart';
import 'services/lead_scoring_service.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Wrap toda inicialização em try/catch para nunca crashar na abertura
  try {
    // 0) Inicializar Firebase (push notifications + crashlytics)
    if (!kIsWeb) {
      try {
        await Firebase.initializeApp();
        debugPrint('✅ Firebase inicializado');

        // Crashlytics: capturar erros Flutter
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

        // Crashlytics: capturar erros assíncronos
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } catch (e) {
        debugPrint('⚠️ Erro ao inicializar Firebase: $e');
      }
    }

    // 1) Carregar variáveis de ambiente
    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (e) {
      debugPrint("⚠️ Erro ao carregar .env: $e");
    }

    // 2) Ler variáveis de ambiente (sem fallback hardcoded)
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint('❌ SUPABASE_URL ou SUPABASE_ANON_KEY não configurados no .env');
    }

    // 3) Inicializar Supabase
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        debugPrint("✅ Supabase inicializado: $supabaseUrl");
      } catch (e) {
        debugPrint("❌ Erro ao inicializar Supabase: $e");
      }
    }

    // 4) Buscar câmbio inicial (opcional, com timeout)
    try {
      await ExchangeRateService.fetchUsdToBrl().timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint("⚠️ Timeout ao buscar câmbio"),
      );
    } catch (e) {
      debugPrint("⚠️ Erro ao buscar câmbio USD/BRL: $e");
    }

    // 5) Carregar regras de scoring
    try {
      await LeadScoringService.loadRules();
    } catch (e) {
      debugPrint("⚠️ Erro ao carregar regras de scoring: $e");
    }

    // 5.1) Carregar role do usuário (se logado)
    try {
      if (await AuthService.isLoggedIn()) {
        await AuthService.getUserRole();
      }
    } catch (e) {
      debugPrint("⚠️ Erro ao carregar role: $e");
    }

    // 6) Inicializar push notifications (só mobile)
    if (!kIsWeb) {
      try {
        await PushNotificationService.initialize();
      } catch (e) {
        debugPrint("⚠️ Erro ao inicializar push: $e");
      }
    }
  } catch (e) {
    debugPrint("❌ Erro fatal na inicialização: $e");
  }

  // 6) Rodar o app — SEMPRE, mesmo se algo falhou acima
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('pt');

  /// Chave global do navigator pra deep linking via push notifications
  static final navigatorKey = GlobalKey<NavigatorState>();

  void _changeLanguage(Locale locale) {
    setState(() => _locale = locale);
  }

  /// Protege rotas que exigem autenticação
  Widget _authGuard(Widget page) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) return page;
        return const LoginPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Conectar navigator key ao push notification service
    PushNotificationService.navigatorKey = navigatorKey;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Global Real',
      theme: AppTheme.lightTheme,

      // Internacionalização
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      onGenerateRoute: (settings) {
        // Rotas nomeadas para deep links (Stripe redirect, etc.)
        switch (settings.name) {
          case '/sucesso':
            return MaterialPageRoute(builder: (_) => const SuccessPage());
          case '/cancelado':
            return MaterialPageRoute(builder: (_) => const CancelPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/excluir-conta':
            return MaterialPageRoute(builder: (_) => const DeleteAccountPage());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => _authGuard(const DashboardPage()));
          case '/leads':
            return MaterialPageRoute(builder: (_) => _authGuard(const LeadsPage()));
          default:
            return MaterialPageRoute(
              builder: (_) => FutureBuilder<bool>(
                future: AuthService.isLoggedIn(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.data == true) {
                    return const DashboardPage();
                  }
                  return PublicHomePage(
                    onChangeLanguage: _changeLanguage,
                  );
                },
              ),
            );
        }
      },
    );
  }
}

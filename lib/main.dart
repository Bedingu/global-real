import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // 1) Carregar variáveis de ambiente diferenciando WEB vs MOBILE/DESKTOP
  try {
    if (kIsWeb) {
      // No web o .env precisa estar dentro de assets/
      await dotenv.load(fileName: 'assets/.env');
    } else {
      // No mobile/desktop pode ficar na raiz
      await dotenv.load(fileName: '.env');
    }
  } catch (e) {
    debugPrint("⚠️ Erro ao carregar .env: $e");
  }

  // 2) Ler variáveis com fallback
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // 3) Inicializar Supabase se as chaves existirem
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
  } else {
    debugPrint("❌ SUPABASE_URL ou SUPABASE_ANON_KEY não definidas no .env");
  }

  // 4) Buscar câmbio inicial (opcional)
  try {
    await ExchangeRateService.fetchUsdToBrl();
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

  // 6) Rodar o app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('pt');

  void _changeLanguage(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            return MaterialPageRoute(builder: (_) => const DashboardPage());
          case '/leads':
            return MaterialPageRoute(builder: (_) => const LeadsPage());
          case '/crm':
            return MaterialPageRoute(builder: (_) => const CrmDashboardPage());
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

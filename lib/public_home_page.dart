import 'package:flutter/material.dart';
import 'theme.dart';
import 'generated/app_localizations.dart';
import 'login_page.dart';

class PublicHomePage extends StatelessWidget {
  final void Function(Locale) onChangeLanguage;

  const PublicHomePage({
    super.key,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🌐 Botão de idioma
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.language, color: Colors.white),
                  onPressed: () {
                    final locale = Localizations.localeOf(context);

                    if (locale.languageCode == 'pt') {
                      onChangeLanguage(const Locale('en'));
                    } else {
                      onChangeLanguage(const Locale('pt'));
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Logo
              Image.asset(
                'assets/images/logo_global_real.png',
                height: 64,
              ),

              const SizedBox(height: 48),

              // 🔹 Headline
              Text(
                AppLocalizations.of(context)!.headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Subheadline
              Text(
                AppLocalizations.of(context)!.subheadline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 48),

              // 🔹 Cards de autoridade
              Row(
                children: [
                  Expanded(
                    child: _AuthorityCard(
                      title: AppLocalizations.of(context)!.authority_curation,
                      description:
                      AppLocalizations.of(context)!.authority_curation_desc,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AuthorityCard(
                      title: AppLocalizations.of(context)!.authority_curation,
                      description:
                      AppLocalizations.of(context)!.authority_curation_desc,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _AuthorityCard(
                title: AppLocalizations.of(context)!.authority_curation,
                description:
                AppLocalizations.of(context)!.authority_curation_desc,
                fullWidth: true,
              ),

              const Spacer(),

              // 🔹 Botão Criar Conta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: navegar para signup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                  child: Text(AppLocalizations.of(context)!.signup),
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Botão Login
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: Text(AppLocalizations.of(context)!.login),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Card de autoridade
class _AuthorityCard extends StatelessWidget {
  final String title;
  final String description;
  final bool fullWidth;

  const _AuthorityCard({
    required this.title,
    required this.description,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth
          ? double.infinity
          : (MediaQuery.of(context).size.width - 72) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

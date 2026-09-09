import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'dashboard/dashboard_page.dart';
import 'public_home_page.dart';
import 'prototype/teaser_showcase_page.dart';

/// Tela de entrada pós-login.
///
/// Em vez de jogar o usuário direto no dashboard, deixa ele escolher a frente
/// que quer consumir: o Curso / Vídeo-aulas ou o Portfólio de Investimentos.
/// Alinha a entrada do app aos dois pilares do reposicionamento (aprender vs.
/// operar o portfólio), sem alterar o Dashboard ou a PrivatePage existentes.
class HubPage extends StatelessWidget {
  const HubPage({super.key});

  // Paleta escura, coerente com PrivatePage / PublicHomePage.
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1628),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo_global_real.png', height: 32),
            const SizedBox(width: 10),
            const Text('Global Real', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicHomePage(onChangeLanguage: (_) {}),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Suas oportunidades na Global',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Domine a venda de fundos imobiliários, associe-se e negocie os investimentos com maior demanda da América Latina.',
                    style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _courseCard(context)),
                            const SizedBox(width: 20),
                            Expanded(child: _portfolioCard(context)),
                          ],
                        )
                      : Column(
                          children: [
                            _courseCard(context),
                            const SizedBox(height: 20),
                            _portfolioCard(context),
                          ],
                        ),
                  const SizedBox(height: 28),
                  _skipToDashboard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Card 1: Curso / Vídeo-aulas ───────────────────────
  Widget _courseCard(BuildContext context) {
    return _choiceCard(
      context: context,
      accent: _gold,
      icon: Icons.play_circle_outline,
      tag: 'Aprenda',
      title: 'Curso e Vídeo-aulas',
      description:
          'Aprenda a vender fundos via SCP e imóveis para investidores. '
          'Trilhas de conteúdo, do básico ao avançado.',
      bullets: const [
        'Trilhas Varejo e Private',
        'Aulas em vídeo no seu ritmo',
        'Certificado ao concluir',
      ],
      cta: 'Acessar aulas',
      onTap: () => _openCourse(context),
    );
  }

  // ── Card 2: Portfólio de Investimentos ────────────────
  Widget _portfolioCard(BuildContext context) {
    return _choiceCard(
      context: context,
      accent: _blue,
      icon: Icons.trending_up,
      tag: 'Opere',
      title: 'Portfólio de Investimentos',
      description:
          'Explore o portfólio da Global em São Paulo: empreendimentos, '
          'rentabilidade e simulações para levar ao investidor.',
      bullets: const [
        'Catálogo de empreendimentos',
        'Simulações de rentabilidade',
        'Leads e funil de vendas',
      ],
      cta: 'Ver portfólio',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      },
    );
  }

  Widget _choiceCard({
    required BuildContext context,
    required Color accent,
    required IconData icon,
    required String tag,
    required String title,
    required String description,
    required List<String> bullets,
    required String cta,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor:
                      accent == _gold ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  cta,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Acesso ao Curso ───────────────────────────────────
  // Leva à vitrine de prévias (teasers). Lá dentro, o CTA de desbloquear
  // checa premium e abre o paywall se necessário.
  void _openCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeaserShowcasePage()),
    );
  }

  Widget _skipToDashboard(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        ),
        icon: const Icon(Icons.dashboard_outlined,
            size: 16, color: Colors.white38),
        label: const Text(
          'Ir direto para o painel',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}

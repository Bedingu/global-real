import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../generated/app_localizations.dart';
import '../models/development.dart';
import '../helpers/revenue_calculator.dart';
import '../helpers/hub_currency_helper.dart';
import 'login_page.dart';
import 'signup_page.dart';

class PublicHomePage extends StatefulWidget {
  final void Function(Locale) onChangeLanguage;

  const PublicHomePage({
    super.key,
    required this.onChangeLanguage,
  });

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  final ScrollController _scrollController = ScrollController();

  // Cores do app
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _blue = Color(0xFF232845);

  static const _carouselImages = [
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1200&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200&q=80',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&q=80',
    'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200&q=80',
    'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=1200&q=80',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _navigateSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    final contentWidth = isWide ? 1100.0 : screenWidth;

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ═══ NAVBAR ═══
            _buildNavbar(t, isWide),

            // ═══ HERO ═══
            _buildHero(t, isWide, contentWidth),

            // ═══ DESTAQUE: SENIOR LIVING ═══
            _buildFeaturedDevelopment(t, isWide, contentWidth),

            // ═══ GUIA DO INVESTIDOR ═══
            _buildInvestorGuide(t, isWide, contentWidth),

            // ═══ POR QUE INVESTIR ═══
            _buildWhyInvest(t, isWide, contentWidth),

            // ═══ NÚMEROS ═══
            _buildNumbers(t, isWide, contentWidth),

            // ═══ CTA FINAL ═══
            _buildFinalCta(t, isWide, contentWidth),

            // ═══ FOOTER ═══
            _buildFooter(t, isWide, contentWidth),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // NAVBAR
  // ═══════════════════════════════════════
  Widget _buildNavbar(AppLocalizations t, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: isWide ? 16 : 10),
      color: _blue,
      child: Row(
        children: [
          Image.asset('assets/images/logo_global_real.png', height: isWide ? 88 : 48),
          const Spacer(),
          // Idioma
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: Colors.white70, size: 20),
            color: _card,
            onSelected: (locale) => widget.onChangeLanguage(locale),
            itemBuilder: (_) => const [
              PopupMenuItem(value: Locale('pt'), child: Text('🇧🇷  Português', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: Locale('en'), child: Text('🇺🇸  English', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: Locale('es'), child: Text('🇪🇸  Español', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: Locale('zh'), child: Text('🇨🇳  中文', style: TextStyle(color: Colors.white))),
            ],
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _navigateLogin,
            child: Text(t.login, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _navigateSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(t.signup, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════
  Widget _buildHero(AppLocalizations t, bool isWide, double contentWidth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_blue, _bg],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _heroText(t)),
                      const SizedBox(width: 48),
                      Expanded(child: _heroImage()),
                    ],
                  )
                : Column(
                    children: [
                      _heroText(t),
                      const SizedBox(height: 32),
                      _heroImage(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _heroText(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.headline,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
        ),
        const SizedBox(height: 16),
        Text(
          t.subheadline,
          style: const TextStyle(fontSize: 16, color: Colors.white60, height: 1.5),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _navigateSignup,
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: const Text('Comece Agora', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _navigateLogin,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Acessar App', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        _carouselImages[0],
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ═══════════════════════════════════════
  // DESTAQUE: SENIOR LIVING ALBERT EINSTEIN
  // ═══════════════════════════════════════
  Widget _buildFeaturedDevelopment(AppLocalizations t, bool isWide, double contentWidth) {
    const featuredImage = 'https://pcbwbndrnnqptxdbrqnm.supabase.co/storage/v1/object/public/development-images/senior-living/page39_img01_1280x720.jpeg';
    const secondImage = 'https://pcbwbndrnnqptxdbrqnm.supabase.co/storage/v1/object/public/development-images/senior-living/page43_img01_4396x2473.jpeg';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
            child: Column(
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: _gold, size: 14),
                      SizedBox(width: 6),
                      Text('Empreendimento em Destaque',
                          style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Senior Living Albert Einstein',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Higienópolis, São Paulo — O primeiro Senior Living com a chancela Albert Einstein',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 32),

                // Images
                isWide
                    ? Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(featuredImage, height: 320, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(height: 320, color: _card)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(secondImage, height: 152, width: double.infinity, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(height: 152, color: _card)),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    'https://pcbwbndrnnqptxdbrqnm.supabase.co/storage/v1/object/public/development-images/senior-living/page44_img01_4396x2473.jpeg',
                                    height: 152, width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(height: 152, color: _card),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(featuredImage, height: 220, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 220, color: _card)),
                      ),

                const SizedBox(height: 32),

                // Metrics
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _featuredMetric('R\$ 16.900', 'Preço/m² entrada'),
                    _featuredMetric('R\$ 30.000', 'Preço/m² saída estimada'),
                    _featuredMetric('70,5%', 'ROI projetado'),
                    _featuredMetric('22%', 'TIR/IRR a.a.'),
                    _featuredMetric('36 meses', 'Prazo de entrega'),
                    _featuredMetric('R\$ 200 mil', 'Entrada a partir de'),
                  ],
                ),

                const SizedBox(height: 32),

                // CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _navigateSignup,
                      icon: const Icon(Icons.rocket_launch, size: 18),
                      label: const Text('Quero Investir', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openWhatsApp(),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('Falar com Consultor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featuredMetric(String value, String label) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // AUTORIDADE (3 cards)
  // ═══════════════════════════════════════
  Widget _buildAuthoritySection(AppLocalizations t, bool isWide, double contentWidth) {
    final cards = [
      _AuthCardData(Icons.verified, t.authority_curation, t.authority_curation_desc),
      _AuthCardData(Icons.insights, t.authority_strategy, t.authority_strategy_desc),
      _AuthCardData(Icons.psychology, t.authority_intelligence, t.authority_intelligence_desc),
    ];

    return Container(
      width: double.infinity,
      color: _bg,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: isWide
                ? Row(
                    children: cards
                        .map((c) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _authorityCard(c),
                              ),
                            ))
                        .toList(),
                  )
                : Column(
                    children: cards.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _authorityCard(c),
                    )).toList(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _authorityCard(_AuthCardData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: _gold, size: 28),
          const SizedBox(height: 14),
          Text(data.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(data.desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // LANÇAMENTOS (dinâmico do Supabase)
  // ═══════════════════════════════════════
  Widget _buildLaunchesSection(AppLocalizations t, bool isWide, double contentWidth) {
    return Container(
      width: double.infinity,
      color: _card,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                const Text('Lançamentos', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Empreendimentos selecionados com alto potencial de retorno',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 32),
                FutureBuilder<List<Development>>(
                  future: _fetchFeaturedDevelopments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: _gold));
                    }
                    final devs = snapshot.data ?? [];
                    if (devs.isEmpty) {
                      return const Text('Nenhum empreendimento disponível', style: TextStyle(color: Colors.white38));
                    }
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: devs.map((dev) => SizedBox(
                        width: isWide ? (contentWidth - 96) / 4 : contentWidth - 48,
                        child: _developmentCard(dev),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Development>> _fetchFeaturedDevelopments() async {
    try {
      final data = await Supabase.instance.client
          .from('developments')
          .select()
          .order('created_at', ascending: false)
          .limit(8);
      return (data as List).map((j) => Development.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Widget _developmentCard(Development dev) {
    final imageUrl = dev.images.isNotEmpty && dev.images.first.startsWith('http')
        ? dev.images.first
        : _carouselImages[dev.name.hashCode.abs() % _carouselImages.length];

    final revenue = calculateMonthlyRevenue(
      avgDailyRate: dev.avgDailyRate,
      occupancyRate: dev.occupancyRate,
      cleaningFee: dev.cleaningFee,
      condoFeeMonthly: dev.condoFeeMonthly,
      managementFeePct: dev.managementFeePct,
    );

    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 140, color: _card,
              child: const Center(child: Icon(Icons.apartment, color: Colors.white24, size: 32)))),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dev.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(dev.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniMetric('Occ', '${dev.occupancyRate.toStringAsFixed(0)}%'),
                    _miniMetric('ADR', formatMoneyByHub(dev.avgDailyRate, hub: dev.hub)),
                    _miniMetric('Rev', formatMoneyByHub(revenue.grossMonthly, hub: dev.hub)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: _gold, fontWeight: FontWeight.w700, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }

  // ═══════════════════════════════════════
  // GUIA DO INVESTIDOR
  // ═══════════════════════════════════════
  Widget _buildInvestorGuide(AppLocalizations t, bool isWide, double contentWidth) {
    final steps = [
      _StepData(Icons.flag_outlined, 'Defina seus objetivos', 'Identifique se seu foco é renda mensal, valorização patrimonial ou diversificação.'),
      _StepData(Icons.person_outline, 'Conheça seu perfil', 'Entenda sua tolerância a risco e horizonte de retorno para escolher os projetos certos.'),
      _StepData(Icons.search, 'Analise as oportunidades', 'Avalie empreendimentos com base em localização, potencial de valorização e liquidez.'),
      _StepData(Icons.support_agent, 'Consulte especialistas', 'Conte com apoio jurídico e consultores financeiros para garantir segurança.'),
      _StepData(Icons.verified_user_outlined, 'Invista com segurança', 'Realize seu aporte com total transparência e documentos claros.'),
      _StepData(Icons.trending_up, 'Acompanhe resultados', 'Monitore a evolução do seu investimento com relatórios periódicos.'),
    ];

    return Container(
      width: double.infinity,
      color: _bg,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                const Text('Guia do Investidor', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Passo a passo para investir com inteligência', style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: steps.asMap().entries.map((e) => SizedBox(
                    width: isWide ? (contentWidth - 80) / 3 : contentWidth - 48,
                    child: _stepCard(e.key + 1, e.value),
                  )).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _navigateSignup,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Quero Investir', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepCard(int number, _StepData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: _gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('$number', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
              const SizedBox(width: 10),
              Icon(data.icon, color: _gold, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(data.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 6),
          Text(data.desc, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // POR QUE INVESTIR
  // ═══════════════════════════════════════
  Widget _buildWhyInvest(AppLocalizations t, bool isWide, double contentWidth) {
    final benefits = [
      _BenefitData(Icons.trending_up, 'Valorização Constante'),
      _BenefitData(Icons.water_drop, 'Liquidez Garantida'),
      _BenefitData(Icons.location_on, 'Localização Estratégica'),
      _BenefitData(Icons.people, 'Demanda Crescente'),
      _BenefitData(Icons.business_center, 'Gestão Profissional'),
      _BenefitData(Icons.shield, 'Segurança Jurídica'),
    ];

    return Container(
      width: double.infinity,
      color: _card,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                const Text('Por que investir em imóveis?',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: const Text(
                    'Investir em imóveis é apostar em um ativo real, durável e historicamente valorizado. '
                    'O mercado imobiliário oferece estabilidade, renda recorrente com aluguéis e ganhos de capital.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: benefits.map((b) => SizedBox(
                    width: isWide ? (contentWidth - 96) / 3 : (contentWidth - 64) / 2,
                    child: _benefitCard(b),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefitCard(_BenefitData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: _gold, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(data.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // NÚMEROS
  // ═══════════════════════════════════════
  Widget _buildNumbers(AppLocalizations t, bool isWide, double contentWidth) {
    final stats = [
      _StatData('5K+', 'Usuários cadastrados'),
      _StatData('18%', 'Média de Valorização'),
      _StatData('R\$ 12M', 'Distribuídos aos investidores'),
    ];

    return Container(
      width: double.infinity,
      color: _bg,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.map((s) => Column(
                children: [
                  Text(s.value, style: const TextStyle(color: _gold, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(s.label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // COMUNIDADE
  // ═══════════════════════════════════════
  Widget _buildCommunity(AppLocalizations t, bool isWide, double contentWidth) {
    final items = [
      _AuthCardData(Icons.handshake, 'Onde Negócios se Tornam Laços', 'A Global Real Estate é mais que uma imobiliária; é uma comunidade.'),
      _AuthCardData(Icons.memory, 'Expertise e Tecnologia', 'Metodologia refinada na seleção de imóveis, aprimorando o trabalho humano e tecnológico.'),
      _AuthCardData(Icons.public, 'A Oportunidade de Ser Global', 'Seja um corretor interamericano para negociar imóveis no Brasil e nos Estados Unidos.'),
    ];

    return Container(
      width: double.infinity,
      color: _card,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                const Text('Global Real Estate Community',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                isWide
                    ? Row(children: items.map((c) => Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _authorityCard(c),
                      ))).toList())
                    : Column(children: items.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _authorityCard(c),
                      )).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // CTA FINAL
  // ═══════════════════════════════════════
  Widget _buildFinalCta(AppLocalizations t, bool isWide, double contentWidth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_blue, _bg]),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
            child: Column(
              children: [
                const Text('O Futuro dos Investimentos Imobiliários Começa Aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Baixe o app e leve sua estratégia para o próximo nível. #SejaGlobal',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 28),
                // QR Code — only on web
                if (kIsWeb) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: 'https://global-real-rho.vercel.app',
                      version: QrVersions.auto,
                      size: 140,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Escaneie para acessar o app', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 28),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _navigateSignup,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Criar Conta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold, foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openWhatsApp(),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/5511996701990?text=Olá, venho do site Global Real Estate');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ═══════════════════════════════════════
  // FOOTER
  // ═══════════════════════════════════════
  Widget _buildFooter(AppLocalizations t, bool isWide, double contentWidth) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF070D18),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _footerBrand()),
                      Expanded(child: _footerLinks()),
                      Expanded(child: _footerContact()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _footerBrand(),
                      const SizedBox(height: 24),
                      _footerLinks(),
                      const SizedBox(height: 24),
                      _footerContact(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/logo_global_real.png', height: 32),
        const SizedBox(height: 12),
        const Text('Conectamos você às melhores oportunidades de investimento imobiliário.',
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        const Text('© 2025 Global Real Estate. Todos os direitos reservados.',
            style: TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  Widget _footerLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INSTITUCIONAL', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 12),
        _footerLink('Sobre'),
        _footerLink('Rentabilidade'),
        _footerLink('Invista'),
        _footerLink('Contato'),
        _footerLink('Política de Privacidade'),
        _footerLink('Termos de Uso'),
      ],
    );
  }

  Widget _footerLink(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }

  Widget _footerContact() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONTATO', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        SizedBox(height: 12),
        Text('(11) 99670-1990', style: TextStyle(color: Colors.white38, fontSize: 12)),
        SizedBox(height: 4),
        Text('contato@globalrealestate.com.br', style: TextStyle(color: Colors.white38, fontSize: 12)),
        SizedBox(height: 4),
        Text('Av. Paulista, 1842 - 15° Andar', style: TextStyle(color: Colors.white38, fontSize: 12)),
        Text('Bela Vista, São Paulo - SP', style: TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}

// ═══ Data classes ═══
class _AuthCardData {
  final IconData icon;
  final String title;
  final String desc;
  const _AuthCardData(this.icon, this.title, this.desc);
}

class _StepData {
  final IconData icon;
  final String title, desc;
  const _StepData(this.icon, this.title, this.desc);
}

class _BenefitData {
  final IconData icon;
  final String label;
  const _BenefitData(this.icon, this.label);
}

class _StatData {
  final String value, label;
  const _StatData(this.value, this.label);
}

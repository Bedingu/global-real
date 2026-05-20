import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// FLUTTER
import '../../theme.dart';
import '../../generated/app_localizations.dart';

// MODELS
import '../../models/development.dart';
import '../../models/market_filter.dart' as mf;
import '../../models/market_proximity.dart';
import '../../models/proximity_filter.dart';
import '../../models/market_hub.dart';
import '../../models/budget_filter.dart' as bf;

// SERVICES
import '../../services/auth_service.dart';
import '../../services/development_service.dart';
import '../../services/favorite_service.dart';
import '../../services/payment_service.dart';

// WIDGETS
import '../public_home_page.dart';
import '../private/private_page.dart';
import '../leads/leads_page.dart';
import '../crm/crm_dashboard_page.dart';
import '../../widgets/development/development_card.dart';
import '../../widgets/market/market_filter_bar.dart';
import '../../widgets/market/market_filter_panel.dart';
import '../../widgets/market/market_capacity_filter_modal.dart';
import '../../widgets/market/market_hub_filter.dart' hide MarketHub;
import '../../widgets/market/market_proximity_filter.dart';
import '../../widgets/all_filters/all_filters_button.dart';
import '../../widgets/all_filters/all_filters_panel.dart';
import '../../widgets/subscription_buttons.dart';
import '../../widgets/paywall/paywall_modal.dart';
import '../../widgets/dashboard/investor_banner.dart';
import '../../widgets/dashboard/premium_banner.dart';
import '../../widgets/dashboard/development_grid.dart';

// HELPERS
import '../../helpers/default_filters.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  // 🔓 DEV MODE — mude para true apenas durante desenvolvimento local
  // TODO: voltar para false antes de publicar na loja
  static const bool kDevBypassPremium = false;

  String _searchQuery = '';
  Set<String> _favoriteIds = {};

  mf.MarketFilter _marketFilter = const mf.MarketFilter();
  MarketProximity _marketProximity = MarketProximity.any;
  MarketHub _hub = MarketHub.saoPaulo;

  bool _isPremiumUser = false;
  RealtimeChannel? _premiumChannel;

  // Tab controller para Empreendimentos / Investimentos
  late TabController _tabController;

  final Map<String, bool> selectedAmenities = {
    "parking": false,
    "pool": false,
    "air_conditioning": false,
    "pet_friendly": false,
  };

  final _capexCtrl = TextEditingController();
  final _priceM2Ctrl = TextEditingController();
  final _adrCtrl = TextEditingController();
  final _yieldCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

  static const double _filterHeight = 34;
  static const double _filterRadius = 20;
  static const Color _filterBorder = Color(0xFFE5E7EB);
  static const Color _filterBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
    _loadPremiumStatus();
    _listenPremiumRealtime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _premiumChannel?.unsubscribe();
    _capexCtrl.dispose();
    _priceM2Ctrl.dispose();
    _adrCtrl.dispose();
    _yieldCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  // =============================
  // PREMIUM
  // =============================

  Future<void> _loadPremiumStatus() async {
    if (kDevBypassPremium) {
      _isPremiumUser = true;
      return;
    }

    final isPremium = await AuthService.isPremiumUser();
    if (!mounted) return;
    setState(() => _isPremiumUser = isPremium);
  }

  void _listenPremiumRealtime() {
    if (kDevBypassPremium) return;

    final userId = AuthService.currentUserId();
    if (userId == null) return;

    _premiumChannel?.unsubscribe();

    _premiumChannel = Supabase.instance.client
        .channel('profiles-premium-$userId')
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'profiles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: userId,
      ),
      callback: (payload) {
        final record = payload.newRecord;
        if (record == null || !mounted) return;

        final isPremium =
            record['is_premium'] == true &&
                record['subscription_status'] == 'active';

        setState(() => _isPremiumUser = isPremium);
      },
    )
        .subscribe();
  }

  Future<void> _loadFavorites() async {
    final ids = await FavoriteService.fetchFavoriteIds();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  void _openPaywall() {
    if (kDevBypassPremium) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallModal(
        onSubscribe: (planType) {
          final priceId = planType == 'annual'
              ? PaymentService.annualPriceId
              : PaymentService.monthlyPriceId;
          PaymentService.startCheckout(priceId);
        },
      ),
    );
  }

  // =============================
  // BUILD
  // =============================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(t.dashboard_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Leads',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeadsPage()),
            ),
          ),
          if (!_isPremiumUser && !kDevBypassPremium)
            IconButton(
              icon: const Icon(Icons.workspace_premium_outlined),
              tooltip: 'Premium',
              onPressed: _openPaywall,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PublicHomePage(onChangeLanguage: (_) {}),
                ),
                    (_) => false,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🔹 Banners (Sócio Investidor + Premium)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                // 🔹 Botão Seja Sócio Investidor
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivatePage()));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF232845), Color(0xFF2C3366)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.handshake_outlined, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seja Sócio Investidor',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Aportes a partir de R\$ 200 mil',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                      ],
                    ),
                  ),
                ),
                // 🔹 Widget Assinatura Premium (para não-premium)
                if (!_isPremiumUser && !kDevBypassPremium)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: _openPaywall,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: Color(0xFFFFC107), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Turbine suas vendas',
                                    style: TextStyle(color: Color(0xFFFFC107), fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Assine e acesse CRM, leads e simulações exclusivas',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFC107), size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Tab Bar: Empreendimentos | Investimentos
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF232845),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF232845),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              dividerHeight: 0,
              padding: const EdgeInsets.all(3),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apartment, size: 16),
                      SizedBox(width: 6),
                      Text('Empreendimentos'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.trending_up, size: 16),
                      SizedBox(width: 6),
                      Text('Investimentos'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // === ABA 1: EMPREENDIMENTOS ===
                _buildEmpreendimentosTab(),
                // === ABA 2: INVESTIMENTOS (FREE) ===
                _buildInvestimentosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // TAB: EMPREENDIMENTOS
  // =============================

  Widget _buildEmpreendimentosTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // 🔹 Cards dos materiais de venda (PDFs)
        const SizedBox(height: 8),
        const Text(
          'Materiais de Venda',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acesse as apresentações completas dos empreendimentos',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 14),
        ..._empreendimentoCards.map((emp) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEmpreendimentoCard(emp),
        )),
        const SizedBox(height: 24),
        // 🔹 Grid de empreendimentos (busca + filtros)
        const Text(
          'Buscar Empreendimentos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 12),
        _buildSearch(),
        const SizedBox(height: 12),
        _buildFilterRowResponsive(context),
        const SizedBox(height: 24),
        _buildResults(),
      ],
    );
  }

  Widget _buildEmpreendimentoCard(_EmpreendimentoData emp) {
    return GestureDetector(
      onTap: () => _openPdfViewer(emp),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Imagem
            SizedBox(
              width: 120,
              height: 100,
              child: Image.network(
                emp.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.apartment, color: Colors.grey)),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      emp.location,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232845).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 12, color: Color(0xFF232845)),
                          SizedBox(width: 4),
                          Text('Ver Material', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF232845))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _openPdfViewer(_EmpreendimentoData emp) {
    // Abre a galeria de imagens do empreendimento
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _EmpreendimentoGalleryPage(empreendimento: emp),
      ),
    );
  }

  // =============================
  // TAB: INVESTIMENTOS (FREE)
  // =============================

  /// Busca imagens dos empreendimentos de investimento no Supabase
  Future<Map<String, String>> _fetchInvestmentImages() async {
    try {
      final data = await Supabase.instance.client
          .from('developments')
          .select('empreendimentos, images')
          .or('empreendimentos.ilike.%Barros%,empreendimentos.ilike.%Venâncio%,empreendimentos.ilike.%Higienópolis%,empreendimentos.ilike.%Nove de Julho%');

      final Map<String, String> imageMap = {};
      for (final row in data) {
        final name = row['empreendimentos'] as String? ?? '';
        final images = row['images'] as List<dynamic>? ?? [];
        if (images.isNotEmpty) {
          imageMap[name] = images.first.toString();
        }
      }
      return imageMap;
    } catch (_) {
      return {};
    }
  }

  Widget _buildInvestimentosTab() {
    return FutureBuilder<Map<String, String>>(
      future: _fetchInvestmentImages(),
      builder: (context, snapshot) {
        final imageMap = snapshot.data ?? {};

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            // Gráfico comparativo
            _buildInvestmentComparisonChart(),
            const SizedBox(height: 20),
            // Cards dos investimentos com imagens
            ..._investmentPreviews.map((inv) {
              // Match image by partial name
              String? imageUrl;
              for (final entry in imageMap.entries) {
                if (entry.key.contains('Barros') && inv.name.contains('Barros')) {
                  imageUrl = entry.value;
                  break;
                }
                if (entry.key.contains('Venâncio') && inv.name.contains('Venâncio')) {
                  imageUrl = entry.value;
                  break;
                }
                if (entry.key.contains('Higienópolis') && inv.name.contains('Higienópolis')) {
                  imageUrl = entry.value;
                  break;
                }
                if (entry.key.contains('Nove de Julho') && inv.name.contains('Nove de Julho')) {
                  imageUrl = entry.value;
                  break;
                }
              }
              // Fallback: use Supabase storage known images
              imageUrl ??= inv.fallbackImageUrl;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildInvestmentFreeCard(inv, imageUrl: imageUrl),
              );
            }),
            const SizedBox(height: 16),
            // CTA para análise completa (premium)
            _buildInvestmentCta(),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildInvestmentComparisonChart() {
    const maxPrice = 30000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF232845), size: 18),
              SizedBox(width: 8),
              Text(
                'R\$/m² — Compra vs Saída',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF232845)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _chartLegend(const Color(0xFF3B82F6), 'Entrada'),
              const SizedBox(width: 12),
              _chartLegend(const Color(0xFF22C55E), 'Saída estimada'),
            ],
          ),
          const SizedBox(height: 16),
          ..._investmentPreviews.map((inv) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _chartBarRow(inv, maxPrice),
          )),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _chartBarRow(_InvPreview inv, double maxPrice) {
    final entryFraction = inv.priceM2Entry / maxPrice;
    final exitFraction = inv.priceM2Exit / maxPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(inv.shortName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(3))),
                  FractionallySizedBox(
                    widthFactor: entryFraction,
                    child: Container(height: 10, decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(3))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(width: 50, child: Text('R\$ ${_fmtK(inv.priceM2Entry)}', style: const TextStyle(fontSize: 9, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600))),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(3))),
                  FractionallySizedBox(
                    widthFactor: exitFraction,
                    child: Container(height: 10, decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(3))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(width: 50, child: Text('R\$ ${_fmtK(inv.priceM2Exit)}', style: const TextStyle(fontSize: 9, color: Color(0xFF22C55E), fontWeight: FontWeight.w600))),
          ],
        ),
      ],
    );
  }

  Widget _buildInvestmentFreeCard(_InvPreview inv, {String? imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do empreendimento
          if (imageUrl != null)
            Image.network(
              imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.apartment, color: Colors.grey, size: 32)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF232845).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.apartment, color: Color(0xFF232845), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inv.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                          Text(inv.location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Métricas
                Row(
                  children: [
                    _invMetricChip('ROI', '${inv.roi}%', const Color(0xFF22C55E)),
                    const SizedBox(width: 8),
                    _invMetricChip('IRR', '${inv.irr}%', const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    _invMetricChip('Prazo', '${inv.prazoMeses}m', const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 12),
                // Aporte e Renda
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Aporte', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('R\$ ${_fmtCurrency(inv.aporte)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Renda', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('${inv.renda}% a.m.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Barra de valorização
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Valorização R\$/m²', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('+${((inv.priceM2Exit - inv.priceM2Entry) / inv.priceM2Entry * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ((inv.priceM2Exit - inv.priceM2Entry) / inv.priceM2Entry / 1.2).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _invMetricChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCta() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFC107).withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFFFFC107), size: 28),
          const SizedBox(height: 10),
          const Text(
            'Análise Completa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fluxo de caixa, curva de vendas, VPL, payback e projeções detalhadas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!_isPremiumUser && !kDevBypassPremium) {
                  _openPaywall();
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivatePage()));
              },
              icon: const Icon(Icons.trending_up, size: 16),
              label: const Text('Desbloquear', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF232845),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtK(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  String _fmtCurrency(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m.toStringAsFixed(m == m.roundToDouble() ? 0 : 1)} mi';
    }
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} mil';
    return value.toStringAsFixed(0);
  }

  // =============================
  // FILTER ROW RESPONSIVE
  // =============================

  Widget _buildFilterRowResponsive(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return _buildMobileFilterBar();
    }
    return _buildFilterRow();
  }

  Widget _buildMobileFilterBar() {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Hub selector
        Expanded(
          child: MarketHubFilter(
            value: _hub,
            onChanged: (hub) {
              setState(() {
                _hub = hub;
                _marketFilter = defaultMarketFilterByHub(hub);
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        // Botão Filtros
        InkWell(
          onTap: () => _openMobileFilterDrawer(context),
          borderRadius: BorderRadius.circular(_filterRadius),
          child: Container(
            height: _filterHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _filterBg,
              borderRadius: BorderRadius.circular(_filterRadius),
              border: Border.all(color: _filterBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune, size: 16),
                const SizedBox(width: 6),
                Text(t.filters_title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Botão Investimento
        InkWell(
          onTap: () {
            if (!_isPremiumUser && !kDevBypassPremium) {
              _openPaywall();
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivatePage()));
          },
          borderRadius: BorderRadius.circular(_filterRadius),
          child: Container(
            height: _filterHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF232845),
              borderRadius: BorderRadius.circular(_filterRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(t.invest_button, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openMobileFilterDrawer(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.filters_title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Empreendimentos
            _mobileFilterTile(t.developments_label, Icons.apartment_outlined, _openMarketFilter),
            _mobileFilterTile(t.filter_capacity, Icons.people_outline, _openCapacityFilter),
            _mobileFilterTile(t.budget_title, Icons.attach_money, _openBudgetModal),
            _mobileFilterTile(t.amenities_title, Icons.pool_outlined, _openAmenitiesModal),
            _mobileFilterTile(t.filter_property_type, Icons.apartment_outlined, _openPropertyTypeModal),
            _mobileFilterTile(t.filter_delivery_date, Icons.calendar_month_outlined, _openDeliveryDateModal),
            _mobileFilterTile(t.filter_price_range, Icons.price_change_outlined, _openPriceRangeModal),
            _mobileFilterTile(t.proximity_label, Icons.near_me_outlined, () {
              Navigator.pop(ctx);
              // TODO: open proximity filter
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF232845),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t.apply_filters, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileFilterTile(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF232845), size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  // =============================
  // FILTER ROW (LEGADO COMPLETO)
  // =============================

  Widget _buildFilterRow() {
    final t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          MarketHubFilter(
            value: _hub,
            onChanged: (hub) {
              setState(() {
                _hub = hub;
                _marketFilter = defaultMarketFilterByHub(hub);
              });
            },
          ),
          const SizedBox(width: 8),
          MarketFilterBar(
            filter: _marketFilter,
            onOpenMarketFilters: _openMarketFilter,
            onOpenCapacityFilters: _openCapacityFilter,
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: t.budget_title,
            icon: Icons.attach_money,
            onTap: _openBudgetModal,
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: t.amenities_title,
            icon: Icons.pool_outlined,
            onTap: _openAmenitiesModal,
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: t.filter_property_type,
            icon: Icons.apartment_outlined,
            onTap: _openPropertyTypeModal,
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: t.filter_delivery_date,
            icon: Icons.calendar_month_outlined,
            onTap: _openDeliveryDateModal,
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: t.filter_price_range,
            icon: Icons.price_change_outlined,
            onTap: _openPriceRangeModal,
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: t.filter_investment,
            icon: Icons.trending_up,
            onTap: () {
              if (!_isPremiumUser && !kDevBypassPremium) {
                _openPaywall();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivatePage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          MarketProximityFilter(
            value: _marketProximity,
            onChanged: (v) =>
                setState(() => _marketProximity = v),
          ),
          const SizedBox(width: 8),
          AllFiltersButton(
            isActive: false,
            onTap: _openAllFilters,
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool highlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_filterRadius),
      child: Container(
        height: _filterHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFFFFF8E1) : _filterBg,
          borderRadius: BorderRadius.circular(_filterRadius),
          border: Border.all(color: highlighted ? const Color(0xFFFFC107) : _filterBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: highlighted ? const Color(0xFFE65100) : null),
              const SizedBox(width: 5),
            ],
            Text(label, style: TextStyle(fontSize: 12, fontWeight: highlighted ? FontWeight.w700 : FontWeight.normal, color: highlighted ? const Color(0xFFE65100) : null)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 15, color: highlighted ? const Color(0xFFE65100) : null),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    final t = AppLocalizations.of(context)!;
    return TextField(
      onChanged: (v) =>
          setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText:
        t.search_hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResults() {
    return FutureBuilder<List<Development>>(
      future: DevelopmentService.searchDevelopments(
        _searchQuery,
        _marketFilter,
        ProximityFilter(
          maxSubwayDistanceMeters:
          _marketProximity.maxDistanceMeters,
        ),
        _hub,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final developments = snapshot.data!;
        if (developments.isEmpty) {
          return const Text(
              'Nenhum empreendimento encontrado');
        }

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: developments.length,
          itemBuilder: (context, i) {
            final dev = developments[i];
            final isFav =
            _favoriteIds.contains(dev.id);

            return DevelopmentCard(
              development: dev,
              isFavorite: isFav,
              onFavorite: () async {
                setState(() {
                  isFav
                      ? _favoriteIds.remove(dev.id)
                      : _favoriteIds.add(dev.id);
                });

                isFav
                    ? await FavoriteService
                    .removeFavorite(dev.id)
                    : await FavoriteService
                    .addFavorite(dev.id);
              },
            );
          },
        );
      },
    );
  }

  // =============================
  // ALL FILTERS PANEL
  // =============================

  void _openAllFilters() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AllFilters',
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: AllFiltersPanel(
          filter: _marketFilter,
          onApply: (f) => setState(() => _marketFilter = f),
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // =============================
  // MODAIS
  // =============================

  void _openMarketFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MarketFilterPanel(
        initialFilter: _marketFilter,
        onApply: (f) =>
            setState(() => _marketFilter = f),
      ),
    );
  }

  Future<void> _openCapacityFilter() async {
    final result =
    await showModalBottomSheet<mf.MarketFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarketCapacityFilterModal(
        initialFilter: _marketFilter,
      ),
    );

    if (mounted && result != null) {
      setState(() => _marketFilter = result);
    }
  }

  void _openAmenitiesModal() {
    final t = AppLocalizations.of(context)!;

    final amenityLabels = {
      "parking": t.amenity_parking,
      "pool": t.amenity_pool,
      "air_conditioning": t.amenity_air_conditioning,
      "pet_friendly": t.amenity_pet_friendly,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding:
          const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Wrap(
            children: [
              Text(
                t.amenities_title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              ...selectedAmenities.keys.map((k) {
                return SwitchListTile(
                  title: Text(amenityLabels[k] ?? k),
                  value: selectedAmenities[k]!,
                  onChanged: (v) =>
                      setModal(() =>
                      selectedAmenities[k] = v),
                );
              }),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setModal(() {
                        for (final key in selectedAmenities.keys) {
                          selectedAmenities[key] = false;
                        }
                      });
                    },
                    child: Text(t.filter_reset),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _marketFilter =
                            _marketFilter.copyWith(
                              amenities:
                              Map.of(selectedAmenities),
                            );
                      });
                      Navigator.pop(context);
                    },
                    child: Text(t.filter_apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBudgetModal() {
    final t = AppLocalizations.of(context)!;
    final budget = _marketFilter.budget;

    _capexCtrl.text =
        budget?.maxCapex?.toString() ?? "";
    _priceM2Ctrl.text =
        budget?.maxPricePerM2?.toString() ?? "";
    _adrCtrl.text =
        budget?.minADR?.toString() ?? "";
    _yieldCtrl.text =
        budget?.minYield?.toString() ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Wrap(
          children: [
            Text(
              t.budget_title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8, width: double.infinity),
            TextField(
              controller: _capexCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: t.budget_max_capex,
                  prefixText: _hub.currencySymbol),
            ),
            TextField(
              controller: _priceM2Ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: t.budget_price_m2,
                  prefixText: _hub.currencySymbol),
            ),
            TextField(
              controller: _adrCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: t.budget_min_adr,
                  prefixText: _hub.currencySymbol),
            ),
            TextField(
              controller: _yieldCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: t.budget_min_yield,
                  suffixText: '%'),
            ),
            const SizedBox(height: 16, width: double.infinity),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _capexCtrl.clear();
                    _priceM2Ctrl.clear();
                    _adrCtrl.clear();
                    _yieldCtrl.clear();
                  },
                  child: Text(t.filter_reset),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _marketFilter =
                          _marketFilter.copyWith(
                            budget: bf.BudgetFilter(
                              maxCapex: double.tryParse(
                                  _capexCtrl.text),
                              maxPricePerM2:
                              double.tryParse(
                                  _priceM2Ctrl.text),
                              minADR: double.tryParse(
                                  _adrCtrl.text),
                              minYield: double.tryParse(
                                  _yieldCtrl.text),
                            ),
                          );
                    });
                    Navigator.pop(context);
                  },
                  child: Text(t.filter_apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // PROPERTY TYPE MODAL
  // =============================
  void _openPropertyTypeModal() {
    final t = AppLocalizations.of(context)!;

    final allTypes = {
      'Apartamento': t.property_type_apartment,
      'Studio': t.property_type_studio,
      'Casa': t.property_type_house,
      'Comercial': t.property_type_commercial,
      'Terreno': t.property_type_land,
      'Flat': t.property_type_flat,
    };

    final selected = Set<String>.from(_marketFilter.propertyTypes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Wrap(
            children: [
              Text(
                t.filter_property_type,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12, width: double.infinity),
              ...allTypes.entries.map((e) {
                return CheckboxListTile(
                  title: Text(e.value),
                  value: selected.contains(e.key),
                  onChanged: (v) {
                    setModal(() {
                      v == true
                          ? selected.add(e.key)
                          : selected.remove(e.key);
                    });
                  },
                );
              }),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setModal(() => selected.clear()),
                    child: Text(t.filter_reset),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _marketFilter = _marketFilter.copyWith(
                          propertyTypes: Set<String>.from(selected),
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: Text(t.filter_apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // DELIVERY DATE MODAL
  // =============================
  void _openDeliveryDateModal() {
    final t = AppLocalizations.of(context)!;

    String? fromDate = _marketFilter.deliveryDateStart;
    String? toDate = _marketFilter.deliveryDateEnd;

    // Generate year/quarter options from current year to +5 years
    final now = DateTime.now();
    final options = <String>[];
    for (int y = now.year; y <= now.year + 5; y++) {
      for (final q in ['Q1', 'Q2', 'Q3', 'Q4']) {
        options.add('$q $y');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Wrap(
            children: [
              Text(
                t.filter_delivery_date,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16, width: double.infinity),
              DropdownButtonFormField<String>(
                initialValue: fromDate,
                decoration: InputDecoration(labelText: t.delivery_from),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  ...options.map((o) =>
                      DropdownMenuItem(value: o, child: Text(o))),
                ],
                onChanged: (v) => setModal(() => fromDate = v),
              ),
              const SizedBox(height: 12, width: double.infinity),
              DropdownButtonFormField<String>(
                initialValue: toDate,
                decoration: InputDecoration(labelText: t.delivery_to),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  ...options.map((o) =>
                      DropdownMenuItem(value: o, child: Text(o))),
                ],
                onChanged: (v) => setModal(() => toDate = v),
              ),
              const SizedBox(height: 16, width: double.infinity),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setModal(() {
                      fromDate = null;
                      toDate = null;
                    }),
                    child: Text(t.filter_reset),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _marketFilter = _marketFilter.copyWith(
                          deliveryDateStart: fromDate,
                          deliveryDateEnd: toDate,
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: Text(t.filter_apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // PRICE RANGE MODAL
  // =============================
  void _openPriceRangeModal() {
    final t = AppLocalizations.of(context)!;

    _minPriceCtrl.text = _marketFilter.minPrice?.toString() ?? '';
    _maxPriceCtrl.text = _marketFilter.maxPrice?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Wrap(
          children: [
            Text(
              t.filter_price_range,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12, width: double.infinity),
            TextField(
              controller: _minPriceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.price_min,
                prefixText: _hub.currencySymbol,
              ),
            ),
            const SizedBox(height: 8, width: double.infinity),
            TextField(
              controller: _maxPriceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.price_max,
                prefixText: _hub.currencySymbol,
              ),
            ),
            const SizedBox(height: 16, width: double.infinity),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _minPriceCtrl.clear();
                    _maxPriceCtrl.clear();
                  },
                  child: Text(t.filter_reset),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _marketFilter = _marketFilter.copyWith(
                        minPrice: double.tryParse(_minPriceCtrl.text),
                        maxPrice: double.tryParse(_maxPriceCtrl.text),
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: Text(t.filter_apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ Dados de investimento para a aba free ═══
class _InvPreview {
  final String name;
  final String shortName;
  final String location;
  final double aporte;
  final double priceM2Entry;
  final double priceM2Exit;
  final double roi;
  final double irr;
  final int prazoMeses;
  final double renda;
  final String fallbackImageUrl;

  const _InvPreview({
    required this.name,
    required this.shortName,
    required this.location,
    required this.aporte,
    required this.priceM2Entry,
    required this.priceM2Exit,
    required this.roi,
    required this.irr,
    required this.prazoMeses,
    required this.renda,
    required this.fallbackImageUrl,
  });
}

const _supabaseStorage = 'https://pcbwbndrnnqptxdbrqnm.supabase.co/storage/v1/object/public/development-images';

const _investmentPreviews = [
  _InvPreview(
    name: 'Vitacon Al Barros 886',
    shortName: 'Al Barros 886',
    location: 'Alameda Barros, São Paulo',
    aporte: 1200000,
    priceM2Entry: 11900,
    priceM2Exit: 24000,
    roi: 93.7,
    irr: 26.4,
    prazoMeses: 36,
    renda: 0.8,
    fallbackImageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
  ),
  _InvPreview(
    name: 'Vitacon Venâncio 943',
    shortName: 'Venâncio 943',
    location: 'Rua Venâncio Aires, São Paulo',
    aporte: 1000000,
    priceM2Entry: 12614,
    priceM2Exit: 20000,
    roi: 52.3,
    irr: 15.8,
    prazoMeses: 36,
    renda: 1.0,
    fallbackImageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
  ),
  _InvPreview(
    name: 'Vitacon Higienópolis',
    shortName: 'Higienópolis',
    location: 'Higienópolis, São Paulo',
    aporte: 1000000,
    priceM2Entry: 16900,
    priceM2Exit: 30000,
    roi: 70.5,
    irr: 21.3,
    prazoMeses: 36,
    renda: 1.0,
    fallbackImageUrl: '$_supabaseStorage/senior-living/page39_img01_1280x720.jpeg',
  ),
  _InvPreview(
    name: 'Vitacon Nove de Julho',
    shortName: 'Nove de Julho',
    location: 'Av. Nove de Julho, São Paulo',
    aporte: 1000000,
    priceM2Entry: 12614,
    priceM2Exit: 20000,
    roi: 52.3,
    irr: 15.8,
    prazoMeses: 36,
    renda: 1.0,
    fallbackImageUrl: '$_supabaseStorage/nove-de-julho/slides/slide_05_01_1920x1080.jpeg',
  ),
];


// ═══ Dados dos empreendimentos (PDFs / materiais de venda) ═══
class _EmpreendimentoData {
  final String name;
  final String location;
  final String coverImageUrl;
  final List<String> galleryImageUrls;

  const _EmpreendimentoData({
    required this.name,
    required this.location,
    required this.coverImageUrl,
    required this.galleryImageUrls,
  });
}

const _empreendimentoCards = [
  _EmpreendimentoData(
    name: 'Vitacon Alto Pinheiros',
    location: 'Alto de Pinheiros, São Paulo',
    coverImageUrl: '$_supabaseStorage/alto-pinheiros/page04_img02_845x598.jpeg',
    galleryImageUrls: [
      '$_supabaseStorage/alto-pinheiros/page04_img02_845x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page10_img01_1071x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page11_img01_1087x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page13_img01_1106x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page14_img01_1087x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page15_img01_1173x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page16_img01_1087x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page17_img01_1111x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page18_img01_1086x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page21_img01_1034x598.jpeg',
      '$_supabaseStorage/alto-pinheiros/page22_img01_1035x598.jpeg',
    ],
  ),
  _EmpreendimentoData(
    name: 'Vitacon Bela Cintra',
    location: 'Consolação, São Paulo',
    coverImageUrl: '$_supabaseStorage/bela-cintra/page05_img01_845x598.jpeg',
    galleryImageUrls: [
      '$_supabaseStorage/bela-cintra/page05_img01_845x598.jpeg',
      '$_supabaseStorage/bela-cintra/page09_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page10_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page11_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page13_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page14_img01_1103x599.jpeg',
      '$_supabaseStorage/bela-cintra/page16_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page17_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page18_img02_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page19_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page22_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page23_img01_1158x599.jpeg',
      '$_supabaseStorage/bela-cintra/page24_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page28_img01_1096x598.jpeg',
      '$_supabaseStorage/bela-cintra/page30_img01_1096x598.jpeg',
      '$_supabaseStorage/bela-cintra/page32_img01_1096x599.jpeg',
      '$_supabaseStorage/bela-cintra/page33_img01_1096x599.jpeg',
    ],
  ),
  _EmpreendimentoData(
    name: 'Vitacon Domingos de Morais',
    location: 'Vila Mariana, São Paulo',
    coverImageUrl: '$_supabaseStorage/domingos-morais/page02_img01_3517x2490.jpeg',
    galleryImageUrls: [
      '$_supabaseStorage/domingos-morais/page02_img01_3517x2490.jpeg',
      '$_supabaseStorage/domingos-morais/page09_img01_1619x943.jpeg',
      '$_supabaseStorage/domingos-morais/page13_img01_2863x2027.jpeg',
      '$_supabaseStorage/domingos-morais/page17_img01_2614x1850.jpeg',
      '$_supabaseStorage/domingos-morais/page18_img01_3676x2602.jpeg',
      '$_supabaseStorage/domingos-morais/page22_img01_3762x2669.jpeg',
      '$_supabaseStorage/domingos-morais/page39_img01_3793x2471.jpeg',
      '$_supabaseStorage/domingos-morais/page40_img01_3517x2489.jpeg',
      '$_supabaseStorage/domingos-morais/page44_img01_3517x2490.jpeg',
      '$_supabaseStorage/domingos-morais/page48_img01_3088x2000.jpeg',
      '$_supabaseStorage/domingos-morais/page62_img01_3607x2343.jpeg',
      '$_supabaseStorage/domingos-morais/page72_img01_3772x2457.jpeg',
      '$_supabaseStorage/domingos-morais/page78_img01_5051x3576.jpeg',
    ],
  ),
  _EmpreendimentoData(
    name: 'Vitacon João Moura',
    location: 'Pinheiros, São Paulo',
    coverImageUrl: '$_supabaseStorage/joao-moura/page02_img01_1923x1083.jpeg',
    galleryImageUrls: [
      '$_supabaseStorage/joao-moura/page02_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page04_img01_1920x1083.jpeg',
      '$_supabaseStorage/joao-moura/page05_img01_1922x1083.jpeg',
      '$_supabaseStorage/joao-moura/page13_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page17_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page18_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page19_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page20_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page22_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page23_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page24_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page25_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page26_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page27_img01_1923x1083.jpeg',
      '$_supabaseStorage/joao-moura/page28_img01_1923x1083.jpeg',
    ],
  ),
  _EmpreendimentoData(
    name: 'Vitacon Perdizes',
    location: 'Perdizes, São Paulo',
    coverImageUrl: '$_supabaseStorage/perdizes/page05_img01_845x598.jpeg',
    galleryImageUrls: [
      '$_supabaseStorage/perdizes/page05_img01_845x598.jpeg',
      '$_supabaseStorage/perdizes/page07_img01_754x598.jpeg',
      '$_supabaseStorage/perdizes/page08_img01_1059x596.jpeg',
      '$_supabaseStorage/perdizes/page14_img01_1064x598.jpeg',
      '$_supabaseStorage/perdizes/page15_img01_1027x598.jpeg',
      '$_supabaseStorage/perdizes/page17_img01_1101x598.jpeg',
      '$_supabaseStorage/perdizes/page19_img01_1027x598.jpeg',
      '$_supabaseStorage/perdizes/page20_img01_1027x598.jpeg',
      '$_supabaseStorage/perdizes/page21_img01_1101x598.jpeg',
      '$_supabaseStorage/perdizes/page22_img01_1096x598.jpeg',
      '$_supabaseStorage/perdizes/page23_img01_1072x598.jpeg',
      '$_supabaseStorage/perdizes/page24_img01_1063x598.jpeg',
      '$_supabaseStorage/perdizes/page25_img01_1066x598.jpeg',
      '$_supabaseStorage/perdizes/page27_img01_1096x598.jpeg',
      '$_supabaseStorage/perdizes/page28_img01_1068x598.jpeg',
      '$_supabaseStorage/perdizes/page29_img01_1096x598.jpeg',
      '$_supabaseStorage/perdizes/page30_img01_1096x598.jpeg',
      '$_supabaseStorage/perdizes/page31_img01_1096x598.jpeg',
    ],
  ),
  _EmpreendimentoData(
    name: 'Vitacon Pinheiros',
    location: 'Pinheiros, São Paulo',
    coverImageUrl: '$_supabaseStorage/pinheiros/page05_img01_1923x1082.jpeg',
    galleryImageUrls: [
      '$_supabaseStorage/pinheiros/page05_img01_1923x1082.jpeg',
      '$_supabaseStorage/pinheiros/page06_img01_1920x1080.jpeg',
      '$_supabaseStorage/pinheiros/page08_img01_1923x1083.jpeg',
      '$_supabaseStorage/pinheiros/page16_img01_1921x1081.jpeg',
      '$_supabaseStorage/pinheiros/page17_img01_1921x1081.jpeg',
      '$_supabaseStorage/pinheiros/page18_img01_1922x1083.jpeg',
      '$_supabaseStorage/pinheiros/page19_img01_1922x1082.jpeg',
      '$_supabaseStorage/pinheiros/page22_img01_1922x1082.jpeg',
      '$_supabaseStorage/pinheiros/page23_img01_1922x1082.jpeg',
      '$_supabaseStorage/pinheiros/page25_img01_1921x1083.jpeg',
      '$_supabaseStorage/pinheiros/page26_img01_1922x1081.jpeg',
      '$_supabaseStorage/pinheiros/page27_img01_1922x1083.jpeg',
      '$_supabaseStorage/pinheiros/page28_img01_1922x1082.jpeg',
      '$_supabaseStorage/pinheiros/page31_img01_1921x1082.jpeg',
      '$_supabaseStorage/pinheiros/page34_img01_1923x1082.jpeg',
      '$_supabaseStorage/pinheiros/page35_img01_1921x1083.jpeg',
      '$_supabaseStorage/pinheiros/page36_img01_1922x1083.jpeg',
      '$_supabaseStorage/pinheiros/page37_img01_1922x1082.jpeg',
    ],
  ),
];

// ═══ Página de galeria do empreendimento ═══
class _EmpreendimentoGalleryPage extends StatelessWidget {
  final _EmpreendimentoData empreendimento;

  const _EmpreendimentoGalleryPage({required this.empreendimento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF232845),
        title: Text(
          empreendimento.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: PageView.builder(
        itemCount: empreendimento.galleryImageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                empreendimento.galleryImageUrls[index],
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFFFFC107),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 48),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF111C2E),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Text(
          'Deslize para navegar • ${empreendimento.galleryImageUrls.length} slides',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}

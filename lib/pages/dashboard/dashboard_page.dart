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

// HELPERS
import '../../helpers/default_filters.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
    _loadFavorites();
    _loadPremiumStatus();
    _listenPremiumRealtime();
  }

  @override
  void dispose() {
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
              ? "price_1SqeRLIHf8Ey84xrDd51z4UA"
              : "price_xxx"; // TODO: substituir pelo price ID mensal real
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 🔹 Botão Seja Sócio Investidor
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
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
          ),
          // 🔹 Widget Assinatura Premium (para não-premium)
          if (!_isPremiumUser && !kDevBypassPremium)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
          _buildSearch(),
          const SizedBox(height: 12),
          _buildFilterRowResponsive(context),
          const SizedBox(height: 24),
          _buildResults(),
        ],
      ),
    );
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune, size: 16),
                SizedBox(width: 6),
                Text('Filtros', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Investir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
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
            const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Empreendimentos
            _mobileFilterTile('Empreendimentos', Icons.apartment_outlined, _openMarketFilter),
            _mobileFilterTile(t.filter_capacity, Icons.people_outline, _openCapacityFilter),
            _mobileFilterTile(t.budget_title, Icons.attach_money, _openBudgetModal),
            _mobileFilterTile(t.amenities_title, Icons.pool_outlined, _openAmenitiesModal),
            _mobileFilterTile(t.filter_property_type, Icons.apartment_outlined, _openPropertyTypeModal),
            _mobileFilterTile(t.filter_delivery_date, Icons.calendar_month_outlined, _openDeliveryDateModal),
            _mobileFilterTile(t.filter_price_range, Icons.price_change_outlined, _openPriceRangeModal),
            _mobileFilterTile('Proximidade', Icons.near_me_outlined, () {
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
                child: const Text('Aplicar Filtros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
    return TextField(
      onChanged: (v) =>
          setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText:
        'Buscar empreendimento, cidade ou endereço',
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
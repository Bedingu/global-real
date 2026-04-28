import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../models/private/private_case.dart';
import '../../models/private/private_simulation_result.dart';
import '../../services/private/private_simulation_engine.dart';
import '../../data/private/private_cases.dart';
import '../../generated/app_localizations.dart';
import '../../models/development.dart';
import '../../services/favorite_service.dart';
import '../../widgets/development/development_card.dart';
import '../../models/private/stock_item.dart';
import '../../services/private/stock_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fraction_page.dart';
import 'widgets/IPO_page.dart';
import 'str_analytics_page.dart';
import '../admin/admin_videos_page.dart';

enum PrivateInvestmentType {
  education,
  privateInvestments,
  realEstateFraction,
  launches,
  stock,
  ipo,
  catalog,
  calculator,
  strAnalytics,
  marketSP,
  marketFL,
  partnership,
}

class PrivatePage extends StatefulWidget {
  const PrivatePage({super.key});

  @override
  State<PrivatePage> createState() => _PrivatePageState();
}

class _PrivatePageState extends State<PrivatePage> {
  PrivateInvestmentType _selectedType =
      PrivateInvestmentType.privateInvestments;

  late PrivateCase _selectedCase;
  late PrivateSimulationResult _result;
  bool _showCumulative = true;

  // Cores
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _blue = Color(0xFF3B82F6);
  static const _red = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _selectedCase = privateCases.first;
    _runSimulation();
  }

  void _runSimulation() {
    _result = PrivateSimulationEngine.run(_selectedCase.input);
  }

  String _fmtCurrency(double value) {
    final fmt = NumberFormat('#,##0', 'pt_BR');
    return 'R\$ ${fmt.format(value.round())}';
  }

  String _fmtPayback(AppLocalizations t) {
    final months = _result.paybackMonths;
    if (months == null) return '—';
    if (months >= 12) {
      final y = months ~/ 12;
      final m = months % 12;
      return t.private_payback_years(m, y);
    }
    return t.private_payback_months(months);
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final content = switch (_selectedType) {
      PrivateInvestmentType.education => _buildEducationView(t),
      PrivateInvestmentType.privateInvestments => _buildPrivateContent(t),
      PrivateInvestmentType.realEstateFraction => const FractionPage(),
      PrivateInvestmentType.launches => _buildLaunchesView(t),
      PrivateInvestmentType.stock => _buildStockView(t),
      PrivateInvestmentType.ipo => const IPOPage(),
      PrivateInvestmentType.catalog => _buildCatalogView(t),
      PrivateInvestmentType.calculator => _buildCalculatorView(t),
      PrivateInvestmentType.strAnalytics => const STRAnalyticsPage(),
      PrivateInvestmentType.marketSP => _buildMarketLeadsView(t, 'sao_paulo'),
      PrivateInvestmentType.marketFL => _buildMarketLeadsView(t, 'florida'),
      PrivateInvestmentType.partnership => _buildPartnershipView(t),
    };

    if (isMobile) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1628),
          title: Row(
            children: [
              const Icon(Icons.insights, color: _gold, size: 20),
              const SizedBox(width: 8),
              Text(t.private_title, style: const TextStyle(fontSize: 15)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF0D1628),
          child: SafeArea(child: _buildSidebar(t)),
        ),
        body: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _buildSidebar(t),
          Expanded(child: content),
        ],
      ),
    );
  }

  // ==========================================================
  // SIDEBAR
  // ==========================================================
  Widget _buildSidebar(AppLocalizations t) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1628),
        border: Border(right: BorderSide(color: _border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Row(
              children: [
                const Icon(Icons.insights, color: _gold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.private_title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _border, height: 1),

          // ── Scrollable nav ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ SEÇÃO 1: Educação ═══
                  _sidebarSection(t.edu_section_title),
                  _sidebarItem(
                    icon: Icons.play_circle_outline,
                    label: t.edu_videos_title,
                    selected: _selectedType == PrivateInvestmentType.education,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.education),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: _border, height: 1),
                  ),

                  // ═══ SEÇÃO 2: Formas de Investimentos ═══
                  _sidebarSection(t.private_title),
                  _sidebarItem(
                    icon: Icons.lock_outline,
                    label: t.private_type_private,
                    selected: _selectedType == PrivateInvestmentType.privateInvestments,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.privateInvestments),
                  ),
                  _sidebarItem(
                    icon: Icons.pie_chart_outline,
                    label: t.private_type_fraction,
                    selected: _selectedType == PrivateInvestmentType.realEstateFraction,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.realEstateFraction),
                  ),
                  _sidebarItem(
                    icon: Icons.rocket_launch_outlined,
                    label: t.private_launches,
                    selected: _selectedType == PrivateInvestmentType.launches,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.launches),
                  ),
                  _sidebarItem(
                    icon: Icons.inventory_2_outlined,
                    label: t.private_stock,
                    selected: _selectedType == PrivateInvestmentType.stock,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.stock),
                  ),
                  _sidebarItem(
                    icon: Icons.trending_up,
                    label: t.private_ipo,
                    selected: _selectedType == PrivateInvestmentType.ipo,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.ipo),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: _border, height: 1),
                  ),

                  // ═══ SEÇÃO 3: Catálogo + Calculadora ═══
                  _sidebarSection(t.tools_section_title),
                  _sidebarItem(
                    icon: Icons.storefront_outlined,
                    label: t.catalog_title,
                    selected: _selectedType == PrivateInvestmentType.catalog,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.catalog),
                  ),
                  _sidebarItem(
                    icon: Icons.calculate_outlined,
                    label: t.calculator_title,
                    selected: _selectedType == PrivateInvestmentType.calculator,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.calculator),
                  ),
                  _sidebarItem(
                    icon: Icons.analytics_outlined,
                    label: t.str_analytics_title,
                    selected: _selectedType == PrivateInvestmentType.strAnalytics,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.strAnalytics),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: _border, height: 1),
                  ),

                  // ═══ SEÇÃO 4: Mercados / Leads ═══
                  _sidebarSection(t.markets_section_title),
                  _sidebarItem(
                    icon: Icons.location_city,
                    label: t.market_sp_title,
                    selected: _selectedType == PrivateInvestmentType.marketSP,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.marketSP),
                  ),
                  _sidebarItem(
                    icon: Icons.beach_access_outlined,
                    label: t.market_fl_title,
                    selected: _selectedType == PrivateInvestmentType.marketFL,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.marketFL),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: _border, height: 1),
                  ),

                  // ═══ SEÇÃO 5: Proposta de Parceria ═══
                  _sidebarSection(t.partnership_section_title),
                  _sidebarItem(
                    icon: Icons.handshake_outlined,
                    label: t.partnership_proposals,
                    selected: _selectedType == PrivateInvestmentType.partnership,
                    onTap: () => setState(
                        () => _selectedType = PrivateInvestmentType.partnership),
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white38),
              label: Text(t.dashboard_title,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? _gold.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            onTap();
            // Close drawer on mobile
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold != null && scaffold.isDrawerOpen) {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon,
                    size: 18, color: selected ? _gold : Colors.white38),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? _gold : Colors.white60,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MAIN CONTENT — INVESTIMENTOS PRIVADOS
  // ==========================================================
  Widget _buildPrivateContent(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP: 5 METRIC CARDS ──
          _buildMetricsRow(t),
          const SizedBox(height: 16),

          // ── FINANCIAL SUMMARY BAR ──
          _buildFinancialSummary(t),
          const SizedBox(height: 20),

          // ── CHART SECTION ──
          Expanded(child: _buildChartSection(t)),
        ],
      ),
    );
  }

  // ==========================================================
  // 5 METRIC CARDS — HORIZONTAL
  // ==========================================================
  Widget _buildMetricsRow(AppLocalizations t) {
    final metrics = [
      _MetricData(Icons.show_chart, t.private_irr_annual,
          '${(_result.irrAnnual * 100).toStringAsFixed(2)}%',
          t.private_irr_annual_desc),
      _MetricData(Icons.timeline, t.private_irr_monthly,
          '${(_result.irrMonthly * 100).toStringAsFixed(2)}%',
          t.private_irr_monthly_desc),
      _MetricData(Icons.pie_chart_outline, t.private_roi,
          '${(_result.roi * 100).toStringAsFixed(1)}%',
          t.private_roi_desc),
      _MetricData(Icons.access_time, t.private_payback,
          _fmtPayback(t), t.private_payback_desc),
      _MetricData(Icons.account_balance_wallet, t.private_npv,
          _fmtCurrency(_result.npv), t.private_npv_desc),
    ];

    return Row(
      children: metrics
          .map((m) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _metricCard(m),
                ),
              ))
          .toList(),
    );
  }

  Widget _metricCard(_MetricData m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131E30), Color(0xFF0F1926)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(m.icon, color: _gold, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(m.title,
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(m.value,
                style: const TextStyle(
                    color: _gold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(m.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white30, fontSize: 9)),
        ],
      ),
    );
  }

  // ==========================================================
  // FINANCIAL SUMMARY BAR
  // ==========================================================
  Widget _buildFinancialSummary(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Row(
        children: [
          _summaryItem(
            Icons.arrow_downward,
            t.private_invested,
            _fmtCurrency(_result.totalInvested),
            Colors.white70,
          ),
          _summaryArrow(),
          _summaryItem(
            Icons.arrow_upward,
            t.private_return,
            _fmtCurrency(_result.totalReturn),
            _blue,
          ),
          _summaryArrow(),
          _summaryItem(
            Icons.trending_up,
            t.private_profit,
            _fmtCurrency(_result.totalProfit),
            _result.totalProfit >= 0 ? const Color(0xFF22C55E) : _red,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right, color: Colors.white24, size: 20),
    );
  }

  // ==========================================================
  // CHART SECTION
  // ==========================================================
  Widget _buildChartSection(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: toggle + legend
          Row(
            children: [
              _buildChartToggle(t),
              const SizedBox(width: 20),
              _legendDot(_blue, t.private_legend_revenue),
              const SizedBox(width: 14),
              _legendDot(_red, t.private_legend_cost),
              const SizedBox(width: 14),
              _legendDot(_gold, t.private_legend_net),
              const Spacer(),
              Text(
                t.private_chart_months,
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildChartToggle(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(t.private_cumulative, true),
          _toggleBtn(t.private_monthly, false),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool cumVal) {
    final active = _showCumulative == cumVal;
    return GestureDetector(
      onTap: () => setState(() => _showCumulative = cumVal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white54,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            )),
      ),
    );
  }

  // ==========================================================
  // CHART
  // ==========================================================
  Widget _buildChart() {
    final revenues = _result.monthlyRevenues;
    final costs = _result.monthlyCosts;
    final net = _result.monthlyCashFlows;

    final revData = _showCumulative ? _cumulative(revenues) : revenues;
    final costData = _showCumulative ? _cumulative(costs) : costs;
    final netData = _showCumulative ? _cumulative(net) : net;

    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _hInterval(revData, costData, netData),
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white10, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _xInterval(revData.length),
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(v.toInt().toString(),
                    style:
                        const TextStyle(color: Colors.white30, fontSize: 10)),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (v, _) => Text(_shortNum(v),
                  style:
                      const TextStyle(color: Colors.white30, fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _line(revData, _blue, 1.8),
          _line(costData, _red, 1.8),
          _line(netData, _gold, 2.2),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final c = [_blue, _red, _gold];
              return LineTooltipItem(
                _fmtCurrency(s.y),
                TextStyle(
                    color: c[s.barIndex % c.length],
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  LineChartBarData _line(List<double> data, Color color, double w) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: w,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.04),
      ),
    );
  }

  double _hInterval(List<double> a, List<double> b, List<double> c) {
    final all = [...a, ...b, ...c];
    if (all.isEmpty) return 1;
    final range =
        all.reduce((x, y) => x > y ? x : y) - all.reduce((x, y) => x < y ? x : y);
    if (range == 0) return 1;
    return (range / 5).ceilToDouble();
  }

  double _xInterval(int len) {
    if (len <= 12) return 1;
    if (len <= 24) return 2;
    if (len <= 48) return 4;
    return 6;
  }

  String _shortNum(double v) {
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  List<double> _cumulative(List<double> values) {
    double sum = 0;
    return values.map((v) {
      sum += v;
      return sum;
    }).toList();
  }
  // ==========================================================
  // LAUNCHES VIEW
  // ==========================================================
  Widget _buildLaunchesView(AppLocalizations t) {
    // Busca empreendimentos criados nos últimos 30 dias
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.rocket_launch_outlined, color: _gold, size: 20),
            const SizedBox(width: 10),
            Text(t.private_launches,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(t.private_launches_subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 20),

        // Grid de cards
        Expanded(
          child: FutureBuilder<List<Development>>(
            future: _fetchRecentLaunches(cutoff),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: _gold));
              }
              final devs = snapshot.data ?? [];
              if (devs.isEmpty) {
                return Center(
                  child: Text(t.private_no_launches,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 14)),
                );
              }

              return FutureBuilder<Set<String>>(
                future: FavoriteService.fetchFavoriteIds(),
                builder: (context, favSnap) {
                  final favIds = favSnap.data ?? {};

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: devs.length,
                    itemBuilder: (context, i) {
                      final dev = devs[i];
                      return DevelopmentCard(
                        development: dev,
                        isFavorite: favIds.contains(dev.id),
                        onFavorite: () async {
                          final isFav = favIds.contains(dev.id);
                          setState(() {
                            isFav
                                ? favIds.remove(dev.id)
                                : favIds.add(dev.id);
                          });
                          isFav
                              ? await FavoriteService.removeFavorite(dev.id)
                              : await FavoriteService.addFavorite(dev.id);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Development>> _fetchRecentLaunches(DateTime cutoff) async {
    final data = await Supabase.instance.client
        .from('developments')
        .select()
        .gte('created_at', cutoff.toIso8601String())
        .order('created_at', ascending: false);

    return (data as List).map((j) => Development.fromJson(j)).toList();
  }

  // ==========================================================
  // STOCK VIEW
  // ==========================================================
  Widget _buildStockView(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: _gold, size: 20),
              const SizedBox(width: 10),
              Text(t.private_stock,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.stock_subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 20),

          // Grid
          Expanded(
            child: FutureBuilder<List<StockItem>>(
              future: StockService.fetchStockItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _gold));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Text(t.stock_no_items,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 14)),
                  );
                }
                return GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _buildStockCard(items[i], t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Premium Unsplash images for stock cards — apartments & high-rises
  static const _stockImages = [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&q=80',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&q=80',
    'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=600&q=80',
    'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&q=80',
    'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=600&q=80',
    'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=600&q=80',
  ];

  String _getStockImageUrl(StockItem item) {
    if (item.imageUrl != null && item.imageUrl!.startsWith('http')) {
      return item.imageUrl!;
    }
    final idx = item.name.hashCode.abs() % _stockImages.length;
    return _stockImages[idx];
  }

  Widget _buildStockCard(StockItem item, AppLocalizations t) {
    final fmt = NumberFormat('#,##0', 'pt_BR');
    final discount = item.discountPct;
    final imgUrl = _getStockImageUrl(item);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PREMIUM IMAGE with overlay ──
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 2.0,
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) => p == null
                      ? child
                      : Container(
                          color: _card,
                          child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _gold),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: _card,
                    child: const Center(
                      child: Icon(Icons.apartment,
                          size: 32, color: Color(0x44D4AF37)),
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              // Discount badge
              if (discount > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          '-${discount.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              // Liquidation label
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t.stock_liquidation,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              // Name overlay on image bottom
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(blurRadius: 6, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── CONTENT ──
          Expanded(
            child: Container(
              color: _card,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Region
                  Text(item.region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 6),

                  // Info chips
                  Row(
                    children: [
                      _stockInfoChip(Icons.straighten,
                          '${item.areaM2.toStringAsFixed(0)} m²'),
                      const SizedBox(width: 8),
                      _stockInfoChip(Icons.apartment, item.unitRef),
                      const SizedBox(width: 8),
                      _stockInfoChip(
                          Icons.calendar_today, item.deliveryDate),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Available units
                  Row(
                    children: [
                      Icon(Icons.door_front_door_outlined,
                          color: _gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        t.stock_units_available(item.availableUnits),
                        style: TextStyle(
                          color:
                              item.availableUnits <= 3 ? _red : _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Prices — crossed out
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.stock_price_table,
                                style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 9)),
                            Text('R\$ ${fmt.format(item.priceTable)}',
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 12,
                                  decoration:
                                      TextDecoration.lineThrough,
                                  decorationColor: Colors.white30
                                      .withValues(alpha: 0.6),
                                )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.stock_price_tabelao,
                                style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 9)),
                            Text(
                                'R\$ ${fmt.format(item.priceTabelao)}',
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor:
                                      Colors.white30.withValues(alpha: 0.6),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Week price — highlighted
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _gold.withValues(alpha: 0.15),
                          _gold.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _gold.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Text(t.stock_price_week,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 10)),
                        const Spacer(),
                        Text('R\$ ${fmt.format(item.priceWeek)}',
                            style: const TextStyle(
                                color: _gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Payment conditions — expandable
                  _StockPaymentExpander(item: item, t: t),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white30),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  // ==========================================================
  // EDUCATION VIEW — Vídeos e Insights
  // ==========================================================
  Widget _buildEducationView(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_outline, color: _gold, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.edu_videos_title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(t.edu_videos_subtitle,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          // Admin button - gerenciar vídeos
          FutureBuilder<bool>(
            future: _checkIsAdmin(),
            builder: (context, snap) {
              if (snap.data != true) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVideosPage())),
                  icon: const Icon(Icons.admin_panel_settings, size: 18),
                  label: const Text('Gerenciar Vídeos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Categorias
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchEducationContent(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _gold));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return _buildEducationEmpty(t);
                }
                return GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) =>
                      _buildEducationCard(items[i], t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationEmpty(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.video_library_outlined,
              size: 48, color: _gold.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(t.edu_no_content,
              style: const TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 8),
          Text(t.edu_coming_soon,
              style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> item, AppLocalizations t) {
    final title = item['title'] ?? '';
    final description = item['description'] ?? '';
    final category = item['category'] ?? '';
    final duration = item['duration_minutes'] ?? 0;
    final thumbnailUrl = item['thumbnail_url'] as String?;

    IconData catIcon;
    Color catColor;
    switch (category) {
      case 'video':
        catIcon = Icons.play_circle_filled;
        catColor = _red;
        break;
      case 'article':
        catIcon = Icons.article_outlined;
        catColor = _blue;
        break;
      case 'course':
        catIcon = Icons.school_outlined;
        catColor = _gold;
        break;
      default:
        catIcon = Icons.lightbulb_outline;
        catColor = _gold;
    }

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail / placeholder
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                  Image.network(thumbnailUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _eduPlaceholder(catIcon, catColor))
                else
                  _eduPlaceholder(catIcon, catColor),
                // Duration badge
                if (duration > 0)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${duration} min',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9)),
                    ),
                  ),
                // Category badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(catIcon, size: 10, color: catColor),
                        const SizedBox(width: 3),
                        Text(category.toUpperCase(),
                            style: TextStyle(
                                color: catColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eduPlaceholder(IconData icon, Color color) {
    return Container(
      color: color.withValues(alpha: 0.08),
      child: Center(child: Icon(icon, size: 32, color: color.withValues(alpha: 0.3))),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchEducationContent() async {
    try {
      final data = await Supabase.instance.client
          .from('education_content')
          .select()
          .eq('status', 'published')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<bool> _checkIsAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      return profile['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // PARTNERSHIP VIEW — Proposta de Parceria
  // ==========================================================
  Widget _buildPartnershipView(AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.handshake_outlined, color: _gold, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.partnership_title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(t.partnership_subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── A quem se destina? ──
          _partnershipSection(
            icon: Icons.people_outline,
            title: t.partnership_audience_title,
            description: t.partnership_audience_desc,
            items: [
              t.partnership_audience_1,
              t.partnership_audience_2,
              t.partnership_audience_3,
            ],
          ),
          const SizedBox(height: 16),

          // ── Tipos de Parceria ──
          Text(t.partnership_types_title.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 12),

          // Cards grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _partnershipTypeCard(
                  icon: Icons.workspace_premium,
                  title: t.partnership_vip_title,
                  description: t.partnership_vip_desc,
                  features: [
                    t.partnership_vip_1,
                    t.partnership_vip_2,
                    t.partnership_vip_3,
                  ],
                  accentColor: _gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _partnershipTypeCard(
                  icon: Icons.psychology_outlined,
                  title: t.partnership_mentoring_title,
                  description: t.partnership_mentoring_desc,
                  features: [
                    t.partnership_mentoring_1,
                    t.partnership_mentoring_2,
                    t.partnership_mentoring_3,
                  ],
                  accentColor: _blue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _partnershipTypeCard(
                  icon: Icons.business_center_outlined,
                  title: t.partnership_prospecting_title,
                  description: t.partnership_prospecting_desc,
                  features: [
                    t.partnership_prospecting_1,
                    t.partnership_prospecting_2,
                    t.partnership_prospecting_3,
                  ],
                  accentColor: const Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // CTA
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(t.partnership_cta,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnershipSection({
    required IconData icon,
    required String title,
    required String description,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _gold, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: _gold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _partnershipTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 14),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, size: 14, color: accentColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(f,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ==========================================================
  // CATALOG VIEW — Catálogo de Produtos SPE
  // ==========================================================
  Widget _buildCatalogView(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, color: _gold, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.catalog_title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(t.catalog_subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCatalogProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _gold));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Text(t.catalog_no_items,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 14)),
                  );
                }
                return GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) =>
                      _buildCatalogCard(items[i], t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(Map<String, dynamic> item, AppLocalizations t) {
    final name = item['name'] ?? '';
    final speName = item['spe_name'] ?? '';
    final targetReturn = (item['target_return_pct'] as num?)?.toDouble() ?? 0;
    final proposedReturn =
        (item['proposed_return_pct'] as num?)?.toDouble() ?? 0;
    final minInvestment = (item['min_investment'] as num?)?.toDouble() ?? 0;
    final status = item['status'] ?? 'open';
    final category = item['category'] ?? '';

    final fmt = NumberFormat('#,##0', 'pt_BR');

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.business, color: _gold, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    if (speName.isNotEmpty)
                      Text('SPE: $speName',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'open'
                      ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status == 'open'
                      ? t.catalog_status_open
                      : t.catalog_status_closed,
                  style: TextStyle(
                    color: status == 'open'
                        ? const Color(0xFF22C55E)
                        : Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (category.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(category.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
          ],
          const SizedBox(height: 14),

          // Gráfico de barras: Rentabilidade vs Proposta
          Text(t.catalog_return_chart,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _catalogReturnBar(
              t.catalog_target, targetReturn, _blue),
          const SizedBox(height: 6),
          _catalogReturnBar(
              t.catalog_proposed, proposedReturn, _gold),
          const Spacer(),

          // Min investment
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _gold.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.catalog_min_investment,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 10)),
                Text('R\$ ${fmt.format(minInvestment)}',
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _catalogReturnBar(String label, double pct, Color color) {
    final barWidth = (pct / 30).clamp(0.05, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: barWidth,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 4),
                  child: Text('${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                          color: color,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCatalogProducts() async {
    try {
      final data = await Supabase.instance.client
          .from('investment_catalog')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  // ==========================================================
  // CALCULATOR VIEW — Comparação de Investimentos
  // ==========================================================
  double _calcInitial = 100000;
  int _calcYears = 10;

  Widget _buildCalculatorView(AppLocalizations t) {
    // Índices de comparação
    final indices = [
      _CalcIndex(t.calc_real_estate, 0.12, _gold),
      _CalcIndex('CDI', 0.105, _blue),
      _CalcIndex('IPCA', 0.045, const Color(0xFF22C55E)),
      _CalcIndex('Ibovespa', 0.10, const Color(0xFFEF4444)),
      _CalcIndex('S&P 500', 0.11, const Color(0xFF8B5CF6)),
      _CalcIndex(t.calc_savings, 0.065, Colors.white38),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: _gold, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.calculator_title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(t.calculator_subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sliders
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border, width: 0.6),
            ),
            child: Row(
              children: [
                // Valor inicial
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.calc_initial_value,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          const Spacer(),
                          Text(_fmtCurrency(_calcInitial),
                              style: const TextStyle(
                                  color: _gold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _gold,
                          inactiveTrackColor: _border,
                          thumbColor: _gold,
                          overlayColor: _gold.withValues(alpha: 0.1),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: _calcInitial,
                          min: 10000,
                          max: 2000000,
                          divisions: 199,
                          onChanged: (v) =>
                              setState(() => _calcInitial = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Prazo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.calc_period,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          const Spacer(),
                          Text('$_calcYears ${t.calc_years}',
                              style: const TextStyle(
                                  color: _gold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _gold,
                          inactiveTrackColor: _border,
                          thumbColor: _gold,
                          overlayColor: _gold.withValues(alpha: 0.1),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: _calcYears.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          onChanged: (v) =>
                              setState(() => _calcYears = v.round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Chart + Table
          Expanded(
            child: Row(
              children: [
                // Chart
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border, width: 0.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ...indices.map((idx) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: idx.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(idx.name,
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 9)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              backgroundColor: Colors.transparent,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(
                                    color: Colors.white10,
                                    strokeWidth: 0.5),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (_calcYears / 5)
                                        .ceilToDouble()
                                        .clamp(1, 10),
                                    getTitlesWidget: (v, _) => Text(
                                        '${v.toInt()}',
                                        style: const TextStyle(
                                            color: Colors.white30,
                                            fontSize: 10)),
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 55,
                                    getTitlesWidget: (v, _) => Text(
                                        _shortNum(v),
                                        style: const TextStyle(
                                            color: Colors.white30,
                                            fontSize: 10)),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: indices
                                  .map((idx) => LineChartBarData(
                                        spots: List.generate(
                                          _calcYears + 1,
                                          (y) => FlSpot(
                                            y.toDouble(),
                                            _calcInitial *
                                                math.pow(
                                                    1 + idx.rate, y),
                                          ),
                                        ),
                                        isCurved: true,
                                        color: idx.color,
                                        barWidth: idx.name ==
                                                t.calc_real_estate
                                            ? 2.5
                                            : 1.5,
                                        dotData:
                                            const FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: idx.name ==
                                              t.calc_real_estate,
                                          color: _gold.withValues(
                                              alpha: 0.05),
                                        ),
                                      ))
                                  .toList(),
                              lineTouchData: LineTouchData(
                                touchTooltipData:
                                    LineTouchTooltipData(
                                  getTooltipItems: (spots) =>
                                      spots.map((s) {
                                    return LineTooltipItem(
                                      _fmtCurrency(s.y),
                                      TextStyle(
                                          color: indices[s.barIndex]
                                              .color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Results table
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border, width: 0.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.calc_results,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            '${t.calc_after} $_calcYears ${t.calc_years}',
                            style: const TextStyle(
                                color: Colors.white30, fontSize: 10)),
                        const SizedBox(height: 14),
                        ...indices.map((idx) {
                          final finalVal = _calcInitial *
                              math.pow(1 + idx.rate, _calcYears);
                          final profit = finalVal - _calcInitial;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: idx.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(idx.name,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11)),
                                      Text(
                                          '${(idx.rate * 100).toStringAsFixed(1)}% a.a.',
                                          style: const TextStyle(
                                              color: Colors.white24,
                                              fontSize: 9)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(_fmtCurrency(finalVal),
                                        style: TextStyle(
                                            color: idx.color,
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w700)),
                                    Text(
                                        '+${_fmtCurrency(profit)}',
                                        style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 9)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MARKET LEADS VIEW — São Paulo / Flórida
  // ==========================================================
  Widget _buildMarketLeadsView(AppLocalizations t, String market) {
    final isSP = market == 'sao_paulo';
    final title = isSP ? t.market_sp_title : t.market_fl_title;
    final subtitle = isSP ? t.market_sp_subtitle : t.market_fl_subtitle;
    final icon = isSP ? Icons.location_city : Icons.beach_access_outlined;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _gold, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Leads list
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMarketLeads(market),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _gold));
                }
                final leads = snapshot.data ?? [];
                if (leads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 48,
                            color: _gold.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(t.market_no_leads,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 14)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _buildLeadCard(leads[i], t, isSP),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(
      Map<String, dynamic> lead, AppLocalizations t, bool isSP) {
    final name = lead['name'] ?? '';
    final email = lead['email'] ?? '';
    final phone = lead['phone'] ?? '';
    final interest = lead['interest'] ?? '';
    final budget = (lead['budget'] as num?)?.toDouble();
    final status = lead['status'] ?? 'new';
    final createdAt = lead['created_at'] != null
        ? DateTime.tryParse(lead['created_at'].toString())
        : null;
    final company = lead['company'] ?? '';

    final fmt = NumberFormat('#,##0', 'pt_BR');

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'contacted':
        statusColor = _blue;
        statusLabel = t.lead_status_contacted;
        break;
      case 'qualified':
        statusColor = const Color(0xFF22C55E);
        statusLabel = t.lead_status_qualified;
        break;
      case 'closed':
        statusColor = _gold;
        statusLabel = t.lead_status_closed;
        break;
      default:
        statusColor = Colors.white38;
        statusLabel = t.lead_status_new;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: _gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (company.isNotEmpty) ...[
                      const Icon(Icons.business,
                          size: 11, color: Colors.white30),
                      const SizedBox(width: 4),
                      Text(company,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                      const SizedBox(width: 12),
                    ],
                    if (email.isNotEmpty) ...[
                      const Icon(Icons.email_outlined,
                          size: 11, color: Colors.white30),
                      const SizedBox(width: 4),
                      Text(email,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (phone.isNotEmpty) ...[
                      const Icon(Icons.phone_outlined,
                          size: 11, color: Colors.white30),
                      const SizedBox(width: 4),
                      Text(phone,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                      const SizedBox(width: 12),
                    ],
                    if (interest.isNotEmpty) ...[
                      Icon(Icons.interests_outlined,
                          size: 11, color: _gold.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(interest,
                          style: TextStyle(
                              color: _gold.withValues(alpha: 0.7),
                              fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Budget + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (budget != null && budget > 0)
                Text(
                  isSP
                      ? 'R\$ ${fmt.format(budget)}'
                      : 'US\$ ${fmt.format(budget)}',
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              if (createdAt != null)
                Text(
                  DateFormat('dd/MM/yyyy').format(createdAt),
                  style: const TextStyle(
                      color: Colors.white24, fontSize: 9),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchMarketLeads(String market) async {
    try {
      final data = await Supabase.instance.client
          .from('market_leads')
          .select()
          .eq('market', market)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}

// ==========================================================
// STOCK PAYMENT EXPANDER
// ==========================================================
class _StockPaymentExpander extends StatefulWidget {
  final StockItem item;
  final AppLocalizations t;
  const _StockPaymentExpander({required this.item, required this.t});

  @override
  State<_StockPaymentExpander> createState() => _StockPaymentExpanderState();
}

class _StockPaymentExpanderState extends State<_StockPaymentExpander> {
  bool _expanded = false;

  static const _gold = Color(0xFFFFC107);
  static const _border = Color(0xFF1F2A44);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final t = widget.t;
    final fmt = NumberFormat('#,##0', 'pt_BR');

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _border, width: 0.4),
            ),
            child: Row(
              children: [
                Icon(Icons.payment, size: 13, color: _gold),
                const SizedBox(width: 6),
                Text(t.stock_payment_conditions,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11)),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.white38,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _border, width: 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _payRow(t.stock_down_payment,
                    '${(item.downPaymentPct * 100).toStringAsFixed(0)}% — R\$ ${fmt.format(item.downPaymentValue)}'),
                _payRow(t.stock_installments,
                    '${item.installments306090}x R\$ ${fmt.format(item.installmentValue)}'),
                _payRow(t.stock_financing,
                    'R\$ ${fmt.format(item.financingTotal)}'),
                _payRow(t.stock_first_installment,
                    'R\$ ${fmt.format(item.firstInstallment)}'),
                _payRow(t.stock_last_installment,
                    'R\$ ${fmt.format(item.lastInstallment)}'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _payRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==========================================================
// HELPERS
// ==========================================================
class _MetricData {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  const _MetricData(this.icon, this.title, this.value, this.subtitle);
}

class _CalcIndex {
  final String name;
  final double rate;
  final Color color;
  const _CalcIndex(this.name, this.rate, this.color);
}

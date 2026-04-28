import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../generated/app_localizations.dart';

// ══════════════════════════════════════════════════════════════
// STR Analytics — 6 funcionalidades inspiradas no AirDNA
// ══════════════════════════════════════════════════════════════

enum STRSection { revenueCalc, heatmap, compSets, dynamicPricing, seasonality, strProperties }

class STRAnalyticsPage extends StatefulWidget {
  const STRAnalyticsPage({super.key});
  @override
  State<STRAnalyticsPage> createState() => _STRAnalyticsPageState();
}

class _STRAnalyticsPageState extends State<STRAnalyticsPage> {
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);

  STRSection _section = STRSection.revenueCalc;

  // Revenue Calculator state
  int _bedrooms = 2;
  int _bathrooms = 2;
  int _guests = 4;
  String _selectedCity = 'São Paulo';
  bool _calculated = false;

  // Dynamic Pricing state
  String _pricingCity = 'Miami';
  int _pricingBedrooms = 2;

  // Comp Sets state
  String _compCity = 'São Paulo';

  String _fmtCurrency(double v, {String prefix = 'R\$'}) {
    final fmt = NumberFormat('#,##0', 'pt_BR');
    return '$prefix ${fmt.format(v.round())}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      color: _bg,
      child: Column(
        children: [
          isMobile ? _buildMobileTabSelector(t) : _buildTabBar(t),
          Expanded(child: _buildContent(t)),
        ],
      ),
    );
  }

  Widget _buildMobileTabSelector(AppLocalizations t) {
    final tabs = [
      (STRSection.revenueCalc, t.str_revenue_calc),
      (STRSection.heatmap, t.str_heatmap),
      (STRSection.compSets, t.str_comp_sets),
      (STRSection.dynamicPricing, t.str_dynamic_pricing),
      (STRSection.seasonality, t.str_seasonality),
      (STRSection.strProperties, t.str_properties),
    ];
    final currentLabel = tabs.firstWhere((t) => t.$1 == _section).$2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1628),
        border: Border(bottom: BorderSide(color: _border, width: 0.5)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<STRSection>(
            value: _section,
            isExpanded: true,
            dropdownColor: _card,
            icon: const Icon(Icons.keyboard_arrow_down, color: _gold, size: 20),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: tabs.map((tab) => DropdownMenuItem(
              value: tab.$1,
              child: Text(tab.$2),
            )).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _section = v);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations t) {
    final tabs = [
      (STRSection.revenueCalc, Icons.calculate_outlined, t.str_revenue_calc),
      (STRSection.heatmap, Icons.map_outlined, t.str_heatmap),
      (STRSection.compSets, Icons.compare_arrows, t.str_comp_sets),
      (STRSection.dynamicPricing, Icons.price_change_outlined, t.str_dynamic_pricing),
      (STRSection.seasonality, Icons.calendar_month, t.str_seasonality),
      (STRSection.strProperties, Icons.house_outlined, t.str_properties),
    ];
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1628),
        border: Border(bottom: BorderSide(color: _border, width: 0.5)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: tabs.map((tab) {
          final selected = _section == tab.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _section = tab.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? _gold.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? _gold.withOpacity(0.3) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(tab.$2, size: 16, color: selected ? _gold : Colors.white38),
                    const SizedBox(width: 6),
                    Text(tab.$3, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? _gold : Colors.white54)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(AppLocalizations t) {
    return switch (_section) {
      STRSection.revenueCalc => _buildRevenueCalc(t),
      STRSection.heatmap => _buildHeatmap(t),
      STRSection.compSets => _buildCompSets(t),
      STRSection.dynamicPricing => _buildDynamicPricing(t),
      STRSection.seasonality => _buildSeasonality(t),
      STRSection.strProperties => _buildSTRProperties(t),
    };
  }

  // ══════════════════════════════════════════
  // 1. CALCULADORA DE RECEITA STR
  // ══════════════════════════════════════════
  Widget _buildRevenueCalc(AppLocalizations t) {
    final cities = ['São Paulo', 'Miami', 'Orlando', 'Rio de Janeiro'];
    final rng = math.Random(_bedrooms * 100 + _bathrooms * 10 + _guests + _selectedCity.hashCode);
    final adr = 280.0 + rng.nextDouble() * 420 + _bedrooms * 80;
    final occupancy = 0.55 + rng.nextDouble() * 0.3;
    final monthlyRev = adr * 30 * occupancy;
    final annualRev = monthlyRev * 12;
    final isUSD = _selectedCity == 'Miami' || _selectedCity == 'Orlando';
    final prefix = isUSD ? 'US\$' : 'R\$';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.str_revenue_calc, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t.str_revenue_calc_sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 24),

          // Input card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
            child: Column(
              children: [
                // City selector
                Row(children: [
                  const Icon(Icons.location_on, color: _gold, size: 18),
                  const SizedBox(width: 8),
                  Text(t.str_city, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _selectedCity,
                    dropdownColor: _card,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    underline: const SizedBox(),
                    items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() { _selectedCity = v!; _calculated = false; }),
                  ),
                ]),
                const SizedBox(height: 16),
                _counterRow(Icons.bed, t.str_bedrooms, _bedrooms, (v) => setState(() { _bedrooms = v; _calculated = false; }), 1, 10),
                const SizedBox(height: 12),
                _counterRow(Icons.bathtub_outlined, t.str_bathrooms, _bathrooms, (v) => setState(() { _bathrooms = v; _calculated = false; }), 1, 8),
                const SizedBox(height: 12),
                _counterRow(Icons.people_outline, t.str_guests, _guests, (v) => setState(() { _guests = v; _calculated = false; }), 1, 20),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () => setState(() => _calculated = true),
                    child: Text(t.str_calculate, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          if (_calculated) ...[
            const SizedBox(height: 24),
            // Results
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_gold.withOpacity(0.08), _gold.withOpacity(0.02)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _gold.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(t.str_estimated_revenue, style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _resultMetric(t.str_adr, _fmtCurrency(adr, prefix: prefix), Icons.nights_stay),
                      _resultMetric(t.str_occupancy, '${(occupancy * 100).toStringAsFixed(0)}%', Icons.event_available),
                      _resultMetric(t.str_monthly, _fmtCurrency(monthlyRev, prefix: prefix), Icons.calendar_today),
                      _resultMetric(t.str_annual, _fmtCurrency(annualRev, prefix: prefix), Icons.trending_up),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _counterRow(IconData icon, String label, int value, ValueChanged<int> onChanged, int min, int max) {
    return Row(children: [
      Icon(icon, color: Colors.white38, size: 18),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      const Spacer(),
      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.white38, size: 20), onPressed: value > min ? () => onChanged(value - 1) : null),
      Text('$value', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      IconButton(icon: const Icon(Icons.add_circle_outline, color: _gold, size: 20), onPressed: value < max ? () => onChanged(value + 1) : null),
    ]);
  }

  Widget _resultMetric(String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, color: _gold, size: 22),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
    ]);
  }

  // ══════════════════════════════════════════
  // 2. MAPA DE CALOR DE MERCADO
  // ══════════════════════════════════════════
  Widget _buildHeatmap(AppLocalizations t) {
    final regions = [
      _HeatRegion('Vila Olímpia', 92, 'R\$ 580', 78),
      _HeatRegion('Itaim Bibi', 88, 'R\$ 620', 82),
      _HeatRegion('Pinheiros', 85, 'R\$ 490', 75),
      _HeatRegion('Moema', 80, 'R\$ 510', 70),
      _HeatRegion('Jardins', 78, 'R\$ 680', 68),
      _HeatRegion('Brooklin', 75, 'R\$ 450', 72),
      _HeatRegion('Miami Beach', 95, 'US\$ 320', 85),
      _HeatRegion('Brickell', 90, 'US\$ 280', 80),
      _HeatRegion('Wynwood', 82, 'US\$ 210', 74),
      _HeatRegion('Orlando - Kissimmee', 88, 'US\$ 190', 82),
      _HeatRegion('Orlando - Champions Gate', 86, 'US\$ 240', 79),
      _HeatRegion('Copacabana', 84, 'US\$ 150', 76),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.str_heatmap, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t.str_heatmap_sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 8),
          // Legend
          Row(children: [
            _legendDot(Colors.red, t.str_heat_high),
            const SizedBox(width: 16),
            _legendDot(Colors.orange, t.str_heat_medium),
            const SizedBox(width: 16),
            _legendDot(Colors.green, t.str_heat_low),
          ]),
          const SizedBox(height: 20),
          ...regions.map((r) => _heatCard(r)),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
    ]);
  }

  Widget _heatCard(_HeatRegion r) {
    final color = r.score >= 85 ? Colors.red : (r.score >= 75 ? Colors.orange : Colors.green);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(children: [
        Container(width: 8, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Text('ADR: ${r.adr}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${r.score}', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${r.occupancy}% ocp.', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
        ]),
      ]),
    );
  }

  // ══════════════════════════════════════════
  // 3. COMP SETS — Comparativo de Listings
  // ══════════════════════════════════════════
  Widget _buildCompSets(AppLocalizations t) {
    final cities = ['São Paulo', 'Miami', 'Orlando', 'Rio de Janeiro'];
    final rng = math.Random(_compCity.hashCode);
    final comps = List.generate(6, (i) {
      final adr = 200.0 + rng.nextDouble() * 500;
      final occ = 0.5 + rng.nextDouble() * 0.4;
      final rev = adr * 30 * occ;
      final rating = 4.0 + rng.nextDouble() * 1.0;
      return _CompListing('${t.str_listing} ${i + 1}', adr, occ, rev, rating, '${(rng.nextInt(3) + 1)}q/${(rng.nextInt(2) + 1)}b');
    });
    final isUSD = _compCity == 'Miami' || _compCity == 'Orlando';
    final prefix = isUSD ? 'US\$' : 'R\$';
    final avgAdr = comps.map((c) => c.adr).reduce((a, b) => a + b) / comps.length;
    final avgOcc = comps.map((c) => c.occupancy).reduce((a, b) => a + b) / comps.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.str_comp_sets, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t.str_comp_sets_sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.location_on, color: _gold, size: 16),
            const SizedBox(width: 6),
            DropdownButton<String>(
              value: _compCity,
              dropdownColor: _card,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              underline: const SizedBox(),
              items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _compCity = v!),
            ),
          ]),
          const SizedBox(height: 12),
          // Averages
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [_gold.withOpacity(0.08), _gold.withOpacity(0.02)]), borderRadius: BorderRadius.circular(10), border: Border.all(color: _gold.withOpacity(0.2))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _compAvg(t.str_avg_adr, _fmtCurrency(avgAdr, prefix: prefix)),
              _compAvg(t.str_avg_occupancy, '${(avgOcc * 100).toStringAsFixed(0)}%'),
              _compAvg(t.str_listings_count, '${comps.length}'),
            ]),
          ),
          const SizedBox(height: 16),
          ...comps.map((c) => _compCard(c, prefix)),
        ],
      ),
    );
  }

  Widget _compAvg(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
    ]);
  }

  Widget _compCard(_CompListing c, String prefix) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: _gold.withOpacity(0.15), child: const Icon(Icons.home, color: _gold, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(c.config, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_fmtCurrency(c.adr, prefix: prefix), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Row(children: [
            Icon(Icons.star, color: Colors.amber, size: 12),
            Text(' ${c.rating.toStringAsFixed(1)}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            Text(' • ${(c.occupancy * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ]),
        ]),
      ]),
    );
  }

  // ══════════════════════════════════════════
  // 4. PRECIFICAÇÃO DINÂMICA
  // ══════════════════════════════════════════
  Widget _buildDynamicPricing(AppLocalizations t) {
    final cities = ['Miami', 'Orlando', 'São Paulo', 'Rio de Janeiro'];
    final isUSD = _pricingCity == 'Miami' || _pricingCity == 'Orlando';
    final prefix = isUSD ? 'US\$' : 'R\$';
    final base = isUSD ? 180.0 : 350.0;
    final rng = math.Random(_pricingCity.hashCode + _pricingBedrooms);

    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final prices = List.generate(12, (i) {
      final seasonal = (i == 0 || i == 1 || i == 6 || i == 11) ? 1.4 : (i >= 3 && i <= 5) ? 0.75 : 1.0;
      return (base + _pricingBedrooms * 60) * seasonal * (0.9 + rng.nextDouble() * 0.2);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.str_dynamic_pricing, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t.str_dynamic_pricing_sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 16),
          Row(children: [
            DropdownButton<String>(
              value: _pricingCity, dropdownColor: _card,
              style: const TextStyle(color: Colors.white, fontSize: 13), underline: const SizedBox(),
              items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _pricingCity = v!),
            ),
            const SizedBox(width: 16),
            _counterRow(Icons.bed, t.str_bedrooms, _pricingBedrooms, (v) => setState(() => _pricingBedrooms = v), 1, 8),
          ].map((w) => Expanded(child: w)).toList()),
          const SizedBox(height: 24),
          // Chart
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: prices.reduce(math.max) * 1.15,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (g, gi, r, ri) => BarTooltipItem('$prefix ${r.toY.toStringAsFixed(0)}', const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(months[v.toInt()], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)))),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(12, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: prices[i], color: prices[i] > base * 1.2 ? _gold : const Color(0xFF3B82F6), width: 16, borderRadius: BorderRadius.circular(4)),
              ])),
            )),
          ),
          const SizedBox(height: 16),
          // Price table
          ...List.generate(12, (i) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
            child: Row(children: [
              Text(months[i], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text(_fmtCurrency(prices[i], prefix: prefix), style: TextStyle(color: prices[i] > base * 1.2 ? _gold : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              if (prices[i] > base * 1.2) ...[
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _gold.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(t.str_high_demand, style: const TextStyle(color: _gold, fontSize: 9, fontWeight: FontWeight.bold))),
              ],
            ]),
          )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // 5. SAZONALIDADE
  // ══════════════════════════════════════════
  Widget _buildSeasonality(AppLocalizations t) {
    final cities = {
      'São Paulo': [0.65, 0.70, 0.60, 0.55, 0.50, 0.58, 0.72, 0.68, 0.62, 0.60, 0.64, 0.75],
      'Miami': [0.85, 0.88, 0.82, 0.70, 0.60, 0.55, 0.65, 0.62, 0.58, 0.65, 0.72, 0.80],
      'Orlando': [0.80, 0.78, 0.82, 0.75, 0.60, 0.85, 0.90, 0.85, 0.65, 0.70, 0.75, 0.88],
      'Rio de Janeiro': [0.80, 0.85, 0.70, 0.55, 0.50, 0.55, 0.75, 0.65, 0.58, 0.60, 0.65, 0.82],
    };
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final colors = [const Color(0xFF3B82F6), _gold, const Color(0xFF22C55E), const Color(0xFFEF4444)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.str_seasonality, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t.str_seasonality_sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 8),
          // Legend
          Wrap(spacing: 12, runSpacing: 6, children: cities.keys.toList().asMap().entries.map((e) =>
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 3, color: colors[e.key]),
              const SizedBox(width: 4),
              Text(e.value, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ]),
          ).toList()),
          const SizedBox(height: 20),
          // Chart
          Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
            child: LineChart(LineChartData(
              minY: 0.3, maxY: 1.0,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, m) {
                  if (v.toInt() >= 0 && v.toInt() < 12) return Text(months[v.toInt()], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9));
                  return const SizedBox();
                })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, m) => Text('${(v * 100).toInt()}%', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)))),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: _border, strokeWidth: 0.5)),
              borderData: FlBorderData(show: false),
              lineBarsData: cities.entries.toList().asMap().entries.map((e) => LineChartBarData(
                spots: List.generate(12, (i) => FlSpot(i.toDouble(), e.value.value[i])),
                color: colors[e.key],
                barWidth: 2,
                dotData: FlDotData(show: false),
                isCurved: true,
              )).toList(),
            )),
          ),
          const SizedBox(height: 20),
          // Insights
          Text(t.str_insights, style: const TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _insightCard(Icons.wb_sunny, t.str_insight_miami, Colors.orange),
          _insightCard(Icons.family_restroom, t.str_insight_orlando, const Color(0xFF22C55E)),
          _insightCard(Icons.celebration, t.str_insight_sp, const Color(0xFF3B82F6)),
          _insightCard(Icons.beach_access, t.str_insight_rj, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _insightCard(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12))),
      ]),
    );
  }

  // ══════════════════════════════════════════
  // 6. PROPRIEDADES À VENDA COM POTENCIAL STR
  // ══════════════════════════════════════════
  Widget _buildSTRProperties(AppLocalizations t) {
    final rng = math.Random(42);
    final properties = [
      _STRProperty('Flat Vila Olímpia', 'São Paulo', '2q/1b', 680000, 4200, 0.72, 'R\$'),
      _STRProperty('Studio Pinheiros', 'São Paulo', '1q/1b', 420000, 3100, 0.68, 'R\$'),
      _STRProperty('Apt Moema', 'São Paulo', '3q/2b', 950000, 5800, 0.65, 'R\$'),
      _STRProperty('Condo Brickell', 'Miami', '2q/2b', 450000, 3800, 0.78, 'US\$'),
      _STRProperty('Townhouse Kissimmee', 'Orlando', '4q/3b', 380000, 4500, 0.82, 'US\$'),
      _STRProperty('Apt Copacabana', 'Rio de Janeiro', '2q/1b', 580000, 3600, 0.70, 'R\$'),
      _STRProperty('Villa Champions Gate', 'Orlando', '5q/4b', 520000, 6200, 0.80, 'US\$'),
      _STRProperty('Loft Itaim', 'São Paulo', '1q/1b', 550000, 3400, 0.74, 'R\$'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.str_properties, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t.str_properties_sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 20),
          ...properties.map((p) {
            final annualRev = p.monthlyRev * 12 * p.occupancy;
            final yieldPct = (annualRev / p.price) * 100;
            final paybackYears = p.price / annualRev;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(radius: 20, backgroundColor: _gold.withOpacity(0.12), child: const Icon(Icons.apartment, color: _gold, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${p.city} • ${p.config}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: yieldPct > 8 ? Colors.green.withOpacity(0.15) : _gold.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text('${yieldPct.toStringAsFixed(1)}% yield', style: TextStyle(color: yieldPct > 8 ? Colors.green : _gold, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    _propMetric(t.str_price, _fmtCurrency(p.price.toDouble(), prefix: p.currency)),
                    _propMetric(t.str_monthly_rev, _fmtCurrency(p.monthlyRev.toDouble(), prefix: p.currency)),
                    _propMetric(t.str_occupancy, '${(p.occupancy * 100).toStringAsFixed(0)}%'),
                    _propMetric(t.str_payback_years, '${paybackYears.toStringAsFixed(1)} ${t.str_years}'),
                  ]),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _propMetric(String label, String value) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10)),
    ]));
  }
}

// ── Helper classes ──
class _HeatRegion {
  final String name;
  final int score;
  final String adr;
  final int occupancy;
  _HeatRegion(this.name, this.score, this.adr, this.occupancy);
}

class _CompListing {
  final String name;
  final double adr, occupancy, revenue, rating;
  final String config;
  _CompListing(this.name, this.adr, this.occupancy, this.revenue, this.rating, this.config);
}

class _STRProperty {
  final String name, city, config, currency;
  final int price, monthlyRev;
  final double occupancy;
  _STRProperty(this.name, this.city, this.config, this.price, this.monthlyRev, this.occupancy, this.currency);
}

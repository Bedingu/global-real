import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/private/fraction_simulation_input.dart';
import '../../models/private/fraction_simulation_result.dart';
import '../../services/private/fraction_simulation_engine.dart';
import '../../models/private/fraction_week.dart';
import '../../generated/app_localizations.dart';

class FractionPage extends StatefulWidget {
  const FractionPage({super.key});

  @override
  State<FractionPage> createState() => _FractionPageState();
}

class _FractionPageState extends State<FractionPage> {
  // ── CORES ──
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF22C55E);

  // ── SUPABASE ──
  late final SupabaseClient _client;
  late final RealtimeChannel _reservationChannel;
  late String _fractionInvestmentId;

  // ── ESTADO ──
  String _selectedDevelopment = "Vitacon Jardins";
  int _selectedWeeks = 2;
  int _holdingYears = 5;
  double _annualAppreciation = 0.12;
  double _annualYield = 0.05;
  double _estimatedVolatility = 0.15;

  late FractionSimulationResult _simulationResult;

  // ── CALENDÁRIO ──
  DateTime _focusedDay = DateTime.now();
  late List<FractionWeek> _weeks;

  int get _maxWeeksAllowed => _selectedWeeks;
  List<FractionWeek> get _selectedWeeksList =>
      _weeks.where((w) => w.isReserved).toList();

  // ── DADOS LOCAIS ──
  final Map<String, Map<int, Map<String, dynamic>>> _fractionData = {
    "Vitacon Jardins": {
      2: {"price": 320000, "simultaneous": 1},
      4: {"price": 610000, "simultaneous": 2},
      6: {"price": 890000, "simultaneous": 3},
    },
    "Vitacon Higienópolis": {
      2: {"price": 350000, "simultaneous": 1},
      4: {"price": 640000, "simultaneous": 2},
      6: {"price": 920000, "simultaneous": 3},
    },
  };

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _generateWeeks();
    _runSimulation();
    _initializePlatform();
  }

  Future<void> _initializePlatform() async {
    await _loadUserInvestment();
    _listenReservationsRealtime();
    await _reloadReservationsFromDatabase();
  }

  Future<void> _loadUserInvestment() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final data = await _client
        .from('fraction_investments')
        .select('id')
        .eq('user_id', user.id)
        .limit(1)
        .single();
    _fractionInvestmentId = data['id'];
  }

  void _listenReservationsRealtime() {
    _reservationChannel = _client
        .channel('fraction_reservations_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'fraction_reservations',
          callback: (payload) => _reloadReservationsFromDatabase(),
        )
        .subscribe();
  }

  Future<void> _reloadReservationsFromDatabase() async {
    final response =
        await _client.from('fraction_reservations').select('week_start_date');
    setState(() {
      for (final w in _weeks) {
        w.isReserved = false;
      }
      for (final item in response) {
        final date = DateTime.parse(item['week_start_date']);
        for (final week in _weeks) {
          if (_isSameWeek(week.start, date)) week.isReserved = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _reservationChannel.unsubscribe();
    super.dispose();
  }

  bool _isPremiumWeek(DateTime date) {
    if (date.month == 1) return true;
    if (date.month == 12 && date.day >= 20) return true;
    if (date.month == 2 && date.day >= 10 && date.day <= 25) return true;
    return false;
  }

  void _generateWeeks() {
    final now = DateTime.now();
    final end = DateTime(now.year + 2, now.month, now.day);
    _weeks = [];
    DateTime current = now;
    while (current.isBefore(end)) {
      final isPremium = _isPremiumWeek(current);
      _weeks.add(FractionWeek(
        start: current,
        isBlocked: isPremium && _selectedWeeks < 4,
      ));
      current = current.add(const Duration(days: 7));
    }
  }

  void _runSimulation() {
    final price =
        _fractionData[_selectedDevelopment]![_selectedWeeks]!["price"];
    final input = FractionSimulationInput(
      initialInvestment: (price as num).toDouble(),
      annualAppreciationRate: _annualAppreciation,
      holdingYears: _holdingYears,
      annualRentalYield: _annualYield,
    );
    _simulationResult = FractionSimulationEngine.run(input);
  }

  Future<void> _toggleWeek(DateTime date) async {
    final weekStart = date
        .subtract(Duration(days: date.weekday - 1))
        .toIso8601String()
        .split('T')
        .first;
    final week = _weeks.firstWhere(
      (w) => _isSameWeek(w.start, date),
      orElse: () => _weeks.first,
    );
    if (week.isBlocked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semana bloqueada")),
        );
      }
      return;
    }
    try {
      if (week.isReserved) {
        await _client
            .from('fraction_reservations')
            .delete()
            .eq('fraction_investment_id', _fractionInvestmentId)
            .eq('week_start_date', weekStart);
      } else {
        await _client.from('fraction_reservations').insert({
          'fraction_investment_id': _fractionInvestmentId,
          'week_start_date': weekStart,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${e.toString()}")),
        );
      }
    }
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final aS = a.subtract(Duration(days: a.weekday - 1));
    final bS = b.subtract(Duration(days: b.weekday - 1));
    return aS.year == bS.year && aS.month == bS.month && aS.day == bS.day;
  }

  String _fmtCurrency(double v) {
    final fmt = NumberFormat('#,##0', 'pt_BR');
    return 'R\$ ${fmt.format(v.round())}';
  }

  // ══════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final option = _fractionData[_selectedDevelopment]![_selectedWeeks]!;
    final price = (option["price"] as num).toDouble();
    final simultaneous = option["simultaneous"] as int;

    return Container(
      color: _bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── COLUNA ESQUERDA: Seleção + Calendário ──
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(t),
                  const SizedBox(height: 20),
                  _buildDevelopmentSelector(t),
                  const SizedBox(height: 20),
                  _buildQuotaCards(t),
                  const SizedBox(height: 20),
                  _buildFractionSummary(t, price, simultaneous),
                  const SizedBox(height: 20),
                  _buildCalendar(t),
                  const SizedBox(height: 20),
                  _buildOccupancySection(t),
                ],
              ),
            ),
          ),

          // ── COLUNA DIREITA: Métricas + Simulação ──
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
              child: Column(
                children: [
                  _buildMetricsGrid(t, price),
                  const SizedBox(height: 16),
                  _buildValuationCard(t),
                  const SizedBox(height: 16),
                  _buildBenchmarkCard(t),
                  const SizedBox(height: 16),
                  _buildCTA(t, price),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════
  Widget _buildHeader(AppLocalizations t) {
    return Row(
      children: [
        const Icon(Icons.pie_chart_outline, color: _gold, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.fraction_title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(t.fraction_subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // DEVELOPMENT SELECTOR
  // ══════════════════════════════════════════
  Widget _buildDevelopmentSelector(AppLocalizations t) {
    return _panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.fraction_select_development,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border, width: 0.6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDevelopment,
                isExpanded: true,
                dropdownColor: _card,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: _gold, size: 20),
                items: _fractionData.keys
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _selectedDevelopment = v;
                    _selectedWeeks = 2;
                    _generateWeeks();
                    _runSimulation();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // QUOTA CARDS (2/4/6 semanas)
  // ══════════════════════════════════════════
  Widget _buildQuotaCards(AppLocalizations t) {
    return Row(
      children: [2, 4, 6].map((weeks) {
        final selected = _selectedWeeks == weeks;
        final price = _fractionData[_selectedDevelopment]![weeks]!["price"];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedWeeks = weeks;
                _generateWeeks();
                _runSimulation();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                      : null,
                  color: selected ? null : _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? _gold.withValues(alpha: 0.5)
                        : _border,
                    width: selected ? 1.2 : 0.6,
                  ),
                ),
                child: Column(
                  children: [
                    Text('$weeks',
                        style: TextStyle(
                            color: selected ? _gold : Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    Text(t.fraction_weeks_label,
                        style: TextStyle(
                            color: selected ? _gold : Colors.white54,
                            fontSize: 11)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: selected
                            ? _gold.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${weeks * 7} ${t.fraction_days_year}',
                          style: TextStyle(
                              color: selected ? _gold : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    Text(_fmtCurrency((price as num).toDouble()),
                        style: TextStyle(
                            color: selected ? _gold : Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════
  // FRACTION SUMMARY
  // ══════════════════════════════════════════
  Widget _buildFractionSummary(AppLocalizations t, double price, int simultaneous) {
    return _panelCard(
      child: Row(
        children: [
          _summaryChip(Icons.attach_money, t.fraction_investment,
              _fmtCurrency(price)),
          _summaryChip(Icons.calendar_today, t.fraction_annual_use,
              '${_selectedWeeks * 7} ${t.fraction_days}'),
          _summaryChip(Icons.layers, t.fraction_simultaneous,
              '$simultaneous'),
          _summaryChip(Icons.date_range, t.fraction_schedule,
              '24 ${t.fraction_months}'),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _gold, size: 16),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // CALENDAR
  // ══════════════════════════════════════════
  Widget _buildCalendar(AppLocalizations t) {
    return _panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: _gold, size: 16),
              const SizedBox(width: 8),
              Text(t.fraction_calendar,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              // Legenda
              _calendarLegend(_gold, t.fraction_legend_reserved),
              const SizedBox(width: 12),
              _calendarLegend(Colors.red, t.fraction_legend_blocked),
              const SizedBox(width: 12),
              _calendarLegend(_blue, t.fraction_legend_premium),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 730)),
            focusedDay: _focusedDay,
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              weekendTextStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              outsideTextStyle: const TextStyle(color: Colors.white12, fontSize: 12),
              todayDecoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
              selectedDecoration: const BoxDecoration(
                color: _gold,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 14),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: Colors.white38, size: 20),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white30, fontSize: 11),
              weekendStyle: TextStyle(color: Colors.white24, fontSize: 11),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (ctx, day, focused) =>
                  _buildCalendarDay(day, false),
              todayBuilder: (ctx, day, focused) =>
                  _buildCalendarDay(day, true),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => _focusedDay = focusedDay);
              _toggleWeek(selectedDay);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, bool isToday) {
    final week = _weeks.cast<FractionWeek?>().firstWhere(
          (w) => _isSameWeek(w!.start, day),
          orElse: () => null,
        );

    Color bg = Colors.transparent;
    Color textColor = Colors.white70;

    if (week != null) {
      if (week.isReserved) {
        bg = _gold.withValues(alpha: 0.25);
        textColor = _gold;
      } else if (week.isBlocked) {
        bg = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.withValues(alpha: 0.6);
      } else if (_isPremiumWeek(day)) {
        bg = _blue.withValues(alpha: 0.12);
        textColor = _blue;
      }
    }

    if (isToday && bg == Colors.transparent) {
      bg = _blue.withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text('${day.day}',
          style: TextStyle(color: textColor, fontSize: 12)),
    );
  }

  Widget _calendarLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }

  // ══════════════════════════════════════════
  // OCCUPANCY SECTION
  // ══════════════════════════════════════════
  Widget _buildOccupancySection(AppLocalizations t) {
    final personalUtil = _maxWeeksAllowed == 0
        ? 0.0
        : _selectedWeeksList.length / _maxWeeksAllowed;
    final propertyOcc = _weeks.isEmpty
        ? 0.0
        : _weeks.where((w) => w.isReserved || w.isBlocked).length /
            _weeks.length;

    return _panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: _gold, size: 16),
              const SizedBox(width: 8),
              Text(t.fraction_occupancy,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _occupancyGauge(
                  t.fraction_your_usage,
                  personalUtil,
                  _gold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _occupancyGauge(
                  t.fraction_total_occupancy,
                  propertyOcc,
                  _green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _occupancyGauge(String label, double value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text('${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  // ══════════════════════════════════════════
  // METRICS GRID (coluna direita)
  // ══════════════════════════════════════════
  Widget _buildMetricsGrid(AppLocalizations t, double price) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricTile(
                Icons.show_chart,
                t.fraction_future_value,
                _fmtCurrency(_simulationResult.futureValue),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricTile(
                Icons.pie_chart_outline,
                'ROI',
                '${(_simulationResult.roi * 100).toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricTile(
                Icons.timeline,
                'IRR',
                '${(_simulationResult.irr * 100).toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricTile(
                Icons.account_balance_wallet,
                t.fraction_rental_income,
                _fmtCurrency(_simulationResult.totalRentalIncome),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricTile(IconData icon, String label, String value) {
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
          Icon(icon, color: _gold, size: 15),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    color: _gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // VALUATION CARD
  // ══════════════════════════════════════════
  Widget _buildValuationCard(AppLocalizations t) {
    return _panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, color: _gold, size: 16),
              const SizedBox(width: 8),
              Text(t.fraction_valuation_title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          // Holding years slider
          Row(
            children: [
              Text(t.fraction_holding_years,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const Spacer(),
              Text('$_holdingYears ${t.fraction_years}',
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _holdingYears.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              onChanged: (v) => setState(() {
                _holdingYears = v.round();
                _runSimulation();
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Appreciation slider
          Row(
            children: [
              Text(t.fraction_appreciation,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const Spacer(),
              Text('${(_annualAppreciation * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _annualAppreciation,
              min: 0.02,
              max: 0.30,
              divisions: 28,
              onChanged: (v) => setState(() {
                _annualAppreciation = v;
                _runSimulation();
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Yield slider
          Row(
            children: [
              Text(t.fraction_yield,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const Spacer(),
              Text('${(_annualYield * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _annualYield,
              min: 0.01,
              max: 0.15,
              divisions: 14,
              onChanged: (v) => setState(() {
                _annualYield = v;
                _runSimulation();
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // BENCHMARK CARD
  // ══════════════════════════════════════════
  Widget _buildBenchmarkCard(AppLocalizations t) {
    const double cdiRate = 0.10;
    final alpha = _simulationResult.irr - cdiRate;
    final sharpe = _estimatedVolatility > 0 ? alpha / _estimatedVolatility : 0.0;

    return _panelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, color: _gold, size: 16),
              const SizedBox(width: 8),
              Text(t.fraction_benchmark,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          // Alpha vs CDI
          _benchmarkRow(
            'Alpha vs CDI',
            '${(alpha * 100).toStringAsFixed(2)}%',
            alpha >= 0 ? _green : Colors.red,
          ),
          const SizedBox(height: 10),
          // Sharpe
          _benchmarkRow(
            'Sharpe',
            sharpe.toStringAsFixed(2),
            sharpe >= 1 ? _green : (sharpe >= 0.5 ? _gold : Colors.red),
          ),
          const SizedBox(height: 12),
          // Volatility slider
          Row(
            children: [
              Text(t.fraction_volatility,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const Spacer(),
              Text('${(_estimatedVolatility * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _blue,
              inactiveTrackColor: _border,
              thumbColor: _blue,
              overlayColor: _blue.withValues(alpha: 0.1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _estimatedVolatility,
              min: 0.05,
              max: 0.30,
              divisions: 25,
              onChanged: (v) => setState(() => _estimatedVolatility = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benchmarkRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // CTA
  // ══════════════════════════════════════════
  Widget _buildCTA(AppLocalizations t, double price) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.25),
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
            child: Column(
              children: [
                Text(t.fraction_cta,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  '$_selectedDevelopment • $_selectedWeeks ${t.fraction_weeks_label} • ${_fmtCurrency(price)}',
                  style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // PANEL CARD (reusável)
  // ══════════════════════════════════════════
  Widget _panelCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: child,
    );
  }
}

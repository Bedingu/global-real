import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmActivitiesPage extends StatefulWidget {
  const CrmActivitiesPage({super.key});

  @override
  State<CrmActivitiesPage> createState() => _CrmActivitiesPageState();
}

class _CrmActivitiesPageState extends State<CrmActivitiesPage> {
  String? _status = 'Todas atividades';
  String? _assignedTo;
  String? _linkedTo;
  String? _createdBy;
  String? _period;
  final Set<String> _activityTypes = {};
  bool _isCalendar = true;

  // Week navigation
  late DateTime _weekStart;

  final List<Map<String, dynamic>> _activities = [];

  static const _types = [
    {'icon': Icons.phone, 'label': 'Ligar'},
    {'icon': Icons.email_outlined, 'label': 'Email'},
    {'icon': Icons.groups_outlined, 'label': 'Reunião'},
    {'icon': Icons.check_circle_outline, 'label': 'Tarefa'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Mensagem'},
    {'icon': Icons.location_on_outlined, 'label': 'Visita'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
  void _goToday() {
    final now = DateTime.now();
    setState(() => _weekStart = now.subtract(Duration(days: now.weekday - 1)));
  }

  void _clear() => setState(() {
    _status = 'Todas atividades'; _assignedTo = null; _linkedTo = null;
    _createdBy = null; _period = null; _activityTypes.clear();
  });

  String _monthLabel(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return months[d.month - 1];
  }

  String _weekLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    return '${_weekStart.day} ${_monthLabel(_weekStart)} - ${end.day} ${_monthLabel(end)} ${end.year}';
  }

  static const _dayNames = ['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Atividades'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('ATIVIDADES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),

          // Action button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova atividade'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          ),
          const SizedBox(height: 24),

          // Filtros
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.filter_list, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                  const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const Spacer(),
                  TextButton.icon(onPressed: () {}, icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Salvar filtro', style: TextStyle(fontSize: 12))),
                ]),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (ctx, c) {
                  if (c.maxWidth > 700) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(child: _col('Status', _drop(_status, ['Todas atividades', 'Pendentes', 'Concluídas', 'Atrasadas'], (v) => setState(() => _status = v)))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Atribuída a', _drop(_assignedTo, [], (v) => setState(() => _assignedTo = v), hint: 'Escolha uma atribuição'))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Vinculada a', _drop(_linkedTo, [], (v) => setState(() => _linkedTo = v), hint: 'Escolha um vínculo'))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Criada por', _drop(_createdBy, [], (v) => setState(() => _createdBy = v), hint: 'Escolha uma opção'))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Período', _drop(_period, [], (v) => setState(() => _period = v), hint: 'Selecione uma data'))),
                    ]);
                  }
                  return Column(children: [
                    _col('Status', _drop(_status, ['Todas atividades', 'Pendentes', 'Concluídas', 'Atrasadas'], (v) => setState(() => _status = v))),
                    const SizedBox(height: 12),
                    _col('Atribuída a', _drop(_assignedTo, [], (v) => setState(() => _assignedTo = v), hint: 'Escolha uma atribuição')),
                    const SizedBox(height: 12),
                    _col('Vinculada a', _drop(_linkedTo, [], (v) => setState(() => _linkedTo = v), hint: 'Escolha um vínculo')),
                    const SizedBox(height: 12),
                    _col('Criada por', _drop(_createdBy, [], (v) => setState(() => _createdBy = v), hint: 'Escolha uma opção')),
                    const SizedBox(height: 12),
                    _col('Período', _drop(_period, [], (v) => setState(() => _period = v), hint: 'Selecione uma data')),
                  ]);
                }),
                const SizedBox(height: 16),
                // Tipo de atividade
                const Text('Tipo de atividade', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
                  final label = t['label'] as String;
                  final icon = t['icon'] as IconData;
                  final selected = _activityTypes.contains(label);
                  return FilterChip(
                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: 14, color: selected ? Colors.white : AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppTheme.textPrimary)),
                    ]),
                    selected: selected,
                    selectedColor: AppTheme.primaryBlue,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[300]!)),
                    onSelected: (v) => setState(() { v ? _activityTypes.add(label) : _activityTypes.remove(label); }),
                  );
                }).toList()),
                const SizedBox(height: 20),
                // Limpar / Filtrar
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(onPressed: _clear,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                    child: const Text('Limpar')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                    child: const Text('Filtrar')),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Atividades
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header
                Row(children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text('Atividades (${_activities.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const Spacer(),
                  _viewToggle(Icons.calendar_month, _isCalendar, () => setState(() => _isCalendar = true)),
                  const SizedBox(width: 4),
                  _viewToggle(Icons.view_list_outlined, !_isCalendar, () => setState(() => _isCalendar = false)),
                ]),
                const SizedBox(height: 16),

                // Week navigation
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  OutlinedButton(onPressed: _goToday,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    child: Text('Voltar para hoje', style: TextStyle(fontSize: 12, color: Colors.grey[400]))),
                  const Spacer(),
                  IconButton(onPressed: _prevWeek, icon: const Icon(Icons.chevron_left, size: 20)),
                  Text(_weekLabel(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: _nextWeek, icon: const Icon(Icons.chevron_right, size: 20)),
                  const Spacer(),
                  const SizedBox(width: 100),
                ]),
                const SizedBox(height: 16),

                // Calendar week view
                if (_isCalendar) _buildWeekView(),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildWeekView() {
    return Table(
      border: TableBorder.all(color: Colors.grey[200]!, width: 1),
      children: [
        // Header
        TableRow(children: List.generate(7, (i) {
          final day = _weekStart.add(Duration(days: i));
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            color: Colors.grey[50],
            child: Column(children: [
              Text(_dayNames[i], style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Text('${day.day}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          );
        })),
        // Empty row for activities
        TableRow(children: List.generate(7, (_) => Container(height: 120, padding: const EdgeInsets.all(4)))),
      ],
    );
  }

  Widget _viewToggle(IconData icon, bool active, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? AppTheme.primaryBlue : Colors.grey[300]!),
      ),
      child: Icon(icon, size: 18, color: active ? AppTheme.primaryBlue : Colors.grey[400]),
    ),
  );

  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged, {String hint = 'Selecione'}) => DropdownButtonFormField<String>(
    value: value, isExpanded: true, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
    onChanged: onChanged,
  );
}

import 'package:flutter/material.dart';
import '../../theme.dart';
import 'crm_new_opportunity_page.dart';
import 'crm_opportunity_settings_page.dart';

class CrmOpportunitiesPage extends StatefulWidget {
  const CrmOpportunitiesPage({super.key});

  @override
  State<CrmOpportunitiesPage> createState() => _CrmOpportunitiesPageState();
}

class _CrmOpportunitiesPageState extends State<CrmOpportunitiesPage> {
  final _searchCtrl = TextEditingController();
  String? _funnel = 'Venda';
  String? _status = 'Abertas';
  bool _showMoreFilters = false;
  bool _isKanban = true;

  // More filters
  String? _responsible;
  String? _agency;
  String? _stage;
  String? _update;
  String? _temperature;
  String? _activityStatus;
  String? _origin;
  String? _registerPeriod;
  String? _updatePeriod;
  String? _team;
  String? _tag;

  final List<Map<String, dynamic>> _opportunities = [];
  final List<String> _activeFilters = ['Contrato: Venda', 'Status: Abertas'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _clearFilters() => setState(() {
    _searchCtrl.clear(); _funnel = null; _status = null;
    _responsible = null; _agency = null; _stage = null; _update = null;
    _temperature = null; _activityStatus = null; _origin = null;
    _registerPeriod = null; _updatePeriod = null; _team = null; _tag = null;
    _showMoreFilters = false; _activeFilters.clear();
  });

  void _saveFilter() {
    final hasFilter = _searchCtrl.text.isNotEmpty || _funnel != null || _status != null;
    if (!hasFilter) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.white, behavior: SnackBarBehavior.floating, width: 400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(children: [
          const Icon(Icons.cancel, color: Colors.red, size: 32), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text('Oooops!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 16)),
            Text('Selecione pelo menos um campo para poder salvar como filtro', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ])),
        ]),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filtro salvo!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Oportunidades'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('OPORTUNIDADES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),

          // Action buttons
          Row(children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNewOpportunityPage())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova oportunidade'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmOpportunitySettingsPage())),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Configurações'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            ),
          ]),
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
                  TextButton.icon(onPressed: _saveFilter, icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Salvar filtro', style: TextStyle(fontSize: 12))),
                ]),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, c) {
                  if (c.maxWidth > 700) {
                    return Column(children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(flex: 2, child: _col('Busca', _searchInput())),
                        const SizedBox(width: 12),
                        Expanded(child: _col('Funil', _drop(_funnel, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _funnel = v)))),
                        const SizedBox(width: 12),
                        Expanded(child: _col('Status', _drop(_status, ['Todas', 'Ganhas', 'Perdidas', 'Abertas'], (v) => setState(() => _status = v), hint: 'Abertas'))),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => setState(() => _showMoreFilters = !_showMoreFilters),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_showMoreFilters ? 'Menos filtros' : 'Mais filtros'),
                            const SizedBox(width: 4),
                            Icon(_showMoreFilters ? Icons.expand_less : Icons.expand_more, size: 18),
                          ]),
                        ),
                      ]),
                      if (_showMoreFilters) ...[
                        const SizedBox(height: 12),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Expanded(child: _col('Responsável', _drop(_responsible, ['Todos'], (v) => setState(() => _responsible = v), hint: 'Todos'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Agência', _drop(_agency, [], (v) => setState(() => _agency = v), hint: 'Escolha uma agência'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Etapa', _drop(_stage, [], (v) => setState(() => _stage = v), hint: 'Escolha uma etapa'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Atualização', _drop(_update, ['Atualizadas', 'Estagnadas'], (v) => setState(() => _update = v), hint: 'Escolha uma opção'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Temperatura', _drop(_temperature, ['Não informado', 'Frio', 'Morno', 'Quente'], (v) => setState(() => _temperature = v), hint: 'Escolha uma temperatura'))),
                        ]),
                        const SizedBox(height: 12),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Expanded(child: _col('Status de atividade', _drop(_activityStatus, [], (v) => setState(() => _activityStatus = v), hint: 'Escolha um status'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Origem', _drop(_origin, [], (v) => setState(() => _origin = v), hint: 'Escolha uma origem'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Período de cadastro', _drop(_registerPeriod, [], (v) => setState(() => _registerPeriod = v), hint: 'Selecione um período'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Período de atualização', _drop(_updatePeriod, [], (v) => setState(() => _updatePeriod = v), hint: 'Selecione um período'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Equipes', _drop(_team, [], (v) => setState(() => _team = v), hint: 'Selecione uma ou mais equip...'))),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          SizedBox(width: 220, child: _col('Etiquetas', _drop(_tag, [], (v) => setState(() => _tag = v), hint: 'Selecione ou pesquise etiquet...'))),
                        ]),
                      ],
                    ]);
                  }
                  return Column(children: [
                    _col('Busca', _searchInput()), const SizedBox(height: 12),
                    _col('Funil', _drop(_funnel, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _funnel = v))), const SizedBox(height: 12),
                    _col('Status', _drop(_status, ['Todas', 'Ganhas', 'Perdidas', 'Abertas'], (v) => setState(() => _status = v), hint: 'Abertas')), const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => setState(() => _showMoreFilters = !_showMoreFilters),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_showMoreFilters ? 'Menos filtros' : 'Mais filtros'),
                        const SizedBox(width: 4),
                        Icon(_showMoreFilters ? Icons.expand_less : Icons.expand_more, size: 18),
                      ]),
                    ),
                    if (_showMoreFilters) ...[
                      const SizedBox(height: 12),
                      _col('Responsável', _drop(_responsible, ['Todos'], (v) => setState(() => _responsible = v), hint: 'Todos')),
                      const SizedBox(height: 12),
                      _col('Agência', _drop(_agency, [], (v) => setState(() => _agency = v), hint: 'Escolha uma agência')),
                      const SizedBox(height: 12),
                      _col('Etapa', _drop(_stage, [], (v) => setState(() => _stage = v), hint: 'Escolha uma etapa')),
                      const SizedBox(height: 12),
                      _col('Atualização', _drop(_update, ['Atualizadas', 'Estagnadas'], (v) => setState(() => _update = v), hint: 'Escolha uma opção')),
                      const SizedBox(height: 12),
                      _col('Temperatura', _drop(_temperature, ['Não informado', 'Frio', 'Morno', 'Quente'], (v) => setState(() => _temperature = v), hint: 'Escolha uma temperatura')),
                      const SizedBox(height: 12),
                      _col('Status de atividade', _drop(_activityStatus, [], (v) => setState(() => _activityStatus = v), hint: 'Escolha um status')),
                      const SizedBox(height: 12),
                      _col('Origem', _drop(_origin, [], (v) => setState(() => _origin = v), hint: 'Escolha uma origem')),
                      const SizedBox(height: 12),
                      _col('Período de cadastro', _drop(_registerPeriod, [], (v) => setState(() => _registerPeriod = v), hint: 'Selecione um período')),
                      const SizedBox(height: 12),
                      _col('Período de atualização', _drop(_updatePeriod, [], (v) => setState(() => _updatePeriod = v), hint: 'Selecione um período')),
                      const SizedBox(height: 12),
                      _col('Equipes', _drop(_team, [], (v) => setState(() => _team = v), hint: 'Selecione uma ou mais equip...')),
                      const SizedBox(height: 12),
                      _col('Etiquetas', _drop(_tag, [], (v) => setState(() => _tag = v), hint: 'Selecione ou pesquise etiquet...')),
                    ],
                  ]);
                }),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Oportunidades
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header com toggle kanban/lista
                Row(children: [
                  const Icon(Icons.autorenew, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text('Oportunidades (${_opportunities.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const Spacer(),
                  _viewToggle(Icons.view_column_outlined, _isKanban, () => setState(() => _isKanban = true)),
                  const SizedBox(width: 4),
                  _viewToggle(Icons.view_list_outlined, !_isKanban, () => setState(() => _isKanban = false)),
                ]),
                const SizedBox(height: 16),

                // Active filter chips
                if (_activeFilters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(children: [
                      ..._activeFilters.map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(f, style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => setState(() => _activeFilters.remove(f)),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: Colors.grey[300]!)),
                        ),
                      )),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                        child: const Text('Limpar filtros', style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                  ),

                // Empty state
                if (_opportunities.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(children: [
                        Icon(Icons.groups_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Nenhuma oportunidade encontrada.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNewOpportunityPage())),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nova oportunidade'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
        ]),
      ),
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

  // Helpers
  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _searchInput() => TextField(
    controller: _searchCtrl, style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Busque por nome, telefone, email, notas ou observações', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

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

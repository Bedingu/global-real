import 'package:flutter/material.dart';
import '../../theme.dart';
import 'crm_new_roulette_page.dart';
import 'crm_roulette_settings_page.dart';

class CrmLeadRoulettePage extends StatefulWidget {
  const CrmLeadRoulettePage({super.key});

  @override
  State<CrmLeadRoulettePage> createState() => _CrmLeadRoulettePageState();
}

class _CrmLeadRoulettePageState extends State<CrmLeadRoulettePage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String? _status;
  String? _team;
  String? _user;
  String? _leadOrigin;
  String? _propertyType;
  String? _propertyTag;
  bool _showMoreFilters = false;

  // Mock data
  final _roulettes = [
    {'priority': '1ª', 'name': 'Roleta geral de venda', 'team': 'Equipe Matriz', 'status': 'Ativo'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose(); _searchCtrl.dispose();
    super.dispose();
  }

  void _saveFilter() {
    final hasFilter = _searchCtrl.text.isNotEmpty || _status != null || _team != null;
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text('Roletas de Leads'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('ROLETAS DE LEADS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 16),

            // Action buttons
            Row(children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNewRoulettePage())),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova Roleta'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmRouletteSettingsPage())),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Configurações'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Roletagens'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              ),
            ]),
            const SizedBox(height: 24),

            // Filtros
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            Expanded(child: _col('Status', _drop(_status, ['Todas', 'Ativo', 'Inativo'], (v) => setState(() => _status = v)))),
                            const SizedBox(width: 12),
                            Expanded(child: _col('Equipes', _drop(_team, [], (v) => setState(() => _team = v), hint: 'Selecione uma ou mais equipe...'))),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => setState(() => _showMoreFilters = !_showMoreFilters),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                              child: Row(children: [
                                Text(_showMoreFilters ? 'Menos filtros' : 'Mais filtros'),
                                const SizedBox(width: 4),
                                Icon(_showMoreFilters ? Icons.expand_less : Icons.expand_more, size: 18),
                              ]),
                            ),
                          ]),
                          if (_showMoreFilters) ...[
                            const SizedBox(height: 12),
                            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Expanded(child: _col('Usuário', _drop(_user, [], (v) => setState(() => _user = v), hint: 'Selecione um usuário'))),
                              const SizedBox(width: 12),
                              Expanded(child: _col('Origem do lead', _drop(_leadOrigin, ['Site - gustavo-26615', 'site - jetlar.com'], (v) => setState(() => _leadOrigin = v), hint: 'Selecione uma origem'))),
                              const SizedBox(width: 12),
                              Expanded(child: _col('Tipo de imóvel', _drop(_propertyType, ['Apartamento', 'Casa', 'Cobertura', 'Duplex', 'Flat', 'Geminado', 'Loft', 'Prédio Residencial', 'Sobrado', 'Triplex', 'Casa de Condomínio', 'Kitnet', 'Studio', 'Terreno', 'Apartamento Garden', 'Box', 'Casa Comercial', 'Conjunto Comercial', 'Galpão', 'Hotel', 'Loja', 'Pavilhão', 'Ponto Comercial', 'Pousada', 'Prédio Comercial', 'Sala Comercial', 'Terreno Comercial', 'Área Rural', 'Campo', 'Chácara', 'Fazenda', 'Haras', 'Sítio', 'Salão comercial'], (v) => setState(() => _propertyType = v), hint: 'Selecione um ou mais tipos'))),
                              const SizedBox(width: 12),
                              Expanded(child: _col('Etiquetas do imóvel', _drop(_propertyTag, [], (v) => setState(() => _propertyTag = v), hint: 'Selecione ou pesquise etiquet...'))),
                            ]),
                          ],
                        ]);
                      }
                      return Column(children: [
                        _col('Busca', _searchInput()), const SizedBox(height: 12),
                        _col('Status', _drop(_status, ['Todas', 'Ativo', 'Inativo'], (v) => setState(() => _status = v))), const SizedBox(height: 12),
                        _col('Equipes', _drop(_team, [], (v) => setState(() => _team = v), hint: 'Selecione uma ou mais equipe...')),
                        const SizedBox(height: 12),
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
                          _col('Usuário', _drop(_user, [], (v) => setState(() => _user = v), hint: 'Selecione um usuário')),
                          const SizedBox(height: 12),
                          _col('Origem do lead', _drop(_leadOrigin, ['Site - gustavo-26615', 'site - jetlar.com'], (v) => setState(() => _leadOrigin = v), hint: 'Selecione uma origem')),
                          const SizedBox(height: 12),
                          _col('Tipo de imóvel', _drop(_propertyType, ['Apartamento', 'Casa', 'Cobertura', 'Duplex', 'Flat', 'Geminado', 'Loft', 'Prédio Residencial', 'Sobrado', 'Triplex', 'Casa de Condomínio', 'Kitnet', 'Studio', 'Terreno', 'Apartamento Garden', 'Box', 'Casa Comercial', 'Conjunto Comercial', 'Galpão', 'Hotel', 'Loja', 'Pavilhão', 'Ponto Comercial', 'Pousada', 'Prédio Comercial', 'Sala Comercial', 'Terreno Comercial', 'Área Rural', 'Campo', 'Chácara', 'Fazenda', 'Haras', 'Sítio', 'Salão comercial'], (v) => setState(() => _propertyType = v), hint: 'Selecione um ou mais tipos')),
                          const SizedBox(height: 12),
                          _col('Etiquetas do imóvel', _drop(_propertyTag, [], (v) => setState(() => _propertyTag = v), hint: 'Selecione ou pesquise etiquet...')),
                        ],
                      ]);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabs: Venda | Locação | Temporada
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabCtrl,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryBlue,
                    tabs: const [
                      Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.sell_outlined, size: 16), SizedBox(width: 6), Text('Venda')])),
                      Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.home_work_outlined, size: 16), SizedBox(width: 6), Text('Locação')])),
                      Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.beach_access_outlined, size: 16), SizedBox(width: 6), Text('Temporada')])),
                    ],
                  ),
                  // Roletas table
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.casino_outlined, size: 18, color: AppTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text('Roletas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ]),
                        const SizedBox(height: 16),
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                          child: const Row(children: [
                            Expanded(flex: 1, child: Text('Prioridade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            Expanded(flex: 2, child: Text('Nome', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            Expanded(flex: 2, child: Text('Equipes/Usuários', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            SizedBox(width: 40),
                          ]),
                        ),
                        // Rows
                        ..._roulettes.map((r) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey[200]!), right: BorderSide(color: Colors.grey[200]!), bottom: BorderSide(color: Colors.grey[200]!))),
                          child: Row(children: [
                            Expanded(flex: 1, child: Text(r['priority']!, style: const TextStyle(fontSize: 13))),
                            Expanded(flex: 2, child: Text(r['name']!, style: const TextStyle(fontSize: 13))),
                            Expanded(flex: 2, child: Text(r['team']!, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                            Expanded(flex: 1, child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                              child: Text(r['status']!, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                            )),
                            SizedBox(width: 40, child: Row(children: [
                              Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
                              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
                            ])),
                          ]),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _searchInput() => TextField(
    controller: _searchCtrl, style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Busque pelo nome da roleta', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      suffixIcon: const Icon(Icons.search, size: 18),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged, {String hint = 'Todas'}) => DropdownButtonFormField<String>(
    value: value, isExpanded: true,
    style: const TextStyle(fontSize: 13, color: Colors.black87),
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

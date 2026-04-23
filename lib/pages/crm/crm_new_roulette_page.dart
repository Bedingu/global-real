import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/brazil_locations.dart';

class CrmNewRoulettePage extends StatefulWidget {
  const CrmNewRoulettePage({super.key});

  @override
  State<CrmNewRoulettePage> createState() => _CrmNewRoulettePageState();
}

class _CrmNewRoulettePageState extends State<CrmNewRoulettePage> {
  int _currentSection = 0;
  bool _hasChanges = false;

  final _nameCtrl = TextEditingController();
  String? _purpose;
  String _status = 'Ativa';
  String _prioritizeOwner = '';
  String _redistribute = 'Não';
  final Set<String> _days = {'Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'};
  bool _selectAll = true;

  // Equipes section state
  final List<String?> _selectedTeams = [null];
  final List<String> _addedUsers = [];
  static const _availableTeams = ['Equipe Matriz', 'Equipe Filial SP', 'Equipe Filial RJ', 'Equipe Comercial'];

  // Dados do lead section state
  String? _leadOrigin;
  static const _availableOrigins = ['Site - gustavo-26615', 'site - jetlar.com'];

  // Dados do imóvel section state
  String? _propertyType;
  String? _propertyTag;
  final _minValueCtrl = TextEditingController();
  final _maxValueCtrl = TextEditingController();
  final Set<String> _conditions = {};
  final Set<String> _business = {};
  String? _locState;
  String? _locCity;
  String? _locNeighborhood;

  static const _propertyTypes = [
    'Apartamento', 'Casa', 'Cobertura', 'Duplex', 'Flat', 'Geminado', 'Loft',
    'Prédio Residencial', 'Sobrado', 'Triplex', 'Casa de Condomínio', 'Kitnet',
    'Studio', 'Terreno', 'Apartamento Garden', 'Box',
    'Casa Comercial', 'Conjunto Comercial', 'Galpão', 'Hotel', 'Loja', 'Pavilhão',
    'Ponto Comercial', 'Pousada', 'Prédio Comercial', 'Sala Comercial',
    'Terreno Comercial', 'Área Rural', 'Campo', 'Chácara', 'Fazenda', 'Haras',
    'Sítio', 'Salão comercial',
  ];
  static const _conditionOptions = ['Em construção', 'Na planta', 'Novo', 'Usado'];
  static const _businessOptions = ['Aceita permuta', 'Financiável', 'MCMV'];

  // Destino do lead section state
  String _autoDestinate = 'Não';
  String? _funnel;
  String? _stage;

  static const _sections = [
    _Sec(Icons.casino_outlined, 'Dados'),
    _Sec(Icons.people_outline, 'Equipes'),
    _Sec(Icons.hub_outlined, 'Dados do lead'),
    _Sec(Icons.apartment_outlined, 'Imóveis'),
    _Sec(Icons.tune_outlined, 'Regras'),
    _Sec(Icons.notifications_outlined, 'Notificações'),
    _Sec(Icons.track_changes_outlined, 'Destino'),
  ];

  @override
  void dispose() { _nameCtrl.dispose(); _minValueCtrl.dispose(); _maxValueCtrl.dispose(); super.dispose(); }

  void _mark() { if (!_hasChanges) setState(() => _hasChanges = true); }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning_amber_rounded, size: 56, color: Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          const Text('Deseja sair sem salvar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RichText(textAlign: TextAlign.center, text: const TextSpan(
            style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            children: [TextSpan(text: 'As alterações '), TextSpan(text: 'não serão salvas.', style: TextStyle(fontWeight: FontWeight.w700))],
          )),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
            child: const Text('Sair')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _onWillPop();
        if (ok && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Nova Roleta'), backgroundColor: AppTheme.primaryBlue,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () async {
            if (_hasChanges) { final ok = await _onWillPop(); if (ok && mounted) Navigator.pop(context); }
            else Navigator.pop(context);
          }),
        ),
        body: Row(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Breadcrumb
                Row(children: [
                  GestureDetector(onTap: () async { if (_hasChanges) { final ok = await _onWillPop(); if (ok && mounted) Navigator.pop(context); } else Navigator.pop(context); },
                    child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                  const Text('ROLETAS DE LEADS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                  const Text('NOVA ROLETA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 24),
                _buildCurrentSection(),
              ]),
            ),
          ),
          // Right sidebar
          Container(width: 56, color: Colors.white,
            child: Column(children: List.generate(_sections.length, (i) {
              final sel = _currentSection == i;
              return InkWell(onTap: () => setState(() => _currentSection = i),
                child: Container(width: 56, height: 56,
                  decoration: BoxDecoration(color: sel ? AppTheme.primaryBlue : Colors.transparent),
                  child: Icon(_sections[i].icon, color: sel ? Colors.white : Colors.grey[400], size: 22),
                ),
              );
            })),
          ),
        ]),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 0: return _buildDataSection();
      case 1: return _buildTeamsSection();
      case 2: return _buildLeadDataSection();
      case 3: return _buildPropertySection();
      case 4: return _buildDistributionSection();
      case 6: return _buildDestinationSection();
      default: return _card(_sections[_currentSection].icon, _sections[_currentSection].label,
        Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Seção "${_sections[_currentSection].label}" — em breve', style: TextStyle(color: Colors.grey[400])))));
    }
  }

  Widget _buildTeamsSection() {
    return _card(Icons.people_outline, 'Equipe(s) e usuário(s)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'É necessário vincular sua roleta a pelo menos uma equipe ou um usuário nessa etapa.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        // Team rows + User button
        ..._selectedTeams.asMap().entries.map((entry) {
          final idx = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: idx < _selectedTeams.length - 1 ? 12 : 0),
            child: LayoutBuilder(builder: (ctx, c) {
              final teamDropdown = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(text: const TextSpan(children: [
                    TextSpan(text: 'Equipe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    TextSpan(text: ' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
                  ])),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedTeams[idx],
                    isExpanded: true,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: _inputDeco('Selecione uma equipe'),
                    items: _availableTeams.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() { _selectedTeams[idx] = v; _mark(); }),
                  ),
                ],
              );
              final userButton = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usuário', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar usuário', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ],
              );
              if (c.maxWidth > 600) {
                return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: teamDropdown),
                  const SizedBox(width: 16),
                  userButton,
                  if (_selectedTeams.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                      onPressed: () => setState(() { _selectedTeams.removeAt(idx); _mark(); }),
                    ),
                  ],
                ]);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                teamDropdown, const SizedBox(height: 12), userButton,
                if (_selectedTeams.length > 1)
                  Align(alignment: Alignment.centerRight, child: IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                    onPressed: () => setState(() { _selectedTeams.removeAt(idx); _mark(); }),
                  )),
              ]);
            }),
          );
        }),
        const SizedBox(height: 16),
        // Add team button
        OutlinedButton.icon(
          onPressed: () => setState(() { _selectedTeams.add(null); _mark(); }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Adicionar equipe', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
        ),
        const SizedBox(height: 24),
        _navButtons(onBack: () => setState(() => _currentSection = 0), onNext: () => setState(() => _currentSection = 2)),
      ],
    ));
  }

  Widget _buildLeadDataSection() {
    return _card(Icons.hub_outlined, 'Dados do lead', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Origem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _leadOrigin,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
          decoration: _inputDeco('Escolha uma origem'),
          items: _availableOrigins.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() { _leadOrigin = v; _mark(); }),
        ),
        const SizedBox(height: 24),
        _navButtons(onBack: () => setState(() => _currentSection = 1), onNext: () => setState(() => _currentSection = 3)),
      ],
    ));
  }

  Widget _buildPropertySection() {
    final cities = _locState != null ? BrazilLocations.getCities(_locState!) : <String>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Card 1: Dados do imóvel
      _card(Icons.home_outlined, 'Dados do imóvel', Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 600) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _dropField2('Tipos', _propertyType, _propertyTypes, (v) => setState(() { _propertyType = v; _mark(); }), 'Selecione o tipo de imóvel')),
                const SizedBox(width: 16),
                Expanded(child: _dropField2('Etiquetas', _propertyTag, [], (v) => setState(() { _propertyTag = v; _mark(); }), 'Selecione ou pesquise etiquetas')),
              ]);
            }
            return Column(children: [
              _dropField2('Tipos', _propertyType, _propertyTypes, (v) => setState(() { _propertyType = v; _mark(); }), 'Selecione o tipo de imóvel'),
              const SizedBox(height: 12),
              _dropField2('Etiquetas', _propertyTag, [], (v) => setState(() { _propertyTag = v; _mark(); }), 'Selecione ou pesquise etiquetas'),
            ]);
          }),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _field('Valor mínimo do imóvel', _minValueCtrl, 'R\$ 80.000,00')),
                const SizedBox(width: 16),
                Expanded(child: _field('Valor máximo do imóvel', _maxValueCtrl, 'R\$ 12.000.000,00')),
                const SizedBox(width: 16),
                Expanded(child: _checkboxGroup('Condição', _conditionOptions, _conditions)),
                const SizedBox(width: 16),
                Expanded(child: _checkboxGroup('Negócio', _businessOptions, _business)),
              ]);
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: _field('Valor mínimo do imóvel', _minValueCtrl, 'R\$ 80.000,00')),
                const SizedBox(width: 16),
                Expanded(child: _field('Valor máximo do imóvel', _maxValueCtrl, 'R\$ 12.000.000,00')),
              ]),
              const SizedBox(height: 12),
              _checkboxGroup('Condição', _conditionOptions, _conditions),
              const SizedBox(height: 12),
              _checkboxGroup('Negócio', _businessOptions, _business),
            ]);
          }),
        ],
      )),
      const SizedBox(height: 16),
      // Card 2: Localização
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
        child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Localização', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryBlue)),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _dropField2('Estado', _locState, BrazilLocations.states, (v) => setState(() { _locState = v; _locCity = null; _mark(); }), 'Escolha um estado')),
                const SizedBox(width: 16),
                Expanded(child: _dropField2('Cidade', _locCity, cities, (v) => setState(() { _locCity = v; _mark(); }), 'Escolha uma cidade')),
                const SizedBox(width: 16),
                Expanded(child: _dropField2('Bairros e condomínios', _locNeighborhood, [], (v) => setState(() { _locNeighborhood = v; _mark(); }), 'Escolha um bairro ou condomínio')),
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(top: 28), child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[300]!))),
                )),
              ]);
            }
            return Column(children: [
              _dropField2('Estado', _locState, BrazilLocations.states, (v) => setState(() { _locState = v; _locCity = null; _mark(); }), 'Escolha um estado'),
              const SizedBox(height: 12),
              _dropField2('Cidade', _locCity, cities, (v) => setState(() { _locCity = v; _mark(); }), 'Escolha uma cidade'),
              const SizedBox(height: 12),
              _dropField2('Bairros e condomínios', _locNeighborhood, [], (v) => setState(() { _locNeighborhood = v; _mark(); }), 'Escolha um bairro ou condomínio'),
            ]);
          }),
          const SizedBox(height: 24),
          _navButtons(onBack: () => setState(() => _currentSection = 2), onNext: () => setState(() => _currentSection = 4)),
        ])),
      ),
    ]);
  }

  Widget _buildDestinationSection() {
    return _card(Icons.track_changes_outlined, 'Destino do lead em oportunidades', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth > 600) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _radioRow('Destinar lead automaticamente *', _autoDestinate, ['Sim', 'Não'], (v) => setState(() { _autoDestinate = v; _mark(); }))),
              const SizedBox(width: 16),
              Expanded(child: _dropField2('Funil *', _funnel, _autoDestinate == 'Sim' ? ['Locação'] : [], (v) => setState(() { _funnel = v; _mark(); }), 'Selecione um funil')),
              const SizedBox(width: 16),
              Expanded(child: _dropField2('Etapa *', _stage, [], (v) => setState(() { _stage = v; _mark(); }), 'Selecione uma etapa')),
            ]);
          }
          return Column(children: [
            _radioRow('Destinar lead automaticamente *', _autoDestinate, ['Sim', 'Não'], (v) => setState(() { _autoDestinate = v; _mark(); })),
            const SizedBox(height: 12),
            _dropField2('Funil *', _funnel, _autoDestinate == 'Sim' ? ['Locação'] : [], (v) => setState(() { _funnel = v; _mark(); }), 'Selecione um funil'),
            const SizedBox(height: 12),
            _dropField2('Etapa *', _stage, [], (v) => setState(() { _stage = v; _mark(); }), 'Selecione uma etapa'),
          ]);
        }),
        const SizedBox(height: 24),
        _navButtonsSave(onBack: () => setState(() => _currentSection = 5)),
      ],
    ));
  }

  Widget _buildDataSection() {
    return _card(Icons.casino_outlined, 'Dados da roleta', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (ctx, c) {
        if (c.maxWidth > 600) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: _field('Nome *', _nameCtrl, 'Digite um nome para a roleta')),
            const SizedBox(width: 12),
            Expanded(child: _dropField('Finalidade *', _purpose, ['Venda', 'Locação', 'Temporada'], (v) => setState(() { _purpose = v; _mark(); }))),
            const SizedBox(width: 12),
            Expanded(child: _radioRow('Status *', _status, ['Ativa', 'Inativa'], (v) => setState(() { _status = v; _mark(); }))),
          ]);
        }
        return Column(children: [
          _field('Nome *', _nameCtrl, 'Digite um nome para a roleta'), const SizedBox(height: 12),
          _dropField('Finalidade *', _purpose, ['Venda', 'Locação', 'Temporada'], (v) => setState(() { _purpose = v; _mark(); })), const SizedBox(height: 12),
          _radioRow('Status *', _status, ['Ativa', 'Inativa'], (v) => setState(() { _status = v; _mark(); })),
        ]);
      }),
      const SizedBox(height: 24),
      _navButtons(onNext: () => setState(() => _currentSection = 1)),
    ]));
  }

  Widget _buildDistributionSection() {
    return _card(Icons.tune_outlined, 'Distribuição', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (ctx, c) {
        if (c.maxWidth > 600) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _radioRow('Priorizar responsável do imóvel *', _prioritizeOwner, ['Sim', 'Não'], (v) => setState(() { _prioritizeOwner = v; _mark(); }))),
            const SizedBox(width: 12),
            Expanded(child: _radioRow('Redistribuir lead não atendido *', _redistribute, ['Sim', 'Não'], (v) => setState(() { _redistribute = v; _mark(); }))),
            const SizedBox(width: 12),
            if (_redistribute == 'Sim') Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Após', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: [
                SizedBox(width: 60, child: TextField(decoration: _inputDeco(''), keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13))),
                const SizedBox(width: 8),
                Expanded(child: DropdownButtonFormField<String>(decoration: _inputDeco('Minutos'), items: const [
                  DropdownMenuItem(value: 'Minutos', child: Text('Minutos')), DropdownMenuItem(value: 'Horas', child: Text('Horas')),
                ], onChanged: (_) {}, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary))),
              ]),
            ])),
          ]);
        }
        return Column(children: [
          _radioRow('Priorizar responsável do imóvel *', _prioritizeOwner, ['Sim', 'Não'], (v) => setState(() { _prioritizeOwner = v; _mark(); })),
          const SizedBox(height: 12),
          _radioRow('Redistribuir lead não atendido *', _redistribute, ['Sim', 'Não'], (v) => setState(() { _redistribute = v; _mark(); })),
        ]);
      }),
      const SizedBox(height: 20),
      // Dias
      const Text('Distribuir nos dias *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: [
        Checkbox(value: _selectAll, activeColor: AppTheme.primaryBlue, onChanged: (v) {
          setState(() { _selectAll = v!; if (v) _days.addAll(['Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sábado']); else _days.clear(); _mark(); });
        }),
        const Text('Selecionar todos', style: TextStyle(fontSize: 13)),
      ]),
      Wrap(spacing: 0, children: ['Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sábado'].map((d) => Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: _days.contains(d), activeColor: AppTheme.primaryBlue, onChanged: (v) {
          setState(() { v! ? _days.add(d) : _days.remove(d); _selectAll = _days.length == 7; _mark(); });
        }),
        Text(d, style: const TextStyle(fontSize: 13)),
      ])).toList()),
      const SizedBox(height: 16),
      Row(children: [
        const Text('Horário de funcionamento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        SizedBox(width: 100, child: TextField(
          decoration: _inputDeco('09:30'),
          style: const TextStyle(fontSize: 13),
          keyboardType: TextInputType.datetime,
        )),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('até', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
        SizedBox(width: 100, child: TextField(
          decoration: _inputDeco('18:00'),
          style: const TextStyle(fontSize: 13),
          keyboardType: TextInputType.datetime,
        )),
      ]),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Mais um horário', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
      ),
      const SizedBox(height: 24),
      _navButtons(onBack: () => setState(() => _currentSection = 3), onNext: () => setState(() => _currentSection = 5)),
    ]));
  }

  // ==================== HELPERS ====================

  Widget _checkboxGroup(String label, List<String> options, Set<String> selected) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      ...options.map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: selected.contains(o), activeColor: AppTheme.primaryBlue,
          onChanged: (v) => setState(() { v! ? selected.add(o) : selected.remove(o); _mark(); }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact,
        ),
        Text(o, style: const TextStyle(fontSize: 12)),
      ])),
    ],
  );

  Widget _dropField2(String label, String? value, List<String> items, ValueChanged<String?> onChanged, String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(value: value, isExpanded: true, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
        decoration: _inputDeco(hint),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged),
    ],
  );

  Widget _navButtonsSave({VoidCallback? onBack}) => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    if (onBack != null) ...[OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Voltar')), const SizedBox(width: 12)],
    ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Roleta salva com sucesso!'), backgroundColor: Colors.green)); },
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      child: const Text('Salvar')),
  ]);

  Widget _card(IconData icon, String title, Widget child) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
    child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 20, color: AppTheme.primaryBlue), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
      const Divider(height: 32), child,
    ])),
  );

  Widget _field(String label, TextEditingController ctrl, String hint) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    TextField(controller: ctrl, onChanged: (_) => _mark(), style: const TextStyle(fontSize: 13), decoration: _inputDeco(hint)),
  ]);

  Widget _dropField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    DropdownButtonFormField<String>(value: value, isExpanded: true, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
      decoration: _inputDeco('Escolha uma finalidade'),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged),
  ]);

  Widget _radioRow(String label, String value, List<String> options, ValueChanged<String> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    Row(children: options.map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(value: o, groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      Text(o, style: const TextStyle(fontSize: 12)), const SizedBox(width: 8),
    ])).toList()),
  ]);

  Widget _navButtons({VoidCallback? onBack, VoidCallback? onNext}) => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    if (onBack != null) ...[OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Voltar')), const SizedBox(width: 12)],
    ElevatedButton(onPressed: onNext, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Próximo')),
  ]);

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
  );
}

class _Sec { final IconData icon; final String label; const _Sec(this.icon, this.label); }

import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/brazil_locations.dart';

class CrmNewOpportunityPage extends StatefulWidget {
  const CrmNewOpportunityPage({super.key});

  @override
  State<CrmNewOpportunityPage> createState() => _CrmNewOpportunityPageState();
}

class _CrmNewOpportunityPageState extends State<CrmNewOpportunityPage> {
  int _step = 0;

  // Step 0: Novo cadastro
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _responsible = 'GUSTAVO';
  String? _funnel;
  String? _stage;
  String _isPublic = 'Não';
  String? _campaign;

  // Step 1: Perfil de interesse
  final _refCtrl = TextEditingController();
  String? _propertyType;
  String? _amenities;
  String? _propertyTag;
  final _minValueCtrl = TextEditingController();
  final _maxValueCtrl = TextEditingController();
  final Set<String> _bedrooms = {};
  final Set<String> _suites = {};
  final Set<String> _bathrooms = {};
  final Set<String> _parking = {};
  final Set<String> _position = {};
  final Set<String> _sunOrientation = {};
  String? _furnished = 'Indiferente';
  final _seaDistCtrl = TextEditingController();
  final _minTotalAreaCtrl = TextEditingController();
  final _minPrivateAreaCtrl = TextEditingController();
  final _minLandAreaCtrl = TextEditingController();
  String? _landAreaUnit = 'm²';

  // Localização
  String? _locState;
  String? _locCity;

  static const _bedroomOpts = ['1', '2', '3', '4+'];
  static const _suiteOpts = ['0', '1', '2', '3+'];
  static const _bathroomOpts = ['1', '2', '3', '4+'];
  static const _parkingOpts = ['0', '1', '2', '3+'];
  static const _positionOpts = ['Frente', 'Fundos', 'Lateral'];
  static const _sunOpts = ['Norte', 'Sul', 'Leste', 'Oeste'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    _refCtrl.dispose(); _minValueCtrl.dispose(); _maxValueCtrl.dispose();
    _seaDistCtrl.dispose(); _minTotalAreaCtrl.dispose();
    _minPrivateAreaCtrl.dispose(); _minLandAreaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Nova Oportunidade'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('OPORTUNIDADES', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('NOVO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),
          if (_step == 0) _buildNewRegistration(),
          if (_step == 1) _buildInterestProfile(),
        ]),
      ),
    );
  }

  // ==================== STEP 0: Novo cadastro ====================
  Widget _buildNewRegistration() {
    return _card(Icons.person_add_outlined, 'Novo cadastro', Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Pessoa section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(text: const TextSpan(children: [
              TextSpan(text: 'Pessoa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 4),
            Text('Preencha o nome completo e pelo menos uma opção de contato', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (ctx, c) {
              if (c.maxWidth > 700) {
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _field('Nome completo *', _nameCtrl, 'Informe o nome')),
                  const SizedBox(width: 12),
                  Expanded(child: _phoneField()),
                  const SizedBox(width: 12),
                  Expanded(child: _field('E-mail', _emailCtrl, 'exemplo@exemplo.com')),
                ]);
              }
              return Column(children: [
                _field('Nome completo *', _nameCtrl, 'Informe o nome'), const SizedBox(height: 12),
                _phoneField(), const SizedBox(height: 12),
                _field('E-mail', _emailCtrl, 'exemplo@exemplo.com'),
              ]);
            }),
          ]),
        ),
        const SizedBox(height: 20),
        // Responsável, Funil, Etapa
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth > 700) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _dropField('Responsável *', _responsible, ['GUSTAVO'], (v) => setState(() => _responsible = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropField('Funil *', _funnel, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _funnel = v), hint: 'Selecione um funil')),
              const SizedBox(width: 12),
              Expanded(child: _dropField('Etapa *', _stage, [], (v) => setState(() => _stage = v), hint: 'Selecione uma etapa')),
            ]);
          }
          return Column(children: [
            _dropField('Responsável *', _responsible, ['GUSTAVO'], (v) => setState(() => _responsible = v)), const SizedBox(height: 12),
            _dropField('Funil *', _funnel, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _funnel = v), hint: 'Selecione um funil'), const SizedBox(height: 12),
            _dropField('Etapa *', _stage, [], (v) => setState(() => _stage = v), hint: 'Selecione uma etapa'),
          ]);
        }),
        const SizedBox(height: 16),
        // Público + Campanha
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth > 700) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _radioRow('Público ⓘ *', _isPublic, ['Sim', 'Não'], (v) => setState(() => _isPublic = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropField('Campanha ⓘ', _campaign, [], (v) => setState(() => _campaign = v), hint: 'Selecione uma campanha')),
              const Spacer(),
            ]);
          }
          return Column(children: [
            _radioRow('Público ⓘ *', _isPublic, ['Sim', 'Não'], (v) => setState(() => _isPublic = v)), const SizedBox(height: 12),
            _dropField('Campanha ⓘ', _campaign, [], (v) => setState(() => _campaign = v), hint: 'Selecione uma campanha'),
          ]);
        }),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
          child: const Text('Próximo'),
        )),
      ],
    ));
  }

  // ==================== STEP 1: Perfil de interesse ====================
  Widget _buildInterestProfile() {
    final cities = _locState != null ? BrazilLocations.getCities(_locState!) : <String>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _card(Icons.home_outlined, 'Perfil de interesse', Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Tab Perfil 1
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
            child: const Text('Perfil 1', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),

          // Imóvel de referência + Tipos
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _field('Imóvel(is) de referência', _refCtrl, 'Pesquise por: Código, endereço ou condomínio')),
                const SizedBox(width: 12),
                Expanded(child: _dropField('Tipos', _propertyType, ['Apartamento', 'Casa', 'Cobertura', 'Duplex', 'Flat', 'Terreno', 'Sala Comercial', 'Loja', 'Galpão'], (v) => setState(() => _propertyType = v), hint: 'Selecione os tipos de imóveis')),
              ]);
            }
            return Column(children: [
              _field('Imóvel(is) de referência', _refCtrl, 'Pesquise por: Código, endereço ou condomínio'), const SizedBox(height: 12),
              _dropField('Tipos', _propertyType, ['Apartamento', 'Casa', 'Cobertura', 'Duplex', 'Flat', 'Terreno', 'Sala Comercial', 'Loja', 'Galpão'], (v) => setState(() => _propertyType = v), hint: 'Selecione os tipos de imóveis'),
            ]);
          }),
          const SizedBox(height: 16),

          // Comodidades + Etiquetas
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _dropField('Comodidades e infraestruturas', _amenities, [], (v) => setState(() => _amenities = v), hint: 'Escolhe ou busque por comodidades ou infraestrutura')),
                const SizedBox(width: 12),
                Expanded(child: _dropField('Etiquetas do imóvel', _propertyTag, [], (v) => setState(() => _propertyTag = v), hint: 'Selecione ou pesquise etiquetas')),
              ]);
            }
            return Column(children: [
              _dropField('Comodidades e infraestruturas', _amenities, [], (v) => setState(() => _amenities = v), hint: 'Escolhe ou busque por comodidades ou infraestrutura'), const SizedBox(height: 12),
              _dropField('Etiquetas do imóvel', _propertyTag, [], (v) => setState(() => _propertyTag = v), hint: 'Selecione ou pesquise etiquetas'),
            ]);
          }),
          const SizedBox(height: 16),

          // Valor
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Valor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (ctx, c) {
                if (c.maxWidth > 500) {
                  return Row(children: [
                    Expanded(child: _field('Valor mínimo do imóvel', _minValueCtrl, 'R\$ 100.000')),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Valor máximo do imóvel', _maxValueCtrl, 'R\$ 110.000')),
                  ]);
                }
                return Column(children: [
                  _field('Valor mínimo do imóvel', _minValueCtrl, 'R\$ 100.000'), const SizedBox(height: 12),
                  _field('Valor máximo do imóvel', _maxValueCtrl, 'R\$ 110.000'),
                ]);
              }),
            ]),
          ),
          const SizedBox(height: 16),

          // Dormitórios, Suítes, Banheiros, Vagas
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _checkboxGroup('Dormitórios', _bedroomOpts, _bedrooms)),
                Expanded(child: _checkboxGroup('Suítes', _suiteOpts, _suites)),
                Expanded(child: _checkboxGroup('Banheiros', _bathroomOpts, _bathrooms)),
                Expanded(child: _checkboxGroup('Vagas', _parkingOpts, _parking)),
              ]);
            }
            return Column(children: [
              Row(children: [
                Expanded(child: _checkboxGroup('Dormitórios', _bedroomOpts, _bedrooms)),
                Expanded(child: _checkboxGroup('Suítes', _suiteOpts, _suites)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _checkboxGroup('Banheiros', _bathroomOpts, _bathrooms)),
                Expanded(child: _checkboxGroup('Vagas', _parkingOpts, _parking)),
              ]),
            ]);
          }),
          const SizedBox(height: 16),

          // Posição, Orientação solar, Mobiliado, Distância mar
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _checkboxGroup('Posição', _positionOpts, _position)),
                Expanded(child: _checkboxGroup('Orientação solar', _sunOpts, _sunOrientation)),
                Expanded(child: _dropField('Mobiliado', _furnished, ['Indiferente', 'Sim', 'Não'], (v) => setState(() => _furnished = v))),
                Expanded(child: _fieldWithSuffix('Distância para o mar', _seaDistCtrl, '500', 'm')),
              ]);
            }
            return Column(children: [
              Row(children: [
                Expanded(child: _checkboxGroup('Posição', _positionOpts, _position)),
                Expanded(child: _checkboxGroup('Orientação solar', _sunOpts, _sunOrientation)),
              ]),
              const SizedBox(height: 12),
              _dropField('Mobiliado', _furnished, ['Indiferente', 'Sim', 'Não'], (v) => setState(() => _furnished = v)),
              const SizedBox(height: 12),
              _fieldWithSuffix('Distância para o mar', _seaDistCtrl, '500', 'm'),
            ]);
          }),
          const SizedBox(height: 16),

          // Áreas mínimas
          LayoutBuilder(builder: (ctx, c) {
            if (c.maxWidth > 700) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _fieldWithSuffix('Mínimo área total', _minTotalAreaCtrl, '110', 'm²')),
                const SizedBox(width: 12),
                Expanded(child: _fieldWithSuffix('Mínimo área privativa', _minPrivateAreaCtrl, '110', 'm²')),
                const SizedBox(width: 12),
                Expanded(child: Row(children: [
                  Expanded(child: _field('Mínimo área terreno', _minLandAreaCtrl, '110')),
                  const SizedBox(width: 8),
                  SizedBox(width: 70, child: DropdownButtonFormField<String>(
                    value: _landAreaUnit, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: _inputDeco(''),
                    items: ['m²', 'ha'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _landAreaUnit = v),
                  )),
                ])),
              ]);
            }
            return Column(children: [
              _fieldWithSuffix('Mínimo área total', _minTotalAreaCtrl, '110', 'm²'), const SizedBox(height: 12),
              _fieldWithSuffix('Mínimo área privativa', _minPrivateAreaCtrl, '110', 'm²'), const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field('Mínimo área terreno', _minLandAreaCtrl, '110')),
                const SizedBox(width: 8),
                SizedBox(width: 70, child: DropdownButtonFormField<String>(
                  value: _landAreaUnit, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  decoration: _inputDeco(''),
                  items: ['m²', 'ha'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _landAreaUnit = v),
                )),
              ]),
            ]);
          }),
          const SizedBox(height: 20),

          // Localização
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Localização', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
              ])),
              const SizedBox(height: 16),
              Center(child: Column(children: [
                Icon(Icons.location_on, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Você não tem endereços nesta oportunidade.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: const Text('Adicionar localização'),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              child: const Text('Voltar')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oportunidade salva!'), backgroundColor: Colors.green));
              Navigator.pop(context);
            },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              child: const Text('Salvar')),
          ]),
        ],
      )),
    ]);
  }

  // ==================== HELPERS ====================

  Widget _card(IconData icon, String title, Widget child) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
    child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 20, color: AppTheme.primaryBlue), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
      const Divider(height: 32), child,
    ])),
  );

  Widget _field(String label, TextEditingController ctrl, String hint) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    TextField(controller: ctrl, style: const TextStyle(fontSize: 13), decoration: _inputDeco(hint)),
  ]);

  Widget _fieldWithSuffix(String label, TextEditingController ctrl, String hint, String suffix) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      TextField(controller: ctrl, style: const TextStyle(fontSize: 13), keyboardType: TextInputType.number,
        decoration: _inputDeco(hint).copyWith(suffixText: suffix, suffixStyle: TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
    ],
  );

  Widget _phoneField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Telefone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    TextField(controller: _phoneCtrl, style: const TextStyle(fontSize: 13), keyboardType: TextInputType.phone,
      decoration: _inputDeco('(11) 96123-4567').copyWith(
        prefixIcon: Padding(padding: const EdgeInsets.only(left: 8, right: 4),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🇧🇷', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text('+55', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[400]),
          ]),
        ),
      )),
  ]);

  Widget _dropField(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {String hint = 'Selecione'}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      DropdownButtonFormField<String>(value: value, isExpanded: true, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
        decoration: _inputDeco(hint),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged),
    ],
  );

  Widget _radioRow(String label, String value, List<String> options, ValueChanged<String> onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      Row(children: options.map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
        Radio<String>(value: o, groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Text(o, style: const TextStyle(fontSize: 12)), const SizedBox(width: 8),
      ])).toList()),
    ],
  );

  Widget _checkboxGroup(String label, List<String> options, Set<String> selected) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 4),
      ...options.map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: selected.contains(o), activeColor: AppTheme.primaryBlue,
          onChanged: (v) => setState(() { v! ? selected.add(o) : selected.remove(o); }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
        Text(o, style: const TextStyle(fontSize: 12)),
      ])),
    ],
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
  );
}

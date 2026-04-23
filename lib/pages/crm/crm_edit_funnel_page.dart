import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmEditFunnelPage extends StatefulWidget {
  final String funnelName;
  const CrmEditFunnelPage({super.key, required this.funnelName});

  @override
  State<CrmEditFunnelPage> createState() => _CrmEditFunnelPageState();
}

class _CrmEditFunnelPageState extends State<CrmEditFunnelPage> {
  late TextEditingController _nameCtrl;
  String? _purpose;
  String? _team;
  String _responsible = 'Sim';
  String _teamVisibility = 'Nenhuma';
  int _step = 0;

  late List<_StageData> _stages;

  static const _stageColors = [
    Color(0xFF1E3A5F), Color(0xFF2563EB), Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFF84CC16),
    Color(0xFFF59E0B), Color(0xFFF97316), Color(0xFFEF4444),
    Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFFD946EF),
    Color(0xFF9CA3AF), Color(0xFF6B7280), Color(0xFF374151),
  ];

  static const _defaultStages = {
    'Funil de Venda': ['Captação', 'Qualificação', 'Visita', 'Negociação', 'Fechamento'],
    'Funil de Locação': ['Captação', 'Qualificação', 'Visita', 'Negociação', 'Fechamento'],
    'Funil de Temporada': ['Captação', 'Qualificação', 'Reserva', 'Confirmado'],
  };

  static const _purposeMap = {
    'Funil de Venda': 'Comprar',
    'Funil de Locação': 'Alugar',
    'Funil de Temporada': 'Temporada',
  };

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.funnelName);
    _purpose = _purposeMap[widget.funnelName] ?? 'Comprar';
    final stages = _defaultStages[widget.funnelName] ?? ['Captação', 'Qualificação', 'Visita', 'Negociação', 'Fechamento'];
    _stages = stages.asMap().entries.map((e) => _StageData(name: e.value, color: _stageColors[e.key % _stageColors.length])).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final s in _stages) { s.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Funis'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            _breadcrumb('INÍCIO', () { Navigator.pop(context); Navigator.pop(context); Navigator.pop(context); }),
            _chevron(),
            _breadcrumb('OPORTUNIDADES', () { Navigator.pop(context); Navigator.pop(context); }),
            _chevron(),
            _breadcrumb('CONFIGURAÇÕES', () => Navigator.pop(context)),
            _chevron(),
            const Text('FUNIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),

          if (_step == 0) _buildDataStep(),
          if (_step == 1) _buildStagesStep(),
        ]),
      ),
    );
  }

  // ==================== Step 0: Dados do funil ====================
  Widget _buildDataStep() {
    return _card(Icons.edit_outlined, 'Dados do funil', Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth > 700) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _fieldCtrl('Nome *', _nameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _dropField('Finalidade *', _purpose, ['Comprar', 'Alugar', 'Temporada'], (v) => setState(() => _purpose = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropField('Equipes *', _team, [], (v) => setState(() => _team = v), hint: 'Selecione uma ou mais equipes')),
            ]);
          }
          return Column(children: [
            _fieldCtrl('Nome *', _nameCtrl), const SizedBox(height: 12),
            _dropField('Finalidade *', _purpose, ['Comprar', 'Alugar', 'Temporada'], (v) => setState(() => _purpose = v)), const SizedBox(height: 12),
            _dropField('Equipes *', _team, [], (v) => setState(() => _team = v), hint: 'Selecione uma ou mais equipes'),
          ]);
        }),
        const SizedBox(height: 20),

        // Visibilidade
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Visibilidade de oportunidades estagnadas e perdidas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (ctx, c) {
              if (c.maxWidth > 500) {
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _radioRow('Responsável *', _responsible, ['Sim', 'Não'], (v) => setState(() => _responsible = v))),
                  const SizedBox(width: 24),
                  Expanded(child: _radioRow('Equipe *', _teamVisibility, ['Apenas sua equipe', 'Todas', 'Nenhuma'], (v) => setState(() => _teamVisibility = v))),
                ]);
              }
              return Column(children: [
                _radioRow('Responsável *', _responsible, ['Sim', 'Não'], (v) => setState(() => _responsible = v)),
                const SizedBox(height: 12),
                _radioRow('Equipe *', _teamVisibility, ['Apenas sua equipe', 'Todas', 'Nenhuma'], (v) => setState(() => _teamVisibility = v)),
              ]);
            }),
          ]),
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
          child: const Text('Próximo'),
        )),
      ],
    ));
  }

  // ==================== Step 1: Etapas ====================
  Widget _buildStagesStep() {
    return _card(Icons.view_column_outlined, 'Etapas (${_stages.length})', Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ..._stages.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header: nome resumido + delete
                  Row(children: [
                    Expanded(child: Text(s.nameCtrl.text.isEmpty ? 'Etapa ${idx + 1}' : s.nameCtrl.text,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    IconButton(icon: Icon(Icons.delete_outline, size: 16, color: Colors.grey[400]), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      onPressed: _stages.length > 1 ? () => setState(() { _stages[idx].dispose(); _stages.removeAt(idx); }) : null),
                  ]),
                  const Divider(height: 16),
                  // Nome
                  const Text('Nome *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(controller: s.nameCtrl, style: const TextStyle(fontSize: 12),
                    decoration: _inputDeco('').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                  const SizedBox(height: 12),
                  // Cor
                  const Text('Cor *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: _stageColors.map((c) => GestureDetector(
                    onTap: () => setState(() => s.color = c),
                    child: Container(width: 24, height: 24,
                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4),
                        border: s.color == c ? Border.all(color: Colors.black, width: 2) : null)),
                  )).toList()),
                  const SizedBox(height: 12),
                  // Estagnação toggle
                  Row(children: [
                    SizedBox(width: 36, height: 20, child: Switch(value: s.stagnation, activeColor: AppTheme.primaryBlue,
                      onChanged: (v) => setState(() => s.stagnation = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                    const SizedBox(width: 6),
                    const Text('Estagnação', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 2),
                    Icon(Icons.info_outline, size: 12, color: Colors.grey[400]),
                  ]),
                  const SizedBox(height: 10),
                  // Estagnar após
                  const Text('Estagnar após', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    SizedBox(width: 50, child: TextField(controller: s.stagnationDaysCtrl, style: const TextStyle(fontSize: 11),
                      keyboardType: TextInputType.number,
                      decoration: _inputDeco('30').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)))),
                    const SizedBox(width: 6),
                    Expanded(child: DropdownButtonFormField<String>(value: s.stagnationUnit, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                      decoration: _inputDeco('').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                      items: ['Dia(s)', 'Hora(s)'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 11)))).toList(),
                      onChanged: (v) => setState(() => s.stagnationUnit = v ?? 'Dia(s)'))),
                  ]),
                ]),
              );
            }),
            // Add button
            GestureDetector(
              onTap: () => setState(() => _stages.add(_StageData())),
              child: Container(width: 48, height: 48, margin: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: Icon(Icons.add, color: Colors.grey[400])),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: () => setState(() => _step = 0),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            child: const Text('Voltar')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funil salvo!'), backgroundColor: Colors.green));
            Navigator.pop(context);
          },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            child: const Text('Salvar')),
        ]),
      ],
    ));
  }

  // ==================== HELPERS ====================
  Widget _card(IconData icon, String title, Widget child) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
    child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 20, color: AppTheme.primaryBlue), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
      const Divider(height: 32), child,
    ])),
  );

  Widget _fieldCtrl(String label, TextEditingController ctrl) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    TextField(controller: ctrl, style: const TextStyle(fontSize: 13), decoration: _inputDeco('')),
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
      Wrap(children: options.map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
        Radio<String>(value: o, groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Text(o, style: const TextStyle(fontSize: 12)), const SizedBox(width: 8),
      ])).toList()),
    ],
  );

  Widget _breadcrumb(String text, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Text(text, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)));

  Widget _chevron() => Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]);

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
  );
}

class _StageData {
  final TextEditingController nameCtrl;
  final TextEditingController stagnationDaysCtrl;
  Color color;
  bool stagnation;
  String stagnationUnit;

  _StageData({String name = '', Color? color})
      : nameCtrl = TextEditingController(text: name),
        stagnationDaysCtrl = TextEditingController(text: '30'),
        color = color ?? const Color(0xFF2563EB),
        stagnation = true,
        stagnationUnit = 'Dia(s)';

  void dispose() { nameCtrl.dispose(); stagnationDaysCtrl.dispose(); }
}

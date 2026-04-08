import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmPeoplePage extends StatefulWidget {
  const CrmPeoplePage({super.key});

  @override
  State<CrmPeoplePage> createState() => _CrmPeoplePageState();
}

class _CrmPeoplePageState extends State<CrmPeoplePage> {
  final _searchCtrl = TextEditingController();
  String? _bond;
  String? _civilStatus;
  String? _tag;
  String? _type;
  String _sortOrder = 'Ordem alfabética';
  bool _selectAll = false;

  final _people = [
    _Person(name: 'Global Real Estate', phone: '-', email: '-', birthDate: '-', gender: '-', type: 'PJ', properties: '-'),
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _saveFilter() {
    final hasFilter = _searchCtrl.text.isNotEmpty || _bond != null || _civilStatus != null || _tag != null || _type != null;
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
      appBar: AppBar(title: const Text('Pessoas'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('PESSOAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),

          // Action button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova pessoa'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          ),
          const SizedBox(height: 24),

          // Filtros
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
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
                // Busca
                _col('Busca', TextField(
                  controller: _searchCtrl, style: const TextStyle(fontSize: 13),
                  decoration: _inputDeco('Busque pelo nome, telefone ou email'),
                )),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (ctx, c) {
                  if (c.maxWidth > 700) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(child: _col('Vínculo', _drop(_bond, ['Proprietário', 'Agenciador'], (v) => setState(() => _bond = v), 'Selecione o vínculo'))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Estado civil', _drop(_civilStatus, ['Solteiro(a)', 'Casado(a)', 'Separado(a)', 'União Estável', 'Divorciado(a)', 'Viúvo(a)'], (v) => setState(() => _civilStatus = v), 'Selecione o estado civil'))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Etiquetas', _drop(_tag, [], (v) => setState(() => _tag = v), 'Selecione ou pesquise etiquetas'))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Tipo', _drop(_type, ['Não informado', 'Física', 'Jurídica'], (v) => setState(() => _type = v), 'Selecione o tipo de pessoa'))),
                    ]);
                  }
                  return Column(children: [
                    _col('Vínculo', _drop(_bond, ['Proprietário', 'Agenciador'], (v) => setState(() => _bond = v), 'Selecione o vínculo')),
                    const SizedBox(height: 12),
                    _col('Estado civil', _drop(_civilStatus, ['Solteiro(a)', 'Casado(a)', 'Separado(a)', 'União Estável', 'Divorciado(a)', 'Viúvo(a)'], (v) => setState(() => _civilStatus = v), 'Selecione o estado civil')),
                    const SizedBox(height: 12),
                    _col('Etiquetas', _drop(_tag, [], (v) => setState(() => _tag = v), 'Selecione ou pesquise etiquetas')),
                    const SizedBox(height: 12),
                    _col('Tipo', _drop(_type, ['Não informado', 'Física', 'Jurídica'], (v) => setState(() => _type = v), 'Selecione o tipo de pessoa')),
                  ]);
                }),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Pessoas table
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.groups_outlined, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text('Pessoas (${_people.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
                const SizedBox(height: 16),
                // Toolbar
                Row(children: [
                  Checkbox(value: _selectAll, onChanged: (v) => setState(() => _selectAll = v!), activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  const Text('Selecionar', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 12),
                  SizedBox(width: 120, child: DropdownButtonFormField<String>(
                    decoration: _inputDeco('Selecionar'), style: const TextStyle(fontSize: 12, color: Colors.black87),
                    items: const [DropdownMenuItem(value: 'all', child: Text('Todos')), DropdownMenuItem(value: 'none', child: Text('Nenhum'))],
                    onChanged: (_) {},
                  )),
                  const Spacer(),
                  SizedBox(width: 200, child: DropdownButtonFormField<String>(
                    value: _sortOrder, style: const TextStyle(fontSize: 12, color: Colors.black87),
                    decoration: _inputDeco(''),
                    items: ['Ordem alfabética', 'Mais recentes', 'Mais antigos'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _sortOrder = v!),
                  )),
                ]),
                const SizedBox(height: 12),
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                  child: Row(children: const [
                    SizedBox(width: 32),
                    Expanded(flex: 2, child: Text('Nome', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Telefones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('E-mail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Data Nasc.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Gênero', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Tipo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Imóveis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    SizedBox(width: 24),
                  ]),
                ),
                // Rows
                ..._people.map((p) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey[200]!), right: BorderSide(color: Colors.grey[200]!), bottom: BorderSide(color: Colors.grey[200]!))),
                  child: Row(children: [
                    SizedBox(width: 32, child: Checkbox(value: false, onChanged: (_) {}, activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                    Expanded(flex: 2, child: Text(p.name, style: const TextStyle(fontSize: 13))),
                    Expanded(child: Text(p.phone, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                    Expanded(child: Text(p.email, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                    Expanded(child: Text(p.birthDate, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                    Expanded(child: Text(p.gender, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                    Expanded(child: Text(p.type, style: const TextStyle(fontSize: 13))),
                    Expanded(child: Text(p.properties, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                    SizedBox(width: 24, child: Icon(Icons.chevron_right, size: 18, color: Colors.grey[400])),
                  ]),
                )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // Helpers
  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged, String hint) => DropdownButtonFormField<String>(
    value: value, isExpanded: true, style: const TextStyle(fontSize: 13, color: Colors.black87),
    decoration: _inputDeco(hint),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
    onChanged: onChanged,
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
  );
}

class _Person {
  final String name, phone, email, birthDate, gender, type, properties;
  const _Person({required this.name, required this.phone, required this.email, required this.birthDate, required this.gender, required this.type, required this.properties});
}

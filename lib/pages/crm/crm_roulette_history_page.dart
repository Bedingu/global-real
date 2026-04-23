import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmRouletteHistoryPage extends StatefulWidget {
  const CrmRouletteHistoryPage({super.key});

  @override
  State<CrmRouletteHistoryPage> createState() => _CrmRouletteHistoryPageState();
}

class _CrmRouletteHistoryPageState extends State<CrmRouletteHistoryPage> {
  String? _purpose;
  String? _withProperty;
  String? _user;
  final _dateCtrl = TextEditingController();

  final List<Map<String, dynamic>> _results = [];

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _purpose = null; _withProperty = null; _user = null; _dateCtrl.clear();
  });

  Future<void> _pickDate() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (range != null) {
      _dateCtrl.text = '${_fmt(range.start)} - ${_fmt(range.end)}';
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static const _columns = ['Usuário', 'Status', 'Seleção', 'Lead', 'Pessoa', 'Roleta', 'Contrato', 'Imóvel', 'Data', 'Eventos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Roletagens'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () { Navigator.pop(context); Navigator.pop(context); },
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('ROLETAS DE LEADS', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('ROLETAGENS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),

          // Filtros
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.filter_list, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                  const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 700;
                  if (wide) {
                    return Column(children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(child: _col('Finalidade', _drop(_purpose, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _purpose = v)))),
                        const SizedBox(width: 12),
                        Expanded(child: _col('Data', _dateInput())),
                        const SizedBox(width: 12),
                        Expanded(child: _col('Com imóvel', _drop(_withProperty, ['Indiferente', 'Sim', 'Não'], (v) => setState(() => _withProperty = v), hint: 'Indiferente'))),
                      ]),
                      const SizedBox(height: 12),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(child: _col('Usuário', _drop(_user, [], (v) => setState(() => _user = v)))),
                        const Spacer(flex: 2),
                      ]),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        OutlinedButton(onPressed: _clear,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                          child: const Text('Limpar')),
                        const SizedBox(width: 12),
                        ElevatedButton(onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                          child: const Text('Filtrar')),
                      ]),
                    ]);
                  }
                  return Column(children: [
                    _col('Finalidade', _drop(_purpose, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _purpose = v))),
                    const SizedBox(height: 12),
                    _col('Data', _dateInput()),
                    const SizedBox(height: 12),
                    _col('Com imóvel', _drop(_withProperty, ['Indiferente', 'Sim', 'Não'], (v) => setState(() => _withProperty = v), hint: 'Indiferente')),
                    const SizedBox(height: 12),
                    _col('Usuário', _drop(_user, [], (v) => setState(() => _user = v))),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: _clear,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Limpar'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Filtrar'))),
                    ]),
                  ]);
                }),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Resultados
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.list_alt, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text('Resultados de roletagens (${_results.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    columns: _columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))).toList(),
                    rows: _results.map((r) => DataRow(cells: _columns.map((c) => DataCell(Text(r[c] ?? '', style: const TextStyle(fontSize: 13)))).toList())).toList(),
                  ),
                ),
                if (_results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Nenhuma roletagem encontrada.', style: TextStyle(color: Colors.grey[400], fontSize: 14))),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _dateInput() => TextField(
    controller: _dateCtrl, readOnly: true, onTap: _pickDate,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Selecione uma data', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      suffixIcon: const Icon(Icons.calendar_today, size: 16),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged, {String hint = 'Selecione'}) => DropdownButtonFormField<String>(
    value: value, isExpanded: true,
    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
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

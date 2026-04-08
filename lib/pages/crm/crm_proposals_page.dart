import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

class CrmProposalsPage extends StatefulWidget {
  const CrmProposalsPage({super.key});

  @override
  State<CrmProposalsPage> createState() => _CrmProposalsPageState();
}

class _CrmProposalsPageState extends State<CrmProposalsPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _proposals = [];
  bool _loading = true;
  String _sortBy = 'created_at';

  final _propertyCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  String? _contract;
  String? _responsible;
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _propertyCtrl.dispose(); _dateCtrl.dispose(); _clientCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('crm_proposals')
          .select()
          .order(_sortBy, ascending: false);
      _proposals = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _proposals = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clear() {
    setState(() {
      _propertyCtrl.clear(); _dateCtrl.clear(); _clientCtrl.clear();
      _contract = null; _responsible = null; _status = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text('Propostas'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('PROPOSTAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                    const Row(children: [
                      Icon(Icons.filter_list, size: 18, color: AppTheme.primaryBlue),
                      SizedBox(width: 6),
                      Text('Filtros', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ]),
                    const SizedBox(height: 16),
                    // Row 1: Imóvel + Período + Contrato
                    LayoutBuilder(builder: (context, c) {
                      if (c.maxWidth > 700) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Expanded(flex: 3, child: _col('Imóvel', _input(_propertyCtrl, 'Busque por rua, código ou condomínio'))),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: _col('Período de validade', _input(_dateCtrl, 'Selecione uma data'))),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: _col('Contrato', _drop(_contract, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _contract = v)))),
                        ]);
                      }
                      return Column(children: [
                        _col('Imóvel', _input(_propertyCtrl, 'Busque por rua, código ou condomínio')),
                        const SizedBox(height: 12),
                        _col('Período de validade', _input(_dateCtrl, 'Selecione uma data')),
                        const SizedBox(height: 12),
                        _col('Contrato', _drop(_contract, ['Venda', 'Locação', 'Temporada'], (v) => setState(() => _contract = v))),
                      ]);
                    }),
                    const SizedBox(height: 14),
                    // Row 2: Cliente + Responsável + Status
                    LayoutBuilder(builder: (context, c) {
                      if (c.maxWidth > 700) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Expanded(flex: 3, child: _col('Cliente', _dropSearch(_clientCtrl, 'Busque pelo cliente'))),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: _col('Responsável', _drop(_responsible, ['Todos'], (v) => setState(() => _responsible = v)))),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: _col('Status', _drop(_status, ['Pendente', 'Aceita', 'Recusada', 'Expirada'], (v) => setState(() => _status = v)))),
                        ]);
                      }
                      return Column(children: [
                        _col('Cliente', _dropSearch(_clientCtrl, 'Busque pelo cliente')),
                        const SizedBox(height: 12),
                        _col('Responsável', _drop(_responsible, ['Todos'], (v) => setState(() => _responsible = v))),
                        const SizedBox(height: 12),
                        _col('Status', _drop(_status, ['Pendente', 'Aceita', 'Recusada', 'Expirada'], (v) => setState(() => _status = v))),
                      ]);
                    }),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: _clear, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Limpar'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: _load, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Filtrar'))),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabela
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.description_outlined, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text('Propostas (${_proposals.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(width: 6),
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        items: const [
                          DropdownMenuItem(value: 'created_at', child: Text('Data de cadastro')),
                          DropdownMenuItem(value: 'due_date', child: Text('Data de validade')),
                          DropdownMenuItem(value: 'proposed_value', child: Text('Valor')),
                        ],
                        onChanged: (v) { setState(() => _sortBy = v!); _load(); },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Row(children: [
                        Expanded(flex: 2, child: Text('Imóvel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Valor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Período', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Fila', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Oportunidade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Responsável', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                    _loading
                        ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                        : _proposals.isEmpty
                            ? _emptyState()
                            : Column(children: _proposals.map((p) => _proposalRow(p)).toList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(children: [
        Icon(Icons.description_outlined, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Nenhuma proposta encontrada.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
      ]),
    );
  }

  Widget _proposalRow(Map<String, dynamic> p) {
    final status = p['status'] ?? 'active';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey[200]!), right: BorderSide(color: Colors.grey[200]!), bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(p['property_id']?.toString().substring(0, 8) ?? '-', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 1, child: Text(p['proposed_value'] != null ? 'R\$ ${(p['proposed_value'] as num).toStringAsFixed(0)}' : '-', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 1, child: Text(p['due_date'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
        Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
        Expanded(flex: 2, child: Text('-', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
        Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
        Expanded(flex: 1, child: _badge(status)),
      ]),
    );
  }

  Widget _badge(String status) {
    Color c; String l;
    switch (status) {
      case 'active': c = Colors.blue; l = 'Pendente'; break;
      case 'accepted': c = Colors.green; l = 'Aceita'; break;
      case 'rejected': c = Colors.red; l = 'Recusada'; break;
      case 'expired': c = Colors.grey; l = 'Expirada'; break;
      default: c = Colors.grey; l = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(l, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
    );
  }

  // Helpers
  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _input(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl, style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

  Widget _dropSearch(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl, style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
    value: value, isExpanded: true,
    style: const TextStyle(fontSize: 13, color: Colors.black87),
    decoration: InputDecoration(
      hintText: 'Escolha', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
    onChanged: onChanged,
  );
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import 'crm_new_sale_contract_page.dart';

class CrmSalesPage extends StatefulWidget {
  const CrmSalesPage({super.key});

  @override
  State<CrmSalesPage> createState() => _CrmSalesPageState();
}

class _CrmSalesPageState extends State<CrmSalesPage> {
  final _supabase = Supabase.instance.client;
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _contracts = [];
  bool _loading = true;

  String? _tag;
  String? _period;
  String _sortBy = 'created_at';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      var query = _supabase
          .from('crm_sales_contracts')
          .select()
          .order(_sortBy, ascending: false);

      final data = await query;
      _contracts = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _contracts = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clearFilters() {
    setState(() {
      _searchCtrl.clear();
      _tag = null;
      _period = null;
    });
    _load();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchCtrl.text.isEmpty) return _contracts;
    final q = _searchCtrl.text.toLowerCase();
    return _contracts.where((c) {
      final buyer = (c['buyer_name'] ?? '').toString().toLowerCase();
      final property = (c['property_name'] ?? '').toString().toLowerCase();
      final phone = (c['buyer_phone'] ?? '').toString().toLowerCase();
      final cpf = (c['buyer_cpf'] ?? '').toString().toLowerCase();
      return buyer.contains(q) || property.contains(q) || phone.contains(q) || cpf.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Vendas'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('VENDAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 20),

            // Botão Novo Contrato
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNewSaleContractPage()));
                _load(); // Refresh after returning
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo contrato', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Filtros
            _buildFilters(),
            const SizedBox(height: 24),

            // Contratos
            _buildContractsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 18),
                const SizedBox(width: 8),
                const Text('Filtros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Salvar filtro', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row de filtros
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Busca
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Por nome, telefone, CPF',
                      labelText: 'Busca',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                // Etiquetas
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _tag,
                    decoration: InputDecoration(
                      labelText: 'Etiquetas',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'vitacon', child: Text('Vitacon')),
                      DropdownMenuItem(value: 'investidor', child: Text('Investidor')),
                      DropdownMenuItem(value: 'corretor', child: Text('Corretor')),
                    ],
                    onChanged: (v) => setState(() => _tag = v),
                  ),
                ),
                // Período
                SizedBox(
                  width: 200,
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (range != null) {
                        setState(() {
                          _period = '${range.start.day}/${range.start.month}/${range.start.year} - ${range.end.day}/${range.end.month}/${range.end.year}';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Período',
                      hintText: 'Selecione uma data',
                      suffixIcon: _period != null
                          ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _period = null))
                          : const Icon(Icons.calendar_today, size: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    controller: TextEditingController(text: _period),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Botões
            Row(
              children: [
                OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Limpar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Filtrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractsSection() {
    final contracts = _filtered;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Contratos (${contracts.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                // Sort
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: const [
                    DropdownMenuItem(value: 'created_at', child: Text('Data de cadastro')),
                    DropdownMenuItem(value: 'signing_date', child: Text('Data de assinatura')),
                    DropdownMenuItem(value: 'value', child: Text('Valor')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _sortBy = v);
                      _load();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (contracts.isEmpty)
              _buildEmptyState()
            else
              _buildTable(contracts),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhum contrato de venda encontrado.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            const SizedBox(height: 8),
            Text('Clique em "Novo contrato" para adicionar.', style: TextStyle(color: Colors.grey[350], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> contracts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(label: Text('Contrato', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          DataColumn(label: Text('Imóvel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          DataColumn(label: Text('Comprador', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          DataColumn(label: Text('Valor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          DataColumn(label: Text('Data de assinatura', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        ],
        rows: contracts.map((c) {
          return DataRow(cells: [
            DataCell(Text(c['contract_number']?.toString() ?? '—', style: const TextStyle(fontSize: 13))),
            DataCell(Text(c['property_name']?.toString() ?? '—', style: const TextStyle(fontSize: 13))),
            DataCell(Text(c['buyer_name']?.toString() ?? '—', style: const TextStyle(fontSize: 13))),
            DataCell(Text(_formatValue(c['value']), style: const TextStyle(fontSize: 13))),
            DataCell(Text(_formatDate(c['signing_date']), style: const TextStyle(fontSize: 13))),
          ]);
        }).toList(),
      ),
    );
  }

  void _showNewContractDialog() {
    final contractCtrl = TextEditingController();
    final propertyCtrl = TextEditingController();
    final buyerCtrl = TextEditingController();
    final valueCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Contrato de Venda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: contractCtrl, decoration: const InputDecoration(labelText: 'Nº do Contrato')),
              const SizedBox(height: 12),
              TextField(controller: propertyCtrl, decoration: const InputDecoration(labelText: 'Imóvel')),
              const SizedBox(height: 12),
              TextField(controller: buyerCtrl, decoration: const InputDecoration(labelText: 'Comprador')),
              const SizedBox(height: 12),
              TextField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Valor (R\$)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _supabase.from('crm_sales_contracts').insert({
                'contract_number': contractCtrl.text,
                'property_name': propertyCtrl.text,
                'buyer_name': buyerCtrl.text,
                'value': double.tryParse(valueCtrl.text) ?? 0,
                'signing_date': DateTime.now().toIso8601String(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '—';
    final v = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0;
    if (v >= 1000000) return 'R\$ ${(v / 1000000).toStringAsFixed(2)} mi';
    if (v >= 1000) return 'R\$ ${(v / 1000).toStringAsFixed(0)} mil';
    return 'R\$ ${v.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    final d = DateTime.tryParse(date.toString());
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

class CrmLeadsPage extends StatefulWidget {
  const CrmLeadsPage({super.key});

  @override
  State<CrmLeadsPage> createState() => _CrmLeadsPageState();
}

class _CrmLeadsPageState extends State<CrmLeadsPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _leads = [];
  bool _loading = true;

  final _searchCtrl = TextEditingController();
  String? _responsible;
  String? _origin;
  String? _status;
  String? _campaign;
  final _periodCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); _periodCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('market_leads')
          .select()
          .order('created_at', ascending: false);
      _leads = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _leads = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clear() {
    setState(() {
      _searchCtrl.clear(); _periodCtrl.clear();
      _responsible = null; _origin = null; _status = null; _campaign = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text('Leads'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb + action
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('LEADS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novo Lead'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
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
                      TextButton.icon(
                        onPressed: _saveFilter,
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Salvar filtro', style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Row 1
                    LayoutBuilder(builder: (context, c) {
                      if (c.maxWidth > 700) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Expanded(child: _col('Busca', _input(_searchCtrl, 'Busque por nome, telefone ou email do cli...'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Responsável', _drop(_responsible, ['Todos'], (v) => setState(() => _responsible = v), hint: 'Escolha um responsável'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Origem', _drop(_origin, [
                            'Não informado', 'Todos',
                          ], (v) => setState(() => _origin = v), hint: 'Escolha uma origem'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Status', _drop(_status, [
                            'Não resolvido', 'Resolvido',
                          ], (v) => setState(() => _status = v), hint: 'Escolha um status'))),
                        ]);
                      }
                      return Column(children: [
                        _col('Busca', _input(_searchCtrl, 'Busque por nome, telefone ou email')),
                        const SizedBox(height: 12),
                        _col('Responsável', _drop(_responsible, ['Todos'], (v) => setState(() => _responsible = v), hint: 'Escolha um responsável')),
                        const SizedBox(height: 12),
                        _col('Origem', _drop(_origin, ['Site', 'WhatsApp', 'Indicação', 'Portal', 'Telefone', 'Redes sociais', 'Outros'], (v) => setState(() => _origin = v), hint: 'Escolha uma origem')),
                        const SizedBox(height: 12),
                        _col('Status', _drop(_status, ['Novo', 'Em atendimento', 'Aceito', 'Recusado', 'Expirado'], (v) => setState(() => _status = v), hint: 'Escolha um status')),
                      ]);
                    }),
                    const SizedBox(height: 14),
                    // Row 2
                    LayoutBuilder(builder: (context, c) {
                      if (c.maxWidth > 700) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Expanded(child: _col('Campanha', _drop(_campaign, ['Todas'], (v) => setState(() => _campaign = v), hint: 'Escolha uma campanha'))),
                          const SizedBox(width: 12),
                          Expanded(child: _col('Período', _input(_periodCtrl, 'Escolha um período'))),
                          const Spacer(),
                          const Spacer(),
                        ]);
                      }
                      return Column(children: [
                        _col('Campanha', _drop(_campaign, ['Todas'], (v) => setState(() => _campaign = v), hint: 'Escolha uma campanha')),
                        const SizedBox(height: 12),
                        _col('Período', _input(_periodCtrl, 'Escolha um período')),
                      ]);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lista
            _loading
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                : _leads.isEmpty
                    ? _emptyState()
                    : Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _leads.length,
                          itemBuilder: (_, i) => _leadTile(_leads[i]),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Nenhum lead encontrado.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
        ]),
      ),
    );
  }

  Widget _leadTile(Map<String, dynamic> lead) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          child: Text((lead['name'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lead['name'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(lead['email'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ])),
        Text(lead['phone'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(width: 16),
        _statusBadge(lead['status'] ?? 'new'),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    Color c; String l;
    switch (status) {
      case 'new': c = Colors.blue; l = 'Novo'; break;
      case 'contacted': c = Colors.orange; l = 'Contatado'; break;
      case 'qualified': c = Colors.green; l = 'Qualificado'; break;
      case 'closed': c = Colors.grey; l = 'Fechado'; break;
      default: c = Colors.grey; l = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(l, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
    );
  }

  void _saveFilter() {
    final hasFilter = _searchCtrl.text.isNotEmpty || _periodCtrl.text.isNotEmpty ||
        _responsible != null || _origin != null || _status != null || _campaign != null;
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

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged, {String hint = 'Escolha'}) => DropdownButtonFormField<String>(
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

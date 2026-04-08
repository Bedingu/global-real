import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

class CrmKeysPage extends StatefulWidget {
  const CrmKeysPage({super.key});

  @override
  State<CrmKeysPage> createState() => _CrmKeysPageState();
}

class _CrmKeysPageState extends State<CrmKeysPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _keys = [];
  bool _loading = true;

  final _codeCtrl = TextEditingController();
  final _propertyCtrl = TextEditingController();
  final _personCtrl = TextEditingController();
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeCtrl.dispose(); _propertyCtrl.dispose(); _personCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('crm_keys')
          .select()
          .order('withdrawn_at', ascending: false);
      _keys = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _keys = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clear() {
    setState(() {
      _codeCtrl.clear(); _propertyCtrl.clear(); _personCtrl.clear(); _status = null;
    });
  }

  void _saveFilter() {
    final hasFilter = _codeCtrl.text.isNotEmpty ||
        _propertyCtrl.text.isNotEmpty ||
        _personCtrl.text.isNotEmpty ||
        _status != null;

    if (!hasFilter) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          width: 400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Oooops!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Selecione pelo menos um campo para poder salvar como filtro',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // TODO: salvar filtro no Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro salvo!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text('Chaves'), backgroundColor: AppTheme.primaryBlue),
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
              const Text('CHAVES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                    // Filter row
                    LayoutBuilder(builder: (context, c) {
                      if (c.maxWidth > 700) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: _filterCol('Código da chave', _codeCtrl, 'Busque pelo código da chave')),
                            const SizedBox(width: 12),
                            Expanded(child: _filterCol('Imóvel', _propertyCtrl, 'Busque pelo código imóvel')),
                            const SizedBox(width: 12),
                            Expanded(child: _filterCol('Retirada por', _personCtrl, 'Buscar')),
                            const SizedBox(width: 12),
                            Expanded(child: _statusDropdown()),
                          ],
                        );
                      }
                      return Column(children: [
                        _filterCol('Código da chave', _codeCtrl, 'Busque pelo código da chave'),
                        const SizedBox(height: 12),
                        _filterCol('Imóvel', _propertyCtrl, 'Busque pelo código imóvel'),
                        const SizedBox(height: 12),
                        _filterCol('Retirada por', _personCtrl, 'Buscar'),
                        const SizedBox(height: 12),
                        _statusDropdown(),
                      ]);
                    }),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clear,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Filtrar'),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabela de chaves
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.vpn_key_outlined, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text('Chaves (${_keys.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(width: 6),
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                    ]),
                    const SizedBox(height: 16),
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Row(children: [
                        Expanded(flex: 1, child: Text('Código', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Agência', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Imóvel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Retirada', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Previsão de entrega', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                    // Content
                    _loading
                        ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                        : _keys.isEmpty
                            ? _emptyState()
                            : Column(children: _keys.map((k) => _keyRow(k)).toList()),
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
      child: Column(
        children: [
          Icon(Icons.vpn_key_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Nenhuma chave encontrada.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
        ],
      ),
    );
  }

  Widget _keyRow(Map<String, dynamic> key) {
    final status = key['status'] ?? 'withdrawn';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[200]!),
          right: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(children: [
        Expanded(flex: 1, child: Text(key['id']?.toString().substring(0, 6) ?? '-', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
        Expanded(flex: 2, child: Text(key['property_id']?.toString().substring(0, 8) ?? '-', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(key['person_name'] ?? '-', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 1, child: _statusBadge(status)),
        Expanded(flex: 2, child: Text(key['returned_at'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'withdrawn': color = Colors.orange; label = 'Retirada'; break;
      case 'returned': color = Colors.green; label = 'Devolvida'; break;
      case 'late': color = Colors.red; label = 'Atrasada'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  // Filter helpers
  Widget _filterCol(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _status,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Todos', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Todos')),
            DropdownMenuItem(value: 'late', child: Text('Atrasadas')),
            DropdownMenuItem(value: 'withdrawn', child: Text('Retiradas')),
            DropdownMenuItem(value: 'available', child: Text('Disponíveis')),
          ],
          onChanged: (v) => setState(() => _status = v),
        ),
      ],
    );
  }
}

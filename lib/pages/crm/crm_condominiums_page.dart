import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import 'crm_new_condominium_page.dart';

class CrmCondominiumsPage extends StatefulWidget {
  const CrmCondominiumsPage({super.key});

  @override
  State<CrmCondominiumsPage> createState() => _CrmCondominiumsPageState();
}

class _CrmCondominiumsPageState extends State<CrmCondominiumsPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _condos = [];
  bool _loading = true;
  String _sortBy = 'created_at';

  final _searchCtrl = TextEditingController();
  String? _launch;    // Sim, Não, null=Sem filtro
  String? _highlight;
  String? _available;
  String? _stage;

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
      final data = await _supabase
          .from('crm_condominiums')
          .select()
          .order(_sortBy, ascending: false);
      _condos = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _condos = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text('Condomínios'), backgroundColor: AppTheme.primaryBlue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb + action
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                ),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                const Text('CONDOMÍNIOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNewCondominiumPage()));
                    if (result == true) _load();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Novo condomínio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 340, child: _buildFilters()),
                Expanded(child: _buildList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.only(left: 24, bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 18, color: AppTheme.primaryBlue),
                const SizedBox(width: 6),
                const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border, size: 16),
                  label: const Text('Salvar filtro', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _input(Icons.search, 'Busque por endereço, código ou condomínio', _searchCtrl),
            const SizedBox(height: 14),
            _label('Incorporadora'),
            _dropdown('Pesquise por: Nome, CPF, Telefone'),
            const SizedBox(height: 14),
            _label('Construtora'),
            _dropdown('Pesquise por: Nome, CPF, Telefone'),
            const SizedBox(height: 14),
            _label('Cidade / estado'),
            _dropdown('Digite a cidade'),
            const SizedBox(height: 14),
            _label('Bairro'),
            _dropdown('Digite o bairro'),
            const SizedBox(height: 14),
            _label('Etiquetas'),
            _dropdown('Selecione ou pesquise etiquetas'),
            const SizedBox(height: 14),
            // Lançamento + Destaque
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _radioGroup('Lançamento', _launch, (v) => setState(() => _launch = v))),
              const SizedBox(width: 12),
              Expanded(child: _radioGroup('Destaque', _highlight, (v) => setState(() => _highlight = v))),
            ]),
            const SizedBox(height: 14),
            // Imóveis disponíveis + Estágio
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _radioGroup('Imóveis disponíveis', _available, (v) => setState(() => _available = v))),
              const SizedBox(width: 12),
              Expanded(child: _stageGroup()),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _searchCtrl.clear(),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Filtrar'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 24, bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.domain, size: 18, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text('Condomínios (${_condos.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: const [
                    DropdownMenuItem(value: 'created_at', child: Text('Data de cadastro')),
                    DropdownMenuItem(value: 'updated_at', child: Text('Data de atualização')),
                  ],
                  onChanged: (v) { setState(() => _sortBy = v!); _load(); },
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _condos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.domain_outlined, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('Nenhum condomínio encontrado.', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNewCondominiumPage()));
                                  if (result == true) _load();
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Novo condomínio'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _condos.length,
                          itemBuilder: (_, i) => _condoTile(_condos[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _condoTile(Map<String, dynamic> condo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.domain, color: Colors.grey[400]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(condo['name'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${condo['neighborhood'] ?? ''} · ${condo['city'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _input(IconData? icon, String hint, TextEditingController ctrl) => TextField(
    controller: ctrl,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

  Widget _dropdown(String hint) => DropdownButtonFormField<String>(
    isExpanded: true,
    style: const TextStyle(fontSize: 13, color: Colors.black87),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
    items: const [],
    onChanged: (_) {},
  );

  Widget _radioGroup(String title, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        _radioOption('Sim', value, onChanged),
        _radioOption('Não', value, onChanged),
        _radioOption(null, value, onChanged, label: 'Sem filtro'),
      ],
    );
  }

  Widget _radioOption(String? optValue, String? groupValue, ValueChanged<String?> onChanged, {String? label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String?>(
          value: optValue,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label ?? optValue ?? 'Sem filtro', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _stageGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Estágio'),
        _radioOption('Na planta', _stage, (v) => setState(() => _stage = v)),
        _radioOption('Em construção', _stage, (v) => setState(() => _stage = v)),
        _radioOption('Pronto', _stage, (v) => setState(() => _stage = v)),
        _radioOption(null, _stage, (v) => setState(() => _stage = v), label: 'Sem filtro'),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

class CrmPropertiesPage extends StatefulWidget {
  const CrmPropertiesPage({super.key});

  @override
  State<CrmPropertiesPage> createState() => _CrmPropertiesPageState();
}

class _CrmPropertiesPageState extends State<CrmPropertiesPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _properties = [];
  bool _loading = true;
  String _sortBy = 'updated_at';
  bool _gridView = false;

  // Filtros
  final _searchCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final Set<String> _contractTypes = {};
  String? _availability;
  String? _propertyType;
  String? _city;
  String? _neighborhood;
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  int? _bedrooms;
  int? _suites;
  int? _bathrooms;
  int? _parking;
  String? _furnished;
  String? _condition;
  final Set<String> _dealTags = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); _codeCtrl.dispose();
    _minPriceCtrl.dispose(); _maxPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('crm_properties')
          .select()
          .order(_sortBy, ascending: false);
      _properties = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _properties = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clearFilters() {
    setState(() {
      _searchCtrl.clear(); _codeCtrl.clear();
      _contractTypes.clear(); _availability = null;
      _propertyType = null; _city = null; _neighborhood = null;
      _minPriceCtrl.clear(); _maxPriceCtrl.clear();
      _bedrooms = null; _suites = null; _bathrooms = null;
      _parking = null; _furnished = null; _condition = null;
      _dealTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Imóveis'), backgroundColor: AppTheme.primaryBlue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                ),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                const Text('IMÓVEIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Novo imóvel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.price_change_outlined, size: 18),
                  label: const Text('Reajustar valores'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Body: Filters + List
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters panel
                SizedBox(
                  width: 340,
                  child: _buildFilters(),
                ),
                // Properties list
                Expanded(child: _buildPropertyList()),
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
      elevation: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
            // Busca
            _filterInput(Icons.search, 'Busque por endereço, código, condomínio', _searchCtrl),
            const SizedBox(height: 14),
            // Código
            _filterLabel('Código'),
            _filterInput(null, 'Informe um código', _codeCtrl),
            const SizedBox(height: 14),
            // Contrato
            _filterLabel('Contrato'),
            Row(children: [
              _checkOption('Venda', _contractTypes),
              _checkOption('Locação', _contractTypes),
              _checkOption('Temporada', _contractTypes),
            ]),
            const SizedBox(height: 14),
            // Disponibilidade
            _filterLabel('Disponibilidade'),
            _dropdown('Disponível, negociado, etc...', _availability, [
              'Disponível para negociação',
              'Indisponível para negociação',
              'Negociado',
              'Aguardando aprovação',
            ], (v) => setState(() => _availability = v)),
            const SizedBox(height: 14),
            // Tipo
            _filterLabel('Tipo'),
            _dropdown('Apartamento, casa, etc...', _propertyType, [
              'Apartamento', 'Apartamento Garden', 'Área Rural', 'Box', 'Campo',
              'Casa', 'Casa Comercial', 'Casa de Condomínio', 'Chácara', 'Cobertura',
              'Conjunto Comercial', 'Duplex', 'Fazenda', 'Flat', 'Galpão',
              'Geminado', 'Haras', 'Hotel', 'Kitnet', 'Loft',
              'Loja', 'Pavilhão', 'Ponto Comercial', 'Pousada', 'Prédio Comercial',
              'Prédio Residencial', 'Sala Comercial', 'Salão Comercial', 'Sítio', 'Sobrado',
              'Studio', 'Terreno', 'Terreno Comercial', 'Triplex',
            ], (v) => setState(() => _propertyType = v)),
            const SizedBox(height: 14),
            // Cidade
            _filterLabel('Cidade - UF'),
            _dropdown('Escolha a cidade', _city, [
              'São Paulo - SP', 'Rio de Janeiro - RJ', 'Curitiba - PR', 'Orlando - FL', 'Miami - FL',
            ], (v) => setState(() => _city = v)),
            const SizedBox(height: 14),
            // Bairro
            _filterLabel('Bairro'),
            _dropdown('Escolha o bairro', _neighborhood, [
              'Pinheiros', 'Vila Madalena', 'Itaim Bibi', 'Moema', 'Jardins', 'Brooklin',
            ], (v) => setState(() => _neighborhood = v)),
            const SizedBox(height: 14),
            // Valores
            _filterLabel('Valores'),
            Row(children: [
              Expanded(child: _filterInput(null, 'De', _minPriceCtrl, keyboard: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('até')),
              Expanded(child: _filterInput(null, 'Até', _maxPriceCtrl, keyboard: TextInputType.number)),
            ]),
            const SizedBox(height: 14),
            // Dormitórios
            _filterLabel('Dormitórios'),
            _numberSelector(_bedrooms, (v) => setState(() => _bedrooms = v)),
            const SizedBox(height: 14),
            // Suítes
            _filterLabel('Suítes'),
            _numberSelector(_suites, (v) => setState(() => _suites = v), startAt: 0),
            const SizedBox(height: 14),
            // Banheiros
            _filterLabel('Banheiros'),
            _numberSelector(_bathrooms, (v) => setState(() => _bathrooms = v), startAt: 0),
            const SizedBox(height: 14),
            // Vagas
            _filterLabel('Vagas de garagem'),
            _numberSelector(_parking, (v) => setState(() => _parking = v), startAt: 0),
            const SizedBox(height: 14),
            // Mobiliado
            _filterLabel('Mobiliado'),
            _dropdown('Indiferente', _furnished, [
              'Mobiliado',
              'Semimobiliado',
              'Mobiliado ou Semi',
              'Não mobiliado',
            ], (v) => setState(() => _furnished = v)),
            const SizedBox(height: 14),
            // Comodidades e infraestruturas
            _filterLabel('Comodidades e infraestruturas'),
            _dropdown('Elevador, Piscina, etc...', null, _amenitiesList, (v) {}),
            const SizedBox(height: 14),
            // Andar
            _filterLabel('Andar'),
            _dropdown('Selecione o andar', null, [
              'Último andar', 'Térreo',
              ...List.generate(70, (i) => '${i + 1}º Andar'),
            ], (v) {}),
            const SizedBox(height: 14),
            // Condição
            _filterLabel('Condição'),
            Wrap(spacing: 6, children: [
              _choiceTag('Em construção', _condition == 'construction', () => setState(() => _condition = 'construction')),
              _choiceTag('Na planta', _condition == 'blueprint', () => setState(() => _condition = 'blueprint')),
              _choiceTag('Novo', _condition == 'new', () => setState(() => _condition = 'new')),
              _choiceTag('Usado', _condition == 'used', () => setState(() => _condition = 'used')),
            ]),
            const SizedBox(height: 14),
            // Negócio
            _filterLabel('Negócio'),
            Wrap(spacing: 6, children: [
              _checkOption('Financiável', _dealTags),
              _checkOption('MCMV', _dealTags),
              _checkOption('Aceita permuta', _dealTags),
            ]),
            const SizedBox(height: 14),
            // Anunciado
            _filterLabel('Anunciado'),
            _dropdown('Indiferente', null, ['Sim', 'Não'], (v) {}),
            const SizedBox(height: 14),
            // Área terreno
            _filterLabel('Área terreno'),
            Row(children: [
              Expanded(child: _filterInput(null, 'Mín', TextEditingController(), keyboard: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('m²')),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('até')),
              Expanded(child: _filterInput(null, 'Máx', TextEditingController(), keyboard: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('m²')),
            ]),
            const SizedBox(height: 14),
            // Fotos + Atualização
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Fotos'),
                  _dropdown('Indiferente', null, ['Com', 'Sem'], (v) {}),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Atualização'),
                  _dropdown('Indiferente', null, ['Atualizados', 'Expirando', 'Desatualizados'], (v) {}),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            // Placa + Exclusividade
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Placa'),
                  _dropdown('Indiferente', null, ['Com', 'Sem'], (v) {}),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Exclusividade'),
                  _dropdown('Indiferente', null, ['Todos', 'Atualizados', 'Desatualizados', 'Vencendo', 'Não exclusivos'], (v) {}),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            // Plantas + Vídeos
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Plantas'),
                  _dropdown('Indiferente', null, ['Com', 'Sem'], (v) {}),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Vídeos'),
                  _dropdown('Indiferente', null, ['Com', 'Sem'], (v) {}),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            // Tours + Arquivos
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Tours'),
                  _dropdown('Indiferente', null, ['Com', 'Sem'], (v) {}),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Arquivos'),
                  _dropdown('Indiferente', null, ['Com', 'Sem'], (v) {}),
                ],
              )),
            ]),
            const SizedBox(height: 14),
            // Distância para o mar
            _filterLabel('Distância para o mar'),
            _filterInput(null, 'Máximo', TextEditingController(), keyboard: TextInputType.number),
            const SizedBox(height: 14),
            // Ocupação
            _filterLabel('Ocupação'),
            _dropdown('Indiferente', null, ['Desocupado', 'Locado', 'Ocupado'], (v) {}),
            const SizedBox(height: 24),
            // Buttons
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildPropertyList() {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 24, bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.apartment, size: 18, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  _gridView ? 'Localizações (${_properties.length})' : 'Imóveis (${_properties.length})',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Spacer(),
                // View toggle
                IconButton(
                  icon: Icon(Icons.view_list, color: !_gridView ? AppTheme.primaryBlue : Colors.grey[400], size: 20),
                  onPressed: () => setState(() => _gridView = false),
                ),
                IconButton(
                  icon: Icon(Icons.grid_view, color: _gridView ? AppTheme.primaryBlue : Colors.grey[400], size: 20),
                  onPressed: () => setState(() => _gridView = true),
                ),
                const SizedBox(width: 8),
                // Sort
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'updated_at', child: Text('Data de atualização')),
                    DropdownMenuItem(value: 'created_at', child: Text('Data de cadastro')),
                    DropdownMenuItem(value: 'edited_at', child: Text('Data de edição')),
                    DropdownMenuItem(value: 'price_asc', child: Text('Menor valor')),
                    DropdownMenuItem(value: 'price_desc', child: Text('Maior valor')),
                  ],
                  onChanged: (v) { setState(() => _sortBy = v!); _load(); },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Select all + actions
            Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                const Text('Selecionar', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    hint: const Text('Ações', style: TextStyle(fontSize: 13)),
                    items: const [
                      DropdownMenuItem(value: 'delete', child: Text('Excluir')),
                      DropdownMenuItem(value: 'export', child: Text('Exportar')),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _properties.isEmpty
                      ? _emptyState()
                      : _gridView
                          ? _buildMapView()
                          : ListView.builder(
                              itemCount: _properties.length,
                              itemBuilder: (_, i) => _propertyTile(_properties[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              color: const Color(0xFFE8F5E9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      _properties.isEmpty
                          ? 'Nenhuma localização encontrada'
                          : '${_properties.length} imóvel(is) no mapa',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre imóveis com endereço para visualizar no mapa',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12, left: 12,
              child: Column(
                children: [
                  _mapButton(Icons.add),
                  const SizedBox(height: 4),
                  _mapButton(Icons.remove),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapButton(IconData icon) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
      ),
      child: Icon(icon, size: 18, color: Colors.grey[700]),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Nenhum imóvel encontrado.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Novo imóvel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyTile(Map<String, dynamic> prop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(value: false, onChanged: (_) {}),
          const SizedBox(width: 8),
          Container(
            width: 64, height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.image, color: Colors.grey[400]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prop['title'] ?? 'Sem título', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  '${prop['neighborhood'] ?? ''} · ${prop['city'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            prop['price'] != null ? 'R\$ ${(prop['price'] as num).toStringAsFixed(0)}' : '-',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(prop['status']).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusLabel(prop['status']),
              style: TextStyle(fontSize: 11, color: _statusColor(prop['status']), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FILTER HELPERS ====================

  Widget _filterLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _filterInput(IconData? icon, String hint, TextEditingController ctrl, {TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
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

  Widget _checkOption(String label, Set<String> set) {
    final selected = set.contains(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: selected,
          onChanged: (v) => setState(() => v == true ? set.add(label) : set.remove(label)),
          activeColor: AppTheme.primaryBlue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _numberSelector(int? value, ValueChanged<int?> onChanged, {int startAt = 1}) {
    final options = List.generate(5, (i) => i + startAt);
    return Wrap(
      spacing: 6,
      children: [
        ...options.map((n) => _choiceTag(
          '$n',
          value == n,
          () => onChanged(value == n ? null : n),
        )),
        _choiceTag('5 ou +', value == 6, () => onChanged(value == 6 ? null : 6)),
      ],
    );
  }

  Widget _choiceTag(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppTheme.primaryBlue : Colors.grey[300]!),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      ),
    );
  }

  static const _amenitiesList = [
    'Academia', 'Acessibilidade para PCD', 'Acesso asfaltado', 'Acesso para banhistas',
    'Adega', 'Administradora', 'Agility', 'Alarme', 'Alojamento', 'Antena TV',
    'Aquecedor', 'Aquecimento a gás', 'Aquecimento central', 'Aquecimento solar',
    'Ar condicionado', 'Armário cozinha', 'Armário embutido', 'Auditório',
    'Automação predial', 'Açude', 'Balança', 'Banheira hidromassagem',
    'Banheiro auxiliar', 'Banheiro social', 'Bar', 'Bar molhado', 'Barragem',
    'Biblioteca', 'Bicicletário', 'Boate', 'Bomba de combustível', 'Brinquedoteca',
    'Business center', 'Cabeamento estruturado', 'Cachoeira', 'Campo de futebol',
    'Campo de golfe', 'Cancha de bocha', 'Canil', 'Cantina', 'Capela',
    'Captação água da chuva', 'Car wash', 'Carregador veicular',
    'Carregador veicular (espera)', 'Casa de funcionários', 'Caseiro', 'Celeiro',
    'Central telefônica', 'Centro de estética', 'Cerca elétrica', 'Cercas',
    'Children care', 'Churrasqueira', 'Churrasqueira coletiva', 'Circuito TV',
    'Closet', 'Clube', 'Coffee bar', 'Coleta seletiva de lixo',
    'Coleta óleo de cozinha', 'Copa', 'Coworking', 'Cozinha',
    'Cozinha americana', 'Cozinha gourmet', 'Cozinha grande', 'Cozinha independente',
    'Cube', 'Curral', 'De esquina', 'Deck', 'Deck molhado', 'Dep. empregada',
    'Depósito', 'Depósito de defensivos', 'Despensa', 'Edícula', 'Elevador',
    'Elevador de serviço', 'Energia elétrica', 'Energia solar', 'Entrada lateral',
    'Escada', 'Escritório', 'Espaço de beleza', 'Espaço gourmet', 'Espaço kids',
    'Espaço pet', 'Espaço zen', "Espelho d'agua", 'Espera para split',
    'Estacionamento', 'Estacionamento visitantes', 'Estar social',
    'Estudio de pilates', 'Estúdio fitness', 'Fechadura digital', 'Ferro passar',
    'Fiação subterrânea', 'Fire pit', 'Fitness ao ar livre', 'Fogão',
    'Forno de pizza', 'Freezer', 'Galpão', 'Galpão de máquinas', 'Garage band',
    'Geladeira', 'Gerador de energia', 'Gramado', 'Guarita', 'Guarita blindada',
    'Guias e sarjeta', 'Gás central', 'Gás encanado', 'Gás individual',
    'Hall de entrada', 'Heliponto', 'Hidrômetro individual', 'Hipica', 'Hobby box',
    'Home market', 'Home office', 'Horta', 'Horta comunitária',
    'Interfone', 'Internet', 'Jacuzzi', 'Janela grande', 'Jardim', 'Lago',
    'Lareira', 'Lareira a gás (espera)', 'Lava louças', 'Lava-pés', 'Lavabo',
    'Lavador', 'Lavanderia', 'Lavanderia coletiva', 'Lockers', 'Lounge', 'Luminárias',
    'Mangueira', 'Manobrista', 'Marina', 'Mezanino', 'Microondas', 'Mini quadra',
    'Moega', 'Muro', 'Muro de escalada', 'Muros perimetrais', 'Máquina de lavar',
    'Móveis planejados', 'Nascente', 'Oficina', 'Permite festas', 'Pet care',
    'Pet friendly', 'Piscina', 'Piscina aquecida', 'Piscina coberta',
    'Piscina infantil', 'Piscina semi-olímpica', 'Pista de boliche',
    'Pista de caminhada', 'Pista de pouso', 'Pista de skate', 'Pivô irrigação',
    'Playground', 'Pomar', 'Portaria 24h', 'Portaria virtual', 'Porte-cochère',
    'Portão eletrônico', 'Porão', 'Poço artesiano', 'Praça', 'Pátio',
    'Pé direito elevado', 'Quadra de beach tennis', 'Quadra de padel',
    'Quadra de squash', 'Quadra de tênis', 'Quadra de tênis de saibro',
    'Quadra poliesportiva', 'Quintal', 'Quiosque com churrasqueira', 'Recepção',
    'Redario', 'Reservatório de água', 'Residência inteligente', 'Restaurante',
    'Riacho', 'Rio', 'Ronda motorizada', 'Rooftop', 'Roupa de cama', 'Roupa de mesa',
    'Ruas asfaltadas', 'Sacada', 'Sala de almoço', 'Sala de cinema',
    'Sala de estar', 'Sala de jantar', 'Sala de massagem', 'Sala de reunião',
    'Salão de festas', 'Salão de festas infantil', 'Salão de jogos', 'Sauna',
    'Secador', 'Sede', 'Segurança 24h', 'Silo', 'Solarium', 'Spa', 'Sótão',
    'TV', 'TV a cabo', 'Telefone', 'Terraço', 'Utensílios churrasqueira',
    'Utensílios cozinha', 'Varanda', 'Varanda fechada com vidro', 'Varanda gourmet',
    'Varanda integrada', 'Varanda separada', 'Ventilador', 'Vestiário',
    'Vestiário para diaristas', 'Vigilância', 'Vista panorâmica',
    'Vídeo monitoramento', 'WC empregada', 'Zelador', 'Área de lazer',
    'Área de serviço', 'Área verde', 'Árvores frutíferas',
  ];

  String _statusLabel(String? status) {
    switch (status) {
      case 'active': return 'Disponível';
      case 'pending_approval': return 'Aguardando';
      case 'expiring': return 'Expirando';
      case 'outdated': return 'Desatualizado';
      case 'negotiated': return 'Negociado';
      default: return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'pending_approval': return Colors.blue;
      case 'expiring': return Colors.orange;
      case 'outdated': return Colors.red;
      case 'negotiated': return Colors.grey;
      default: return Colors.grey;
    }
  }
}

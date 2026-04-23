import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmPortalsPage extends StatefulWidget {
  const CrmPortalsPage({super.key});

  @override
  State<CrmPortalsPage> createState() => _CrmPortalsPageState();
}

class _CrmPortalsPageState extends State<CrmPortalsPage> {
  final _searchCtrl = TextEditingController();
  String? _attention;
  String? _paid;
  String? _status;

  static final _portals = [
    _Portal('gustavo-26710', 0, '0 / 100', '-', '-', '-', '-', 'Ativo'),
    _Portal('jetlar.com', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('123i', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('321 Achei', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('62imoveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Achou Mudou!', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Apto', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Attria', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Barbada Classe A', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Buskaza', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Casa Mineira', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Casa Temporada', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('CasaCarro', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Casafy', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Chave Fácil', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Chaves na Mão', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Chãozão', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Classificados Joinville', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Clic Litoral Sul', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Cliquei Mudei', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Compre & Alugue Agora', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('DF Imóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Dream Casa', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Eu Corretor', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Expo Imóvel', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Facebook', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Grupo OLX | Viva Real, Zap, OLX', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Guia Imóvel & Cia', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Guia de Imóveis SP', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Homer', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Immobile', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imovago', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imovelpratico', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imovelweb', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('ImovoMAP', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imóveis Global', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imóveis na Serra', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imóveis-SC', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Imóvel Guide', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Kazaki', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Koort Imóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('La Gran Inmobiliaria', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Leadfy', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Leasy', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Localize Mais', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Loft', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Lugar Certo', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('LuxuryEstate', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('MGF Imóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Mappo', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Moving', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Núcleo Imobiliário de Francisco Beltrão', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('OLX', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Olho Mágico', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('PIM 360', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Painel Imobiliário', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Pesca Imóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Portal Imóveis Brasil', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Portal Imóveis Curitiba', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Portal Imóveis Litoral do Paraná', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Portal Imóveis Paraná', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Procura-se Imóvel', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Procure Imóvel', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Properstar (ListGlobally)', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Quinto Andar', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Rede Inova Imóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('RoteMix', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('RuaDois', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('SPImóvel', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('SUB100', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Temporada Livre', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Terraz', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Vale do Paraíba Imóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Vem pra casa', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Viveendo Bem', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('VrSync', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Web Escritórios', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('WebImóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Wimóveis', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('iGlobal', null, '-', '-', '-', '-', '-', 'Inativo'),
    _Portal('Órulo - Exclusividades', null, '-', '-', '-', '-', '-', 'Inativo'),
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Portais'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('PORTAIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),

          // Filtros
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.filter_list, size: 18, color: AppTheme.primaryBlue),
                  SizedBox(width: 6),
                  Text('Filtros', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (ctx, c) {
                  if (c.maxWidth > 700) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(child: _col('Busca', _searchInput())),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Requer atenção', _drop(_attention, [], (v) => setState(() => _attention = v)))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Pago', _drop(_paid, [], (v) => setState(() => _paid = v)))),
                      const SizedBox(width: 12),
                      Expanded(child: _col('Status', _drop(_status, [], (v) => setState(() => _status = v)))),
                    ]);
                  }
                  return Column(children: [
                    _col('Busca', _searchInput()), const SizedBox(height: 12),
                    _col('Requer atenção', _drop(_attention, [], (v) => setState(() => _attention = v))), const SizedBox(height: 12),
                    _col('Pago', _drop(_paid, [], (v) => setState(() => _paid = v))), const SizedBox(height: 12),
                    _col('Status', _drop(_status, [], (v) => setState(() => _status = v))),
                  ]);
                }),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Portais table
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.language, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text('Portais (${_portals.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    columns: const [
                      DataColumn(label: Text('Portal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Anúncios', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Destaque', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Super', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Premium', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Especial', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Requer atenção', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    ],
                    rows: _portals.map((p) => DataRow(cells: [
                      DataCell(Text(p.name, style: const TextStyle(fontSize: 13))),
                      DataCell(Text(p.ads != null ? '${p.ads}' : '-', style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                      DataCell(Text(p.highlight, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                      DataCell(Text(p.superVal, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                      DataCell(Text(p.premium, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                      DataCell(Text(p.special, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                      DataCell(Text(p.attention, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                      DataCell(_statusBadge(p.status)),
                    ])).toList(),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isActive = status == 'Ativo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, color: isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.w600)),
    );
  }

  Widget _col(String label, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), child,
  ]);

  Widget _searchInput() => TextField(
    controller: _searchCtrl, style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Busque pelo nome do portal', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
  );

  Widget _drop(String? value, List<String> items, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
    value: value, isExpanded: true, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
    decoration: InputDecoration(
      hintText: 'Selecione', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
    onChanged: onChanged,
  );
}

class _Portal {
  final String name;
  final int? ads;
  final String highlight, superVal, premium, special, attention, status;
  const _Portal(this.name, this.ads, this.highlight, this.superVal, this.premium, this.special, this.attention, this.status);
}

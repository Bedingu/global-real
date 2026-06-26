import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemTagsPage extends StatefulWidget {
  const CrmSystemTagsPage({super.key});

  @override
  State<CrmSystemTagsPage> createState() => _CrmSystemTagsPageState();
}

class _CrmSystemTagsPageState extends State<CrmSystemTagsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Configurações de Etiqueta'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('CONFIGURAÇÕES DE ETIQUETA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryBlue,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Etiquetas (0)'),
                Tab(text: 'Campanhas (0)'),
                Tab(text: 'Origens (102)'),
                Tab(text: 'Equipes (1)'),
                Tab(text: 'Agências (1)'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildEtiquetasTab(),
                _buildCampanhasTab(),
                _buildOrigensTab(),
                _buildEquipesTab(),
                _buildAgenciasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══ ETIQUETAS ═══
  Widget _buildEtiquetasTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _showNewTagDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nova etiqueta', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Pesquise por nome ou módulo',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Empty state
          _emptyState(
            icon: Icons.label_outlined,
            message: 'Nenhuma etiqueta foi criada até o momento.',
            buttonLabel: 'Nova etiqueta',
            onTap: _showNewTagDialog,
          ),
        ],
      ),
    );
  }

  // ═══ CAMPANHAS ═══
  Widget _buildCampanhasTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nova campanha', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 40),
          _emptyState(icon: Icons.campaign_outlined, message: 'Nenhuma campanha criada.', buttonLabel: 'Nova campanha', onTap: () {}),
        ],
      ),
    );
  }

  // ═══ ORIGENS ═══
  Widget _buildOrigensTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Nova origem', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Integração ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                ],
                rows: _origens.map((o) => DataRow(cells: [
                  DataCell(Text(o.name, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(o.type, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(o.integrationId, style: const TextStyle(fontSize: 12))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: o.active ? const Color(0xFF22C55E).withValues(alpha: 0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(o.active ? 'Ativo' : 'Inativo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: o.active ? const Color(0xFF22C55E) : Colors.grey)),
                  )),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ EQUIPES ═══
  Widget _buildEquipesTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Nova equipe', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 16),
          DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            columns: const [
              DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              DataColumn(label: Text('Integração ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Equipe Matriz', style: TextStyle(fontSize: 13))),
                DataCell(Text('29549', style: TextStyle(fontSize: 13))),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  // ═══ AGÊNCIAS ═══
  Widget _buildAgenciasTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Nova agência', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 16),
          DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            columns: const [
              DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              DataColumn(label: Text('Integração ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Matriz', style: TextStyle(fontSize: 13))),
                DataCell(Text('28517', style: TextStyle(fontSize: 13))),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  // ═══ HELPERS ═══
  Widget _emptyState({required IconData icon, required String message, required String buttonLabel, required VoidCallback onTap}) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 16),
            label: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }

  void _showNewTagDialog() {
    final nameCtrl = TextEditingController();
    int selectedColor = 0;
    final colors = [const Color(0xFFB8860B), const Color(0xFF1E40AF), const Color(0xFF166534), const Color(0xFFDC2626), const Color(0xFF581C87)];
    final modules = {'Condomínios': false, 'Gestão de locação': false, 'Gestão de vendas': false, 'Imóveis': false, 'Pessoas': false};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Row(children: [Icon(Icons.label_outline, size: 20), SizedBox(width: 8), Text('Nova etiqueta', style: TextStyle(fontSize: 16))]),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nome *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: InputDecoration(hintText: 'Nome', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
                const SizedBox(height: 14),
                const Text('Cor *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: colors.asMap().entries.map((e) => GestureDetector(
                  onTap: () => setDialog(() => selectedColor = e.key),
                  child: Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: e.value, borderRadius: BorderRadius.circular(6), border: selectedColor == e.key ? Border.all(color: Colors.black, width: 2) : null)),
                )).toList()),
                const SizedBox(height: 14),
                const Text('Módulos *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ...modules.entries.map((e) => CheckboxListTile(title: Text(e.key, style: const TextStyle(fontSize: 13)), value: e.value, dense: true, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, onChanged: (v) => setDialog(() => modules[e.key] = v ?? false))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}


class _OrigemData {
  final String name;
  final String type;
  final String integrationId;
  final bool active;
  const _OrigemData(this.name, this.type, this.integrationId, this.active);
}

const _origens = [
  _OrigemData('123i', 'Padrão', '2400155', false),
  _OrigemData('321 Achei', 'Padrão', '2400143', false),
  _OrigemData('62imoveis', 'Padrão', '2400139', false),
  _OrigemData('Achou Mudou!', 'Padrão', '2400094', false),
  _OrigemData('Apto', 'Padrão', '2400102', false),
  _OrigemData('Attria', 'Padrão', '2400093', false),
  _OrigemData('Barbada Classe A', 'Padrão', '2400149', false),
  _OrigemData('Buskaza', 'Padrão', '2400097', false),
  _OrigemData('Casa Mineira', 'Padrão', '2400129', false),
  _OrigemData('Casa Temporada', 'Padrão', '2400113', false),
  _OrigemData('CasaCarro', 'Padrão', '2400116', false),
  _OrigemData('Casafy', 'Padrão', '2400096', false),
  _OrigemData('Chat', 'Padrão', '2400082', false),
  _OrigemData('Chave Fácil', 'Padrão', '2400091', false),
  _OrigemData('Chaves na Mão', 'Padrão', '2400165', false),
  _OrigemData('Chãozão', 'Padrão', '2400122', false),
  _OrigemData('Classificados Joinville', 'Padrão', '2400150', false),
  _OrigemData('Clic Litoral Sul', 'Padrão', '2400156', false),
  _OrigemData('Cliquei Mudei', 'Padrão', '2400090', false),
  _OrigemData('Compre & Alugue Agora', 'Padrão', '2400117', false),
  _OrigemData('DF Imóveis', 'Padrão', '2400111', false),
  _OrigemData('Dream Casa', 'Padrão', '2400092', false),
  _OrigemData('E-mail marketing', 'Padrão', '2400067', false),
  _OrigemData('Easy Imóveis', 'Padrão', '2400118', false),
  _OrigemData('Eu Corretor', 'Padrão', '2400153', false),
  _OrigemData('Expo Imóvel', 'Padrão', '2400157', false),
  _OrigemData('Facebook', 'Padrão', '2400107', false),
  _OrigemData('Facebook Ads', 'Padrão', '2400068', false),
  _OrigemData('Google Ads', 'Padrão', '2400069', false),
  _OrigemData('GreatPages', 'Padrão', '2400083', false),
  _OrigemData('Grupo OLX | Viva Real, Zap, OLX', 'Padrão', '2400126', false),
  _OrigemData('Guia Imóvel & Cia', 'Padrão', '2400103', false),
  _OrigemData('Guia de Imóveis SP', 'Padrão', '2400088', false),
  _OrigemData('Homer', 'Padrão', '2400098', false),
  _OrigemData('Immobile', 'Padrão', '2400140', false),
  _OrigemData('Imovago', 'Padrão', '2400109', false),
  _OrigemData('Imovelpratico', 'Padrão', '2400131', false),
  _OrigemData('Imovelweb', 'Padrão', '2400130', false),
  _OrigemData('ImovoMAPP', 'Padrão', '2400099', false),
  _OrigemData('Imóveis Global', 'Padrão', '2400087', false),
  _OrigemData('Imóveis Pra Negócio', 'Padrão', '2400106', false),
  _OrigemData('Imóveis na Serra', 'Padrão', '2400104', false),
  _OrigemData('Imóveis-SC', 'Padrão', '2400158', false),
  _OrigemData('Imóvel Guide', 'Padrão', '2400151', false),
  _OrigemData('Indicação', 'Padrão', '2400072', false),
  _OrigemData('Instagram', 'Padrão', '2400070', false),
  _OrigemData('JamesEdition', 'Padrão', '2400124', false),
  _OrigemData('Jornal', 'Padrão', '2400071', false),
  _OrigemData('Kazaki', 'Padrão', '2400154', false),
  _OrigemData('Koort Imóveis', 'Padrão', '2400084', false),
  _OrigemData('La Gran Inmobiliaria', 'Padrão', '2400089', false),
  _OrigemData('Leadfy', 'Padrão', '2400142', false),
  _OrigemData('Leasy', 'Padrão', '2400127', false),
  _OrigemData('LinkedIn', 'Padrão', '2400073', false),
  _OrigemData('Localize Mais', 'Padrão', '2400128', false),
  _OrigemData('Loft', 'Padrão', '2400137', false),
  _OrigemData('Lugar Certo', 'Padrão', '2400144', false),
  _OrigemData('LuxuryEstate', 'Padrão', '2400159', false),
  _OrigemData('MGF Imóveis', 'Padrão', '2400148', false),
  _OrigemData('Mappo', 'Padrão', '2400120', false),
  _OrigemData('Moving', 'Padrão', '2400105', false),
  _OrigemData('OLX', 'Padrão', '2400101', false),
  _OrigemData('Olho Mágico', 'Padrão', '2400114', false),
  _OrigemData('Outros', 'Padrão', '2400074', false),
  _OrigemData('PIM 360', 'Padrão', '2400136', false),
  _OrigemData('Painel Imobiliário', 'Padrão', '2400095', false),
  _OrigemData('Pesca Imóveis', 'Padrão', '2400085', false),
  _OrigemData('Placa', 'Padrão', '2400075', false),
  _OrigemData('Portal Imóveis Brasil', 'Padrão', '2400134', false),
  _OrigemData('Portal Imóveis Curitiba', 'Padrão', '2400135', false),
  _OrigemData('Portal Imóveis Litoral do Paraná', 'Padrão', '2400133', false),
  _OrigemData('Portal Imóveis Paraná', 'Padrão', '2400132', false),
  _OrigemData('Procura-se Imóvel', 'Padrão', '2400162', false),
  _OrigemData('Procure Imóvel', 'Padrão', '2400160', false),
  _OrigemData('Properstar (ListGlobally)', 'Padrão', '2400112', false),
  _OrigemData('Prospecção', 'Padrão', '2400076', false),
  _OrigemData('Quinto Andar', 'Padrão', '2400138', false),
  _OrigemData('RD Station - Integração', 'Padrão', '2400168', false),
  _OrigemData('Rede Inova Imóveis', 'Padrão', '2400119', false),
  _OrigemData('RoteMix', 'Padrão', '2400152', false),
  _OrigemData('RuaDois', 'Padrão', '2400125', false),
  _OrigemData('SPImóvel', 'Padrão', '2400161', false),
  _OrigemData('SUB100', 'Padrão', '2400100', false),
  _OrigemData('Sede', 'Padrão', '2400077', false),
  _OrigemData('Site - gustavo-27587', 'Padrão', '2400169', true),
  _OrigemData('Telefone', 'Padrão', '2400078', false),
  _OrigemData('Temporada Livre', 'Padrão', '2400145', false),
  _OrigemData('Terraz', 'Padrão', '2400167', false),
  _OrigemData('Twitter', 'Padrão', '2400079', false),
  _OrigemData('Vale do Paraíba Imóveis', 'Padrão', '2400163', false),
  _OrigemData('Vem pra casa', 'Padrão', '2400146', false),
  _OrigemData('Viveendo Bem', 'Padrão', '2400108', false),
  _OrigemData('VrSync', 'Padrão', '2400121', false),
  _OrigemData('Web Escritórios', 'Padrão', '2400147', false),
  _OrigemData('WebImóveis', 'Padrão', '2400141', false),
  _OrigemData('WhatsApp', 'Padrão', '2400080', false),
  _OrigemData('Wimóveis', 'Padrão', '2400164', false),
  _OrigemData('Youtube', 'Padrão', '2400081', false),
  _OrigemData('iGlobal', 'Padrão', '2400086', false),
  _OrigemData('site - jetlar.com', 'Padrão', '2400166', true),
  _OrigemData('Órulo - Exclusividades', 'Padrão', '2400110', false),
];

import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemDocsPage extends StatefulWidget {
  const CrmSystemDocsPage({super.key});

  @override
  State<CrmSystemDocsPage> createState() => _CrmSystemDocsPageState();
}

class _CrmSystemDocsPageState extends State<CrmSystemDocsPage> {
  final _searchCtrl = TextEditingController();
  String? _module;
  String? _type;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Modelos de Documento'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('MODELOS DE DOCUMENTO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 20),
            // Botão Novo
            OutlinedButton.icon(
              onPressed: _showNewDocDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Novo', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 20),
            // Filtros
            _buildFilters(),
            const SizedBox(height: 24),
            // Documentos
            _buildDocuments(),
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
                TextButton(onPressed: () {}, child: const Text('Salvar filtro', style: TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Busca
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Busque pelo título do documento',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                // Módulo
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _module,
                    decoration: InputDecoration(
                      labelText: 'Módulo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Escolha um tipo')),
                      DropdownMenuItem(value: 'alugueis', child: Text('Gestão de aluguéis')),
                    ],
                    onChanged: (v) => setState(() => _module = v),
                  ),
                ),
                // Tipo
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Escolha um tipo')),
                      DropdownMenuItem(value: 'contrato', child: Text('Contrato')),
                      DropdownMenuItem(value: 'intermediacao', child: Text('Intermediação')),
                      DropdownMenuItem(value: 'procuracao', child: Text('Procuração')),
                      DropdownMenuItem(value: 'vistoria', child: Text('Vistoria')),
                    ],
                    onChanged: (v) => setState(() => _type = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocuments() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 18),
                const SizedBox(width: 8),
                const Text('Documentos (0)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 32),
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Não encontramos nenhum modelo de documento cadastrado', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 4),
            Text('Deseja gerar um novo modelo?', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _showNewDocDialog,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Novo modelo'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNewDocDialog() {
    String? dialogModule = 'alugueis';
    String? dialogType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.description_outlined, size: 20),
            SizedBox(width: 8),
            Text('Novo modelo de documento', style: TextStyle(fontSize: 16)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Módulo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: dialogModule,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: const [
                  DropdownMenuItem(value: 'alugueis', child: Text('Gestão de aluguéis')),
                ],
                onChanged: (v) => setDialog(() => dialogModule = v),
              ),
              const SizedBox(height: 14),
              const Text('Tipo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: dialogType,
                decoration: InputDecoration(hintText: 'Selecionar', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Selecionar')),
                  DropdownMenuItem(value: 'contrato', child: Text('Contrato')),
                  DropdownMenuItem(value: 'intermediacao', child: Text('Intermediação')),
                  DropdownMenuItem(value: 'procuracao', child: Text('Procuração')),
                  DropdownMenuItem(value: 'vistoria', child: Text('Vistoria')),
                ],
                onChanged: (v) => setDialog(() => dialogType = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: const Text('Avançar'),
            ),
          ],
        ),
      ),
    );
  }
}

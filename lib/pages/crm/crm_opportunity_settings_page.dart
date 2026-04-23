import 'package:flutter/material.dart';
import '../../theme.dart';
import 'crm_edit_funnel_page.dart';

class CrmOpportunitySettingsPage extends StatefulWidget {
  const CrmOpportunitySettingsPage({super.key});

  @override
  State<CrmOpportunitySettingsPage> createState() => _CrmOpportunitySettingsPageState();
}

class _CrmOpportunitySettingsPageState extends State<CrmOpportunitySettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final List<_LossReason> _reasons = [
    _LossReason('Financiamento não aprovado', 'Venda, Locação, Temporada'),
    _LossReason('Negociou com terceiros', 'Venda, Locação, Temporada'),
    _LossReason('Desistiu do negócio', 'Venda, Locação, Temporada'),
    _LossReason('Não gostou de nenhum imóvel', 'Venda, Locação, Temporada'),
    _LossReason('Não gostou do atendimento', 'Venda, Locação, Temporada'),
    _LossReason('Proprietário desistiu', 'Venda, Locação, Temporada'),
    _LossReason('Valores acima do esperado', 'Venda, Locação, Temporada'),
    _LossReason('Perdido contato com o cliente', 'Venda, Locação, Temporada'),
    _LossReason('Cliente pesquisando', 'Venda, Locação, Temporada'),
    _LossReason('Outros', 'Venda, Locação, Temporada'),
    _LossReason('Contatar futuramente', 'Venda, Locação, Temporada'),
    _LossReason('Dados de contato inválido', 'Venda, Locação, Temporada'),
    _LossReason('Sem contato', 'Venda, Locação, Temporada'),
    _LossReason('Desacordo de contrato', 'Venda, Locação, Temporada'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _addReason() {
    final nameCtrl = TextEditingController();
    final funnels = <String>{'Venda', 'Locação', 'Temporada'};
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Novo motivo de perda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: _inputDeco('Nome do motivo'), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 12),
        const Align(alignment: Alignment.centerLeft, child: Text('Atribuir aos funis:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ...['Venda', 'Locação', 'Temporada'].map((f) => CheckboxListTile(
          dense: true, title: Text(f, style: const TextStyle(fontSize: 13)),
          value: funnels.contains(f), activeColor: AppTheme.primaryBlue,
          onChanged: (v) => setDlg(() { v! ? funnels.add(f) : funnels.remove(f); }),
        )),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          if (nameCtrl.text.trim().isNotEmpty) {
            setState(() => _reasons.add(_LossReason(nameCtrl.text.trim(), funnels.join(', '))));
            Navigator.pop(ctx);
          }
        }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Adicionar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Configurações'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () { Navigator.pop(context); Navigator.pop(context); },
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('OPORTUNIDADES', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('CONFIGURAÇÕES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),

          // Tabs
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Column(children: [
              TabBar(
                controller: _tabCtrl,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryBlue,
                tabs: const [
                  Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.settings_outlined, size: 16), SizedBox(width: 6), Text('Configurações gerais')])),
                  Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.autorenew, size: 16), SizedBox(width: 6), Text('Funis de oportunidades')])),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: TabBarView(controller: _tabCtrl, children: [
                  _buildGeneralTab(),
                  _buildFunnelsTab(),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ==================== Tab: Configurações gerais ====================
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.list_alt, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Text('Motivos de perda (${_reasons.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          IconButton(
            onPressed: _addReason,
            icon: const Icon(Icons.add, size: 20),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[300]!)),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
          child: const Row(children: [
            Expanded(flex: 3, child: Text('Motivo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(flex: 3, child: Text('Atribuído aos funis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            SizedBox(width: 40),
          ]),
        ),
        // Rows
        ..._reasons.asMap().entries.map((entry) {
          final idx = entry.key;
          final r = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(border: Border(
              left: BorderSide(color: Colors.grey[200]!),
              right: BorderSide(color: Colors.grey[200]!),
              bottom: BorderSide(color: Colors.grey[200]!),
            )),
            child: Row(children: [
              Expanded(flex: 3, child: Text(r.reason, style: const TextStyle(fontSize: 13))),
              Expanded(flex: 3, child: Text(r.funnels, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
              SizedBox(width: 40, child: IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                onPressed: () => setState(() => _reasons.removeAt(idx)),
              )),
            ]),
          );
        }),
      ]),
    );
  }

  // ==================== Tab: Funis de oportunidades ====================
  Widget _buildFunnelsTab() {
    final funnels = [
      _Funnel('Funil de Venda', 0, '14/04/2026'),
      _Funnel('Funil de Locação', 0, '14/04/2026'),
      _Funnel('Funil de Temporada', 0, '14/04/2026'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.autorenew, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          const Text('Funis de Oportunidades', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
        const SizedBox(height: 16),
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
          child: const Row(children: [
            Expanded(flex: 3, child: Text('Nome', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('Oportunidades', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('Atualizado em', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            SizedBox(width: 40),
          ]),
        ),
        // Rows
        ...funnels.map((f) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(border: Border(
            left: BorderSide(color: Colors.grey[200]!),
            right: BorderSide(color: Colors.grey[200]!),
            bottom: BorderSide(color: Colors.grey[200]!),
          )),
          child: Row(children: [
            Expanded(flex: 3, child: Text(f.name, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text('${f.opportunities}', style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
            Expanded(flex: 2, child: Text(f.updatedAt, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
            SizedBox(width: 40, child: IconButton(
              icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey[400]),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CrmEditFunnelPage(funnelName: f.name))),
            )),
          ]),
        )),
        // Fim da lista
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(
            left: BorderSide(color: Colors.grey[200]!),
            right: BorderSide(color: Colors.grey[200]!),
            bottom: BorderSide(color: Colors.grey[200]!),
          ), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))),
          child: Center(child: Text('Fim da lista', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic))),
        ),
      ]),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
  );
}

class _LossReason {
  final String reason;
  final String funnels;
  _LossReason(this.reason, this.funnels);
}

class _Funnel {
  final String name;
  final int opportunities;
  final String updatedAt;
  _Funnel(this.name, this.opportunities, this.updatedAt);
}

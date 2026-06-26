import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemWebhooksPage extends StatefulWidget {
  const CrmSystemWebhooksPage({super.key});

  @override
  State<CrmSystemWebhooksPage> createState() => _CrmSystemWebhooksPageState();
}

class _CrmSystemWebhooksPageState extends State<CrmSystemWebhooksPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Webhooks'), backgroundColor: AppTheme.primaryBlue),
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
              const Text('WEBHOOKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 20),
            // Botão Novo
            ElevatedButton.icon(
              onPressed: _showNewWebhookDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Novo Webhook', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 20),
            // Filtros
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.filter_list, size: 18),
                      SizedBox(width: 8),
                      Text('Filtros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Busca',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      OutlinedButton(onPressed: () => _searchCtrl.clear(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Limpar')),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Filtrar')),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Webhooks table
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(children: [
                      Icon(Icons.webhook_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Webhooks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 16),
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      color: Colors.grey.shade50,
                      child: const Row(children: [
                        Expanded(child: Text('Nome', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        SizedBox(width: 100, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                      ]),
                    ),
                    const SizedBox(height: 32),
                    // Empty state
                    Icon(Icons.webhook_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Nenhum webhook encontrado', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _showNewWebhookDialog, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Novo webhook')),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewWebhookDialog() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _NewWebhookPage()));
  }
}

class _NewWebhookPage extends StatefulWidget {
  const _NewWebhookPage();

  @override
  State<_NewWebhookPage> createState() => _NewWebhookPageState();
}

class _NewWebhookPageState extends State<_NewWebhookPage> {
  bool _active = true;
  String? _event;
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _auth = 'Nenhum';

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Novo Webhook'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(children: [
              GestureDetector(onTap: () { Navigator.pop(context); Navigator.pop(context); },
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Text('WEBHOOKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('NOVO WEBHOOK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF232845))),
            ]),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.webhook_outlined, size: 20, color: Color(0xFF232845)),
                      SizedBox(width: 8),
                      Text('Novo webhook', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 24),
                    // Status + Evento + URL
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Row(children: [
                              Switch(value: _active, onChanged: (v) => setState(() => _active = v), activeColor: AppTheme.primaryBlue),
                              Text(_active ? 'Ativo' : 'Inativo', style: const TextStyle(fontSize: 12)),
                            ]),
                          ],
                        ),
                        // Evento
                        SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Evento'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _event,
                                decoration: _deco('Selecione um evento'),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Selecione um evento')),
                                  DropdownMenuItem(value: 'lead_created', child: Text('Lead criado')),
                                  DropdownMenuItem(value: 'lead_updated', child: Text('Lead atualizado')),
                                  DropdownMenuItem(value: 'property_created', child: Text('Imóvel criado')),
                                  DropdownMenuItem(value: 'property_updated', child: Text('Imóvel atualizado')),
                                  DropdownMenuItem(value: 'proposal_created', child: Text('Proposta criada')),
                                  DropdownMenuItem(value: 'contract_created', child: Text('Contrato criado')),
                                ],
                                onChanged: (v) => setState(() => _event = v),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                        // URL
                        SizedBox(
                          width: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('URL'),
                              const SizedBox(height: 6),
                              TextField(controller: _urlCtrl, decoration: _deco('https://exemplo.com.br')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Nome + Autenticação
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Nome'),
                              const SizedBox(height: 6),
                              TextField(controller: _nameCtrl, decoration: _deco('Digite o nome do webhook')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _requiredLabel('Autenticação'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _auth,
                                decoration: _deco(''),
                                items: const [
                                  DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
                                  DropdownMenuItem(value: 'Basic', child: Text('Basic')),
                                  DropdownMenuItem(value: 'Bearer', child: Text('Bearer')),
                                  DropdownMenuItem(value: 'API Key', child: Text('API Key')),
                                  DropdownMenuItem(value: 'HMAC', child: Text('HMAC')),
                                ],
                                onChanged: (v) => setState(() => _auth = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Descrição
                    const Text('Descrição', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _descCtrl, maxLines: 3, decoration: _deco('Descreva o webhook')),
                    const SizedBox(height: 24),
                    // Botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Cancelar')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Webhook salvo!'), backgroundColor: Colors.green));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requiredLabel(String text) {
    return RichText(text: TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87), children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]));
  }

  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10));
}

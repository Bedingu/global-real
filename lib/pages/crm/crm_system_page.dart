import 'package:flutter/material.dart';
import '../../theme.dart';
import 'crm_system_config_page.dart';
import 'crm_system_tags_page.dart';
import 'crm_system_holidays_page.dart';
import 'crm_system_users_page.dart';
import 'crm_system_docs_page.dart';
import 'crm_system_xml_page.dart';
import 'crm_system_webhooks_page.dart';

class CrmSystemPage extends StatelessWidget {
  const CrmSystemPage({super.key});

  static const _items = [
    _SystemItem('Configurações', Icons.settings_outlined, 'Configurações gerais do sistema'),
    _SystemItem('Etiquetas e origens', Icons.label_outlined, 'Gerencie etiquetas e origens de leads'),
    _SystemItem('Feriados', Icons.event_outlined, 'Cadastre feriados para o calendário'),
    _SystemItem('Usuários e grupos', Icons.group_outlined, 'Gerencie usuários, permissões e equipes'),
    _SystemItem('Modelos de Doc', Icons.description_outlined, 'Modelos de contratos e documentos'),
    _SystemItem('Importador XML', Icons.upload_file_outlined, 'Importe imóveis via XML'),
    _SystemItem('Webhooks', Icons.webhook_outlined, 'Configure webhooks para integrações'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Sistema'),
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
              const Text('SISTEMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 24),
            // Cards
            ...(_items.map((item) => _systemTile(context, item))),
          ],
        ),
      ),
    );
  }

  Widget _systemTile(BuildContext context, _SystemItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (item.label == 'Configurações') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemConfigPage()));
            } else if (item.label == 'Etiquetas e origens') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemTagsPage()));
            } else if (item.label == 'Feriados') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemHolidaysPage()));
            } else if (item.label == 'Usuários e grupos') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemUsersPage()));
            } else if (item.label == 'Modelos de Doc') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemDocsPage()));
            } else if (item.label == 'Importador XML') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemXmlPage()));
            } else if (item.label == 'Webhooks') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmSystemWebhooksPage()));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => _SystemDetailPage(title: item.label)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppTheme.primaryBlue, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemItem {
  final String label;
  final IconData icon;
  final String description;
  const _SystemItem(this.label, this.icon, this.description);
}

// ═══ Página de detalhe genérica ═══
class _SystemDetailPage extends StatelessWidget {
  final String title;
  const _SystemDetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(title), backgroundColor: AppTheme.primaryBlue),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Em construção.\nEm breve você terá acesso a esta funcionalidade.', style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

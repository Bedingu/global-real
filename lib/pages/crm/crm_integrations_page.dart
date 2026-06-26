import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmIntegrationsPage extends StatefulWidget {
  const CrmIntegrationsPage({super.key});

  @override
  State<CrmIntegrationsPage> createState() => _CrmIntegrationsPageState();
}

class _CrmIntegrationsPageState extends State<CrmIntegrationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _integrations = [
    _IntegrationItem(
      name: 'Facebook Leads Ads',
      description: 'Simplifique o processo de geração de leads e aumenta a eficácia das campanhas.',
      icon: Icons.facebook,
      color: Color(0xFF1877F2),
      isActive: false,
    ),
    _IntegrationItem(
      name: 'RD Station',
      description: 'Capte, gerencie seus leads e converta visitantes em clientes de forma eficiente.',
      icon: Icons.hub,
      color: Color(0xFF00BFA5),
      isActive: false,
    ),
    _IntegrationItem(
      name: 'Zapier',
      description: 'Automação entre diferentes aplicativos, simplificando a integração e a produtividade.',
      icon: Icons.electric_bolt,
      color: Color(0xFFFF4A00),
      isActive: false,
    ),
    _IntegrationItem(
      name: 'WhatsApp Business',
      description: 'Conecte seu WhatsApp Business para receber e responder leads diretamente.',
      icon: Icons.chat,
      color: Color(0xFF25D366),
      isActive: false,
    ),
    _IntegrationItem(
      name: 'Google Ads',
      description: 'Importe leads gerados por campanhas do Google Ads automaticamente.',
      icon: Icons.ads_click,
      color: Color(0xFF4285F4),
      isActive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Integrações'),
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
              const Text('INTEGRAÇÕES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryBlue,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: 'Integrações (${_integrations.length})'),
                const Tab(text: 'Chaves API (0)'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildIntegrationsTab(),
                _buildApiKeysTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _integrations.map((item) => _integrationCard(item)).toList(),
      ),
    );
  }

  Widget _integrationCard(_IntegrationItem item) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const Spacer(),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isActive ? const Color(0xFF22C55E).withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.isActive ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.isActive ? const Color(0xFF22C55E) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 16),
          // Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Integração ${item.name} em breve!'), duration: const Duration(seconds: 2)),
                );
              },
              icon: Icon(item.isActive ? Icons.settings : Icons.power, size: 16),
              label: Text(item.isActive ? 'Configurar' : 'Ativar Integração', style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vpn_key_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhuma chave API cadastrada.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova chave API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntegrationItem {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _IntegrationItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isActive,
  });
}

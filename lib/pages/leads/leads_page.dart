import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/market_lead.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/lead_scoring_service.dart';
import '../../services/payment_service.dart';
import '../../theme.dart';
import '../../widgets/paywall/paywall_modal.dart';
import 'chat_page.dart';
import 'lead_score_detail_page.dart';
import 'lead_funnel_page.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  String _filterMarket = 'all';
  List<MarketLead> _leads = [];
  bool _loading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadLeads();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final premium = await AuthService.isPremiumUser();
    if (!mounted) return;
    setState(() => _isPremium = premium);
  }

  void _openPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallModal(
        onSubscribe: (planType) {
          final priceId = planType == 'annual'
              ? "price_1SqeRLIHf8Ey84xrDd51z4UA"
              : "price_xxx";
          PaymentService.startCheckout(priceId);
        },
      ),
    );
  }

  Future<void> _loadLeads() async {
    setState(() => _loading = true);
    final market = _filterMarket == 'all' ? null : _filterMarket;
    final leads = await ChatService.fetchLeads(market: market);
    if (!mounted) return;
    setState(() {
      _leads = leads;
      _loading = false;
    });
  }

  Color _scoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new': return Colors.blue;
      case 'contacted': return Colors.orange;
      case 'qualified': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Future<void> _openWhatsApp(MarketLead lead) async {
    final phone = lead.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final text = Uri.encodeComponent(
      'Olá ${lead.name}, tudo bem? Sou assessor da Global Real Estate. '
      'Vi que você tem interesse em ${lead.interest.isNotEmpty ? lead.interest : "investimentos imobiliários"}. '
      'Posso te ajudar?',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Registrar interação + marcar como contatado
      await LeadScoringService.trackEvent(lead.id, LeadEvent.clickWhatsapp);
      await ChatService.updateLeadStatus(lead.id, 'contacted');
      _loadLeads();
    }
  }

  void _openChat(MarketLead lead) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(lead: lead)),
    ).then((_) => _loadLeads());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_kanban_outlined),
            tooltip: 'Funil de Vendas',
            onPressed: () {
              if (!_isPremium) {
                _openPaywall();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadFunnelPage()),
              ).then((_) => _loadLeads());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de mercado
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _marketChip('all', 'Todos'),
                const SizedBox(width: 8),
                _marketChip('sao_paulo', '🇧🇷 São Paulo'),
                const SizedBox(width: 8),
                _marketChip('florida', '🇺🇸 Florida'),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _leads.isEmpty
                    ? const Center(child: Text('Nenhum lead encontrado'))
                    : RefreshIndicator(
                        onRefresh: _loadLeads,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _leads.length,
                          itemBuilder: (_, i) => _leadCard(_leads[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _marketChip(String value, String label) {
    final selected = _filterMarket == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(
        fontSize: 12,
        color: selected ? Colors.white : Colors.black87,
      )),
      selected: selected,
      selectedColor: AppTheme.primaryBlue,
      onSelected: (_) {
        setState(() => _filterMarket = value);
        _loadLeads();
      },
    );
  }

  Widget _leadCard(MarketLead lead) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nome + score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lead.name, style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16,
                      )),
                      const SizedBox(height: 2),
                      Text(
                        '${lead.marketLabel} · ${lead.interest}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // AI Score
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LeadScoreDetailPage(lead: lead)),
                  ).then((_) => _loadLeads()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _scoreColor(lead.aiScore).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: _scoreColor(lead.aiScore)),
                        const SizedBox(width: 4),
                        Text(
                          '${lead.aiScore}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _scoreColor(lead.aiScore),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // AI Summary
            if (lead.aiSummary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lead.aiSummary,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Alerta de follow-up pendente
            if (lead.status == 'new' && DateTime.now().difference(lead.createdAt).inHours >= 24)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        'Sem contato há ${DateTime.now().difference(lead.createdAt).inHours}h — follow-up automático enviado',
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            // Status + budget
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(lead.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lead.statusLabel,
                    style: TextStyle(fontSize: 11, color: _statusColor(lead.status), fontWeight: FontWeight.w600),
                  ),
                ),
                if (lead.budget != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'R\$ ${lead.budget!.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
                const Spacer(),
                // Botão WhatsApp
                if (lead.phone.isNotEmpty)
                  IconButton(
                    onPressed: () => _openWhatsApp(lead),
                    icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                    tooltip: 'WhatsApp',
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                // Botão Chat no app
                IconButton(
                  onPressed: () => _openChat(lead),
                  icon: const Icon(Icons.message_outlined, color: AppTheme.primaryBlue),
                  tooltip: 'Chat no app',
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

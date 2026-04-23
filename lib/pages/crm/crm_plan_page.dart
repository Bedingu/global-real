import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../theme.dart';

class CrmPlanPage extends StatefulWidget {
  const CrmPlanPage({super.key});

  @override
  State<CrmPlanPage> createState() => _CrmPlanPageState();
}

class _CrmPlanPageState extends State<CrmPlanPage> {
  bool _isPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final premium = await AuthService.isPremiumUser();
    if (!mounted) return;
    setState(() { _isPremium = premium; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Meu Plano'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                      const Text('MEU PLANO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status atual
                  _buildCurrentPlan(),
                  const SizedBox(height: 32),

                  // Planos disponíveis
                  const Text('Escolha seu plano', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Desbloqueie todo o potencial do CRM imobiliário', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _planCard(
                              title: 'Starter',
                              price: 'Grátis',
                              period: '',
                              color: Colors.grey,
                              features: _starterFeatures,
                              isCurrent: !_isPremium,
                              onSelect: null,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _planCard(
                              title: 'Profissional',
                              price: 'R\$ 197',
                              period: '/mês',
                              color: AppTheme.primaryBlue,
                              features: _proFeatures,
                              isCurrent: false,
                              isPopular: true,
                              onSelect: () => _subscribe('monthly'),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _planCard(
                              title: 'Anual',
                              price: 'R\$ 1.970',
                              period: '/ano',
                              subtitle: 'Economia de R\$ 394 (2 meses grátis)',
                              color: const Color(0xFFF59E0B),
                              features: _annualFeatures,
                              isCurrent: _isPremium,
                              onSelect: _isPremium ? null : () => _subscribe('annual'),
                            )),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _planCard(title: 'Starter', price: 'Grátis', period: '', color: Colors.grey, features: _starterFeatures, isCurrent: !_isPremium, onSelect: null),
                          const SizedBox(height: 16),
                          _planCard(title: 'Profissional', price: 'R\$ 197', period: '/mês', color: AppTheme.primaryBlue, features: _proFeatures, isCurrent: false, isPopular: true, onSelect: () => _subscribe('monthly')),
                          const SizedBox(height: 16),
                          _planCard(title: 'Anual', price: 'R\$ 1.970', period: '/ano', subtitle: 'Economia de R\$ 394 (2 meses grátis)', color: const Color(0xFFF59E0B), features: _annualFeatures, isCurrent: _isPremium, onSelect: _isPremium ? null : () => _subscribe('annual')),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentPlan() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _isPremium ? const Color(0xFFF59E0B).withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isPremium ? Icons.workspace_premium : Icons.person_outline,
                color: _isPremium ? const Color(0xFFF59E0B) : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plano atual: ${_isPremium ? "Premium" : "Starter (Grátis)"}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPremium
                        ? 'Você tem acesso completo a todas as funcionalidades.'
                        : 'Você está no plano gratuito. Faça upgrade para desbloquear o CRM completo.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (_isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Ativo', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required String period,
    String? subtitle,
    required Color color,
    required List<String> features,
    required bool isCurrent,
    bool isPopular = false,
    VoidCallback? onSelect,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      elevation: isPopular ? 4 : 0,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                    if (period.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 2),
                        child: Text(period, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.green[600], fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: color),
                      const SizedBox(width: 10),
                      Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: isCurrent
                      ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Plano atual'),
                        )
                      : ElevatedButton(
                          onPressed: onSelect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: color == const Color(0xFFF59E0B) ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(onSelect != null ? 'Assinar agora' : 'Em breve'),
                        ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  void _subscribe(String planType) {
    final priceId = planType == 'annual'
        ? "price_1SqeRLIHf8Ey84xrDd51z4UA"
        : "price_xxx"; // TODO: substituir pelo price ID mensal real
    PaymentService.startCheckout(priceId);
  }

  static const _starterFeatures = [
    'Catálogo de empreendimentos',
    'Busca e filtros básicos',
    'Favoritos',
    'Câmbio em tempo real',
    'Até 10 leads',
  ];

  static const _proFeatures = [
    'Tudo do Starter +',
    'CRM completo (Imóveis, Propostas, Contratos)',
    'Funil de vendas Kanban',
    'Lead Scoring com IA',
    'Chat + WhatsApp integrados',
    'Follow-up automático',
    'Calculadora de investimentos',
    'Simulador de fração',
    'Relatórios de performance',
    'Leads ilimitados',
  ];

  static const _annualFeatures = [
    'Tudo do Profissional +',
    '2 meses grátis (pague 10, use 12)',
    'Suporte prioritário',
    'Acesso antecipado a novas funcionalidades',
    'Match Imobiliário com IA (em breve)',
    'Dashboard de performance avançado',
  ];
}

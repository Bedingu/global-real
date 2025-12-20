import 'package:flutter/material.dart';
import 'theme.dart';
import 'generated/app_localizations.dart';
import 'models/investment.dart';
import 'services/auth_service.dart';
import 'services/investment_service.dart';
import 'public_home_page.dart';
import 'widgets/return_chart.dart';

/// ===============================
/// DASHBOARD
/// ===============================
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(t.dashboard_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicHomePage(
                    onChangeLanguage: (_) {},
                  ),
                ),
                    (_) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Investment>>(
        future: InvestmentService.fetchInvestments(),
        builder: (context, snapshot) {
          /// ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ Erro real
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            );
          }

          /// ⚠️ Sem dados
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum investimento encontrado'),
            );
          }

          final investments = snapshot.data!;
          final grouped = _groupByLocation(investments);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _MetricCard(
                title: t.total_assets,
                value: _formatCurrency(
                  _calculateTotal(investments),
                  'BRL',
                ),
              ),

              const SizedBox(height: 16),

              _MetricCard(
                title: t.monthly_return,
                value: '+1,4%',
                highlight: true,
              ),

              const SizedBox(height: 16),

              /// 📈 Gráfico
              ReturnChart(),

              const SizedBox(height: 32),

              const _SummaryRow(),

              const SizedBox(height: 32),

              /// 📍 Investimentos por local
              for (final entry in grouped.entries) ...[
                _LocationHeader(title: entry.key),
                const SizedBox(height: 8),
                ...entry.value.map(
                      (inv) => _InvestmentTile(
                    name: inv.name,
                    value: _formatCurrency(inv.amount, inv.currency),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// ===============================
/// CARD DE MÉTRICA
/// ===============================
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const _MetricCard({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Colors.black12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: highlight ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// RESUMO VISUAL
/// ===============================
class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SummaryItem(label: 'Imóveis', value: '6'),
        _SummaryItem(label: 'Cidades', value: '4'),
        _SummaryItem(label: 'Países', value: '2'),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

/// ===============================
/// ITEM DE INVESTIMENTO
/// ===============================
class _InvestmentTile extends StatelessWidget {
  final String name;
  final String value;

  const _InvestmentTile({
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.apartment),
        title: Text(name),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// ===============================
/// CABEÇALHO POR LOCAL
/// ===============================
class _LocationHeader extends StatelessWidget {
  final String title;

  const _LocationHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

/// ===============================
/// AGRUPAMENTO
/// ===============================
Map<String, List<Investment>> _groupByLocation(
    List<Investment> investments,
    ) {
  final map = <String, List<Investment>>{};

  for (final inv in investments) {
    final key = '${inv.city} • ${inv.country}';
    map.putIfAbsent(key, () => []);
    map[key]!.add(inv);
  }

  return map;
}

/// ===============================
/// HELPERS
/// ===============================
String _formatCurrency(double amount, String currency) {
  switch (currency) {
    case 'USD':
      return '\$ ${amount.toStringAsFixed(2)}';
    case 'BRL':
    default:
      return 'R\$ ${amount.toStringAsFixed(2)}';
  }
}

double _calculateTotal(List<Investment> investments) {
  return investments.fold(
    0.0,
        (sum, inv) => sum + inv.amount,
  );
}

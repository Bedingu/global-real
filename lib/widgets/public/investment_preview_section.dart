import 'package:flutter/material.dart';
import '../../pages/login_page.dart';
import '../../pages/signup_page.dart';

/// Dados resumidos de cada investimento para a seção freemium
class _InvestmentPreview {
  final String name;
  final String location;
  final double aporte;
  final double priceM2Entry;
  final double priceM2Exit;
  final double roi;
  final double irr;
  final int prazoMeses;
  final double renda;

  const _InvestmentPreview({
    required this.name,
    required this.location,
    required this.aporte,
    required this.priceM2Entry,
    required this.priceM2Exit,
    required this.roi,
    required this.irr,
    required this.prazoMeses,
    required this.renda,
  });
}

/// Seção freemium de Investimentos na home pública.
/// Mostra cards resumidos com gráfico de barras simples (compra vs saída)
/// e CTA para desbloquear análise completa.
class InvestmentPreviewSection extends StatelessWidget {
  final bool isWide;
  final double contentWidth;

  const InvestmentPreviewSection({
    super.key,
    required this.isWide,
    required this.contentWidth,
  });

  // Cores consistentes com a home
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _green = Color(0xFF22C55E);
  static const _blue = Color(0xFF3B82F6);

  // Dados extraídos dos CSVs
  static const _investments = [
    _InvestmentPreview(
      name: 'Vitacon Al Barros 886',
      location: 'Alameda Barros, São Paulo',
      aporte: 1200000,
      priceM2Entry: 11900,
      priceM2Exit: 24000,
      roi: 93.7,
      irr: 26.4,
      prazoMeses: 36,
      renda: 0.8,
    ),
    _InvestmentPreview(
      name: 'Vitacon Venâncio 943',
      location: 'Rua Venâncio Aires, São Paulo',
      aporte: 1000000,
      priceM2Entry: 12614,
      priceM2Exit: 20000,
      roi: 52.3,
      irr: 15.8,
      prazoMeses: 36,
      renda: 1.0,
    ),
    _InvestmentPreview(
      name: 'Vitacon Higienópolis',
      location: 'Higienópolis, São Paulo',
      aporte: 1000000,
      priceM2Entry: 16900,
      priceM2Exit: 30000,
      roi: 70.5,
      irr: 21.3,
      prazoMeses: 36,
      renda: 1.0,
    ),
    _InvestmentPreview(
      name: 'Vitacon Nove de Julho',
      location: 'Av. Nove de Julho, São Paulo',
      aporte: 1000000,
      priceM2Entry: 12614,
      priceM2Exit: 20000,
      roi: 52.3,
      irr: 15.8,
      prazoMeses: 36,
      renda: 1.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), _bg],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
            child: Column(
              children: [
                // Header
                _buildSectionHeader(),
                const SizedBox(height: 40),

                // Gráfico comparativo de barras
                _buildComparisonChart(),
                const SizedBox(height: 40),

                // Cards dos investimentos
                _buildInvestmentCards(context),
                const SizedBox(height: 40),

                // CTA Paywall
                _buildPaywallCta(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, color: _green, size: 14),
              SizedBox(width: 6),
              Text(
                'Oportunidades de Investimento',
                style: TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Investimentos Imobiliários',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Compare os indicadores-chave e descubra qual empreendimento se encaixa no seu perfil',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  /// Gráfico de barras simples: preço de compra vs preço de saída estimada
  Widget _buildComparisonChart() {
    final maxPrice = _investments
        .map((i) => i.priceM2Exit)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: _gold, size: 20),
              SizedBox(width: 8),
              Text(
                'R\$/m² — Compra vs Saída Estimada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Legenda
          Row(
            children: [
              _legendDot(_blue, 'Preço de Entrada'),
              const SizedBox(width: 16),
              _legendDot(_green, 'Saída Estimada'),
            ],
          ),
          const SizedBox(height: 24),
          // Barras
          ..._investments.map((inv) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _barRow(inv, maxPrice),
              )),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _barRow(_InvestmentPreview inv, double maxPrice) {
    final entryWidth = inv.priceM2Entry / maxPrice;
    final exitWidth = inv.priceM2Exit / maxPrice;

    // Abreviar nome para mobile
    final shortName = inv.name.replaceAll('Vitacon ', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shortName,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        // Barra de entrada
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: entryWidth,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                'R\$ ${_formatNumber(inv.priceM2Entry)}',
                style: const TextStyle(color: _blue, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Barra de saída
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: exitWidth,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                'R\$ ${_formatNumber(inv.priceM2Exit)}',
                style: const TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvestmentCards(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _investments
          .map((inv) => SizedBox(
                width: isWide
                    ? (contentWidth - 72) / 2
                    : contentWidth - 48,
                child: _investmentCard(context, inv),
              ))
          .toList(),
    );
  }

  Widget _investmentCard(BuildContext context, _InvestmentPreview inv) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.apartment, color: _gold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.location,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Métricas principais (3 indicadores visíveis)
          Row(
            children: [
              _metricChip('ROI', '${inv.roi}%', _green),
              const SizedBox(width: 8),
              _metricChip('IRR', '${inv.irr}%', _blue),
              const SizedBox(width: 8),
              _metricChip('Prazo', '${inv.prazoMeses}m', _gold),
            ],
          ),
          const SizedBox(height: 14),

          // Linha de aporte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aporte',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Text(
                  'R\$ ${_formatCurrency(inv.aporte)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Renda mensal',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Text(
                  '${inv.renda}% a.m.',
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Mini barra de valorização
          _miniValorizationBar(inv),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  /// Mini barra mostrando a valorização percentual
  Widget _miniValorizationBar(_InvestmentPreview inv) {
    final valorization =
        ((inv.priceM2Exit - inv.priceM2Entry) / inv.priceM2Entry * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Valorização R\$/m²',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
            Text(
              '+${valorization.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (valorization / 120).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(_green),
          ),
        ),
      ],
    );
  }

  Widget _buildPaywallCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gold.withValues(alpha: 0.08),
            _card,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: _gold, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Desbloqueie a Análise Completa',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acesse fluxo de caixa detalhado, curva de vendas, VPL, payback mensal e projeções completas de cada empreendimento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: const Text(
                  'Criar Conta Grátis',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Já tenho conta'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Features list
          const Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FeatureTag(icon: Icons.show_chart, label: 'Fluxo de Caixa'),
              _FeatureTag(icon: Icons.pie_chart, label: 'Curva de Vendas'),
              _FeatureTag(icon: Icons.calculate, label: 'VPL & Payback'),
              _FeatureTag(icon: Icons.analytics, label: 'Projeções IRR'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m.toStringAsFixed(m == m.roundToDouble() ? 0 : 1)} mi';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} mil';
    }
    return value.toStringAsFixed(0);
  }
}

class _FeatureTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

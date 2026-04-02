import 'package:flutter/material.dart';
import '../../../models/private/private_simulation_result.dart';
import 'private_metric_card.dart';

class PrivateMetricsGrid extends StatelessWidget {
  final PrivateSimulationResult result;

  const PrivateMetricsGrid({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        PrivateMetricCard(
          title: 'IRR anual',
          value: '${(result.irrAnnual * 100).toStringAsFixed(2)}%',
        ),
        PrivateMetricCard(
          title: 'ROI',
          value: '${(result.roi * 100).toStringAsFixed(1)}%',
        ),
        PrivateMetricCard(
          title: 'Payback',
          value: result.paybackMonths == null
              ? '—'
              : '${result.paybackMonths} meses',
        ),
        PrivateMetricCard(
          title: 'NPV',
          value: result.npv.toStringAsFixed(0),
        ),
      ],
    );
  }
}

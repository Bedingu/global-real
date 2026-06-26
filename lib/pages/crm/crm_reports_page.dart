import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmReportsPage extends StatelessWidget {
  const CrmReportsPage({super.key});

  static const _reports = [
    _ReportItem('Geral de imóveis', Icons.apartment),
    _ReportItem('Geral de imóveis para venda', Icons.sell),
    _ReportItem('Geral de imóveis para locação', Icons.home_work),
    _ReportItem('Agenciamentos venda', Icons.handshake),
    _ReportItem('Agenciamentos locação', Icons.key),
    _ReportItem('Atualização de imóveis', Icons.update),
    _ReportItem('Geral de oportunidades', Icons.trending_up),
    _ReportItem('Oportunidades ganhas', Icons.emoji_events),
    _ReportItem('Oportunidades perdidas', Icons.thumb_down_outlined),
    _ReportItem('Conversão de oportunidades', Icons.swap_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Relatórios'),
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
              const Text('RELATÓRIOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 24),
            // Card de relatórios
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description_outlined, size: 20, color: Color(0xFF232845)),
                        SizedBox(width: 8),
                        Text('Relatórios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._reports.map((r) => _reportTile(context, r)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportTile(BuildContext context, _ReportItem report) {
    return InkWell(
      onTap: () => _openReport(context, report.label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Icon(report.icon, size: 18, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                report.label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E40AF)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _openReport(BuildContext context, String reportName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReportDetailPage(reportName: reportName),
      ),
    );
  }
}

class _ReportItem {
  final String label;
  final IconData icon;
  const _ReportItem(this.label, this.icon);
}

// ═══ Página de detalhe de cada relatório ═══
class _ReportDetailPage extends StatelessWidget {
  final String reportName;
  const _ReportDetailPage({required this.reportName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(reportName),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                reportName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Relatório em construção.\nEm breve você terá acesso aos dados completos.',
                style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

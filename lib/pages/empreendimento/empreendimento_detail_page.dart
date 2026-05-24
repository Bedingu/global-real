import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dados completos de um empreendimento para a página de detalhe
class EmpreendimentoDetail {
  final String name;
  final String location;
  final String type;
  final String area;
  final String priceFrom;
  final int totalUnits;
  final int availableUnits;
  final String? rentability;
  final String? deliveryDate;
  final String coverImageUrl;
  final List<String> galleryImageUrls;
  final String? tourUrl;
  final String? linktreeUrl;
  final String? salesTableUrl;
  final List<String> videoUrls;
  final List<String> highlights;

  const EmpreendimentoDetail({
    required this.name,
    required this.location,
    required this.type,
    required this.area,
    required this.priceFrom,
    required this.totalUnits,
    required this.availableUnits,
    this.rentability,
    this.deliveryDate,
    required this.coverImageUrl,
    this.galleryImageUrls = const [],
    this.tourUrl,
    this.linktreeUrl,
    this.salesTableUrl,
    this.videoUrls = const [],
    this.highlights = const [],
  });
}

class EmpreendimentoDetailPage extends StatelessWidget {
  final EmpreendimentoDetail empreendimento;

  const EmpreendimentoDetailPage({super.key, required this.empreendimento});

  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _green = Color(0xFF22C55E);
  static const _blue = Color(0xFF232845);

  @override
  Widget build(BuildContext context) {
    final emp = empreendimento;
    final soldPercent = emp.totalUnits > 0
        ? ((emp.totalUnits - emp.availableUnits) / emp.totalUnits * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ═══ APP BAR COM IMAGEM ═══
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _blue,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    emp.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _card),
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC0B1220)],
                      ),
                    ),
                  ),
                  // Nome no bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            emp.type,
                            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emp.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white60, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                emp.location,
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ═══ CONTEÚDO ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ MÉTRICAS PRINCIPAIS ═══
                  _buildMetricsGrid(emp, soldPercent),
                  const SizedBox(height: 24),

                  // ═══ BARRA DE VENDAS ═══
                  _buildSalesProgress(emp, soldPercent),
                  const SizedBox(height: 24),

                  // ═══ DESTAQUES ═══
                  if (emp.highlights.isNotEmpty) ...[
                    _sectionTitle('Destaques'),
                    const SizedBox(height: 12),
                    ...emp.highlights.map((h) => _highlightItem(h)),
                    const SizedBox(height: 24),
                  ],

                  // ═══ GALERIA ═══
                  if (emp.galleryImageUrls.isNotEmpty) ...[
                    _sectionTitle('Galeria'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: emp.galleryImageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            emp.galleryImageUrls[i],
                            width: 240,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 240,
                              color: _card,
                              child: const Icon(Icons.broken_image, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ═══ AÇÕES ═══
                  _sectionTitle('Materiais'),
                  const SizedBox(height: 12),
                  _buildActionButtons(context, emp),
                  const SizedBox(height: 32),

                  // ═══ CTA WHATSAPP ═══
                  _buildWhatsAppCta(emp),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(EmpreendimentoDetail emp, int soldPercent) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metricCard('A partir de', emp.priceFrom, Icons.attach_money, _gold),
        _metricCard('Área', emp.area, Icons.straighten, _green),
        _metricCard('Unidades', '${emp.totalUnits}', Icons.apartment, Colors.white70),
        _metricCard('Disponíveis', '${emp.availableUnits}', Icons.check_circle_outline, _green),
        if (emp.rentability != null)
          _metricCard('Rentabilidade', emp.rentability!, Icons.trending_up, _gold),
        if (emp.deliveryDate != null)
          _metricCard('Entrega', emp.deliveryDate!, Icons.calendar_month, Colors.white70),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSalesProgress(EmpreendimentoDetail emp, int soldPercent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vendas', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$soldPercent% vendido', style: TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: soldPercent / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(_gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${emp.totalUnits - emp.availableUnits} vendidas • ${emp.availableUnits} disponíveis',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _highlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: _green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, EmpreendimentoDetail emp) {
    return Column(
      children: [
        if (emp.tourUrl != null)
          _actionButton(
            icon: Icons.view_in_ar,
            label: 'Tour Virtual 360°',
            color: _gold,
            onTap: () => _openUrl(emp.tourUrl!),
          ),
        if (emp.linktreeUrl != null)
          _actionButton(
            icon: Icons.link,
            label: 'Todos os Materiais',
            color: _green,
            onTap: () => _openUrl(emp.linktreeUrl!),
          ),
        if (emp.salesTableUrl != null)
          _actionButton(
            icon: Icons.table_chart,
            label: 'Tabela de Vendas',
            color: Colors.white70,
            onTap: () => _openUrl(emp.salesTableUrl!),
          ),
        if (emp.videoUrls.isNotEmpty)
          _actionButton(
            icon: Icons.play_circle_outline,
            label: 'Vídeos do Empreendimento',
            color: Colors.redAccent,
            onTap: () => _openUrl(emp.linktreeUrl ?? emp.videoUrls.first),
          ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.open_in_new, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppCta(EmpreendimentoDetail emp) {
    return InkWell(
      onTap: () => _openWhatsApp(emp.name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Falar com Consultor',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String devName) async {
    final msg = Uri.encodeComponent(
      'Olá, venho do App Global Real e gostaria de saber mais sobre o empreendimento $devName.',
    );
    final uri = Uri.parse('https://wa.me/5511996701990?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

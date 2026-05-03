import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/development.dart';
import '../../models/market_hub.dart';
import '../../services/development_service.dart';
import '../../services/favorite_service.dart';
import '../../widgets/development/fullscreen_gallery.dart';

class DevelopmentDetailPage extends StatefulWidget {
  final String developmentId;
  final MarketHub hub;

  const DevelopmentDetailPage({
    super.key,
    required this.developmentId,
    required this.hub,
  });

  @override
  State<DevelopmentDetailPage> createState() => _DevelopmentDetailPageState();
}

class _DevelopmentDetailPageState extends State<DevelopmentDetailPage> {
  bool _isFavorite = false;

  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);

  // Slides das apresentações por empreendimento
  static const _baseUrl = 'https://pcbwbndrnnqptxdbrqnm.supabase.co/storage/v1/object/public/development-images';

  List<String> _getPresentationSlides(String devName) {
    if (devName.contains('Senior Living')) {
      const files = [
        'slide_01_01_1639x921.jpeg', 'slide_02_01_1920x1080.jpeg', 'slide_03_01_1920x1080.jpeg',
        'slide_04_01_1920x1080.jpeg', 'slide_05_01_1920x1080.jpeg', 'slide_06_01_1920x1080.jpeg',
        'slide_07_01_1536x864.jpeg', 'slide_08_01_1920x1080.jpeg', 'slide_09_01_1518x857.jpeg',
        'slide_10_01_1920x1080.jpeg', 'slide_11_01_1536x864.jpeg', 'slide_12_01_1920x1080.jpeg',
        'slide_13_01_1896x1067.jpeg', 'slide_14_01_1390x776.jpeg', 'slide_15_01_1920x1080.jpeg',
        'slide_16_01_1920x1080.jpeg', 'slide_17_01_1920x1080.jpeg', 'slide_18_01_1920x1080.png',
        'slide_19_01_1920x1080.jpeg', 'slide_20_01_1920x1080.png', 'slide_21_01_1920x1080.jpeg',
        'slide_22_01_1920x1080.jpeg', 'slide_23_01_1920x1080.jpeg', 'slide_24_01_1920x1080.jpeg',
        'slide_25_01_1920x1080.jpeg', 'slide_26_01_1920x1080.jpeg', 'slide_27_01_1920x1080.jpeg',
        'slide_28_01_1920x1080.jpeg', 'slide_29_01_1920x1080.jpeg', 'slide_30_01_1920x1080.jpeg',
        'slide_32_01_1920x1080.jpeg', 'slide_33_01_1920x1080.jpeg', 'slide_34_01_1920x1080.jpeg',
        'slide_35_01_1920x1080.jpeg', 'slide_36_01_1920x1080.jpeg', 'slide_37_01_1920x1080.jpeg',
        'slide_38_01_1920x1080.jpeg', 'slide_39_01_1280x720.jpeg', 'slide_40_01_1280x720.jpeg',
        'slide_41_01_1280x720.jpeg', 'slide_42_01_1280x720.jpeg', 'slide_43_01_4396x2473.jpeg',
        'slide_44_01_4396x2473.jpeg', 'slide_45_01_4396x2470.jpeg', 'slide_46_01_4396x2224.jpeg',
        'slide_47_01_4389x2478.jpeg', 'slide_48_01_4389x2466.jpeg', 'slide_49_01_1920x1080.jpeg',
        'slide_50_01_1920x1080.jpeg', 'slide_51_01_1920x1080.jpeg', 'slide_52_01_1920x1080.jpeg',
        'slide_53_01_1639x921.jpeg',
      ];
      return files.map((f) => '$_baseUrl/senior-living/slides/$f').toList();
    }
    if (devName.contains('Nove de Julho')) {
      const files = [
        'slide_01_01_1315x740.png', 'slide_02_01_819x464.jpeg', 'slide_05_01_1920x1080.jpeg',
        'slide_06_01_1755x1015.jpeg', 'slide_09_01_2004x940.png', 'slide_10_01_936x1082.jpeg',
        'slide_12_01_1920x1080.jpeg', 'slide_14_01_789x1024.jpeg', 'slide_17_01_965x675.jpeg',
        'slide_19_01_1887x1042.jpeg', 'slide_20_01_2426x1354.jpeg', 'slide_22_01_1423x968.jpeg',
        'slide_23_01_581x836.jpeg', 'slide_27_01_814x1215.jpeg', 'slide_31_01_1474x1533.jpeg',
        'slide_32_01_1960x1102.jpeg', 'slide_33_01_2665x1500.jpeg', 'slide_34_01_1682x946.jpeg',
        'slide_35_01_2665x1500.jpeg', 'slide_36_01_1743x980.jpeg', 'slide_37_01_1960x1100.jpeg',
        'slide_38_01_1960x1101.jpeg', 'slide_39_01_1392x1652.jpeg', 'slide_40_01_1590x1650.jpeg',
      ];
      return files.map((f) => '$_baseUrl/nove-de-julho/slides/$f').toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoriteService.isFavorite(widget.developmentId);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    _isFavorite
        ? await FavoriteService.addFavorite(widget.developmentId)
        : await FavoriteService.removeFavorite(widget.developmentId);
  }

  Future<void> _openWhatsApp(String devName) async {
    final msg = Uri.encodeComponent(
      'Olá, venho do App Global Real e gostaria de falar sobre o empreendimento $devName.',
    );
    final uri = Uri.parse('https://wa.me/5511996701990?text=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FutureBuilder<Development>(
        future: DevelopmentService.getById(widget.developmentId, hub: widget.hub),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white38, size: 48),
                  const SizedBox(height: 12),
                  const Text('Erro ao carregar empreendimento', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Voltar')),
                ],
              ),
            );
          }

          final dev = snapshot.data!;
          return _buildContent(dev);
        },
      ),
    );
  }

  Widget _buildContent(Development dev) {
    return CustomScrollView(
      slivers: [
        // ── SLIVER APP BAR com imagem ──
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: dev.images.isNotEmpty
                ? GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenGallery(images: dev.images, initialIndex: 0),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(dev.images.first, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: _card)),
                        // Gradient overlay
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xFF0B1220)],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                        // Image count badge
                        if (dev.images.length > 1)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${dev.images.length} fotos',
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(color: _card, child: const Center(child: Icon(Icons.apartment, color: Colors.white24, size: 64))),
          ),
        ),

        // ── CONTEÚDO ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                Text(dev.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),

                // Localização
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: _gold),
                    const SizedBox(width: 4),
                    Expanded(child: Text(dev.location, style: const TextStyle(color: Colors.white54, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _tag(dev.type, Icons.apartment),
                    if (dev.deliveryDate.isNotEmpty) _tag('Entrega: ${dev.deliveryDate}', Icons.calendar_today),
                    _tag('${dev.bedrooms} quarto(s)', Icons.bed),
                    _tag('${dev.bathrooms} banheiro(s)', Icons.bathtub),
                  ],
                ),
                const SizedBox(height: 20),

                // ── MÉTRICAS FINANCEIRAS ──
                _sectionTitle('Dados do Investimento'),
                const SizedBox(height: 12),
                _metricsGrid(dev),
                const SizedBox(height: 20),

                // ── GALERIA HORIZONTAL ──
                if (dev.images.length > 1) ...[
                  _sectionTitle('Galeria'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dev.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FullscreenGallery(images: dev.images, initialIndex: i),
                        )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(dev.images[i], width: 220, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 220, color: _card)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── DEMAND DRIVERS ──
                if (dev.demandDrivers.isNotEmpty) ...[
                  _sectionTitle('Diferenciais da Região'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dev.demandDrivers.map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _gold.withValues(alpha: 0.2)),
                      ),
                      child: Text(d, style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── AMENITIES ──
                if (dev.amenities != null && dev.amenities!.isNotEmpty) ...[
                  _sectionTitle('Comodidades'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dev.amenities!.entries
                        .where((e) => e.value == true)
                        .map((e) => _amenityChip(e.key))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── LOCALIZAÇÃO ──
                if (dev.nearestSubwayName != null) ...[
                  _sectionTitle('Mobilidade'),
                  const SizedBox(height: 12),
                  _infoRow(Icons.train, 'Metrô mais próximo', '${dev.nearestSubwayName} (${dev.nearestSubwayDistanceMeters}m)'),
                  const SizedBox(height: 20),
                ],

                // ── APRESENTAÇÃO COMPLETA (slides do PDF) ──
                ..._buildPresentationSection(dev),

                // ── CTAs ──
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(dev.name),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Falar com Consultor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (dev.localizacaoMaps.isNotEmpty) {
                        final encoded = Uri.encodeComponent(dev.localizacaoMaps);
                        launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Ver no Mapa', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPresentationSection(Development dev) {
    final slides = _getPresentationSlides(dev.name);
    if (slides.isEmpty) return [];

    return [
      _sectionTitle('Apresentação Completa'),
      const SizedBox(height: 8),
      Text(
        'Material exclusivo do empreendimento',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
      ),
      const SizedBox(height: 12),
      ...slides.asMap().entries.map((entry) {
        final index = entry.key;
        final url = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullscreenGallery(images: slides, initialIndex: index),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: _card,
                    child: const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2)),
                  );
                },
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: 20),
    ];
  }

  Widget _sectionTitle(String title) {
    return Text(title.toUpperCase(),
        style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1));
  }

  Widget _tag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white54),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _metricsGrid(Development dev) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metricCard('Entrada', 'R\$ ${_formatCapex(double.tryParse(dev.aPartirDe) ?? 200000)}', Icons.payments),
        _metricCard('Preço/m²', 'R\$ ${dev.avgDailyRate.toStringAsFixed(0)}', Icons.square_foot),
        _metricCard('Renda', '${dev.occupancyRate.toStringAsFixed(1)}% a.m.', Icons.trending_up),
        _metricCard('Entrega', dev.deliveryDate, Icons.calendar_month),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    final w = (MediaQuery.of(context).size.width - 50) / 2;
    return Container(
      width: w,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _gold, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: _gold, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _amenityChip(String key) {
    final labels = {
      'parking': '🅿️ Estacionamento',
      'pool': '🏊 Piscina',
      'air_conditioning': '❄️ Ar Condicionado',
      'pet_friendly': '🐾 Pet Friendly',
      'senior_living': '🏥 Senior Living',
      'coworking': '💻 Coworking',
      'fitness': '🏋️ Fitness',
      'podcast_studio': '🎙️ Podcast Studio',
      'laundry': '🧺 Lavanderia',
      'concierge': '🛎️ Concierge',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
      child: Text(labels[key] ?? key, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border, width: 0.5)),
      child: Row(
        children: [
          Icon(icon, color: _gold, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCapex(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)} Mi';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} Mil';
    return value.toStringAsFixed(0);
  }
}

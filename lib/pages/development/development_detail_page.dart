import 'package:flutter/material.dart';
import '../../models/development.dart';
import '../../models/market_hub.dart';
import '../../services/development_service.dart';
import '../../services/favorite_service.dart';
import '../../theme.dart';
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
  State<DevelopmentDetailPage> createState() =>
      _DevelopmentDetailPageState();
}

class _DevelopmentDetailPageState
    extends State<DevelopmentDetailPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav =
    await FavoriteService.isFavorite(widget.developmentId);
    if (mounted) {
      setState(() => _isFavorite = fav);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);

    if (_isFavorite) {
      await FavoriteService.addFavorite(widget.developmentId);
    } else {
      await FavoriteService.removeFavorite(widget.developmentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Empreendimento'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
              _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Development>(
        future:
        DevelopmentService.getById(widget.developmentId, hub: widget.hub),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Erro ao carregar empreendimento'),
            );
          }

          final dev = snapshot.data!;

          return ListView(
            children: [
              // ===============================
              // GALERIA (AIRBNB / AIRDNA)
              // ===============================
              _ImageGallery(images: dev.images),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      dev.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dev.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(dev.type)),
                        if (dev.deliveryDate != null)
                          Chip(
                            label: Text(
                              'Entrega: ${dev.deliveryDate}',
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Sobre o empreendimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Informações detalhadas do empreendimento vindas do Supabase.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===============================
// IMAGE GALLERY
// ===============================
class _ImageGallery extends StatelessWidget {
  final List<String> images;

  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          'https://images.unsplash.com/photo-1502673530728-f79b4cab31b1',
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullscreenGallery(
                    images: images,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

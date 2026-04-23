import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/development.dart';
import '../../models/market_hub.dart';
import '../../helpers/revenue_calculator.dart';
import '../../helpers/confidence_score_calculator.dart';
import '../../helpers/hub_currency_helper.dart';
import '../../widgets/common/animated_urgency_badge.dart';
import '../../widgets/common/urgency_badge.dart';

// ── Premium Unsplash images by hub + type ──
const _unsplashImages = <String, List<String>>{
  'florida': [
    // Luxury apartment buildings & condos — Florida style
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
    'https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=800&q=80',
  ],
  'saopaulo': [
    // Modern high-rise apartments & interiors — São Paulo style
    'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&q=80',
    'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80',
    'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=80',
    'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800&q=80',
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=80',
  ],
  'riodejaneiro': [
    // Beachfront apartments & balcony views — Rio style
    'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800&q=80',
    'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800&q=80',
    'https://images.unsplash.com/photo-1560448075-bb485b067938?w=800&q=80',
    'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800&q=80',
    'https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800&q=80',
  ],
};

String _getPremiumImageUrl(Development dev) {
  // 1. Use real image if available
  if (dev.images.isNotEmpty && dev.images.first.startsWith('http')) {
    return dev.images.first;
  }
  // 2. Fallback to Unsplash by hub
  final hubKey = switch (dev.hub) {
    MarketHub.florida => 'florida',
    MarketHub.saoPaulo => 'saopaulo',
    MarketHub.rioDeJaneiro => 'riodejaneiro',
  };
  final list = _unsplashImages[hubKey] ?? _unsplashImages['saopaulo']!;
  final idx = dev.name.hashCode.abs() % list.length;
  return list[idx];
}

Future<void> openMaps(String query) async {
  if (query.isEmpty) return;
  final encoded = Uri.encodeComponent(query);
  final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
}

String _formatCapex(double value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return m == m.roundToDouble() ? '${m.toInt()} Mi' : '${m.toStringAsFixed(1)} Mi';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return k == k.roundToDouble() ? '${k.toInt()} Mil' : '${k.toStringAsFixed(0)} Mil';
  }
  return value.toStringAsFixed(0);
}

class DevelopmentCard extends StatelessWidget {
  final Development development;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const DevelopmentCard({
    super.key,
    required this.development,
    required this.isFavorite,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getPremiumImageUrl(development);

    final revenueResult = calculateMonthlyRevenue(
      avgDailyRate: development.avgDailyRate,
      occupancyRate: development.occupancyRate,
      cleaningFee: development.cleaningFee,
      condoFeeMonthly: development.condoFeeMonthly,
      managementFeePct: development.managementFeePct,
    );

    final confidenceScore = calculateConfidenceScore(
      avgDailyRate: development.avgDailyRate,
      occupancyRate: development.occupancyRate,
      cleaningFee: development.cleaningFee,
      condoFeeMonthly: development.condoFeeMonthly,
      managementFeePct: development.managementFeePct,
    );

    final isLastUnits =
        development.availableUnits > 0 && development.availableUnits <= 5;
    final isNew =
        DateTime.now().difference(development.createdAt).inDays <= 14;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => openMaps(development.localizacaoMaps),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PREMIUM IMAGE ──
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.8,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, p) =>
                          p == null ? child : const _ImageLoading(),
                      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                    ),
                  ),
                  // Gradient overlay on image
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Hub badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            development.hub.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Urgency badges
                  if (isLastUnits)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: AnimatedUrgencyBadge(
                        child: UrgencyBadge(
                          label: 'Últimas unidades',
                          icon: Icons.local_fire_department,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (isNew)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: AnimatedUrgencyBadge(
                        child: UrgencyBadge(
                          label: 'Novo',
                          icon: Icons.fiber_new,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  // Favorite
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavorite,
                    ),
                  ),
                ],
              ),

              // ── CONTENT ──
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Valor a partir de
                      Text(
                        development.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Location
                      Text(
                        development.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Valor a partir de
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Entrada a partir de R\$ ${_formatCapex(double.tryParse(development.aPartirDe) ?? 200000)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD4AF37)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rentabilidade + Entrada à vista
                      Row(
                        children: [
                          // Projeção de renda
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.trending_up, size: 14, color: Colors.greenAccent),
                              const SizedBox(width: 4),
                              Text(
                                '${development.occupancyRate.toStringAsFixed(0)}% a.m.',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.greenAccent),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          // Entrada à vista
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.payments_outlined, size: 14, color: Colors.white54),
                              SizedBox(width: 4),
                              Text('Entrada à vista', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white54)),
                            ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Seja Sócio Investidor button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), width: 0.5),
                        ),
                        child: const Text(
                          'Seja Sócio Investidor',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== FAVORITE BUTTON =====
class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const _FavoriteButton({required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isFavorite ? Colors.redAccent : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ===== CAPACITY CHIP =====
class _CapacityChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _CapacityChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70)),
        ],
      ),
    );
  }
}

// ===== METRIC PILL =====
class _MetricPill extends StatelessWidget {
  final String value;
  final String label;
  const _MetricPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD4AF37))),
        Text(label,
            style: const TextStyle(fontSize: 9, color: Colors.white38)),
      ],
    );
  }
}

// ===== CONFIDENCE BADGE =====
enum BadgeTone { success, warning, danger }

BadgeTone confidenceTone(double score) {
  if (score >= 80) return BadgeTone.success;
  if (score >= 60) return BadgeTone.warning;
  return BadgeTone.danger;
}

class _ConfidenceBadge extends StatelessWidget {
  final double score;
  const _ConfidenceBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final tone = confidenceTone(score);
    final color = switch (tone) {
      BadgeTone.success => Colors.green,
      BadgeTone.warning => Colors.orange,
      BadgeTone.danger => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        '${score.toInt()} • Confidence',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ===== PLACEHOLDERS =====
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Icon(Icons.apartment, size: 32, color: Color(0x44D4AF37)),
      ),
    );
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/development.dart';

class MarketCard extends StatelessWidget {
  final Development market;

  const MarketCard({
    super.key,
    required this.market,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
    market.images.isNotEmpty ? market.images.first : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===============================
          // IMAGE
          // ===============================
          SizedBox(
            height: 140,
            width: double.infinity,
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
            )
                : Container(
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreBadge(score: market.listingCount),
                const SizedBox(height: 8),

                // NAME
                Text(
                  market.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                // METRICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric(
                      'ADR',
                      'R\$ ${market.avgDailyRate.toStringAsFixed(0)}',
                    ),
                    _metric(
                      'Occ.',
                      '${market.occupancyRate.toStringAsFixed(0)}%',
                    ),
                    _metric(
                      'Listings',
                      market.listingCount.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

// ===============================
// SCORE BADGE (SIMPLE)
// ===============================
class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Listings: $score',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

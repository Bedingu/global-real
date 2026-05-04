import 'package:flutter/material.dart';
import '../../models/development.dart';
import '../../models/market_filter.dart';
import '../../models/proximity_filter.dart';
import '../../models/market_proximity.dart';
import '../../models/market_hub.dart';
import '../../services/development_service.dart';
import '../../services/favorite_service.dart';
import '../../helpers/retry_helper.dart';
import '../development/development_card.dart';

class DevelopmentGrid extends StatelessWidget {
  final String searchQuery;
  final MarketFilter marketFilter;
  final MarketProximity marketProximity;
  final MarketHub hub;
  final Set<String> favoriteIds;
  final ValueChanged<String> onToggleFavorite;

  const DevelopmentGrid({
    super.key,
    required this.searchQuery,
    required this.marketFilter,
    required this.marketProximity,
    required this.hub,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Development>>(
      future: withRetry(
        () => DevelopmentService.searchDevelopments(
          searchQuery,
          marketFilter,
          ProximityFilter(
            maxSubwayDistanceMeters: marketProximity.maxDistanceMeters,
          ),
          hub,
        ),
        maxAttempts: 2,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Semantics(
            label: 'Erro ao carregar empreendimentos',
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao carregar empreendimentos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final developments = snapshot.data!;
        if (developments.isEmpty) {
          return const Text('Nenhum empreendimento encontrado');
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: developments.length,
          itemBuilder: (context, i) {
            final dev = developments[i];
            final isFav = favoriteIds.contains(dev.id);

            return DevelopmentCard(
              development: dev,
              isFavorite: isFav,
              onFavorite: () => onToggleFavorite(dev.id),
            );
          },
        );
      },
    );
  }
}

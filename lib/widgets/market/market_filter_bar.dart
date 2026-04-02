import 'package:flutter/material.dart';
import '../../models/market_filter.dart';
import '../../generated/app_localizations.dart';
import '../common/market_filter_chip.dart';

class MarketFilterBar extends StatelessWidget {
  final MarketFilter filter;
  final VoidCallback onOpenMarketFilters;
  final VoidCallback onOpenCapacityFilters;

  const MarketFilterBar({
    super.key,
    required this.filter,
    required this.onOpenMarketFilters,
    required this.onOpenCapacityFilters,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarketFilterChip(
          label: t.all_filters_developments,
          icon: Icons.tune,
          onTap: onOpenMarketFilters,
        ),
        const SizedBox(width: 8),
        MarketFilterChip(
          label: '${t.capacity_baths} / ${t.capacity_bedrooms}',
          icon: Icons.bed_outlined,
          onTap: onOpenCapacityFilters,
        ),
      ],
    );
  }
}

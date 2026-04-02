import 'package:flutter/material.dart';
import '../../models/market_hub.dart';
import '../common/market_filter_chip.dart';

class MarketHubFilter extends StatelessWidget {
  final MarketHub value;
  final ValueChanged<MarketHub> onChanged;

  const MarketHubFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MarketHub>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) {
        return MarketHub.values.map((hub) {
          return PopupMenuItem(
            value: hub,
            child: Text(hub.label),
          );
        }).toList();
      },

      // VISUAL PADRONIZADO
      child: MarketFilterChip(
        label: value.label,
        icon: Icons.location_on_outlined,
      ),
    );
  }
}

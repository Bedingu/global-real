import 'package:flutter/material.dart';
import '../../models/market_proximity.dart';
import '../../generated/app_localizations.dart';
import '../common/market_filter_chip.dart';

class MarketProximityFilter extends StatelessWidget {
  final MarketProximity value;
  final ValueChanged<MarketProximity> onChanged;

  const MarketProximityFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _label(MarketProximity option, AppLocalizations t) {
    switch (option) {
      case MarketProximity.any:
        return t.proximity_any;
      case MarketProximity.upTo300m:
        return t.proximity_300m;
      case MarketProximity.upTo500m:
        return t.proximity_500m;
      case MarketProximity.upTo800m:
        return t.proximity_800m;
      case MarketProximity.upTo1km:
        return t.proximity_1km;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopupMenuButton<MarketProximity>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => MarketProximity.values
          .map(
            (option) => PopupMenuItem(
              value: option,
              child: Text(_label(option, t)),
            ),
          )
          .toList(),
      child: MarketFilterChip(
        label: _label(value, t),
        icon: Icons.directions_subway_outlined,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/market_filter.dart';
import '../../widgets/market/market_filter_bar.dart';
import '../../widgets/market/market_capacity_filter_modal.dart';
import '../../widgets/market/market_filter_panel.dart';

class MarketOverviewBody extends StatefulWidget {
  const MarketOverviewBody({super.key});

  @override
  State<MarketOverviewBody> createState() => _MarketOverviewBodyState();
}

class _MarketOverviewBodyState extends State<MarketOverviewBody> {
  MarketFilter _filter = const MarketFilter();

  void _openMarketFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MarketFilterPanel(
        initialFilter: _filter,
        onApply: (f) => setState(() => _filter = f),
      ),
    );
  }

  Future<void> _openCapacityFilters() async {
    final result = await showModalBottomSheet<MarketFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarketCapacityFilterModal(
        initialFilter: _filter,
      ),
    );
    if (mounted && result != null) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 900) {
      return Column(
        children: [
          MarketFilterBar(
            filter: _filter,
            onOpenMarketFilters: _openMarketFilters,
            onOpenCapacityFilters: _openCapacityFilters,
          ),
          const Expanded(
            child: Center(child: Text('Market overview content')),
          ),
        ],
      );
    }

    return Column(
      children: [
        MarketFilterBar(
          filter: _filter,
          onOpenMarketFilters: _openMarketFilters,
          onOpenCapacityFilters: _openCapacityFilters,
        ),
        const Expanded(
          child: Center(child: Text('Market overview content')),
        ),
      ],
    );
  }
}

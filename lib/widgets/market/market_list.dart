import 'package:flutter/material.dart';

import '../../models/development.dart';
import 'market_card.dart';

class MarketList extends StatelessWidget {
  final List<Development> markets;

  const MarketList({
    super.key,
    required this.markets,
  });

  int _columns(double width) {
    if (width >= 1400) return 3;
    if (width >= 1000) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (markets.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum empreendimento encontrado',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns(width),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: markets.length,
      itemBuilder: (context, index) {
        return MarketCard(
          market: markets[index],
        );
      },
    );
  }
}

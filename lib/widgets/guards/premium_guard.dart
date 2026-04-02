import 'package:flutter/material.dart';

class PremiumGuard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onBlocked;
  final Widget child;

  const PremiumGuard({
    super.key,
    required this.isPremium,
    required this.onBlocked,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onBlocked();
      });

      return const SizedBox.shrink();
    }

    return child;
  }
}

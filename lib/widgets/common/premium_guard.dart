import 'package:flutter/material.dart';

class PremiumGuard extends StatelessWidget {
  final bool isPremium;
  final Widget child;
  final VoidCallback onBlocked;

  const PremiumGuard({
    super.key,
    required this.isPremium,
    required this.child,
    required this.onBlocked,
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

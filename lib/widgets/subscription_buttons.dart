import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/payment_service.dart';

class SubscriptionButtons extends StatelessWidget {
  /// Stripe Price IDs — substitua pelos seus IDs reais
  static const String monthlyPriceId = "price_xxx"; // TODO: substituir pelo price ID mensal real
  static const String annualPriceId = "price_yyy"; // TODO: substituir pelo price ID anual real

  const SubscriptionButtons({super.key});

  void _handleCheckout(BuildContext context, String priceId) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login antes de assinar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await PaymentService.startCheckout(priceId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar pagamento: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _handleCheckout(context, monthlyPriceId),
          child: const Text("Assinar Mensal"),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _handleCheckout(context, annualPriceId),
          child: const Text("Assinar Anual"),
        ),
      ],
    );
  }
}

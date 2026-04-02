import 'package:flutter/material.dart';
import '../../widgets/guards/premium_guard.dart';

/// ===============================
/// MODEL
/// ===============================

class Investment {
  final String id;
  final String name;
  final String city;
  final String country;
  final double amount;
  final String currency;

  Investment({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.amount,
    required this.currency,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

/// ===============================
/// PAGE (PREMIUM)
/// ===============================

class InvestmentPage extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onBlocked;

  const InvestmentPage({
    super.key,
    required this.isPremium,
    required this.onBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGuard(
      isPremium: isPremium,
      onBlocked: onBlocked,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Investimentos'),
        ),
        body: const Center(
          child: Text(
            'Conteúdo premium de investimentos',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

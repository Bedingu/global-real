import 'private_simulation_input.dart';

class PrivateInvestment {
  final String id;
  final String name;
  final String city;
  final String country;

  /// Datas
  final DateTime startDate;
  final int durationMonths;

  /// Simulação base
  final PrivateSimulationInput baseSimulation;

  const PrivateInvestment({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.startDate,
    required this.durationMonths,
    required this.baseSimulation,
  });
}

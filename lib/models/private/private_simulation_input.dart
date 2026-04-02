class PrivateSimulationInput {
  /// Capital
  final double initialInvestment;
  final double exitValue;

  /// Operação
  final double monthlyRevenue;
  final double monthlyCosts;

  /// Crescimento
  final double revenueGrowthRateMonthly;
  final double costGrowthRateMonthly;

  /// Duração
  final int durationMonths;

  /// Financeiro
  final double discountRateMonthly;

  /// Flags
  final bool reinvestCashflow;

  const PrivateSimulationInput({
    required this.initialInvestment,
    required this.exitValue,
    required this.monthlyRevenue,
    required this.monthlyCosts,
    required this.revenueGrowthRateMonthly,
    required this.costGrowthRateMonthly,
    required this.durationMonths,
    required this.discountRateMonthly,
    this.reinvestCashflow = false,
  });
}

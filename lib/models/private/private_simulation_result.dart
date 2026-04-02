class PrivateSimulationResult {
  final double irrMonthly;
  final double irrAnnual;
  final double roi;

  final int? paybackMonths;
  final double npv;

  final double totalInvested;
  final double totalReturn;
  final double totalProfit;

  // NOVO
  final List<double> monthlyRevenues;
  final List<double> monthlyCosts;

  // LEGADO (mantido)
  final List<double> monthlyCashFlows;

  const PrivateSimulationResult({
    required this.irrMonthly,
    required this.irrAnnual,
    required this.roi,
    required this.paybackMonths,
    required this.npv,
    required this.totalInvested,
    required this.totalReturn,
    required this.totalProfit,
    required this.monthlyRevenues,
    required this.monthlyCosts,
    required this.monthlyCashFlows,
  });
}
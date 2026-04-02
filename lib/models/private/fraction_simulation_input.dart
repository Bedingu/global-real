class FractionSimulationInput {
  final double initialInvestment;
  final double annualAppreciationRate;
  final int holdingYears;
  final double annualRentalYield;

  const FractionSimulationInput({
    required this.initialInvestment,
    required this.annualAppreciationRate,
    required this.holdingYears,
    required this.annualRentalYield,
  });
}
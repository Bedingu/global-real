import 'dart:math';

import '../../models/private/fraction_simulation_input.dart';
import '../../models/private/fraction_simulation_result.dart';

class FractionSimulationEngine {
  static FractionSimulationResult run(
      FractionSimulationInput input) {

    final futureValue = input.initialInvestment *
        pow(1 + input.annualAppreciationRate,
            input.holdingYears);

    final totalRentalIncome =
        input.initialInvestment *
            input.annualRentalYield *
            input.holdingYears;

    final roi =
        (futureValue + totalRentalIncome -
            input.initialInvestment) /
            input.initialInvestment;

    return FractionSimulationResult(
      futureValue: futureValue,
      roi: roi,
      irr: input.annualAppreciationRate,
      totalRentalIncome: totalRentalIncome,
    );
  }
}
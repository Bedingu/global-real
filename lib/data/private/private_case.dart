import '../../models/private/private_case.dart';
import '../../models/private/private_simulation_input.dart';

final privateCases = <PrivateCase>[
  PrivateCase(
    name: 'Vitacon Venâncio 943',
    input: PrivateSimulationInput(
      initialInvestment: 1000000,
      exitValue: 1614499,
      monthlyRevenue: 0,
      monthlyCosts: 0,
      revenueGrowthRateMonthly: 0,
      costGrowthRateMonthly: 0,
      durationMonths: 36,
      discountRateMonthly: 0.01,
    ),
  ),
  PrivateCase(
    name: 'Senior Living Albert Einstein',
    input: PrivateSimulationInput(
      initialInvestment: 1000000,
      exitValue: 1705255,
      monthlyRevenue: 0,
      monthlyCosts: 0,
      revenueGrowthRateMonthly: 0,
      costGrowthRateMonthly: 0,
      durationMonths: 36,
      discountRateMonthly: 0.01,
    ),
  ),
  PrivateCase(
    name: 'Vitacon Nove de Julho',
    input: PrivateSimulationInput(
      initialInvestment: 200000,
      exitValue: 371893,
      monthlyRevenue: 0,
      monthlyCosts: 0,
      revenueGrowthRateMonthly: 0,
      costGrowthRateMonthly: 0,
      durationMonths: 36,
      discountRateMonthly: 0.01,
    ),
  ),
];

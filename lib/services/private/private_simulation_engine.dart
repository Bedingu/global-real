import 'dart:math';

import '../../models/private/private_simulation_input.dart';
import '../../models/private/private_simulation_result.dart';

class PrivateSimulationEngine {
  static PrivateSimulationResult run(
      PrivateSimulationInput input,
      ) {
    final revenues = <double>[];
    final costs = <double>[];
    final cashFlows = <double>[];

    // =============================
    // MÊS 0 — INVESTIMENTO
    // =============================

    revenues.add(0);
    costs.add(input.initialInvestment);
    cashFlows.add(-input.initialInvestment);

    double revenue = input.monthlyRevenue;
    double cost = input.monthlyCosts;

    // =============================
    // MESES OPERACIONAIS
    // =============================

    for (int m = 1; m <= input.durationMonths; m++) {
      revenues.add(revenue);
      costs.add(cost);
      cashFlows.add(revenue - cost);

      revenue *= (1 + input.revenueGrowthRateMonthly);
      cost *= (1 + input.costGrowthRateMonthly);
    }

    // =============================
    // EXIT
    // =============================

    if (input.exitValue != 0) {
      revenues[revenues.length - 1] += input.exitValue;
      cashFlows[cashFlows.length - 1] += input.exitValue;
    }

    // =============================
    // MÉTRICAS
    // =============================

    final irrMonthly = _irrBisection(cashFlows);
    final irrAnnual =
    (pow(1 + irrMonthly, 12) - 1).toDouble();

    final totalInvested = input.initialInvestment;
    final totalReturn =
    cashFlows.skip(1).reduce((a, b) => a + b);
    final totalProfit = totalReturn - totalInvested;

    final roi = totalProfit / totalInvested;
    final payback = _paybackMonths(cashFlows);
    final npv = _npv(cashFlows, input.discountRateMonthly);

    return PrivateSimulationResult(
      irrMonthly: irrMonthly,
      irrAnnual: irrAnnual,
      roi: roi,
      paybackMonths: payback,
      npv: npv,
      totalInvested: totalInvested,
      totalReturn: totalReturn,
      totalProfit: totalProfit,
      monthlyRevenues: revenues,
      monthlyCosts: costs,
      monthlyCashFlows: cashFlows,
    );
  }

  // =============================
  // IRR — Bisseção
  // =============================

  static double _irrBisection(
      List<double> cashFlows, {
        double min = -0.999,
        double max = 10,
        double tolerance = 1e-7,
        int maxIterations = 1000,
      }) {
    double low = min;
    double high = max;
    double mid = 0;

    for (int i = 0; i < maxIterations; i++) {
      mid = (low + high) / 2;
      final value = _npv(cashFlows, mid);

      if (value.abs() < tolerance) return mid;

      if (value > 0) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return mid;
  }

  // =============================
  // NPV
  // =============================

  static double _npv(
      List<double> cashFlows,
      double rate,
      ) {
    double value = 0;

    for (int t = 0; t < cashFlows.length; t++) {
      value += cashFlows[t] / pow(1 + rate, t);
    }

    return value;
  }

  // =============================
  // PAYBACK
  // =============================

  static int? _paybackMonths(
      List<double> cashFlows,
      ) {
    double cumulative = 0;

    for (int i = 0; i < cashFlows.length; i++) {
      cumulative += cashFlows[i];
      if (cumulative >= 0) return i;
    }

    return null;
  }
}
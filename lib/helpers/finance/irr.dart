import 'dart:math';

double? calculateIRR(
    List<double> cashFlows, {
      double guess = 0.1,
      int maxIterations = 1000,
      double tolerance = 1e-6,
    }) {
  double rate = guess;

  for (int i = 0; i < maxIterations; i++) {
    double npv = 0;
    double dNpv = 0;

    for (int t = 0; t < cashFlows.length; t++) {
      npv += cashFlows[t] / pow(1 + rate, t);
      dNpv -= t * cashFlows[t] / pow(1 + rate, t + 1);
    }

    if (dNpv.abs() < tolerance) return null;

    double newRate = rate - npv / dNpv;

    if ((newRate - rate).abs() < tolerance) {
      return newRate;
    }

    rate = newRate;
  }

  return null;
}

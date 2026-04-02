import 'dart:math';

double? calculateIRRBisection(
    List<double> cashFlows, {
      double minRate = -0.99,
      double maxRate = 10.0,
      double tolerance = 1e-6,
      int maxIterations = 1000,
    }) {
  double npv(double rate) {
    double total = 0;
    for (int t = 0; t < cashFlows.length; t++) {
      total += cashFlows[t] / pow(1 + rate, t);
    }
    return total;
  }

  double low = minRate;
  double high = maxRate;
  double npvLow = npv(low);
  double npvHigh = npv(high);

  // Não existe TIR no intervalo
  if (npvLow * npvHigh > 0) {
    return null;
  }
  for (int i = 0; i < maxIterations; i++) {
    final mid = (low + high) / 2;
    final npvMid = npv(mid);
    if (npvMid.abs() < tolerance) {
      return mid;
    }
    if (npvLow * npvMid < 0) {
      high = mid;
      npvHigh = npvMid;
    } else {
      low = mid;
      npvLow = npvMid;
    }
  }
  return (low + high) / 2;
}

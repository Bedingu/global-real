class IrrCalculator {
  /// Calcula IRR via bisseção (robusto e auditável)
  static double calculate({
    required List<double> cashFlows,
    double minRate = -0.9999,
    double maxRate = 10.0,
    double precision = 1e-7,
    int maxIterations = 10000,
  }) {
    double low = minRate;
    double high = maxRate;
    double mid = 0;

    for (int i = 0; i < maxIterations; i++) {
      mid = (low + high) / 2;
      final npv = _npv(cashFlows, mid);

      if (npv.abs() < precision) {
        return mid;
      }

      if (npv > 0) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return mid;
  }

  static double _npv(List<double> cashFlows, double rate) {
    double sum = 0;
    for (int t = 0; t < cashFlows.length; t++) {
      sum += cashFlows[t] / _pow(1 + rate, t);
    }
    return sum;
  }

  static double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

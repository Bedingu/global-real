int? calculatePaybackMonths({
  required double initialInvestment,
  required List<double> monthlyCashFlows,
}) {
  double accumulated = -initialInvestment;

  for (int i = 0; i < monthlyCashFlows.length; i++) {
    accumulated += monthlyCashFlows[i];
    if (accumulated >= 0) {
      return i + 1;
    }
  }

  return null; // não teve payback no período
}

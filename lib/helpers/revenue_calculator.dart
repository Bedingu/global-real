class RevenueResult {
  final double grossMonthly;
  final double netMonthly;

  RevenueResult({
    required this.grossMonthly,
    required this.netMonthly,
  });
}

RevenueResult calculateMonthlyRevenue({
  required double avgDailyRate,
  required double occupancyRate,
  required double cleaningFee,
  required double condoFeeMonthly,
  required double managementFeePct,
}) {
  if (avgDailyRate <= 0 || occupancyRate <= 0) {
    return RevenueResult(grossMonthly: 0, netMonthly: 0);
  }

  final grossMonthly = avgDailyRate * occupancyRate * 30;

  final estimatedBookings = (30 * occupancyRate) / 3;

  final cleaningCost = cleaningFee * estimatedBookings;
  final managementCost = grossMonthly * managementFeePct;

  final netMonthly = grossMonthly -
      cleaningCost -
      condoFeeMonthly -
      managementCost;

  return RevenueResult(
    grossMonthly: grossMonthly,
    netMonthly: netMonthly < 0 ? 0 : netMonthly,
  );
}


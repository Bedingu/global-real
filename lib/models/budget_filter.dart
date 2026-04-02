// ===============================
// BUDGET FILTER (CAPEX / ADR / YIELD / M²)
// ===============================
class BudgetFilter {
  final double? maxCapex;        // Ticket de entrada máximo
  final double? maxPricePerM2;   // Preço por m² máximo
  final double? minADR;          // ADR mínimo
  final double? minYield;        // Yield mínimo

  const BudgetFilter({
    this.maxCapex,
    this.maxPricePerM2,
    this.minADR,
    this.minYield,
  });

  BudgetFilter copyWith({
    double? maxCapex,
    double? maxPricePerM2,
    double? minADR,
    double? minYield,
  }) {
    return BudgetFilter(
      maxCapex: maxCapex ?? this.maxCapex,
      maxPricePerM2: maxPricePerM2 ?? this.maxPricePerM2,
      minADR: minADR ?? this.minADR,
      minYield: minYield ?? this.minYield,
    );
  }

  bool get hasFilter =>
      maxCapex != null ||
          maxPricePerM2 != null ||
          minADR != null ||
          minYield != null;
}

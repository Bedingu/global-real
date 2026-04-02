import '../models/development.dart';

/// ===============================
/// CONFIDENCE SCORE CALCULATOR
/// ===============================
double calculateConfidenceScore({
  required double avgDailyRate,
  required double occupancyRate,
  required double cleaningFee,
  required double condoFeeMonthly,
  required double managementFeePct,
}) {
  double score = 0;

  // ===============================
  // ADR (0–30 pontos)
  // ===============================
  if (avgDailyRate >= 400) {
    score += 30;
  } else if (avgDailyRate >= 300) {
    score += 22;
  } else if (avgDailyRate >= 200) {
    score += 14;
  } else if (avgDailyRate > 0) {
    score += 6;
  }

  // ===============================
  // OCCUPANCY (0–30 pontos)
  // ===============================
  if (occupancyRate >= 0.7) {
    score += 30;
  } else if (occupancyRate >= 0.6) {
    score += 22;
  } else if (occupancyRate >= 0.5) {
    score += 14;
  } else if (occupancyRate > 0) {
    score += 6;
  }

  // ===============================
  // COST EFFICIENCY (0–25 pontos)
  // ===============================
  final fixedCosts = cleaningFee + condoFeeMonthly;

  if (fixedCosts > 0 && fixedCosts <= 1200) {
    score += 25;
  } else if (fixedCosts <= 1800) {
    score += 18;
  } else if (fixedCosts <= 2500) {
    score += 10;
  } else if (fixedCosts > 0) {
    score += 4;
  }

  // ===============================
  // MANAGEMENT FEE (0–15 pontos)
  // ===============================
  if (managementFeePct <= 0.15 && managementFeePct > 0) {
    score += 15;
  } else if (managementFeePct <= 0.2) {
    score += 10;
  } else if (managementFeePct > 0) {
    score += 5;
  }

  return score.clamp(0, 100);
}

/// ===============================
/// TOOLTIP BUILDER
/// ===============================
String buildConfidenceTooltip(Development d) {
  final occupancyPct = (d.occupancyRate * 100).toStringAsFixed(0);

  String dataQuality;
  if (d.avgDailyRate > 0 &&
      d.occupancyRate > 0 &&
      d.cleaningFee > 0 &&
      d.condoFeeMonthly > 0 &&
      d.managementFeePct > 0) {
    dataQuality = 'Alta';
  } else if (d.avgDailyRate > 0 && d.occupancyRate > 0) {
    dataQuality = 'Média';
  } else {
    dataQuality = 'Baixa';
  }

  return '''
Diária média: R\$ ${d.avgDailyRate.toStringAsFixed(0)}
Ocupação: $occupancyPct%
Taxa de gestão: ${(d.managementFeePct * 100).toStringAsFixed(0)}%
Condomínio: R\$ ${d.condoFeeMonthly.toStringAsFixed(0)}/mês

Cobertura de dados: $dataQuality

Quanto maior a consistência desses dados,
maior a confiabilidade da projeção.
''';
}

import '../../../models/private/FII_IPO.dart';

class FiiScoringService {

  /// Calcula score individual
  double calculateScore(FiiModel fii) {

    switch (fii.type) {

      case FiiType.tijolo:
        return _scoreTijolo(fii);

      case FiiType.papel:
        return _scorePapel(fii);

      case FiiType.multiclasse:
        return _scoreMulticlasse(fii);

      case FiiType.fof:
        return _scoreFof(fii);
    }
  }

  double _scoreTijolo(FiiModel fii) {
    final dyScore = fii.dividendYield * 4;
    final pvpScore = fii.pvp != null ? (2 - fii.pvp!) * 3 : 0;
    final liquidityScore =
    fii.liquidity != null ? (fii.liquidity! / 1000000) : 0;

    return dyScore + pvpScore + liquidityScore;
  }

  double _scorePapel(FiiModel fii) {
    final dyScore = fii.dividendYield * 5;
    final pvpScore = fii.pvp != null ? (2 - fii.pvp!) * 3 : 0;
    final liquidityScore =
    fii.liquidity != null ? (fii.liquidity! / 1000000) * 2 : 0;

    return dyScore + pvpScore + liquidityScore;
  }

  double _scoreMulticlasse(FiiModel fii) {
    final dyScore = fii.dividendYield * 4;
    final pvpScore = fii.pvp != null ? (2 - fii.pvp!) * 2 : 0;

    return dyScore + pvpScore;
  }

  double _scoreFof(FiiModel fii) {
    final dyScore = fii.dividendYield * 4;
    final pvpScore = fii.pvp != null ? (2 - fii.pvp!) * 4 : 0;

    return dyScore + pvpScore;
  }

  /// Retorna lista já ranqueada
  List<FiiModel> rankFiis(List<FiiModel> fiis) {

    final List<FiiModel> scored = fiis.map((fii) {

      final score = calculateScore(fii);

      return fii.copyWith(privateScore: score);

    }).toList();

    scored.sort((a, b) =>
        (b.privateScore ?? 0).compareTo(a.privateScore ?? 0));

    return scored;
  }
}
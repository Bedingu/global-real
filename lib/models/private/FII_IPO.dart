enum FiiType {
  papel,
  tijolo,
  multiclasse,
  fof,
}

class FiiModel {
  final String ticker;
  final String name;
  final FiiType type;
  final String segment;

  final double price;
  final double dividendYield;
  final double? pvp;
  final double? liquidity;
  final double? aum;

  /// Métricas proprietárias (inteligência private)
  final double? privateScore;
  final double? volatility;
  final double? sharpe;

  const FiiModel({
    required this.ticker,
    required this.name,
    required this.type,
    required this.segment,
    required this.price,
    required this.dividendYield,
    this.pvp,
    this.liquidity,
    this.aum,
    this.privateScore,
    this.volatility,
    this.sharpe,
  });

  /// 🔹 Conversão de JSON → Model (segura)
  factory FiiModel.fromJson(Map<String, dynamic> json) {
    return FiiModel(
      ticker: json['ticker'] ?? '',
      name: json['name'] ?? '',
      type: FiiType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => FiiType.tijolo,
      ),
      segment: json['segment'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      dividendYield:
      (json['dividend_yield'] as num?)?.toDouble() ?? 0.0,
      pvp: (json['pvp'] as num?)?.toDouble(),
      liquidity: (json['liquidity'] as num?)?.toDouble(),
      aum: (json['aum'] as num?)?.toDouble(),
      privateScore: (json['private_score'] as num?)?.toDouble(),
      volatility: (json['volatility'] as num?)?.toDouble(),
      sharpe: (json['sharpe'] as num?)?.toDouble(),
    );
  }

  /// 🔹 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'name': name,
      'type': type.name,
      'segment': segment,
      'price': price,
      'dividend_yield': dividendYield,
      'pvp': pvp,
      'liquidity': liquidity,
      'aum': aum,
      'private_score': privateScore,
      'volatility': volatility,
      'sharpe': sharpe,
    };
  }

  /// 🔹 Atualização parcial segura
  FiiModel copyWith({
    double? price,
    double? dividendYield,
    double? pvp,
    double? liquidity,
    double? aum,
    double? privateScore,
    double? volatility,
    double? sharpe,
  }) {
    return FiiModel(
      ticker: ticker,
      name: name,
      type: type,
      segment: segment,
      price: price ?? this.price,
      dividendYield: dividendYield ?? this.dividendYield,
      pvp: pvp ?? this.pvp,
      liquidity: liquidity ?? this.liquidity,
      aum: aum ?? this.aum,
      privateScore: privateScore ?? this.privateScore,
      volatility: volatility ?? this.volatility,
      sharpe: sharpe ?? this.sharpe,
    );
  }
}
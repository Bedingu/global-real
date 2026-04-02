enum MarketHub {
  saoPaulo,
  rioDeJaneiro,
  florida,
}

extension MarketHubX on MarketHub {
  /// Nome amigável para UI
  String get label {
    switch (this) {
      case MarketHub.saoPaulo:
        return 'São Paulo';
      case MarketHub.rioDeJaneiro:
        return 'Rio de Janeiro';
      case MarketHub.florida:
        return 'Florida (EUA)';
    }
  }

  /// Valor salvo no banco (Supabase)
  String get dbValue {
    switch (this) {
      case MarketHub.saoPaulo:
        return 'saopaulo';
      case MarketHub.rioDeJaneiro:
        return 'riodejaneiro';
      case MarketHub.florida:
        return 'florida';
    }
  }

  /// Símbolo recomendado da moeda
  String get currencySymbol {
    switch (this) {
      case MarketHub.saoPaulo:
      case MarketHub.rioDeJaneiro:
        return 'R\$';
      case MarketHub.florida:
        return '\$';
    }
  }

  /// Locale para NumberFormat
  String get locale {
    switch (this) {
      case MarketHub.saoPaulo:
      case MarketHub.rioDeJaneiro:
        return 'pt_BR';
      case MarketHub.florida:
        return 'en_US';
    }
  }

  /// Se usa USD como base
  bool get isUsd => this == MarketHub.florida;
}

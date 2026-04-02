enum MarketProximity {
  any,
  upTo300m,
  upTo500m,
  upTo800m,
  upTo1km,
}

extension MarketProximityX on MarketProximity {
  int? get maxDistanceMeters {
    switch (this) {
      case MarketProximity.any:
        return null;
      case MarketProximity.upTo300m:
        return 300;
      case MarketProximity.upTo500m:
        return 500;
      case MarketProximity.upTo800m:
        return 800;
      case MarketProximity.upTo1km:
        return 1000;
    }
  }

  String get label {
    switch (this) {
      case MarketProximity.any:
        return 'Metrô';
      case MarketProximity.upTo300m:
        return 'Up to 300m';
      case MarketProximity.upTo500m:
        return 'Up to 500m';
      case MarketProximity.upTo800m:
        return 'Up to 800m';
      case MarketProximity.upTo1km:
        return 'Up to 1 km';
    }
  }
}


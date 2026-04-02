import '../models/market_filter.dart';
import '../models/market_hub.dart';

MarketFilter defaultMarketFilterByHub(MarketHub hub) {
  switch (hub) {
    case MarketHub.saoPaulo:
      return const MarketFilter(
        minBedrooms: 1,
        maxBedrooms: 3,
        minBathrooms: 1,
        maxBathrooms: 3,
        minGuests: 2,
        maxGuests: 6,
        minListings: 5,
        maxListings: 500,
        demandDrivers: {},
      );

    case MarketHub.rioDeJaneiro:
      return const MarketFilter(
        minBedrooms: 1,
        maxBedrooms: 4,
        minBathrooms: 1,
        maxBathrooms: 3,
        minGuests: 2,
        maxGuests: 8,
        minListings: 5,
        maxListings: 500,
        demandDrivers: {},
      );

    case MarketHub.florida:
      return const MarketFilter(
        minBedrooms: 2,
        maxBedrooms: 6,
        minBathrooms: 2,
        maxBathrooms: 5,
        minGuests: 4,
        maxGuests: 12,
        minListings: 10,
        maxListings: 5000,
        demandDrivers: {},
      );
  }
}

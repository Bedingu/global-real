import 'market_proximity.dart';
import 'budget_filter.dart' as bf;

// ===============================
// DEMAND DRIVERS
// ===============================
enum DemandDriver {
  airport,
  arts,
  coastal,
  golf,
  lake,
  military,
  mountains,
  nationalPark,
  ski,
  university,
  winery,
}

// ===============================
// INVESTMENT TIER (OPCIONAL)
// ===============================
enum InvestmentTier {
  budget,
  midscale,
  upscale,
}

// ===============================
// MARKET FILTER MODEL
// ===============================
class MarketFilter {
  // Location
  final String? market;
  final String? submarketOrZip;

  /// Proximidade do metrô (via MarketProximity)
  final MarketProximity proximity;

  // Supply
  final double minListings;
  final double maxListings;

  // Capacity
  final int minBedrooms;
  final int maxBedrooms;

  final int minBathrooms;
  final int maxBathrooms;

  final int minGuests;
  final int maxGuests;

  // Demand Drivers
  final Set<DemandDriver> demandDrivers;

  // Amenities
  final Map<String, bool> amenities;

  // Market Metrics (0–100)
  final double marketScoreMin;
  final double marketScoreMax;

  final double revenueGrowthMin;
  final double revenueGrowthMax;

  final double rentalDemandMin;
  final double rentalDemandMax;

  final double seasonalityMin;
  final double seasonalityMax;

  final double regulationMin;
  final double regulationMax;

  // Budget
  final bf.BudgetFilter? budget;

  // Property Type (multi-select)
  final Set<String> propertyTypes;

  // Delivery Date range
  final String? deliveryDateStart;
  final String? deliveryDateEnd;

  // Price Range (a_partir_de / até)
  final double? minPrice;
  final double? maxPrice;

  const MarketFilter({
    // Location
    this.market,
    this.submarketOrZip,
    this.proximity = MarketProximity.any,

    // Supply
    this.minListings = 10,
    this.maxListings = 100000,

    // Capacity
    this.minBedrooms = 0,
    this.maxBedrooms = 10,
    this.minBathrooms = 1,
    this.maxBathrooms = 6,
    this.minGuests = 1,
    this.maxGuests = 20,

    // Demand
    this.demandDrivers = const {},

    // Amenities
    this.amenities = const {},

    // Metrics
    this.marketScoreMin = 0,
    this.marketScoreMax = 100,
    this.revenueGrowthMin = 0,
    this.revenueGrowthMax = 100,
    this.rentalDemandMin = 0,
    this.rentalDemandMax = 100,
    this.seasonalityMin = 0,
    this.seasonalityMax = 100,
    this.regulationMin = 0,
    this.regulationMax = 100,

    // Budget
    this.budget,

    // Property Type
    this.propertyTypes = const {},

    // Delivery Date
    this.deliveryDateStart,
    this.deliveryDateEnd,

    // Price Range
    this.minPrice,
    this.maxPrice,
  })  : assert(minBedrooms <= maxBedrooms),
        assert(minBathrooms <= maxBathrooms),
        assert(minGuests <= maxGuests);

  // ===============================
  // copyWith
  // ===============================
  MarketFilter copyWith({
    String? market,
    String? submarketOrZip,
    MarketProximity? proximity,

    double? minListings,
    double? maxListings,

    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minGuests,
    int? maxGuests,

    Set<DemandDriver>? demandDrivers,
    Map<String, bool>? amenities,

    double? marketScoreMin,
    double? marketScoreMax,
    double? revenueGrowthMin,
    double? revenueGrowthMax,
    double? rentalDemandMin,
    double? rentalDemandMax,
    double? seasonalityMin,
    double? seasonalityMax,
    double? regulationMin,
    double? regulationMax,

    bf.BudgetFilter? budget,

    Set<String>? propertyTypes,
    String? deliveryDateStart,
    String? deliveryDateEnd,
    double? minPrice,
    double? maxPrice,
  }) {
    return MarketFilter(
      market: market ?? this.market,
      submarketOrZip: submarketOrZip ?? this.submarketOrZip,
      proximity: proximity ?? this.proximity,

      minListings: minListings ?? this.minListings,
      maxListings: maxListings ?? this.maxListings,

      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minGuests: minGuests ?? this.minGuests,
      maxGuests: maxGuests ?? this.maxGuests,

      demandDrivers: demandDrivers ?? this.demandDrivers,
      amenities: amenities ?? this.amenities,

      marketScoreMin: marketScoreMin ?? this.marketScoreMin,
      marketScoreMax: marketScoreMax ?? this.marketScoreMax,
      revenueGrowthMin: revenueGrowthMin ?? this.revenueGrowthMin,
      revenueGrowthMax: revenueGrowthMax ?? this.revenueGrowthMax,
      rentalDemandMin: rentalDemandMin ?? this.rentalDemandMin,
      rentalDemandMax: rentalDemandMax ?? this.rentalDemandMax,
      seasonalityMin: seasonalityMin ?? this.seasonalityMin,
      seasonalityMax: seasonalityMax ?? this.seasonalityMax,
      regulationMin: regulationMin ?? this.regulationMin,
      regulationMax: regulationMax ?? this.regulationMax,

      budget: budget ?? this.budget,

      propertyTypes: propertyTypes ?? this.propertyTypes,
      deliveryDateStart: deliveryDateStart ?? this.deliveryDateStart,
      deliveryDateEnd: deliveryDateEnd ?? this.deliveryDateEnd,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  // ===============================
  // Helpers
  // ===============================
  MarketFilter copyWithProximity(MarketProximity v) =>
      copyWith(proximity: v);

  List<String> get demandDriversAsString =>
      demandDrivers.map((e) => e.name).toList();

  bool get hasProximityFilter => proximity != MarketProximity.any;
  bool get hasDemandDrivers => demandDrivers.isNotEmpty;
  bool get hasAmenitiesFilter => amenities.values.any((v) => v == true);
  bool get hasBudgetFilter => budget?.hasFilter == true;

  bool get hasBedroomFilter => minBedrooms > 0 || maxBedrooms < 10;
  bool get hasBathroomFilter => minBathrooms > 1 || maxBathrooms < 6;
  bool get hasGuestFilter => minGuests > 1 || maxGuests < 20;

  bool get hasPropertyTypeFilter => propertyTypes.isNotEmpty;
  bool get hasDeliveryDateFilter =>
      deliveryDateStart != null || deliveryDateEnd != null;
  bool get hasPriceRangeFilter => minPrice != null || maxPrice != null;
}

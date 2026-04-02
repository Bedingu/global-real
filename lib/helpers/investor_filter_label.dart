import '../models/market_filter.dart';
import '../models/market_hub.dart';
import '../models/market_proximity.dart';

String buildInvestorFilterLabel({
  required MarketFilter filter,
  required MarketHub hub,
  MarketProximity? proximity,
}) {
  final List<String> parts = [];

  // HUB
  parts.add("Hub: ${hub.label}");

  // Bedrooms
  if (filter.hasBedroomFilter) {
    parts.add("Dorms: ${filter.minBedrooms}-${filter.maxBedrooms}");
  }

  // Bathrooms
  if (filter.hasBathroomFilter) {
    parts.add("Banheiros: ${filter.minBathrooms}-${filter.maxBathrooms}");
  }

  // Guests
  if (filter.hasGuestFilter) {
    parts.add("Hóspedes: ${filter.minGuests}-${filter.maxGuests}");
  }

  // Amenities
  if (filter.hasAmenitiesFilter) {
    final enabled = filter.amenities.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (enabled.isNotEmpty) {
      parts.add("Comodidades: ${enabled.join(', ')}");
    }
  }

  // Demand Drivers
  if (filter.hasDemandDrivers) {
    parts.add("Demand: ${filter.demandDriversAsString.join(', ')}");
  }

  // Budget
  if (filter.hasBudgetFilter) {
    final b = filter.budget!;
    final caps = <String>[];
    if (b.maxCapex != null) caps.add("Capex ≤ ${b.maxCapex}");
    if (b.maxPricePerM2 != null) caps.add("€/m² ≤ ${b.maxPricePerM2}");
    if (b.minADR != null) caps.add("ADR ≥ ${b.minADR}");
    if (b.minYield != null) caps.add("Yield ≥ ${b.minYield}%");
    parts.add("Budget: ${caps.join(', ')}");
  }

  // Proximidade
  if (proximity != null && proximity != MarketProximity.any) {
    parts.add("Metrô: ${proximity.label}");
  }

  return parts.join(" • ");
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/development.dart';
import '../models/market_filter.dart';
import '../models/proximity_filter.dart';
import '../models/market_hub.dart';

class DevelopmentService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<Development>> searchDevelopments(
      String search,
      MarketFilter marketFilter,
      ProximityFilter proximityFilter,
      MarketHub hub,
      ) async {
    final query = _supabase.from('developments').select('''
      id,
      empreendimentos,
      localização,
      data_de_entrega,
      tipo,
      localizacao_maps,
      bedrooms,
      bathrooms,
      max_guests,
      occupancy_rate,
      cleaning_fee,
      condo_fee_monthly,
      management_fee_pct,
      listing_count,
      demand_drivers,
      nearest_subway_distance_m,
      nearest_subway_name,
      available_units,
      created_at,
      hub,
      capex,
      price_per_m2,
      avg_daily_rate,
      yield,
      a_partir_de,
      até
    ''');

    // =========================
    // HUB (obrigatório)
    // =========================
    query.eq('hub', hub.dbValue);

    // =========================
    // TEXT SEARCH
    // =========================
    if (search.isNotEmpty) {
      query.or(
        'empreendimentos.ilike.%$search%,localização.ilike.%$search%',
      );
    }

    // =========================
    // SUPPLY
    // =========================
    query
        .gte('listing_count', marketFilter.minListings)
        .lte('listing_count', marketFilter.maxListings);

    // =========================
    // CAPACITY
    // =========================
    query
        .gte('bedrooms', marketFilter.minBedrooms)
        .lte('bedrooms', marketFilter.maxBedrooms)
        .gte('bathrooms', marketFilter.minBathrooms)
        .lte('bathrooms', marketFilter.maxBathrooms)
        .gte('max_guests', marketFilter.minGuests)
        .lte('max_guests', marketFilter.maxGuests);

    // =========================
    // METRÔ (Proximidade)
    // =========================
    if (proximityFilter.maxSubwayDistanceMeters != null) {
      query.lte(
        'nearest_subway_distance_m',
        proximityFilter.maxSubwayDistanceMeters!,
      );
    }

    // =========================
    // AIRPORT (Opcional futuro)
    // =========================
    if (proximityFilter.maxAirportDistanceKm != null) {
      query.lte(
        'nearest_airport_distance_km',
        proximityFilter.maxAirportDistanceKm!,
      );
    }

    // =========================
    // DEMAND DRIVERS
    // =========================
    if (marketFilter.demandDrivers.isNotEmpty) {
      query.contains(
        'demand_drivers',
        marketFilter.demandDriversAsString,
      );
    }

    // =========================
    // AMENITIES (JSONB)
    // =========================
    if (marketFilter.hasAmenitiesFilter) {
      marketFilter.amenities.forEach((key, value) {
        if (value == true) {
          // JSONB ->> retorna TEXT, então comparamos com 'true'
          query.eq('amenities->>$key', 'true');
        }
      });
    }

    // =========================
    // BUDGET FILTERS (Novo)
    // =========================
    final budget = marketFilter.budget;
    if (budget != null && budget.hasFilter) {
      if (budget.maxCapex != null) {
        query.lte('capex', budget.maxCapex!);
      }
      if (budget.maxPricePerM2 != null) {
        query.lte('price_per_m2', budget.maxPricePerM2!);
      }
      if (budget.minADR != null) {
        query.gte('avg_daily_rate', budget.minADR!);
      }
      if (budget.minYield != null) {
        query.gte('yield', budget.minYield!);
      }
    }

    // =========================
    // PROPERTY TYPE
    // =========================
    if (marketFilter.hasPropertyTypeFilter) {
      query.inFilter('tipo', marketFilter.propertyTypes.toList());
    }

    // =========================
    // DELIVERY DATE (text comparison)
    // =========================
    if (marketFilter.deliveryDateStart != null) {
      query.gte('data_de_entrega', marketFilter.deliveryDateStart!);
    }
    if (marketFilter.deliveryDateEnd != null) {
      query.lte('data_de_entrega', marketFilter.deliveryDateEnd!);
    }

    // =========================
    // PRICE RANGE (a_partir_de / até)
    // =========================
    if (marketFilter.minPrice != null) {
      query.gte('a_partir_de', marketFilter.minPrice!.toString());
    }
    if (marketFilter.maxPrice != null) {
      query.lte('até', marketFilter.maxPrice!.toString());
    }

    // EXECUTE
    final data = await query;

    return (data as List)
        .map((json) => Development.fromJson(json))
        .toList();
  }

  // =========================
  // GET BY ID
  // =========================
  static Future<Development> getById(
      String id, {
        required MarketHub hub,
      }) async {
    final query = _supabase
        .from('developments')
        .select()
        .eq('id', id)
        .eq('hub', hub.dbValue);

    final response = await query.single();
    return Development.fromJson(response);
  }
}

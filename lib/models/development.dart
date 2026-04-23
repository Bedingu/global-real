import 'dart:convert';
import 'market_hub.dart';

class Development {
  final MarketHub hub;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;

  final int availableUnits;
  final DateTime createdAt;

  final List<String> images;
  final String id;
  final String name;
  final String location;
  final String deliveryDate;
  final String type;

  final double avgDailyRate;
  final double occupancyRate;
  final double cleaningFee;
  final double condoFeeMonthly;
  final double managementFeePct;

  final int listingCount;
  final List<String> demandDrivers;

  final String localizacaoMaps;
  final String? nearestSubwayName;
  final int? nearestSubwayDistanceMeters;

  final Map<String, bool>? amenities;
  final double capex;
  final String aPartirDe;

  const Development({
    required this.id,
    required this.hub,
    required this.name,
    required this.location,
    required this.deliveryDate,
    required this.type,
    required this.avgDailyRate,
    required this.occupancyRate,
    required this.cleaningFee,
    required this.condoFeeMonthly,
    required this.managementFeePct,
    required this.listingCount,
    required this.demandDrivers,
    required this.localizacaoMaps,
    this.nearestSubwayName,
    this.nearestSubwayDistanceMeters,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.availableUnits,
    required this.createdAt,
    this.amenities,
    this.capex = 200000,
    this.aPartirDe = '200000',
  });

  factory Development.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) {
        return double.tryParse(
          v.replaceAll(',', '.').replaceAll('%', ''),
        ) ??
            0;
      }
      return 0;
    }

    // --- HUB PARSER ROBUSTO ---
    MarketHub parseHub(dynamic v) {
      final value = v?.toString().toLowerCase() ?? '';
      switch (value) {
        case 'florida':
          return MarketHub.florida;
        case 'saopaulo':
        case 'sao_paulo':
        case 'sao-paulo':
        case 'sp':
          return MarketHub.saoPaulo;
        default:
          return MarketHub.saoPaulo;
      }
    }

    // --- DEMAND DRIVERS ROBUSTO ---
    List<String> parseDrivers(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      if (v is String && v.contains('[')) {
        try {
          return (jsonDecode(v) as List).map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    // --- AMENITIES SEGURO ---
    Map<String, bool>? parseAmenities(dynamic v) {
      if (v == null) return null;
      if (v is Map) {
        return v.map(
              (key, value) => MapEntry(key.toString(), value == true),
        );
      }
      return null;
    }

    return Development(
      id: json['id'].toString(),
      hub: parseHub(json['hub']),
      name: json['empreendimentos'] ?? '',
      location: json['localizacao'] ?? json['localização'] ?? '',
      deliveryDate: json['data_de_entrega'] ?? '',
      type: json['tipo'] ?? '',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      maxGuests: json['max_guests'] ?? 0,
      avgDailyRate: toDouble(json['avg_daily_rate']),
      occupancyRate: toDouble(json['occupancy_rate']),
      cleaningFee: toDouble(json['cleaning_fee']),
      condoFeeMonthly: toDouble(json['condo_fee_monthly']),
      managementFeePct: toDouble(json['management_fee_pct']),
      listingCount: json['listing_count'] ?? 0,
      demandDrivers: parseDrivers(json['demand_drivers']),
      localizacaoMaps: json['localizacao_maps'] ?? '',
      nearestSubwayName: json['nearest_subway_name'],
      nearestSubwayDistanceMeters: json['nearest_subway_distance_m'],
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      availableUnits: json['available_units'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      amenities: parseAmenities(json['amenities']),
      capex: toDouble(json['capex']),
      aPartirDe: json['a_partir_de']?.toString() ?? '200000',
    );
  }
}

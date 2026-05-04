import 'package:flutter_test/flutter_test.dart';
import 'package:global_real/models/development.dart';
import 'package:global_real/models/market_hub.dart';

void main() {
  group('Development.fromJson', () {
    test('parseia JSON completo corretamente', () {
      final json = {
        'id': '123',
        'hub': 'sao_paulo',
        'empreendimentos': 'Edifício Teste',
        'localização': 'Vila Mariana, SP',
        'data_de_entrega': 'Q2 2026',
        'tipo': 'Apartamento',
        'bedrooms': 2,
        'bathrooms': 1,
        'max_guests': 4,
        'avg_daily_rate': 350.0,
        'occupancy_rate': 0.85,
        'cleaning_fee': 150.0,
        'condo_fee_monthly': 800.0,
        'management_fee_pct': 0.20,
        'listing_count': 45,
        'demand_drivers': ['university', 'airport'],
        'localizacao_maps': 'Vila Mariana, São Paulo',
        'nearest_subway_name': 'Vila Mariana',
        'nearest_subway_distance_m': 200,
        'images': ['img1.jpg', 'img2.jpg'],
        'available_units': 10,
        'created_at': '2025-01-15T10:00:00Z',
        'capex': 450000.0,
        'a_partir_de': '350000',
      };

      final dev = Development.fromJson(json);

      expect(dev.id, '123');
      expect(dev.hub, MarketHub.saoPaulo);
      expect(dev.name, 'Edifício Teste');
      expect(dev.location, 'Vila Mariana, SP');
      expect(dev.deliveryDate, 'Q2 2026');
      expect(dev.type, 'Apartamento');
      expect(dev.bedrooms, 2);
      expect(dev.bathrooms, 1);
      expect(dev.maxGuests, 4);
      expect(dev.avgDailyRate, 350.0);
      expect(dev.occupancyRate, 0.85);
      expect(dev.listingCount, 45);
      expect(dev.demandDrivers, ['university', 'airport']);
      expect(dev.nearestSubwayName, 'Vila Mariana');
      expect(dev.nearestSubwayDistanceMeters, 200);
      expect(dev.images.length, 2);
      expect(dev.availableUnits, 10);
      expect(dev.capex, 450000.0);
      expect(dev.aPartirDe, '350000');
    });

    test('parseia hub florida', () {
      final dev = Development.fromJson(_minimalJson(hub: 'florida'));
      expect(dev.hub, MarketHub.florida);
    });

    test('parseia hub saopaulo (sem underscore)', () {
      final dev = Development.fromJson(_minimalJson(hub: 'saopaulo'));
      expect(dev.hub, MarketHub.saoPaulo);
    });

    test('parseia hub sp', () {
      final dev = Development.fromJson(_minimalJson(hub: 'sp'));
      expect(dev.hub, MarketHub.saoPaulo);
    });

    test('hub desconhecido retorna saoPaulo como padrão', () {
      final dev = Development.fromJson(_minimalJson(hub: 'tokyo'));
      expect(dev.hub, MarketHub.saoPaulo);
    });

    test('lida com valores nulos graciosamente', () {
      final json = {
        'id': '1',
        'created_at': '2025-01-01T00:00:00Z',
      };

      final dev = Development.fromJson(json);

      expect(dev.id, '1');
      expect(dev.name, '');
      expect(dev.location, '');
      expect(dev.bedrooms, 0);
      expect(dev.avgDailyRate, 0.0);
      expect(dev.demandDrivers, isEmpty);
      expect(dev.images, isEmpty);
    });

    test('parseia demand_drivers como string JSON', () {
      final json = _minimalJson();
      json['demand_drivers'] = '["airport", "university"]';

      final dev = Development.fromJson(json);
      expect(dev.demandDrivers, ['airport', 'university']);
    });

    test('parseia avg_daily_rate como string', () {
      final json = _minimalJson();
      json['avg_daily_rate'] = '350,50';

      final dev = Development.fromJson(json);
      expect(dev.avgDailyRate, 350.50);
    });

    test('parseia amenities corretamente', () {
      final json = _minimalJson();
      json['amenities'] = {
        'pool': true,
        'parking': false,
        'air_conditioning': true,
      };

      final dev = Development.fromJson(json);
      expect(dev.amenities, isNotNull);
      expect(dev.amenities!['pool'], true);
      expect(dev.amenities!['parking'], false);
      expect(dev.amenities!['air_conditioning'], true);
    });

    test('amenities null retorna null', () {
      final dev = Development.fromJson(_minimalJson());
      expect(dev.amenities, isNull);
    });

    test('images vazio retorna lista vazia', () {
      final json = _minimalJson();
      json['images'] = null;

      final dev = Development.fromJson(json);
      expect(dev.images, isEmpty);
    });
  });
}

Map<String, dynamic> _minimalJson({String hub = 'sao_paulo'}) {
  return {
    'id': '1',
    'hub': hub,
    'empreendimentos': 'Test',
    'localização': 'SP',
    'data_de_entrega': 'Q1 2026',
    'tipo': 'Apartamento',
    'bedrooms': 1,
    'bathrooms': 1,
    'max_guests': 2,
    'listing_count': 10,
    'images': [],
    'available_units': 5,
    'created_at': '2025-01-01T00:00:00Z',
  };
}

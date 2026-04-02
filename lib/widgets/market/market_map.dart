import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/development.dart';

class MarketMap extends StatelessWidget {
  final List<Development> markets;

  const MarketMap({
    super.key,
    required this.markets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: _initialCameraPosition(),
          markers: _buildMarkers(),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  // ===============================
  // CAMERA
  // ===============================
  CameraPosition _initialCameraPosition() {
    if (markets.isNotEmpty &&
        markets.first.nearestSubwayDistanceMeters != null) {
      // fallback simples: Brasil
      return const CameraPosition(
        target: LatLng(-14.2350, -51.9253),
        zoom: 4,
      );
    }

    return const CameraPosition(
      target: LatLng(-14.2350, -51.9253),
      zoom: 4,
    );
  }

  // ===============================
  // MARKERS
  // ===============================
  Set<Marker> _buildMarkers() {
    return markets
        .where(
          (m) =>
      m.nearestSubwayDistanceMeters != null &&
          m.localizacaoMaps.isNotEmpty,
    )
        .map((m) {
      final coords = _parseLatLng(m.localizacaoMaps);
      if (coords == null) return null;

      return Marker(
        markerId: MarkerId(m.id),
        position: coords,
        infoWindow: InfoWindow(
          title: m.name,
          snippet: m.location,
        ),
      );
    })
        .whereType<Marker>()
        .toSet();
  }

  // ===============================
  // HELPERS
  // ===============================
  LatLng? _parseLatLng(String value) {
    // Esperado: "lat,lng"
    final parts = value.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());

    if (lat == null || lng == null) return null;

    return LatLng(lat, lng);
  }
}

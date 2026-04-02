class ProximityFilter {
  final int? maxSubwayDistanceMeters;
  final int? maxAirportDistanceKm;

  const ProximityFilter({
    this.maxSubwayDistanceMeters,
    this.maxAirportDistanceKm,
  });

  ProximityFilter copyWith({
    int? maxSubwayDistanceMeters,
    int? maxAirportDistanceKm,
  }) {
    return ProximityFilter(
      maxSubwayDistanceMeters:
      maxSubwayDistanceMeters ?? this.maxSubwayDistanceMeters,
      maxAirportDistanceKm:
      maxAirportDistanceKm ?? this.maxAirportDistanceKm,
    );
  }

  bool get isActive =>
      maxSubwayDistanceMeters != null ||
          maxAirportDistanceKm != null;
}

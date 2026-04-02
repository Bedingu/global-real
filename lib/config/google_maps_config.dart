class GoogleMapsConfig {
  // Lê de --dart-define=GOOGLE_MAPS_API_KEY=... se disponível,
  // senão usa a chave padrão abaixo.
  static const apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyAfkTMK6054qNC78q6p-UBv3BF8ig9EmVQ',
  );
}

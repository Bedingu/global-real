class GoogleMapsConfig {
  // Chave deve ser passada via --dart-define=GOOGLE_MAPS_API_KEY=...
  // ou definida no .env (nunca hardcoded no código)
  static const apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}

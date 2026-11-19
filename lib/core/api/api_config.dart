/// Centralise les URLs de l'API selon l'environnement de build.
///
/// Utilisation :
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
///
/// Par défaut, pointe sur l'émulateur Android qui route 10.0.2.2 vers le
/// localhost de la machine hôte. Pour un appareil physique en WiFi local,
/// remplacez par l'IP de votre machine sur le réseau (ex. 192.168.1.x).
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.121.173:8085',
  );

  static String get httpBaseUrl => '$baseUrl/api/v1';

  static String get wsBaseUrl {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.authority}/api/v1/ws';
  }
}

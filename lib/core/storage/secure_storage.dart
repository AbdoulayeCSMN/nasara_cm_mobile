import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Enveloppe autour de flutter_secure_storage — garde le JWT dans le
/// keystore Android / keychain iOS plutôt qu'en clair (SharedPreferences).
class SecureStorage {
  static const _cleToken = 'nasara_jwt_token';
  static const _cleUtilisateurId = 'nasara_utilisateur_id';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> sauvegarderSession(String token, String utilisateurId) async {
    await _storage.write(key: _cleToken, value: token);
    await _storage.write(key: _cleUtilisateurId, value: utilisateurId);
  }

  Future<String?> lireToken() => _storage.read(key: _cleToken);

  Future<String?> lireUtilisateurId() => _storage.read(key: _cleUtilisateurId);

  Future<void> effacerSession() async {
    await _storage.delete(key: _cleToken);
    await _storage.delete(key: _cleUtilisateurId);
  }
}

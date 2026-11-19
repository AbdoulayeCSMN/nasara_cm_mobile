import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/utilisateur.dart';

class SessionAuth {
  final String token;
  final Utilisateur utilisateur;

  SessionAuth({required this.token, required this.utilisateur});
}

class AuthRepository {
  final ApiClient _api;
  final SecureStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<SessionAuth> inscrire({
    required String nom,
    required String telephone,
    String? email,
    required String motDePasse,
  }) async {
    try {
      final reponse = await _api.dio.post('/auth/inscription', data: {
        'nom': nom,
        'telephone': telephone,
        if (email != null && email.isNotEmpty) 'email': email,
        'mot_de_passe': motDePasse,
      });
      return await _traiterReponse(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de l\'inscription');
    }
  }

  Future<SessionAuth> connecter({
    required String telephone,
    required String motDePasse,
  }) async {
    try {
      final reponse = await _api.dio.post('/auth/connexion', data: {
        'telephone': telephone,
        'mot_de_passe': motDePasse,
      });
      return await _traiterReponse(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de la connexion');
    }
  }

  Future<SessionAuth> _traiterReponse(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final utilisateur = Utilisateur.fromJson(data['utilisateur'] as Map<String, dynamic>);
    await _storage.sauvegarderSession(token, utilisateur.id);
    return SessionAuth(token: token, utilisateur: utilisateur);
  }

  Future<void> deconnecter() => _storage.effacerSession();

  Future<bool> estConnecte() async {
    final token = await _storage.lireToken();
    return token != null;
  }
}

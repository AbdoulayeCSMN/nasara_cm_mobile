import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/utilisateur.dart';
import '../data/auth_repository.dart';

final secureStorageProvider = Provider((ref) => SecureStorage());

final apiClientProvider = Provider((ref) {
  return ApiClient(storage: ref.read(secureStorageProvider));
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
  );
});

/// État d'authentification global de l'app.
class AuthState {
  final bool chargement;
  final Utilisateur? utilisateur;
  final String? erreur;

  const AuthState({this.chargement = false, this.utilisateur, this.erreur});

  bool get estConnecte => utilisateur != null;

  AuthState copierAvec({
    bool? chargement,
    Utilisateur? utilisateur,
    String? erreur,
    bool effacerErreur = false,
    bool effacerUtilisateur = false,
  }) {
    return AuthState(
      chargement: chargement ?? this.chargement,
      utilisateur: effacerUtilisateur ? null : (utilisateur ?? this.utilisateur),
      erreur: effacerErreur ? null : (erreur ?? this.erreur),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<void> inscrire({
    required String nom,
    required String telephone,
    String? email,
    required String motDePasse,
  }) async {
    state = state.copierAvec(chargement: true, effacerErreur: true);
    try {
      final session = await _repo.inscrire(
        nom: nom,
        telephone: telephone,
        email: email,
        motDePasse: motDePasse,
      );
      state = AuthState(utilisateur: session.utilisateur);
    } catch (e) {
      state = state.copierAvec(chargement: false, erreur: e.toString());
    }
  }

  Future<void> connecter({required String telephone, required String motDePasse}) async {
    state = state.copierAvec(chargement: true, effacerErreur: true);
    try {
      final session = await _repo.connecter(telephone: telephone, motDePasse: motDePasse);
      state = AuthState(utilisateur: session.utilisateur);
    } catch (e) {
      state = state.copierAvec(chargement: false, erreur: e.toString());
    }
  }

  Future<void> deconnecter() async {
    await _repo.deconnecter();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

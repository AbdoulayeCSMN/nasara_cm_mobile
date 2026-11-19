import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../models/boutique.dart';

class BoutiqueRepository {
  final ApiClient _api;
  BoutiqueRepository(this._api);

  Future<List<Boutique>> lister({String? ville}) async {
    try {
      final reponse = await _api.dio.get('/boutiques', queryParameters: {
        if (ville != null && ville.isNotEmpty) 'ville': ville,
      });
      return (reponse.data as List).map((e) => Boutique.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors du chargement des boutiques');
    }
  }

  Future<Boutique> recuperer(String id) async {
    try {
      final reponse = await _api.dio.get('/boutiques/$id');
      return Boutique.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Boutique introuvable');
    }
  }

  Future<Boutique> creer({required String nom, String? description, String? ville}) async {
    try {
      final reponse = await _api.dio.post('/boutiques', data: {
        'nom': nom,
        if (description != null) 'description': description,
        if (ville != null) 'ville': ville,
      });
      return Boutique.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de la création de la boutique');
    }
  }

  Future<List<Boutique>> mesBoutiques() async {
    try {
      final reponse = await _api.dio.get('/mes-boutiques');
      return (reponse.data as List).map((e) => Boutique.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors du chargement de vos boutiques');
    }
  }
}

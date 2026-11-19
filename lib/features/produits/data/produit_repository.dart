import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../models/produit.dart';

class ProduitRepository {
  final ApiClient _api;
  ProduitRepository(this._api);

  Future<Produit> recuperer(String id) async {
    try {
      final reponse = await _api.dio.get('/produits/$id');
      return Produit.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Produit introuvable');
    }
  }

  Future<List<Produit>> listerParBoutique(String boutiqueId) async {
    try {
      final reponse = await _api.dio.get('/boutiques/$boutiqueId/produits');
      return (reponse.data as List).map((e) => Produit.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors du chargement des produits');
    }
  }

  Future<List<Produit>> rechercher(String motCle) async {
    try {
      final reponse = await _api.dio.get('/produits', queryParameters: {'q': motCle});
      return (reponse.data as List).map((e) => Produit.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de la recherche');
    }
  }

  Future<Produit> creer({
    required String boutiqueId,
    required String titre,
    String? description,
    required double prix,
  }) async {
    try {
      final reponse = await _api.dio.post('/produits', data: {
        'boutique_id': boutiqueId,
        'titre': titre,
        if (description != null) 'description': description,
        'prix': prix,
      });
      return Produit.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de la création du produit');
    }
  }

  Future<void> ajouterPhoto(String produitId, String url) async {
    try {
      await _api.dio.post('/produits/$produitId/photos', data: {'url': url, 'ordre': 0});
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de l\'ajout de la photo');
    }
  }
}

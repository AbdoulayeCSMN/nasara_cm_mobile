import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/produit.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/produit_repository.dart';

final produitRepositoryProvider = Provider((ref) {
  return ProduitRepository(ref.read(apiClientProvider));
});

final produitsParBoutiqueProvider =
    FutureProvider.family<List<Produit>, String>((ref, boutiqueId) async {
  return ref.read(produitRepositoryProvider).listerParBoutique(boutiqueId);
});

final detailProduitProvider = FutureProvider.family<Produit, String>((ref, id) async {
  return ref.read(produitRepositoryProvider).recuperer(id);
});

final rechercheProduitsProvider =
    FutureProvider.family<List<Produit>, String>((ref, motCle) async {
  if (motCle.trim().isEmpty) return [];
  return ref.read(produitRepositoryProvider).rechercher(motCle);
});

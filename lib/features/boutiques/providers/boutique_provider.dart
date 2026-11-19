import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/boutique.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/boutique_repository.dart';

final boutiqueRepositoryProvider = Provider((ref) {
  return BoutiqueRepository(ref.read(apiClientProvider));
});

/// Liste publique des boutiques, avec filtre optionnel par ville.
final listeBoutiquesProvider =
    FutureProvider.family<List<Boutique>, String?>((ref, ville) async {
  return ref.read(boutiqueRepositoryProvider).lister(ville: ville);
});

final mesBoutiquesProvider = FutureProvider<List<Boutique>>((ref) async {
  return ref.read(boutiqueRepositoryProvider).mesBoutiques();
});

final detailBoutiqueProvider = FutureProvider.family<Boutique, String>((ref, id) async {
  return ref.read(boutiqueRepositoryProvider).recuperer(id);
});

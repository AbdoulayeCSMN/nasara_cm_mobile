import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/ecran_connexion.dart';
import '../../features/auth/screens/ecran_inscription.dart';
import '../../features/boutiques/screens/ecran_liste_boutiques.dart';
import '../../features/boutiques/screens/ecran_mes_boutiques.dart';
import '../../features/produits/screens/ecran_detail_boutique.dart';
import '../../features/produits/screens/ecran_detail_produit.dart';
import '../../features/messagerie/screens/ecran_liste_conversations.dart';
import '../../features/messagerie/screens/ecran_chat.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/connexion',
    redirect: (context, state) {
      final estConnecte = ref.read(authProvider).estConnecte;
      final surPageAuth = state.matchedLocation == '/connexion' || state.matchedLocation == '/inscription';

      if (!estConnecte && !surPageAuth) return '/connexion';
      if (estConnecte && surPageAuth) return '/boutiques';
      return null;
    },
    routes: [
      GoRoute(path: '/connexion', builder: (context, state) => const EcranConnexion()),
      GoRoute(path: '/inscription', builder: (context, state) => const EcranInscription()),
      GoRoute(path: '/boutiques', builder: (context, state) => const EcranListeBoutiques()),
      GoRoute(path: '/mes-boutiques', builder: (context, state) => const EcranMesBoutiques()),
      GoRoute(
        path: '/boutiques/:id',
        builder: (context, state) => EcranDetailBoutique(boutiqueId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/produits/:id',
        builder: (context, state) => EcranDetailProduit(produitId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/conversations', builder: (context, state) => const EcranListeConversations()),
      GoRoute(
        path: '/conversations/:id',
        builder: (context, state) => EcranChat(
          conversationId: state.pathParameters['id']!,
          produitIdContexte: state.uri.queryParameters['produit'],
        ),
      ),
    ],
  );
});

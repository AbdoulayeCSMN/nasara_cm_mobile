import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/messagerie.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/messagerie_repository.dart';
import '../data/websocket_service.dart';

final messagerieRepositoryProvider = Provider((ref) {
  return MessagerieRepository(ref.read(apiClientProvider));
});

final mesConversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  return ref.read(messagerieRepositoryProvider).mesConversations();
});

/// Service WebSocket unique, partagé par toute l'app tant que l'utilisateur
/// est connecté. Il faut appeler `connecter(token)` une fois après le login
/// (voir main.dart / routeur) et `dispose()` à la déconnexion.
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

/// État des messages d'une conversation donnée : historique REST au chargement,
/// puis messages ajoutés au fil de l'eau via le flux WebSocket.
class ConversationChatNotifier extends StateNotifier<List<Message>> {
  final MessagerieRepository _repo;
  final WebSocketService _ws;
  final String conversationId;

  ConversationChatNotifier(this._repo, this._ws, this.conversationId) : super([]) {
    _chargerHistorique();
    _ws.messages.listen((message) {
      if (message.conversationId == conversationId) {
        state = [...state, message];
      }
    });
  }

  Future<void> _chargerHistorique() async {
    final historique = await _repo.historiqueMessages(conversationId);
    state = historique;
  }

  void envoyer(String contenu, {String? produitId}) {
    final messageOptimiste = Message(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      expediteurId: '', // rempli par le serveur à la confirmation
      produitId: produitId,
      contenu: contenu,
      lu: false,
      dateEnvoi: DateTime.now(),
    );
    _ws.envoyer(messageOptimiste);
  }
}

final conversationChatProvider = StateNotifierProvider.family<ConversationChatNotifier, List<Message>, String>(
  (ref, conversationId) {
    return ConversationChatNotifier(
      ref.read(messagerieRepositoryProvider),
      ref.read(webSocketServiceProvider),
      conversationId,
    );
  },
);

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../models/messagerie.dart';

class MessagerieRepository {
  final ApiClient _api;
  MessagerieRepository(this._api);

  Future<Conversation> demarrerConversation(String autreUtilisateurId) async {
    try {
      final reponse = await _api.dio.post('/conversations', data: {
        'autre_utilisateur_id': autreUtilisateurId,
      });
      return Conversation.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors de la création de la conversation');
    }
  }

  Future<List<Conversation>> mesConversations() async {
    try {
      final reponse = await _api.dio.get('/conversations');
      return (reponse.data as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors du chargement des conversations');
    }
  }

  Future<List<Message>> historiqueMessages(String conversationId) async {
    try {
      final reponse = await _api.dio.get('/conversations/$conversationId/messages');
      return (reponse.data as List).map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Erreur lors du chargement des messages');
    }
  }
}

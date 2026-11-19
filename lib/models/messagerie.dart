class Conversation {
  final String id;
  final String utilisateur1Id;
  final String utilisateur2Id;
  final DateTime dateCreation;

  Conversation({
    required this.id,
    required this.utilisateur1Id,
    required this.utilisateur2Id,
    required this.dateCreation,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      utilisateur1Id: json['utilisateur_1_id'] as String,
      utilisateur2Id: json['utilisateur_2_id'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  /// Retourne l'ID de l'autre participant, étant donné son propre ID.
  String autreParticipant(String monId) {
    return utilisateur1Id == monId ? utilisateur2Id : utilisateur1Id;
  }
}

class Message {
  final String id;
  final String conversationId;
  final String expediteurId;
  final String? produitId;
  final String contenu;
  final bool lu;
  final DateTime dateEnvoi;

  Message({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    this.produitId,
    required this.contenu,
    required this.lu,
    required this.dateEnvoi,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      expediteurId: json['expediteur_id'] as String,
      produitId: json['produit_id'] as String?,
      contenu: json['contenu'] as String,
      lu: json['lu'] as bool? ?? false,
      dateEnvoi: DateTime.parse(json['date_envoi'] as String),
    );
  }

  Map<String, dynamic> versEnvoiWebSocket() {
    return {
      'conversation_id': conversationId,
      if (produitId != null) 'produit_id': produitId,
      'contenu': contenu,
    };
  }
}

class Utilisateur {
  final String id;
  final String nom;
  final DateTime dateCreation;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.dateCreation,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as String,
      nom: json['nom'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }
}

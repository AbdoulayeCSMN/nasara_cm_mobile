class Boutique {
  final String id;
  final String utilisateurId;
  final String nom;
  final String? description;
  final String? logoUrl;
  final String? couvertureUrl;
  final String? ville;
  final String statut;
  final DateTime dateCreation;

  Boutique({
    required this.id,
    required this.utilisateurId,
    required this.nom,
    this.description,
    this.logoUrl,
    this.couvertureUrl,
    this.ville,
    required this.statut,
    required this.dateCreation,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    return Boutique(
      id: json['id'] as String,
      utilisateurId: json['utilisateur_id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      couvertureUrl: json['couverture_url'] as String?,
      ville: json['ville'] as String?,
      statut: json['statut'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }
}

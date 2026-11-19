class Produit {
  final String id;
  final String boutiqueId;
  final int? categorieId;
  final String titre;
  final String? description;
  final double prix;
  final bool disponible;
  final DateTime dateCreation;
  final List<String> photos;

  Produit({
    required this.id,
    required this.boutiqueId,
    this.categorieId,
    required this.titre,
    this.description,
    required this.prix,
    required this.disponible,
    required this.dateCreation,
    this.photos = const [],
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as String,
      boutiqueId: json['boutique_id'] as String,
      categorieId: json['categorie_id'] as int?,
      titre: json['titre'] as String,
      description: json['description'] as String?,
      prix: (json['prix'] as num).toDouble(),
      disponible: json['disponible'] as bool,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

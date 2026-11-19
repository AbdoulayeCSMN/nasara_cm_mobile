import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../boutiques/providers/boutique_provider.dart';
import '../../messagerie/providers/messagerie_provider.dart';
import '../providers/produit_provider.dart';

class EcranDetailProduit extends ConsumerWidget {
  final String produitId;
  const EcranDetailProduit({super.key, required this.produitId});

  Future<void> _contacterVendeur(BuildContext context, WidgetRef ref, String boutiqueId) async {
    final boutique = await ref.read(detailBoutiqueProvider(boutiqueId).future);
    final conv = await ref
        .read(messagerieRepositoryProvider)
        .demarrerConversation(boutique.utilisateurId);
    if (context.mounted) {
      context.push('/conversations/${conv.id}?produit=$produitId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitAsync = ref.watch(detailProduitProvider(produitId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du produit')),
      body: produitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (p) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.photos.isNotEmpty)
                SizedBox(
                  height: 280,
                  child: PageView(
                    children: p.photos.map((url) => Image.network(url, fit: BoxFit.cover)).toList(),
                  ),
                )
              else
                Container(
                  height: 280,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.titre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${p.prix.toStringAsFixed(0)} FCFA',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 16),
                    if (p.description != null) Text(p.description!),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Contacter le vendeur à propos de ce produit'),
                      onPressed: () => _contacterVendeur(context, ref, p.boutiqueId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

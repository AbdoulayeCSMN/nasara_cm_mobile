import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../boutiques/providers/boutique_provider.dart';
import '../../messagerie/providers/messagerie_provider.dart';
import '../providers/produit_provider.dart';

class EcranDetailBoutique extends ConsumerWidget {
  final String boutiqueId;
  const EcranDetailBoutique({super.key, required this.boutiqueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boutiqueAsync = ref.watch(detailBoutiqueProvider(boutiqueId));
    final produitsAsync = ref.watch(produitsParBoutiqueProvider(boutiqueId));

    return Scaffold(
      appBar: AppBar(
        title: boutiqueAsync.when(
          data: (b) => Text(b.nom),
          loading: () => const Text('...'),
          error: (_, __) => const Text('Boutique'),
        ),
        actions: [
          boutiqueAsync.maybeWhen(
            data: (b) => IconButton(
              icon: const Icon(Icons.chat),
              tooltip: 'Contacter le vendeur',
              onPressed: () async {
                final conv = await ref
                    .read(messagerieRepositoryProvider)
                    .demarrerConversation(b.utilisateurId);
                if (context.mounted) {
                  context.push('/conversations/${conv.id}');
                }
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: produitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (produits) {
          if (produits.isEmpty) {
            return const Center(child: Text('Aucun produit dans cette boutique'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final p = produits[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/produits/${p.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: p.photos.isNotEmpty
                            ? Image.network(p.photos.first, fit: BoxFit.cover, width: double.infinity)
                            : Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${p.prix.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

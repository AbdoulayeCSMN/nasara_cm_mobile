import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/boutique_provider.dart';

class EcranMesBoutiques extends ConsumerWidget {
  const EcranMesBoutiques({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesBoutiquesAsync = ref.watch(mesBoutiquesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes boutiques')),
      body: mesBoutiquesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (boutiques) {
          if (boutiques.isEmpty) {
            return const Center(child: Text('Vous n\'avez pas encore de boutique'));
          }
          return ListView.builder(
            itemCount: boutiques.length,
            itemBuilder: (context, index) {
              final b = boutiques[index];
              return ListTile(
                title: Text(b.nom),
                subtitle: Text(b.ville ?? ''),
                onTap: () => context.push('/boutiques/${b.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Créer une boutique'),
        onPressed: () => _ouvrirFormulaireCreation(context, ref),
      ),
    );
  }

  void _ouvrirFormulaireCreation(BuildContext context, WidgetRef ref) {
    final nomCtrl = TextEditingController();
    final villeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nouvelle boutique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom de la boutique')),
            const SizedBox(height: 8),
            TextField(controller: villeCtrl, decoration: const InputDecoration(labelText: 'Ville')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (nomCtrl.text.trim().length < 2) return;
                await ref.read(boutiqueRepositoryProvider).creer(
                      nom: nomCtrl.text.trim(),
                      ville: villeCtrl.text.trim().isEmpty ? null : villeCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    );
                ref.invalidate(mesBoutiquesProvider);
                ref.invalidate(listeBoutiquesProvider);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}

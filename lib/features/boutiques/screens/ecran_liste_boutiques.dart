import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/boutique_provider.dart';

class EcranListeBoutiques extends ConsumerStatefulWidget {
  const EcranListeBoutiques({super.key});

  @override
  ConsumerState<EcranListeBoutiques> createState() => _EcranListeBoutiquesState();
}

class _EcranListeBoutiquesState extends ConsumerState<EcranListeBoutiques> {
  String? _villeFiltre;

  @override
  Widget build(BuildContext context) {
    final boutiquesAsync = ref.watch(listeBoutiquesProvider(_villeFiltre));

    return Scaffold(
      appBar: AppBar(
        title: const Text('NASARA Central Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/conversations'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).deconnecter();
              if (context.mounted) context.go('/connexion');
            },
          ),
        ],
      ),
      body: boutiquesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (boutiques) {
          if (boutiques.isEmpty) {
            return const Center(child: Text('Aucune boutique pour le moment'));
          }
          return ListView.builder(
            itemCount: boutiques.length,
            itemBuilder: (context, index) {
              final b = boutiques[index];
              return ListTile(
                leading: CircleAvatar(child: Text(b.nom.substring(0, 1).toUpperCase())),
                title: Text(b.nom),
                subtitle: Text(b.ville ?? 'Ville non renseignée'),
                onTap: () => context.push('/boutiques/${b.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/mes-boutiques'),
        child: const Icon(Icons.storefront),
      ),
    );
  }
}

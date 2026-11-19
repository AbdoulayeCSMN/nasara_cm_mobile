import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/messagerie_provider.dart';

class EcranListeConversations extends ConsumerWidget {
  const EcranListeConversations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(mesConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('Aucune conversation pour le moment'));
          }
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final c = conversations[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Conversation'),
                subtitle: Text('Démarrée le ${c.dateCreation.day}/${c.dateCreation.month}/${c.dateCreation.year}'),
                onTap: () => context.push('/conversations/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/messagerie_provider.dart';

class EcranChat extends ConsumerStatefulWidget {
  final String conversationId;
  final String? produitIdContexte;

  const EcranChat({super.key, required this.conversationId, this.produitIdContexte});

  @override
  ConsumerState<EcranChat> createState() => _EcranChatState();
}

class _EcranChatState extends ConsumerState<EcranChat> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _envoyer() {
    final texte = _messageCtrl.text.trim();
    if (texte.isEmpty) return;
    ref.read(conversationChatProvider(widget.conversationId).notifier)
        .envoyer(texte, produitId: widget.produitIdContexte);
    _messageCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationChatProvider(widget.conversationId));
    final monId = ref.watch(authProvider).utilisateur?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                final estMoi = m.expediteurId == monId || m.expediteurId.isEmpty;
                return Align(
                  alignment: estMoi ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: estMoi
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.contenu),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _envoyer(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _envoyer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

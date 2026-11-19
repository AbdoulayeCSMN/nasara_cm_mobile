import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class EcranConnexion extends ConsumerStatefulWidget {
  const EcranConnexion({super.key});

  @override
  ConsumerState<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends ConsumerState<EcranConnexion> {
  final _cleForm = GlobalKey<FormState>();
  final _telephoneCtrl = TextEditingController();
  final _motDePasseCtrl = TextEditingController();

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _motDePasseCtrl.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_cleForm.currentState!.validate()) return;
    await ref.read(authProvider.notifier).connecter(
          telephone: _telephoneCtrl.text.trim(),
          motDePasse: _motDePasseCtrl.text,
        );
    if (mounted && ref.read(authProvider).estConnecte) {
      context.go('/boutiques');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _cleForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'NASARA Central Market',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _telephoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  hintText: '+22790112233',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Le téléphone est requis';
                  if (!v.startsWith('+')) return 'Format international requis, ex. +22790112233';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motDePasseCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Minimum 8 caractères';
                  return null;
                },
              ),
              if (authState.erreur != null) ...[
                const SizedBox(height: 12),
                Text(authState.erreur!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: authState.chargement ? null : _soumettre,
                child: authState.chargement
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/inscription'),
                child: const Text('Pas de compte ? Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

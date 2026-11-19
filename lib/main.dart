import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/messagerie/providers/messagerie_provider.dart';

void main() {
  runApp(const ProviderScope(child: NasaraApp()));
}

class NasaraApp extends ConsumerStatefulWidget {
  const NasaraApp({super.key});

  @override
  ConsumerState<NasaraApp> createState() => _NasaraAppState();
}

class _NasaraAppState extends ConsumerState<NasaraApp> {
  @override
  void initState() {
    super.initState();
    // Connecte automatiquement le WebSocket si une session existe déjà
    // (retour dans l'app après avoir été connecté précédemment).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.lireToken();
      if (token != null) {
        ref.read(webSocketServiceProvider).connecter(token);
      }
    });

    // Reconnecte le WebSocket dès qu'une nouvelle session démarre (login/inscription).
    ref.listenManual(authProvider, (previous, next) async {
      if (next.estConnecte && previous?.estConnecte != true) {
        final storage = ref.read(secureStorageProvider);
        final token = await storage.lireToken();
        if (token != null) {
          ref.read(webSocketServiceProvider).connecter(token);
        }
      } else if (!next.estConnecte) {
        ref.read(webSocketServiceProvider).deconnecter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NASARA Central Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD97706)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

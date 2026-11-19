import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/api/api_config.dart';
import '../../../models/messagerie.dart';

/// Gère une connexion WebSocket unique vers /api/v1/ws et expose les
/// messages entrants comme un Stream, avec reconnexion automatique.
class WebSocketService {
  WebSocketChannel? _channel;
  final _controleurMessages = StreamController<Message>.broadcast();
  final _controleurErreurs = StreamController<String>.broadcast();
  Timer? _timerReconnexion;
  String? _tokenActuel;
  bool _fermeVolontairement = false;

  Stream<Message> get messages => _controleurMessages.stream;
  Stream<String> get erreurs => _controleurErreurs.stream;

  void connecter(String token) {
    _fermeVolontairement = false;
    _tokenActuel = token;
    _ouvrirConnexion();
  }

  void _ouvrirConnexion() {
    if (_tokenActuel == null) return;
    final uri = Uri.parse('${ApiConfig.wsBaseUrl}?token=$_tokenActuel');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (donnee) {
        try {
          final json = jsonDecode(donnee as String) as Map<String, dynamic>;
          if (json.containsKey('erreur')) {
            _controleurErreurs.add(json['erreur'] as String);
            return;
          }
          _controleurMessages.add(Message.fromJson(json));
        } catch (_) {
          // message mal formé, ignoré silencieusement côté client
        }
      },
      onDone: _planifierReconnexion,
      onError: (_) => _planifierReconnexion(),
    );
  }

  void _planifierReconnexion() {
    if (_fermeVolontairement) return;
    _timerReconnexion?.cancel();
    _timerReconnexion = Timer(const Duration(seconds: 3), _ouvrirConnexion);
  }

  void envoyer(Message message) {
    _channel?.sink.add(jsonEncode(message.versEnvoiWebSocket()));
  }

  void deconnecter() {
    _fermeVolontairement = true;
    _timerReconnexion?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    deconnecter();
    _controleurMessages.close();
    _controleurErreurs.close();
  }
}

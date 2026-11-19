import 'package:dio/dio.dart';

import 'api_config.dart';
import '../storage/secure_storage.dart';

/// Exception métier uniforme, construite à partir des réponses d'erreur
/// du backend Go (`{"erreur": "..."}` ou `{"erreurs": ["...", "..."]}`).
class ApiException implements Exception {
  final int? statutHttp;
  final String message;

  ApiException(this.message, {this.statutHttp});

  @override
  String toString() => message;
}

class ApiClient {
  final Dio dio;
  final SecureStorage _storage;

  ApiClient({SecureStorage? storage})
      : _storage = storage ?? SecureStorage(),
        dio = Dio(BaseOptions(
          baseUrl: ApiConfig.httpBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.lireToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException erreur, handler) {
        handler.next(_normaliser(erreur));
      },
    ));
  }

  DioException _normaliser(DioException erreur) {
    final data = erreur.response?.data;
    String message = 'Erreur réseau — vérifiez votre connexion';

    if (data is Map<String, dynamic>) {
      if (data['erreur'] != null) {
        message = data['erreur'] as String;
      } else if (data['erreurs'] is List) {
        message = (data['erreurs'] as List).join('\n');
      }
    }

    return erreur.copyWith(error: ApiException(message, statutHttp: erreur.response?.statusCode));
  }
}

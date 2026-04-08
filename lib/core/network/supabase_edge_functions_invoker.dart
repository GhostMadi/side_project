import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Обёртка над [SupabaseClient.functions.invoke]: к каждому вызову добавляет
/// `Authorization: Bearer <access_token>` (с обновлением сессии при истечении).
///
/// Новые Edge Functions вызывайте только через этот класс, чтобы JWT не терялся
/// из‑за `putIfAbsent` в [AuthHttpClient].
@lazySingleton
class SupabaseEdgeFunctionsInvoker {
  SupabaseEdgeFunctionsInvoker(this._client);

  final SupabaseClient _client;

  static const _refreshSkewSeconds = 120;

  /// JWT для заголовка `Authorization` (при необходимости обновляет сессию).
  Future<String> requireUserAccessToken() async {
    var session = _client.auth.currentSession;
    if (session == null) {
      throw StateError('Требуется вход в аккаунт');
    }

    final expiresAt = session.expiresAt;
    final needsRefresh = session.isExpired ||
        (expiresAt != null &&
            DateTime.now().toUtc().isAfter(
              DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true)
                  .subtract(const Duration(seconds: _refreshSkewSeconds)),
            ));

    if (needsRefresh) {
      try {
        final refreshed = await _client.auth.refreshSession();
        session = refreshed.session ?? _client.auth.currentSession;
      } on AuthException {
        throw StateError('Сессия истекла. Войдите снова.');
      }
    }

    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Не удалось получить токен авторизации');
    }
    return token;
  }

  /// Вызов функции с JWT пользователя. Заголовок [Authorization] выставляется
  /// последним и перекрывает одноимённый ключ из [headers], если был передан.
  ///
  /// Для **публичных** функций (без пользовательской сессии) передайте
  /// [withUserAuthorization]: false.
  Future<FunctionResponse> invoke(
    String functionName, {
    Map<String, String>? headers,
    Object? body,
    Iterable<http.MultipartFile>? files,
    Map<String, dynamic>? queryParameters,
    HttpMethod method = HttpMethod.post,
    String? region,
    bool withUserAuthorization = true,
  }) async {
    final merged = <String, String>{
      ...?headers,
      if (withUserAuthorization) 'Authorization': 'Bearer ${await requireUserAccessToken()}',
    };
    return _client.functions.invoke(
      functionName,
      headers: merged,
      body: body,
      files: files,
      queryParameters: queryParameters,
      method: method,
      region: region,
    );
  }
}

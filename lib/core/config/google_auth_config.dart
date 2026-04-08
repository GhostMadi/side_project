/// **Синхронизация OAuth после смены/удаления клиента в Google Cloud**
///
/// Ошибка `401: deleted_client` = в приложении или в Supabase всё ещё указан **старый**
/// Client ID. Нужны **новые** credentials из
/// [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials.
///
/// 1. **Web client** (тип «Веб-приложение») — тот же ID и Secret вставить в
///    Supabase → Authentication → Providers → Google. Для Android передавать ID сюда:
///    `flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-id>.apps.googleusercontent.com`
///
/// 2. **iOS client** (тип iOS, Bundle ID = `app.clover.mobile`) — подставить в
///    `ios/Runner/Info.plist`: `GIDClientID` и URL scheme
///    `com.googleusercontent.apps.<суффикс_как_в_client_id_без_домена>`.
///
/// 3. **Android**: в Console для типа Android укажи package `app.clover.mobile` и SHA-1
///    (debug/release). Старый клиент удалён — создай новый Android OAuth client при необходимости.
///
/// Переопределение `serverClientId` из Dart (необязательно на Android, если задан
/// `default_web_client_id` в `android/.../values/strings.xml`).
///
/// **Google native (`google_sign_in`):** в Supabase Dashboard → Authentication →
/// Providers → Google включи **Skip nonce check**. Иначе GoTrue не сойдётся с nonce
/// в id_token от Google (см. `token_oidc.go`: hex(sha256(body)) vs claim).
///
/// В Supabase → Google обычно указывают **Web** client ID + secret.
abstract final class GoogleAuthConfig {
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}

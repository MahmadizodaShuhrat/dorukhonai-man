/// Application-wide constants.
///
/// The single source of truth for the contract is the server's Swagger/OpenAPI
/// (TZ §10). The backend base URL is NOT here — it is configurable at runtime
/// via `ServerConfig`/`serverConfigProvider` (see `core/config/api_config.dart`).
class AppConstants {
  AppConstants._();

  /// Currency code/label used across the app (somoni, TZ §6).
  static const String currencyCode = 'TJS';
  static const String currencySymbol = 'сом.';

  /// Number of fraction digits for money (TZ_00: recommended 2).
  static const int moneyFractionDigits = 2;

  /// Default request timeout.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Secure-storage key for the JWT access token.
  static const String accessTokenKey = 'access_token';

  /// Secure-storage key for the refresh token.
  static const String refreshTokenKey = 'refresh_token';
}

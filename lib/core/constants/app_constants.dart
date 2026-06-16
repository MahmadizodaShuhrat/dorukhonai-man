import '../config/api_config.dart';

/// Application-wide constants.
///
/// The single source of truth for the contract is the server's Swagger/OpenAPI
/// (TZ §10).
class AppConstants {
  AppConstants._();

  /// Base URL of the .NET backend, resolved per platform (see [ApiConfig]).
  /// API version is `/api/v1` (TZ §10).
  static String get apiBaseUrl => ApiConfig.baseUrl;

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

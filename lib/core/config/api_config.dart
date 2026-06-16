import 'package:flutter/foundation.dart';

/// Platform-aware resolution of the backend API base URL.
///
/// The backend during development runs on the host machine at port 5000. How a
/// client reaches that host differs per platform:
///  - web / iOS simulator / macOS / Windows / Linux → `localhost`;
///  - Android emulator → `10.0.2.2` (the emulator's alias for the host loopback).
///
/// For a physical device pointed at a server on the LAN, set [kApiHostOverride]
/// to the server's IP (e.g. `192.168.1.50`). When set, it wins on every
/// platform.
class ApiConfig {
  ApiConfig._();

  /// Optional manual override of the API host (no scheme, no port).
  ///
  /// Leave `null` to use the per-platform defaults below. Set to e.g.
  /// `'192.168.1.50'` to point a real device at a LAN server.
  static const String? kApiHostOverride = null;

  /// Backend port (the .NET API listens on 5000 in development).
  static const int _port = 5000;

  /// API version segment (TZ §10).
  static const String _apiVersionPath = '/api/v1';

  /// Host the current platform should use to reach the dev backend.
  static String get _host {
    if (kApiHostOverride != null) return kApiHostOverride!;
    if (kIsWeb) return 'localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator maps the host loopback to 10.0.2.2.
        return '10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'localhost';
    }
  }

  /// Fully-qualified API base URL, including the `/api/v1` suffix.
  static String get baseUrl => 'http://$_host:$_port$_apiVersionPath';
}

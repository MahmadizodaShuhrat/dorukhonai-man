import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'core/storage/app_preferences.dart';
import 'features/auth/presentation/auth_provider.dart';

/// Desktop platforms this app targets (Windows + macOS; Linux harmless).
bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initWindow();

  // Load non-secret preferences (configurable server URL, etc.) before the
  // first frame so the resolved base URL is ready for the first request.
  final prefs = await SharedPreferences.getInstance();
  final appPreferences = AppPreferences(prefs);

  final container = ProviderContainer(
    overrides: [
      appPreferencesProvider.overrideWithValue(appPreferences),
      sharedPreferencesProvider.overrideWith((ref) => prefs),
    ],
  );
  // Re-hydrate any persisted session before the first frame so the router
  // redirect lands on the right screen.
  await container.read(authControllerProvider.notifier).loadSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

/// Configures the native window for desktop (TZ_03 §E.2): minimum 1100x720,
/// default 1440x900, centred, titled, then shown. Guarded so non-desktop
/// targets (and the test environment) skip it cleanly.
Future<void> _initWindow() async {
  if (!_isDesktop) return;
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(1440, 900),
    minimumSize: Size(1100, 720),
    center: true,
    title: 'Dorukhona',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setMinimumSize(const Size(1100, 720));
    await windowManager.show();
    await windowManager.focus();
  });
}

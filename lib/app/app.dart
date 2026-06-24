import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localization_config.dart';
import '../l10n/app_localizations.dart';
import 'locale_provider.dart';
import 'router.dart';
import 'theme.dart';
import 'theme_mode_provider.dart';

/// Root application widget: wires the go_router config, Material 3 themes and
/// the runtime Tajik/Russian localization (TZ §1/§6, Roadmap step 0) into a
/// [MaterialApp.router].
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: appSupportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      localeResolutionCallback: (deviceLocale, supported) =>
          appLocaleResolution(locale, supported),
      routerConfig: router,
    );
  }
}

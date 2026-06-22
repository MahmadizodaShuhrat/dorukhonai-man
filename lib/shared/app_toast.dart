import 'package:flutter/material.dart';

import '../app/status_colors.dart';

/// Snackbar/toast helper (TZ_03 §B.7/§D). Floating, auto-dismiss; success and
/// error variants tint with [StatusColors]. Call from any widget with a
/// [BuildContext] under a [ScaffoldMessenger].
class AppToast {
  AppToast._();

  static void success(BuildContext context, String message) =>
      _show(context, message, tone: _Tone.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, tone: _Tone.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, tone: _Tone.info);

  static void _show(
    BuildContext context,
    String message, {
    required _Tone tone,
  }) {
    final status = StatusColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      _Tone.success => (status.okContainer, status.ok),
      _Tone.error => (status.dangerContainer, status.danger),
      _Tone.info => (scheme.inverseSurface, scheme.onInverseSurface),
    };
    final icon = switch (tone) {
      _Tone.success => Icons.check_circle_outline,
      _Tone.error => Icons.error_outline,
      _Tone.info => Icons.info_outline,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: bg,
          content: Row(
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: TextStyle(color: fg)),
              ),
            ],
          ),
        ),
      );
  }
}

enum _Tone { success, error, info }

import 'package:flutter/material.dart';

/// Semantic status palette kept OUTSIDE the seed-derived [ColorScheme]
/// (TZ_03 §B.2) so the green/amber/red signals never collide with the
/// Clinical-Teal primary hue. Used for expiry, low-stock, posted/draft, and
/// sync/online state.
///
/// Each token carries a foreground (`*`) and a tonal background (`*Container`)
/// for chips/banners.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.danger,
    required this.dangerContainer,
    required this.warn,
    required this.warnContainer,
    required this.ok,
    required this.okContainer,
    required this.info,
    required this.infoContainer,
    required this.sync,
    required this.syncContainer,
  });

  /// Expired, out-of-stock, offline error.
  final Color danger;
  final Color dangerContainer;

  /// Near expiry (<=30d), low stock, pending sync.
  final Color warn;
  final Color warnContainer;

  /// Healthy, posted, synced/online.
  final Color ok;
  final Color okContainer;

  /// Neutral badge (draft, informational).
  final Color info;
  final Color infoContainer;

  /// Offline/sync indicator (distinct from warn so the top-bar pill reads
  /// clearly even when nothing is overdue).
  final Color sync;
  final Color syncContainer;

  /// Light-mode palette (TZ_03 §B.2 table).
  static const light = StatusColors(
    danger: Color(0xFFC62828),
    dangerContainer: Color(0xFFFDECEC),
    warn: Color(0xFFB26A00),
    warnContainer: Color(0xFFFFF4E2),
    ok: Color(0xFF2E7D32),
    okContainer: Color(0xFFE8F5E9),
    info: Color(0xFF37474F),
    infoContainer: Color(0xFFECEFF1),
    sync: Color(0xFF0E7C66),
    syncContainer: Color(0xFFDCF1EC),
  );

  /// Dark-mode palette (TZ_03 §B.2 table).
  static const dark = StatusColors(
    danger: Color(0xFFFF6B6B),
    dangerContainer: Color(0xFF3A1A1A),
    warn: Color(0xFFFFB74D),
    warnContainer: Color(0xFF3A2E16),
    ok: Color(0xFF81C784),
    okContainer: Color(0xFF16331A),
    info: Color(0xFFB0BEC5),
    infoContainer: Color(0xFF263238),
    sync: Color(0xFF4DB6A4),
    syncContainer: Color(0xFF103A33),
  );

  /// Convenience accessor: `Theme.of(context).statusColors`.
  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  @override
  StatusColors copyWith({
    Color? danger,
    Color? dangerContainer,
    Color? warn,
    Color? warnContainer,
    Color? ok,
    Color? okContainer,
    Color? info,
    Color? infoContainer,
    Color? sync,
    Color? syncContainer,
  }) {
    return StatusColors(
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      warn: warn ?? this.warn,
      warnContainer: warnContainer ?? this.warnContainer,
      ok: ok ?? this.ok,
      okContainer: okContainer ?? this.okContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      sync: sync ?? this.sync,
      syncContainer: syncContainer ?? this.syncContainer,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnContainer: Color.lerp(warnContainer, other.warnContainer, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      okContainer: Color.lerp(okContainer, other.okContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      sync: Color.lerp(sync, other.sync, t)!,
      syncContainer: Color.lerp(syncContainer, other.syncContainer, t)!,
    );
  }
}

/// Sugar to read the [StatusColors] extension from a [ThemeData].
extension StatusColorsThemeX on ThemeData {
  StatusColors get statusColors =>
      extension<StatusColors>() ?? StatusColors.light;
}

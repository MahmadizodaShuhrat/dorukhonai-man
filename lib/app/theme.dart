import 'package:flutter/material.dart';

import 'status_colors.dart';

/// Material 3 light/dark themes — "Clinical Teal" direction (TZ_03 §B.0).
///
/// Desktop-tuned: deeper teal seed `#0E7C66`, compact density, flat
/// outline-bordered cards, a refined typography scale (body 14, not the old
/// oversize 16), and a polished [DataTableThemeData]. Semantic status colours
/// live in the [StatusColors] theme extension, not in the seed.
class AppTheme {
  AppTheme._();

  /// Clinical-Teal seed (TZ_03 §B.0).
  static const Color _seed = Color(0xFF0E7C66);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final status = isDark ? StatusColors.dark : StatusColors.light;

    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      visualDensity: VisualDensity.compact,
      // Desktop: keep tap targets tight so tables stay dense (TZ_03 §B.4).
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      extensions: <ThemeExtension<dynamic>>[status],
    );

    final textTheme = _textTheme(base.textTheme, colorScheme);

    return base.copyWith(
      textTheme: textTheme,
      // Flat-bordered cards (elevation 0 + hairline), radius 10 (TZ_03 §B.6).
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Hairline top bar / surfaces, no Material 3 tint elevation.
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
      ),
      // Dense outlined inputs (TZ_03 §B.6): radius 8, padding (12,10).
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      tooltipTheme: const TooltipThemeData(preferBelow: false),
      // Polished DataTable theme (TZ_03 §B.6): dense rows, header fill,
      // hairline dividers, tabular-friendly header weight.
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        horizontalMargin: 16,
        columnSpacing: 24,
        dividerThickness: 1,
        headingRowColor: WidgetStatePropertyAll(colorScheme.surfaceContainer),
        headingTextStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: colorScheme.onSurfaceVariant,
        ),
        dataTextStyle: TextStyle(
          fontSize: 13.5,
          color: colorScheme.onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Desktop typography scale (TZ_03 §B.3): page H1 22/w600, H2 18/w600,
  /// body 14, table cell 13.5, caption 12.
  static TextTheme _textTheme(TextTheme base, ColorScheme cs) {
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 14),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12),
      labelLarge: base.labelLarge?.copyWith(fontSize: 13.5),
    );
  }
}

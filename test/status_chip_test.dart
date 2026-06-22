// StatusChip maps each StatusTone to the correct foreground/background pair
// from the StatusColors theme extension (TZ_03 §B.2/§B.6).

import 'package:dorukhonai_man/app/status_colors.dart';
import 'package:dorukhonai_man/app/theme.dart';
import 'package:dorukhonai_man/shared/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('each tone uses its StatusColors pair', (tester) async {
    const cases = {
      StatusTone.danger: 'danger',
      StatusTone.warn: 'warn',
      StatusTone.ok: 'ok',
      StatusTone.info: 'info',
      StatusTone.sync: 'sync',
    };
    final light = StatusColors.light;
    final expected = {
      StatusTone.danger: (light.danger, light.dangerContainer),
      StatusTone.warn: (light.warn, light.warnContainer),
      StatusTone.ok: (light.ok, light.okContainer),
      StatusTone.info: (light.info, light.infoContainer),
      StatusTone.sync: (light.sync, light.syncContainer),
    };

    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _host(StatusChip(label: entry.value, tone: entry.key)),
      );
      await tester.pump();

      final (fg, bg) = expected[entry.key]!;

      // Background of the pill container.
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StatusChip),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, bg, reason: 'bg for ${entry.value}');

      // Foreground of the label text.
      final text = tester.widget<Text>(find.text(entry.value));
      expect(text.style?.color, fg, reason: 'fg for ${entry.value}');
    }
  });
}

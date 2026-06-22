import 'package:flutter/material.dart';

/// Consistent page chrome (TZ_03 §A.5): a 64px page header — leading icon,
/// H1 title, optional subtitle, optional centre slot (e.g. view tabs), and a
/// right-aligned actions slot — over the page [body], separated by a hairline.
///
/// Pages render INSIDE the desktop shell, so this is NOT a [Scaffold]; it is a
/// column the shell drops into its content area. Use [AppScaffold.page] for the
/// common title + actions case.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.icon,
    this.subtitle,
    this.actions = const [],
    this.center,
    this.padBody = true,
  });

  /// Convenience alias kept for call-site readability.
  const AppScaffold.page({
    Key? key,
    required String title,
    required Widget body,
    IconData? icon,
    String? subtitle,
    List<Widget> actions = const [],
    Widget? center,
    bool padBody = true,
  }) : this(
         key: key,
         title: title,
         body: body,
         icon: icon,
         subtitle: subtitle,
         actions: actions,
         center: center,
         padBody: padBody,
       );

  final String title;
  final Widget body;
  final IconData? icon;
  final String? subtitle;

  /// Right-aligned header actions (primary [FilledButton] + overflow).
  final List<Widget> actions;

  /// Optional centre slot, e.g. segmented view tabs.
  final Widget? center;

  /// When `true`, wraps [body] in standard 24px page padding.
  final bool padBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageHeader(
          title: title,
          icon: icon,
          subtitle: subtitle,
          actions: actions,
          center: center,
        ),
        Divider(height: 1, thickness: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: padBody
              ? Padding(padding: const EdgeInsets.all(24), child: body)
              : body,
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.actions,
    required this.center,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (center != null) ...[
            const SizedBox(width: 24),
            Expanded(child: Center(child: center!)),
          ] else
            const Spacer(),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final a in actions) ...[
                  a,
                  const SizedBox(width: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

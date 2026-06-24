import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// A 380px master-detail editor panel docked to the right of a list
/// (TZ_03 §C.5 / §D "Master-detail … SidePanel 380px"). Flat-bordered to match
/// the desktop card style: a hairline left border, a titled header with a close
/// button, and a scrolling body.
///
/// This lives in the feature folder (the shared `SidePanel` from the TZ widget
/// list was not built); it is reused by the Products and reference editors.
class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onClose,
    this.width = 380,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onClose;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    tooltip: l.commonClose,
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
          Expanded(
            // Transparent Material so ListTile-based fields (SwitchListTile)
            // paint their ink/selection on it rather than the coloured
            // Container above (which would otherwise trigger an assertion).
            child: Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

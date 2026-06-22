import 'package:flutter/material.dart';

import '../app/status_colors.dart';

/// Semantic tone for a [StatusChip], mapped to the [StatusColors] extension.
enum StatusTone { danger, warn, ok, info, sync }

/// Compact pill that renders a status/label with the semantic colour pair from
/// [StatusColors] (TZ_03 §B.6/§B.7). Used for expiry, stock, posted/draft, and
/// sync states across tables and headers.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.dense = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  /// Tighter padding for use inside dense table cells.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final status = StatusColors.of(context);
    final (fg, bg) = switch (tone) {
      StatusTone.danger => (status.danger, status.dangerContainer),
      StatusTone.warn => (status.warn, status.warnContainer),
      StatusTone.ok => (status.ok, status.okContainer),
      StatusTone.info => (status.info, status.infoContainer),
      StatusTone.sync => (status.sync, status.syncContainer),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 11.5 : 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

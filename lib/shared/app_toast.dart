import 'package:flutter/material.dart';

import '../app/status_colors.dart';

/// Web-style toast (TZ_03 §B.7/§D): a compact card that slides in from the TOP,
/// auto-dismisses after 3 seconds, and shows a depleting countdown bar along its
/// bottom edge. Success/error variants tint with [StatusColors]. Only one toast
/// is visible at a time. Hovering pauses the timer; tapping (or the × button)
/// dismisses early.
///
/// Public API unchanged — call from any widget under a [MaterialApp]/[Overlay].
class AppToast {
  AppToast._();

  /// The currently-shown toast (replaced when a new one appears).
  static OverlayEntry? _current;

  static void success(BuildContext context, String message) =>
      _show(context, message, _Tone.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _Tone.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, _Tone.info);

  static void _show(BuildContext context, String message, _Tone tone) {
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

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Replace any visible toast so only one shows at a time.
    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    void dismiss() {
      if (_current == entry) _current = null;
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(
      builder: (_) => _ToastCard(
        message: message,
        icon: icon,
        background: bg,
        foreground: fg,
        onDismiss: dismiss,
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

enum _Tone { success, error, info }

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.message,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onDismiss,
  });

  final String message;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onDismiss;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  /// Total visible life (incl. the slide in/out at either end).
  static const _life = Duration(seconds: 3);

  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _life)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _close();
      })
      ..forward();

    // Fade/slide in during the first ~8% of the timeline, hold, then out.
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 84),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 8),
    ]).animate(_c);
    // Slide in from the right edge, hold, then slide back out to the right.
    _slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.6, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 8,
      ),
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 84),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.6, 0)),
        weight: 8,
      ),
    ]).animate(_c);
  }

  void _close() {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismiss();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.foreground;
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MouseRegion(
              onEnter: (_) => _c.stop(),
              onExit: (_) {
                if (!_dismissed) _c.forward();
              },
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: _close,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: fg.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                                child: Row(
                                  children: [
                                    Icon(widget.icon, color: fg, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          color: fg,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkResponse(
                                      onTap: _close,
                                      radius: 16,
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: fg.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 3-second countdown bar (depletes left→right).
                              SizedBox(
                                height: 3,
                                width: double.infinity,
                                child: AnimatedBuilder(
                                  animation: _c,
                                  builder: (_, _) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: (1 - _c.value).clamp(0.0, 1.0),
                                      child: Container(
                                        color: fg.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

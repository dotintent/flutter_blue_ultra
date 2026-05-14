import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IntentMark extends StatelessWidget {
  const IntentMark({super.key, this.height = 18});
  final double height;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: height * 0.3,
            height: height * 0.3,
            decoration: const BoxDecoration(
              color: IntentColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'intent',
            style: TextStyle(
              fontFamily: 'Bradford',
              fontSize: height,
              fontWeight: FontWeight.w400,
              color: it.textPrimary,
              letterSpacing: -0.3,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class IntentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IntentAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.brand = false,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool brand;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final leading = this.leading;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    return Container(
      decoration: BoxDecoration(
        color: it.bg,
        border: Border(bottom: BorderSide(color: it.border)),
      ),
      padding: EdgeInsets.fromLTRB(brand ? 20 : 16, 14, 16, brand ? 14 : 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: brand
                  ? const IntentMark(height: 18)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title ?? '',
                          style:
                              IntentTextStyles.serifTitle(17, it.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: IntentTextStyles.mono(10.5, it.textDim),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }
}

class IntentIconBtn extends StatelessWidget {
  const IntentIconBtn(
      {super.key, required this.child, this.onTap, this.accent = false});
  final Widget child;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accent ? it.accent : Colors.transparent,
          border: accent ? null : Border.all(color: it.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(child: child),
      ),
    );
  }
}

enum ChipKind { defaultKind, notify, muted, accent }

class IntentChip extends StatelessWidget {
  const IntentChip(
      {super.key,
      required this.label,
      this.kind = ChipKind.defaultKind,
      this.small = true});
  final String label;
  final ChipKind kind;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    Color bg, fg;
    switch (kind) {
      case ChipKind.notify:
        bg = it.accentSoft;
        fg = it.accent;
      case ChipKind.muted:
        bg = it.surfaceAlt;
        fg = it.textDim;
      case ChipKind.accent:
        bg = it.accent;
        fg = Colors.white;
      default:
        bg = it.chipBg;
        fg = it.textPrimary;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: bg,
        border: kind != ChipKind.accent ? Border.all(color: it.border) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: IntentTextStyles.mono(small ? 10 : 11, fg, letterSpacing: 0.4),
      ),
    );
  }
}

class RSSIBars extends StatelessWidget {
  const RSSIBars({super.key, required this.rssi});
  final int rssi;

  int get _bars => (((rssi + 100) / 10).round()).clamp(1, 5);

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (i) {
        final filled = i < _bars;
        return Container(
          width: 3,
          height: (3 + (i + 1) * 2).toDouble(),
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: filled ? it.textPrimary : it.surfaceHi,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class UUIDText extends StatelessWidget {
  const UUIDText({super.key, required this.uuid, this.short = false});
  final String uuid;
  final bool short;

  String get _display {
    if (!short) return uuid;
    final std = RegExp(r'^0000([0-9a-fA-F]{4})-0000-1000-8000-00805f9b34fb$');
    final m = std.firstMatch(uuid);
    if (m != null) return '0x${m.group(1)!.toUpperCase()}';
    return '${uuid.substring(0, 8)}…${uuid.substring(uuid.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return Text(
      _display,
      style: IntentTextStyles.mono(11, short ? it.textDim : it.textPrimary,
          letterSpacing: 0.2),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
      {super.key, required this.label, this.count, this.trailing});
  final String label;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Text(label.toUpperCase(),
              style: IntentTextStyles.monoLabel(10, it.textFaint)),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text('· $count', style: IntentTextStyles.mono(10, it.accent)),
          ],
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: it.border)),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}

class ConcentricDecor extends StatelessWidget {
  const ConcentricDecor(
      {super.key, this.size = 200, this.strokeOpacity = 0.18, this.dot = true});
  final double size;
  final double strokeOpacity;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _ConcentricPainter(
        color: it.textPrimary,
        strokeOpacity: strokeOpacity,
        dot: dot,
      ),
    );
  }
}

class _ConcentricPainter extends CustomPainter {
  _ConcentricPainter(
      {required this.color, required this.strokeOpacity, required this.dot});
  final Color color;
  final double strokeOpacity;
  final bool dot;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;
    final ringPaint = Paint()
      ..color = color.withValues(alpha: strokeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final r in [40, 60, 80, 100, 120, 140]) {
      canvas.drawCircle(center, r * scale, ringPaint);
    }
    if (dot) {
      canvas.drawCircle(
        center,
        14 * scale,
        Paint()..color = IntentColors.accent,
      );
    }
  }

  @override
  bool shouldRepaint(_ConcentricPainter old) =>
      old.color != color ||
      old.strokeOpacity != strokeOpacity ||
      old.dot != dot;
}

class SunburstDecor extends StatelessWidget {
  const SunburstDecor(
      {super.key, this.size = 220, this.opacity = 0.18, this.lines = 70});
  final double size;
  final double opacity;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _SunburstPainter(
          color: it.textPrimary, opacity: opacity, lines: lines),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  _SunburstPainter(
      {required this.color, required this.opacity, required this.lines});
  final Color color;
  final double opacity;
  final int lines;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.8;
    for (int i = 0; i < lines; i++) {
      final angle = (i / lines) * math.pi * 2;
      final x1 = center.dx + math.cos(angle) * 30 * scale;
      final y1 = center.dy + math.sin(angle) * 30 * scale;
      final x2 = center.dx + math.cos(angle) * 95 * scale;
      final y2 = center.dy + math.sin(angle) * 95 * scale;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_SunburstPainter old) =>
      old.color != color || old.opacity != opacity;
}

enum ConnectionDotState { connecting, discovering, connected, disconnected }

class ConnectionDot extends StatelessWidget {
  const ConnectionDot({super.key, required this.state});
  final ConnectionDotState state;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    Color dotColor;
    String label;
    switch (state) {
      case ConnectionDotState.connecting:
        dotColor = it.accent;
        label = 'CONNECTING';
      case ConnectionDotState.discovering:
        dotColor = it.accent;
        label = 'DISCOVERING';
      case ConnectionDotState.connected:
        dotColor = it.success;
        label = 'CONNECTED';
      case ConnectionDotState.disconnected:
        dotColor = it.textDim;
        label = 'DISCONNECTED';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseDot(
            color: dotColor,
            pulse: state == ConnectionDotState.connecting ||
                state == ConnectionDotState.discovering),
        const SizedBox(width: 8),
        Text(label, style: IntentTextStyles.monoLabel(10.5, dotColor)),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: widget.color.withValues(alpha: 0.5), blurRadius: 6)
            ]),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: widget.color.withValues(alpha: 0.5), blurRadius: 6)
              ]),
        ),
      ),
    );
  }
}

class IntentButton extends StatelessWidget {
  const IntentButton({super.key, required this.label, this.onTap, this.icon});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: it.accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: IntentTextStyles.sans(15, Colors.white,
                    weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class ScanRipple extends StatefulWidget {
  const ScanRipple({super.key, required this.scanning});
  final bool scanning;

  @override
  State<ScanRipple> createState() => _ScanRippleState();
}

class _ScanRippleState extends State<ScanRipple> with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _scales = [];
  final List<Animation<double>> _opacities = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 2000));
      _controllers.add(c);
      _scales.add(Tween(begin: 1.0, end: 2.6)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)));
      _opacities.add(Tween(begin: 1.0, end: 0.0)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)));
      Future.delayed(Duration(milliseconds: i * 650), () {
        if (mounted) c.repeat();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.scanning)
            ...List.generate(
                3,
                (i) => AnimatedBuilder(
                      animation: _controllers[i],
                      builder: (_, __) => Transform.scale(
                        scale: _scales[i].value,
                        child: Opacity(
                          opacity: _opacities[i].value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: it.textPrimary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.scanning ? it.accent : it.surfaceHi,
              shape: BoxShape.circle,
              boxShadow: widget.scanning
                  ? [
                      BoxShadow(
                          color: it.accent.withValues(alpha: 0.4),
                          blurRadius: 20)
                    ]
                  : [],
            ),
            child: const Center(child: _BluetoothIcon()),
          ),
        ],
      ),
    );
  }
}

class _BluetoothIcon extends StatelessWidget {
  const _BluetoothIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _BTPainter(),
    );
  }
}

class _BTPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final path = Path()
      ..moveTo(cx - 5, 5)
      ..lineTo(cx + 5, 13)
      ..lineTo(cx, 22)
      ..lineTo(cx, 0)
      ..lineTo(cx + 5, 8)
      ..lineTo(cx - 5, 16);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BTPainter old) => false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';

class DsConcentricRings extends StatelessWidget {
  const DsConcentricRings({
    super.key,
    this.size = 200,
    this.strokeOpacity = 0.18,
    this.strokeWidth = 1,
    this.radii = const [40, 60, 80, 100, 120, 140],
    this.showCore = true,
    this.coreRadius = 14,
    this.color,
    this.coreColor,
  });

  final double size;
  final double strokeOpacity;
  final double strokeWidth;
  final List<double> radii;
  final bool showCore;
  final double coreRadius;
  final Color? color;
  final Color? coreColor;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _ConcentricPainter(
        color: color ?? colors.textPrimary,
        coreColor: coreColor ?? colors.accent,
        strokeOpacity: strokeOpacity,
        strokeWidth: strokeWidth,
        radii: radii,
        showCore: showCore,
        coreRadius: coreRadius,
      ),
    );
  }
}

class _ConcentricPainter extends CustomPainter {
  _ConcentricPainter({
    required this.color,
    required this.coreColor,
    required this.strokeOpacity,
    required this.strokeWidth,
    required this.radii,
    required this.showCore,
    required this.coreRadius,
  });

  final Color color;
  final Color coreColor;
  final double strokeOpacity;
  final double strokeWidth;
  final List<double> radii;
  final bool showCore;
  final double coreRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;
    final ringPaint = Paint()
      ..color = color.withValues(alpha: strokeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final radius in radii) {
      canvas.drawCircle(center, radius * scale, ringPaint);
    }
    if (showCore) {
      canvas.drawCircle(center, coreRadius * scale, Paint()..color = coreColor);
    }
  }

  @override
  bool shouldRepaint(_ConcentricPainter old) =>
      old.color != color ||
      old.coreColor != coreColor ||
      old.strokeOpacity != strokeOpacity ||
      old.strokeWidth != strokeWidth ||
      old.radii != radii ||
      old.showCore != showCore ||
      old.coreRadius != coreRadius;
}

class DsSunburst extends StatelessWidget {
  const DsSunburst({
    super.key,
    this.size = 220,
    this.opacity = 0.18,
    this.lines = 70,
    this.innerRadius = 30,
    this.outerRadius = 95,
    this.strokeWidth = 0.8,
    this.color,
  });

  final double size;
  final double opacity;
  final int lines;
  final double innerRadius;
  final double outerRadius;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _SunburstPainter(
        color: color ?? colors.textPrimary,
        opacity: opacity,
        lines: lines,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  _SunburstPainter({
    required this.color,
    required this.opacity,
    required this.lines,
    required this.innerRadius,
    required this.outerRadius,
    required this.strokeWidth,
  });

  final Color color;
  final double opacity;
  final int lines;
  final double innerRadius;
  final double outerRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeWidth;
    for (var index = 0; index < lines; index++) {
      final angle = (index / lines) * math.pi * 2;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        center + Offset(cos, sin) * innerRadius * scale,
        center + Offset(cos, sin) * outerRadius * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunburstPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.lines != lines ||
      old.innerRadius != innerRadius ||
      old.outerRadius != outerRadius ||
      old.strokeWidth != strokeWidth;
}

class DsRadarSweep extends StatefulWidget {
  const DsRadarSweep({
    super.key,
    this.active = true,
    this.rings = 5,
    this.ringOpacity = 0.1,
    this.crosshairOpacity = 0.07,
    this.coreRadius = 5,
    this.sweepArc = 0.22,
    this.duration = const Duration(milliseconds: 3600),
    this.ringColor,
    this.coreColor,
    this.sweepColor,
  });

  final bool active;
  final int rings;
  final double ringOpacity;
  final double crosshairOpacity;
  final double coreRadius;
  final double sweepArc;
  final Duration duration;
  final Color? ringColor;
  final Color? coreColor;
  final Color? sweepColor;

  @override
  State<DsRadarSweep> createState() => _DsRadarSweepState();
}

class _DsRadarSweepState extends State<DsRadarSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(DsRadarSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final ring = widget.ringColor ?? colors.textPrimary;
    final core = widget.coreColor ?? colors.accent;
    final sweep = widget.sweepColor ?? colors.textPrimary;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _RadarPainter(
            phase: _controller.value,
            rings: widget.rings,
            ringColor: ring,
            ringOpacity: widget.ringOpacity,
            crosshairOpacity: widget.crosshairOpacity,
            coreColor: core,
            coreRadius: widget.coreRadius,
            sweepColor: sweep,
            sweepArc: widget.sweepArc,
            showSweep: widget.active,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.phase,
    required this.rings,
    required this.ringColor,
    required this.ringOpacity,
    required this.crosshairOpacity,
    required this.coreColor,
    required this.coreRadius,
    required this.sweepColor,
    required this.sweepArc,
    required this.showSweep,
  });

  final double phase;
  final int rings;
  final Color ringColor;
  final double ringOpacity;
  final double crosshairOpacity;
  final Color coreColor;
  final double coreRadius;
  final Color sweepColor;
  final double sweepArc;
  final bool showSweep;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide / 2;

    final crosshairPaint = Paint()
      ..color = ringColor.withValues(alpha: crosshairOpacity)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      crosshairPaint,
    );

    final ringPaint = Paint()
      ..color = ringColor.withValues(alpha: ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var index = 1; index <= rings; index++) {
      canvas.drawCircle(center, maxRadius * index / rings, ringPaint);
    }

    if (showSweep) {
      final startAngle = phase * math.pi * 2 - math.pi / 2;
      final sweepAngle = sweepArc * math.pi * 2;
      final rect = Rect.fromCircle(center: center, radius: maxRadius);
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            sweepColor.withValues(alpha: 0),
            sweepColor.withValues(alpha: 0.22),
          ],
          tileMode: TileMode.clamp,
          transform: GradientRotation(startAngle),
        ).createShader(rect);
      canvas.drawArc(rect, startAngle, sweepAngle, true, sweepPaint);
    }

    canvas.drawCircle(
      center,
      coreRadius * 2.6,
      Paint()..color = coreColor.withValues(alpha: 0.18),
    );
    canvas.drawCircle(center, coreRadius, Paint()..color = coreColor);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.phase != phase ||
      old.rings != rings ||
      old.ringColor != ringColor ||
      old.ringOpacity != ringOpacity ||
      old.crosshairOpacity != crosshairOpacity ||
      old.coreColor != coreColor ||
      old.coreRadius != coreRadius ||
      old.sweepColor != sweepColor ||
      old.sweepArc != sweepArc ||
      old.showSweep != showSweep;
}

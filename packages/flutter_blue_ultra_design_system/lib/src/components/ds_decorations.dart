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

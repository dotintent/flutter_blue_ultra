import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/dimension_tokens.dart';

class DsStatusRing extends StatefulWidget {
  const DsStatusRing({
    super.key,
    required this.tone,
    required this.child,
    this.spinning = false,
    this.size = DsSize.statusRing,
    this.strokeWidth = 2,
    this.arc = 0.22,
    this.trackOpacity = 0.3,
    this.duration,
  });

  final Color tone;
  final Widget child;
  final bool spinning;
  final double size;
  final double strokeWidth;
  final double arc;
  final double trackOpacity;
  final Duration? duration;

  @override
  State<DsStatusRing> createState() => _DsStatusRingState();
}

class _DsStatusRingState extends State<DsStatusRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration ?? DsMotion.wave,
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(DsStatusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning == oldWidget.spinning) return;
    if (widget.spinning) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: Size.square(widget.size),
                painter: _StatusRingPainter(
                  tone: widget.tone,
                  phase: _controller.value,
                  strokeWidth: widget.strokeWidth,
                  arc: widget.arc,
                  trackOpacity: widget.trackOpacity,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _StatusRingPainter extends CustomPainter {
  _StatusRingPainter({
    required this.tone,
    required this.phase,
    required this.strokeWidth,
    required this.arc,
    required this.trackOpacity,
  });

  final Color tone;
  final double phase;
  final double strokeWidth;
  final double arc;
  final double trackOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = tone.withValues(alpha: trackOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      phase * math.pi * 2 - math.pi / 2,
      arc * math.pi * 2,
      false,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StatusRingPainter old) =>
      old.tone != tone ||
      old.phase != phase ||
      old.strokeWidth != strokeWidth ||
      old.arc != arc ||
      old.trackOpacity != trackOpacity;
}

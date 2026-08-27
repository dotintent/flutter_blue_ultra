import 'package:flutter/material.dart';

import '../theme/ds_dimensions.dart';
import '../theme/ds_typography.dart';
import '../tokens/dimension_tokens.dart';

class DsStatusDot extends StatefulWidget {
  const DsStatusDot({
    super.key,
    required this.color,
    this.pulsing = false,
    this.size = DsSize.statusDot,
    this.glowRadius = 6,
    this.minOpacity = 0.2,
    this.duration,
  });

  final Color color;
  final bool pulsing;
  final double size;
  final double glowRadius;
  final double minOpacity;
  final Duration? duration;

  @override
  State<DsStatusDot> createState() => _DsStatusDotState();
}

class _DsStatusDotState extends State<DsStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? DsMotion.pulse,
    );
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(DsStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing == oldWidget.pulsing) return;
    if (widget.pulsing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot() => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5),
              blurRadius: widget.glowRadius,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!widget.pulsing) return _dot();

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: widget.minOpacity)
          .animate(_controller),
      child: _dot(),
    );
  }
}

class DsStatusIndicator extends StatelessWidget {
  const DsStatusIndicator({
    super.key,
    required this.label,
    required this.color,
    this.pulsing = false,
    this.dotSize = DsSize.statusDot,
    this.labelStyle,
    this.gap,
    this.uppercase = true,
  });

  final String label;
  final Color color;
  final bool pulsing;
  final double dotSize;
  final TextStyle? labelStyle;
  final double? gap;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final typography = DsTypography.of(context);
    final dimensions = DsDimensions.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsStatusDot(color: color, pulsing: pulsing, size: dotSize),
        SizedBox(width: gap ?? dimensions.spaceSm),
        Text(
          uppercase ? label.toUpperCase() : label,
          style: labelStyle ?? typography.label.copyWith(color: color),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../tokens/dimension_tokens.dart';

class DsSpinner extends StatefulWidget {
  const DsSpinner({
    super.key,
    this.size = DsSize.iconXSmall,
    this.color,
    this.strokeWidth = 2,
    this.arc = 0.75,
    this.duration = const Duration(milliseconds: 800),
  });

  final double size;
  final Color? color;
  final double strokeWidth;
  final double arc;
  final Duration duration;

  @override
  State<DsSpinner> createState() => _DsSpinnerState();
}

class _DsSpinnerState extends State<DsSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return RepaintBoundary(
      child: RotationTransition(
        turns: _controller,
        child: SizedBox.square(
          dimension: widget.size,
          child: CircularProgressIndicator(
            value: widget.arc,
            strokeWidth: widget.strokeWidth,
            color: widget.color ?? colors.accent,
          ),
        ),
      ),
    );
  }
}

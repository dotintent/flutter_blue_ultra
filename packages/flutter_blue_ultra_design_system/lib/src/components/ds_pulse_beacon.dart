import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../tokens/dimension_tokens.dart';
import 'ds_bluetooth_glyph.dart';

class DsPulseBeacon extends StatefulWidget {
  const DsPulseBeacon({
    super.key,
    required this.active,
    this.child,
    this.size = DsSize.pulseField,
    this.coreSize = DsSize.controlLarge,
    this.ringCount = 3,
    this.maxScale = 2.6,
    this.ringWidth = 1.5,
    this.activeColor,
    this.inactiveColor,
    this.ringColor,
    this.duration,
  });

  final bool active;
  final Widget? child;
  final double size;
  final double coreSize;
  final int ringCount;
  final double maxScale;
  final double ringWidth;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? ringColor;
  final Duration? duration;

  @override
  State<DsPulseBeacon> createState() => _DsPulseBeaconState();
}

class _DsPulseBeaconState extends State<DsPulseBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? DsMotion.wave,
    );
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(DsPulseBeacon oldWidget) {
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
    final dimensions = DsDimensions.of(context);
    final core = widget.active
        ? (widget.activeColor ?? colors.accent)
        : (widget.inactiveColor ?? colors.surfaceHi);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.active)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var index = 0; index < widget.ringCount; index++)
                      _ring(
                        (_controller.value + index / widget.ringCount) % 1.0,
                        widget.ringColor ?? colors.textPrimary,
                      ),
                  ],
                ),
              ),
            ),
          AnimatedContainer(
            duration: dimensions.durationFast,
            width: widget.coreSize,
            height: widget.coreSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: core,
              shape: BoxShape.circle,
              boxShadow: widget.active
                  ? [
                      BoxShadow(
                        color: core.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ]
                  : const [],
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: colors.onAccent),
              child: widget.child ?? const DsBluetoothGlyph(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double phase, Color color) {
    final eased = Curves.easeOut.transform(phase);
    return Opacity(
      opacity: 1 - eased,
      child: Transform.scale(
        scale: 1 + (widget.maxScale - 1) * eased,
        child: Container(
          width: widget.coreSize,
          height: widget.coreSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: widget.ringWidth),
          ),
        ),
      ),
    );
  }
}

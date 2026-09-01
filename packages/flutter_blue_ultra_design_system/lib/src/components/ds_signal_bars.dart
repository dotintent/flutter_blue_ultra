import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../tokens/dimension_tokens.dart';

class DsSignalBars extends StatelessWidget {
  const DsSignalBars({
    super.key,
    required this.level,
    this.count = 5,
    this.barWidth = DsSize.signalBarWidth,
    this.gap = DsSize.signalBarGap,
    this.baseHeight = 5,
    this.step = 2,
    this.activeColor,
    this.inactiveColor,
  });

  DsSignalBars.rssi({
    super.key,
    required int rssi,
    this.count = 5,
    this.barWidth = DsSize.signalBarWidth,
    this.gap = DsSize.signalBarGap,
    this.baseHeight = 5,
    this.step = 2,
    this.activeColor,
    this.inactiveColor,
  }) : level = levelFromRssi(rssi, count: count);

  final int level;
  final int count;
  final double barWidth;
  final double gap;
  final double baseHeight;
  final double step;
  final Color? activeColor;
  final Color? inactiveColor;

  static int levelFromRssi(int rssi, {int count = 5}) =>
      ((rssi + 100) / 10).round().clamp(1, count);

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final active = activeColor ?? colors.textPrimary;
    final inactive = inactiveColor ?? colors.surfaceHi;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(count, (index) {
        return Container(
          width: barWidth,
          height: baseHeight + (index + 1) * step,
          margin: EdgeInsets.only(right: gap),
          decoration: BoxDecoration(
            color: index < level ? active : inactive,
            borderRadius: BorderRadius.circular(DsRadius.hairline),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class TelemetryRow extends StatelessWidget {
  const TelemetryRow({super.key, required this.stats});

  final List<StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DsRadius.medium),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DsRadius.medium),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, stat) in stats.indexed)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceInset,
                      border: index == stats.length - 1
                          ? null
                          : Border(right: BorderSide(color: colors.border)),
                    ),
                    child: _StatCard(data: stat),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCardData {
  const StatCardData({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final StatCardData data;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(DsSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DsTextStyles.monoLabel(color: colors.textDim),
          ),
          const SizedBox(height: DsSpace.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.value,
                style: DsTextStyles.monoLg(color: colors.textPrimary),
              ),
              const SizedBox(width: DsSpace.s4),
              Text(
                data.unit,
                style: DsTextStyles.monoMd(color: colors.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

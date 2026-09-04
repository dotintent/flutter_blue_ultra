import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../models/ble_models.dart';

class FormatSegments extends StatelessWidget {
  const FormatSegments({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ValueFormat value;
  final ValueChanged<ValueFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Container(
      padding: const EdgeInsets.all(DsSpace.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DsRadius.medium),
        border: Border.all(color: colors.borderHi),
      ),
      child: Row(
        children: [
          for (final format in ValueFormat.values)
            Expanded(
              child: _Segment(
                label: format.label(),
                selected: format == value,
                onTap: () => onChanged(format),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: DsSpace.s2),
        padding: const EdgeInsets.symmetric(vertical: DsSpace.s8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(DsRadius.small),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: DsTextStyles.monoLabel(
            color: selected ? colors.surfaceInset : colors.textDim,
          ),
        ),
      ),
    );
  }
}

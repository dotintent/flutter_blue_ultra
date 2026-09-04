import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class NotifyToggle extends StatelessWidget {
  const NotifyToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: DsMotion.fast,
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(DsSpace.s2),
        decoration: BoxDecoration(
          color: value ? colors.accent : colors.surfaceControl,
          borderRadius: BorderRadius.circular(DsRadius.pill),
        ),
        child: AnimatedAlign(
          duration: DsMotion.fast,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colors.onAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class EventLogRow extends StatelessWidget {
  const EventLogRow({super.key, required this.value, required this.time});

  final String value;
  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DsSpace.s12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DsTextStyles.monoMd(color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: DsSpace.s8),
            Text(
              time,
              style: DsTextStyles.monoMd(color: colors.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

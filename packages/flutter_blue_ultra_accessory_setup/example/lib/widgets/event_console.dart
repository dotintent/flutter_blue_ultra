import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class EventConsole extends StatelessWidget {
  const EventConsole({super.key, required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpace.s16),
      decoration: BoxDecoration(
        color: colors.surfaceInset,
        borderRadius: BorderRadius.circular(DsRadius.medium),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, entry) in entries.indexed) ...[
            if (index > 0) const SizedBox(height: DsSpace.s8),
            _LogEntry(entry: entry),
          ],
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.entry});

  final String entry;

  /// Log lines are written as `[HH:mm:ss] message` by the cubit; split them so
  /// the timestamp can take its own dimmer column like the design shows.
  static (String?, String) _split(String entry) {
    if (!entry.startsWith('[')) return (null, entry);
    final close = entry.indexOf(']');
    if (close < 0) return (null, entry);
    return (
      entry.substring(1, close),
      entry.substring(close + 1).trimLeft(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final (time, message) = _split(entry);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (time != null) ...[
          Text(
            time,
            style: DsTextStyles.monoCaption(color: colors.textFaint),
          ),
          const SizedBox(width: DsSpace.s12),
        ],
        Expanded(
          child: Text(
            message,
            style: DsTextStyles.monoMd(color: colors.textDim),
          ),
        ),
      ],
    );
  }
}

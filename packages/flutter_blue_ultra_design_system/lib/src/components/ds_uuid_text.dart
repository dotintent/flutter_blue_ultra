import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_typography.dart';

class DsUuidText extends StatelessWidget {
  const DsUuidText({
    super.key,
    required this.uuid,
    this.short = false,
    this.style,
    this.color,
    this.overflow,
  });

  final String uuid;
  final bool short;
  final TextStyle? style;
  final Color? color;
  final TextOverflow? overflow;

  static final RegExp _sigAssigned =
      RegExp(r'^0000([0-9a-fA-F]{4})-0000-1000-8000-00805f9b34fb$');

  static String format(String uuid, {bool short = false}) {
    if (!short) return uuid;
    final match = _sigAssigned.firstMatch(uuid);
    if (match != null) return '0x${match.group(1)!.toUpperCase()}';
    if (uuid.length <= 8) return uuid;
    return '${uuid.substring(0, 8)}…${uuid.substring(uuid.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final typography = DsTypography.of(context);

    return Text(
      format(uuid, short: short),
      overflow: overflow,
      style: (style ?? typography.mono).copyWith(
        color: color ?? (short ? colors.textDim : colors.textPrimary),
      ),
    );
  }
}

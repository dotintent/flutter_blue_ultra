import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class FooterMessage extends StatelessWidget {
  const FooterMessage({super.key, required this.message, this.tone});

  final String message;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final color = tone ?? colors.textDim;
    final wrap = tone != null;

    return Row(
      crossAxisAlignment:
          wrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment:
          wrap ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        DsBluetoothGlyph(size: DsSize.iconXSmall, color: color),
        const SizedBox(width: DsSpace.s4),
        if (wrap)
          Expanded(
            child: Text(
              message,
              style: DsTextStyles.bodyXs(color: color),
            ),
          )
        else
          Text(
            message,
            textAlign: TextAlign.center,
            style: DsTextStyles.bodyXs(color: color),
          ),
      ],
    );
  }
}

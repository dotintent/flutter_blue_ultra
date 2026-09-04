import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.logoHeight = 12});

  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsBrandMark(height: logoHeight),
        const SizedBox(height: DsSpace.s12),
        Text(
          'FLUTTER BLUE ULTRA',
          style: DsTextStyles.monoLabelLoud(color: colors.textDim),
        ),
      ],
    );
  }
}

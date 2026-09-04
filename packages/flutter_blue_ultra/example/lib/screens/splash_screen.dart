import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 88),
            const Center(child: DsBrandMark(height: 24)),
            const Spacer(flex: 96),
            const Flexible(
              flex: 366,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: DsSpace.s16),
                child: DsRadarSweep(),
              ),
            ),
            const Spacer(flex: 45),
            Text(
              'FLUTTER BLUE ULTRA',
              textAlign: TextAlign.center,
              style: DsTextStyles.monoLabelLoud(
                color: colors.textDim,
                size: DsFontSize.monoLg,
              ),
            ),
            const Spacer(flex: 88),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/dimension_tokens.dart';

@immutable
class DsDimensions extends ThemeExtension<DsDimensions> {
  const DsDimensions({
    required this.spaceXxs,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.spaceXxl,
    required this.screenPadding,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.radiusPill,
    required this.borderWidth,
    required this.controlSmall,
    required this.controlMedium,
    required this.controlLarge,
    required this.iconSmall,
    required this.iconMedium,
    required this.iconLarge,
    required this.avatarSize,
    required this.appBarHeight,
    required this.durationFast,
    required this.durationPulse,
    required this.durationWave,
  });

  final double spaceXxs;
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double spaceXxl;
  final double screenPadding;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusPill;
  final double borderWidth;
  final double controlSmall;
  final double controlMedium;
  final double controlLarge;
  final double iconSmall;
  final double iconMedium;
  final double iconLarge;
  final double avatarSize;
  final double appBarHeight;
  final Duration durationFast;
  final Duration durationPulse;
  final Duration durationWave;

  static const DsDimensions standard = DsDimensions(
    spaceXxs: DsSpace.s2,
    spaceXs: DsSpace.s4,
    spaceSm: DsSpace.s8,
    spaceMd: DsSpace.s12,
    spaceLg: DsSpace.s16,
    spaceXl: DsSpace.s20,
    spaceXxl: DsSpace.s24,
    screenPadding: DsSpace.s20,
    radiusSmall: DsRadius.small,
    radiusMedium: DsRadius.medium,
    radiusLarge: DsRadius.large,
    radiusPill: DsRadius.pill,
    borderWidth: DsSize.hairline,
    controlSmall: DsSize.controlSmall,
    controlMedium: DsSize.controlMedium,
    controlLarge: DsSize.controlLarge,
    iconSmall: DsSize.iconSmall,
    iconMedium: DsSize.iconMedium,
    iconLarge: DsSize.iconLarge,
    avatarSize: DsSize.avatar,
    appBarHeight: DsSize.appBarHeight,
    durationFast: DsMotion.fast,
    durationPulse: DsMotion.pulse,
    durationWave: DsMotion.wave,
  );

  static DsDimensions of(BuildContext context) =>
      Theme.of(context).extension<DsDimensions>() ?? standard;

  EdgeInsets get screenInsets => EdgeInsets.symmetric(horizontal: screenPadding);

  BorderRadius get pillRadius => BorderRadius.circular(radiusPill);

  BorderRadius get cardRadius => BorderRadius.circular(radiusLarge);

  @override
  DsDimensions copyWith({
    double? spaceXxs,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? spaceXxl,
    double? screenPadding,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? radiusPill,
    double? borderWidth,
    double? controlSmall,
    double? controlMedium,
    double? controlLarge,
    double? iconSmall,
    double? iconMedium,
    double? iconLarge,
    double? avatarSize,
    double? appBarHeight,
    Duration? durationFast,
    Duration? durationPulse,
    Duration? durationWave,
  }) {
    return DsDimensions(
      spaceXxs: spaceXxs ?? this.spaceXxs,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      spaceXxl: spaceXxl ?? this.spaceXxl,
      screenPadding: screenPadding ?? this.screenPadding,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      radiusPill: radiusPill ?? this.radiusPill,
      borderWidth: borderWidth ?? this.borderWidth,
      controlSmall: controlSmall ?? this.controlSmall,
      controlMedium: controlMedium ?? this.controlMedium,
      controlLarge: controlLarge ?? this.controlLarge,
      iconSmall: iconSmall ?? this.iconSmall,
      iconMedium: iconMedium ?? this.iconMedium,
      iconLarge: iconLarge ?? this.iconLarge,
      avatarSize: avatarSize ?? this.avatarSize,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      durationFast: durationFast ?? this.durationFast,
      durationPulse: durationPulse ?? this.durationPulse,
      durationWave: durationWave ?? this.durationWave,
    );
  }

  @override
  DsDimensions lerp(DsDimensions? other, double t) {
    if (other == null) return this;
    double l(double a, double b) => a + (b - a) * t;
    return DsDimensions(
      spaceXxs: l(spaceXxs, other.spaceXxs),
      spaceXs: l(spaceXs, other.spaceXs),
      spaceSm: l(spaceSm, other.spaceSm),
      spaceMd: l(spaceMd, other.spaceMd),
      spaceLg: l(spaceLg, other.spaceLg),
      spaceXl: l(spaceXl, other.spaceXl),
      spaceXxl: l(spaceXxl, other.spaceXxl),
      screenPadding: l(screenPadding, other.screenPadding),
      radiusSmall: l(radiusSmall, other.radiusSmall),
      radiusMedium: l(radiusMedium, other.radiusMedium),
      radiusLarge: l(radiusLarge, other.radiusLarge),
      radiusPill: l(radiusPill, other.radiusPill),
      borderWidth: l(borderWidth, other.borderWidth),
      controlSmall: l(controlSmall, other.controlSmall),
      controlMedium: l(controlMedium, other.controlMedium),
      controlLarge: l(controlLarge, other.controlLarge),
      iconSmall: l(iconSmall, other.iconSmall),
      iconMedium: l(iconMedium, other.iconMedium),
      iconLarge: l(iconLarge, other.iconLarge),
      avatarSize: l(avatarSize, other.avatarSize),
      appBarHeight: l(appBarHeight, other.appBarHeight),
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationPulse: t < 0.5 ? durationPulse : other.durationPulse,
      durationWave: t < 0.5 ? durationWave : other.durationWave,
    );
  }
}

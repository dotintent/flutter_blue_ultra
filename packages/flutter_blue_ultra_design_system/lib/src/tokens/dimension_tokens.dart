class DsSpace {
  const DsSpace._();

  static const double s2 = 2;
  static const double s3 = 3;
  static const double s4 = 4;
  static const double s5 = 5;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s48 = 48;
  static const double s80 = 80;
}

class DsRadius {
  const DsRadius._();

  static const double hairline = 1;
  static const double small = 8;
  static const double medium = 14;
  static const double large = 18;
  static const double xLarge = 24;
  static const double pill = 999;
}

class DsSize {
  const DsSize._();

  static const double hairline = 1;
  static const double brandDot = 6;
  static const double statusDot = 8;
  static const double signalBarWidth = 3;
  static const double signalBarGap = 2;

  static const double iconXSmall = 14;
  static const double iconSmall = 16;
  static const double iconMedium = 18;
  static const double iconLarge = 20;
  static const double iconXLarge = 22;

  static const double controlSmall = 38;
  static const double controlMedium = 44;
  static const double controlLarge = 56;

  static const double avatar = 44;
  static const double pulseField = 88;

  static const double appBarHeight = 64;
}

class DsMotion {
  const DsMotion._();

  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration pulse = Duration(milliseconds: 1000);
  static const Duration wave = Duration(milliseconds: 2000);
  static const Duration waveStagger = Duration(milliseconds: 650);
}

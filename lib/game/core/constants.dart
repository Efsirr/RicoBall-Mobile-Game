import 'dart:ui';

abstract final class GameColors {
  static const background = Color(0xFF0A0A0C);
  static const backgroundAlt = Color(0xFF040814);
  static const surface = Color(0xFF1C1C1E);
  static const surfaceLight = Color(0xFF2C2C2E);
  static const border = Color(0xFF38383A);
  static const gridLine = Color(0xFF161C28);
  static const neonCyan = Color(0xFF62F4FF);
  static const electricBlue = Color(0xFF0A84FF);
  static const orbitGlow = Color(0xFF0A84FF);
  static const wallColor = Color(0xFF26334C);
  static const wallGlow = Color(0xFF0A84FF);
  static const blockHp1 = Color(0xFF30D158);
  static const blockHp2 = Color(0xFF0A84FF);
  static const blockHp3 = Color(0xFFFFD60A);
  static const warning = Color(0xFFFFD60A);
  static const danger = Color(0xFFFF453A);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF636366);
  static const uiText = textSecondary;
  static const comboText = Color(0xFF62F4FF);
  static const aimLine = Color(0x990A84FF);
}

abstract final class GameConst {
  static const double wallInset = 12.0;
  static const double fieldTopInset = 190.0;
  static const double fieldBottomInset = 112.0;
  static const double ballRadius = 8.0;
  static const double ballSpeed = 800.0;
  static const double ballMinSpeed = 60.0;
  static const double ballDrag = 0.9995;
  static const double wallBounceDamp = 0.98;
  static const double blockBounceDamp = 0.95;
  static const double reinforcedDamageSpeed = 420.0;
  static const double movingBlockSpeed = 34.0;
  static const double explosionRadius = 76.0;
  static const double maxBallLifetime = 20.0;

  static const double orbitCoreRadius = 18.0;
  static const double orbitInfluenceRadius = 130.0;
  static const double orbitStrength = 600.0;
  static const double repulsorStrength = 520.0;
  static const double movingCoreSpeed = 22.0;
  static const double maxBallSpeed = 1400.0;

  static const double blockWidth = 48.0;
  static const double blockHeight = 22.0;

  static const double powerUpRadius = 13.0;
  static const double heavyBallDuration = 5.0;
  static const int piercingHits = 4;

  static const int trailLength = 30;
  static const int trajectorySteps = 250;
  static const double trajectoryDt = 0.016;
}

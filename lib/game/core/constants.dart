import 'dart:ui';

abstract final class GameColors {
  static const background = Color(0xFF0A0E1A);
  static const gridLine = Color(0xFF141A2E);
  static const neonCyan = Color(0xFF00FFFF);
  static const electricBlue = Color(0xFF2979FF);
  static const orbitGlow = Color(0xFF00E5FF);
  static const wallColor = Color(0xFF1A237E);
  static const wallGlow = Color(0xFF304FFE);
  static const blockHp1 = Color(0xFF00897B);
  static const blockHp2 = Color(0xFF0277BD);
  static const blockHp3 = Color(0xFF6A1B9A);
  static const uiText = Color(0xFFB0BEC5);
  static const comboText = Color(0xFF00FFFF);
  static const aimLine = Color(0x8000FFFF);
}

abstract final class GameConst {
  static const double wallInset = 12.0;
  static const double ballRadius = 8.0;
  static const double ballSpeed = 500.0;
  static const double ballMinSpeed = 60.0;
  static const double ballDrag = 0.9995;
  static const double wallBounceDamp = 0.98;
  static const double blockBounceDamp = 0.95;
  static const double maxBallLifetime = 20.0;

  static const double orbitCoreRadius = 18.0;
  static const double orbitInfluenceRadius = 130.0;
  static const double orbitStrength = 600.0;
  static const double maxBallSpeed = 900.0;

  static const double blockWidth = 48.0;
  static const double blockHeight = 22.0;

  static const int trailLength = 30;
  static const int trajectorySteps = 250;
  static const double trajectoryDt = 0.016;
}

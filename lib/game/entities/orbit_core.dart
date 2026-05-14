import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';
import 'ball.dart';

class OrbitCore extends PositionComponent {
  double _pulsePhase = 0;
  bool ballInOrbit = false;

  OrbitCore({required super.position}) : super(anchor: Anchor.center);

  void applyInfluence(Ball ball, double dt) {
    final toCore = position - ball.position;
    final distance = toCore.length;

    if (distance > GameConst.orbitInfluenceRadius ||
        distance < GameConst.orbitCoreRadius) {
      return;
    }

    final t = 1.0 - (distance / GameConst.orbitInfluenceRadius);
    final strength = GameConst.orbitStrength * t * t;

    final force = toCore.normalized()..scale(strength * dt);
    ball.velocity.add(force);

    // Slight speed boost while orbiting
    final speed = ball.velocity.length;
    if (speed < GameConst.maxBallSpeed) {
      ball.velocity.scale(min(GameConst.maxBallSpeed / speed, 1.0 + 0.3 * dt));
    }

    ball.isInOrbit = true;
    ballInOrbit = true;
  }

  @override
  void update(double dt) {
    _pulsePhase += dt * 2.5;
    ballInOrbit = false;
  }

  @override
  void render(Canvas canvas) {
    final pulse = (sin(_pulsePhase) + 1) / 2;

    // Influence radius ring
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitInfluenceRadius,
      Paint()
        ..color = GameColors.orbitGlow.withValues(alpha:0.04 + pulse * 0.03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Inner ring
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitInfluenceRadius * 0.6,
      Paint()
        ..color = GameColors.orbitGlow.withValues(alpha:0.02 + pulse * 0.02)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Outer diffuse glow
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitCoreRadius * 3,
      Paint()
        ..color = GameColors.orbitGlow.withValues(alpha:0.06 + pulse * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );

    // Active orbit boost
    if (ballInOrbit) {
      canvas.drawCircle(
        Offset.zero,
        GameConst.orbitCoreRadius * 4,
        Paint()
          ..color = GameColors.orbitGlow.withValues(alpha:0.2 + pulse * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35),
      );
    }

    // Core body
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitCoreRadius,
      Paint()..color = GameColors.orbitGlow.withValues(alpha:0.7 + pulse * 0.3),
    );

    // Inner bright spot
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitCoreRadius * 0.35,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha:0.5 + pulse * 0.5),
    );
  }
}

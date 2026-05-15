import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';
import '../save/game_progress.dart';
import 'ball.dart';

enum OrbitCoreKind { attractor, repulsor }

class OrbitCore extends PositionComponent {
  final OrbitCoreKind kind;
  final double? moveMinX;
  final double? moveMaxX;
  final double moveSpeed;

  double _pulsePhase = 0;
  double _moveDirection = 1;
  bool ballInField = false;

  OrbitCore({
    required super.position,
    this.kind = OrbitCoreKind.attractor,
    this.moveMinX,
    this.moveMaxX,
    this.moveSpeed = GameConst.movingCoreSpeed,
  }) : super(anchor: Anchor.center);

  bool get isRepulsor => kind == OrbitCoreKind.repulsor;

  bool get isMoving => moveMinX != null && moveMaxX != null;

  Color get fieldColor {
    if (isRepulsor) return GameColors.danger;
    return GameProgress.instance.selectedCoreColor;
  }

  void applyInfluence(Ball ball, double dt) {
    final toCore = position - ball.position;
    final distance = toCore.length;

    if (distance > GameConst.orbitInfluenceRadius ||
        distance < GameConst.orbitCoreRadius) {
      return;
    }

    final t = 1.0 - (distance / GameConst.orbitInfluenceRadius);
    final strength = (isRepulsor
            ? GameConst.repulsorStrength
            : GameConst.orbitStrength) *
        t *
        t;

    final forceDirection = isRepulsor
        ? (ball.position - position).normalized()
        : toCore.normalized();
    final force = forceDirection..scale(strength * dt);
    ball.velocity.add(force);

    // Slight speed boost while touching a field keeps the orbit feeling authored.
    final speed = ball.velocity.length;
    if (speed < GameConst.maxBallSpeed) {
      final boost = isRepulsor ? 0.18 : 0.3;
      ball.velocity.scale(min(GameConst.maxBallSpeed / speed, 1.0 + boost * dt));
    }

    ball.isInOrbit = true;
    ballInField = true;
  }

  @override
  void update(double dt) {
    _pulsePhase += dt * 2.5;
    ballInField = false;

    if (isMoving) {
      position.x += moveSpeed * _moveDirection * dt;
      if (position.x <= moveMinX!) {
        position.x = moveMinX!;
        _moveDirection = 1;
      } else if (position.x >= moveMaxX!) {
        position.x = moveMaxX!;
        _moveDirection = -1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final pulse = (sin(_pulsePhase) + 1) / 2;
    final coreColor = fieldColor;

    // Influence radius ring
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitInfluenceRadius,
      Paint()
        ..color = coreColor.withValues(alpha: 0.04 + pulse * 0.03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Inner ring
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitInfluenceRadius * 0.6,
      Paint()
        ..color = coreColor.withValues(alpha: 0.02 + pulse * 0.02)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Outer diffuse glow
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitCoreRadius * 3,
      Paint()
        ..color = coreColor.withValues(alpha: 0.06 + pulse * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );

    // Active orbit boost
    if (ballInField) {
      canvas.drawCircle(
        Offset.zero,
        GameConst.orbitCoreRadius * 4,
        Paint()
          ..color = coreColor.withValues(alpha: 0.2 + pulse * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35),
      );
    }

    // Core body
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitCoreRadius,
      Paint()..color = coreColor.withValues(alpha: 0.7 + pulse * 0.3),
    );

    if (isRepulsor) {
      final markerPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas
        ..drawLine(const Offset(-7, -7), const Offset(7, 7), markerPaint)
        ..drawLine(const Offset(7, -7), const Offset(-7, 7), markerPaint);
    }

    if (isMoving) {
      canvas.drawLine(
        const Offset(-24, 25),
        const Offset(24, 25),
        Paint()
          ..color = coreColor.withValues(alpha: 0.32)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Inner bright spot
    canvas.drawCircle(
      Offset.zero,
      GameConst.orbitCoreRadius * 0.35,
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.5 + pulse * 0.5),
    );
  }
}

import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';
import '../save/game_progress.dart';

class Ball extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  bool isActive = false;
  double lifetime = 0;
  bool isInOrbit = false;
  double radiusScale = 1.0;
  final List<_TrailPoint> _trail = [];

  Ball({required super.position}) : super(anchor: Anchor.center);

  double get collisionRadius => GameConst.ballRadius * radiusScale;

  void launch(Vector2 dir) {
    velocity = dir.normalized()..scale(GameConst.ballSpeed);
    isActive = true;
    lifetime = 0;
    isInOrbit = false;
    _trail.clear();
  }

  void setHeavy(bool enabled) {
    radiusScale = enabled ? 1.42 : 1.0;
  }

  void deactivate() {
    isActive = false;
    velocity.setZero();
    isInOrbit = false;
    _trail.clear();
  }

  void addTrailPoint() {
    _trail.add(_TrailPoint(position.clone(), isInOrbit));
    while (_trail.length > GameConst.trailLength) {
      _trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = GameProgress.instance;
    final ballColor = progress.selectedBallColor;
    final trailBaseColor = progress.selectedTrailColor;
    final coreColor = progress.selectedCoreColor;

    if (!isActive) {
      canvas.drawCircle(
        Offset.zero,
        collisionRadius,
        Paint()..color = ballColor.withValues(alpha: 0.3),
      );
      canvas.drawCircle(
        Offset.zero,
        collisionRadius * 1.8,
        Paint()
          ..color = ballColor.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      return;
    }

    // Trail
    for (int i = 0; i < _trail.length; i++) {
      final t = i / _trail.length;
      final point = _trail[i];
      final trailOffset = (point.position - position).toOffset();
      final trailColor = point.inOrbit ? coreColor : trailBaseColor;
      final cometScale = progress.hasCometTrail ? 1.35 : 1.0;
      canvas.drawCircle(
        trailOffset,
        collisionRadius * (point.inOrbit ? 0.8 : 0.6) * t * cometScale,
        Paint()
          ..color = trailColor.withValues(
            alpha: t * (point.inOrbit ? 0.58 : 0.4) * cometScale.clamp(1, 1.15),
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + t * 5),
      );

      if (progress.hasSparkTrail && i % 5 == 0) {
        canvas.drawCircle(
          trailOffset + Offset(2 - (i % 3).toDouble(), -1),
          1.4 + t,
          Paint()..color = GameColors.textPrimary.withValues(alpha: t * 0.7),
        );
      }
    }

    final bodyColor = isInOrbit ? coreColor : ballColor;

    // Outer glow
    canvas.drawCircle(
      Offset.zero,
      collisionRadius * (isInOrbit ? 3.2 : 2.5),
      Paint()
        ..color = bodyColor.withValues(alpha: isInOrbit ? 0.24 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Ball body
    canvas.drawCircle(
      Offset.zero,
      collisionRadius,
      Paint()..color = bodyColor,
    );

    // Inner highlight
    canvas.drawCircle(
      const Offset(-2, -2),
      collisionRadius * 0.35,
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }
}

class _TrailPoint {
  final Vector2 position;
  final bool inOrbit;

  _TrailPoint(this.position, this.inOrbit);
}

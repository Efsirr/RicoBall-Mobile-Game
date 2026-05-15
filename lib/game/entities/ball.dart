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

  // Fixed-size circular buffer of trail points. Avoids the per-frame
  // List.add + List.removeAt(0) shift, and the per-point allocation.
  late final List<_TrailPoint> _trail = List<_TrailPoint>.generate(
    GameConst.trailLength,
    (_) => _TrailPoint(),
  );
  int _trailHead = 0; // index of next write
  int _trailCount = 0; // valid samples currently in the buffer

  Ball({required super.position}) : super(anchor: Anchor.center);

  double get collisionRadius => GameConst.ballRadius * radiusScale;

  void launch(Vector2 dir) {
    velocity = dir.normalized()..scale(GameConst.ballSpeed);
    isActive = true;
    lifetime = 0;
    isInOrbit = false;
    _resetTrail();
  }

  void setHeavy(bool enabled) {
    radiusScale = enabled ? 1.42 : 1.0;
  }

  void deactivate() {
    isActive = false;
    velocity.setZero();
    isInOrbit = false;
    _resetTrail();
  }

  void _resetTrail() {
    _trailHead = 0;
    _trailCount = 0;
  }

  void addTrailPoint() {
    final cell = _trail[_trailHead];
    cell.x = position.x;
    cell.y = position.y;
    cell.inOrbit = isInOrbit;
    _trailHead = (_trailHead + 1) % _trail.length;
    if (_trailCount < _trail.length) _trailCount++;
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

    // Trail — walk from oldest to newest. When the buffer is full the
    // oldest sample sits at _trailHead; otherwise it sits at index 0.
    final count = _trailCount;
    if (count > 0) {
      final len = _trail.length;
      final start = count < len ? 0 : _trailHead;
      final cometScale = progress.hasCometTrail ? 1.35 : 1.0;
      final hasSparks = progress.hasSparkTrail;
      for (int n = 0; n < count; n++) {
        final point = _trail[(start + n) % len];
        final t = n / count;
        final trailOffset = Offset(point.x - position.x, point.y - position.y);
        final trailColor = point.inOrbit ? coreColor : trailBaseColor;
        canvas.drawCircle(
          trailOffset,
          collisionRadius * (point.inOrbit ? 0.8 : 0.6) * t * cometScale,
          Paint()
            ..color = trailColor.withValues(
              alpha: t * (point.inOrbit ? 0.58 : 0.4) * cometScale.clamp(1, 1.15),
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + t * 5),
        );

        if (hasSparks && n % 5 == 0) {
          canvas.drawCircle(
            trailOffset + Offset(2 - (n % 3).toDouble(), -1),
            1.4 + t,
            Paint()..color = GameColors.textPrimary.withValues(alpha: t * 0.7),
          );
        }
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
  double x = 0;
  double y = 0;
  bool inOrbit = false;
}

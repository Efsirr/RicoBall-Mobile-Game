import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';

class Ball extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  bool isActive = false;
  double lifetime = 0;
  bool isInOrbit = false;
  final List<Vector2> _trail = [];

  Ball({required super.position}) : super(anchor: Anchor.center);

  void launch(Vector2 dir) {
    velocity = dir.normalized()..scale(GameConst.ballSpeed);
    isActive = true;
    lifetime = 0;
    isInOrbit = false;
    _trail.clear();
  }

  void deactivate() {
    isActive = false;
    velocity.setZero();
    isInOrbit = false;
    _trail.clear();
  }

  void addTrailPoint() {
    _trail.add(position.clone());
    while (_trail.length > GameConst.trailLength) {
      _trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) {
      canvas.drawCircle(
        Offset.zero,
        GameConst.ballRadius,
        Paint()..color = GameColors.neonCyan.withValues(alpha:0.3),
      );
      canvas.drawCircle(
        Offset.zero,
        GameConst.ballRadius * 1.8,
        Paint()
          ..color = GameColors.neonCyan.withValues(alpha:0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      return;
    }

    // Trail
    for (int i = 0; i < _trail.length; i++) {
      final t = i / _trail.length;
      final trailOffset = (_trail[i] - position).toOffset();
      canvas.drawCircle(
        trailOffset,
        GameConst.ballRadius * 0.6 * t,
        Paint()
          ..color = GameColors.neonCyan.withValues(alpha:t * 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + t * 4),
      );
    }

    // Outer glow
    canvas.drawCircle(
      Offset.zero,
      GameConst.ballRadius * 2.5,
      Paint()
        ..color = GameColors.neonCyan.withValues(alpha:0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Ball body
    canvas.drawCircle(
      Offset.zero,
      GameConst.ballRadius,
      Paint()..color = GameColors.neonCyan,
    );

    // Inner highlight
    canvas.drawCircle(
      const Offset(-2, -2),
      GameConst.ballRadius * 0.35,
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }
}

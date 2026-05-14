import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/constants.dart';
import '../physics/physics_engine.dart';

class AimLine extends Component with HasGameReference<FlameGame> {
  List<Vector2> _points = [];

  void calculate(Vector2 origin, Vector2 velocity, Vector2 orbitCorePos) {
    _points = _simulate(origin, velocity, orbitCorePos);
  }

  void clear() => _points = [];

  List<Vector2> _simulate(
    Vector2 startPos,
    Vector2 vel,
    Vector2 corePos,
  ) {
    final pts = <Vector2>[];
    final pos = startPos.clone();
    final v = vel.clone();
    final field = PhysicsEngine.gameField(game.size);
    const r = GameConst.ballRadius;

    for (int i = 0; i < GameConst.trajectorySteps; i++) {
      pos.add(v.scaled(GameConst.trajectoryDt));

      // Wall bounces
      if (pos.x - r < field.left) {
        pos.x = field.left + r;
        v.x = v.x.abs();
      }
      if (pos.x + r > field.right) {
        pos.x = field.right - r;
        v.x = -v.x.abs();
      }
      if (pos.y - r < field.top) {
        pos.y = field.top + r;
        v.y = v.y.abs();
      }
      if (pos.y + r > field.bottom) {
        pos.y = field.bottom - r;
        v.y = -v.y.abs();
      }

      // Orbit influence
      final toCore = corePos - pos;
      final dist = toCore.length;
      if (dist < GameConst.orbitInfluenceRadius &&
          dist > GameConst.orbitCoreRadius) {
        final t = 1.0 - dist / GameConst.orbitInfluenceRadius;
        final str = GameConst.orbitStrength * t * t;
        v.add(toCore.normalized()..scale(str * GameConst.trajectoryDt));
      }

      v.scale(GameConst.ballDrag);
      pts.add(pos.clone());
    }

    return pts;
  }

  @override
  void render(Canvas canvas) {
    if (_points.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < _points.length; i++) {
      if (i % 4 >= 2) continue; // Dashed pattern

      final t = 1.0 - (i / _points.length);
      paint.color = GameColors.aimLine.withValues(alpha:t * 0.6);
      canvas.drawLine(
        _points[i - 1].toOffset(),
        _points[i].toOffset(),
        paint,
      );
    }
  }
}

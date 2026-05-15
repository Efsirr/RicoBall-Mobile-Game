import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class LevelFlash extends Component with HasGameReference<FlameGame> {
  static const double _duration = 0.45;

  final Color color;
  double _age = 0;

  LevelFlash({required this.color});

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1.0 - t) * 0.22;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      Paint()..color = color.withValues(alpha: opacity),
    );
  }
}

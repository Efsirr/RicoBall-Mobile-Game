import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/constants.dart';
import '../physics/physics_engine.dart';

class Background extends Component with HasGameReference<FlameGame> {
  @override
  void render(Canvas canvas) {
    final s = game.size;

    // Fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.x, s.y),
      Paint()..color = GameColors.background,
    );

    // Subtle grid
    final gridPaint = Paint()
      ..color = GameColors.gridLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 40.0;
    for (double x = 0; x < s.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.y), gridPaint);
    }
    for (double y = 0; y < s.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(s.x, y), gridPaint);
    }

    // Wall glow
    final field = PhysicsEngine.gameField(s);
    canvas.drawRect(
      field,
      Paint()
        ..color = GameColors.wallGlow.withValues(alpha:0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Wall border
    canvas.drawRect(
      field,
      Paint()
        ..color = GameColors.wallColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

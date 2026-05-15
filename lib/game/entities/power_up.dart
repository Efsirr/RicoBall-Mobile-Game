import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle, RadialGradient;

import '../core/constants.dart';
import '../core/power_up_type.dart';

class PowerUp extends PositionComponent {
  final PowerUpType type;

  double _age = 0;

  PowerUp({required super.position, required this.type})
    : super(
        anchor: Anchor.center,
        size: Vector2.all(GameConst.powerUpRadius * 2),
      );

  double get collisionRadius => GameConst.powerUpRadius;

  @override
  void update(double dt) {
    _age += dt;
    final hover = sin(_age * 3.2) * 2.2;
    scale.setAll(0.94 + sin(_age * 4.6) * 0.035);
    position.y += hover * dt;
  }

  @override
  void render(Canvas canvas) {
    final pulse = (sin(_age * 4.0) + 1) / 2;
    final color = type.color;

    canvas.drawCircle(
      Offset.zero,
      collisionRadius * 2.0,
      Paint()
        ..color = color.withValues(alpha: 0.12 + pulse * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(
      Offset.zero,
      collisionRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.38),
            GameColors.surface.withValues(alpha: 0.84),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset.zero, radius: collisionRadius),
        ),
    );
    canvas.drawCircle(
      Offset.zero,
      collisionRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = GameColors.textPrimary.withValues(alpha: 0.28),
    );

    final painter = TextPainter(
      text: TextSpan(
        text: type.glyph,
        style: const TextStyle(
          color: GameColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}

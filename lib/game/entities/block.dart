import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

import '../core/constants.dart';

class Block extends PositionComponent {
  int hp;
  final int maxHp;
  double _flashTimer = 0;

  Block({
    required super.position,
    required this.hp,
    required super.size,
  })  : maxHp = hp,
        super(anchor: Anchor.center);

  Color get baseColor => switch (hp) {
        1 => GameColors.blockHp1,
        2 => GameColors.blockHp2,
        _ => GameColors.blockHp3,
      };

  void onHit() {
    hp--;
    _flashTimer = 0.12;
  }

  bool get isDestroyed => hp <= 0;

  @override
  void update(double dt) {
    if (_flashTimer > 0) _flashTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(6)),
      Paint()
        ..color = baseColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Body
    canvas.drawRRect(
      rrect,
      Paint()..color = _flashTimer > 0 ? const Color(0xFFFFFFFF) : baseColor,
    );

    // Border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = baseColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // HP label
    if (hp > 1) {
      final tp = TextPainter(
        text: TextSpan(
          text: '$hp',
          style: TextStyle(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2),
      );
    }
  }
}

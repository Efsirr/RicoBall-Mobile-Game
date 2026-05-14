import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

import '../core/constants.dart';

class ComboDisplay extends Component with HasGameReference<FlameGame> {
  String? _text;
  double _timer = 0;
  static const double _duration = 1.5;

  void show(String text) {
    _text = text;
    _timer = _duration;
  }

  @override
  void update(double dt) {
    if (_timer > 0) {
      _timer -= dt;
      if (_timer <= 0) _text = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_text == null || _timer <= 0) return;

    final opacity = (_timer / _duration).clamp(0.0, 1.0);
    final scale = 1.0 + (1 - opacity) * 0.3;
    final yOffset = (1 - opacity) * -20;

    final s = game.size;

    // Glow behind text
    final glowPaint = Paint()
      ..color = GameColors.comboText.withValues(alpha:opacity * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(
      Offset(s.x / 2, s.y * 0.25 + yOffset),
      60,
      glowPaint,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: _text,
        style: TextStyle(
          color: GameColors.comboText.withValues(alpha:opacity),
          fontSize: 28 * scale,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        (s.x - tp.width) / 2,
        s.y * 0.25 + yOffset - tp.height / 2,
      ),
    );
  }
}

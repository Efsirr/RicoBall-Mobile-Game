import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

import '../core/constants.dart';

enum BlockType { standard, explosive, reinforced, moving, indestructible }

class Block extends PositionComponent {
  static const double _spawnDuration = 0.22;

  int hp;
  final int maxHp;
  final BlockType type;
  final double? moveMinX;
  final double? moveMaxX;
  double _flashTimer = 0;
  double _spawnTimer = 0;
  double _moveDirection = 1;

  Block({
    required super.position,
    required this.hp,
    required super.size,
    this.type = BlockType.standard,
    this.moveMinX,
    this.moveMaxX,
  }) : maxHp = hp,
       super(anchor: Anchor.center);

  bool get isDestructible => type != BlockType.indestructible;

  Color get baseColor => switch (type) {
    BlockType.explosive => GameColors.danger,
    BlockType.reinforced => GameColors.warning,
    BlockType.moving => GameColors.electricBlue,
    BlockType.indestructible => GameColors.textTertiary,
    BlockType.standard => switch (hp) {
      1 => GameColors.blockHp1,
      2 => GameColors.blockHp2,
      _ => GameColors.blockHp3,
    },
  };

  bool onHit(double impactSpeed) {
    _flashTimer = 0.12;
    if (type == BlockType.indestructible) return false;
    if (type == BlockType.reinforced &&
        impactSpeed < GameConst.reinforcedDamageSpeed) {
      return false;
    }

    hp--;
    return true;
  }

  bool get isDestroyed => isDestructible && hp <= 0;

  @override
  void update(double dt) {
    if (_flashTimer > 0) _flashTimer -= dt;

    if (type == BlockType.moving && moveMinX != null && moveMaxX != null) {
      position.x += GameConst.movingBlockSpeed * _moveDirection * dt;
      if (position.x <= moveMinX!) {
        position.x = moveMinX!;
        _moveDirection = 1;
      } else if (position.x >= moveMaxX!) {
        position.x = moveMaxX!;
        _moveDirection = -1;
      }
    }

    if (_spawnTimer < _spawnDuration) {
      _spawnTimer += dt;
      final t = (_spawnTimer / _spawnDuration).clamp(0.0, 1.0);
      final eased = 1 - (1 - t) * (1 - t) * (1 - t);
      scale.setAll(0.78 + eased * 0.22);
    } else {
      scale.setAll(1);
    }
  }

  @override
  void render(Canvas canvas) {
    final spawnT = (_spawnTimer / _spawnDuration).clamp(0.0, 1.0);
    final opacity = _flashTimer > 0 ? 1.0 : spawnT;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(6)),
      Paint()
        ..color = baseColor.withValues(alpha: 0.25 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Body
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _flashTimer > 0
            ? const Color(0xFFFFFFFF)
            : baseColor.withValues(alpha: opacity),
    );

    // Border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = baseColor.withValues(alpha: 0.6 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _renderTypeDetails(canvas, rect, opacity);

    // HP label
    if (isDestructible && hp > 1) {
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

  void _renderTypeDetails(Canvas canvas, Rect rect, double opacity) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55 * opacity);

    switch (type) {
      case BlockType.standard:
        break;
      case BlockType.explosive:
        canvas.drawCircle(
          Offset(rect.right - 8, rect.top + 8),
          3.5,
          Paint()..color = GameColors.warning.withValues(alpha: 0.82 * opacity),
        );
        canvas.drawCircle(
          Offset(rect.right - 8, rect.top + 8),
          7,
          Paint()
            ..color = GameColors.danger.withValues(alpha: 0.18 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        break;
      case BlockType.reinforced:
        canvas
          ..drawLine(
            Offset(rect.left + 9, rect.top + 7),
            Offset(rect.right - 9, rect.top + 7),
            paint,
          )
          ..drawLine(
            Offset(rect.left + 9, rect.bottom - 7),
            Offset(rect.right - 9, rect.bottom - 7),
            paint,
          );
        break;
      case BlockType.moving:
        canvas.drawLine(
          Offset(rect.left + 10, rect.bottom - 6),
          Offset(rect.right - 10, rect.bottom - 6),
          paint..color = GameColors.neonCyan.withValues(alpha: 0.55 * opacity),
        );
        break;
      case BlockType.indestructible:
        canvas
          ..drawLine(
            Offset(rect.left + 10, rect.top + 6),
            Offset(rect.right - 10, rect.bottom - 6),
            paint,
          )
          ..drawLine(
            Offset(rect.left + 10, rect.bottom - 6),
            Offset(rect.right - 10, rect.top + 6),
            paint,
          );
        break;
    }
  }
}

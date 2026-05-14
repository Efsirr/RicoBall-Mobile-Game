import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart' hide Block;

import 'constants.dart';
import '../entities/block.dart';

class LevelGenerator {
  final Random _rng = Random();

  List<Block> generate({
    required Rect field,
    required int level,
    required Vector2 orbitCorePos,
    required double orbitRadius,
  }) {
    final blocks = <Block>[];

    const bw = GameConst.blockWidth;
    const bh = GameConst.blockHeight;
    const gap = 6.0;

    final cols = ((field.width - 20) / (bw + gap)).floor();
    final rows = (2 + level).clamp(3, 7);

    final totalW = cols * (bw + gap) - gap;
    final startX = field.left + (field.width - totalW) / 2 + bw / 2;
    final startY = field.top + 50;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (_rng.nextDouble() < 0.25) continue;

        final x = startX + col * (bw + gap);
        final y = startY + row * (bh + gap);
        final pos = Vector2(x, y);

        if (pos.distanceTo(orbitCorePos) < orbitRadius + 30) continue;

        final hp = 1 + _rng.nextInt(level.clamp(1, 3));
        blocks.add(Block(position: pos, hp: hp, size: Vector2(bw, bh)));
      }
    }

    if (blocks.isEmpty) {
      blocks.add(Block(
        position: Vector2(field.center.dx, field.top + 80),
        hp: 1,
        size: Vector2(bw, bh),
      ));
    }

    return blocks;
  }
}

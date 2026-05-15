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
    required List<Vector2> orbitCorePositions,
    required double orbitRadius,
    int? seed,
  }) {
    final rng = seed == null ? _rng : Random(seed);
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
        if (rng.nextDouble() < 0.25) continue;

        final x = startX + col * (bw + gap);
        final y = startY + row * (bh + gap);
        final pos = Vector2(x, y);

        final insideCoreField = orbitCorePositions.any(
          (corePos) => pos.distanceTo(corePos) < orbitRadius + 30,
        );
        if (insideCoreField) continue;

        final hp = 1 + rng.nextInt(level.clamp(1, 3));
        final type = _pickBlockType(level, rng);
        blocks.add(
          Block(
            position: pos,
            hp: type == BlockType.indestructible ? 1 : hp,
            size: Vector2(bw, bh),
            type: type,
            moveMinX: type == BlockType.moving
                ? max(field.left + bw / 2, x - 46)
                : null,
            moveMaxX: type == BlockType.moving
                ? min(field.right - bw / 2, x + 46)
                : null,
          ),
        );
      }
    }

    if (blocks.isEmpty) {
      blocks.add(
        Block(
          position: Vector2(field.center.dx, field.top + 80),
          hp: 1,
          size: Vector2(bw, bh),
        ),
      );
    }

    return blocks;
  }

  BlockType _pickBlockType(int level, Random rng) {
    final roll = rng.nextDouble();

    if (level >= 6 && roll < 0.06) return BlockType.indestructible;
    if (level >= 5 && roll < 0.13) return BlockType.moving;
    if (level >= 4 && roll < 0.21) return BlockType.reinforced;
    if (level >= 3 && roll < 0.29) return BlockType.explosive;

    return BlockType.standard;
  }
}

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class BlockParticles extends PositionComponent {
  static final Random _rng = Random();
  static const double _duration = 0.55;

  final Color color;
  final List<_Shard> _shards;
  double _age = 0;

  BlockParticles({required super.position, required this.color, int count = 16})
    : _shards = List.generate(count, _Shard.random),
      super(anchor: Anchor.center);

  @override
  void update(double dt) {
    _age += dt;

    for (final shard in _shards) {
      shard.velocity.y += 180 * dt;
      shard.position.add(shard.velocity.scaled(dt));
      shard.rotation += shard.spin * dt;
    }

    if (_age >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1.0 - t) * (1.0 - t);

    for (final shard in _shards) {
      canvas.save();
      canvas.translate(shard.position.x, shard.position.y);
      canvas.rotate(shard.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: shard.size.x,
            height: shard.size.y,
          ),
          const Radius.circular(1.5),
        ),
        Paint()
          ..color = color.withValues(alpha: opacity * shard.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      canvas.restore();
    }
  }
}

class _Shard {
  final Vector2 position = Vector2.zero();
  final Vector2 velocity;
  final Vector2 size;
  final double opacity;
  final double spin;
  double rotation;

  _Shard({
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.spin,
    required this.rotation,
  });

  factory _Shard.random(int index) {
    final angle =
        (index / 16) * pi * 2 + (BlockParticles._rng.nextDouble() - 0.5) * 0.8;
    final speed = 90 + BlockParticles._rng.nextDouble() * 180;

    return _Shard(
      velocity: Vector2(cos(angle), sin(angle))..scale(speed),
      size: Vector2(
        3 + BlockParticles._rng.nextDouble() * 7,
        2 + BlockParticles._rng.nextDouble() * 4,
      ),
      opacity: 0.45 + BlockParticles._rng.nextDouble() * 0.55,
      spin: -8 + BlockParticles._rng.nextDouble() * 16,
      rotation: BlockParticles._rng.nextDouble() * pi,
    );
  }
}

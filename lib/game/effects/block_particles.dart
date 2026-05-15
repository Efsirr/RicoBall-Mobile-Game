import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class BlockParticles extends PositionComponent {
  static final Random _rng = Random();
  static const double _duration = 0.55;
  static const int _shardCount = 16;

  // Pool of shard lists. Each list has _shardCount mutable shards. When a
  // BlockParticles is added, it borrows one list (or allocates if empty);
  // on removal it returns the list. Capped to avoid unbounded growth.
  static const int _poolMax = 24;
  static final List<List<_Shard>> _pool = [];

  final Color color;
  final List<_Shard> _shards;
  double _age = 0;

  BlockParticles({required super.position, required this.color})
      : _shards = _acquireShards(),
        super(anchor: Anchor.center);

  static List<_Shard> _acquireShards() {
    final shards = _pool.isNotEmpty
        ? _pool.removeLast()
        : List<_Shard>.generate(_shardCount, (_) => _Shard());
    for (var i = 0; i < shards.length; i++) {
      shards[i].reset(i);
    }
    return shards;
  }

  @override
  void onRemove() {
    if (_pool.length < _poolMax) {
      _pool.add(_shards);
    }
    super.onRemove();
  }

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
  final Vector2 velocity = Vector2.zero();
  final Vector2 size = Vector2.zero();
  double opacity = 1.0;
  double spin = 0;
  double rotation = 0;

  void reset(int index) {
    final rng = BlockParticles._rng;
    final angle =
        (index / BlockParticles._shardCount) * pi * 2 + (rng.nextDouble() - 0.5) * 0.8;
    final speed = 90 + rng.nextDouble() * 180;

    position.setZero();
    velocity.setValues(cos(angle) * speed, sin(angle) * speed);
    size.setValues(
      3 + rng.nextDouble() * 7,
      2 + rng.nextDouble() * 4,
    );
    opacity = 0.45 + rng.nextDouble() * 0.55;
    spin = -8 + rng.nextDouble() * 16;
    rotation = rng.nextDouble() * pi;
  }
}

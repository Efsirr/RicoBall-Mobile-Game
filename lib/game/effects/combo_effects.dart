import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, FontWeight;

import '../core/constants.dart';

enum ComboTier { none, spark, surge, streak, blaze, apex, singularity }

ComboTier comboTierFor(int combo) {
  if (combo < 2) return ComboTier.none;
  if (combo < 5) return ComboTier.spark;
  if (combo < 10) return ComboTier.surge;
  if (combo < 20) return ComboTier.streak;
  if (combo < 35) return ComboTier.blaze;
  if (combo < 50) return ComboTier.apex;
  return ComboTier.singularity;
}

String _tierLabel(ComboTier tier) => switch (tier) {
      ComboTier.none => '',
      ComboTier.spark => 'SPARK',
      ComboTier.surge => 'SURGE',
      ComboTier.streak => 'STREAK',
      ComboTier.blaze => 'BLAZE',
      ComboTier.apex => 'TRANSCENDENT',
      ComboTier.singularity => 'SINGULARITY',
    };

Color _tierColor(ComboTier tier) => switch (tier) {
      ComboTier.none => GameColors.neonCyan,
      ComboTier.spark => GameColors.neonCyan,
      ComboTier.surge => const Color(0xFF7AE5FF),
      ComboTier.streak => GameColors.electricBlue,
      ComboTier.blaze => const Color(0xFF7090FF),
      ComboTier.apex => const Color(0xFFB585FF),
      ComboTier.singularity => const Color(0xFFFF6BD4),
    };

Color _tierAccent(ComboTier tier) => switch (tier) {
      ComboTier.none => GameColors.neonCyan,
      ComboTier.spark => GameColors.neonCyan,
      ComboTier.surge => GameColors.neonCyan,
      ComboTier.streak => const Color(0xFF7AE5FF),
      ComboTier.blaze => const Color(0xFFB585FF),
      ComboTier.apex => const Color(0xFFFF6BD4),
      ComboTier.singularity => const Color(0xFFFFD166),
    };

double _tierIntensity(ComboTier tier) => switch (tier) {
      ComboTier.none => 0.0,
      ComboTier.spark => 0.2,
      ComboTier.surge => 0.4,
      ComboTier.streak => 0.6,
      ComboTier.blaze => 0.78,
      ComboTier.apex => 0.9,
      ComboTier.singularity => 1.0,
    };

final Random _rng = Random();

// ─── Dispatcher ────────────────────────────────────────────────────────────

class ComboFx {
  static void onBlockHit({
    required FlameGame game,
    required Vector2 impactPosition,
    required Vector2 ballPosition,
    required int combo,
    required int previousCombo,
    required int scoreDelta,
    required bool perfectOrbit,
  }) {
    final tier = comboTierFor(combo);
    final prevTier = comboTierFor(previousCombo);
    final tierBroke = tier.index > prevTier.index && tier != ComboTier.none;

    if (combo >= 1) {
      game.world.add(ComboRingPulse(impactPosition.clone(), tier)..priority = 28);
      game.world.add(ScoreFloat(impactPosition.clone(), scoreDelta, tier)..priority = 33);
    }

    if (tier.index >= ComboTier.spark.index) {
      game.world.add(ImpactBurst(impactPosition.clone(), tier)..priority = 27);
      game.world.add(MicroFlash(tier)..priority = 87);
    }

    if (tier.index >= ComboTier.surge.index) {
      game.world.add(GridPulse(tier)..priority = 5);
      game.world.add(BallAura(ballPosition.clone(), tier)..priority = 24);
    }

    if (tier.index >= ComboTier.streak.index) {
      game.world.add(ChromaticEdge(tier)..priority = 88);
      if (_rng.nextDouble() < 0.5) {
        game.world.add(LightBeam(impactPosition.clone(), tier)..priority = 26);
      }
    }

    if (tier.index >= ComboTier.blaze.index) {
      game.world.add(ComboAurora(tier)..priority = 6);
      game.world.add(FrameGlow(tier)..priority = 22);
      game.world.add(VignetteBreath(tier)..priority = 86);
    }

    if (tier.index >= ComboTier.apex.index) {
      game.world.add(CenterRing(tier)..priority = 7);
      game.world.add(ParticleHalo(ballPosition.clone(), tier)..priority = 24);
      game.world.add(ConcentricRings(impactPosition.clone(), tier)..priority = 28);
    }

    if (tier == ComboTier.singularity) {
      game.world.add(SingularityRift(tier)..priority = 8);
      game.world.add(StarBurst(impactPosition.clone(), tier)..priority = 29);
    }

    if (tierBroke) {
      game.world.add(TierBanner(tier)..priority = 95);
      game.world.add(Shockwave(impactPosition.clone(), tier, intensity: 1.0)..priority = 92);
      game.world.add(ScreenSlash(tier)..priority = 94);
    }

    if (combo > 0 && combo % 5 == 0) {
      game.world.add(NumberStamp(impactPosition.clone(), combo, tier)..priority = 33);
      if (!tierBroke) {
        game.world.add(Shockwave(impactPosition.clone(), tier, intensity: 0.55)..priority = 92);
      }
    }

    if (perfectOrbit) {
      game.world.add(ComboRingPulse(impactPosition.clone(), tier, accent: true)..priority = 28);
    }
  }
}

// ─── 1. ComboRingPulse ─────────────────────────────────────────────────────

class ComboRingPulse extends PositionComponent {
  ComboRingPulse(Vector2 pos, this.tier, {this.accent = false})
      : super(position: pos);

  final ComboTier tier;
  final bool accent;
  static const _duration = 0.55;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final eased = 1 - (1 - t) * (1 - t);
    final radius = 10 + eased * (44 + tier.index * 14);
    final opacity = (1 - t) * (0.55 + _tierIntensity(tier) * 0.25);
    final color = accent ? _tierAccent(tier) : _tierColor(tier);

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}

// ─── 2. ScoreFloat ─────────────────────────────────────────────────────────

class ScoreFloat extends PositionComponent {
  ScoreFloat(Vector2 pos, this.points, this.tier) : super(position: pos);

  final int points;
  final ComboTier tier;
  static const _duration = 0.9;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    position.y -= 38 * dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1 - t * t);
    final scale = 1 + tier.index * 0.07;
    final color = _tierColor(tier);

    final tp = TextPainter(
      text: TextSpan(
        text: '+$points',
        style: TextStyle(
          color: color.withValues(alpha: opacity),
          fontSize: 14 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Glow shadow
    final shadow = TextPainter(
      text: TextSpan(
        text: '+$points',
        style: TextStyle(
          color: color.withValues(alpha: opacity * 0.4),
          fontSize: 14 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(0, 0);
    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.saveLayer(
      Rect.fromCenter(center: Offset.zero, width: 80, height: 40),
      shadowPaint,
    );
    shadow.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
    canvas.restore();

    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}

// ─── 3. ImpactBurst ────────────────────────────────────────────────────────

class ImpactBurst extends PositionComponent {
  ImpactBurst(Vector2 pos, this.tier) : super(position: pos);

  final ComboTier tier;
  static const _duration = 0.32;
  double _age = 0;
  late final int _spokes = 4 + tier.index * 2;
  late final double _phase = _rng.nextDouble() * pi;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1 - t) * 0.85;
    final inner = 8.0;
    final outer = 18 + t * (28 + tier.index * 6);

    final paint = Paint()
      ..color = _tierColor(tier).withValues(alpha: opacity)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    for (var i = 0; i < _spokes; i++) {
      final a = _phase + (i / _spokes) * pi * 2;
      final c = cos(a);
      final s = sin(a);
      canvas.drawLine(
        Offset(c * inner, s * inner),
        Offset(c * outer, s * outer),
        paint,
      );
    }
  }
}

// ─── 4. MicroFlash ─────────────────────────────────────────────────────────

class MicroFlash extends Component with HasGameReference<FlameGame> {
  MicroFlash(this.tier);

  final ComboTier tier;
  static const _duration = 0.14;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1 - t) * 0.06 * (1 + _tierIntensity(tier));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      Paint()..color = _tierColor(tier).withValues(alpha: opacity),
    );
  }
}

// ─── 5. ChromaticEdge ──────────────────────────────────────────────────────

class ChromaticEdge extends Component with HasGameReference<FlameGame> {
  ChromaticEdge(this.tier);

  final ComboTier tier;
  static const _duration = 0.45;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.34 * (0.5 + _tierIntensity(tier) * 0.5);
    final s = game.size;
    final w = 36 + tier.index * 8;

    final rPaint = Paint()
      ..color = const Color(0xFFFF3366).withValues(alpha: opacity * 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w.toDouble());
    final bPaint = Paint()
      ..color = _tierColor(tier).withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w.toDouble());

    canvas.drawRect(Rect.fromLTWH(-4, 0, 8, s.y), rPaint);
    canvas.drawRect(Rect.fromLTWH(s.x - 4, 0, 8, s.y), bPaint);
  }
}

// ─── 6. GridPulse ──────────────────────────────────────────────────────────

class GridPulse extends Component with HasGameReference<FlameGame> {
  GridPulse(this.tier);

  final ComboTier tier;
  static const _duration = 0.5;
  static const _spacing = 38.0;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.12 * _tierIntensity(tier);
    final paint = Paint()
      ..color = _tierColor(tier).withValues(alpha: opacity)
      ..strokeWidth = 0.8;

    final s = game.size;
    for (double x = 0; x < s.x; x += _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.y), paint);
    }
    for (double y = 0; y < s.y; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(s.x, y), paint);
    }
  }
}

// ─── 7. ComboAurora ────────────────────────────────────────────────────────

class ComboAurora extends Component with HasGameReference<FlameGame> {
  ComboAurora(this.tier);

  final ComboTier tier;
  static const _duration = 0.85;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.32 * _tierIntensity(tier);
    final color = _tierColor(tier);
    final s = game.size;

    final rect = Rect.fromLTWH(0, 0, s.x, s.y * 0.45);
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(0, 0),
        Offset(0, rect.height),
        [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      );
    canvas.drawRect(rect, paint);

    final bottom = Rect.fromLTWH(0, s.y * 0.65, s.x, s.y * 0.35);
    final paint2 = Paint()
      ..shader = Gradient.linear(
        Offset(0, bottom.top),
        Offset(0, bottom.bottom),
        [
          color.withValues(alpha: 0),
          color.withValues(alpha: opacity * 0.6),
        ],
      );
    canvas.drawRect(bottom, paint2);
  }
}

// ─── 8. FrameGlow ──────────────────────────────────────────────────────────

class FrameGlow extends Component with HasGameReference<FlameGame> {
  FrameGlow(this.tier);

  final ComboTier tier;
  static const _duration = 0.6;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.5 * _tierIntensity(tier);
    final s = game.size;
    final inset = GameConst.wallInset;
    final rect = Rect.fromLTRB(
      inset,
      GameConst.fieldTopInset,
      s.x - inset,
      s.y - GameConst.fieldBottomInset,
    );

    final paint = Paint()
      ..color = _tierColor(tier).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      paint,
    );
  }
}

// ─── 9. BallAura ───────────────────────────────────────────────────────────

class BallAura extends PositionComponent {
  BallAura(Vector2 pos, this.tier) : super(position: pos);

  final ComboTier tier;
  static const _duration = 0.42;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1 - t) * 0.55 * _tierIntensity(tier);
    final radius = 18 + tier.index * 4 + t * 8;
    final color = _tierColor(tier);

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = Gradient.radial(
          Offset.zero,
          radius,
          [
            color.withValues(alpha: opacity * 0.8),
            color.withValues(alpha: 0),
          ],
        ),
    );
  }
}

// ─── 10. LightBeam ─────────────────────────────────────────────────────────

class LightBeam extends PositionComponent with HasGameReference<FlameGame> {
  LightBeam(Vector2 pos, this.tier) : super(position: pos);

  final ComboTier tier;
  static const _duration = 0.32;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.5 * _tierIntensity(tier);
    final width = 6.0 + tier.index * 1.5;
    final color = _tierColor(tier);

    final rect = Rect.fromLTWH(
      -width / 2,
      -position.y,
      width,
      position.y + 20,
    );
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(0, rect.top),
        Offset(0, rect.bottom),
        [
          color.withValues(alpha: 0),
          color.withValues(alpha: opacity),
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(rect, paint);
  }
}

// ─── 11. CenterRing ────────────────────────────────────────────────────────

class CenterRing extends Component with HasGameReference<FlameGame> {
  CenterRing(this.tier);

  final ComboTier tier;
  static const _duration = 0.55;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.55 * _tierIntensity(tier);
    final s = game.size;
    final cx = s.x / 2;
    final cy = s.y * 0.42;
    final radius = 60 + tier.index * 14 + t * 30;

    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = _tierColor(tier).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }
}

// ─── 12. ParticleHalo ──────────────────────────────────────────────────────

class ParticleHalo extends PositionComponent {
  ParticleHalo(Vector2 pos, this.tier) : super(position: pos);

  final ComboTier tier;
  static const _duration = 0.6;
  double _age = 0;
  late final List<_HaloMote> _motes = List.generate(
    8 + tier.index * 2,
    (i) => _HaloMote(
      angle: (i / (8 + tier.index * 2)) * pi * 2,
      radius: 22.0 + _rng.nextDouble() * 12,
      spinRate: 2.6 + _rng.nextDouble() * 1.6,
      size: 1.5 + _rng.nextDouble() * 1.5,
    ),
  );

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1 - t) * 0.85 * _tierIntensity(tier);
    final color = _tierAccent(tier);

    for (final mote in _motes) {
      final a = mote.angle + _age * mote.spinRate;
      final p = Offset(cos(a) * mote.radius, sin(a) * mote.radius);
      canvas.drawCircle(
        p,
        mote.size,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }
}

class _HaloMote {
  final double angle;
  final double radius;
  final double spinRate;
  final double size;

  _HaloMote({
    required this.angle,
    required this.radius,
    required this.spinRate,
    required this.size,
  });
}

// ─── 13. ConcentricRings ───────────────────────────────────────────────────

class ConcentricRings extends PositionComponent {
  ConcentricRings(Vector2 pos, this.tier) : super(position: pos);

  final ComboTier tier;
  static const _duration = 0.75;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final color = _tierColor(tier);
    for (var i = 0; i < 3; i++) {
      final offset = i * 0.18;
      final localT = ((_age - offset) / (_duration - offset)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = 1 - (1 - localT) * (1 - localT);
      final radius = 14 + eased * (80 + tier.index * 10);
      final opacity = (1 - localT) * 0.45;
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }
}

// ─── 14. VignetteBreath ────────────────────────────────────────────────────

class VignetteBreath extends Component with HasGameReference<FlameGame> {
  VignetteBreath(this.tier);

  final ComboTier tier;
  static const _duration = 0.75;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.32 * _tierIntensity(tier);
    final s = game.size;
    final cx = s.x / 2;
    final cy = s.y / 2;
    final r = sqrt(s.x * s.x + s.y * s.y) * 0.6;

    final paint = Paint()
      ..shader = Gradient.radial(
        Offset(cx, cy),
        r,
        [
          const Color(0x00000000),
          Color.fromRGBO(5, 8, 16, opacity),
        ],
        const [0.55, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, s.x, s.y), paint);
  }
}

// ─── 15. SingularityRift ───────────────────────────────────────────────────

class SingularityRift extends Component with HasGameReference<FlameGame> {
  SingularityRift(this.tier);

  static const _duration = 0.7;
  final ComboTier tier;
  double _age = 0;
  late final double _phase = _rng.nextDouble() * pi;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pulse = sin(t * pi);
    final opacity = pulse * 0.6;
    final s = game.size;
    final cx = s.x / 2;
    final cy = s.y * 0.42;
    final accent = _tierAccent(tier);
    final core = _tierColor(tier);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_age * 1.6 + _phase);
    final paint = Paint()
      ..shader = Gradient.linear(
        const Offset(-180, 0),
        const Offset(180, 0),
        [
          core.withValues(alpha: 0),
          accent.withValues(alpha: opacity),
          core.withValues(alpha: 0),
        ],
        const [0.0, 0.5, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 360, height: 22),
      paint,
    );
    canvas.restore();
  }
}

// ─── 16. TierBanner ────────────────────────────────────────────────────────

class TierBanner extends Component with HasGameReference<FlameGame> {
  TierBanner(this.tier);

  final ComboTier tier;
  static const _duration = 1.4;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final label = _tierLabel(tier);
    if (label.isEmpty) return;

    final t = (_age / _duration).clamp(0.0, 1.0);
    final enter = (t * 4).clamp(0.0, 1.0);
    final exit = t > 0.7 ? 1 - ((t - 0.7) / 0.3).clamp(0.0, 1.0) : 1.0;
    final opacity = enter * exit;

    final s = game.size;
    final cx = s.x / 2;
    final cy = s.y * 0.34;
    final color = _tierColor(tier);
    final accent = _tierAccent(tier);

    // Backdrop bar
    final barW = 220 + tier.index * 22.0;
    final barRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: barW * enter,
      height: 2,
    );
    canvas.drawRect(
      barRect,
      Paint()
        ..color = accent.withValues(alpha: opacity * 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Glow disc
    canvas.drawCircle(
      Offset(cx, cy),
      80 + tier.index * 8,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
    );

    // Letter-by-letter reveal
    final reveal = (t * 2.2).clamp(0.0, 1.0);
    final shownLen = (label.length * reveal).round();
    final shown = label.substring(0, shownLen);

    final fontSize = 30.0 + tier.index * 2.0;
    final tp = TextPainter(
      text: TextSpan(
        text: shown,
        style: TextStyle(
          color: color.withValues(alpha: opacity),
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 7,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height - 14));
  }
}

// ─── 17. Shockwave ─────────────────────────────────────────────────────────

class Shockwave extends PositionComponent {
  Shockwave(Vector2 pos, this.tier, {this.intensity = 1.0}) : super(position: pos);

  final ComboTier tier;
  final double intensity;
  static const _duration = 0.65;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final eased = 1 - (1 - t) * (1 - t) * (1 - t);
    final radius = eased * (220 + tier.index * 36) * intensity;
    final opacity = (1 - t) * 0.7;
    final color = _tierColor(tier);

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3.0 + tier.index * 0.4) * intensity
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.92,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }
}

// ─── 18. ScreenSlash ───────────────────────────────────────────────────────

class ScreenSlash extends Component with HasGameReference<FlameGame> {
  ScreenSlash(this.tier);

  final ComboTier tier;
  static const _duration = 0.32;
  double _age = 0;
  late final double _angle = -0.6 + _rng.nextDouble() * 1.2;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final eased = 1 - (1 - t) * (1 - t);
    final opacity = (1 - t) * 0.7;
    final s = game.size;
    final cx = s.x / 2;
    final cy = s.y / 2;
    final color = _tierAccent(tier);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_angle);
    final reveal = eased * (s.x * 1.4);
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(-reveal, 0),
        Offset(reveal, 0),
        [
          color.withValues(alpha: 0),
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: reveal * 2, height: 4),
      paint,
    );
    canvas.restore();
  }
}

// ─── 19. NumberStamp ───────────────────────────────────────────────────────

class NumberStamp extends PositionComponent {
  NumberStamp(Vector2 pos, this.combo, this.tier) : super(position: pos);

  final int combo;
  final ComboTier tier;
  static const _duration = 0.85;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    position.y -= 22 * dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final pop = t < 0.18 ? t / 0.18 : 1.0;
    final opacity = (1 - t * t) * pop;
    final scale = (0.6 + pop * 0.6) + (1 - opacity) * 0.2;
    final color = _tierAccent(tier);

    final tp = TextPainter(
      text: TextSpan(
        text: 'x$combo',
        style: TextStyle(
          color: color.withValues(alpha: opacity),
          fontSize: 26 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.drawCircle(
      Offset.zero,
      tp.width * 0.7,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}

// ─── 20. StarBurst ─────────────────────────────────────────────────────────

class StarBurst extends PositionComponent {
  StarBurst(Vector2 pos, this.tier) : super(position: pos);

  final ComboTier tier;
  static const _duration = 0.45;
  double _age = 0;
  late final double _phase = _rng.nextDouble() * pi;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final opacity = (1 - t) * 0.85;
    final reach = 26 + t * 60;
    final color = _tierAccent(tier);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (var i = 0; i < 6; i++) {
      final a = _phase + i * (pi / 3);
      final c = cos(a);
      final s = sin(a);
      canvas.drawLine(
        Offset(c * 4, s * 4),
        Offset(c * reach, s * reach),
        paint,
      );
    }
  }
}

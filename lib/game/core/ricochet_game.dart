import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart' hide Block;
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'constants.dart';
import 'game_state.dart';
import 'level_generator.dart';
import '../entities/ball.dart';
import '../entities/block.dart';
import '../entities/orbit_core.dart';
import '../physics/physics_engine.dart';
import '../rendering/background.dart';
import '../ui/aim_line.dart';
import '../ui/combo_display.dart';

class RicochetGame extends FlameGame {
  late final Ball ball;
  late final OrbitCore orbitCore;
  late final AimLine aimLine;
  late final ComboDisplay comboDisplay;
  final GameState state = GameState();

  final List<Block> _blocks = [];
  final LevelGenerator _levelGen = LevelGenerator();
  final Random _rng = Random();

  Vector2 _ballSpawn = Vector2.zero();
  Vector2? _aimDir;
  double _shakeIntensity = 0;

  Rect get field => PhysicsEngine.gameField(size);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    _ballSpawn = Vector2(size.x / 2, size.y - 60);

    // Render order via priority (low = behind)
    world.add(Background()..priority = 0);

    orbitCore = OrbitCore(position: Vector2(size.x / 2, size.y * 0.4))
      ..priority = 15;
    world.add(orbitCore);

    aimLine = AimLine()..priority = 20;
    world.add(aimLine);

    ball = Ball(position: _ballSpawn.clone())..priority = 25;
    world.add(ball);

    comboDisplay = ComboDisplay()..priority = 30;
    world.add(comboDisplay);

    world.add(_InputOverlay(this)..priority = 100);

    _generateLevel();
  }

  // ---------------------------------------------------------------------------
  // Level management
  // ---------------------------------------------------------------------------

  void _generateLevel() {
    for (final b in _blocks) {
      b.removeFromParent();
    }
    _blocks.clear();

    final newBlocks = _levelGen.generate(
      field: field,
      level: state.level,
      orbitCorePos: orbitCore.position,
      orbitRadius: GameConst.orbitInfluenceRadius,
    );

    for (final b in newBlocks) {
      b.priority = 10;
      _blocks.add(b);
      world.add(b);
    }
    state.blocksRemaining = _blocks.length;
  }

  // ---------------------------------------------------------------------------
  // Game loop
  // ---------------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);

    switch (state.phase) {
      case GamePhase.shooting:
        _updatePhysics(dt);
      case GamePhase.resetting:
        state.resetTimer -= dt;
        if (state.resetTimer <= 0) {
          state.phase = GamePhase.aiming;
          ball.position.setFrom(_ballSpawn);
        }
      case GamePhase.aiming:
        break;
    }

    _updateShake();
  }

  void _updatePhysics(double dt) {
    if (!ball.isActive) return;

    ball.isInOrbit = false;

    // Orbit influence
    orbitCore.applyInfluence(ball, dt);

    // Drag
    ball.velocity.scale(GameConst.ballDrag);

    // Move
    ball.position.add(ball.velocity.scaled(dt));
    ball.addTrailPoint();
    ball.lifetime += dt;

    // Collisions
    PhysicsEngine.handleWallCollisions(ball, field);
    PhysicsEngine.handleCoreCollision(
      ball,
      orbitCore.position,
      GameConst.orbitCoreRadius,
    );

    for (final block in _blocks.toList()) {
      if (PhysicsEngine.checkBallBlock(ball, block)) {
        PhysicsEngine.resolveBallBlock(ball, block);
        block.onHit();
        _onBlockHit();
        if (block.isDestroyed) {
          _onBlockDestroyed();
          block.removeFromParent();
          _blocks.remove(block);
        }
      }
    }

    // Ball exhausted
    if (ball.velocity.length < GameConst.ballMinSpeed ||
        ball.lifetime > GameConst.maxBallLifetime) {
      _onBallStopped();
      return;
    }

    // Level complete
    if (_blocks.isEmpty) {
      state.nextLevel();
      ball.deactivate();
      state.phase = GamePhase.resetting;
      state.resetTimer = 1.0;
      _generateLevel();
    }
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  void _onBlockHit() {
    state.incrementCombo();
    state.addScore(10);
    _shakeIntensity = 2.0 + state.combo * 0.5;

    if (ball.isInOrbit && state.combo >= 3) {
      comboDisplay.show('PERFECT ORBIT');
    } else if (state.combo >= 2) {
      comboDisplay.show('COMBO x${state.combo}');
    }
  }

  void _onBlockDestroyed() {
    state.blocksRemaining--;
    state.addScore(50);
    _shakeIntensity = 5.0;
  }

  void _onBallStopped() {
    ball.deactivate();
    ball.position.setFrom(_ballSpawn);
    state.phase = GamePhase.resetting;
    state.resetTimer = 0.4;
    state.resetCombo();
  }

  // ---------------------------------------------------------------------------
  // Screen shake
  // ---------------------------------------------------------------------------

  void _updateShake() {
    if (_shakeIntensity > 0.3) {
      _shakeIntensity *= 0.88;
      camera.viewfinder.position = Vector2(
        (_rng.nextDouble() - 0.5) * _shakeIntensity * 2,
        (_rng.nextDouble() - 0.5) * _shakeIntensity * 2,
      );
    } else {
      _shakeIntensity = 0;
      camera.viewfinder.position = Vector2.zero();
    }
  }

  // ---------------------------------------------------------------------------
  // Input (called by _InputOverlay)
  // ---------------------------------------------------------------------------

  void onAimUpdate(Vector2 touchPos) {
    if (state.phase != GamePhase.aiming) return;

    final dir = touchPos - ball.position;
    if (dir.length < 15) return;

    _aimDir = dir.normalized();
    aimLine.calculate(
      ball.position,
      _aimDir! * GameConst.ballSpeed,
      orbitCore.position,
    );
  }

  void onAimEnd() {
    if (state.phase != GamePhase.aiming || _aimDir == null) return;

    ball.launch(_aimDir!);
    state.phase = GamePhase.shooting;
    state.resetCombo();
    aimLine.clear();
    _aimDir = null;
  }
}

// -----------------------------------------------------------------------------
// Full-screen touch overlay for drag input
// -----------------------------------------------------------------------------

class _InputOverlay extends PositionComponent with DragCallbacks {
  final RicochetGame gameRef;

  _InputOverlay(this.gameRef);

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    gameRef.onAimUpdate(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    gameRef.onAimUpdate(event.canvasEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    gameRef.onAimEnd();
  }
}

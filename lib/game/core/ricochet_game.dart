import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart' hide Block;
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../../ads/unity_ads_service.dart';
import '../audio/game_audio.dart';
import 'constants.dart';
import 'game_state.dart';
import 'level_generator.dart';
import '../effects/block_particles.dart';
import '../effects/combo_effects.dart';
import '../effects/game_haptics.dart';
import '../effects/level_flash.dart';
import '../entities/ball.dart';
import '../entities/block.dart';
import '../entities/orbit_core.dart';
import '../entities/power_up.dart';
import '../physics/physics_engine.dart';
import '../rendering/background.dart';
import '../save/game_progress.dart';
import '../ui/aim_line.dart';
import '../ui/combo_display.dart';
import 'power_up_type.dart';

class RicochetGame extends FlameGame {
  late final Ball ball;
  late OrbitCore orbitCore;
  late final AimLine aimLine;
  late final ComboDisplay comboDisplay;
  final GameState state = GameState();

  final List<Block> _blocks = [];
  final List<OrbitCore> _orbitCores = [];
  final List<Ball> _balls = [];
  final List<PowerUp> _powerUps = [];
  final LevelGenerator _levelGen = LevelGenerator();
  final Random _rng = Random();

  Vector2 _ballSpawn = Vector2.zero();
  Vector2? _aimDir;
  double _shakeIntensity = 0;
  double _slowMoTimer = 0;
  double _freezeTimer = 0;
  double _heavyTimer = 0;
  int _blocksDestroyedThisShot = 0;
  int _piercingHitsRemaining = 0;
  int _levelsSinceInterstitial = 0;
  PowerUpType? _activePowerUp;
  bool _interstitialInProgress = false;
  bool _wasOrbitingLastFrame = false;

  Rect get field => PhysicsEngine.gameField(size);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    final playField = field;
    _ballSpawn = Vector2(size.x / 2, playField.bottom - 36);

    // Render order via priority (low = behind)
    world.add(Background()..priority = 0);

    aimLine = AimLine()..priority = 20;
    world.add(aimLine);

    ball = Ball(position: _ballSpawn.clone())..priority = 25;
    _balls.add(ball);
    world.add(ball);

    comboDisplay = ComboDisplay()..priority = 30;
    world.add(comboDisplay);

    world.add(_InputOverlay(this)..priority = 100);

    // Wire the combo dispatcher's hitstop bridge to our own freeze timer.
    ComboFx.freezeCallback = triggerComboFreeze;

    _generateLevel();

    // Start tutorial on first launch (after level gen so hints don't interfere)
    if (!GameProgress.instance.tutorialDone) {
      state.startTutorial();
    }
  }

  // ---------------------------------------------------------------------------
  // Level management
  // ---------------------------------------------------------------------------

  void _generateLevel() {
    for (final b in _blocks) {
      b.removeFromParent();
    }
    _blocks.clear();
    _clearPowerUps();

    final progress = GameProgress.instance;
    final effectiveLevel = progress.effectiveLevel(state.level);
    _generateOrbitCores(effectiveLevel);

    final newBlocks = _levelGen.generate(
      field: field,
      level: effectiveLevel,
      orbitCorePositions: _orbitCores.map((core) => core.position).toList(),
      orbitRadius: GameConst.orbitInfluenceRadius,
      seed: progress.seedForLevel(state.level),
    );

    for (final b in newBlocks) {
      b.priority = 10;
      _blocks.add(b);
      world.add(b);
    }
    state.blocksRemaining = _blocks.where((b) => b.isDestructible).length;
    _showLevelHint(newBlocks);
  }

  void _generateOrbitCores(int effectiveLevel) {
    for (final core in _orbitCores) {
      core.removeFromParent();
    }
    _orbitCores.clear();

    final playField = field;
    final baseCore = OrbitCore(
      position: Vector2(
        size.x / 2,
        playField.top + playField.height * 0.42,
      ),
    )..priority = 15;

    orbitCore = baseCore;
    _addOrbitCore(baseCore);

    if (effectiveLevel >= 5) {
      final moving = effectiveLevel >= 9;
      final x = effectiveLevel.isEven ? size.x * 0.32 : size.x * 0.68;
      _addOrbitCore(
        OrbitCore(
          position: Vector2(x, playField.top + playField.height * 0.62),
          moveMinX: moving ? playField.left + 58 : null,
          moveMaxX: moving ? playField.right - 58 : null,
        )..priority = 15,
      );
    }

    if (effectiveLevel >= 7) {
      final moving = effectiveLevel >= 11;
      _addOrbitCore(
        OrbitCore(
          position: Vector2(size.x * 0.5, playField.top + playField.height * 0.24),
          kind: OrbitCoreKind.repulsor,
          moveMinX: moving ? playField.left + 72 : null,
          moveMaxX: moving ? playField.right - 72 : null,
          moveSpeed: GameConst.movingCoreSpeed * 0.82,
        )..priority = 15,
      );
    }
  }

  void _addOrbitCore(OrbitCore core) {
    _orbitCores.add(core);
    world.add(core);
  }

  void restartLevel() {
    state.clearNoProgressOverlay();
    state.phase = GamePhase.aiming;
    state.resetTimer = 0;
    state.resetCombo();
    _blocksDestroyedThisShot = 0;
    _slowMoTimer = 0;
    _wasOrbitingLastFrame = false;
    _aimDir = null;
    _clearActivePowerUp();
    _resetBallRoster();
    aimLine.clear();
    ball.deactivate();
    ball.position.setFrom(_ballSpawn);
    _generateLevel();
    resumeEngine();
  }

  void restartRun() {
    state.resetRun();
    _blocksDestroyedThisShot = 0;
    _levelsSinceInterstitial = 0;
    _slowMoTimer = 0;
    _wasOrbitingLastFrame = false;
    _aimDir = null;
    _clearActivePowerUp();
    _resetBallRoster();
    aimLine.clear();
    ball.deactivate();
    ball.position.setFrom(_ballSpawn);
    _generateLevel();
    resumeEngine();
  }

  void _showLevelHint(List<Block> blocks) {
    final types = blocks.map((block) => block.type).toSet();

    if (_orbitCores.any((core) => core.isMoving)) {
      state.showHint('Moving cores drift slowly. Aim where the field will be.');
    } else if (_orbitCores.any((core) => core.isRepulsor)) {
      state.showHint('Red repulsor cores push the ball away. Use them to redirect.');
    } else if (_orbitCores.length > 1) {
      state.showHint('Multiple cores overlap. Thread the shot through both fields.');
    } else if (types.contains(BlockType.indestructible)) {
      state.showHint('Indestructible blocks cannot break. Bank around them.');
    } else if (types.contains(BlockType.moving)) {
      state.showHint('Moving blocks drift on rails. Lead your shot.');
    } else if (types.contains(BlockType.reinforced)) {
      state.showHint('Reinforced blocks only crack at high speed.');
    } else if (types.contains(BlockType.explosive)) {
      state.showHint('Explosive blocks clear nearby blocks on destroy.');
    } else if (state.level == 1) {
      state.showHint('Drag to aim. Release to launch through the orbit core.');
    } else {
      state.clearHint();
    }
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

  /// Called by the combo dispatcher on tier breaks. Pauses the physics
  /// sim for [duration] seconds — the visual hitstop that makes big
  /// combos feel weighty.
  void triggerComboFreeze(double duration) {
    _freezeTimer = max(_freezeTimer, duration);
  }

  void _updatePhysics(double dt) {
    final activeBalls = _balls.where((activeBall) => activeBall.isActive).toList();
    if (activeBalls.isEmpty) return;

    final frozen = _freezeTimer > 0;
    _freezeTimer = max(0, _freezeTimer - dt);
    final simDt = frozen ? 0.0 : (_slowMoTimer > 0 ? dt * 0.55 : dt);
    _slowMoTimer = max(0, _slowMoTimer - dt);
    _updatePowerUpTimers(dt);

    var anyInOrbit = false;

    for (final activeBall in activeBalls) {
      if (!activeBall.isActive) continue;

      activeBall.isInOrbit = false;

      for (final core in _orbitCores) {
        core.applyInfluence(activeBall, simDt);
      }
      anyInOrbit = anyInOrbit || activeBall.isInOrbit;

      activeBall.velocity.scale(GameConst.ballDrag);
      activeBall.position.add(activeBall.velocity.scaled(simDt));
      activeBall.addTrailPoint();
      activeBall.lifetime += simDt;

      if (PhysicsEngine.handleWallCollisions(
        activeBall,
        field,
        applyDamping: _activePowerUp != PowerUpType.heavyBall,
      )) {
        unawaited(GameProgress.instance.recordRicochet());
        unawaited(GameAudio.instance.playSfx(GameSfx.wallBounce));
        _tryTriggerMultiBall(activeBall);
      }

      for (final core in _orbitCores) {
        PhysicsEngine.handleCoreCollision(
          activeBall,
          core.position,
          GameConst.orbitCoreRadius,
        );
      }

      _collectPowerUps(activeBall);
      _handleBlockCollisions(activeBall);

      if (!_blocks.any((block) => block.isDestructible)) {
        _completeLevel();
        return;
      }

      if (activeBall.velocity.length < GameConst.ballMinSpeed ||
          activeBall.lifetime > GameConst.maxBallLifetime) {
        _onBallStopped(activeBall);
      }
    }

    if (!_wasOrbitingLastFrame && anyInOrbit) {
      _slowMoTimer = 0.18;
      _shakeIntensity = max(_shakeIntensity, 1.5);
      unawaited(GameAudio.instance.playSfx(GameSfx.orbitEnter));
      unawaited(GameProgress.instance.recordOrbitEnter());

      // Tutorial: Step 2 — ball entered orbit
      if (state.tutorialNotifier.value == TutorialStep.orbit) {
        state.advanceTutorial(); // -> combo
      }
    }
    _wasOrbitingLastFrame = anyInOrbit;
  }

  void _handleBlockCollisions(Ball activeBall) {
    for (final block in _blocks.toList()) {
      if (!_blocks.contains(block)) continue;
      if (!PhysicsEngine.checkBallBlock(activeBall, block)) continue;

      final isPiercing = _activePowerUp == PowerUpType.piercingBall &&
          _piercingHitsRemaining > 0 &&
          block.isDestructible;
      final impactSpeed = isPiercing
          ? max(activeBall.velocity.length, GameConst.reinforcedDamageSpeed + 1)
          : activeBall.velocity.length;

      if (!isPiercing) {
        PhysicsEngine.resolveBallBlock(activeBall, block);
        unawaited(GameProgress.instance.recordRicochet());
      }

      final damaged = block.onHit(impactSpeed);
      if (damaged) {
        _onBlockHit(activeBall);
        if (isPiercing) {
          _consumePiercingHit(activeBall);
        } else {
          _tryTriggerMultiBall(activeBall);
        }
        if (block.isDestroyed) {
          _destroyBlock(block);
        }
      } else {
        _onBlockDeflected();
        _tryTriggerMultiBall(activeBall);
      }
    }
  }

  void _completeLevel() {
    state.nextLevel();
    unawaited(GameProgress.instance.recordLevelCleared());
    _deactivateAllBalls();
    _clearActivePowerUp();
    state.phase = GamePhase.resetting;
    state.resetTimer = 1.0;
    world.add(LevelFlash(color: GameColors.orbitGlow)..priority = 90);
    GameHaptics.levelComplete();
    unawaited(GameAudio.instance.playSfx(GameSfx.levelComplete));
    _generateLevel();
    _levelsSinceInterstitial++;
    if (_levelsSinceInterstitial >= 3) {
      _levelsSinceInterstitial = 0;
      unawaited(_showLevelBreakAd());
    }
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  void _onBlockHit(Ball activeBall) {
    final previousCombo = state.combo;
    state.incrementCombo();
    final scoreDelta = 10 * (state.combo < 1 ? 1 : state.combo);
    state.addScore(10);
    unawaited(GameProgress.instance.recordScore(state.score));
    unawaited(GameProgress.instance.recordCombo(state.combo));
    final newTier = comboTierFor(state.combo);
    final tierBroke = newTier.index > comboTierFor(previousCombo).index;
    _shakeIntensity = max(_shakeIntensity, 2.0 + state.combo * 0.5);
    if (tierBroke && newTier.index >= ComboTier.streak.index) {
      _shakeIntensity = max(_shakeIntensity, 7.0 + newTier.index * 1.5);
      _slowMoTimer = max(_slowMoTimer, 0.14 + newTier.index * 0.04);
    }
    GameHaptics.blockHit();
    unawaited(GameAudio.instance.playSfx(GameSfx.blockHit));

    ComboFx.onBlockHit(
      game: this,
      impactPosition: activeBall.position.clone(),
      ballPosition: activeBall.position.clone(),
      combo: state.combo,
      previousCombo: previousCombo,
      scoreDelta: scoreDelta,
      perfectOrbit: activeBall.isInOrbit && state.combo >= 3,
    );

    // Tutorial: Step 3 — player got a combo (2+ hits in one shot)
    if (state.tutorialNotifier.value == TutorialStep.combo && state.combo >= 2) {
      state.advanceTutorial(); // -> done
      unawaited(_finishTutorial());
    }

    if (activeBall.isInOrbit && state.combo >= 3) {
      comboDisplay.show('PERFECT ORBIT');
      GameHaptics.combo();
      unawaited(GameAudio.instance.playSfx(GameSfx.combo));
    } else if (state.combo >= 2) {
      comboDisplay.show('COMBO x${state.combo}');
      GameHaptics.combo();
      unawaited(GameAudio.instance.playSfx(GameSfx.combo));
    }
  }

  void _onBlockDestroyed(Block block) {
    state.blocksRemaining--;
    _blocksDestroyedThisShot++;
    state.addScore(50);
    unawaited(GameProgress.instance.recordScore(state.score));
    unawaited(
      GameProgress.instance.recordBlockDestroyed(
        coinReward: _coinReward(block),
      ),
    );
    _shakeIntensity = 5.0;
    world.add(
      BlockParticles(position: block.position.clone(), color: block.baseColor)
        ..priority = 18,
    );
    GameHaptics.blockDestroyed();
    unawaited(GameAudio.instance.playSfx(GameSfx.blockDestroy));
    _maybeDropPowerUp(block);
  }

  void _destroyBlock(Block block, {bool fromExplosion = false}) {
    if (!_blocks.contains(block) || !block.isDestructible) return;

    final explosionOrigin = block.position.clone();
    _onBlockDestroyed(block);
    block.removeFromParent();
    _blocks.remove(block);

    if (block.type == BlockType.explosive && !fromExplosion) {
      _triggerExplosion(explosionOrigin);
    }
  }

  void _triggerExplosion(Vector2 origin) {
    _shakeIntensity = max(_shakeIntensity, 9.0);

    for (final block in _blocks.toList()) {
      if (!block.isDestructible) continue;
      if (block.position.distanceTo(origin) > GameConst.explosionRadius) {
        continue;
      }

      block.hp = 0;
      _destroyBlock(block, fromExplosion: true);
    }
  }

  void _onBlockDeflected() {
    _shakeIntensity = max(_shakeIntensity, 1.8);
    GameHaptics.blockHit();
    unawaited(GameAudio.instance.playSfx(GameSfx.blockHit));
  }

  int _coinReward(Block block) {
    final typeBonus = switch (block.type) {
      BlockType.standard => 0,
      BlockType.explosive => 3,
      BlockType.reinforced => 4,
      BlockType.moving => 5,
      BlockType.indestructible => 0,
    };
    return 2 + block.maxHp * 2 + typeBonus;
  }

  void _onBallStopped(Ball stoppedBall) {
    stoppedBall.deactivate();
    if (stoppedBall != ball) {
      stoppedBall.removeFromParent();
      _balls.remove(stoppedBall);
    }

    if (_balls.any((activeBall) => activeBall.isActive)) return;

    ball.position.setFrom(_ballSpawn);
    state.resetCombo();
    _slowMoTimer = 0;
    _wasOrbitingLastFrame = false;
    _clearActivePowerUp();
    if (_blocksDestroyedThisShot == 0) {
      state.phase = GamePhase.aiming;
      state.showNoProgressOverlay();
      return;
    }

    state.phase = GamePhase.resetting;
    state.resetTimer = 0.4;
  }

  void _maybeDropPowerUp(Block block) {
    final effectiveLevel = GameProgress.instance.effectiveLevel(state.level);
    if (effectiveLevel < 3) return;
    if (_activePowerUp != null || _powerUps.isNotEmpty) return;
    if (_rng.nextDouble() > 0.18) return;

    final availableTypes = <PowerUpType>[
      PowerUpType.multiBall,
      if (effectiveLevel >= 4) PowerUpType.heavyBall,
      if (effectiveLevel >= 5) PowerUpType.piercingBall,
    ];
    final type = availableTypes[_rng.nextInt(availableTypes.length)];
    final powerUp = PowerUp(position: block.position.clone(), type: type)
      ..priority = 17;
    _powerUps.add(powerUp);
    world.add(powerUp);
  }

  void _collectPowerUps(Ball activeBall) {
    if (_activePowerUp != null) return;

    for (final powerUp in _powerUps.toList()) {
      final pickupDistance = powerUp.collisionRadius + activeBall.collisionRadius;
      if (activeBall.position.distanceTo(powerUp.position) > pickupDistance) {
        continue;
      }

      _powerUps.remove(powerUp);
      powerUp.removeFromParent();
      _activatePowerUp(powerUp.type);
      return;
    }
  }

  void _activatePowerUp(PowerUpType type) {
    _activePowerUp = type;
    unawaited(GameAudio.instance.playSfx(GameSfx.powerUp));
    GameHaptics.combo();

    switch (type) {
      case PowerUpType.multiBall:
        state.showPowerUp(type, 'NEXT BOUNCE');
        comboDisplay.show('MULTI-BALL ARMED');
      case PowerUpType.heavyBall:
        _heavyTimer = GameConst.heavyBallDuration;
        _setAllBallsHeavy(true);
        state.showPowerUp(type, '${_heavyTimer.toStringAsFixed(1)}S');
        comboDisplay.show('HEAVY BALL');
      case PowerUpType.piercingBall:
        _piercingHitsRemaining = GameConst.piercingHits;
        state.showPowerUp(type, '$_piercingHitsRemaining HITS');
        comboDisplay.show('PIERCING BALL');
    }
  }

  void _updatePowerUpTimers(double dt) {
    if (_activePowerUp != PowerUpType.heavyBall) return;

    _heavyTimer = max(0, _heavyTimer - dt);
    state.showPowerUp(
      PowerUpType.heavyBall,
      '${_heavyTimer.toStringAsFixed(1)}S',
    );

    if (_heavyTimer <= 0) {
      _clearActivePowerUp();
    }
  }

  void _consumePiercingHit(Ball activeBall) {
    _piercingHitsRemaining--;
    if (activeBall.velocity.length2 > 0.001) {
      activeBall.position.add(
        activeBall.velocity.normalized().scaled(activeBall.collisionRadius * 1.4),
      );
    }

    if (_piercingHitsRemaining <= 0) {
      _clearActivePowerUp();
      return;
    }

    state.showPowerUp(
      PowerUpType.piercingBall,
      '$_piercingHitsRemaining HITS',
    );
  }

  void _tryTriggerMultiBall(Ball source) {
    if (_activePowerUp != PowerUpType.multiBall) return;
    if (!source.isActive || source.velocity.length2 < 0.001) return;
    if (_balls.length >= 3) {
      _clearActivePowerUp();
      return;
    }

    final speed = max(source.velocity.length, GameConst.ballSpeed * 0.72);
    final primaryVelocity = _rotated(source.velocity, -0.22)
      ..normalize()
      ..scale(speed);
    final splitVelocity = _rotated(source.velocity, 0.28)
      ..normalize()
      ..scale(speed * 0.96);

    source.velocity.setFrom(primaryVelocity);
    _spawnExtraBall(source.position, splitVelocity, source.lifetime);
    comboDisplay.show('MULTI-BALL');
    _shakeIntensity = max(_shakeIntensity, 5.5);
    _clearActivePowerUp();
  }

  void _spawnExtraBall(Vector2 position, Vector2 velocity, double lifetime) {
    final extraBall = Ball(position: position.clone())
      ..priority = 25
      ..isActive = true
      ..velocity = velocity.clone()
      ..lifetime = lifetime;
    extraBall.setHeavy(_activePowerUp == PowerUpType.heavyBall);
    _balls.add(extraBall);
    world.add(extraBall);
  }

  Vector2 _rotated(Vector2 vector, double radians) {
    final c = cos(radians);
    final s = sin(radians);
    return Vector2(vector.x * c - vector.y * s, vector.x * s + vector.y * c);
  }

  void _clearPowerUps() {
    for (final powerUp in _powerUps) {
      powerUp.removeFromParent();
    }
    _powerUps.clear();
  }

  void _clearActivePowerUp() {
    if (_activePowerUp == PowerUpType.heavyBall) {
      _setAllBallsHeavy(false);
    }

    _activePowerUp = null;
    _heavyTimer = 0;
    _piercingHitsRemaining = 0;
    state.clearPowerUp();
  }

  void _setAllBallsHeavy(bool enabled) {
    for (final activeBall in _balls) {
      activeBall.setHeavy(enabled);
    }
  }

  void _resetBallRoster() {
    for (final activeBall in _balls.toList()) {
      if (activeBall == ball) continue;
      activeBall.removeFromParent();
      _balls.remove(activeBall);
    }
    if (!_balls.contains(ball)) {
      _balls.add(ball);
    }
    ball.setHeavy(false);
  }

  void _deactivateAllBalls() {
    for (final activeBall in _balls.toList()) {
      activeBall.deactivate();
      if (activeBall == ball) continue;
      activeBall.removeFromParent();
      _balls.remove(activeBall);
    }
  }

  Future<void> _showLevelBreakAd() async {
    if (_interstitialInProgress) return;

    _interstitialInProgress = true;
    pauseEngine();

    final wasShown = await UnityAdsService.instance.showInterstitial(
      onFinished: () {
        _interstitialInProgress = false;
        resumeEngine();
      },
    );

    if (!wasShown) {
      _interstitialInProgress = false;
      resumeEngine();
    }
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
    if (state.phase != GamePhase.aiming || state.noProgressOverlayVisible) {
      return;
    }

    final dir = touchPos - ball.position;
    if (dir.length < 15) return;

    _aimDir = dir.normalized();
    aimLine.calculate(
      ball.position,
      _aimDir! * GameConst.ballSpeed,
      _orbitCores,
    );
  }

  void onAimEnd() {
    if (state.phase != GamePhase.aiming || _aimDir == null) return;

    unawaited(GameProgress.instance.recordSingleShotBlocks(_blocksDestroyedThisShot));
    ball.launch(_aimDir!);
    state.phase = GamePhase.shooting;
    state.resetCombo();
    state.clearNoProgressOverlay();
    _blocksDestroyedThisShot = 0;
    _slowMoTimer = 0;
    _wasOrbitingLastFrame = false;
    aimLine.clear();
    _aimDir = null;
    GameHaptics.launch();
    unawaited(GameAudio.instance.playSfx(GameSfx.launch));
    unawaited(GameProgress.instance.recordShotLaunched());

    // Tutorial: Step 1 — player aimed and shot
    if (state.tutorialNotifier.value == TutorialStep.aim) {
      state.advanceTutorial(); // -> orbit
    }
  }

  // ---------------------------------------------------------------------------
  // Tutorial helpers
  // ---------------------------------------------------------------------------

  Future<void> _finishTutorial() async {
    await GameProgress.instance.setTutorialDone();
    state.endTutorial();
  }

  Future<void> skipTutorial() async {
    await GameProgress.instance.setTutorialDone();
    state.endTutorial();
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

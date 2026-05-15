import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../save/game_progress.dart';

enum GameSfx {
  launch('audio/sfx/launch.wav', 0.42),
  wallBounce('audio/sfx/wall_bounce.wav', 0.26),
  blockHit('audio/sfx/block_hit.wav', 0.34),
  blockDestroy('audio/sfx/block_destroy.wav', 0.44),
  orbitEnter('audio/sfx/orbit_enter.wav', 0.38),
  combo('audio/sfx/combo.wav', 0.48),
  levelComplete('audio/sfx/level_complete.wav', 0.52),
  powerUp('audio/sfx/power_up.wav', 0.44);

  final String assetPath;
  final double volume;

  const GameSfx(this.assetPath, this.volume);
}

class GameAudio {
  static final GameAudio instance = GameAudio._();

  final Map<GameSfx, AudioPlayer> _sfxPlayers = {};
  final Map<GameSfx, DateTime> _lastPlayedAt = {};
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'ambient-loop');

  bool _initialized = false;
  bool _musicPlaying = false;

  GameAudio._();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Music is loaded lazily on first play (deferred to _startMusic).
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.18);

    // Preload every SFX so the first hit has no decode hitch.
    await Future.wait([
      for (final sfx in GameSfx.values)
        () async {
          final player = AudioPlayer(playerId: 'sfx-${sfx.name}');
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setPlayerMode(PlayerMode.lowLatency);
          await player.setVolume(sfx.volume);
          try {
            await player.setSource(AssetSource(sfx.assetPath));
          } on Object {
            // Asset missing or platform decoder hiccup — recover gracefully.
          }
          _sfxPlayers[sfx] = player;
        }(),
    ]);

    GameProgress.instance.addListener(syncSettings);
    unawaited(syncSettings());
  }

  Future<void> syncSettings() async {
    if (GameProgress.instance.musicEnabled) {
      await _startMusic();
    } else {
      await _stopMusic();
    }
  }

  Future<void> playSfx(GameSfx sfx) async {
    if (!GameProgress.instance.soundEnabled) return;
    if (!_canPlay(sfx)) return;

    final player = _sfxPlayers[sfx];
    if (player == null) return;

    try {
      // Preloaded source — seek to start and resume. Avoids the per-play
      // decode hitch from re-resolving AssetSource on every trigger.
      await player.seek(Duration.zero);
      await player.resume();
    } on Object {
      // Audio should never interrupt gameplay if a platform decoder hiccups.
    }
  }

  bool _canPlay(GameSfx sfx) {
    final now = DateTime.now();
    final last = _lastPlayedAt[sfx];
    if (last != null && now.difference(last).inMilliseconds < 45) {
      return false;
    }
    _lastPlayedAt[sfx] = now;
    return true;
  }

  Future<void> _startMusic() async {
    if (_musicPlaying) return;

    try {
      _musicPlaying = true;
      await _musicPlayer.play(
        AssetSource('audio/music/ambient_loop.wav'),
        volume: 0.18,
      );
    } on Object {
      _musicPlaying = false;
    }
  }

  Future<void> _stopMusic() async {
    if (!_musicPlaying) return;
    _musicPlaying = false;
    await _musicPlayer.stop();
  }
}

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

enum GameMode { normal, hard, endless, daily }

enum CosmeticCategory { ball, trail, core }

class CosmeticItem {
  final String id;
  final CosmeticCategory category;
  final String title;
  final String subtitle;
  final int price;
  final Color color;

  const CosmeticItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
  });
}

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
  });
}

class GameProgress extends ChangeNotifier {
  static final GameProgress instance = GameProgress._();

  static const _soundKey = 'settings.sound';
  static const _musicKey = 'settings.music';
  static const _hapticsKey = 'settings.haptics';
  static const _modeKey = 'settings.mode';
  static const _highScoreKey = 'stats.highScore';
  static const _levelsClearedKey = 'stats.levelsCleared';
  static const _blocksDestroyedKey = 'stats.blocksDestroyed';
  static const _ricochetsKey = 'stats.ricochets';
  static const _maxComboKey = 'stats.maxCombo';
  static const _coinsKey = 'meta.coins';
  static const _unlockedCosmeticsKey = 'meta.unlockedCosmetics';
  static const _selectedBallKey = 'meta.selectedBall';
  static const _selectedTrailKey = 'meta.selectedTrail';
  static const _selectedCoreKey = 'meta.selectedCore';
  static const _unlockedAchievementsKey = 'meta.unlockedAchievements';

  static const defaultBallSkinId = 'ball.core-blue';
  static const defaultTrailEffectId = 'trail.core-blue';
  static const defaultCoreSkinId = 'core.core-blue';

  static const List<CosmeticItem> cosmetics = [
    CosmeticItem(
      id: defaultBallSkinId,
      category: CosmeticCategory.ball,
      title: 'Core Blue',
      subtitle: 'Default studio identity',
      price: 0,
      color: GameColors.electricBlue,
    ),
    CosmeticItem(
      id: 'ball.ion-green',
      category: CosmeticCategory.ball,
      title: 'Ion Green',
      subtitle: 'Combo-forward glow',
      price: 160,
      color: GameColors.blockHp1,
    ),
    CosmeticItem(
      id: 'ball.solar-warning',
      category: CosmeticCategory.ball,
      title: 'Solar Warning',
      subtitle: 'High-risk heat',
      price: 220,
      color: GameColors.warning,
    ),
    CosmeticItem(
      id: defaultTrailEffectId,
      category: CosmeticCategory.trail,
      title: 'Clean Vector',
      subtitle: 'Smooth premium fade',
      price: 0,
      color: GameColors.neonCyan,
    ),
    CosmeticItem(
      id: 'trail.spark',
      category: CosmeticCategory.trail,
      title: 'Spark Trace',
      subtitle: 'Tiny orbit sparks',
      price: 180,
      color: GameColors.warning,
    ),
    CosmeticItem(
      id: 'trail.comet',
      category: CosmeticCategory.trail,
      title: 'Comet Tail',
      subtitle: 'Longer luminous wake',
      price: 240,
      color: GameColors.danger,
    ),
    CosmeticItem(
      id: defaultCoreSkinId,
      category: CosmeticCategory.core,
      title: 'Blue Singularity',
      subtitle: 'Classic orbit core',
      price: 0,
      color: GameColors.electricBlue,
    ),
    CosmeticItem(
      id: 'core.ion-green',
      category: CosmeticCategory.core,
      title: 'Ion Field',
      subtitle: 'Soft green gravity',
      price: 210,
      color: GameColors.blockHp1,
    ),
    CosmeticItem(
      id: 'core.red-shift',
      category: CosmeticCategory.core,
      title: 'Red Shift',
      subtitle: 'Warmer danger field',
      price: 260,
      color: GameColors.danger,
    ),
  ];

  static const List<AchievementDef> achievements = [
    AchievementDef(
      id: 'clear_10',
      title: 'Clear Level 10',
      description: 'Prove the core loop has legs.',
      rewardCoins: 150,
    ),
    AchievementDef(
      id: 'combo_20',
      title: 'x20 Combo',
      description: 'Chain twenty block hits in one shot.',
      rewardCoins: 220,
    ),
    AchievementDef(
      id: 'ricochet_100',
      title: '100 Ricochets',
      description: 'Survive one hundred recorded bounces.',
      rewardCoins: 120,
    ),
    AchievementDef(
      id: 'breaker_250',
      title: '250 Blocks',
      description: 'Destroy two hundred fifty blocks.',
      rewardCoins: 180,
    ),
  ];

  SharedPreferences? _prefs;

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;
  GameMode selectedMode = GameMode.endless;
  int highScore = 0;
  int levelsCleared = 0;
  int blocksDestroyed = 0;
  int ricochets = 0;
  int maxCombo = 0;
  int coins = 0;
  int dailyBestScore = 0;
  Set<String> unlockedCosmeticIds = {
    defaultBallSkinId,
    defaultTrailEffectId,
    defaultCoreSkinId,
  };
  Set<String> unlockedAchievementIds = {};
  String selectedBallSkinId = defaultBallSkinId;
  String selectedTrailEffectId = defaultTrailEffectId;
  String selectedCoreSkinId = defaultCoreSkinId;

  GameProgress._();

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;

    soundEnabled = prefs.getBool(_soundKey) ?? true;
    musicEnabled = prefs.getBool(_musicKey) ?? true;
    hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
    selectedMode = _modeFromName(prefs.getString(_modeKey));
    highScore = prefs.getInt(_highScoreKey) ?? 0;
    levelsCleared = prefs.getInt(_levelsClearedKey) ?? 0;
    blocksDestroyed = prefs.getInt(_blocksDestroyedKey) ?? 0;
    ricochets = prefs.getInt(_ricochetsKey) ?? 0;
    maxCombo = prefs.getInt(_maxComboKey) ?? 0;
    coins = prefs.getInt(_coinsKey) ?? 0;
    dailyBestScore = prefs.getInt(_dailyScoreKey) ?? 0;
    unlockedCosmeticIds = {
      defaultBallSkinId,
      defaultTrailEffectId,
      defaultCoreSkinId,
      ...prefs.getStringList(_unlockedCosmeticsKey) ?? const [],
    };
    unlockedAchievementIds = {
      ...prefs.getStringList(_unlockedAchievementsKey) ?? const [],
    };
    selectedBallSkinId =
        _validCosmeticId(
          prefs.getString(_selectedBallKey),
          CosmeticCategory.ball,
        ) ??
        defaultBallSkinId;
    selectedTrailEffectId =
        _validCosmeticId(
          prefs.getString(_selectedTrailKey),
          CosmeticCategory.trail,
        ) ??
        defaultTrailEffectId;
    selectedCoreSkinId =
        _validCosmeticId(
          prefs.getString(_selectedCoreKey),
          CosmeticCategory.core,
        ) ??
        defaultCoreSkinId;

    notifyListeners();
  }

  int get dailySeed {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  int get dailyTargetScore => 3000 + dailySeed % 2500;

  String get _dailyScoreKey => 'daily.bestScore.$dailySeed';

  Color get selectedBallColor => _cosmeticById(selectedBallSkinId).color;

  Color get selectedTrailColor => _cosmeticById(selectedTrailEffectId).color;

  Color get selectedCoreColor => _cosmeticById(selectedCoreSkinId).color;

  bool get hasSparkTrail => selectedTrailEffectId == 'trail.spark';

  bool get hasCometTrail => selectedTrailEffectId == 'trail.comet';

  int effectiveLevel(int level) {
    return switch (selectedMode) {
      GameMode.normal => level > 8 ? 8 : level,
      GameMode.hard => level + 3,
      GameMode.endless => level,
      GameMode.daily => level + 2,
    };
  }

  int? seedForLevel(int level) {
    if (selectedMode != GameMode.daily) return null;
    return dailySeed + level * 9973;
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_soundKey, value);
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_musicKey, value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    hapticsEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_hapticsKey, value);
  }

  Future<void> setMode(GameMode mode) async {
    selectedMode = mode;
    notifyListeners();
    await _prefs?.setString(_modeKey, mode.name);
  }

  Future<void> recordScore(int score) async {
    var changed = false;
    if (score > highScore) {
      highScore = score;
      await _prefs?.setInt(_highScoreKey, highScore);
      changed = true;
    }

    if (selectedMode == GameMode.daily && score > dailyBestScore) {
      dailyBestScore = score;
      await _prefs?.setInt(_dailyScoreKey, dailyBestScore);
      changed = true;
    }

    if (changed) notifyListeners();
  }

  Future<void> recordCombo(int combo) async {
    if (combo <= maxCombo) return;

    maxCombo = combo;
    await _prefs?.setInt(_maxComboKey, maxCombo);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordLevelCleared() async {
    levelsCleared++;
    await _prefs?.setInt(_levelsClearedKey, levelsCleared);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordBlockDestroyed({required int coinReward}) async {
    blocksDestroyed++;
    coins += coinReward;
    await _prefs?.setInt(_blocksDestroyedKey, blocksDestroyed);
    await _prefs?.setInt(_coinsKey, coins);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordRicochet() async {
    ricochets++;
    await _prefs?.setInt(_ricochetsKey, ricochets);
    await _checkAchievements();
    notifyListeners();
  }

  Future<bool> unlockOrEquipCosmetic(String cosmeticId) async {
    final item = _cosmeticById(cosmeticId);

    if (!unlockedCosmeticIds.contains(item.id)) {
      if (coins < item.price) return false;
      coins -= item.price;
      unlockedCosmeticIds.add(item.id);
      await _prefs?.setInt(_coinsKey, coins);
      await _prefs?.setStringList(
        _unlockedCosmeticsKey,
        unlockedCosmeticIds.toList()..sort(),
      );
    }

    switch (item.category) {
      case CosmeticCategory.ball:
        selectedBallSkinId = item.id;
        await _prefs?.setString(_selectedBallKey, item.id);
      case CosmeticCategory.trail:
        selectedTrailEffectId = item.id;
        await _prefs?.setString(_selectedTrailKey, item.id);
      case CosmeticCategory.core:
        selectedCoreSkinId = item.id;
        await _prefs?.setString(_selectedCoreKey, item.id);
    }

    notifyListeners();
    return true;
  }

  bool isCosmeticEquipped(CosmeticItem item) {
    return switch (item.category) {
      CosmeticCategory.ball => selectedBallSkinId == item.id,
      CosmeticCategory.trail => selectedTrailEffectId == item.id,
      CosmeticCategory.core => selectedCoreSkinId == item.id,
    };
  }

  bool isAchievementUnlocked(AchievementDef achievement) {
    return unlockedAchievementIds.contains(achievement.id);
  }

  CosmeticItem _cosmeticById(String id) {
    return cosmetics.firstWhere((item) => item.id == id);
  }

  String? _validCosmeticId(String? id, CosmeticCategory category) {
    if (id == null || !unlockedCosmeticIds.contains(id)) return null;
    final exists = cosmetics.any(
      (item) => item.id == id && item.category == category,
    );
    return exists ? id : null;
  }

  Future<void> _checkAchievements() async {
    final newlyUnlocked = <String>[];

    for (final achievement in achievements) {
      if (unlockedAchievementIds.contains(achievement.id)) continue;
      if (!_achievementConditionMet(achievement.id)) continue;

      unlockedAchievementIds.add(achievement.id);
      newlyUnlocked.add(achievement.id);
      coins += achievement.rewardCoins;
    }

    if (newlyUnlocked.isEmpty) return;

    await _prefs?.setStringList(
      _unlockedAchievementsKey,
      unlockedAchievementIds.toList()..sort(),
    );
    await _prefs?.setInt(_coinsKey, coins);
  }

  bool _achievementConditionMet(String id) {
    return switch (id) {
      'clear_10' => levelsCleared >= 10,
      'combo_20' => maxCombo >= 20,
      'ricochet_100' => ricochets >= 100,
      'breaker_250' => blocksDestroyed >= 250,
      _ => false,
    };
  }

  GameMode _modeFromName(String? name) {
    return GameMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => GameMode.endless,
    );
  }
}

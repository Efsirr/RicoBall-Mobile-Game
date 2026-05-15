import 'package:flutter_test/flutter_test.dart';
import 'package:ricochet_core/game/save/game_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GameProgress> _freshProgress() async {
  SharedPreferences.setMockInitialValues({});
  final progress = GameProgress.instance;
  await progress.load();
  return progress;
}

void main() {
  test('loads the default meta inventory', () async {
    final progress = await _freshProgress();

    expect(progress.coins, 0);
    expect(progress.selectedMode, GameMode.endless);
    expect(progress.selectedBallSkinId, GameProgress.defaultBallSkinId);
    expect(progress.selectedTrailEffectId, GameProgress.defaultTrailEffectId);
    expect(progress.selectedCoreSkinId, GameProgress.defaultCoreSkinId);
    expect(
      progress.unlockedCosmeticIds,
      containsAll([
        GameProgress.defaultBallSkinId,
        GameProgress.defaultTrailEffectId,
        GameProgress.defaultCoreSkinId,
      ]),
    );
  });

  test('awards block coins and achievement rewards', () async {
    final progress = await _freshProgress();

    await progress.recordBlockDestroyed(coinReward: 12);
    await progress.recordCombo(20);

    final comboAchievement = GameProgress.achievements.firstWhere(
      (achievement) => achievement.id == 'combo_20',
    );

    expect(progress.blocksDestroyed, 1);
    expect(progress.maxCombo, 20);
    expect(progress.coins, 12 + comboAchievement.rewardCoins);
    expect(progress.isAchievementUnlocked(comboAchievement), isTrue);
  });

  test('buys, equips, and persists cosmetics', () async {
    final progress = await _freshProgress();

    await progress.recordBlockDestroyed(coinReward: 200);
    final unlocked = await progress.unlockOrEquipCosmetic('ball.ion-green');

    expect(unlocked, isTrue);
    expect(progress.coins, 40);
    expect(progress.unlockedCosmeticIds, contains('ball.ion-green'));
    expect(progress.selectedBallSkinId, 'ball.ion-green');

    await progress.load();

    expect(progress.coins, 40);
    expect(progress.unlockedCosmeticIds, contains('ball.ion-green'));
    expect(progress.selectedBallSkinId, 'ball.ion-green');
  });

  test('applies difficulty modes and daily scoring', () async {
    final progress = await _freshProgress();

    await progress.setMode(GameMode.normal);
    expect(progress.effectiveLevel(12), 8);
    expect(progress.seedForLevel(3), isNull);

    await progress.setMode(GameMode.hard);
    expect(progress.effectiveLevel(12), 15);

    await progress.setMode(GameMode.endless);
    expect(progress.effectiveLevel(12), 12);

    await progress.setMode(GameMode.daily);
    expect(progress.effectiveLevel(12), 14);
    expect(progress.seedForLevel(3), progress.seedForLevel(3));

    await progress.recordScore(5000);
    expect(progress.highScore, 5000);
    expect(progress.dailyBestScore, 5000);

    await progress.setMode(GameMode.normal);
    await progress.recordScore(7000);
    expect(progress.highScore, 7000);
    expect(progress.dailyBestScore, 5000);
  });
}

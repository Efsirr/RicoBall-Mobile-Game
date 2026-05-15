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
  static const _shotsLaunchedKey = 'stats.shotsLaunched';
  static const _orbitEntersKey = 'stats.orbitEnters';
  static const _totalCoinsEarnedKey = 'stats.totalCoinsEarned';
  static const _hardLevelsClearedKey = 'stats.hardLevelsCleared';
  static const _endlessLevelsClearedKey = 'stats.endlessLevelsCleared';
  static const _dailyPlayedKey = 'stats.dailyPlayed';
  static const _dailyBeatenKey = 'stats.dailyBeaten';
  static const _bestSingleShotBlocksKey = 'stats.bestSingleShotBlocks';
  static const _tutorialDoneKey = 'meta.tutorialDone';

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

  // ── 250 Achievements ────────────────────────────────────────────────────────

  static const List<AchievementDef> achievements = [
    // INTRO (10)
    AchievementDef(id: 'first_shot', title: 'First Launch', description: 'A force set in motion.', rewardCoins: 10),
    AchievementDef(id: 'first_level', title: 'Clean Sweep', description: 'One level down. Endless to go.', rewardCoins: 25),
    AchievementDef(id: 'first_orbit', title: 'Gravity Well', description: 'The core pulled you in. Now exploit it.', rewardCoins: 20),
    AchievementDef(id: 'first_combo', title: 'Chain Reaction', description: 'Blocks know their fate.', rewardCoins: 15),
    AchievementDef(id: 'first_pop', title: 'First Casualty', description: 'One block down. Millions to follow.', rewardCoins: 10),
    AchievementDef(id: 'first_coin', title: 'Pocket Change', description: 'The grind begins.', rewardCoins: 5),
    AchievementDef(id: 'first_bounce', title: 'Wall Rider', description: 'Walls are part of the plan.', rewardCoins: 10),
    AchievementDef(id: 'getting_started', title: 'Getting Started', description: 'Clear 3 levels.', rewardCoins: 40),
    AchievementDef(id: 'warming_up', title: 'Warming Up', description: '10 ricochets logged.', rewardCoins: 30),
    AchievementDef(id: 'picking_up_speed', title: 'Picking Up Speed', description: 'x5 combo achieved.', rewardCoins: 50),

    // NORMAL LEVELS (30)
    AchievementDef(id: 'clear_5', title: 'Five Down', description: 'Five levels cleared.', rewardCoins: 60),
    AchievementDef(id: 'clear_10', title: 'Decade', description: 'Ten levels. The loop holds.', rewardCoins: 80),
    AchievementDef(id: 'clear_20', title: 'Momentum', description: 'Twenty levels cleared.', rewardCoins: 110),
    AchievementDef(id: 'clear_30', title: 'On a Roll', description: 'Thirty levels cleared.', rewardCoins: 140),
    AchievementDef(id: 'clear_50', title: 'Halfway to Triple Digits', description: 'Fifty levels cleared.', rewardCoins: 180),
    AchievementDef(id: 'clear_75', title: 'Three-Quarter Century', description: 'Seventy-five levels.', rewardCoins: 240),
    AchievementDef(id: 'clear_100', title: 'Triple Digits', description: 'One hundred levels. Milestone hit.', rewardCoins: 320),
    AchievementDef(id: 'clear_150', title: 'Relentless', description: 'One hundred fifty levels.', rewardCoins: 420),
    AchievementDef(id: 'clear_200', title: 'Double Century', description: 'Two hundred levels cleared.', rewardCoins: 540),
    AchievementDef(id: 'clear_250', title: 'Quarter Thousand', description: 'Two-fifty.', rewardCoins: 660),
    AchievementDef(id: 'clear_300', title: 'Three Hundred', description: '300 cleared.', rewardCoins: 790),
    AchievementDef(id: 'clear_400', title: 'Four Hundred', description: '400 cleared.', rewardCoins: 940),
    AchievementDef(id: 'clear_500', title: 'Five Hundred', description: '500 levels. Commitment confirmed.', rewardCoins: 1100),
    AchievementDef(id: 'clear_750', title: 'Three Quarters of a Thousand', description: '750 cleared.', rewardCoins: 1400),
    AchievementDef(id: 'clear_1000', title: 'One Thousand', description: '1,000 levels. Rare dedication.', rewardCoins: 1800),
    AchievementDef(id: 'clear_1500', title: 'Fifteen Hundred', description: '1,500 levels. Keep going.', rewardCoins: 2500),
    AchievementDef(id: 'clear_2000', title: 'Two Thousand', description: '2,000 levels of orbit mastery.', rewardCoins: 3200),
    AchievementDef(id: 'clear_3000', title: 'Three Thousand', description: '3,000 levels.', rewardCoins: 4500),
    AchievementDef(id: 'clear_4000', title: 'Four Thousand', description: '4,000 levels.', rewardCoins: 6000),
    AchievementDef(id: 'clear_5000', title: 'Five Thousand', description: '5,000 levels. Your orbit is law.', rewardCoins: 8000),
    AchievementDef(id: 'clear_7500', title: 'Seven Five Hundred', description: '7,500 levels.', rewardCoins: 12000),
    AchievementDef(id: 'clear_10000', title: 'Ten Thousand', description: '10,000 levels. You live here.', rewardCoins: 16000),
    AchievementDef(id: 'clear_15000', title: 'Fifteen Thousand', description: '15,000 cleared.', rewardCoins: 24000),
    AchievementDef(id: 'clear_20000', title: 'Twenty Thousand', description: '20,000 levels. Legendary.', rewardCoins: 32000),
    AchievementDef(id: 'clear_30000', title: 'Thirty Thousand', description: '30,000 levels.', rewardCoins: 48000),
    AchievementDef(id: 'clear_50000', title: 'Orbital Deity', description: '50,000 levels. Incomprehensible.', rewardCoins: 80000),
    AchievementDef(id: 'clear_75000', title: 'Seventy-Five Grand', description: '75,000 levels cleared.', rewardCoins: 120000),
    AchievementDef(id: 'clear_100000', title: 'Hundred Thousand', description: '100,000 levels. Nothing more to prove.', rewardCoins: 200000),
    AchievementDef(id: 'clear_150000', title: 'One Fifty Grand', description: '150,000 levels.', rewardCoins: 300000),
    AchievementDef(id: 'clear_200000', title: 'Transcendent', description: '200,000 levels. Are you even human?', rewardCoins: 500000),

    // HARD MODE (15)
    AchievementDef(id: 'hard_1', title: 'Going Hard', description: 'First Hard mode level cleared.', rewardCoins: 60),
    AchievementDef(id: 'hard_5', title: 'Hard Five', description: 'Five Hard mode levels.', rewardCoins: 100),
    AchievementDef(id: 'hard_10', title: 'Hardened', description: 'Ten Hard levels.', rewardCoins: 150),
    AchievementDef(id: 'hard_20', title: 'Hard Twenty', description: 'Twenty Hard levels.', rewardCoins: 220),
    AchievementDef(id: 'hard_30', title: 'Hard Thirty', description: 'Thirty Hard levels.', rewardCoins: 300),
    AchievementDef(id: 'hard_50', title: 'Hard Fifty', description: 'Fifty Hard levels. The strain is showing.', rewardCoins: 400),
    AchievementDef(id: 'hard_75', title: 'Hard Seventy-Five', description: '75 Hard levels.', rewardCoins: 520),
    AchievementDef(id: 'hard_100', title: 'Hard Century', description: '100 Hard levels. Respect.', rewardCoins: 680),
    AchievementDef(id: 'hard_150', title: 'Hard One-Fifty', description: '150 Hard levels cleared.', rewardCoins: 900),
    AchievementDef(id: 'hard_200', title: 'Hard Two Hundred', description: '200 Hard mode levels. Pure grit.', rewardCoins: 1200),
    AchievementDef(id: 'hard_300', title: 'Hard Three Hundred', description: '300 Hard levels.', rewardCoins: 1800),
    AchievementDef(id: 'hard_500', title: 'Hard Five Hundred', description: '500 Hard levels. Pain became mastery.', rewardCoins: 2800),
    AchievementDef(id: 'hard_750', title: 'Hard Seven-Fifty', description: '750 Hard levels.', rewardCoins: 4200),
    AchievementDef(id: 'hard_1000', title: 'Hard Millennium', description: '1,000 Hard mode levels. Untouchable.', rewardCoins: 6500),
    AchievementDef(id: 'hard_2000', title: 'Hard Two Thousand', description: '2,000 Hard levels. Beyond comprehension.', rewardCoins: 12000),

    // ENDLESS MODE (16)
    AchievementDef(id: 'endless_1', title: 'Into the Void', description: 'First Endless level.', rewardCoins: 50),
    AchievementDef(id: 'endless_5', title: 'Endless Five', description: 'Five Endless levels.', rewardCoins: 80),
    AchievementDef(id: 'endless_10', title: 'Endless Ten', description: 'Ten Endless levels.', rewardCoins: 110),
    AchievementDef(id: 'endless_20', title: 'Endless Twenty', description: 'Twenty Endless levels.', rewardCoins: 160),
    AchievementDef(id: 'endless_30', title: 'Endless Thirty', description: 'Thirty.', rewardCoins: 220),
    AchievementDef(id: 'endless_50', title: 'Endless Fifty', description: 'Fifty Endless levels.', rewardCoins: 300),
    AchievementDef(id: 'endless_75', title: 'Endless Seventy-Five', description: '75.', rewardCoins: 400),
    AchievementDef(id: 'endless_100', title: 'Endless Century', description: '100 Endless levels.', rewardCoins: 520),
    AchievementDef(id: 'endless_150', title: 'Endless One-Fifty', description: '150 Endless levels.', rewardCoins: 680),
    AchievementDef(id: 'endless_200', title: 'Endless Two Hundred', description: '200 Endless levels. The void answers.', rewardCoins: 880),
    AchievementDef(id: 'endless_300', title: 'Endless Three Hundred', description: '300 Endless levels.', rewardCoins: 1200),
    AchievementDef(id: 'endless_500', title: 'Endless Five Hundred', description: '500 Endless levels.', rewardCoins: 1800),
    AchievementDef(id: 'endless_750', title: 'Endless Seven-Fifty', description: '750 Endless levels.', rewardCoins: 2800),
    AchievementDef(id: 'endless_1000', title: 'Endless Millennium', description: '1,000 Endless levels. The run never stops.', rewardCoins: 4500),
    AchievementDef(id: 'endless_1500', title: 'Endless Fifteen Hundred', description: '1,500 Endless levels.', rewardCoins: 7000),
    AchievementDef(id: 'endless_2000', title: 'Endless Two Thousand', description: '2,000 Endless levels. This is your home now.', rewardCoins: 11000),

    // DAILY CHALLENGE (12)
    AchievementDef(id: 'daily_play_1', title: 'Day One', description: 'First Daily Challenge played.', rewardCoins: 40),
    AchievementDef(id: 'daily_play_3', title: 'Three Days', description: '3 Daily Challenges played.', rewardCoins: 70),
    AchievementDef(id: 'daily_play_5', title: 'Five Days', description: '5 Daily Challenges.', rewardCoins: 100),
    AchievementDef(id: 'daily_play_7', title: 'Week One', description: '7 Daily Challenges. One full week.', rewardCoins: 150),
    AchievementDef(id: 'daily_play_10', title: 'Ten Days', description: '10 Daily Challenges.', rewardCoins: 200),
    AchievementDef(id: 'daily_play_14', title: 'Two Weeks', description: '14 Daily Challenges.', rewardCoins: 280),
    AchievementDef(id: 'daily_play_20', title: 'Twenty Days', description: '20 Daily Challenges.', rewardCoins: 380),
    AchievementDef(id: 'daily_play_30', title: 'Month Strong', description: '30 Daily Challenges. One solid month.', rewardCoins: 520),
    AchievementDef(id: 'daily_play_50', title: 'Fifty Days', description: '50 Daily Challenges. Unyielding.', rewardCoins: 750),
    AchievementDef(id: 'daily_play_100', title: 'Century of Days', description: '100 Daily Challenges. Unwavering dedication.', rewardCoins: 1400),
    AchievementDef(id: 'daily_beat_1', title: 'Daily Domination', description: 'Beat the Daily target score.', rewardCoins: 200),
    AchievementDef(id: 'daily_beat_10', title: 'Ten-Time Champion', description: 'Beat the Daily target score 10 times.', rewardCoins: 800),

    // BLOCK DESTRUCTION (22)
    AchievementDef(id: 'blocks_10', title: 'Block Buster', description: 'Destroy 10 blocks.', rewardCoins: 20),
    AchievementDef(id: 'blocks_50', title: 'Demolition Starter', description: '50 blocks destroyed.', rewardCoins: 50),
    AchievementDef(id: 'blocks_100', title: 'Breaking Ground', description: '100 blocks.', rewardCoins: 80),
    AchievementDef(id: 'blocks_250', title: 'Quarter Thousand Blocks', description: '250 blocks.', rewardCoins: 130),
    AchievementDef(id: 'blocks_500', title: 'Half Grand', description: '500 blocks.', rewardCoins: 180),
    AchievementDef(id: 'blocks_1k', title: 'One Thousand Blocks', description: '1,000 destroyed.', rewardCoins: 240),
    AchievementDef(id: 'blocks_2500', title: 'Two and a Half K', description: '2,500 blocks.', rewardCoins: 320),
    AchievementDef(id: 'blocks_5k', title: 'Five Thousand Blocks', description: '5,000 blocks.', rewardCoins: 430),
    AchievementDef(id: 'blocks_10k', title: 'Ten Thousand Blocks', description: '10,000 blocks demolished.', rewardCoins: 570),
    AchievementDef(id: 'blocks_25k', title: 'Twenty-Five K', description: '25,000 blocks.', rewardCoins: 760),
    AchievementDef(id: 'blocks_50k', title: 'Fifty Thousand Blocks', description: '50,000 blocks.', rewardCoins: 1000),
    AchievementDef(id: 'blocks_100k', title: 'One Hundred Thousand', description: '100,000 blocks. Industrial scale.', rewardCoins: 1400),
    AchievementDef(id: 'blocks_250k', title: 'Quarter Million', description: '250,000 blocks.', rewardCoins: 2000),
    AchievementDef(id: 'blocks_500k', title: 'Half Million', description: '500,000 blocks.', rewardCoins: 3000),
    AchievementDef(id: 'blocks_1m', title: 'One Million Blocks', description: '1,000,000 blocks. A monument to persistence.', rewardCoins: 5000),
    AchievementDef(id: 'blocks_2m5', title: 'Two and a Half Million', description: '2,500,000 blocks.', rewardCoins: 8000),
    AchievementDef(id: 'blocks_5m', title: 'Five Million', description: '5,000,000 blocks.', rewardCoins: 13000),
    AchievementDef(id: 'blocks_10m', title: 'Ten Million', description: '10,000,000 blocks. The numbers lose meaning.', rewardCoins: 22000),
    AchievementDef(id: 'blocks_25m', title: 'Twenty-Five Million', description: '25,000,000 blocks.', rewardCoins: 40000),
    AchievementDef(id: 'blocks_50m', title: 'Fifty Million', description: '50,000,000 blocks. You are destruction.', rewardCoins: 70000),
    AchievementDef(id: 'blocks_100m', title: 'One Hundred Million', description: '100,000,000 blocks.', rewardCoins: 130000),
    AchievementDef(id: 'blocks_250m', title: 'Quarter Billion', description: '250,000,000 blocks. The field is yours.', rewardCoins: 250000),

    // RICOCHETS (20)
    AchievementDef(id: 'ricochet_25', title: 'Bouncer', description: '25 ricochets.', rewardCoins: 30),
    AchievementDef(id: 'ricochet_100', title: 'Wall Whisperer', description: '100 ricochets.', rewardCoins: 60),
    AchievementDef(id: 'ricochet_250', title: 'Pinball Logic', description: '250 ricochets.', rewardCoins: 100),
    AchievementDef(id: 'ricochet_500', title: 'Five Hundred Bounces', description: '500 ricochets.', rewardCoins: 150),
    AchievementDef(id: 'ricochet_1k', title: 'One Thousand Bounces', description: '1,000 ricochets.', rewardCoins: 210),
    AchievementDef(id: 'ricochet_2500', title: 'Wall Slapper', description: '2,500 ricochets.', rewardCoins: 290),
    AchievementDef(id: 'ricochet_5k', title: 'Five Thousand Ricochets', description: '5,000 ricochets.', rewardCoins: 400),
    AchievementDef(id: 'ricochet_10k', title: 'Ten Thousand Bounces', description: '10,000 ricochets.', rewardCoins: 550),
    AchievementDef(id: 'ricochet_25k', title: 'Twenty-Five K Ricochets', description: '25,000 ricochets.', rewardCoins: 750),
    AchievementDef(id: 'ricochet_50k', title: 'Fifty Thousand Ricochets', description: '50,000 ricochets.', rewardCoins: 1000),
    AchievementDef(id: 'ricochet_100k', title: 'One Hundred K Ricochets', description: '100,000 ricochets.', rewardCoins: 1400),
    AchievementDef(id: 'ricochet_250k', title: 'Quarter Million Bounces', description: '250,000 ricochets.', rewardCoins: 2200),
    AchievementDef(id: 'ricochet_500k', title: 'Half Million Ricochets', description: '500,000 bounces.', rewardCoins: 3500),
    AchievementDef(id: 'ricochet_1m', title: 'One Million Ricochets', description: '1,000,000 ricochets. Physics is your language.', rewardCoins: 6000),
    AchievementDef(id: 'ricochet_2m5', title: 'Two and a Half Million Bounces', description: '2,500,000 ricochets.', rewardCoins: 10000),
    AchievementDef(id: 'ricochet_5m', title: 'Five Million Ricochets', description: '5,000,000 ricochets.', rewardCoins: 17000),
    AchievementDef(id: 'ricochet_10m', title: 'Ten Million Ricochets', description: '10,000,000 ricochets. You are the bounce.', rewardCoins: 30000),
    AchievementDef(id: 'ricochet_25m', title: 'Twenty-Five Million Ricochets', description: '25,000,000 ricochets.', rewardCoins: 55000),
    AchievementDef(id: 'ricochet_50m', title: 'Fifty Million Ricochets', description: '50,000,000. Nothing escapes your trajectory.', rewardCoins: 100000),
    AchievementDef(id: 'ricochet_100m', title: 'One Hundred Million Ricochets', description: '100,000,000. The math is impossible. Yet here we are.', rewardCoins: 200000),

    // COMBOS (18)
    AchievementDef(id: 'combo_3', title: 'First Chain', description: 'x3 combo.', rewardCoins: 20),
    AchievementDef(id: 'combo_5', title: 'Chain Five', description: 'x5 combo.', rewardCoins: 40),
    AchievementDef(id: 'combo_8', title: 'Chain Eight', description: 'x8 combo.', rewardCoins: 65),
    AchievementDef(id: 'combo_10', title: 'Chain Ten', description: 'x10 combo.', rewardCoins: 90),
    AchievementDef(id: 'combo_12', title: 'Chain Twelve', description: 'x12 combo.', rewardCoins: 120),
    AchievementDef(id: 'combo_15', title: 'Chain Fifteen', description: 'x15 combo.', rewardCoins: 160),
    AchievementDef(id: 'combo_20', title: 'Chain Twenty', description: 'x20 combo.', rewardCoins: 210),
    AchievementDef(id: 'combo_25', title: 'Chain Twenty-Five', description: 'x25 combo.', rewardCoins: 280),
    AchievementDef(id: 'combo_30', title: 'Chain Thirty', description: 'x30 combo. Orbit locked in.', rewardCoins: 360),
    AchievementDef(id: 'combo_40', title: 'Chain Forty', description: 'x40 combo.', rewardCoins: 480),
    AchievementDef(id: 'combo_50', title: 'Chain Fifty', description: 'x50 combo. The orbit never ends.', rewardCoins: 640),
    AchievementDef(id: 'combo_75', title: 'Chain Seventy-Five', description: 'x75 combo.', rewardCoins: 900),
    AchievementDef(id: 'combo_100', title: 'Chain One Hundred', description: 'x100 combo. Precision at an atomic level.', rewardCoins: 1300),
    AchievementDef(id: 'combo_150', title: 'Chain One-Fifty', description: 'x150 combo.', rewardCoins: 2000),
    AchievementDef(id: 'combo_200', title: 'Chain Two Hundred', description: 'x200 combo. The field obeys you.', rewardCoins: 3200),
    AchievementDef(id: 'combo_500', title: 'Chain Five Hundred', description: 'x500 combo. A theoretical limit you have shattered.', rewardCoins: 8000),
    AchievementDef(id: 'combo_750', title: 'Chain Seven-Fifty', description: 'x750 combo.', rewardCoins: 16000),
    AchievementDef(id: 'combo_1000', title: 'One Thousand Chain', description: 'x1000 combo. You have broken the game\'s reality.', rewardCoins: 30000),

    // HIGH SCORE (17)
    AchievementDef(id: 'score_100', title: 'First Points', description: '100 score.', rewardCoins: 20),
    AchievementDef(id: 'score_250', title: 'Quick Quarter', description: '250 score.', rewardCoins: 35),
    AchievementDef(id: 'score_500', title: 'Five Hundred', description: '500 score.', rewardCoins: 55),
    AchievementDef(id: 'score_1k', title: 'One Thousand', description: '1,000 score.', rewardCoins: 80),
    AchievementDef(id: 'score_2500', title: 'Twenty-Five Hundred', description: '2,500 score.', rewardCoins: 110),
    AchievementDef(id: 'score_5k', title: 'Five Thousand Score', description: '5,000 score.', rewardCoins: 150),
    AchievementDef(id: 'score_10k', title: 'Ten Thousand Score', description: '10,000 score.', rewardCoins: 200),
    AchievementDef(id: 'score_25k', title: 'Twenty-Five K Score', description: '25,000 score.', rewardCoins: 280),
    AchievementDef(id: 'score_50k', title: 'Fifty Thousand Score', description: '50,000 score.', rewardCoins: 380),
    AchievementDef(id: 'score_100k', title: 'One Hundred K Score', description: '100,000 score. Elite tier.', rewardCoins: 520),
    AchievementDef(id: 'score_250k', title: 'Quarter Million Score', description: '250,000 score.', rewardCoins: 750),
    AchievementDef(id: 'score_500k', title: 'Half Million Score', description: '500,000 score.', rewardCoins: 1100),
    AchievementDef(id: 'score_1m', title: 'One Million Score', description: '1,000,000 score. Absolute mastery.', rewardCoins: 1800),
    AchievementDef(id: 'score_5m', title: 'Five Million Score', description: '5,000,000 score.', rewardCoins: 4000),
    AchievementDef(id: 'score_10m', title: 'Ten Million Score', description: '10,000,000 score. Staggering.', rewardCoins: 8000),
    AchievementDef(id: 'score_25m', title: 'Twenty-Five Million Score', description: '25,000,000 score.', rewardCoins: 18000),
    AchievementDef(id: 'score_50m', title: 'Fifty Million Score', description: '50,000,000 score. Numbers blur at this altitude.', rewardCoins: 40000),

    // COINS EARNED LIFETIME (16)
    AchievementDef(id: 'earned_50', title: 'Pocket Full', description: '50 coins earned.', rewardCoins: 10),
    AchievementDef(id: 'earned_100', title: 'First Hundred', description: '100 coins earned.', rewardCoins: 15),
    AchievementDef(id: 'earned_250', title: 'Two-Fifty', description: '250 coins earned.', rewardCoins: 25),
    AchievementDef(id: 'earned_500', title: 'Five Hundred Coins', description: '500 total earned.', rewardCoins: 40),
    AchievementDef(id: 'earned_1k', title: 'One K Earned', description: '1,000 total coins.', rewardCoins: 60),
    AchievementDef(id: 'earned_2500', title: 'Two and a Half K', description: '2,500 earned.', rewardCoins: 90),
    AchievementDef(id: 'earned_5k', title: 'Five K Earned', description: '5,000 coins earned.', rewardCoins: 130),
    AchievementDef(id: 'earned_10k', title: 'Ten K Earned', description: '10,000 coins earned.', rewardCoins: 190),
    AchievementDef(id: 'earned_25k', title: 'Twenty-Five K Earned', description: '25,000 total.', rewardCoins: 280),
    AchievementDef(id: 'earned_50k', title: 'Fifty K Earned', description: '50,000 coins earned.', rewardCoins: 400),
    AchievementDef(id: 'earned_100k', title: 'One Hundred K Earned', description: '100,000 coins earned.', rewardCoins: 600),
    AchievementDef(id: 'earned_250k', title: 'Quarter Million Coins', description: '250,000 earned.', rewardCoins: 1000),
    AchievementDef(id: 'earned_500k', title: 'Half Million Coins', description: '500,000 earned.', rewardCoins: 1800),
    AchievementDef(id: 'earned_1m', title: 'Coin Millionaire', description: '1,000,000 total coins earned. The shop ran dry.', rewardCoins: 3500),
    AchievementDef(id: 'earned_5m', title: 'Five Million Coins', description: '5,000,000 earned.', rewardCoins: 9000),
    AchievementDef(id: 'earned_10m', title: 'Ten Million Coins', description: '10,000,000 total. Unfathomable grind.', rewardCoins: 20000),

    // SHOTS LAUNCHED (16)
    AchievementDef(id: 'shots_10', title: 'Ready, Fire', description: '10 shots launched.', rewardCoins: 15),
    AchievementDef(id: 'shots_50', title: 'Fifty Shots', description: '50 shots.', rewardCoins: 30),
    AchievementDef(id: 'shots_100', title: 'One Hundred Shots', description: '100 shots launched.', rewardCoins: 50),
    AchievementDef(id: 'shots_250', title: 'Two-Fifty Shots', description: '250 shots.', rewardCoins: 80),
    AchievementDef(id: 'shots_500', title: 'Five Hundred Shots', description: '500 launched.', rewardCoins: 120),
    AchievementDef(id: 'shots_1k', title: 'One Thousand Shots', description: '1,000 shots.', rewardCoins: 170),
    AchievementDef(id: 'shots_2500', title: 'Two and a Half K Shots', description: '2,500 shots.', rewardCoins: 240),
    AchievementDef(id: 'shots_5k', title: 'Five Thousand Shots', description: '5,000 launched.', rewardCoins: 340),
    AchievementDef(id: 'shots_10k', title: 'Ten Thousand Shots', description: '10,000 shots.', rewardCoins: 480),
    AchievementDef(id: 'shots_25k', title: 'Twenty-Five K Shots', description: '25,000 shots.', rewardCoins: 680),
    AchievementDef(id: 'shots_50k', title: 'Fifty K Shots', description: '50,000 launched.', rewardCoins: 960),
    AchievementDef(id: 'shots_100k', title: 'One Hundred K Shots', description: '100,000 shots.', rewardCoins: 1400),
    AchievementDef(id: 'shots_250k', title: 'Quarter Million Shots', description: '250,000 shots.', rewardCoins: 2200),
    AchievementDef(id: 'shots_500k', title: 'Half Million Shots', description: '500,000 shots.', rewardCoins: 3800),
    AchievementDef(id: 'shots_1m', title: 'One Million Shots', description: '1,000,000 shots fired. The drag alone is legendary.', rewardCoins: 7500),
    AchievementDef(id: 'shots_5m', title: 'Five Million Shots', description: '5,000,000 shots. Time is irrelevant.', rewardCoins: 20000),

    // ORBIT ENTERS (16)
    AchievementDef(id: 'orbit_5', title: 'Gravity Curious', description: 'Enter orbit 5 times.', rewardCoins: 15),
    AchievementDef(id: 'orbit_25', title: 'Orbit Apprentice', description: '25 orbit entries.', rewardCoins: 35),
    AchievementDef(id: 'orbit_100', title: 'Orbit Regular', description: '100 orbit entries.', rewardCoins: 70),
    AchievementDef(id: 'orbit_250', title: 'Orbit Enthusiast', description: '250 orbit entries.', rewardCoins: 110),
    AchievementDef(id: 'orbit_500', title: 'Orbit Addict', description: '500 orbit entries.', rewardCoins: 160),
    AchievementDef(id: 'orbit_1k', title: 'Orbit Devotee', description: '1,000 orbit entries.', rewardCoins: 230),
    AchievementDef(id: 'orbit_2500', title: 'Core Seeker', description: '2,500 orbit entries.', rewardCoins: 320),
    AchievementDef(id: 'orbit_5k', title: 'Orbit Native', description: '5,000 orbit entries.', rewardCoins: 450),
    AchievementDef(id: 'orbit_10k', title: 'Orbit Citizen', description: '10,000 orbit entries.', rewardCoins: 640),
    AchievementDef(id: 'orbit_25k', title: 'Orbit Elder', description: '25,000 orbit entries.', rewardCoins: 900),
    AchievementDef(id: 'orbit_50k', title: 'Orbit Sovereign', description: '50,000 orbit entries.', rewardCoins: 1300),
    AchievementDef(id: 'orbit_100k', title: 'Orbit Master', description: '100,000 entries. Gravity is your home.', rewardCoins: 2000),
    AchievementDef(id: 'orbit_250k', title: 'Orbit Transcendent', description: '250,000 orbit entries.', rewardCoins: 3500),
    AchievementDef(id: 'orbit_500k', title: 'Orbit God', description: '500,000 entries. The core bends to your will.', rewardCoins: 6500),
    AchievementDef(id: 'orbit_1m', title: 'One Million Orbits', description: '1,000,000 orbit entries. Physics weeps.', rewardCoins: 13000),
    AchievementDef(id: 'orbit_5m', title: 'Five Million Orbits', description: '5,000,000 entries. You ARE the gravity.', rewardCoins: 35000),

    // SINGLE SHOT BEST (12)
    AchievementDef(id: 'shot_5_blocks', title: 'Five in One', description: 'Destroy 5 blocks in a single shot.', rewardCoins: 80),
    AchievementDef(id: 'shot_8_blocks', title: 'Eight in One', description: '8 blocks, one shot.', rewardCoins: 130),
    AchievementDef(id: 'shot_10_blocks', title: 'Perfect Ten', description: '10 blocks in one shot.', rewardCoins: 190),
    AchievementDef(id: 'shot_12_blocks', title: 'Dozen Destroyer', description: '12 blocks in one shot.', rewardCoins: 260),
    AchievementDef(id: 'shot_15_blocks', title: 'Fifteen in Flight', description: '15 blocks in one shot.', rewardCoins: 360),
    AchievementDef(id: 'shot_20_blocks', title: 'Twenty in One', description: '20 blocks, one shot. Pure orbit geometry.', rewardCoins: 500),
    AchievementDef(id: 'shot_25_blocks', title: 'Twenty-Five Shot', description: '25 blocks in a single shot.', rewardCoins: 700),
    AchievementDef(id: 'shot_30_blocks', title: 'Thirty in One', description: '30 blocks. One shot. How?', rewardCoins: 1000),
    AchievementDef(id: 'shot_40_blocks', title: 'Forty in One', description: '40 blocks with one shot. Orbit used correctly.', rewardCoins: 1600),
    AchievementDef(id: 'shot_50_blocks', title: 'Fifty in One', description: '50 blocks in a single shot. Frame-perfect orbit.', rewardCoins: 2800),
    AchievementDef(id: 'shot_60_blocks', title: 'Sixty in One', description: '60 blocks, one shot.', rewardCoins: 5000),
    AchievementDef(id: 'shot_75_blocks', title: 'Seventy-Five in One', description: '75 blocks in a single shot. The level had no chance.', rewardCoins: 10000),

    // COSMETICS (10)
    AchievementDef(id: 'cosmetic_1', title: 'First Purchase', description: 'Unlock your first cosmetic.', rewardCoins: 30),
    AchievementDef(id: 'cosmetic_2', title: 'Second Pick', description: 'Unlock 2 paid cosmetics.', rewardCoins: 50),
    AchievementDef(id: 'cosmetic_3', title: 'Three Items', description: 'Unlock 3 paid cosmetics.', rewardCoins: 70),
    AchievementDef(id: 'cosmetic_4', title: 'Four Items', description: 'Unlock 4 paid cosmetics.', rewardCoins: 100),
    AchievementDef(id: 'cosmetic_5', title: 'Five Items', description: 'Unlock 5 paid cosmetics.', rewardCoins: 140),
    AchievementDef(id: 'cosmetic_6', title: 'Six Items', description: 'Unlock 6 paid cosmetics.', rewardCoins: 200),
    AchievementDef(id: 'cosmetic_all_balls', title: 'Ball Collector', description: 'Own all ball skins.', rewardCoins: 300),
    AchievementDef(id: 'cosmetic_all_trails', title: 'Trail Collector', description: 'Own all trail effects.', rewardCoins: 300),
    AchievementDef(id: 'cosmetic_all_cores', title: 'Core Collector', description: 'Own all orbit core skins.', rewardCoins: 300),
    AchievementDef(id: 'cosmetic_all', title: 'The Full Set', description: 'Unlock every cosmetic in the collection.', rewardCoins: 1500),

    // COINS BALANCE (12)
    AchievementDef(id: 'balance_100', title: 'Pocket Full', description: 'Hold 100 coins at once.', rewardCoins: 20),
    AchievementDef(id: 'balance_500', title: 'Five Hundred Saved', description: 'Hold 500 coins.', rewardCoins: 40),
    AchievementDef(id: 'balance_1k', title: 'One K Balance', description: 'Hold 1,000 coins.', rewardCoins: 70),
    AchievementDef(id: 'balance_2500', title: 'Two-Fifty Balance', description: 'Hold 2,500 coins.', rewardCoins: 120),
    AchievementDef(id: 'balance_5k', title: 'Five K Balance', description: 'Hold 5,000 coins.', rewardCoins: 190),
    AchievementDef(id: 'balance_10k', title: 'Ten K Balance', description: 'Hold 10,000 coins.', rewardCoins: 300),
    AchievementDef(id: 'balance_25k', title: 'Twenty-Five K Balance', description: 'Hold 25,000 coins at once. Resist the shop.', rewardCoins: 500),
    AchievementDef(id: 'balance_50k', title: 'Fifty K Balance', description: 'Hold 50,000 coins.', rewardCoins: 850),
    AchievementDef(id: 'balance_100k', title: 'One Hundred K Balance', description: 'Hold 100,000 coins.', rewardCoins: 1500),
    AchievementDef(id: 'balance_500k', title: 'Half Million Balance', description: 'Hold 500,000 coins.', rewardCoins: 5000),
    AchievementDef(id: 'balance_1m', title: 'Coin Millionaire Balance', description: 'Hold 1,000,000 coins at once.', rewardCoins: 12000),
    AchievementDef(id: 'balance_5m', title: 'Five Million Balance', description: 'Hold 5,000,000 coins. The shop can\'t hold your interest.', rewardCoins: 40000),

    // META ACHIEVEMENTS (8)
    AchievementDef(id: 'ach_10', title: 'Achiever', description: 'Unlock 10 achievements.', rewardCoins: 100),
    AchievementDef(id: 'ach_25', title: 'On Track', description: 'Unlock 25 achievements.', rewardCoins: 200),
    AchievementDef(id: 'ach_50', title: 'Halfway There', description: 'Unlock 50 achievements.', rewardCoins: 500),
    AchievementDef(id: 'ach_100', title: 'Centurion', description: 'Unlock 100 achievements.', rewardCoins: 1200),
    AchievementDef(id: 'ach_150', title: 'One-Fifty Unlocked', description: 'Unlock 150 achievements.', rewardCoins: 3000),
    AchievementDef(id: 'ach_200', title: 'Two Hundred', description: 'Unlock 200 achievements.', rewardCoins: 8000),
    AchievementDef(id: 'ach_225', title: 'Closing In', description: 'Unlock 225 achievements. The end is near.', rewardCoins: 20000),
    AchievementDef(id: 'ach_all', title: 'Perfection', description: 'Unlock all 250 achievements. You have seen everything this game has to offer.', rewardCoins: 50000),
  ];

  // ── Instance state ───────────────────────────────────────────────────────────

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
  int totalShotsLaunched = 0;
  int totalOrbitEnters = 0;
  int totalCoinsEarned = 0;
  int hardModeLevelsCleared = 0;
  int endlessModeLevelsCleared = 0;
  int dailyChallengesPlayed = 0;
  int dailyChallengesBeaten = 0;
  int bestSingleShotBlocks = 0;
  bool tutorialDone = false;
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
    totalShotsLaunched = prefs.getInt(_shotsLaunchedKey) ?? 0;
    totalOrbitEnters = prefs.getInt(_orbitEntersKey) ?? 0;
    totalCoinsEarned = prefs.getInt(_totalCoinsEarnedKey) ?? 0;
    hardModeLevelsCleared = prefs.getInt(_hardLevelsClearedKey) ?? 0;
    endlessModeLevelsCleared = prefs.getInt(_endlessLevelsClearedKey) ?? 0;
    dailyChallengesPlayed = prefs.getInt(_dailyPlayedKey) ?? 0;
    dailyChallengesBeaten = prefs.getInt(_dailyBeatenKey) ?? 0;
    bestSingleShotBlocks = prefs.getInt(_bestSingleShotBlocksKey) ?? 0;
    tutorialDone = prefs.getBool(_tutorialDoneKey) ?? false;
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

  Future<void> setTutorialDone() async {
    tutorialDone = true;
    notifyListeners();
    await _prefs?.setBool(_tutorialDoneKey, true);
  }

  Future<void> recordScore(int score) async {
    var changed = false;
    if (score > highScore) {
      highScore = score;
      await _prefs?.setInt(_highScoreKey, highScore);
      changed = true;
    }

    if (selectedMode == GameMode.daily) {
      final prevBest = dailyBestScore;
      if (score > dailyBestScore) {
        dailyBestScore = score;
        await _prefs?.setInt(_dailyScoreKey, dailyBestScore);
        changed = true;
      }
      if (score >= dailyTargetScore && prevBest < dailyTargetScore) {
        dailyChallengesBeaten++;
        await _prefs?.setInt(_dailyBeatenKey, dailyChallengesBeaten);
        await _checkAchievements();
        changed = true;
      }
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

    switch (selectedMode) {
      case GameMode.hard:
        hardModeLevelsCleared++;
        await _prefs?.setInt(_hardLevelsClearedKey, hardModeLevelsCleared);
      case GameMode.endless:
        endlessModeLevelsCleared++;
        await _prefs?.setInt(_endlessLevelsClearedKey, endlessModeLevelsCleared);
      case GameMode.daily:
        dailyChallengesPlayed++;
        await _prefs?.setInt(_dailyPlayedKey, dailyChallengesPlayed);
      case GameMode.normal:
        break;
    }

    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordBlockDestroyed({required int coinReward}) async {
    blocksDestroyed++;
    coins += coinReward;
    totalCoinsEarned += coinReward;
    await _prefs?.setInt(_blocksDestroyedKey, blocksDestroyed);
    await _prefs?.setInt(_coinsKey, coins);
    await _prefs?.setInt(_totalCoinsEarnedKey, totalCoinsEarned);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordRicochet() async {
    ricochets++;
    await _prefs?.setInt(_ricochetsKey, ricochets);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordShotLaunched() async {
    totalShotsLaunched++;
    await _prefs?.setInt(_shotsLaunchedKey, totalShotsLaunched);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordOrbitEnter() async {
    totalOrbitEnters++;
    await _prefs?.setInt(_orbitEntersKey, totalOrbitEnters);
    await _checkAchievements();
    notifyListeners();
  }

  Future<void> recordSingleShotBlocks(int count) async {
    if (count <= bestSingleShotBlocks) return;
    bestSingleShotBlocks = count;
    await _prefs?.setInt(_bestSingleShotBlocksKey, bestSingleShotBlocks);
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
      await _checkAchievements();
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
      totalCoinsEarned += achievement.rewardCoins;
    }

    if (newlyUnlocked.isEmpty) return;

    await _prefs?.setStringList(
      _unlockedAchievementsKey,
      unlockedAchievementIds.toList()..sort(),
    );
    await _prefs?.setInt(_coinsKey, coins);
    await _prefs?.setInt(_totalCoinsEarnedKey, totalCoinsEarned);
  }

  // ignore: long-method
  bool _achievementConditionMet(String id) {
    final n = unlockedAchievementIds.length;
    return switch (id) {
      // INTRO
      'first_shot'       => totalShotsLaunched >= 1,
      'first_level'      => levelsCleared >= 1,
      'first_orbit'      => totalOrbitEnters >= 1,
      'first_combo'      => maxCombo >= 3,
      'first_pop'        => blocksDestroyed >= 1,
      'first_coin'       => totalCoinsEarned >= 1,
      'first_bounce'     => ricochets >= 1,
      'getting_started'  => levelsCleared >= 3,
      'warming_up'       => ricochets >= 10,
      'picking_up_speed' => maxCombo >= 5,

      // NORMAL LEVELS
      'clear_5'      => levelsCleared >= 5,
      'clear_10'     => levelsCleared >= 10,
      'clear_20'     => levelsCleared >= 20,
      'clear_30'     => levelsCleared >= 30,
      'clear_50'     => levelsCleared >= 50,
      'clear_75'     => levelsCleared >= 75,
      'clear_100'    => levelsCleared >= 100,
      'clear_150'    => levelsCleared >= 150,
      'clear_200'    => levelsCleared >= 200,
      'clear_250'    => levelsCleared >= 250,
      'clear_300'    => levelsCleared >= 300,
      'clear_400'    => levelsCleared >= 400,
      'clear_500'    => levelsCleared >= 500,
      'clear_750'    => levelsCleared >= 750,
      'clear_1000'   => levelsCleared >= 1000,
      'clear_1500'   => levelsCleared >= 1500,
      'clear_2000'   => levelsCleared >= 2000,
      'clear_3000'   => levelsCleared >= 3000,
      'clear_4000'   => levelsCleared >= 4000,
      'clear_5000'   => levelsCleared >= 5000,
      'clear_7500'   => levelsCleared >= 7500,
      'clear_10000'  => levelsCleared >= 10000,
      'clear_15000'  => levelsCleared >= 15000,
      'clear_20000'  => levelsCleared >= 20000,
      'clear_30000'  => levelsCleared >= 30000,
      'clear_50000'  => levelsCleared >= 50000,
      'clear_75000'  => levelsCleared >= 75000,
      'clear_100000' => levelsCleared >= 100000,
      'clear_150000' => levelsCleared >= 150000,
      'clear_200000' => levelsCleared >= 200000,

      // HARD MODE
      'hard_1'    => hardModeLevelsCleared >= 1,
      'hard_5'    => hardModeLevelsCleared >= 5,
      'hard_10'   => hardModeLevelsCleared >= 10,
      'hard_20'   => hardModeLevelsCleared >= 20,
      'hard_30'   => hardModeLevelsCleared >= 30,
      'hard_50'   => hardModeLevelsCleared >= 50,
      'hard_75'   => hardModeLevelsCleared >= 75,
      'hard_100'  => hardModeLevelsCleared >= 100,
      'hard_150'  => hardModeLevelsCleared >= 150,
      'hard_200'  => hardModeLevelsCleared >= 200,
      'hard_300'  => hardModeLevelsCleared >= 300,
      'hard_500'  => hardModeLevelsCleared >= 500,
      'hard_750'  => hardModeLevelsCleared >= 750,
      'hard_1000' => hardModeLevelsCleared >= 1000,
      'hard_2000' => hardModeLevelsCleared >= 2000,

      // ENDLESS
      'endless_1'    => endlessModeLevelsCleared >= 1,
      'endless_5'    => endlessModeLevelsCleared >= 5,
      'endless_10'   => endlessModeLevelsCleared >= 10,
      'endless_20'   => endlessModeLevelsCleared >= 20,
      'endless_30'   => endlessModeLevelsCleared >= 30,
      'endless_50'   => endlessModeLevelsCleared >= 50,
      'endless_75'   => endlessModeLevelsCleared >= 75,
      'endless_100'  => endlessModeLevelsCleared >= 100,
      'endless_150'  => endlessModeLevelsCleared >= 150,
      'endless_200'  => endlessModeLevelsCleared >= 200,
      'endless_300'  => endlessModeLevelsCleared >= 300,
      'endless_500'  => endlessModeLevelsCleared >= 500,
      'endless_750'  => endlessModeLevelsCleared >= 750,
      'endless_1000' => endlessModeLevelsCleared >= 1000,
      'endless_1500' => endlessModeLevelsCleared >= 1500,
      'endless_2000' => endlessModeLevelsCleared >= 2000,

      // DAILY
      'daily_play_1'   => dailyChallengesPlayed >= 1,
      'daily_play_3'   => dailyChallengesPlayed >= 3,
      'daily_play_5'   => dailyChallengesPlayed >= 5,
      'daily_play_7'   => dailyChallengesPlayed >= 7,
      'daily_play_10'  => dailyChallengesPlayed >= 10,
      'daily_play_14'  => dailyChallengesPlayed >= 14,
      'daily_play_20'  => dailyChallengesPlayed >= 20,
      'daily_play_30'  => dailyChallengesPlayed >= 30,
      'daily_play_50'  => dailyChallengesPlayed >= 50,
      'daily_play_100' => dailyChallengesPlayed >= 100,
      'daily_beat_1'   => dailyChallengesBeaten >= 1,
      'daily_beat_10'  => dailyChallengesBeaten >= 10,

      // BLOCKS
      'blocks_10'  => blocksDestroyed >= 10,
      'blocks_50'  => blocksDestroyed >= 50,
      'blocks_100' => blocksDestroyed >= 100,
      'blocks_250' => blocksDestroyed >= 250,
      'blocks_500' => blocksDestroyed >= 500,
      'blocks_1k'  => blocksDestroyed >= 1000,
      'blocks_2500'=> blocksDestroyed >= 2500,
      'blocks_5k'  => blocksDestroyed >= 5000,
      'blocks_10k' => blocksDestroyed >= 10000,
      'blocks_25k' => blocksDestroyed >= 25000,
      'blocks_50k' => blocksDestroyed >= 50000,
      'blocks_100k'=> blocksDestroyed >= 100000,
      'blocks_250k'=> blocksDestroyed >= 250000,
      'blocks_500k'=> blocksDestroyed >= 500000,
      'blocks_1m'  => blocksDestroyed >= 1000000,
      'blocks_2m5' => blocksDestroyed >= 2500000,
      'blocks_5m'  => blocksDestroyed >= 5000000,
      'blocks_10m' => blocksDestroyed >= 10000000,
      'blocks_25m' => blocksDestroyed >= 25000000,
      'blocks_50m' => blocksDestroyed >= 50000000,
      'blocks_100m'=> blocksDestroyed >= 100000000,
      'blocks_250m'=> blocksDestroyed >= 250000000,

      // RICOCHETS
      'ricochet_25'  => ricochets >= 25,
      'ricochet_100' => ricochets >= 100,
      'ricochet_250' => ricochets >= 250,
      'ricochet_500' => ricochets >= 500,
      'ricochet_1k'  => ricochets >= 1000,
      'ricochet_2500'=> ricochets >= 2500,
      'ricochet_5k'  => ricochets >= 5000,
      'ricochet_10k' => ricochets >= 10000,
      'ricochet_25k' => ricochets >= 25000,
      'ricochet_50k' => ricochets >= 50000,
      'ricochet_100k'=> ricochets >= 100000,
      'ricochet_250k'=> ricochets >= 250000,
      'ricochet_500k'=> ricochets >= 500000,
      'ricochet_1m'  => ricochets >= 1000000,
      'ricochet_2m5' => ricochets >= 2500000,
      'ricochet_5m'  => ricochets >= 5000000,
      'ricochet_10m' => ricochets >= 10000000,
      'ricochet_25m' => ricochets >= 25000000,
      'ricochet_50m' => ricochets >= 50000000,
      'ricochet_100m'=> ricochets >= 100000000,

      // COMBOS
      'combo_3'    => maxCombo >= 3,
      'combo_5'    => maxCombo >= 5,
      'combo_8'    => maxCombo >= 8,
      'combo_10'   => maxCombo >= 10,
      'combo_12'   => maxCombo >= 12,
      'combo_15'   => maxCombo >= 15,
      'combo_20'   => maxCombo >= 20,
      'combo_25'   => maxCombo >= 25,
      'combo_30'   => maxCombo >= 30,
      'combo_40'   => maxCombo >= 40,
      'combo_50'   => maxCombo >= 50,
      'combo_75'   => maxCombo >= 75,
      'combo_100'  => maxCombo >= 100,
      'combo_150'  => maxCombo >= 150,
      'combo_200'  => maxCombo >= 200,
      'combo_500'  => maxCombo >= 500,
      'combo_750'  => maxCombo >= 750,
      'combo_1000' => maxCombo >= 1000,

      // HIGH SCORE
      'score_100'  => highScore >= 100,
      'score_250'  => highScore >= 250,
      'score_500'  => highScore >= 500,
      'score_1k'   => highScore >= 1000,
      'score_2500' => highScore >= 2500,
      'score_5k'   => highScore >= 5000,
      'score_10k'  => highScore >= 10000,
      'score_25k'  => highScore >= 25000,
      'score_50k'  => highScore >= 50000,
      'score_100k' => highScore >= 100000,
      'score_250k' => highScore >= 250000,
      'score_500k' => highScore >= 500000,
      'score_1m'   => highScore >= 1000000,
      'score_5m'   => highScore >= 5000000,
      'score_10m'  => highScore >= 10000000,
      'score_25m'  => highScore >= 25000000,
      'score_50m'  => highScore >= 50000000,

      // COINS EARNED
      'earned_50'   => totalCoinsEarned >= 50,
      'earned_100'  => totalCoinsEarned >= 100,
      'earned_250'  => totalCoinsEarned >= 250,
      'earned_500'  => totalCoinsEarned >= 500,
      'earned_1k'   => totalCoinsEarned >= 1000,
      'earned_2500' => totalCoinsEarned >= 2500,
      'earned_5k'   => totalCoinsEarned >= 5000,
      'earned_10k'  => totalCoinsEarned >= 10000,
      'earned_25k'  => totalCoinsEarned >= 25000,
      'earned_50k'  => totalCoinsEarned >= 50000,
      'earned_100k' => totalCoinsEarned >= 100000,
      'earned_250k' => totalCoinsEarned >= 250000,
      'earned_500k' => totalCoinsEarned >= 500000,
      'earned_1m'   => totalCoinsEarned >= 1000000,
      'earned_5m'   => totalCoinsEarned >= 5000000,
      'earned_10m'  => totalCoinsEarned >= 10000000,

      // SHOTS LAUNCHED
      'shots_10'   => totalShotsLaunched >= 10,
      'shots_50'   => totalShotsLaunched >= 50,
      'shots_100'  => totalShotsLaunched >= 100,
      'shots_250'  => totalShotsLaunched >= 250,
      'shots_500'  => totalShotsLaunched >= 500,
      'shots_1k'   => totalShotsLaunched >= 1000,
      'shots_2500' => totalShotsLaunched >= 2500,
      'shots_5k'   => totalShotsLaunched >= 5000,
      'shots_10k'  => totalShotsLaunched >= 10000,
      'shots_25k'  => totalShotsLaunched >= 25000,
      'shots_50k'  => totalShotsLaunched >= 50000,
      'shots_100k' => totalShotsLaunched >= 100000,
      'shots_250k' => totalShotsLaunched >= 250000,
      'shots_500k' => totalShotsLaunched >= 500000,
      'shots_1m'   => totalShotsLaunched >= 1000000,
      'shots_5m'   => totalShotsLaunched >= 5000000,

      // ORBIT ENTERS
      'orbit_5'    => totalOrbitEnters >= 5,
      'orbit_25'   => totalOrbitEnters >= 25,
      'orbit_100'  => totalOrbitEnters >= 100,
      'orbit_250'  => totalOrbitEnters >= 250,
      'orbit_500'  => totalOrbitEnters >= 500,
      'orbit_1k'   => totalOrbitEnters >= 1000,
      'orbit_2500' => totalOrbitEnters >= 2500,
      'orbit_5k'   => totalOrbitEnters >= 5000,
      'orbit_10k'  => totalOrbitEnters >= 10000,
      'orbit_25k'  => totalOrbitEnters >= 25000,
      'orbit_50k'  => totalOrbitEnters >= 50000,
      'orbit_100k' => totalOrbitEnters >= 100000,
      'orbit_250k' => totalOrbitEnters >= 250000,
      'orbit_500k' => totalOrbitEnters >= 500000,
      'orbit_1m'   => totalOrbitEnters >= 1000000,
      'orbit_5m'   => totalOrbitEnters >= 5000000,

      // SINGLE SHOT
      'shot_5_blocks'  => bestSingleShotBlocks >= 5,
      'shot_8_blocks'  => bestSingleShotBlocks >= 8,
      'shot_10_blocks' => bestSingleShotBlocks >= 10,
      'shot_12_blocks' => bestSingleShotBlocks >= 12,
      'shot_15_blocks' => bestSingleShotBlocks >= 15,
      'shot_20_blocks' => bestSingleShotBlocks >= 20,
      'shot_25_blocks' => bestSingleShotBlocks >= 25,
      'shot_30_blocks' => bestSingleShotBlocks >= 30,
      'shot_40_blocks' => bestSingleShotBlocks >= 40,
      'shot_50_blocks' => bestSingleShotBlocks >= 50,
      'shot_60_blocks' => bestSingleShotBlocks >= 60,
      'shot_75_blocks' => bestSingleShotBlocks >= 75,

      // COSMETICS
      'cosmetic_1'         => unlockedCosmeticIds.length >= 4,
      'cosmetic_2'         => unlockedCosmeticIds.length >= 5,
      'cosmetic_3'         => unlockedCosmeticIds.length >= 6,
      'cosmetic_4'         => unlockedCosmeticIds.length >= 7,
      'cosmetic_5'         => unlockedCosmeticIds.length >= 8,
      'cosmetic_6'         => unlockedCosmeticIds.length >= 9,
      'cosmetic_all_balls' => unlockedCosmeticIds.containsAll(['ball.core-blue', 'ball.ion-green', 'ball.solar-warning']),
      'cosmetic_all_trails'=> unlockedCosmeticIds.containsAll(['trail.core-blue', 'trail.spark', 'trail.comet']),
      'cosmetic_all_cores' => unlockedCosmeticIds.containsAll(['core.core-blue', 'core.ion-green', 'core.red-shift']),
      'cosmetic_all'       => unlockedCosmeticIds.length >= 9,

      // COINS BALANCE
      'balance_100'  => coins >= 100,
      'balance_500'  => coins >= 500,
      'balance_1k'   => coins >= 1000,
      'balance_2500' => coins >= 2500,
      'balance_5k'   => coins >= 5000,
      'balance_10k'  => coins >= 10000,
      'balance_25k'  => coins >= 25000,
      'balance_50k'  => coins >= 50000,
      'balance_100k' => coins >= 100000,
      'balance_500k' => coins >= 500000,
      'balance_1m'   => coins >= 1000000,
      'balance_5m'   => coins >= 5000000,

      // META
      'ach_10'  => n >= 10,
      'ach_25'  => n >= 25,
      'ach_50'  => n >= 50,
      'ach_100' => n >= 100,
      'ach_150' => n >= 150,
      'ach_200' => n >= 200,
      'ach_225' => n >= 225,
      'ach_all' => n >= 249,

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

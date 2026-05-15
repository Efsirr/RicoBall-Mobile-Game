import 'dart:math';

import 'package:flutter/foundation.dart';

import 'power_up_type.dart';

enum GamePhase { aiming, shooting, resetting }

enum TutorialStep { aim, orbit, combo, done }

class PowerUpHudState {
  final PowerUpType type;
  final String detail;

  const PowerUpHudState({required this.type, required this.detail});
}

class GameState {
  GamePhase phase = GamePhase.aiming;
  int score = 0;
  int combo = 0;
  int level = 1;
  int blocksRemaining = 0;
  double resetTimer = 0;
  bool noProgressOverlayVisible = false;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);
  final ValueNotifier<bool> noProgressNotifier = ValueNotifier(false);
  final ValueNotifier<String?> hintNotifier = ValueNotifier(null);
  final ValueNotifier<PowerUpHudState?> powerUpNotifier = ValueNotifier(null);
  final ValueNotifier<TutorialStep?> tutorialNotifier = ValueNotifier(null);

  void resetCombo() => combo = 0;

  void incrementCombo() => combo++;

  void addScore(int points) {
    score += points * max(1, combo);
    scoreNotifier.value = score;
  }

  void nextLevel() {
    level++;
    levelNotifier.value = level;
  }

  void showNoProgressOverlay() {
    noProgressOverlayVisible = true;
    noProgressNotifier.value = true;
  }

  void clearNoProgressOverlay() {
    noProgressOverlayVisible = false;
    noProgressNotifier.value = false;
  }

  void showHint(String message) {
    hintNotifier.value = message;
  }

  void clearHint() {
    hintNotifier.value = null;
  }

  void showPowerUp(PowerUpType type, String detail) {
    powerUpNotifier.value = PowerUpHudState(type: type, detail: detail);
  }

  void clearPowerUp() {
    powerUpNotifier.value = null;
  }

  void resetRun() {
    phase = GamePhase.aiming;
    score = 0;
    combo = 0;
    level = 1;
    blocksRemaining = 0;
    resetTimer = 0;
    clearNoProgressOverlay();
    clearHint();
    clearPowerUp();
    tutorialNotifier.value = null;
    scoreNotifier.value = score;
    levelNotifier.value = level;
  }

  void startTutorial() => tutorialNotifier.value = TutorialStep.aim;

  void advanceTutorial() {
    final current = tutorialNotifier.value;
    if (current == null || current == TutorialStep.done) return;
    tutorialNotifier.value = switch (current) {
      TutorialStep.aim => TutorialStep.orbit,
      TutorialStep.orbit => TutorialStep.combo,
      TutorialStep.combo => TutorialStep.done,
      TutorialStep.done => TutorialStep.done,
    };
  }

  void endTutorial() => tutorialNotifier.value = null;
}

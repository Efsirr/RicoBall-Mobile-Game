import 'dart:math';

import 'package:flutter/foundation.dart';

enum GamePhase { aiming, shooting, resetting }

class GameState {
  GamePhase phase = GamePhase.aiming;
  int score = 0;
  int combo = 0;
  int level = 1;
  int blocksRemaining = 0;
  double resetTimer = 0;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);

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
}

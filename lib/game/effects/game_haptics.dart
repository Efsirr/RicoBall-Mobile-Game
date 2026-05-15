import 'dart:async';

import 'package:flutter/services.dart';

import '../save/game_progress.dart';

abstract final class GameHaptics {
  static void launch() => _trigger(HapticFeedback.selectionClick);

  static void blockHit() => _trigger(HapticFeedback.lightImpact);

  static void blockDestroyed() => _trigger(HapticFeedback.mediumImpact);

  static void combo() => _trigger(HapticFeedback.heavyImpact);

  static void levelComplete() => _trigger(HapticFeedback.vibrate);

  static void _trigger(Future<void> Function() feedback) {
    if (!GameProgress.instance.hapticsEnabled) return;
    unawaited(feedback());
  }
}

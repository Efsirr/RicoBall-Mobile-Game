import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/ricochet_game.dart';

class HudOverlay extends StatelessWidget {
  final RicochetGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: game.state.levelNotifier,
              builder: (_, level, _) => _label('LEVEL $level'),
            ),
            ValueListenableBuilder<int>(
              valueListenable: game.state.scoreNotifier,
              builder: (_, score, _) => _label('$score'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: GameColors.uiText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        fontFamily: 'monospace',
      ),
    );
  }
}

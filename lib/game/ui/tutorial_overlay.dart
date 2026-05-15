import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/ricochet_game.dart';

class TutorialOverlay extends StatelessWidget {
  final RicochetGame game;

  const TutorialOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TutorialStep?>(
      valueListenable: game.state.tutorialNotifier,
      builder: (_, step, _) {
        if (step == null || step == TutorialStep.done) {
          return const SizedBox.shrink();
        }
        return _TutorialPanel(step: step, game: game);
      },
    );
  }
}

class _TutorialPanel extends StatelessWidget {
  final TutorialStep step;
  final RicochetGame game;

  const _TutorialPanel({required this.step, required this.game});

  _StepContent get _content => switch (step) {
        TutorialStep.aim => _StepContent(
            icon: PhosphorIconsFill.handPointing,
            color: GameColors.electricBlue,
            title: 'Aim your shot',
            body: 'Drag anywhere on screen to aim,\nthen release to launch the ball.',
            step: '1 / 3',
          ),
        TutorialStep.orbit => _StepContent(
            icon: PhosphorIconsFill.circle,
            color: GameColors.neonCyan,
            title: 'Enter the orbit',
            body: 'Guide the ball through the glowing\norbit core for maximum power.',
            step: '2 / 3',
          ),
        TutorialStep.combo => _StepContent(
            icon: PhosphorIconsFill.lightning,
            color: GameColors.warning,
            title: 'Chain a combo',
            body: 'Destroy 2 or more blocks in\none shot to trigger a combo!',
            step: '3 / 3',
          ),
        TutorialStep.done => throw StateError('done step passed to panel'),
      };

  @override
  Widget build(BuildContext context) {
    final c = _content;
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 90,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GameColors.surfaceLight.withValues(alpha: 0.88),
                  GameColors.surface.withValues(alpha: 0.96),
                ],
              ),
              border: Border.all(
                color: c.color.withValues(alpha: 0.32),
              ),
              boxShadow: [
                BoxShadow(
                  color: c.color.withValues(alpha: 0.18),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.color.withValues(alpha: 0.14),
                        border: Border.all(color: c.color.withValues(alpha: 0.28)),
                      ),
                      child: Icon(c.icon, color: c.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: const TextStyle(
                              color: GameColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            c.step,
                            style: const TextStyle(
                              color: GameColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => game.skipTutorial(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: GameColors.textSecondary.withValues(alpha: 0.65),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  c.body,
                  style: const TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _ProgressDots(step: step),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final TutorialStep step;

  const _ProgressDots({required this.step});

  int get _activeIndex => switch (step) {
        TutorialStep.aim => 0,
        TutorialStep.orbit => 1,
        TutorialStep.combo => 2,
        TutorialStep.done => 3,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i == _activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isActive ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? GameColors.electricBlue
                : GameColors.textTertiary.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }
}

class _StepContent {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String step;

  const _StepContent({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.step,
  });
}

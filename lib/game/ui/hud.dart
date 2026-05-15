import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../ads/unity_ads_service.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/power_up_type.dart';
import '../core/ricochet_game.dart';
import '../save/game_progress.dart';
import 'tutorial_overlay.dart';

class HudOverlay extends StatefulWidget {
  final RicochetGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  bool _isPaused = false;

  void _setPaused(bool paused) {
    HapticFeedback.selectionClick();
    setState(() => _isPaused = paused);

    if (paused) {
      widget.game.pauseEngine();
    } else {
      widget.game.resumeEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              children: [
                _TopBar(onPause: () => _setPaused(true)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: widget.game.state.scoreNotifier,
                        builder: (_, score, _) => _StatCard(
                          label: 'SCORE',
                          value: _formatScore(score),
                          color: GameColors.electricBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: widget.game.state.levelNotifier,
                        builder: (_, level, _) => _StatCard(
                          label: 'LEVEL',
                          value: '$level',
                          color: GameColors.blockHp1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _PhasePill(game: widget.game),
                  ],
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: widget.game.state.hintNotifier,
                  builder: (_, hint, _) {
                    if (hint == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _HintBanner(
                        message: hint,
                        onDismiss: widget.game.state.clearHint,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<PowerUpHudState?>(
                  valueListenable: widget.game.state.powerUpNotifier,
                  builder: (_, powerUp, _) {
                    if (powerUp == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _PowerUpBanner(powerUp: powerUp),
                    );
                  },
                ),
                const Spacer(),
                const _BottomTray(),
              ],
            ),
          ),
        ),
        if (_isPaused)
          _PauseOverlay(
            onResume: () => _setPaused(false),
            onRestartLevel: () {
              setState(() => _isPaused = false);
              widget.game.restartLevel();
            },
            onRestartRun: () {
              setState(() => _isPaused = false);
              widget.game.restartRun();
            },
            onWatchAd: _showRewardedAd,
            onQuit: () {
              widget.game.resumeEngine();
              Navigator.of(context).maybePop();
            },
          ),
        if (!_isPaused)
          ValueListenableBuilder<bool>(
            valueListenable: widget.game.state.noProgressNotifier,
            builder: (_, visible, _) {
              if (!visible) return const SizedBox.shrink();

              return _NoProgressOverlay(
                onRetry: widget.game.restartLevel,
                onNewRun: widget.game.restartRun,
                onQuit: () => Navigator.of(context).maybePop(),
              );
            },
          ),
        if (!_isPaused)
          TutorialOverlay(game: widget.game),
      ],
    );
  }

  String _formatScore(int score) {
    if (score < 1000) return '$score';
    final compact = score / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}K';
  }

  Future<void> _showRewardedAd() async {
    HapticFeedback.selectionClick();
    await UnityAdsService.instance.showRewarded(
      onReward: () {
        widget.game.state.addScore(250);
        unawaited(GameProgress.instance.recordScore(widget.game.state.score));
        HapticFeedback.mediumImpact();
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onPause;

  const _TopBar({required this.onPause});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _StatusPill(
          icon: PhosphorIconsFill.hexagon,
          label: 'ORBIT FIELD',
        ),
        const Spacer(),
        _IconButton(icon: PhosphorIconsFill.pause, onPressed: onPause),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _HudSurface(
      borderRadius: 18,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: GameColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 24,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              fontFamily: '.SF UI Display',
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  final RicochetGame game;

  const _PhasePill({required this.game});

  @override
  Widget build(BuildContext context) {
    return _HudSurface(
      width: 82,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      glowColor: GameColors.neonCyan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CORE',
            style: TextStyle(
              color: GameColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameColors.electricBlue.withValues(alpha: 0.95),
                  GameColors.electricBlue.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: GameColors.electricBlue.withValues(alpha: 0.34),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsFill.lightning,
              color: GameColors.textPrimary,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTray extends StatelessWidget {
  const _BottomTray();

  @override
  Widget build(BuildContext context) {
    return _HudSurface(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      glowColor: GameColors.electricBlue,
      child: const Row(
        children: [
          Icon(
            PhosphorIconsFill.handPointing,
            color: GameColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Drag to aim. Release through the core for premium damage.',
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _HintBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return _HudSurface(
      borderRadius: 18,
      padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
      glowColor: GameColors.warning,
      child: Row(
        children: [
          const Icon(
            PhosphorIconsFill.lightbulb,
            color: GameColors.warning,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                PhosphorIconsRegular.x,
                color: GameColors.textTertiary,
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerUpBanner extends StatelessWidget {
  final PowerUpHudState powerUp;

  const _PowerUpBanner({required this.powerUp});

  @override
  Widget build(BuildContext context) {
    final color = powerUp.type.color;
    final icon = switch (powerUp.type) {
      PowerUpType.multiBall => PhosphorIconsFill.circlesThreePlus,
      PowerUpType.heavyBall => PhosphorIconsFill.barbell,
      PowerUpType.piercingBall => PhosphorIconsFill.arrowFatLinesRight,
    };

    return _HudSurface(
      borderRadius: 18,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      glowColor: color,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              powerUp.type.label,
              style: const TextStyle(
                color: GameColors.textPrimary,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.24)),
            ),
            child: Text(
              powerUp.detail,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestartLevel;
  final VoidCallback onRestartRun;
  final VoidCallback onWatchAd;
  final VoidCallback onQuit;

  const _PauseOverlay({
    required this.onResume,
    required this.onRestartLevel,
    required this.onRestartRun,
    required this.onWatchAd,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.48)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GameColors.surfaceLight.withValues(alpha: 0.82),
                        GameColors.surface.withValues(alpha: 0.94),
                      ],
                    ),
                    border: Border.all(
                      color: GameColors.electricBlue.withValues(alpha: 0.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.electricBlue.withValues(alpha: 0.18),
                        blurRadius: 42,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Run Paused',
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.9,
                          fontFamily: '.SF UI Display',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The field is holding your trajectory.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _ModalButton(
                        label: 'Resume',
                        icon: PhosphorIconsFill.play,
                        onPressed: onResume,
                        isPrimary: true,
                      ),
                      _RewardedAdButton(onPressed: onWatchAd),
                      const SizedBox(height: 10),
                      _ModalButton(
                        label: 'Retry Level',
                        icon: PhosphorIconsRegular.arrowCounterClockwise,
                        onPressed: onRestartLevel,
                      ),
                      const SizedBox(height: 10),
                      _ModalButton(
                        label: 'New Run',
                        icon: PhosphorIconsRegular.rewind,
                        onPressed: onRestartRun,
                      ),
                      const SizedBox(height: 10),
                      _ModalButton(
                        label: 'Return Home',
                        icon: PhosphorIconsFill.house,
                        onPressed: onQuit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoProgressOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onNewRun;
  final VoidCallback onQuit;

  const _NoProgressOverlay({
    required this.onRetry,
    required this.onNewRun,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.52)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GameColors.surfaceLight.withValues(alpha: 0.84),
                        GameColors.surface.withValues(alpha: 0.96),
                      ],
                    ),
                    border: Border.all(
                      color: GameColors.danger.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.danger.withValues(alpha: 0.16),
                        blurRadius: 42,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GameColors.danger.withValues(alpha: 0.12),
                          border: Border.all(
                            color: GameColors.danger.withValues(alpha: 0.28),
                          ),
                        ),
                        child: const Icon(
                          PhosphorIconsFill.warning,
                          color: GameColors.danger,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Progress',
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.9,
                          fontFamily: '.SF UI Display',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The shot faded before breaking a block. Reframe the angle and use the orbit well.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _ModalButton(
                        label: 'Retry Level',
                        icon: PhosphorIconsRegular.arrowCounterClockwise,
                        onPressed: onRetry,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 10),
                      _ModalButton(
                        label: 'New Run',
                        icon: PhosphorIconsRegular.rewind,
                        onPressed: onNewRun,
                      ),
                      const SizedBox(height: 10),
                      _ModalButton(
                        label: 'Return Home',
                        icon: PhosphorIconsFill.house,
                        onPressed: onQuit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isEnabled;

  const _ModalButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.selectionClick();
              onPressed();
            }
          : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF36A4FF), GameColors.electricBlue],
                )
              : null,
          color: isPrimary
              ? null
              : GameColors.surfaceLight.withValues(alpha: 0.45),
          border: Border.all(
            color: isPrimary
                ? GameColors.textPrimary.withValues(alpha: 0.12)
                : GameColors.border.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? GameColors.textPrimary
                  : GameColors.textSecondary.withValues(
                      alpha: isEnabled ? 1 : 0.52,
                    ),
              size: 17,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? GameColors.textPrimary
                    : GameColors.textSecondary.withValues(
                        alpha: isEnabled ? 1 : 0.52,
                      ),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardedAdButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RewardedAdButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UnityAdsService.instance,
      builder: (context, _) {
        if (!UnityAdsService.instance.isInitialized) {
          return const SizedBox.shrink();
        }

        final isReady = UnityAdsService.instance.isRewardedReady;
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _ModalButton(
            label: isReady ? 'Watch Ad +250' : 'Loading Ad',
            icon: PhosphorIconsFill.gift,
            onPressed: onPressed,
            isEnabled: isReady,
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return _HudSurface(
      borderRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      glowColor: GameColors.blockHp1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GameColors.blockHp1, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: _HudSurface(
        width: 42,
        height: 42,
        borderRadius: 14,
        padding: EdgeInsets.zero,
        glowColor: GameColors.electricBlue,
        child: Icon(icon, color: GameColors.textSecondary, size: 18),
      ),
    );
  }
}

class _HudSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color glowColor;
  final double? width;
  final double? height;

  const _HudSurface({
    required this.child,
    required this.padding,
    required this.borderRadius,
    required this.glowColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.surfaceLight.withValues(alpha: 0.54),
                GameColors.surface.withValues(alpha: 0.72),
              ],
            ),
            border: Border.all(
              color: Color.lerp(
                GameColors.border,
                glowColor,
                0.18,
              )!.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

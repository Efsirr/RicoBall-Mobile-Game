import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../game/core/constants.dart';
import '../game/save/game_progress.dart';

enum StudioPanelKind { settings, stats, shop }

class StudioPanelScreen extends StatefulWidget {
  final StudioPanelKind kind;

  const StudioPanelScreen({super.key, required this.kind});

  @override
  State<StudioPanelScreen> createState() => _StudioPanelScreenState();
}

class _StudioPanelScreenState extends State<StudioPanelScreen> {
  @override
  Widget build(BuildContext context) {
    final title = switch (widget.kind) {
      StudioPanelKind.settings => 'Settings',
      StudioPanelKind.stats => 'Stats',
      StudioPanelKind.shop => 'Collection',
    };
    final subtitle = switch (widget.kind) {
      StudioPanelKind.settings => 'Tune the run feel.',
      StudioPanelKind.stats => 'Records, achievements, and daily target.',
      StudioPanelKind.shop => 'Spend coins on authored orbit cosmetics.',
    };

    return Scaffold(
      body: Stack(
        children: [
          const _PanelBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PanelTopBar(title: title),
                  const SizedBox(height: 28),
                  _PanelHeader(title: title, subtitle: subtitle),
                  const SizedBox(height: 22),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: GameProgress.instance,
                      builder: (_, _) => _body(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final progress = GameProgress.instance;

    return switch (widget.kind) {
      StudioPanelKind.settings => _SettingsBody(
        sound: progress.soundEnabled,
        music: progress.musicEnabled,
        haptics: progress.hapticsEnabled,
        mode: progress.selectedMode,
        onSound: progress.setSoundEnabled,
        onMusic: progress.setMusicEnabled,
        onHaptics: progress.setHapticsEnabled,
        onMode: progress.setMode,
      ),
      StudioPanelKind.stats => _StatsBody(progress: progress),
      StudioPanelKind.shop => _ShopBody(progress: progress),
    };
  }
}

class _PanelBackdrop extends StatelessWidget {
  const _PanelBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameColors.backgroundAlt,
            GameColors.background,
            Color(0xFF050507),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -120,
            width: 360,
            height: 360,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    GameColors.electricBlue.withValues(alpha: 0.26),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -90,
            width: 260,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    GameColors.neonCyan.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTopBar extends StatelessWidget {
  final String title;

  const _PanelTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PanelIconButton(
          icon: PhosphorIconsRegular.caretLeft,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
        ),
        const Spacer(),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: GameColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 42),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PanelHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: GameColors.textPrimary,
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
            fontFamily: '.SF UI Display',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: GameColors.textSecondary,
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final bool sound;
  final bool music;
  final bool haptics;
  final GameMode mode;
  final ValueChanged<bool> onSound;
  final ValueChanged<bool> onMusic;
  final ValueChanged<bool> onHaptics;
  final ValueChanged<GameMode> onMode;

  const _SettingsBody({
    required this.sound,
    required this.music,
    required this.haptics,
    required this.mode,
    required this.onSound,
    required this.onMusic,
    required this.onHaptics,
    required this.onMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _PanelCard(
          child: Column(
            children: [
              _ModeSelector(value: mode, onChanged: onMode),
              const _SoftDivider(),
              _SettingsRow(
                icon: PhosphorIconsFill.speakerHigh,
                title: 'Sound Effects',
                subtitle: 'Launch, bounce, hit, and reward cues.',
                value: sound,
                onChanged: onSound,
              ),
              const _SoftDivider(),
              _SettingsRow(
                icon: PhosphorIconsRegular.musicNote,
                title: 'Ambient Music',
                subtitle: 'Low-pressure sci-fi loop when audio lands.',
                value: music,
                onChanged: onMusic,
              ),
              const _SoftDivider(),
              _SettingsRow(
                icon: PhosphorIconsRegular.waveform,
                title: 'Haptics',
                subtitle: 'Tactile impact for premium arcade feedback.',
                value: haptics,
                onChanged: onHaptics,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _CalloutCard(
          icon: PhosphorIconsFill.info,
          title: 'Saved locally',
          body:
              'Settings now persist between launches. Audio switches are ready for the sound phase.',
        ),
      ],
    );
  }
}

class _StatsBody extends StatelessWidget {
  final GameProgress progress;

  const _StatsBody({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatPanel(
                label: 'HIGH SCORE',
                value: _formatNumber(progress.highScore),
                tone: GameColors.electricBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatPanel(
                label: 'MAX COMBO',
                value: '${progress.maxCombo}x',
                tone: GameColors.blockHp1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatPanel(
                label: 'CLEARED',
                value: '${progress.levelsCleared}',
                tone: GameColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatPanel(
                label: 'BLOCKS',
                value: _formatNumber(progress.blocksDestroyed),
                tone: GameColors.neonCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatPanel(
                label: 'RICOCHETS',
                value: _formatNumber(progress.ricochets),
                tone: GameColors.danger,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatPanel(
                label: 'COINS',
                value: _formatNumber(progress.coins),
                tone: GameColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatPanel(
                label: 'DAILY BEST',
                value: _formatNumber(progress.dailyBestScore),
                tone: GameColors.electricBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatPanel(
                label: 'TARGET',
                value: _formatNumber(progress.dailyTargetScore),
                tone: GameColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _AchievementList(progress: progress),
        const SizedBox(height: 14),
        const _CalloutCard(
          icon: PhosphorIconsRegular.calendar,
          title: 'Daily challenge',
          body:
              'Daily mode uses a fixed seed for the day and tracks a local target score.',
        ),
      ],
    );
  }

  static String _formatNumber(int value) {
    if (value < 1000) return '$value';
    final compact = value / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}K';
  }
}

class _ModeSelector extends StatelessWidget {
  final GameMode value;
  final ValueChanged<GameMode> onChanged;

  const _ModeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Run Mode',
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Normal, Hard, Endless, or the fixed daily seed.',
            style: TextStyle(
              color: GameColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoSlidingSegmentedControl<GameMode>(
            groupValue: value,
            backgroundColor: GameColors.background.withValues(alpha: 0.74),
            thumbColor: GameColors.electricBlue,
            children: const {
              GameMode.normal: _ModeLabel('Normal'),
              GameMode.hard: _ModeLabel('Hard'),
              GameMode.endless: _ModeLabel('Endless'),
              GameMode.daily: _ModeLabel('Daily'),
            },
            onValueChanged: (mode) {
              if (mode == null) return;
              HapticFeedback.selectionClick();
              onChanged(mode);
            },
          ),
        ],
      ),
    );
  }
}

class _ModeLabel extends StatelessWidget {
  final String label;

  const _ModeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: GameColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _ShopBody extends StatelessWidget {
  final GameProgress progress;

  const _ShopBody({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _WalletCard(coins: progress.coins),
        const SizedBox(height: 14),
        _CosmeticSection(
          title: 'Ball Skins',
          items: GameProgress.cosmetics
              .where((item) => item.category == CosmeticCategory.ball)
              .toList(),
          progress: progress,
        ),
        const SizedBox(height: 14),
        _CosmeticSection(
          title: 'Trail Effects',
          items: GameProgress.cosmetics
              .where((item) => item.category == CosmeticCategory.trail)
              .toList(),
          progress: progress,
        ),
        const SizedBox(height: 14),
        _CosmeticSection(
          title: 'Orbit Core Skins',
          items: GameProgress.cosmetics
              .where((item) => item.category == CosmeticCategory.core)
              .toList(),
          progress: progress,
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          _GlyphBubble(icon: icon, color: GameColors.electricBlue),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: GameColors.textTertiary,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            activeTrackColor: GameColors.electricBlue,
            onChanged: (next) {
              HapticFeedback.selectionClick();
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _StatPanel({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlyphBubble(icon: PhosphorIconsFill.sparkle, color: tone),
          const SizedBox(height: 18),
          Text(
            label,
            style: const TextStyle(
              color: GameColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              fontFamily: '.SF UI Display',
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final int coins;

  const _WalletCard({required this.coins});

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Row(
        children: [
          const _GlyphBubble(
            icon: PhosphorIconsFill.coins,
            color: GameColors.warning,
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Wallet',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Text(
            '$coins coins',
            style: const TextStyle(
              color: GameColors.warning,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmeticSection extends StatelessWidget {
  final String title;
  final List<CosmeticItem> items;
  final GameProgress progress;

  const _CosmeticSection({
    required this.title,
    required this.items,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 9),
          child: Text(
            title,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        for (final item in items) ...[
          _CosmeticCard(item: item, progress: progress),
          if (item != items.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  final CosmeticItem item;
  final GameProgress progress;

  const _CosmeticCard({required this.item, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = progress.unlockedCosmeticIds.contains(item.id);
    final isEquipped = progress.isCosmeticEquipped(item);
    final canAfford = progress.coins >= item.price;
    final status = isEquipped
        ? 'EQUIPPED'
        : isUnlocked
        ? 'OWNED'
        : '${item.price} C';

    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final changed = await progress.unlockOrEquipCosmetic(item.id);
        if (!changed && context.mounted) {
          HapticFeedback.heavyImpact();
        }
      },
      child: Opacity(
        opacity: isUnlocked || canAfford ? 1 : 0.62,
        child: _PanelCard(
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      item.color.withValues(alpha: 0.95),
                      item.color.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.2),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIconsFill.circle,
                  color: item.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: GameColors.textTertiary,
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _TinyStatus(
                label: status,
                color: isEquipped ? GameColors.blockHp1 : item.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementList extends StatelessWidget {
  final GameProgress progress;

  const _AchievementList({required this.progress});

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          for (final achievement in GameProgress.achievements) ...[
            _AchievementRow(
              achievement: achievement,
              isUnlocked: progress.isAchievementUnlocked(achievement),
            ),
            if (achievement != GameProgress.achievements.last)
              const _SoftDivider(),
          ],
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final AchievementDef achievement;
  final bool isUnlocked;

  const _AchievementRow({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _GlyphBubble(
            icon: isUnlocked
                ? PhosphorIconsFill.sealCheck
                : PhosphorIconsFill.lock,
            color: isUnlocked ? GameColors.blockHp1 : GameColors.textTertiary,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: GameColors.textTertiary,
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _TinyStatus(
            label: isUnlocked
                ? 'DONE'
                : '+${GameProgress.instance.effectiveAchievementReward(achievement)} C',
            color: isUnlocked ? GameColors.blockHp1 : GameColors.warning,
          ),
        ],
      ),
    );
  }
}

class _CalloutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _CalloutCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlyphBubble(icon: icon, color: GameColors.warning),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyStatus extends StatelessWidget {
  final String label;
  final Color color;

  const _TinyStatus({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _GlyphBubble extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _GlyphBubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PanelIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _PanelCard(
        width: 42,
        height: 42,
        padding: EdgeInsets.zero,
        radius: 14,
        child: Icon(icon, color: GameColors.textSecondary, size: 18),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? width;
  final double? height;

  const _PanelCard({
    required this.child,
    this.padding = const EdgeInsets.all(15),
    this.radius = 22,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.surfaceLight.withValues(alpha: 0.52),
                GameColors.surface.withValues(alpha: 0.82),
              ],
            ),
            border: Border.all(
              color: GameColors.border.withValues(alpha: 0.68),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: GameColors.border.withValues(alpha: 0.42),
    );
  }
}

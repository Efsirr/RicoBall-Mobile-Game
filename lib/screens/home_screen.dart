import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../ads/unity_ad_banner.dart';
import '../game/core/constants.dart';
import '../game/save/game_progress.dart';
import '../main.dart';
import 'studio_panel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _StudioBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeight = constraints.maxHeight < 640;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TopChrome(
                            onSettings: () => _pushPanel(
                              context,
                              const StudioPanelScreen(
                                kind: StudioPanelKind.settings,
                              ),
                            ),
                          ),
                          SizedBox(height: compactHeight ? 18 : 46),
                          const _HeroMark(),
                          SizedBox(height: compactHeight ? 18 : 28),
                          const _TitleLockup(),
                          SizedBox(height: compactHeight ? 22 : 34),
                          _ActionCluster(
                            onPlay: () => _pushGame(context),
                            onShop: () => _pushPanel(
                              context,
                              const StudioPanelScreen(
                                kind: StudioPanelKind.shop,
                              ),
                            ),
                            onStats: () => _pushPanel(
                              context,
                              const StudioPanelScreen(
                                kind: StudioPanelKind.stats,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _ModeStrip(),
                          SizedBox(height: compactHeight ? 18 : 34),
                          const _FooterMeta(),
                          const SizedBox(height: 10),
                          const UnityAdBanner(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pushGame(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: const RicochetGameScreen(),
        ),
      ),
    );
  }

  void _pushPanel(BuildContext context, Widget panel) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, animation, _) => SlideTransition(
          position: Tween(begin: const Offset(0.06, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: panel),
        ),
      ),
    );
  }
}

class _StudioBackdrop extends StatelessWidget {
  const _StudioBackdrop();

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
            top: -120,
            left: -80,
            right: -80,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    GameColors.electricBlue.withValues(alpha: 0.28),
                    GameColors.electricBlue.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -120,
            width: 280,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    GameColors.neonCyan.withValues(alpha: 0.12),
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

class _TopChrome extends StatelessWidget {
  final VoidCallback onSettings;

  const _TopChrome({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ChromePill(
          icon: PhosphorIconsFill.lightning,
          label: 'CORE ONLINE',
          color: GameColors.blockHp1,
        ),
        const Spacer(),
        _IconChrome(icon: PhosphorIconsFill.gearSix, onTap: onSettings),
      ],
    );
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Center(
        child: Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                GameColors.electricBlue.withValues(alpha: 0.92),
                GameColors.electricBlue.withValues(alpha: 0.22),
                GameColors.surface.withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.48, 1.0],
            ),
            border: Border.all(
              color: GameColors.textPrimary.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.electricBlue.withValues(alpha: 0.32),
                blurRadius: 46,
                spreadRadius: 4,
              ),
            ],
          ),
          child: CustomPaint(painter: _OrbitLogoPainter()),
        ),
      ),
    );
  }
}

class _OrbitLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitPaint = Paint()
      ..color = GameColors.textPrimary.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.55);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 98, height: 42),
      orbitPaint,
    );
    canvas.rotate(1.1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 98, height: 42),
      orbitPaint..color = GameColors.textPrimary.withValues(alpha: 0.24),
    );
    canvas.restore();

    canvas.drawCircle(
      center,
      16,
      Paint()..color = GameColors.textPrimary.withValues(alpha: 0.92),
    );
    canvas.drawCircle(
      center + const Offset(34, -18),
      6,
      Paint()..color = GameColors.neonCyan,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TitleLockup extends StatelessWidget {
  const _TitleLockup();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'RICOCHET',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GameColors.textPrimary,
            fontSize: 52,
            height: 0.94,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
            fontFamily: '.SF UI Display',
          ),
        ),
        SizedBox(height: 2),
        Text(
          'CORE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GameColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Bend the shot. Break the board.',
          textAlign: TextAlign.center,
          style: TextStyle(
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

class _ActionCluster extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onShop;
  final VoidCallback onStats;

  const _ActionCluster({
    required this.onPlay,
    required this.onShop,
    required this.onStats,
  });

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _PrimaryButton(onPressed: onPlay),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniAction(
                  icon: PhosphorIconsFill.sparkle,
                  title: 'Collection',
                  subtitle: 'Skins',
                  onTap: onShop,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniAction(
                  icon: PhosphorIconsFill.chartBar,
                  title: 'Stats',
                  subtitle: 'Records',
                  onTap: onStats,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PrimaryButton({required this.onPressed});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF36A4FF), GameColors.electricBlue],
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.electricBlue.withValues(
                  alpha: _pressed ? 0.16 : 0.32,
                ),
                blurRadius: _pressed ? 18 : 28,
                offset: Offset(0, _pressed ? 8 : 14),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsFill.play, size: 18, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Start Run',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeStrip extends StatelessWidget {
  const _ModeStrip();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgress.instance,
      builder: (_, _) {
        final progress = GameProgress.instance;
        return Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'MODE',
                value: progress.selectedMode.name.toUpperCase(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(label: 'COINS', value: '${progress.coins}'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: progress.selectedMode == GameMode.daily
                    ? 'DAILY'
                    : 'SEED',
                value: progress.selectedMode == GameMode.daily
                    ? '${progress.dailySeed % 10000}'
                    : 'LIVE',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GameColors.surfaceLight.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GameColors.border.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Icon(icon, color: GameColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GameColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              color: GameColors.textTertiary,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _IconChrome extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconChrome({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: GameColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GameColors.border.withValues(alpha: 0.62)),
        ),
        child: Icon(icon, color: GameColors.textSecondary, size: 19),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: GameColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterMeta extends StatelessWidget {
  const _FooterMeta();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Version 1.0  |  Orbit prototype',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: GameColors.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PremiumCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.surfaceLight.withValues(alpha: 0.58),
                GameColors.surface.withValues(alpha: 0.82),
              ],
            ),
            border: Border.all(
              color: GameColors.border.withValues(alpha: 0.68),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ChromePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChromePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: GameColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GameColors.border.withValues(alpha: 0.62)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/game_on_logo.dart';

// ════════════════════════════════════════════════════════════
// SPLASH SCREEN
// ════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));

  // Logo: fade + very subtle scale (0.82→1.0) — no bitmap-scaling artefacts
  late final Animation<double> _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
  late final Animation<double> _logoScale = Tween<double>(begin: 0.82, end: 1.0)
      .animate(CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)));
  // Glow blooms after the logo lands
  late final Animation<double> _glowA = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOut));
  // Text slides up and fades in last
  late final Animation<double> _txtFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut));
  late final Animation<Offset> _txtSlide =
      Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GameOnBrand.slateDark,
        body: Stack(
          children: [
            // Subtle radial background bloom centred on logo
            AnimatedBuilder(
              animation: _glowA,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.12),
                    radius: 0.85,
                    colors: [
                      GameOnBrand.saffron
                          .withValues(alpha: 0.08 * _glowA.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Logo + wordmark
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo — scale+fade via AnimatedBuilder, no Opacity layer
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, child) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: _GlowingLogo(glowAnimation: _glowA),
                  ),
                  const SizedBox(height: 28),
                  // Wordmark — slide + fade
                  SlideTransition(
                    position: _txtSlide,
                    child: FadeTransition(
                      opacity: _txtFade,
                      child: const Text(
                        'GameOn',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _GlowingLogo extends StatelessWidget {
  final Animation<double> glowAnimation;

  const _GlowingLogo({required this.glowAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (_, child) {
        final g = glowAnimation.value;
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: GameOnBrand.saffron.withValues(alpha: 0.50 * g),
                blurRadius: 72,
                spreadRadius: 12,
              ),
              BoxShadow(
                color: GameOnBrand.saffron.withValues(alpha: 0.20 * g),
                blurRadius: 110,
                spreadRadius: 28,
              ),
            ],
          ),
          child: child,
        );
      },
      child: const GameOnLogo(size: 160),
    );
  }
}

// ════════════════════════════════════════════════════════════
// LOADING SCREEN
// ════════════════════════════════════════════════════════════
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800))
    ..repeat();
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..repeat(reverse: true);
  late final AnimationController _txt = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1700))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _orbit.dispose();
    _pulse.dispose();
    _txt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GameOnBrand.slateDark,
        body: AnimatedBuilder(
          animation: Listenable.merge([_orbit, _pulse, _txt]),
          builder: (_, __) {
            final scale = 0.92 + 0.08 * math.sin(_pulse.value * math.pi);
            final txtOp = 0.30 + 0.65 * _txt.value;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: _OrbitPainter(
                              angle: _orbit.value * 2 * math.pi),
                        ),
                        Transform.scale(
                          scale: scale,
                          child: const GameOnLogo(size: 120),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Opacity(
                    opacity: txtOp,
                    child: const Text(
                      'Loading...',
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

/// Two saffron dots orbiting the logo in opposite directions.
class _OrbitPainter extends CustomPainter {
  final double angle;

  const _OrbitPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const orbitR = 88.0;
    const dotR = 7.0;

    final paint = Paint()
      ..color = GameOnBrand.saffron
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(
      Offset(cx + orbitR * math.cos(angle), cy + orbitR * math.sin(angle)),
      dotR,
      paint,
    );
    canvas.drawCircle(
      Offset(cx + orbitR * math.cos(angle + math.pi),
          cy + orbitR * math.sin(angle + math.pi)),
      dotR,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter o) => o.angle != angle;
}

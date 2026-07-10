import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_on_logo.dart';

// ════════════════════════════════════════════════════════════
// SPLASH SCREEN — "Unison Click" animation
//
// Two halves slide in from opposite corners, land together,
// the whole logo punches up with a saffron glow, and a ring
// pulses outward.  Total ≈ 1.4 s then navigates to '/'.
// ════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Master controller — 1.4 s
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  // ── Half-one: slides from bottom-left ────────────────────
  late final Animation<Offset> _half1Offset =
      Tween<Offset>(begin: const Offset(-90, 44), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.0, 0.52,
                  curve: Curves.easeOutBack)));

  late final Animation<double> _half1Opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 1),
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 84),
  ]).animate(_ctrl);

  late final Animation<double> _half1Rot =
      Tween<double>(begin: -14 * math.pi / 180, end: 0).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.0, 0.52,
                  curve: Curves.easeOutBack)));

  // ── Half-two: slides from top-right ──────────────────────
  late final Animation<Offset> _half2Offset =
      Tween<Offset>(begin: const Offset(90, -44), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.0, 0.52,
                  curve: Curves.easeOutBack)));

  late final Animation<double> _half2Opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 1),
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 84),
  ]).animate(_ctrl);

  late final Animation<double> _half2Rot =
      Tween<double>(begin: -14 * math.pi / 180, end: 0).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.0, 0.52,
                  curve: Curves.easeOutBack)));

  // ── Unison punch: scale + glow after halves land ─────────
  late final Animation<double> _unisonScale = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 66),
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12),
    TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 22),
  ]).animate(_ctrl);

  late final Animation<double> _glowIntensity = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 66),
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12),
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.35)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 22),
  ]).animate(_ctrl);

  // ── Pulse ring ───────────────────────────────────────────
  late final Animation<double> _pulseRadius = Tween<double>(begin: 0.29, end: 0.66)
      .animate(CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.47, 0.85, curve: Curves.easeOut)));

  late final Animation<double> _pulseOpacity = Tween<double>(begin: 0.8, end: 0.0)
      .animate(CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.47, 0.85, curve: Curves.easeOut)));

  late final Animation<double> _pulseStroke =
      Tween<double>(begin: 26, end: 2).animate(CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.47, 0.85, curve: Curves.easeOut)));

  // ── Wordmark ─────────────────────────────────────────────
  late final Animation<double> _txtFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.50, 0.85, curve: Curves.easeOut));

  late final Animation<Offset> _txtSlide =
      Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameOnBrand.slateDark,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          children: [
            // Background radial glow
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.12),
                  radius: 0.85,
                  colors: [
                    GameOnBrand.saffron
                        .withValues(alpha: 0.10 * _glowIntensity.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Logo + wordmark
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated logo
                  Transform.scale(
                    scale: _unisonScale.value,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse ring
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _PulseRingPainter(
                              radius: _pulseRadius.value,
                              opacity: _pulseOpacity.value,
                              strokeWidth: _pulseStroke.value,
                            ),
                          ),
                          // Glow behind logo
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: GameOnBrand.saffron.withValues(
                                      alpha: 0.55 * _glowIntensity.value),
                                  blurRadius: 72,
                                  spreadRadius: 12,
                                ),
                                BoxShadow(
                                  color: GameOnBrand.saffron.withValues(
                                      alpha: 0.22 * _glowIntensity.value),
                                  blurRadius: 110,
                                  spreadRadius: 28,
                                ),
                              ],
                            ),
                          ),
                          // Half one (original path)
                          Transform(
                            transform: Matrix4.identity()
                              ..translateByDouble(
                                  _half1Offset.value.dx, _half1Offset.value.dy, 0, 1)
                              ..rotateZ(_half1Rot.value),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: _half1Opacity.value,
                              child: CustomPaint(
                                size: const Size(160, 160),
                                painter: _LogoHalfPainter(rotated: false),
                              ),
                            ),
                          ),
                          // Half two (180° rotated path)
                          Transform(
                            transform: Matrix4.identity()
                              ..translateByDouble(
                                  _half2Offset.value.dx, _half2Offset.value.dy, 0, 1)
                              ..rotateZ(_half2Rot.value),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: _half2Opacity.value,
                              child: CustomPaint(
                                size: const Size(160, 160),
                                painter: _LogoHalfPainter(rotated: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Wordmark
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
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Pulse ring painter
// ────────────────────────────────────────────────────────────

class _PulseRingPainter extends CustomPainter {
  final double radius; // fraction of half-width
  final double opacity;
  final double strokeWidth;

  const _PulseRingPainter({
    required this.radius,
    required this.opacity,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = radius * size.width;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = GameOnBrand.saffron.withValues(alpha: opacity);
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  @override
  bool shouldRepaint(_PulseRingPainter o) =>
      o.radius != radius || o.opacity != opacity || o.strokeWidth != strokeWidth;
}

// ────────────────────────────────────────────────────────────
// Logo half painter — draws one half of the GameOn logo
// using the exact SVG path data.
//
// The SVG viewBox is 0 0 512 512.  We scale to fit `size`.
// When `rotated` is true the path is rotated 180° around
// the SVG centre (256, 256) — matching `<use …
// transform="rotate(180 256 256)"/>`.
// ────────────────────────────────────────────────────────────

class _LogoHalfPainter extends CustomPainter {
  final bool rotated;

  _LogoHalfPainter({required this.rotated});

  // Parsed once — the path from the SVG.
  static final Path _halfPath = _buildHalfPath();

  static Path _buildHalfPath() {
    // Outer contour
    final p = Path()
      ..moveTo(312.5, 286.1)
      // A 11.5 11.5 0 0 0 313.3 281.9
      ..arcToPoint(const Offset(313.3, 281.9),
          radius: const Radius.circular(11.5), largeArc: false, clockwise: false)
      // A 144.7 144.7 0 0 0 314.8 270.4
      ..arcToPoint(const Offset(314.8, 270.4),
          radius: const Radius.circular(144.7), largeArc: false, clockwise: false)
      ..lineTo(225.7, 270.4)
      ..lineTo(225.7, 278.3)
      // A 24.5 24.5 0 0 1 201.2 302.8
      ..arcToPoint(const Offset(201.2, 302.8),
          radius: const Radius.circular(24.5), largeArc: false, clockwise: true)
      // A 24.5 24.5 0 0 1 176.6 278.3
      ..arcToPoint(const Offset(176.6, 278.3),
          radius: const Radius.circular(24.5), largeArc: false, clockwise: true)
      ..lineTo(163.1, 278.3)
      ..lineTo(163.1, 112.8)
      // A 144.7 144.7 0 0 0 61.1 351.8
      ..arcToPoint(const Offset(61.1, 351.8),
          radius: const Radius.circular(144.7), largeArc: false, clockwise: false)
      // A 144.7 144.7 0 0 0 312.5 286.1
      ..arcToPoint(const Offset(312.5, 286.1),
          radius: const Radius.circular(144.7), largeArc: false, clockwise: false)
      ..close();

    // Inner cutout (the hole)
    p.moveTo(252.2, 293.5);
    p.lineTo(276.2, 293.5);
    // A 106.7 106.7 0 0 1 65.8 296.8
    p.arcToPoint(const Offset(65.8, 296.8),
        radius: const Radius.circular(106.7), largeArc: false, clockwise: true);
    p.lineTo(151.2, 296.8);
    // A 53.2 53.2 0 0 0 252.2 293.5
    p.arcToPoint(const Offset(252.2, 293.5),
        radius: const Radius.circular(53.2), largeArc: false, clockwise: false);
    p.close();

    p.fillType = PathFillType.evenOdd;
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512;
    canvas.save();
    canvas.scale(scale, scale);
    if (rotated) {
      canvas.translate(256, 256);
      canvas.rotate(math.pi);
      canvas.translate(-256, -256);
    }
    canvas.drawPath(_halfPath, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoHalfPainter o) => o.rotated != rotated;
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
                    child: Text(
                      AppLocalizations.of(context)?.loading ?? 'Loading...',
                      style: const TextStyle(
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

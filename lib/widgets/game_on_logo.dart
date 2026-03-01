import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameOnLogo extends StatelessWidget {
  final double size;
  final Color color;

  const GameOnLogo({
    super.key,
    this.size = 100.0,
    this.color = const Color(0xFFFDBA30), // Saffron
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GameOnLogoPainter(color: color),
      ),
    );
  }
}

class _GameOnLogoPainter extends CustomPainter {
  final Color color;

  _GameOnLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    final double r = size.width * 0.40;
    const double arcAngle = 130 * (math.pi / 180);
    const double startAngleOffset = 115 * (math.pi / 180);

    canvas.translate(size.width / 2, size.height / 2);

    // Left arc ("C")
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      startAngleOffset,
      arcAngle,
      false,
      paint,
    );

    // Right arc (interlocked, mirrored)
    canvas.rotate(math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      startAngleOffset,
      arcAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GameOnLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Logo inside a rounded square background — use on splash / login.
class GameOnLogoContainer extends StatelessWidget {
  final double size;

  const GameOnLogoContainer({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: GameOnBrand.slateDark,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: GameOnBrand.saffron.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: GameOnLogo(size: size * 0.65),
      ),
    );
  }
}

/// Central brand colour tokens.
class GameOnBrand {
  GameOnBrand._();

  static const Color saffron   = Color(0xFFFDBA30);
  static const Color slateDark = Color(0xFF1E293B);
  static const Color slateLight = Color(0xFF334155); // hover / card surface
  static const Color onSaffron = Color(0xFF1E293B);  // text on saffron buttons
}

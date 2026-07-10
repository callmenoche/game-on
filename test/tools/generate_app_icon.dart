// Brand asset generator — NOT a regular test (no _test suffix, so it is
// skipped by plain `flutter test`). Run explicitly to regenerate the launcher
// icon sources from the vector logo path, then re-run flutter_launcher_icons:
//
//   flutter test test/tools/generate_app_icon.dart
//   dart run flutter_launcher_icons
//
// Outputs (1024×1024):
//   assets/icons/app_icon.png            – slate background + saffron logo
//   assets/icons/app_icon_foreground.png – transparent, smaller logo
//                                          (Android adaptive-icon safe zone)

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _slate = Color(0xFF1E293B);
const _saffron = Color(0xFFF5C542);

/// One half of the GameOn logo — exact SVG path data from
/// assets/icons/logo.svg (viewBox 0 0 512 512). Same data as
/// _LogoHalfPainter in lib/screens/splash_screen.dart.
Path _buildHalfPath() {
  final p = Path()
    ..moveTo(312.5, 286.1)
    ..arcToPoint(const Offset(313.3, 281.9),
        radius: const Radius.circular(11.5), clockwise: false)
    ..arcToPoint(const Offset(314.8, 270.4),
        radius: const Radius.circular(144.7), clockwise: false)
    ..lineTo(225.7, 270.4)
    ..lineTo(225.7, 278.3)
    ..arcToPoint(const Offset(201.2, 302.8),
        radius: const Radius.circular(24.5))
    ..arcToPoint(const Offset(176.6, 278.3),
        radius: const Radius.circular(24.5))
    ..lineTo(163.1, 278.3)
    ..lineTo(163.1, 112.8)
    ..arcToPoint(const Offset(61.1, 351.8),
        radius: const Radius.circular(144.7), clockwise: false)
    ..arcToPoint(const Offset(312.5, 286.1),
        radius: const Radius.circular(144.7), clockwise: false)
    ..close()
    ..moveTo(252.2, 293.5)
    ..lineTo(276.2, 293.5)
    ..arcToPoint(const Offset(65.8, 296.8),
        radius: const Radius.circular(106.7))
    ..lineTo(151.2, 296.8)
    ..arcToPoint(const Offset(252.2, 293.5),
        radius: const Radius.circular(53.2), clockwise: false)
    ..close();
  p.fillType = PathFillType.evenOdd;
  return p;
}

Future<void> _render({
  required String outPath,
  required int size,
  Color? background,
  // How much of the canvas the 512-unit viewBox spans (the glyph itself
  // fills ~76% of the viewBox width).
  required double viewBoxFraction,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();

  if (background != null) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = background);
  }

  final scale = s * viewBoxFraction / 512;
  canvas.translate((s - 512 * scale) / 2, (s - 512 * scale) / 2);
  canvas.scale(scale);

  final paint = Paint()
    ..color = _saffron
    ..isAntiAlias = true;
  final half = _buildHalfPath();
  canvas.drawPath(half, paint);
  canvas.save();
  canvas.translate(256, 256);
  canvas.rotate(math.pi);
  canvas.translate(-256, -256);
  canvas.drawPath(half, paint);
  canvas.restore();

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(outPath).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('generate launcher icon PNGs', () async {
    await _render(
      outPath: 'assets/icons/app_icon.png',
      size: 1024,
      background: _slate,
      viewBoxFraction: 0.85,
    );
    await _render(
      outPath: 'assets/icons/app_icon_foreground.png',
      size: 1024,
      viewBoxFraction: 0.58,
    );
  });
}

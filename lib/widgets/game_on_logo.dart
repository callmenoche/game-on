import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// GameOn logo — resolution-independent SVG asset.
///
/// Defaults to white (for dark backgrounds).
/// Pass [color] to tint the logo (e.g. black for light backgrounds).
class GameOnLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const GameOnLogo({super.key, this.size = 200, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/gameon-logo-white.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Rounded-square container with slate background + saffron glow.
/// Use on the login screen and splash.
class GameOnLogoContainer extends StatelessWidget {
  final double size;

  const GameOnLogoContainer({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF243044), // slightly lighter than pure slateDark
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          // Inner warm glow
          BoxShadow(
            color: GameOnBrand.saffron.withValues(alpha: 0.45),
            blurRadius: size * 0.45,
            spreadRadius: size * 0.01,
          ),
          // Outer wide bloom
          BoxShadow(
            color: GameOnBrand.saffron.withValues(alpha: 0.18),
            blurRadius: size * 1.0,
            spreadRadius: size * 0.04,
          ),
        ],
      ),
      child: Center(
        child: GameOnLogo(size: size * 0.72),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Central brand colour tokens — import this wherever you need brand colours.
class GameOnBrand {
  GameOnBrand._();

  static const Color saffron    = Color(0xFFF5C542); // primary / logo (warmer gold)
  static const Color slateDark  = Color(0xFF1E293B); // scaffold / bg
  static const Color slateCard  = Color(0xFF243044); // card / surface
  static const Color slateLight = Color(0xFF334155); // hover / border
  static const Color onSaffron  = Color(0xFF1E293B); // text on saffron buttons
}

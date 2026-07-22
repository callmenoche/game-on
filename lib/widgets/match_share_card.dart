import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/match.dart';
import 'game_on_logo.dart';

/// Base web URL for shareable match links — TODO: swap for a custom domain
/// once one exists (see docs/universal-links-setup.md), same placeholder
/// already used for guest-invite links in match_detail_screen.dart.
const _shareBaseUrl = 'https://gameon-brown.vercel.app';

String matchShareLink(Match match) => '$_shareBaseUrl/match/${match.id}';

/// Fixed-size (9:16, Instagram Story ratio) branded card for [match].
/// Always dark-themed regardless of the app's theme, like the splash/login
/// screens — this is a standalone image, not a themed in-app surface. The
/// share link is printed as plain text at the bottom so it's usable even
/// when shared somewhere that strips the accompanying caption (e.g. an
/// Instagram Story only carries the image itself).
class MatchShareCard extends StatelessWidget {
  final Match match;
  final String locale;
  const MatchShareCard({super.key, required this.match, required this.locale});

  static const double width = 1080;
  static const double height = 1920;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sportColor = match.sportType.color;
    final link = matchShareLink(match);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GameOnBrand.slateDark,
            Color.lerp(GameOnBrand.slateDark, sportColor, 0.35)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -140,
            bottom: 40,
            child: Transform.rotate(
              angle: -math.pi / 14,
              child: PhosphorIcon(
                match.sportType.icon,
                size: 640,
                color: sportColor.withValues(alpha: 0.14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 96, 72, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    GameOnLogoContainer(size: 76),
                    SizedBox(width: 20),
                    Text(
                      'GameOn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: sportColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: sportColor, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(match.sportType.icon,
                          size: 28, color: sportColor),
                      const SizedBox(width: 10),
                      Text(
                        match.sportType.l10nLabel(context).toUpperCase(),
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  (match.title != null && match.title!.isNotEmpty)
                      ? match.title!
                      : match.sportType.l10nLabel(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 28),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  text: DateFormat('EEEE d MMMM', locale).format(match.dateTime),
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  text: DateFormat('HH:mm').format(match.dateTime),
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  text: match.locationName,
                  maxLines: 2,
                ),
                if (match.creatorUsername != null) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.person_rounded,
                    text: '@${match.creatorUsername}',
                  ),
                ],
                const Spacer(),
                Container(height: 2, color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(height: 24),
                Text(
                  l.joinOnGameOn,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  link,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;
  const _InfoRow({required this.icon, required this.text, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30, color: GameOnBrand.saffron),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders [match]'s [MatchShareCard] off-screen and returns it as PNG bytes.
Future<Uint8List> renderMatchShareCardPng(
    BuildContext context, Match match) async {
  final locale = Localizations.localeOf(context).languageCode;
  final repaintKey = GlobalKey();
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -MatchShareCard.width,
      top: 0,
      child: RepaintBoundary(
        key: repaintKey,
        child: MatchShareCard(match: match, locale: locale),
      ),
    ),
  );
  overlay.insert(entry);

  try {
    // Two frames: the first lays the widget out, the second guarantees the
    // paint from that layout has actually happened before we capture it.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}

/// Generates the match share card and opens the native share sheet with it —
/// the link is baked into the image itself so it survives being shared
/// somewhere that only keeps the image (e.g. an Instagram Story).
Future<void> shareMatchCard(BuildContext context, Match match) async {
  final l = AppLocalizations.of(context)!;
  final sportLabel = match.sportType.l10nLabel(context);
  final caption = l.shareMatchCardText(sportLabel, matchShareLink(match));
  try {
    final bytes = await renderMatchShareCardPng(context, match);
    if (!context.mounted) return;
    final file = XFile.fromData(bytes,
        name: 'gameon-match.png', mimeType: 'image/png');
    await Share.shareXFiles([file],
        text: caption, subject: l.shareMatchCardSubject);
  } catch (_) {
    if (!context.mounted) return;
    await Share.share(caption, subject: l.shareMatchCardSubject);
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import 'game_on_logo.dart';

// ─── Stats strip ──────────────────────────────────────────────────────────────

/// Two-tile strip: Last 7 days + Top sport (up to 3 tied, each in sport color).
class StatsStrip extends StatelessWidget {
  final int lastWeekCount;
  final int lastWeekMins;
  final List<SportType> topSports;

  const StatsStrip({
    super.key,
    required this.lastWeekCount,
    required this.lastWeekMins,
    required this.topSports,
  });

  String _timeLabel(int mins) {
    if (mins == 0) return '—';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.clockCountdown,
            label: l.last7Days,
            value: '$lastWeekCount',
            sub: _timeLabel(lastWeekMins),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.trophy,
            label: l.topSport,
            value: '—',
            sub: l.noneYet,
            topSports: topSports,
          ),
        ),
      ],
    );
  }
}

// ─── Mini stat tile ───────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final String value;
  final String sub;
  final List<SportType>? topSports;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.topSports,
  });

  @override
  Widget build(BuildContext context) {
    final sports = topSports;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, size: 13, color: GameOnBrand.saffron),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (sports != null && sports.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: sports
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: PhosphorIcon(
                          s.icon,
                          size: sports.length == 1 ? 24 : 20,
                          color: s.color,
                        ),
                      ))
                  .toList(),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          Text(
            sports != null && sports.isNotEmpty
                ? (sports.length == 1
                    ? sports.first.l10nLabel(context)
                    : AppLocalizations.of(context)!.nTied(sports.length))
                : sub,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Sport donut chart ────────────────────────────────────────────────────────

class SportDonutChart extends StatelessWidget {
  final Map<SportType, int> counts;
  const SportDonutChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = counts.values.fold(0, (a, b) => a + b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(130, 130),
                painter: _DonutPainter(counts: counts, total: total),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.total,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: sorted.map((e) {
              final pct = total > 0 ? (e.value / total * 100).round() : 0;
              final color = e.key.color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: [
                          PhosphorIcon(e.key.icon, size: 12, color: color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.key.l10nLabel(context),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${e.value} ($pct%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<SportType, int> counts;
  final int total;

  const _DonutPainter({required this.counts, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.55;
    final arcR = (outerR + innerR) / 2;
    final strokeW = outerR - innerR;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: arcR);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    double start = -pi / 2;
    for (final entry in counts.entries) {
      final sweep = 2 * pi * entry.value / total;
      paint.color = entry.key.color;
      canvas.drawArc(rect, start, sweep - 0.04, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.counts != counts || old.total != total;
}

// ─── Top sports computation helper ───────────────────────────────────────────

/// Compute top sports from [history], sorted by count desc then last activity
/// desc. Returns all sports tied at the top count, max 3.
List<SportType> computeTopSports(List<Match> history) {
  final sportCounts = <SportType, int>{};
  final lastActivity = <SportType, DateTime>{};
  for (final m in history) {
    sportCounts[m.sportType] = (sportCounts[m.sportType] ?? 0) + 1;
    final prev = lastActivity[m.sportType];
    if (prev == null || m.dateTime.isAfter(prev)) {
      lastActivity[m.sportType] = m.dateTime;
    }
  }
  if (sportCounts.isEmpty) return [];
  final sorted = sportCounts.entries.toList()
    ..sort((a, b) {
      if (b.value != a.value) return b.value.compareTo(a.value);
      final aDate = lastActivity[a.key] ?? DateTime(0);
      final bDate = lastActivity[b.key] ?? DateTime(0);
      return bDate.compareTo(aDate);
    });
  final maxCount = sorted.first.value;
  return sorted
      .where((e) => e.value == maxCount)
      .map((e) => e.key)
      .toList();
}

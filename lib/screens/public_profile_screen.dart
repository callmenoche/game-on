import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../models/profile.dart';
import '../services/match_service.dart';
import '../services/profile_service.dart';
import '../widgets/game_on_logo.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _profileService = ProfileService();
  final _matchService   = MatchService();

  Profile? _profile;
  List<Match> _history = [];
  List<Match> _upcoming = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _profileService.fetchProfile(widget.userId),
        _matchService.fetchUserMatchHistory(widget.userId),
        _matchService.fetchUserUpcomingMatches(widget.userId),
      ]);
      setState(() {
        _profile  = results[0] as Profile;
        _history  = results[1] as List<Match>;
        _upcoming = results[2] as List<Match>;
        _loading  = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load profile';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _profile?.username ?? AppLocalizations.of(context)!.player,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: GameOnBrand.saffron))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5))))
              : _ProfileBody(profile: _profile!, history: _history, upcoming: _upcoming),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Profile profile;
  final List<Match> history;
  final List<Match> upcoming;

  const _ProfileBody({required this.profile, required this.history, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    // ── Derived stats ────────────────────────────────────────────────────────
    final sportCounts = <SportType, int>{};
    for (final m in history) {
      sportCounts[m.sportType] = (sportCounts[m.sportType] ?? 0) + 1;
    }
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final lastWeek =
        history.where((m) => m.dateTime.isAfter(sevenDaysAgo)).toList();
    final lastWeekMins = lastWeek.fold(0, (s, m) => s + m.durationMinutes);
    SportType? topSport = sportCounts.isEmpty
        ? null
        : sportCounts.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;

    final initial = profile.username.isNotEmpty
        ? profile.username[0].toUpperCase()
        : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + username + bio + sport icons ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipOval(
                  child: profile.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: profile.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              _InitialsAvatar(initial: initial),
                          errorWidget: (_, __, ___) =>
                              _InitialsAvatar(initial: initial),
                        )
                      : _InitialsAvatar(initial: initial),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    if (profile.bio != null && profile.bio!.isNotEmpty)
                      Text(
                        profile.bio!,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.55)),
                      ),
                    if (profile.favoriteSports.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 6,
                          children: profile.favoriteSports.map((s) {
                            final sport = SportType.fromString(s);
                            return Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: sport.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PhosphorIcon(
                                  sport.icon, size: 16, color: sport.color),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stats strip ────────────────────────────────────────────────────
          _StatsStrip(
            totalCount: history.length,
            lastWeekCount: lastWeek.length,
            lastWeekMins: lastWeekMins,
            topSport: topSport,
          ),

          // ── Activity breakdown (donut) ─────────────────────────────────────
          if (sportCounts.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionLabel(AppLocalizations.of(context)!.activityBreakdown),
            const SizedBox(height: 14),
            _SportDonutChart(counts: sportCounts),
          ],

          // ── Upcoming matches ───────────────────────────────────────────────
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionLabel(AppLocalizations.of(context)!.upcomingMatches),
            const SizedBox(height: 12),
            ...upcoming.take(5).map((m) => _HistoryRow(match: m)),
          ],

          // ── Recent matches ─────────────────────────────────────────────────
          if (history.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionLabel(AppLocalizations.of(context)!.recentMatches),
            const SizedBox(height: 12),
            ...history.take(5).map((m) => _HistoryRow(match: m)),
          ],
        ],
      ),
    );
  }
}

// ─── Initials avatar ──────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  final String initial;
  const _InitialsAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [GameOnBrand.saffron, Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: GameOnBrand.slateDark,
          ),
        ),
      ),
    );
  }
}

// ─── Stats strip ──────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int totalCount;
  final int lastWeekCount;
  final int lastWeekMins;
  final SportType? topSport;

  const _StatsStrip({
    required this.totalCount,
    required this.lastWeekCount,
    required this.lastWeekMins,
    required this.topSport,
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
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.chartBar,
            label: AppLocalizations.of(context)!.allTime,
            value: '$totalCount',
            sub: AppLocalizations.of(context)!.activities,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.clockCountdown,
            label: AppLocalizations.of(context)!.last7Days,
            value: '$lastWeekCount',
            sub: _timeLabel(lastWeekMins),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.trophy,
            label: AppLocalizations.of(context)!.topSport,
            value: '—',
            sub: topSport?.l10nLabel(context) ?? AppLocalizations.of(context)!.noneYet,
            sportIcon: topSport?.icon,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final String value;
  final String sub;
  final PhosphorIconData? sportIcon;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.sportIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
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
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (sportIcon != null)
            PhosphorIcon(sportIcon!, size: 26, color: GameOnBrand.saffron)
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
            sub,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity donut chart ─────────────────────────────────────────────────────

class _SportDonutChart extends StatelessWidget {
  final Map<SportType, int> counts;
  const _SportDonutChart({required this.counts});

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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.total,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
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
              final pct =
                  total > 0 ? (e.value / total * 100).round() : 0;
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
                        color: Colors.white.withValues(alpha: 0.5),
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

// ─── History row ──────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  final Match match;
  const _HistoryRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/match/${match.id}'),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(
            left: BorderSide(color: match.sportType.color, width: 3)),
      ),
      child: Row(
        children: [
          PhosphorIcon(match.sportType.icon, size: 22,
              color: match.sportType.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.sportType.l10nLabel(context),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(
                  match.locationName,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('d MMM', Localizations.localeOf(context).languageCode).format(match.dateTime),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                DateFormat('HH:mm').format(match.dateTime),
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}

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
import '../widgets/profile_stats.dart';

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
        _error = AppLocalizations.of(context)!.errorCouldNotLoadProfile;
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
    final topSports = computeTopSports(history);

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
                    _AgeGenderLine(profile: profile),
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
          StatsStrip(
            lastWeekCount: lastWeek.length,
            lastWeekMins: lastWeekMins,
            topSports: topSports,
          ),

          // ── Activity breakdown (donut) ─────────────────────────────────────
          if (sportCounts.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionLabel(AppLocalizations.of(context)!.activityBreakdown),
            const SizedBox(height: 14),
            SportDonutChart(counts: sportCounts),
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

// ─── Age / gender display line ────────────────────────────────────────────────

class _AgeGenderLine extends StatelessWidget {
  final Profile profile;
  const _AgeGenderLine({required this.profile});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (profile.showAge && profile.age != null) parts.add('${profile.age}');
    if (profile.showGender && profile.gender != null) parts.add(profile.gender!);
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        parts.join(' · '),
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.4),
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

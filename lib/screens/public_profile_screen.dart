import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../models/match.dart';
import '../models/profile.dart';
import '../providers/group_provider.dart';
import '../providers/moderation_provider.dart';
import '../services/group_service.dart';
import '../services/match_service.dart';
import '../services/profile_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/game_on_logo.dart';
import '../widgets/profile_highlights.dart';
import '../widgets/report_sheet.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _profileService = ProfileService();
  final _matchService   = MatchService();
  final _groupService   = GroupService();

  Profile? _profile;
  List<Match> _history = [];
  List<Match> _upcoming = [];
  List<Group> _groups = [];
  List<CoPlayer> _coPlayers = [];
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
        _matchService.fetchTopCoPlayers(widget.userId),
        _groupService.fetchGroupsForUser(widget.userId),
      ]);
      setState(() {
        _profile    = results[0] as Profile;
        _history    = results[1] as List<Match>;
        _upcoming   = results[2] as List<Match>;
        _coPlayers  = results[3] as List<CoPlayer>;
        _groups     = results[4] as List<Group>;
        _loading    = false;
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
        actions: [
          _ModerationMenu(userId: widget.userId),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: GameOnBrand.saffron))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))))
              : _ProfileBody(
                  profile: _profile!,
                  history: _history,
                  upcoming: _upcoming,
                  groups: _groups,
                  coPlayers: _coPlayers,
                ),
    );
  }
}

// ─── Report / block menu ─────────────────────────────────────────────────

class _ModerationMenu extends StatelessWidget {
  final String userId;
  const _ModerationMenu({required this.userId});

  Future<void> _confirmBlock(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final moderation = context.read<ModerationProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color,
        title: Text(l.blockUser,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(l.blockUserBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.block),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await moderation.blockUser(userId);
    if (context.mounted && ok) showSuccessSnackBar(context, l.userBlocked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isBlocked = context.watch<ModerationProvider>().isBlocked(userId);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) async {
        switch (value) {
          case 'report':
            await showReportSheet(context, reportedUserId: userId);
          case 'block':
            await _confirmBlock(context);
          case 'unblock':
            final ok =
                await context.read<ModerationProvider>().unblockUser(userId);
            if (context.mounted && ok) {
              showSuccessSnackBar(context, l.userUnblocked);
            }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 18, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(l.reportUser),
            ],
          ),
        ),
        PopupMenuItem(
          value: isBlocked ? 'unblock' : 'block',
          child: Row(
            children: [
              Icon(isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                  size: 18, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(isBlocked ? l.unblockUser : l.blockUser),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Profile profile;
  final List<Match> history;
  final List<Match> upcoming;
  final List<Group> groups;
  final List<CoPlayer> coPlayers;

  const _ProfileBody({
    required this.profile,
    required this.history,
    required this.upcoming,
    required this.groups,
    required this.coPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // ── Derived stats ────────────────────────────────────────────────────────
    final sportCounts = <SportType, int>{};
    for (final m in history) {
      sportCounts[m.sportType] = (sportCounts[m.sportType] ?? 0) + 1;
    }

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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
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

          // ── Recent activities ────────────────────────────────────────────────
          ProfileSectionLabel(AppLocalizations.of(context)!.recentMatches),
          const SizedBox(height: 12),
          ActivityStrip(
            matches: history.take(3).toList(),
            emptyLabel: AppLocalizations.of(context)!.noActivityYet,
          ),
          const SizedBox(height: 24),

          // ── Upcoming activities ───────────────────────────────────────────────
          ProfileSectionLabel(AppLocalizations.of(context)!.upcomingMatches),
          const SizedBox(height: 12),
          ActivityStrip(
            matches: upcoming.take(3).toList(),
            emptyLabel: AppLocalizations.of(context)!.noActivityYet,
          ),
          const SizedBox(height: 24),

          // ── Top sports ─────────────────────────────────────────────────────
          ProfileSectionLabel(AppLocalizations.of(context)!.topSports),
          const SizedBox(height: 12),
          TopSportsBars(counts: sportCounts),
          const SizedBox(height: 24),

          // ── Groups ─────────────────────────────────────────────────────────
          ProfileSectionLabel(AppLocalizations.of(context)!.groupsTitle),
          const SizedBox(height: 12),
          ProfileGroupsStrip(
            groups: groups,
            isMember: context.watch<GroupProvider>().isMember,
          ),
          const SizedBox(height: 24),

          // ── Frequent teammates ─────────────────────────────────────────────
          ProfileSectionLabel(AppLocalizations.of(context)!.frequentTeammates),
          const SizedBox(height: 12),
          TopCoPlayersStrip(players: coPlayers),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}


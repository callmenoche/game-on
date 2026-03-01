import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/match_participant.dart';
import '../providers/match_provider.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';
import '../widgets/game_on_logo.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _service = MatchService();
  late final Stream<Match> _matchStream;
  late final Stream<List<MatchParticipant>> _participantsStream;

  @override
  void initState() {
    super.initState();
    _matchStream = _service.watchMatch(widget.matchId);
    _participantsStream = _service.watchParticipants(widget.matchId);
  }

  Future<void> _confirmCancel(BuildContext context, Match match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel match?'),
        content: const Text(
            'All participants will lose their spot. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Cancel match'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _service.cancelMatch(match.id);
      // ignore: use_build_context_synchronously
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Match>(
      stream: _matchStream,
      builder: (context, matchSnap) {
        if (!matchSnap.hasData) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: GameOnBrand.saffron),
            ),
          );
        }

        final match = matchSnap.data!;
        final currentUserId = SupabaseService.currentUser?.id;
        final isCreator = match.creatorId == currentUserId;
        final isJoined = context.watch<MatchProvider>().isJoined(match.id);

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Row(
              children: [
                Text(match.sportType.emoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(match.sportType.label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            actions: [
              if (isCreator && match.status == MatchStatus.open)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  color: Colors.redAccent,
                  tooltip: 'Cancel match',
                  onPressed: () => _confirmCancel(context, match),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(match: match),
                const SizedBox(height: 28),
                const _SectionLabel('Players'),
                const SizedBox(height: 12),
                StreamBuilder<List<MatchParticipant>>(
                  stream: _participantsStream,
                  builder: (context, partSnap) {
                    if (!partSnap.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              color: GameOnBrand.saffron),
                        ),
                      );
                    }
                    return _ParticipantsList(
                      participants: partSnap.data!,
                      service: _service,
                      creatorId: match.creatorId,
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: _ActionBar(
            match: match,
            isJoined: isJoined,
            isCreator: isCreator,
            onJoin: () => context.read<MatchProvider>().joinMatch(match.id),
            onLeave: () => context.read<MatchProvider>().leaveMatch(match.id),
          ),
        );
      },
    );
  }
}

// ─── Hero card ─────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final Match match;
  const _HeroCard({required this.match});

  Color get _sportColor => switch (match.sportType) {
        SportType.padel => const Color(0xFF00C2A8),
        SportType.football => const Color(0xFF4CAF50),
        SportType.basketball => const Color(0xFFFF6B2B),
        SportType.tennis => const Color(0xFFD4E157),
        SportType.running => const Color(0xFF42A5F5),
        SportType.cycling => const Color(0xFFAB47BC),
        SportType.other => GameOnBrand.saffron,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: _sportColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + skill badges
          Row(
            children: [
              _StatusChip(match.status),
              const SizedBox(width: 8),
              _SkillChip(match.skillLevel),
            ],
          ),
          const SizedBox(height: 16),
          // Location
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: GameOnBrand.saffron),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  match.locationName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date/time
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, d MMMM  •  HH:mm').format(match.dateTime),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SpotsRow(match: match),
        ],
      ),
    );
  }
}

// ─── Spots row ─────────────────────────────────────────────────────────────

class _SpotsRow extends StatelessWidget {
  final Match match;
  const _SpotsRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final taken = match.spotsTaken;
    final total = match.totalSpots;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$taken / $total players',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(
            total,
            (i) => Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < taken
                    ? GameOnBrand.saffron
                    : GameOnBrand.saffron.withValues(alpha: 0.18),
                border: Border.all(
                    color: GameOnBrand.saffron.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Participants list ─────────────────────────────────────────────────────

class _ParticipantsList extends StatefulWidget {
  final List<MatchParticipant> participants;
  final MatchService service;
  final String creatorId;

  const _ParticipantsList({
    required this.participants,
    required this.service,
    required this.creatorId,
  });

  @override
  State<_ParticipantsList> createState() => _ParticipantsListState();
}

class _ParticipantsListState extends State<_ParticipantsList> {
  Map<String, String> _usernames = {};

  @override
  void initState() {
    super.initState();
    _fetchProfiles(widget.participants);
  }

  @override
  void didUpdateWidget(_ParticipantsList old) {
    super.didUpdateWidget(old);
    final oldIds = old.participants.map((p) => p.userId).toSet();
    final newIds = widget.participants.map((p) => p.userId).toSet();
    if (!oldIds.containsAll(newIds) || !newIds.containsAll(oldIds)) {
      _fetchProfiles(widget.participants);
    }
  }

  Future<void> _fetchProfiles(List<MatchParticipant> participants) async {
    final ids = participants.map((p) => p.userId).toList();
    if (ids.isEmpty) return;
    final map = await widget.service.fetchProfiles(ids);
    if (mounted) setState(() => _usernames = map);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.participants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No players yet',
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Column(
      children: widget.participants.map((p) {
        final name = _usernames[p.userId] ?? '…';
        final isCreator = p.userId == widget.creatorId;
        final initial =
            (name.isNotEmpty && name != '…') ? name[0].toUpperCase() : '?';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: GameOnBrand.slateCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: GameOnBrand.saffron.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: GameOnBrand.saffron,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              if (isCreator)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: GameOnBrand.saffron.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Host',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: GameOnBrand.saffron,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Bottom action bar ─────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final Match match;
  final bool isJoined;
  final bool isCreator;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _ActionBar({
    required this.match,
    required this.isJoined,
    required this.isCreator,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (match.status == MatchStatus.cancelled) {
      child = Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Match cancelled',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.redAccent),
        ),
      );
    } else if (isCreator) {
      child = Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: GameOnBrand.slateCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "You're the host ⚡",
          style: TextStyle(
              fontWeight: FontWeight.w700, color: GameOnBrand.saffron),
        ),
      );
    } else if (isJoined) {
      child = OutlinedButton(
        onPressed: onLeave,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: GameOnBrand.saffron),
          foregroundColor: GameOnBrand.saffron,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Leave Match',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );
    } else {
      child = FilledButton(
        onPressed: match.isFull ? null : onJoin,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: GameOnBrand.saffron,
          foregroundColor: GameOnBrand.slateDark,
          disabledBackgroundColor:
              GameOnBrand.saffron.withValues(alpha: 0.25),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          match.isFull ? 'Match is full' : 'Join Match',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: child,
      ),
    );
  }
}

// ─── Shared helper widgets ─────────────────────────────────────────────────

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

class _StatusChip extends StatelessWidget {
  final MatchStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      MatchStatus.open => (GameOnBrand.saffron, 'OPEN'),
      MatchStatus.full => (Colors.redAccent, 'FULL'),
      MatchStatus.cancelled => (Colors.grey, 'CANCELLED'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillLevel level;
  const _SkillChip(this.level);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(level.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            level.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: level.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

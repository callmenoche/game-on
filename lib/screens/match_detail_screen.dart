import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
                      matchId: match.id,
                      creatorId: match.creatorId,
                      currentUserId: currentUserId ?? '',
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
  final String matchId;
  final String creatorId;
  final String currentUserId;

  const _ParticipantsList({
    required this.participants,
    required this.service,
    required this.matchId,
    required this.creatorId,
    required this.currentUserId,
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
    // Compare non-null userIds to detect profile changes
    final oldIds = old.participants
        .map((p) => p.userId)
        .whereType<String>()
        .toSet();
    final newIds = widget.participants
        .map((p) => p.userId)
        .whereType<String>()
        .toSet();
    if (!oldIds.containsAll(newIds) || !newIds.containsAll(oldIds)) {
      _fetchProfiles(widget.participants);
    }
  }

  Future<void> _fetchProfiles(List<MatchParticipant> participants) async {
    final ids = participants
        .map((p) => p.userId)
        .whereType<String>()
        .toList();
    if (ids.isEmpty) return;
    final map = await widget.service.fetchProfiles(ids);
    if (mounted) setState(() => _usernames = map);
  }

  Future<void> _showShareSheet(MatchParticipant guest) async {
    final code = guest.guestClaimToken ?? '';
    final text = 'Join my GameOn match! Use claim code: $code';
    // Copy to clipboard as a convenience
    await Clipboard.setData(ClipboardData(text: code));
    try {
      await Share.share(text);
    } catch (_) {
      // Share sheet unavailable — clipboard fallback already done
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code copied: $code'),
            backgroundColor: GameOnBrand.slateCard,
          ),
        );
      }
    }
  }

  Future<void> _showClaimDialog(BuildContext context) async {
    final codeController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Claim a spot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the claim code shared by the host.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 3),
              decoration: const InputDecoration(
                hintText: 'XXXXXXXX',
                prefixIcon: Icon(Icons.key_rounded, color: GameOnBrand.saffron),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: GameOnBrand.saffron,
                  foregroundColor: GameOnBrand.slateDark,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final code = codeController.text.trim().toUpperCase();
      if (code.isEmpty) return;
      // ignore: use_build_context_synchronously
      final ok = await context
          .read<MatchProvider>()
          .claimGuestSpot(widget.matchId, code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Spot claimed!' : 'Invalid or already used.'),
            backgroundColor: ok ? GameOnBrand.saffron : Colors.redAccent,
          ),
        );
      }
    }
    codeController.dispose();
  }

  Future<void> _confirmRemoveGuest(MatchParticipant guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove guest?'),
        content: const Text('This guest slot will be freed up.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.service.removeGuestSpot(guest.id);
    }
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

    final isHost = widget.currentUserId == widget.creatorId;

    return Column(
      children: widget.participants.map((p) {
        final isGuest = p.isGuest && p.userId == null; // unclaimed guest
        final name = isGuest
            ? (p.guestName ?? 'Guest')
            : (_usernames[p.userId] ?? '…');
        final isCreator = p.userId == widget.creatorId;
        final initial = isGuest ? 'G' : (name.isNotEmpty ? name[0].toUpperCase() : '?');

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: GameOnBrand.slateCard,
            borderRadius: BorderRadius.circular(12),
            border: isGuest
                ? Border.all(
                    color: GameOnBrand.slateLight.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: isGuest
                    ? Colors.white.withValues(alpha: 0.08)
                    : GameOnBrand.saffron.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isGuest
                        ? Colors.white.withValues(alpha: 0.35)
                        : GameOnBrand.saffron,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isGuest
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white,
                      ),
                    ),
                    if (isGuest)
                      Text(
                        'Unclaimed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              // Badges / actions
              if (isCreator && !isGuest)
                _Badge(label: 'Host', color: GameOnBrand.saffron),
              if (isGuest && isHost) ...[
                // Host: share code button
                IconButton(
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  color: GameOnBrand.saffron.withValues(alpha: 0.7),
                  tooltip: 'Share claim code',
                  onPressed: () => _showShareSheet(p),
                ),
                // Host: remove guest button
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: Colors.redAccent.withValues(alpha: 0.6),
                  tooltip: 'Remove guest',
                  onPressed: () => _confirmRemoveGuest(p),
                ),
              ],
              // Non-host who hasn't joined: show Claim button on unclaimed rows
              if (isGuest &&
                  !isHost &&
                  widget.currentUserId.isNotEmpty &&
                  widget.currentUserId != widget.creatorId)
                TextButton(
                  onPressed: () => _showClaimDialog(context),
                  style: TextButton.styleFrom(
                    foregroundColor: GameOnBrand.saffron,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Claim',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 12)),
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
  final VoidCallback onLeave;

  const _ActionBar({
    required this.match,
    required this.isJoined,
    required this.isCreator,
    required this.onLeave,
  });

  void _openJoinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _JoinOptionsSheet(
        matchId: match.id,
        maxGuests: (match.playersNeeded - 1).clamp(0, 10),
      ),
    );
  }

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
        onPressed: match.isFull ? null : () => _openJoinSheet(context),
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

// ─── Join options sheet ────────────────────────────────────────────────────

class _JoinOptionsSheet extends StatefulWidget {
  final String matchId;
  final int maxGuests;

  const _JoinOptionsSheet({required this.matchId, required this.maxGuests});

  @override
  State<_JoinOptionsSheet> createState() => _JoinOptionsSheetState();
}

class _JoinOptionsSheetState extends State<_JoinOptionsSheet> {
  int _guestCount = 0;
  bool _isLoading = false;

  String get _guestLabel => switch (_guestCount) {
        0 => 'No guests',
        1 => '1 guest',
        _ => '$_guestCount guests',
      };

  Future<void> _join() async {
    setState(() => _isLoading = true);
    final provider = context.read<MatchProvider>();
    if (_guestCount == 0) {
      await provider.joinMatch(widget.matchId);
    } else {
      await provider.joinMatchWithGuests(widget.matchId, _guestCount);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join match',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Bring friends along — we\'ll generate a code for each guest slot.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Guest count stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: GameOnBrand.slateDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _guestCount > 0
                    ? GameOnBrand.saffron.withValues(alpha: 0.4)
                    : GameOnBrand.slateLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      size: 18,
                      color: _guestCount > 0
                          ? GameOnBrand.saffron
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _guestLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _guestCount > 0
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _SheetStepButton(
                      icon: Icons.remove_rounded,
                      onTap: _guestCount > 0
                          ? () => setState(() => _guestCount--)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$_guestCount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _guestCount > 0
                              ? GameOnBrand.saffron
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SheetStepButton(
                      icon: Icons.add_rounded,
                      onTap: _guestCount < widget.maxGuests
                          ? () => setState(() => _guestCount++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _join,
              style: FilledButton.styleFrom(
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: GameOnBrand.slateDark),
                    )
                  : Text(
                      _guestCount == 0
                          ? 'Join — just me'
                          : 'Join with $_guestCount guest${_guestCount > 1 ? "s" : ""}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SheetStepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? GameOnBrand.saffron.withValues(alpha: 0.5)
                : GameOnBrand.slateLight.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? GameOnBrand.saffron
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

// ─── Shared helper widgets ─────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../models/match_participant.dart';
import '../providers/match_provider.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';
import '../utils/app_snackbar.dart';
import '../utils/error_helpers.dart';
import '../widgets/game_on_logo.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  final String? initialClaimCode;
  const MatchDetailScreen({super.key, required this.matchId, this.initialClaimCode});

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
    if (widget.initialClaimCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showClaimDialog(context, prefill: widget.initialClaimCode);
      });
    }
  }

  Future<void> _showClaimDialog(BuildContext context, {String? prefill}) async {
    final provider = context.read<MatchProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ClaimSheet(prefill: prefill),
    );

    if (code != null && code.isNotEmpty && mounted) {
      final ok = await provider.claimGuestSpot(widget.matchId, code);
      if (mounted) {
        final l = AppLocalizations.of(this.context)!;
        if (ok) {
          showSuccessSnackBar(this.context, l.spotClaimed);
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.errorInvalidClaimCode),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditSheet(BuildContext context, Match match) async {
    final titleCtrl = TextEditingController(text: match.title ?? '');
    final descCtrl = TextEditingController(text: match.description ?? '');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.editMatch,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: l.title,
                  hintText: l.exampleMatchTitle,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: l.descriptionOptional,
                  hintText: l.anyDetailsForPlayers,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await context.read<MatchProvider>().updateMatchDetails(
                          match.id,
                          title: titleCtrl.text.trim().isEmpty
                              ? null
                              : titleCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                        );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l.save,
                      style:
                          const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
    titleCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _confirmCancel(BuildContext context, Match match) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cancelMatch),
        content: Text(l.cancelMatchWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.keepIt),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l.doCancelMatch),
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
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<Match>(
      stream: _matchStream,
      builder: (context, matchSnap) {
        if (matchSnap.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(l.matchNotFound,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
          );
        }
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

        return StreamBuilder<List<MatchParticipant>>(
          stream: _participantsStream,
          builder: (context, partSnap) {
            final participantCount =
                partSnap.hasData ? partSnap.data!.length : null;
            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                title: Row(
                  children: [
                    PhosphorIcon(match.sportType.icon, size: 22),
                    const SizedBox(width: 8),
                    Text(match.sportType.l10nLabel(context),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                actions: [
                  if (isCreator && match.status == MatchStatus.open) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: l.editTitleDescription,
                      onPressed: () => _showEditSheet(context, match),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      color: Colors.redAccent,
                      tooltip: l.doCancelMatch,
                      onPressed: () => _confirmCancel(context, match),
                    ),
                  ],
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(match: match, participantCount: participantCount),
                    const SizedBox(height: 28),
                    _SectionLabel(l.players),
                    const SizedBox(height: 12),
                    if (!partSnap.hasData)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              color: GameOnBrand.saffron),
                        ),
                      )
                    else
                      _ParticipantsList(
                        participants: partSnap.data!,
                        service: _service,
                        matchId: match.id,
                        creatorId: match.creatorId,
                        currentUserId: currentUserId ?? '',
                      ),
                  ],
                ),
              ),
              bottomNavigationBar: _ActionBar(
                match: match,
                isJoined: isJoined,
                isCreator: isCreator,
                currentUserId: currentUserId ?? '',
                participantCount: participantCount,
                onLeave: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.leaveMatchQuestion),
                      content: Text(l.leaveMatchBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l.keepIt),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent),
                          child: Text(l.leaveMatch),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    final ok = await context.read<MatchProvider>().leaveMatch(match.id);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l.couldNotLeaveMatch),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Hero card ─────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final Match match;
  final int? participantCount;
  const _HeroCard({required this.match, this.participantCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: match.sportType.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatusChip(match),
              _SkillChip(match.skillLevel),
              if (match.isGenderRestricted)
                _GenderChip(match),
            ],
          ),
          if (match.title != null && match.title!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              match.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 16),
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
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, d MMMM  •  HH:mm', Localizations.localeOf(context).languageCode).format(match.dateTime),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 14, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Text(
                match.durationLabel,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SpotsRow(match: match, participantCount: participantCount),
          if (match.description != null && match.description!.isNotEmpty) ...[
            const Divider(height: 24, color: Colors.white12),
            Text(
              match.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Spots row ─────────────────────────────────────────────────────────────

class _SpotsRow extends StatelessWidget {
  final Match match;
  final int? participantCount;
  const _SpotsRow({required this.match, this.participantCount});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (match.isUnlimited) {
      return Row(
        children: [
          Icon(Icons.all_inclusive_rounded,
              size: 18, color: GameOnBrand.saffron.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(
            l.unlimitedSpotsOpenToAll,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    final taken = participantCount ?? match.spotsTaken;
    final total = match.totalSpots!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.spotsCount(taken, total),
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
  Map<String, String?> _avatarUrls = {};

  @override
  void initState() {
    super.initState();
    _fetchProfiles(widget.participants);
  }

  @override
  void didUpdateWidget(_ParticipantsList old) {
    super.didUpdateWidget(old);
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
    if (mounted) {
      setState(() {
        _usernames = {for (final e in map.entries) e.key: e.value.username};
        _avatarUrls = {for (final e in map.entries) e.key: e.value.avatarUrl};
      });
    }
  }

  Future<void> _showShareSheet(MatchParticipant guest) async {
    final l = AppLocalizations.of(context)!;
    final code = guest.guestClaimToken ?? '';
    final deepLink =
        'io.supabase.gameon://claim?code=$code&match=${widget.matchId}';
    final text = l.shareInviteText(deepLink, code);
    try {
      await Share.share(text, subject: l.shareInviteSubject);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.inviteCopied,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
            ),
            backgroundColor: GameOnBrand.saffron,
          ),
        );
      }
    }
  }

  Future<void> _showClaimDialog(BuildContext context) async {
    final provider = context.read<MatchProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ClaimSheet(),
    );

    if (code != null && code.isNotEmpty && mounted) {
      final ok = await provider.claimGuestSpot(widget.matchId, code);
      if (mounted) {
        final l = AppLocalizations.of(this.context)!;
        if (ok) {
          showSuccessSnackBar(this.context, l.spotClaimed);
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.errorInvalidClaimCode),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmRemoveGuest(MatchParticipant guest) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.removeGuestQuestion),
        content: Text(l.removeGuestBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.keepIt)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l.remove),
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
    final l = AppLocalizations.of(context)!;
    if (widget.participants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l.noPlayersYet,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final isHost = widget.currentUserId == widget.creatorId;
    final alreadyJoined = widget.currentUserId.isNotEmpty &&
        widget.participants.any((x) => x.userId == widget.currentUserId);
    int guestIndex = 0;

    return Column(
      children: widget.participants.map((p) {
        final isGuestRow = p.isGuest && p.userId == null;
        final isMe = p.userId == widget.currentUserId;
        final isCreator = p.userId == widget.creatorId;
        if (isGuestRow) guestIndex++;

        final name = isGuestRow
            ? l.guestNumber(guestIndex)
            : (_usernames[p.userId] ?? '…');
        final initial =
            isGuestRow ? 'G' : (name.isNotEmpty ? name[0].toUpperCase() : '?');
        final avatarUrl = isGuestRow ? null : _avatarUrls[p.userId];
        final canTap = !isGuestRow && !isMe && p.userId != null;

        return GestureDetector(
          onTap: canTap ? () => context.push('/player/${p.userId}') : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(12),
              border: isGuestRow
                  ? Border.all(
                      color: GameOnBrand.slateLight.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isGuestRow
                      ? Colors.white.withValues(alpha: 0.06)
                      : GameOnBrand.saffron.withValues(alpha: 0.2),
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isGuestRow
                                ? Colors.white.withValues(alpha: 0.35)
                                : GameOnBrand.saffron,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isGuestRow
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.white,
                        ),
                      ),
                      if (isGuestRow)
                        Text(
                          l.unclaimedSpot,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.25)),
                        ),
                    ],
                  ),
                ),
                if (isMe && !isGuestRow)
                  _Badge(
                      label: l.you,
                      color: Colors.white.withValues(alpha: 0.4)),
                if (isCreator)
                  _Badge(label: l.host, color: GameOnBrand.saffron),
                if (isGuestRow && isHost) ...[
                  IconButton(
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    color: GameOnBrand.saffron.withValues(alpha: 0.7),
                    tooltip: l.share,
                    onPressed: () => _showShareSheet(p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: Colors.redAccent.withValues(alpha: 0.6),
                    tooltip: l.remove,
                    onPressed: () => _confirmRemoveGuest(p),
                  ),
                ] else if (isGuestRow &&
                    p.addedByUserId == widget.currentUserId) ...[
                  IconButton(
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    color: GameOnBrand.saffron.withValues(alpha: 0.7),
                    tooltip: l.share,
                    onPressed: () => _showShareSheet(p),
                  ),
                ] else if (isGuestRow && widget.currentUserId.isNotEmpty)
                  TextButton(
                    onPressed: alreadyJoined
                        ? null
                        : () => _showClaimDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: GameOnBrand.saffron,
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.25),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(l.claim,
                        style:
                            const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
              ],
            ),
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
  final String currentUserId;
  final int? participantCount;

  const _ActionBar({
    required this.match,
    required this.isJoined,
    required this.isCreator,
    required this.onLeave,
    required this.currentUserId,
    this.participantCount,
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
        maxGuests: match.isUnlimited
            ? 10
            : (match.playersNeeded! - 1).clamp(0, 10),
      ),
    );
  }

  void _openAddGuestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddGuestSheet(
        match: match,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final Widget child;
    // Use participant count from the stream as the source of truth;
    // fall back to match.isFull when the stream hasn't loaded yet.
    final showAddGuest = match.isUnlimited
        ? true
        : participantCount != null && match.totalSpots != null
            ? participantCount! < match.totalSpots!
            : !match.isFull;

    if (match.status == MatchStatus.cancelled) {
      child = Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(l.matchCancelledBanner,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.redAccent)),
      );
    } else if (isCreator) {
      child = showAddGuest
          ? SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(l.addGuest),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: GameOnBrand.saffron,
                  side: BorderSide(
                      color: GameOnBrand.saffron.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _openAddGuestSheet(context),
              ),
            )
          : Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(l.matchIsFull,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.redAccent)),
            );
    } else if (isJoined) {
      child = Row(
        children: [
          if (showAddGuest) ...[
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(l.addGuest),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: GameOnBrand.saffron,
                  side: BorderSide(
                      color: GameOnBrand.saffron.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _openAddGuestSheet(context),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: OutlinedButton(
              onPressed: onLeave,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                side: const BorderSide(color: GameOnBrand.saffron),
                foregroundColor: GameOnBrand.saffron,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l.leaveMatch,
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          match.isFull ? l.matchIsFull : l.joinMatch,
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
    final bool ok;
    if (_guestCount == 0) {
      ok = await provider.joinMatch(widget.matchId);
    } else {
      ok = await provider.joinMatchWithGuests(widget.matchId, _guestCount);
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friendlyError(provider.error, AppLocalizations.of(context)!)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 6),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.joinMatch,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            l.joinBringFriendsInfo,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    Icon(Icons.person_add_rounded,
                        size: 18,
                        color: _guestCount > 0
                            ? GameOnBrand.saffron
                            : Colors.white.withValues(alpha: 0.35)),
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
                          strokeWidth: 2.5, color: GameOnBrand.slateDark),
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

// ─── Add guest sheet ────────────────────────────────────────────────────────

class _AddGuestSheet extends StatefulWidget {
  final Match match;
  final String currentUserId;
  const _AddGuestSheet({required this.match, required this.currentUserId});

  @override
  State<_AddGuestSheet> createState() => _AddGuestSheetState();
}

class _AddGuestSheetState extends State<_AddGuestSheet> {
  int _count = 1;
  bool _loading = false;

  int get _maxGuests =>
      widget.match.isUnlimited ? 10 : (widget.match.playersNeeded ?? 0);

  Future<void> _add() async {
    setState(() => _loading = true);
    final ok = await context
        .read<MatchProvider>()
        .addGuestSpots(widget.match.id, _count);
    if (!mounted) return;
    Navigator.pop(context);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(context.read<MatchProvider>().error, AppLocalizations.of(context)!))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.viewInsetsOf(context).bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(AppLocalizations.of(context)!.addGuest,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.guestClaimCodeInfo,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: GameOnBrand.slateDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GameOnBrand.saffron.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_add_rounded,
                        size: 18, color: GameOnBrand.saffron),
                    const SizedBox(width: 10),
                    Text(
                      _count == 1 ? '1 guest' : '$_count guests',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _SheetStepButton(
                      icon: Icons.remove_rounded,
                      onTap: _count > 1
                          ? () => setState(() => _count--)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$_count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GameOnBrand.saffron,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SheetStepButton(
                      icon: Icons.add_rounded,
                      onTap: _count < _maxGuests
                          ? () => setState(() => _count++)
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
              onPressed: _loading ? null : _add,
              style: FilledButton.styleFrom(
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: GameOnBrand.slateDark),
                    )
                  : Text(
                      AppLocalizations.of(context)!.addGuestsCount(_count),
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
        child: Icon(icon,
            size: 16,
            color: enabled
                ? GameOnBrand.saffron
                : Colors.white.withValues(alpha: 0.2)),
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
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: color)),
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
  final Match match;
  const _StatusChip(this.match);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (Color color, String label) = switch (match.status) {
      MatchStatus.open      => (GameOnBrand.saffron, l.open),
      MatchStatus.full      => (Colors.redAccent, l.fullBadge),
      MatchStatus.cancelled => (Colors.grey, l.cancelledBadge),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.8)),
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
          PhosphorIcon(level.icon, size: 11, color: level.color),
          const SizedBox(width: 4),
          Text(level.l10nLabel(context),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: level.color,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final Match match;
  const _GenderChip(this.match);

  @override
  Widget build(BuildContext context) {
    const chipColor = Color(0xFFAB47BC); // purple accent
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PhosphorIcon(PhosphorIconsLight.genderIntersex,
              size: 11, color: chipColor),
          const SizedBox(width: 4),
          Text(match.genderRestrictionLabel(context),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: chipColor,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// ─── Claim sheet ────────────────────────────────────────────────────────────

class _ClaimSheet extends StatefulWidget {
  final String? prefill;
  const _ClaimSheet({this.prefill});

  @override
  State<_ClaimSheet> createState() => _ClaimSheetState();
}

class _ClaimSheetState extends State<_ClaimSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) _controller.text = widget.prefill!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.claimCode,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(l.enterClaimCode,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 3),
            decoration: const InputDecoration(
              hintText: 'XXXXXXXX',
              prefixIcon: Icon(Icons.key_rounded, color: GameOnBrand.saffron),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(
                  context, _controller.text.trim().toUpperCase()),
              style: FilledButton.styleFrom(
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l.claim,
                  style:
                      const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

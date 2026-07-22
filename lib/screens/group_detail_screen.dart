import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../models/match.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../services/group_service.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';
import '../widgets/game_on_logo.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _groupService = GroupService();
  final _matchService = MatchService();
  Map<String, dynamic> _members = {};
  List<Map<String, String>> _pendingRequests = [];
  ({int completed, int upcoming})? _matchCounts;
  bool _loadingMembers = false;
  bool _uploadingImage = false;
  final _membersSectionKey = GlobalKey();

  Group? _findGroup(GroupProvider p) {
    final matches = p.groups.where((g) => g.id == widget.groupId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadMatchCounts();
  }

  bool get _amIAdmin {
    final me = SupabaseService.currentUser?.id;
    final info = _members[me];
    return info is Map && info['role'] == 'admin';
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final data = await _groupService.fetchMembersWithRoles(widget.groupId);
      if (!mounted) return;
      setState(() => _members = data);
      await _loadPendingRequests();
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  Future<void> _loadMatchCounts() async {
    try {
      final counts = await _matchService.fetchGroupMatchCounts(widget.groupId);
      if (mounted) setState(() => _matchCounts = counts);
    } catch (_) {
      // Non-fatal — the stats row just won't show.
    }
  }

  Future<void> _pickAndUploadImage() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (xfile == null || !mounted) return;
    final Uint8List bytes = await xfile.readAsBytes();
    final ext = xfile.path.split('.').last.toLowerCase();
    setState(() => _uploadingImage = true);
    try {
      await _groupService.uploadGroupImage(widget.groupId, bytes, ext);
      if (mounted) await context.read<GroupProvider>().fetchGroups();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGeneric),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _loadPendingRequests() async {
    if (!_amIAdmin) return;
    try {
      final requests =
          await _groupService.fetchPendingRequests(widget.groupId);
      if (mounted) setState(() => _pendingRequests = requests);
    } catch (_) {
      // Non-admins get an empty list via RLS anyway.
    }
  }

  Future<void> _respond(String requestId, bool accept) async {
    await _groupService.respondToRequest(requestId, accept: accept);
    await _loadMembers();
  }

  void _scrollToMembers() {
    final ctx = _membersSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  Future<void> _showMatchListSheet({required bool upcoming}) async {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _GroupMatchListSheet(
        groupId: widget.groupId,
        upcoming: upcoming,
        title: upcoming ? l.matchesUpcoming : l.matchesPlayed,
        emptyLabel: upcoming ? l.noUpcomingMatches : l.noMatchesYet,
      ),
    );
  }

  Future<void> _leave() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(l.leaveGroup,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(l.leaveGroupBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.leave),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<GroupProvider>().leaveGroup(widget.groupId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final group = _findGroup(provider);
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().user?.id;

    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCreator = group.creatorId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!isCreator)
            TextButton(
              onPressed: _leave,
              child: Text(AppLocalizations.of(context)!.leave,
                  style: const TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([_loadMembers(), _loadMatchCounts()]),
        color: GameOnBrand.saffron,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // ── Cover image ─────────────────────────────────────────────────
            GestureDetector(
              onTap: _amIAdmin ? _pickAndUploadImage : null,
              child: Container(
                height: 140,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: GameOnBrand.saffron.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (group.imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: group.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.group_rounded,
                            color: GameOnBrand.saffron,
                            size: 48),
                      )
                    else
                      const Center(
                        child: Icon(Icons.group_rounded,
                            color: GameOnBrand.saffron, size: 48),
                      ),
                    if (_uploadingImage)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: GameOnBrand.saffron),
                        ),
                      )
                    else if (_amIAdmin)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: GameOnBrand.saffron,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: GameOnBrand.slateDark),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats row: members + matches played/upcoming ────────────────
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.people_outline_rounded,
                    value: '${group.memberCount}',
                    label: AppLocalizations.of(context)!.members,
                    onTap: _scrollToMembers,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.check_circle_outline_rounded,
                    value: '${_matchCounts?.completed ?? '—'}',
                    label: AppLocalizations.of(context)!.matchesPlayed,
                    onTap: () => _showMatchListSheet(upcoming: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.event_available_rounded,
                    value: '${_matchCounts?.upcoming ?? '—'}',
                    label: AppLocalizations.of(context)!.matchesUpcoming,
                    onTap: () => _showMatchListSheet(upcoming: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MemberAvatarRow(members: _members),
            const SizedBox(height: 20),

            // ── Invite code card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameOnBrand.saffron.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: GameOnBrand.saffron.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.vpn_key_rounded,
                      color: GameOnBrand.saffron, size: 28),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.inviteCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: group.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.codeCopiedToClipboard),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                GameOnBrand.saffron.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            group.inviteCode,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: GameOnBrand.saffron,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.copy_rounded,
                              size: 18, color: GameOnBrand.saffron),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.shareCodeToJoin,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),

            // ── Description ────────────────────────────────────────────────
            if (group.description != null &&
                group.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(group.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  )),
            ],

            // ── Pending join requests (admins of invite-only groups) ──────
            if (_amIAdmin && _pendingRequests.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.joinRequests,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: GameOnBrand.saffron.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_pendingRequests.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: GameOnBrand.saffron,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._pendingRequests.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              GameOnBrand.saffron.withValues(alpha: 0.2),
                          child: Text(
                            r['username']!.isNotEmpty
                                ? r['username']![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: GameOnBrand.saffron,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                context.push('/player/${r['userId']}'),
                            child: Text(r['username']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 26),
                          tooltip: AppLocalizations.of(context)!.accept,
                          onPressed: () => _respond(r['id']!, true),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel_rounded,
                              color: Colors.redAccent.withValues(alpha: 0.7),
                              size: 26),
                          tooltip: AppLocalizations.of(context)!.decline,
                          onPressed: () => _respond(r['id']!, false),
                        ),
                      ],
                    ),
                  )),
            ],

            // ── Members ────────────────────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              key: _membersSectionKey,
              children: [
                Text(AppLocalizations.of(context)!.members,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameOnBrand.saffron.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_members.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: GameOnBrand.saffron,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_loadingMembers)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: GameOnBrand.saffron),
              ))
            else
              ..._members.entries.map((entry) {
                final info = entry.value as Map<String, dynamic>;
                final username = info['username'] as String;
                final role = info['role'] as String;
                final isAdmin = role == 'admin';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            GameOnBrand.saffron.withValues(alpha: 0.2),
                        child: Text(
                          username.isNotEmpty
                              ? username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: GameOnBrand.saffron,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                GameOnBrand.saffron.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.admin,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: GameOnBrand.saffron,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ─── Stat tile ─────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;
  const _StatTile(
      {required this.icon,
      required this.value,
      required this.label,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 18, color: GameOnBrand.saffron),
              const SizedBox(height: 6),
              Text(value,
                  style:
                      const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Member avatar row (mirrors match_card.dart's participant dots) ───────

class _MemberAvatarRow extends StatelessWidget {
  final Map<String, dynamic> members;
  static const _maxAvatars = 5;

  const _MemberAvatarRow({required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();
    final entries = members.entries.toList();
    final shown = entries.take(_maxAvatars);
    final overflow = entries.length - _maxAvatars;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in shown)
          _MemberDot(
            username: (entry.value as Map<String, dynamic>)['username'] as String,
            avatarUrl:
                (entry.value as Map<String, dynamic>)['avatarUrl'] as String?,
          ),
        if (overflow > 0) _MemberOverflowDot(count: overflow),
      ],
    );
  }
}

class _MemberDot extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  const _MemberDot({required this.username, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: GameOnBrand.saffron, width: 1.5),
        color: GameOnBrand.saffron.withValues(alpha: 0.18),
        image: avatarUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: GameOnBrand.saffron,
                ),
              ),
            )
          : null,
    );
  }
}

class _MemberOverflowDot extends StatelessWidget {
  final int count;
  const _MemberOverflowDot({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

// ─── Group match list bottom sheet (Played / Upcoming stat tiles) ─────────

class _GroupMatchListSheet extends StatefulWidget {
  final String groupId;
  final bool upcoming;
  final String title;
  final String emptyLabel;
  const _GroupMatchListSheet({
    required this.groupId,
    required this.upcoming,
    required this.title,
    required this.emptyLabel,
  });

  @override
  State<_GroupMatchListSheet> createState() => _GroupMatchListSheetState();
}

class _GroupMatchListSheetState extends State<_GroupMatchListSheet> {
  final _matchService = MatchService();
  List<Match>? _matches;

  @override
  void initState() {
    super.initState();
    _matchService
        .fetchGroupMatches(widget.groupId, upcoming: widget.upcoming)
        .then((matches) {
      if (mounted) setState(() => _matches = matches);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _matches;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17)),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (matches == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                    child:
                        CircularProgressIndicator(color: GameOnBrand.saffron)),
              )
            else if (matches.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  widget.emptyLabel,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _GroupMatchRow(match: matches[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupMatchRow extends StatelessWidget {
  final Match match;
  const _GroupMatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = match.sportType.color;
    final locale = Localizations.localeOf(context).languageCode;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.pop(context);
        context.push('/match/${match.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          children: [
            PhosphorIcon(match.sportType.icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(
                    '${DateFormat('d MMM', locale).format(match.dateTime)} · ${DateFormat('HH:mm').format(match.dateTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

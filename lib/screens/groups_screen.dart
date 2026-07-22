import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../models/profile.dart';
import '../providers/group_provider.dart';
import '../services/group_service.dart';
import '../services/match_service.dart' show CoPlayer, MatchService;
import '../services/profile_service.dart';
import '../services/supabase_client.dart';
import '../utils/app_snackbar.dart';
import '../widgets/game_on_logo.dart';

/// Community tab: unified player + group search, my groups, join flows.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _searchCtrl = TextEditingController();
  final _profileService = ProfileService();
  final _groupService = GroupService();
  final _matchService = MatchService();
  Timer? _debounce;

  String _query = '';
  bool _searching = false;
  List<Profile> _playerResults = [];
  List<Group> _groupResults = [];

  List<Group> _recentGroups = [];
  List<CoPlayer> _suggestedPlayers = [];
  bool _loadingDiscovery = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
    });
    _loadDiscovery();
  }

  Future<void> _loadDiscovery() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    try {
      final results = await Future.wait([
        _groupService.fetchRecentGroups(),
        _matchService.fetchSuggestedPlayers(userId),
      ]);
      if (mounted) {
        setState(() {
          _recentGroups = results[0] as List<Group>;
          _suggestedPlayers = results[1] as List<CoPlayer>;
          _loadingDiscovery = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDiscovery = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _playerResults = [];
        _groupResults = [];
        _searching = false;
      });
      return;
    }
    setState(() => _query = query);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      try {
        final results = await Future.wait([
          _profileService.searchPlayers(query),
          _groupService.searchGroups(query),
        ]);
        if (mounted && _query == query) {
          setState(() {
            _playerResults = results[0] as List<Profile>;
            _groupResults = results[1] as List<Group>;
            _searching = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isSearchMode = _query.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.community,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded),
            tooltip: l.joinWithCode,
            onPressed: () => _showJoinDialog(context),
          ),
        ],
      ),
      floatingActionButton: isSearchMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/groups/create'),
              backgroundColor: GameOnBrand.saffron,
              foregroundColor: GameOnBrand.slateDark,
              icon: const Icon(Icons.add_rounded),
              label: Text(l.createGroup,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l.searchCommunityHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: isSearchMode
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: isSearchMode ? _buildSearchResults(l) : _buildMyGroups(l),
          ),
        ],
      ),
    );
  }

  // ── Search results ─────────────────────────────────────────────────────

  Widget _buildSearchResults(AppLocalizations l) {
    if (_searching && _playerResults.isEmpty && _groupResults.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: GameOnBrand.saffron));
    }
    if (_playerResults.isEmpty && _groupResults.isEmpty) {
      return Center(
        child: Text(
          l.noResults,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (_playerResults.isNotEmpty) ...[
          _SectionHeader(l.players),
          ..._playerResults.map((p) => _PlayerTile(profile: p)),
          const SizedBox(height: 12),
        ],
        if (_groupResults.isNotEmpty) ...[
          _SectionHeader(l.groupsTitle),
          ..._groupResults.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GroupSearchCard(group: g),
              )),
        ],
      ],
    );
  }

  // ── My groups ──────────────────────────────────────────────────────────

  Widget _buildMyGroups(AppLocalizations l) {
    final provider = context.watch<GroupProvider>();
    if (provider.isLoading && provider.groups.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: GameOnBrand.saffron));
    }

    // Discovery groups already shown under "My groups" would be redundant.
    final myGroupIds = provider.groups.map((g) => g.id).toSet();
    final discoveryGroups =
        _recentGroups.where((g) => !myGroupIds.contains(g.id)).toList();

    if (provider.groups.isEmpty &&
        discoveryGroups.isEmpty &&
        _suggestedPlayers.isEmpty &&
        !_loadingDiscovery) {
      return _EmptyState(onJoin: () => _showJoinDialog(context));
    }

    return RefreshIndicator(
      onRefresh: () =>
          Future.wait([provider.fetchGroups(), _loadDiscovery()]),
      color: GameOnBrand.saffron,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          if (provider.groups.isNotEmpty) ...[
            _SectionHeader(l.myGroups),
            ...provider.groups.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GroupCard(group: g),
                )),
            const SizedBox(height: 8),
          ],
          if (discoveryGroups.isNotEmpty) ...[
            _SectionHeader(l.recentGroups),
            ...discoveryGroups.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GroupSearchCard(group: g),
                )),
            const SizedBox(height: 8),
          ],
          if (_suggestedPlayers.isNotEmpty) ...[
            _SectionHeader(l.suggestedPlayers),
            const SizedBox(height: 4),
            ..._suggestedPlayers.map((p) => _SuggestedPlayerTile(player: p)),
          ],
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(l.joinAGroup,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          decoration: InputDecoration(
            hintText: l.enter8CharCode,
            prefixIcon: const Icon(Icons.vpn_key_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GameOnBrand.saffron,
              foregroundColor: GameOnBrand.slateDark,
            ),
            onPressed: () async {
              final code = ctrl.text.trim();
              if (code.length != 8) return;
              final provider = context.read<GroupProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final group = await provider.joinByCode(code);
              if (!mounted) return;
              if (group != null) {
                showSuccessSnackBar(this.context, l.joinedGroup(group.name));
              } else {
                messenger.showSnackBar(SnackBar(
                  content: Text(l.invalidGroupCode),
                  backgroundColor: Colors.redAccent,
                ));
              }
            },
            child: Text(l.join),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

// ─── Player result tile ──────────────────────────────────────────────────

class _PlayerTile extends StatelessWidget {
  final Profile profile;
  const _PlayerTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.username.isNotEmpty ? profile.username[0].toUpperCase() : '?';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: GameOnBrand.saffron.withValues(alpha: 0.15),
        backgroundImage: profile.avatarUrl != null
            ? CachedNetworkImageProvider(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? Text(
                initial,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: GameOnBrand.saffron,
                ),
              )
            : null,
      ),
      title: Text(profile.username,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: profile.bio != null && profile.bio!.isNotEmpty
          ? Text(
              profile.bio!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            )
          : null,
      onTap: () => context.push('/player/${profile.id}'),
    );
  }
}

// ─── Suggested player tile ────────────────────────────────────────────────

class _SuggestedPlayerTile extends StatelessWidget {
  final CoPlayer player;
  const _SuggestedPlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final initial =
        player.username.isNotEmpty ? player.username[0].toUpperCase() : '?';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: GameOnBrand.saffron.withValues(alpha: 0.15),
        backgroundImage: player.avatarUrl != null
            ? CachedNetworkImageProvider(player.avatarUrl!)
            : null,
        child: player.avatarUrl == null
            ? Text(initial,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: GameOnBrand.saffron))
            : null,
      ),
      title: Text(player.username,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        l.suggestedPlayer,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
      ),
      onTap: () => context.push('/player/${player.userId}'),
    );
  }
}

// ─── Group thumbnail (image if set, generic icon otherwise) ──────────────

class _GroupThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const _GroupThumbnail({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: GameOnBrand.saffron.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Icon(Icons.group_rounded,
                  color: GameOnBrand.saffron, size: size * 0.5),
            )
          : Icon(Icons.group_rounded,
              color: GameOnBrand.saffron, size: size * 0.5),
    );
  }
}

// ─── Group visibility badge ──────────────────────────────────────────────

class _VisibilityBadge extends StatelessWidget {
  final GroupVisibility visibility;
  const _VisibilityBadge({required this.visibility});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (IconData icon, String label) = switch (visibility) {
      GroupVisibility.public => (Icons.public_rounded, l.visibilityPublic),
      GroupVisibility.private => (Icons.lock_rounded, l.visibilityPrivate),
      GroupVisibility.inviteOnly =>
        (Icons.how_to_reg_rounded, l.visibilityInviteOnly),
    };
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

// ─── Group search result card (with join action) ─────────────────────────

class _GroupSearchCard extends StatelessWidget {
  final Group group;
  const _GroupSearchCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<GroupProvider>();
    final isMember = provider.isMember(group.id);
    final isRequested = provider.hasPendingRequest(group.id);

    return GestureDetector(
      onTap: isMember ? () => context.push('/groups/${group.id}') : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _GroupThumbnail(imageUrl: group.imageUrl, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _VisibilityBadge(visibility: group.visibility),
                      const SizedBox(width: 10),
                      Icon(Icons.people_outline_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                      const SizedBox(width: 3),
                      Text(
                        '${group.memberCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _actionButton(context, l, provider, isMember, isRequested),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, AppLocalizations l,
      GroupProvider provider, bool isMember, bool isRequested) {
    if (isMember) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(l.member,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.green)),
      );
    }
    switch (group.visibility) {
      case GroupVisibility.public:
        return FilledButton(
          onPressed: () async {
            final ok = await provider.joinPublicGroup(group);
            if (context.mounted && ok) {
              showSuccessSnackBar(context, l.joinedGroup(group.name));
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: GameOnBrand.saffron,
            foregroundColor: GameOnBrand.slateDark,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 34),
          ),
          child: Text(l.join,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800)),
        );
      case GroupVisibility.inviteOnly:
        return isRequested
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: GameOnBrand.saffron.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(l.requested,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: GameOnBrand.saffron)),
              )
            : OutlinedButton(
                onPressed: () => provider.requestToJoin(group),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GameOnBrand.saffron,
                  side: BorderSide(
                      color: GameOnBrand.saffron.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 34),
                ),
                child: Text(l.requestToJoin,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800)),
              );
      case GroupVisibility.private:
        // Private groups never appear in search, but guard anyway.
        return const SizedBox.shrink();
    }
  }
}

// ─── My-group card ────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/groups/${group.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: GameOnBrand.saffron, width: 4),
          ),
        ),
        child: Row(
          children: [
            _GroupThumbnail(imageUrl: group.imageUrl, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  if (group.description != null &&
                      group.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      group.description!,
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _VisibilityBadge(visibility: group.visibility),
                      const SizedBox(width: 12),
                      _InviteCodeBadge(code: group.inviteCode),
                      const SizedBox(width: 12),
                      Icon(Icons.people_outline_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                      const SizedBox(width: 3),
                      Text(
                        '${group.memberCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InviteCodeBadge extends StatelessWidget {
  final String code;
  const _InviteCodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.inviteCodeCopied),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.copy_rounded,
              size: 11,
              color: GameOnBrand.saffron.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            code,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: GameOnBrand.saffron,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onJoin;
  const _EmptyState({required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👥', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noGroupsYet,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noGroupsBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.link_rounded),
              label: Text(AppLocalizations.of(context)!.joinWithCode),
            ),
          ],
        ),
      ),
    );
  }
}

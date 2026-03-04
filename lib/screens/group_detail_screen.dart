import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../services/group_service.dart';
import '../widgets/game_on_logo.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _groupService = GroupService();
  Map<String, dynamic> _members = {};
  bool _loadingMembers = false;

  Group? _findGroup(GroupProvider p) {
    final matches = p.groups.where((g) => g.id == widget.groupId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final data = await _groupService.fetchMembersWithRoles(widget.groupId);
      setState(() => _members = data);
    } finally {
      setState(() => _loadingMembers = false);
    }
  }

  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameOnBrand.slateCard,
        title: const Text('Leave Group',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'You will no longer see private matches from this group.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
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
              child: const Text('Leave',
                  style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMembers,
        color: GameOnBrand.saffron,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
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
                  const Text('Invite Code',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: group.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: GameOnBrand.slateDark,
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
                    'Share this code so others can join',
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

            // ── Members ────────────────────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Members',
                    style: TextStyle(
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
                          child: const Text(
                            'Admin',
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
              }),
          ],
        ),
      ),
    );
  }
}

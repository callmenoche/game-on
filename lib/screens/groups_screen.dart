import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../providers/group_provider.dart';
import '../widgets/game_on_logo.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded),
            tooltip: 'Join with code',
            onPressed: () => _showJoinDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/groups/create'),
        backgroundColor: GameOnBrand.saffron,
        foregroundColor: GameOnBrand.slateDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Group',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: provider.isLoading && provider.groups.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: GameOnBrand.saffron))
          : provider.groups.isEmpty
              ? _EmptyState(onJoin: () => _showJoinDialog(context))
              : RefreshIndicator(
                  onRefresh: provider.fetchGroups,
                  color: GameOnBrand.saffron,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: provider.groups.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GroupCard(group: provider.groups[i]),
                    ),
                  ),
                ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameOnBrand.slateCard,
        title: const Text('Join a Group',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          decoration: const InputDecoration(
            hintText: 'Enter 8-character code',
            prefixIcon: Icon(Icons.vpn_key_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GameOnBrand.saffron,
              foregroundColor: GameOnBrand.slateDark,
            ),
            onPressed: () async {
              final code = ctrl.text.trim();
              if (code.length != 8) return;
              Navigator.pop(ctx);
              final group =
                  await context.read<GroupProvider>().joinByCode(code);
              if (!mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              if (group != null) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Joined ${group.name}! 🎉'),
                  backgroundColor: GameOnBrand.saffron,
                ));
              } else {
                messenger.showSnackBar(const SnackBar(
                  content: Text('Invalid code. Check and try again.'),
                  backgroundColor: Colors.redAccent,
                ));
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GameOnBrand.saffron.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group_rounded,
                  color: GameOnBrand.saffron, size: 24),
            ),
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
                  _InviteCodeBadge(code: group.inviteCode),
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
          const SnackBar(
            content: Text('Invite code copied!'),
            duration: Duration(seconds: 2),
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
            Text('No groups yet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Create a private group for your team or company, or join one with an invite code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.link_rounded),
              label: const Text('Join with code'),
            ),
          ],
        ),
      ),
    );
  }
}

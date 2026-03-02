import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/match_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/game_on_logo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _saving = false;

  late TextEditingController _usernameCtrl;
  late TextEditingController _bioCtrl;
  late List<String> _favoriteSports;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _favoriteSports = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Profile profile) {
    _usernameCtrl.text = profile.username;
    _bioCtrl.text = profile.bio ?? '';
    _favoriteSports = List<String>.from(profile.favoriteSports);
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    if (_usernameCtrl.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Username must be at least 3 characters'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    setState(() => _saving = true);
    await context.read<ProfileProvider>().saveProfile(
          username: _usernameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          favoriteSports: _favoriteSports,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final matchProvider = context.watch<MatchProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (profileProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: GameOnBrand.saffron),
              ),
            )
          else if (profile != null) ...[
            if (_editing) ...[
              TextButton(
                onPressed: _saving ? null : _cancelEdit,
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6))),
              ),
              TextButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: GameOnBrand.saffron),
                      )
                    : const Text('Save',
                        style: TextStyle(
                            color: GameOnBrand.saffron,
                            fontWeight: FontWeight.w800)),
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _startEdit(profile),
              ),
          ],
        ],
      ),
      body: profile == null && !profileProvider.isLoading
          ? Center(
              child: Text(
                profileProvider.error ?? 'Could not load profile',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            )
          : profile == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar + name header ─────────────────────────────
                      _AvatarHeader(
                        profile: profile,
                        editing: _editing,
                        usernameCtrl: _usernameCtrl,
                        bioCtrl: _bioCtrl,
                      ),
                      const SizedBox(height: 28),

                      // ── Stats row ────────────────────────────────────────
                      _StatsRow(
                        joinedCount: matchProvider.joinedMatches.length,
                        createdCount: matchProvider.joinedMatches
                            .where((m) =>
                                m.creatorId ==
                                profileProvider.profile?.id)
                            .length,
                      ),
                      const SizedBox(height: 28),

                      // ── Favourite sports ─────────────────────────────────
                      const _SectionLabel('Favourite Sports'),
                      const SizedBox(height: 12),
                      _FavouriteSportsPicker(
                        selected: _editing
                            ? _favoriteSports
                            : profile.favoriteSports,
                        editing: _editing,
                        onToggle: (sport) {
                          setState(() {
                            if (_favoriteSports.contains(sport)) {
                              _favoriteSports.remove(sport);
                            } else {
                              _favoriteSports.add(sport);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 36),

                      // ── Sign out ─────────────────────────────────────────
                      _SignOutButton(),
                    ],
                  ),
                ),
    );
  }
}

// ─── Avatar + name header ───────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final Profile profile;
  final bool editing;
  final TextEditingController usernameCtrl;
  final TextEditingController bioCtrl;

  const _AvatarHeader({
    required this.profile,
    required this.editing,
    required this.usernameCtrl,
    required this.bioCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final initial = profile.username.isNotEmpty
        ? profile.username[0].toUpperCase()
        : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar circle
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
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
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: GameOnBrand.slateDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: editing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: usernameCtrl,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4),
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: GameOnBrand.saffron, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 2,
                      maxLength: 120,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7)),
                      decoration: InputDecoration(
                        hintText: 'A short bio…',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4),
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: GameOnBrand.saffron, width: 2),
                        ),
                        counterStyle: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    if (profile.bio != null && profile.bio!.isNotEmpty)
                      Text(
                        profile.bio!,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.55)),
                      )
                    else
                      Text(
                        'No bio yet — tap ✏️ to add one',
                        style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ─── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int joinedCount;
  final int createdCount;

  const _StatsRow({required this.joinedCount, required this.createdCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.sports_rounded,
            label: 'Joined',
            value: '$joinedCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Created',
            value: '$createdCount',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: GameOnBrand.saffron),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Favourite sports picker ────────────────────────────────────────────────

class _FavouriteSportsPicker extends StatelessWidget {
  final List<String> selected;
  final bool editing;
  final ValueChanged<String> onToggle;

  const _FavouriteSportsPicker({
    required this.selected,
    required this.editing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!editing && selected.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GameOnBrand.slateCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No favourites yet — tap ✏️ to add',
          style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.3)),
        ),
      );
    }

    final sports = editing
        ? SportType.values
        : SportType.values.where((s) => selected.contains(s.name)).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sports.map((sport) {
        final isSelected = selected.contains(sport.name);
        return GestureDetector(
          onTap: editing ? () => onToggle(sport.name) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? GameOnBrand.saffron.withValues(alpha: 0.15)
                  : GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? GameOnBrand.saffron.withValues(alpha: 0.6)
                    : GameOnBrand.slateLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sport.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  sport.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected
                        ? GameOnBrand.saffron
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                if (editing && isSelected) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_rounded,
                      size: 14, color: GameOnBrand.saffron),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Sign out button ────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign out?'),
              content: const Text('You will need to sign in again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<AuthProvider>().signOut();
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sign out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ─── Section label ──────────────────────────────────────────────────────────

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

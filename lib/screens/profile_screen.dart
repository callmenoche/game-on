import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../models/match.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/profile_provider.dart';
import '../services/group_service.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';
import '../utils/error_helpers.dart';
import '../widgets/game_on_logo.dart';
import '../widgets/profile_form_fields.dart';
import '../widgets/profile_highlights.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _saving = false;
  final _bioCtrl = TextEditingController();
  final _groupService = GroupService();
  List<String> _favoriteSports = [];
  List<Match> _history = [];
  List<Match> _upcoming = [];
  List<Group> _groups = [];
  List<CoPlayer> _coPlayers = [];
  bool _dataLoaded = false;

  // Edit-mode state for new fields
  DateTime? _editBirthDate;
  String?   _editGender;
  bool      _editShowAge     = true;
  bool      _editShowGender  = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().loadProfile();
      _loadMatchData();
    });
  }

  Future<void> _loadMatchData() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    try {
      final svc = MatchService();
      final results = await Future.wait([
        svc.fetchUserMatchHistory(userId),
        svc.fetchUserUpcomingMatches(userId),
        svc.fetchTopCoPlayers(userId),
        _groupService.fetchGroupsForUser(userId),
      ]);
      if (mounted) {
        setState(() {
          _history = results[0] as List<Match>;
          _upcoming = results[1] as List<Match>;
          _coPlayers = results[2] as List<CoPlayer>;
          _groups = results[3] as List<Group>;
          _dataLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dataLoaded = true);
    }
  }

  Future<void> _refresh() async {
    await context.read<ProfileProvider>().reload();
    await _loadMatchData();
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Profile profile) {
    _bioCtrl.text = profile.bio ?? '';
    _favoriteSports = List<String>.from(profile.favoriteSports);
    _editBirthDate = profile.birthDate;
    _editGender = profile.gender;
    _editShowAge = profile.showAge;
    _editShowGender = profile.showGender;
    setState(() => _editing = true);
  }

  void _cancelEdit() => setState(() => _editing = false);

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<ProfileProvider>().saveProfile(
          bio: _bioCtrl.text.trim(),
          favoriteSports: _favoriteSports,
          birthDate: _editBirthDate,
          gender: _editGender,
          showAge: _editShowAge,
          showGender: _editShowGender,
        );
    if (!mounted) return;
    final err = context.read<ProfileProvider>().error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.couldNotSaveProfile),
        backgroundColor: Colors.redAccent,
      ));
      context.read<ProfileProvider>().clearError();
      // Stay in edit mode so the user can retry
      setState(() => _saving = false);
      return;
    }
    setState(() {
      _saving = false;
      _editing = false;
    });
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editBirthDate ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: GameOnBrand.saffron,
                onPrimary: GameOnBrand.slateDark,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _editBirthDate = picked);
  }

  Future<void> _pickAvatar() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final lCtx = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: GameOnBrand.saffron),
                title: Text(lCtx.chooseFromLibrary),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: GameOnBrand.saffron),
                title: Text(lCtx.takeAPhoto),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (choice == null || !mounted) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: choice,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (xfile == null || !mounted) return;

    final bytes = await xfile.readAsBytes();
    final ext = xfile.path.split('.').last.toLowerCase();
    if (!mounted) return;

    await context.read<ProfileProvider>().saveAvatar(bytes, ext);
    if (!mounted) return;

    final err = context.read<ProfileProvider>().error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friendlyError(err, AppLocalizations.of(context)!)),
        backgroundColor: Colors.redAccent,
      ));
      context.read<ProfileProvider>().clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    // ── Derived stats from match history ────────────────────────────────────
    final sportCounts = <SportType, int>{};
    for (final m in _history) {
      sportCounts[m.sportType] = (sportCounts[m.sportType] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings,
            onPressed: () => context.push('/settings'),
          ),
          if (profileProvider.isLoading && profile == null)
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
                child: Text(l.cancel,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
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
                    : Text(l.save,
                        style: const TextStyle(
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
                friendlyError(profileProvider.error, AppLocalizations.of(context)!),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            )
          : profile == null
              ? const SizedBox.shrink()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: GameOnBrand.saffron,
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar + username + bio ──────────────────────────
                      _AvatarHeader(
                        profile: profile,
                        editing: _editing,
                        bioCtrl: _bioCtrl,
                        onTapAvatar: _pickAvatar,
                        isUploadingAvatar: profileProvider.isUploadingAvatar,
                      ),
                      const SizedBox(height: 24),

                      // ── Birthdate + gender (edit mode) ───────────────────
                      if (_editing) ...[
                        ProfileSectionLabel(l.dateOfBirth),
                        const SizedBox(height: 8),
                        DateField(
                          value: _editBirthDate,
                          onTap: _pickBirthDate,
                        ),
                        if (_editBirthDate != null) ...[
                          const SizedBox(height: 8),
                          PrivacyToggle(
                            label: l.showAgeOnProfile,
                            value: _editShowAge,
                            onChanged: (v) =>
                                setState(() => _editShowAge = v),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ProfileSectionLabel(l.gender),
                        const SizedBox(height: 8),
                        GenderPicker(
                          value: _editGender,
                          onChanged: (g) =>
                              setState(() => _editGender = g),
                        ),
                        if (_editGender != null) ...[
                          const SizedBox(height: 8),
                          PrivacyToggle(
                            label: l.showGenderOnProfile,
                            value: _editShowGender,
                            onChanged: (v) =>
                                setState(() => _editShowGender = v),
                          ),
                        ],
                        const SizedBox(height: 28),
                      ],

                      // ── Recent activities ────────────────────────────────
                      if (_dataLoaded) ...[
                        ProfileSectionLabel(l.recentMatches),
                        const SizedBox(height: 12),
                        ActivityStrip(
                          matches: _history.take(3).toList(),
                          emptyLabel: l.noActivityYet,
                        ),
                        const SizedBox(height: 24),

                        // ── Upcoming activities ─────────────────────────────
                        ProfileSectionLabel(l.upcomingMatches),
                        const SizedBox(height: 12),
                        ActivityStrip(
                          matches: _upcoming.take(3).toList(),
                          emptyLabel: l.noActivityYet,
                        ),
                        const SizedBox(height: 24),

                        // ── Top sports ───────────────────────────────────────
                        ProfileSectionLabel(l.topSports),
                        const SizedBox(height: 12),
                        TopSportsBars(counts: sportCounts),
                        const SizedBox(height: 24),

                        // ── Groups ───────────────────────────────────────────
                        ProfileSectionLabel(l.groupsTitle),
                        const SizedBox(height: 12),
                        ProfileGroupsStrip(
                          groups: _groups,
                          isMember: context.watch<GroupProvider>().isMember,
                        ),
                        const SizedBox(height: 24),

                        // ── Frequent teammates ───────────────────────────────
                        ProfileSectionLabel(l.frequentTeammates),
                        const SizedBox(height: 12),
                        TopCoPlayersStrip(players: _coPlayers),
                      ],

                      // ── Favourite sports (edit mode only) ───────────────
                      if (_editing) ...[
                        const SizedBox(height: 28),
                        ProfileSectionLabel(l.favouriteSports),
                        const SizedBox(height: 12),
                        _FavouriteSportsPicker(
                          selected: _favoriteSports,
                          editing: true,
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
                      ],

                      const SizedBox(height: 28),
                      const _SignOutButton(),
                    ],
                  ),
                ),
              ),
    );
  }
}

// ─── Avatar header ────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final Profile profile;
  final bool editing;
  final TextEditingController bioCtrl;
  final VoidCallback onTapAvatar;
  final bool isUploadingAvatar;

  const _AvatarHeader({
    required this.profile,
    required this.editing,
    required this.bioCtrl,
    required this.onTapAvatar,
    required this.isUploadingAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final initial = profile.username.isNotEmpty
        ? profile.username[0].toUpperCase()
        : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tappable avatar with camera badge
        GestureDetector(
          onTap: onTapAvatar,
          child: Stack(
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
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isUploadingAvatar
                        ? Colors.grey.shade700
                        : GameOnBrand.saffron,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: GameOnBrand.slateDark, width: 2),
                  ),
                  child: isUploadingAvatar
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt_rounded,
                          size: 12, color: GameOnBrand.slateDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username is always read-only
              Text(
                profile.username,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              if (!editing) _AgeGenderLine(profile: profile),
              if (editing)
                TextField(
                  controller: bioCtrl,
                  maxLines: 2,
                  maxLength: 120,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                  decoration: InputDecoration(
                    hintText: l.bioHint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 4),
                    border: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: GameOnBrand.saffron, width: 2),
                    ),
                    counterStyle: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                )
              else if (profile.bio != null && profile.bio!.isNotEmpty)
                Text(
                  profile.bio!,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                )
              else
                Text(
                  l.noBioYet,
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
              if (!editing && profile.favoriteSports.isNotEmpty)
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
                        child: PhosphorIcon(sport.icon, size: 16, color: sport.color),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

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

// ─── Favourite sports picker ──────────────────────────────────────────────────

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
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(context)!.noFavouritesYet,
          style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        ),
      );
    }

    final sports = editing
        ? SportType.values
        : SportType.values
            .where((s) => selected.contains(s.name))
            .toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sports.map((sport) {
        final isSelected = selected.contains(sport.name);
        return GestureDetector(
          onTap: editing ? () => onToggle(sport.name) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                PhosphorIcon(sport.icon, size: 16, color: GameOnBrand.saffron),
                const SizedBox(width: 6),
                Text(
                  sport.l10nLabel(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected
                        ? GameOnBrand.saffron
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

// ─── Sign out ─────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l.signOut),
              content: Text(l.signOutBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent),
                  child: Text(l.signOutConfirm),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<AuthProvider>().signOut();
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(l.signOutConfirm,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
          side:
              BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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


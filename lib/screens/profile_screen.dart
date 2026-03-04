import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../models/match.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';
import '../widgets/game_on_logo.dart';

// ── Weekday / slot constants ──────────────────────────────────────────────────

const _weekdays = [
  ('monday', 'Mon'),
  ('tuesday', 'Tue'),
  ('wednesday', 'Wed'),
  ('thursday', 'Thu'),
  ('friday', 'Fri'),
  ('saturday', 'Sat'),
  ('sunday', 'Sun'),
];

final _slots = [
  ('morning',   PhosphorIconsLight.sun,      'Morning'),
  ('afternoon', PhosphorIconsLight.cloudSun, 'Afternoon'),
  ('evening',   PhosphorIconsLight.moon,     'Evening'),
];

// ── Sport colour palette ──────────────────────────────────────────────────────

const _sportColors = <SportType, Color>{
  SportType.padel:      Color(0xFF4CAF50),
  SportType.football:   Color(0xFF2196F3),
  SportType.basketball: Color(0xFFFF9800),
  SportType.tennis:     Color(0xFF9C27B0),
  SportType.running:    Color(0xFFE91E63),
  SportType.cycling:    Color(0xFF00BCD4),
  SportType.other:      Color(0xFF607D8B),
};

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
  List<String> _favoriteSports = [];
  List<Match> _history = [];
  List<Match> _upcoming = [];
  bool _dataLoaded = false;

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
      ]);
      if (mounted) {
        setState(() {
          _history = results[0];
          _upcoming = results[1];
          _dataLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dataLoaded = true);
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Profile profile) {
    _bioCtrl.text = profile.bio ?? '';
    _favoriteSports = List<String>.from(profile.favoriteSports);
    setState(() => _editing = true);
  }

  void _cancelEdit() => setState(() => _editing = false);

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<ProfileProvider>().saveProfile(
          bio: _bioCtrl.text.trim(),
          favoriteSports: _favoriteSports,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _editing = false;
    });
  }

  Future<void> _pickAvatar() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: GameOnBrand.saffron),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: GameOnBrand.saffron),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to upload photo. Please try again.'),
        backgroundColor: Colors.redAccent,
      ));
      context.read<ProfileProvider>().clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    // ── Derived stats from match history ────────────────────────────────────
    final sportCounts = <SportType, int>{};
    for (final m in _history) {
      sportCounts[m.sportType] = (sportCounts[m.sportType] ?? 0) + 1;
    }
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final lastWeek =
        _history.where((m) => m.dateTime.isAfter(sevenDaysAgo)).toList();
    final lastWeekMins = lastWeek.fold(0, (s, m) => s + m.durationMinutes);
    SportType? topSport;
    if (sportCounts.isNotEmpty) {
      topSport = sportCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
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
                      // ── Avatar + username + bio ──────────────────────────
                      _AvatarHeader(
                        profile: profile,
                        editing: _editing,
                        bioCtrl: _bioCtrl,
                        onTapAvatar: _pickAvatar,
                        isUploadingAvatar: profileProvider.isUploadingAvatar,
                      ),
                      const SizedBox(height: 24),

                      // ── Stats strip ──────────────────────────────────────
                      _StatsStrip(
                        totalCount: _history.length,
                        lastWeekCount: lastWeek.length,
                        lastWeekMins: lastWeekMins,
                        topSport: topSport,
                      ),

                      // ── Activity breakdown (donut) ───────────────────────
                      if (_dataLoaded && sportCounts.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const _SectionLabel('Activity Breakdown'),
                        const SizedBox(height: 14),
                        _SportDonutChart(counts: sportCounts),
                      ],

                      // ── Upcoming matches ─────────────────────────────────
                      if (_upcoming.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const _SectionLabel('Upcoming Matches'),
                        const SizedBox(height: 12),
                        ..._upcoming
                            .take(5)
                            .map((m) => _MatchRow(match: m)),
                      ],

                      // ── Availability grid ────────────────────────────────
                      const SizedBox(height: 28),
                      const _SectionLabel('My Availability'),
                      const SizedBox(height: 12),
                      const _AvailabilityGrid(),

                      // ── Favourite sports ─────────────────────────────────
                      const SizedBox(height: 28),
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

                      const SizedBox(height: 28),
                      const _SignOutButton(),
                    ],
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
              if (editing)
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
                      borderSide:
                          BorderSide(color: GameOnBrand.saffron, width: 2),
                    ),
                    counterStyle: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                )
              else if (profile.bio != null && profile.bio!.isNotEmpty)
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

// ─── Stats strip ──────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int totalCount;
  final int lastWeekCount;
  final int lastWeekMins;
  final SportType? topSport;

  const _StatsStrip({
    required this.totalCount,
    required this.lastWeekCount,
    required this.lastWeekMins,
    required this.topSport,
  });

  String _timeLabel(int mins) {
    if (mins == 0) return '—';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.chartBar,
            label: 'All time',
            value: '$totalCount',
            sub: 'activities',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.clockCountdown,
            label: 'Last 7 days',
            value: '$lastWeekCount',
            sub: _timeLabel(lastWeekMins),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: PhosphorIconsLight.trophy,
            label: 'Top sport',
            value: '—',
            sub: topSport?.label ?? 'None yet',
            sportIcon: topSport?.icon,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final String value;
  final String sub;
  final PhosphorIconData? sportIcon;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.sportIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, size: 13, color: GameOnBrand.saffron),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (sportIcon != null)
            PhosphorIcon(sportIcon!, size: 26, color: GameOnBrand.saffron)
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity donut chart ─────────────────────────────────────────────────────

class _SportDonutChart extends StatelessWidget {
  final Map<SportType, int> counts;
  const _SportDonutChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = counts.values.fold(0, (a, b) => a + b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(130, 130),
                painter: _DonutPainter(counts: counts, total: total),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'total',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: sorted.map((e) {
              final pct =
                  total > 0 ? (e.value / total * 100).round() : 0;
              final color =
                  _sportColors[e.key] ?? const Color(0xFF607D8B);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: [
                          PhosphorIcon(e.key.icon, size: 12, color: color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.key.label,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${e.value} ($pct%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<SportType, int> counts;
  final int total;

  const _DonutPainter({required this.counts, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.55;
    final arcR = (outerR + innerR) / 2;
    final strokeW = outerR - innerR;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: arcR);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    double start = -pi / 2;
    for (final entry in counts.entries) {
      final sweep = 2 * pi * entry.value / total;
      paint.color = _sportColors[entry.key] ?? const Color(0xFF607D8B);
      canvas.drawArc(rect, start, sweep - 0.04, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.counts != counts || old.total != total;
}

// ─── Upcoming match row ───────────────────────────────────────────────────────

class _MatchRow extends StatelessWidget {
  final Match match;
  const _MatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
            left: BorderSide(color: GameOnBrand.saffron, width: 3)),
      ),
      child: Row(
        children: [
          PhosphorIcon(match.sportType.icon, size: 22, color: GameOnBrand.saffron),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.sportType.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(
                  match.locationName,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('d MMM').format(match.dateTime),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                DateFormat('HH:mm').format(match.dateTime),
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Availability grid ────────────────────────────────────────────────────────

class _AvailabilityGrid extends StatelessWidget {
  const _AvailabilityGrid();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return Column(
      children: [
        // Slot header row
        Row(
          children: [
            const SizedBox(width: 36),
            ..._slots.map((s) => Expanded(
                  child: Center(
                    child: PhosphorIcon(s.$2, size: 15,
                        color: Colors.white.withValues(alpha: 0.5)),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 6),
        // One row per weekday
        ..._weekdays.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    day.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ..._slots.map((slot) {
                  final active = provider.isAvailable(day.$1, slot.$1);
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () =>
                            provider.toggleSlot(day.$1, slot.$1),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 120),
                          height: 30,
                          decoration: BoxDecoration(
                            color: active
                                ? GameOnBrand.saffron
                                    .withValues(alpha: 0.22)
                                : GameOnBrand.slateCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: active
                                  ? GameOnBrand.saffron
                                      .withValues(alpha: 0.55)
                                  : Colors.white
                                      .withValues(alpha: 0.07),
                            ),
                          ),
                          child: active
                              ? const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: GameOnBrand.saffron,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
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

// ─── Sign out ─────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

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
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent),
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

// ─── Section label ────────────────────────────────────────────────────────────

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
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.45),
      ),
    );
  }
}

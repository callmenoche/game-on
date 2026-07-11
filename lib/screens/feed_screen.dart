import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../models/sponsored_post.dart';
import '../providers/match_provider.dart';
import '../utils/error_helpers.dart';
import '../widgets/game_on_logo.dart';
import '../widgets/match_card.dart';
import '../widgets/sponsored_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchMatches();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (!_searchOpen) {
      _searchCtrl.clear();
      context.read<MatchProvider>().setSearchQuery('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: GameOnLogo(size: 32, color: GameOnBrand.saffron),
        ),
        // The brand mark (logo) is enough — the toggle lives here instead of
        // eating a full-height row in the body.
        title: _searchOpen
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchHint,
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4)),
                ),
                onChanged: (q) =>
                    context.read<MatchProvider>().setSearchQuery(q),
              )
            : _FeedModeToggle(),
        actions: [
          IconButton(
            icon: Icon(
                _searchOpen ? Icons.close_rounded : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: context.watch<MatchProvider>().matches.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-match'),
              backgroundColor: GameOnBrand.saffron,
              foregroundColor: GameOnBrand.slateDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.of(context)!.newMatch,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      body: Column(
        children: [
          const SizedBox(height: 4),
          _FilterRow(),
          const Divider(height: 1),
          Expanded(child: _MatchList()),
        ],
      ),
    );
  }
}

// ─── Feed mode toggle ──────────────────────────────────────────────────────

/// Compact Public / My groups toggle — lives in the AppBar title slot.
class _FeedModeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();
    return SegmentedButton<FeedMode>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        backgroundColor:
            Theme.of(context).cardTheme.color?.withValues(alpha: 0.5),
        selectedBackgroundColor: GameOnBrand.saffron.withValues(alpha: 0.18),
        selectedForegroundColor: GameOnBrand.saffron,
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.15)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      segments: [
        ButtonSegment(
          value: FeedMode.public,
          label: Text(AppLocalizations.of(context)!.public),
        ),
        ButtonSegment(
          value: FeedMode.groups,
          label: Text(AppLocalizations.of(context)!.myGroups),
        ),
      ],
      selected: {provider.feedMode},
      onSelectionChanged: (s) => provider.setFeedMode(s.first),
    );
  }
}

// ─── Sport filter chips ────────────────────────────────────────────────────

const _kSportOrder = [
  SportType.padel,
  SportType.football,
  SportType.running,
  SportType.basketball,
  SportType.tennis,
  SportType.cycling,
  SportType.other,
];

/// Single compact filter row: a "tune" button (date + distance live in a
/// bottom sheet, active count shown as a badge) followed by the sport chips.
class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            const SizedBox(width: 12),
            _FilterButton(
              count: provider.activeFilterCount,
              onTap: () => _openFilterSheet(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment(0.85, 0),
                  end: Alignment.centerRight,
                  colors: [Colors.white, Colors.transparent],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _SportChip(
                        label: AppLocalizations.of(context)!.all,
                        icon: null,
                        sport: null,
                        selected: provider.selectedSport == null,
                        onTap: () => provider.setSportFilter(null),
                      ),
                    ),
                    ..._kSportOrder.map((sport) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _SportChip(
                            label: sport.l10nLabel(context),
                            icon: sport.icon,
                            sport: sport,
                            selected: provider.selectedSport == sport,
                            onTap: () => provider.setSportFilter(
                                provider.selectedSport == sport
                                    ? null
                                    : sport),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FilterButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? GameOnBrand.saffron
                : theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded,
                size: 15,
                color: active
                    ? GameOnBrand.saffron
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            if (active) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: GameOnBrand.saffron,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 9,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: GameOnBrand.slateDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Filter bottom sheet (date + distance) ─────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  static const _kmOptions = [2.0, 5.0, 10.0, 25.0, 50.0];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.tune_rounded,
                    color: GameOnBrand.saffron, size: 20),
                const SizedBox(width: 10),
                Text(l.filters,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (provider.activeFilterCount > 0)
                  TextButton(
                    onPressed: provider.resetFilters,
                    child: Text(l.resetFilters,
                        style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6))),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _sectionLabel(context, l.dateAndTime),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _sheetChip(
                  context,
                  label: l.upcoming,
                  selected: provider.dateFilter == DateFilter.upcoming,
                  onTap: () => provider.setDateFilter(DateFilter.upcoming),
                ),
                _sheetChip(
                  context,
                  label: l.today,
                  selected: provider.dateFilter == DateFilter.today,
                  onTap: () => provider.setDateFilter(DateFilter.today),
                ),
                _sheetChip(
                  context,
                  label: l.next7Days,
                  selected: provider.dateFilter == DateFilter.next7,
                  onTap: () => provider.setDateFilter(DateFilter.next7),
                ),
                _sheetChip(
                  context,
                  label: _customRangeLabel(context, provider),
                  selected: provider.dateFilter == DateFilter.custom,
                  icon: Icons.date_range_rounded,
                  onTap: () => _pickCustomRange(context, provider),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel(context, l.distanceFilter),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _sheetChip(
                  context,
                  label: l.filterOff,
                  selected: !provider.distanceFilterEnabled,
                  onTap: provider.disableDistanceFilter,
                ),
                ..._kmOptions.map((km) => _sheetChip(
                      context,
                      label: l.distanceKm(km.round()),
                      selected: provider.distanceFilterEnabled &&
                          provider.distanceKm == km,
                      onTap: () => provider.enableDistanceFilter(km),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: GameOnBrand.saffron,
                  foregroundColor: GameOnBrand.slateDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l.showResults,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _customRangeLabel(BuildContext context, MatchProvider provider) {
    if (provider.dateFilter != DateFilter.custom ||
        provider.customDateRange == null) {
      return AppLocalizations.of(context)!.custom;
    }
    final fmt =
        DateFormat('d MMM', Localizations.localeOf(context).languageCode);
    final r = provider.customDateRange!;
    return '${fmt.format(r.start)} – ${fmt.format(r.end)}';
  }

  Future<void> _pickCustomRange(
      BuildContext context, MatchProvider provider) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: provider.customDateRange,
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
    if (range != null) provider.setCustomDateRange(range);
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      );

  Widget _sheetChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? GameOnBrand.saffron
                : theme.colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected
                      ? GameOnBrand.saffron
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? GameOnBrand.saffron
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final SportType? sport;
  final bool selected;
  final VoidCallback onTap;

  const _SportChip({
    required this.label,
    required this.icon,
    required this.sport,
    required this.selected,
    required this.onTap,
  });

  Color _accentColor() => sport?.color ?? GameOnBrand.saffron;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final unselectedBorder =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25);
    final unselectedText =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : unselectedBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              PhosphorIcon(icon!,
                  size: 13, color: selected ? accent : unselectedText),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? accent : unselectedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Match list ────────────────────────────────────────────────────────────

class _MatchList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    if (provider.isLoading && provider.matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: GameOnBrand.saffron),
      );
    }

    if (provider.matches.isEmpty) {
      return _EmptyState(
        hasSportFilter: provider.selectedSport != null,
        sport: provider.selectedSport,
        dateFilter: provider.dateFilter,
        hasSearch: provider.searchQuery.isNotEmpty,
        hasDistanceFilter: provider.distanceFilterEnabled,
        distanceKm: provider.distanceKm,
      );
    }

    // Interleave sponsored posts: first one after 2 match cards, then
    // every 9 cards; each post appears at most once.
    final sponsored = provider.sponsoredPosts;
    final display = <Object>[];
    var adIdx = 0;
    for (var i = 0; i < provider.matches.length; i++) {
      if (adIdx < sponsored.length && i >= 2 && (i - 2) % 9 == 0) {
        display.add(sponsored[adIdx++]);
      }
      display.add(provider.matches[i]);
    }
    final itemCount = display.length + (provider.hasMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: context.read<MatchProvider>().fetchMatches,
      color: GameOnBrand.saffron,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
              provider.hasMore &&
              !provider.isLoadingMore) {
            context.read<MatchProvider>().fetchMoreMatches();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: itemCount,
          itemBuilder: (context, i) {
            if (i >= display.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: GameOnBrand.saffron),
                ),
              );
            }
            final item = display[i];
            if (item is SponsoredPost) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SponsoredCard(post: item),
              );
            }
            final match = item as Match;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MatchCard(
                match: match,
                isJoined: provider.isJoined(match.id),
                onJoin: () async {
                  final ok = await context.read<MatchProvider>().joinMatch(match.id);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(friendlyError(context.read<MatchProvider>().error, AppLocalizations.of(context)!)),
                      backgroundColor: Colors.redAccent,
                    ));
                  }
                },
                onLeave: () async {
                  final ok = await context.read<MatchProvider>().leaveMatch(match.id);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.couldNotLeaveMatch),
                      backgroundColor: Colors.redAccent,
                    ));
                  }
                },
                onTap: () => context.push('/match/${match.id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSportFilter;
  final SportType? sport;
  final DateFilter dateFilter;
  final bool hasSearch;
  final bool hasDistanceFilter;
  final double distanceKm;

  const _EmptyState({
    required this.hasSportFilter,
    this.sport,
    required this.dateFilter,
    this.hasSearch = false,
    this.hasDistanceFilter = false,
    this.distanceKm = 10.0,
  });

  String _title(AppLocalizations l) {
    if (hasSearch) return l.noMatchesFound;
    if (hasDistanceFilter) return l.noMatchesWithinKm(distanceKm.round());
    final sportLabel = sport?.label ?? '';
    final dateLabel = switch (dateFilter) {
      DateFilter.upcoming => l.dateUpcoming,
      DateFilter.today    => l.dateToday,
      DateFilter.next7    => l.dateNext7,
      DateFilter.next30   => l.dateNext30,
      DateFilter.custom   => l.dateThisPeriod,
    };
    if (hasSportFilter) return l.noMatchesSportDate(sportLabel, dateLabel);
    if (dateFilter != DateFilter.upcoming) return l.noMatchesDate(dateLabel);
    return l.noUpcomingMatches;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final showDateHint = dateFilter != DateFilter.upcoming;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              hasSportFilter
                  ? (sport?.icon ?? PhosphorIconsLight.medal)
                  : PhosphorIconsLight.lightning,
              size: 56,
              color: GameOnBrand.saffron.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _title(l),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/create-match'),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.createMatch),
              style: FilledButton.styleFrom(
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            if (showDateHint) ...[
              const SizedBox(height: 12),
              Text(
                l.widenFilters,
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              l.joinGroup,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

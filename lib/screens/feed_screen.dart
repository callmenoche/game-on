import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../widgets/game_on_logo.dart';
import '../widgets/match_card.dart';
import '../widgets/sport_chip.dart';

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
          child: GameOnLogo(size: 32),
        ),
        title: _searchOpen
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search by sport or location…',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4)),
                ),
                onChanged: (q) =>
                    context.read<MatchProvider>().setSearchQuery(q),
              )
            : Text(
                'GameOn',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
                _searchOpen ? Icons.close_rounded : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
          if (!_searchOpen)
            IconButton(
              icon: const Icon(Icons.person_search_rounded),
              tooltip: 'Find players',
              onPressed: () => context.push('/players/search'),
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-match'),
        backgroundColor: GameOnBrand.saffron,
        foregroundColor: GameOnBrand.slateDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Match',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _FeedModeToggle(),
          _SportFilterBar(),
          _DateFilterBar(),
          const Divider(height: 1),
          Expanded(child: _MatchList()),
        ],
      ),
    );
  }
}

// ─── Feed mode toggle ──────────────────────────────────────────────────────

class _FeedModeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: SegmentedButton<FeedMode>(
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          selectedBackgroundColor:
              GameOnBrand.saffron.withValues(alpha: 0.15),
          selectedForegroundColor: GameOnBrand.saffron,
          side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.15)),
        ),
        segments: const [
          ButtonSegment(
            value: FeedMode.public,
            label: Text('Public'),
            icon: Icon(Icons.public_rounded, size: 16),
          ),
          ButtonSegment(
            value: FeedMode.groups,
            label: Text('My Groups'),
            icon: Icon(Icons.lock_rounded, size: 16),
          ),
        ],
        selected: {provider.feedMode},
        onSelectionChanged: (s) => provider.setFeedMode(s.first),
      ),
    );
  }
}

// ─── Sport filter chips ────────────────────────────────────────────────────

class _SportFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: provider.selectedSport == null,
              onSelected: (_) => provider.setSportFilter(null),
              selectedColor: GameOnBrand.saffron.withValues(alpha: 0.2),
              checkmarkColor: GameOnBrand.saffron,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: provider.selectedSport == null
                    ? GameOnBrand.saffron
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
              ),
              side: BorderSide(
                color: provider.selectedSport == null
                    ? GameOnBrand.saffron
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.15),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          ...SportType.values.map((sport) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SportChip(
                  sport: sport,
                  selected: provider.selectedSport == sport,
                  onSelected: (sel) =>
                      provider.setSportFilter(sel ? sport : null),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Date filter chips ─────────────────────────────────────────────────────

class _DateFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _DateChip(
            label: 'Any date',
            filter: DateFilter.any,
            current: provider.dateFilter,
            onTap: () => provider.setDateFilter(DateFilter.any),
          ),
          const SizedBox(width: 8),
          _DateChip(
            label: 'Today',
            filter: DateFilter.today,
            current: provider.dateFilter,
            onTap: () => provider.setDateFilter(DateFilter.today),
          ),
          const SizedBox(width: 8),
          _DateChip(
            label: 'This week',
            filter: DateFilter.thisWeek,
            current: provider.dateFilter,
            onTap: () => provider.setDateFilter(DateFilter.thisWeek),
          ),
          const SizedBox(width: 8),
          _DistanceChip(
            enabled: provider.distanceFilterEnabled,
            onTap: provider.toggleDistanceFilter,
          ),
        ],
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _DistanceChip({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled
                ? GameOnBrand.saffron
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.near_me_rounded,
                size: 13,
                color: enabled
                    ? GameOnBrand.saffron
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text(
              '≤ 10km',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: enabled
                    ? GameOnBrand.saffron
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateFilter filter;
  final DateFilter current;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.filter,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = filter == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? GameOnBrand.saffron
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? GameOnBrand.saffron
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
          ),
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
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<MatchProvider>().fetchMatches,
      color: GameOnBrand.saffron,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: provider.matches.length,
        itemBuilder: (context, i) {
          final match = provider.matches[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MatchCard(
              match: match,
              isJoined: provider.isJoined(match.id),
              onJoin: () => context.read<MatchProvider>().joinMatch(match.id),
              onLeave: () =>
                  context.read<MatchProvider>().leaveMatch(match.id),
              onTap: () => context.push('/match/${match.id}'),
            ),
          );
        },
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

  const _EmptyState({
    required this.hasSportFilter,
    this.sport,
    required this.dateFilter,
    this.hasSearch = false,
    this.hasDistanceFilter = false,
  });

  String get _title {
    if (hasSearch) return 'No matches found';
    if (hasDistanceFilter) return 'No matches within 10km';
    final sportLabel = sport?.label ?? '';
    final dateLabel = switch (dateFilter) {
      DateFilter.any      => '',
      DateFilter.today    => ' today',
      DateFilter.thisWeek => ' this week',
    };
    if (hasSportFilter) return 'No $sportLabel matches$dateLabel';
    if (dateFilter != DateFilter.any) return 'No matches$dateLabel';
    return 'No matches yet';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
            _title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + New Match to create one!',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

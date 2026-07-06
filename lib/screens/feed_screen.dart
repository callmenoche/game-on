import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../widgets/game_on_logo.dart';
import '../widgets/match_card.dart';

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
                  hintText: AppLocalizations.of(context)!.searchHint,
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
                AppLocalizations.of(context)!.appTitle,
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
              tooltip: AppLocalizations.of(context)!.findPlayers,
              onPressed: () => context.push('/players/search'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-match'),
        backgroundColor: GameOnBrand.saffron,
        foregroundColor: GameOnBrand.slateDark,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.newMatch,
            style: const TextStyle(fontWeight: FontWeight.w700)),
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
          backgroundColor: GameOnBrand.slateCard.withValues(alpha: 0.5),
          selectedBackgroundColor:
              GameOnBrand.saffron.withValues(alpha: 0.18),
          selectedForegroundColor: GameOnBrand.saffron,
          side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.15)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        segments: [
          ButtonSegment(
            value: FeedMode.public,
            label: Text(AppLocalizations.of(context)!.public),
            icon: const Icon(Icons.public_rounded, size: 16),
          ),
          ButtonSegment(
            value: FeedMode.groups,
            label: Text(AppLocalizations.of(context)!.myGroups),
            icon: const Icon(Icons.lock_rounded, size: 16),
          ),
        ],
        selected: {provider.feedMode},
        onSelectionChanged: (s) => provider.setFeedMode(s.first),
      ),
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

class _SportFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return SizedBox(
      height: 42,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment(0.85, 0),
          end: Alignment.centerRight,
          colors: [Colors.white, Colors.transparent],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        provider.selectedSport == sport ? null : sport),
                  ),
                )),
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
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15);
    final unselectedText =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

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

// ─── Date filter chips ─────────────────────────────────────────────────────

class _DateFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _DateChip(
              label: AppLocalizations.of(context)!.upcoming,
              filter: DateFilter.upcoming,
              current: provider.dateFilter,
              onTap: () => provider.setDateFilter(DateFilter.upcoming),
            ),
            const SizedBox(width: 8),
            _DateChip(
              label: AppLocalizations.of(context)!.today,
              filter: DateFilter.today,
              current: provider.dateFilter,
              onTap: () => provider.setDateFilter(DateFilter.today),
            ),
            const SizedBox(width: 8),
            _DateChip(
              label: AppLocalizations.of(context)!.next7Days,
              filter: DateFilter.next7,
              current: provider.dateFilter,
              onTap: () => provider.setDateFilter(DateFilter.next7),
            ),
            const SizedBox(width: 8),
            _DateChip(
              label: AppLocalizations.of(context)!.next30Days,
              filter: DateFilter.next30,
              current: provider.dateFilter,
              onTap: () => provider.setDateFilter(DateFilter.next30),
            ),
            const SizedBox(width: 8),
            _CalendarChip(
              dateFilter: provider.dateFilter,
              customDateRange: provider.customDateRange,
              onRangeSelected: (range) => provider.setCustomDateRange(range),
              onClear: () => provider.setDateFilter(DateFilter.upcoming),
            ),
            const SizedBox(width: 8),
            _GeoChip(
              enabled: provider.distanceFilterEnabled,
              distanceKm: provider.distanceKm,
              onEnable: provider.toggleDistanceFilter,
              onSetDistance: provider.setDistanceKm,
              onDisable: provider.toggleDistanceFilter,
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
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

class _CalendarChip extends StatelessWidget {
  final DateFilter dateFilter;
  final DateTimeRange? customDateRange;
  final ValueChanged<DateTimeRange> onRangeSelected;
  final VoidCallback onClear;

  const _CalendarChip({
    required this.dateFilter,
    required this.customDateRange,
    required this.onRangeSelected,
    required this.onClear,
  });

  String _rangeLabel(BuildContext context) {
    if (customDateRange == null) return AppLocalizations.of(context)!.custom;
    final fmt = DateFormat('d MMM', Localizations.localeOf(context).languageCode);
    return '${fmt.format(customDateRange!.start)} – ${fmt.format(customDateRange!.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = dateFilter == DateFilter.custom && customDateRange != null;
    final unselectedBorder =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15);
    final unselectedText =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () async {
        if (isActive) {
          onClear();
          return;
        }
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
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
        if (range != null) onRangeSelected(range);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? GameOnBrand.saffron : unselectedBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.close_rounded : Icons.date_range_rounded,
              size: 13,
              color: isActive ? GameOnBrand.saffron : unselectedText,
            ),
            const SizedBox(width: 4),
            Text(
              _rangeLabel(context),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? GameOnBrand.saffron : unselectedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeoChip extends StatelessWidget {
  final bool enabled;
  final double distanceKm;
  final VoidCallback onEnable;
  final ValueChanged<double> onSetDistance;
  final VoidCallback onDisable;

  const _GeoChip({
    required this.enabled,
    required this.distanceKm,
    required this.onEnable,
    required this.onSetDistance,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedBorder =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15);
    final unselectedText =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () {
        if (!enabled) {
          onEnable();
        } else {
          _showRadiusSheet(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: enabled
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? GameOnBrand.saffron : unselectedBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.near_me_rounded,
              size: 13,
              color: enabled ? GameOnBrand.saffron : unselectedText,
            ),
            const SizedBox(width: 4),
            Text(
              enabled
                  ? AppLocalizations.of(context)!.distanceKm(distanceKm.round())
                  : AppLocalizations.of(context)!.nearby,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: enabled ? GameOnBrand.saffron : unselectedText,
              ),
            ),
            if (enabled) ...[
              const SizedBox(width: 2),
              const Icon(Icons.expand_more_rounded,
                  size: 13, color: GameOnBrand.saffron),
            ],
          ],
        ),
      ),
    );
  }

  void _showRadiusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameOnBrand.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _RadiusSheet(
        currentKm: distanceKm,
        onSetDistance: (km) {
          Navigator.of(ctx).pop();
          onSetDistance(km);
        },
        onDisable: () {
          Navigator.of(ctx).pop();
          onDisable();
        },
      ),
    );
  }
}

class _RadiusSheet extends StatelessWidget {
  final double currentKm;
  final ValueChanged<double> onSetDistance;
  final VoidCallback onDisable;

  const _RadiusSheet({
    required this.currentKm,
    required this.onSetDistance,
    required this.onDisable,
  });

  static const _options = [2.0, 5.0, 10.0, 25.0, 50.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.near_me_rounded,
                  color: GameOnBrand.saffron, size: 20),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.distanceFilter,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((km) {
              final selected = km == currentKm;
              return GestureDetector(
                onTap: () => onSetDistance(km),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? GameOnBrand.saffron.withValues(alpha: 0.15)
                        : GameOnBrand.slateDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? GameOnBrand.saffron
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.distanceKm(km.round()),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? GameOnBrand.saffron
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onDisable,
            child: Text(
              AppLocalizations.of(context)!.turnOffNearbyFilter,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
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

    final itemCount = provider.matches.length + (provider.hasMore ? 1 : 0);

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
            if (i >= provider.matches.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: GameOnBrand.saffron),
                ),
              );
            }
            final match = provider.matches[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MatchCard(
                match: match,
                isJoined: provider.isJoined(match.id),
                onJoin: () async {
                  final ok = await context.read<MatchProvider>().joinMatch(match.id);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(context.read<MatchProvider>().error ?? AppLocalizations.of(context)!.somethingWentWrong),
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
            _title(l),
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l.tapToCreate,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

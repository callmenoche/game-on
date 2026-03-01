import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchMatches();
    });
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
        title: Text(
          'GameOn',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
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
          _SportFilterBar(),
          const Divider(height: 1),
          Expanded(child: _MatchList()),
        ],
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
          // "All" chip
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
          // Per-sport chips
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

// ─── Match list ────────────────────────────────────────────────────────────

class _MatchList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    // Loading skeleton
    if (provider.isLoading && provider.matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: GameOnBrand.saffron),
      );
    }

    // Empty state
    if (provider.matches.isEmpty) {
      return _EmptyState(
        hasSportFilter: provider.selectedSport != null,
        sport: provider.selectedSport,
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
              onLeave: () => context.read<MatchProvider>().leaveMatch(match.id),
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

  const _EmptyState({required this.hasSportFilter, this.sport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasSportFilter ? (sport?.emoji ?? '🏅') : '🏟️',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            hasSportFilter
                ? 'No ${sport?.label ?? ''} matches'
                : 'No matches yet',
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

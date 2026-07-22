import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../models/match.dart';
import 'game_on_logo.dart';

/// Shared "very visual" profile sections — used by both the own-profile
/// screen and the public-profile screen so the two stay in sync.

// ─── Section header ──────────────────────────────────────────────────────

class ProfileSectionLabel extends StatelessWidget {
  final String text;
  const ProfileSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}

// ─── Activity strip (recent / upcoming) ──────────────────────────────────

class ActivityStrip extends StatelessWidget {
  final List<Match> matches;
  final String emptyLabel;
  const ActivityStrip({super.key, required this.matches, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Container(
        height: 64,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          emptyLabel,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _ActivityCard(match: matches[i]),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Match match;
  const _ActivityCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = match.sportType.color;
    final locale = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: () => context.push('/match/${match.id}'),
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhosphorIcon(match.sportType.icon, size: 22, color: color),
            const Spacer(),
            Text(
              DateFormat('d MMM', locale).format(match.dateTime),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            Text(
              DateFormat('HH:mm').format(match.dateTime),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              match.locationName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top sports — ranked bar list ─────────────────────────────────────────

class TopSportsBars extends StatelessWidget {
  final Map<SportType, int> counts;
  const TopSportsBars({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (counts.isEmpty) {
      return Container(
        height: 56,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          l.noActivityYet,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    return Column(
      children: sorted.map((e) {
        final fraction = e.value / maxCount;
        final color = e.key.color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Stack(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.12, 1.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      PhosphorIcon(e.key.icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key.l10nLabel(context),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Groups strip ─────────────────────────────────────────────────────────

class ProfileGroupsStrip extends StatelessWidget {
  final List<Group> groups;
  final bool Function(String groupId) isMember;
  const ProfileGroupsStrip(
      {super.key, required this.groups, required this.isMember});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (groups.isEmpty) {
      return Container(
        height: 56,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          l.noGroupsToShow,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final g = groups[i];
          final canOpen = isMember(g.id);
          return GestureDetector(
            onTap: canOpen ? () => context.push('/groups/${g.id}') : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GameOnBrand.saffron.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.group_rounded,
                        size: 17, color: GameOnBrand.saffron),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l.nMembers(g.memberCount),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Top co-players strip ─────────────────────────────────────────────────

typedef CoPlayer = ({String userId, String username, String? avatarUrl, int count});

class TopCoPlayersStrip extends StatelessWidget {
  final List<CoPlayer> players;
  const TopCoPlayersStrip({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (players.isEmpty) {
      return Container(
        height: 88,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          l.noCoPlayersYet,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final p = players[i];
          final initial =
              p.username.isNotEmpty ? p.username[0].toUpperCase() : '?';
          return GestureDetector(
            onTap: () => context.push('/player/${p.userId}'),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            GameOnBrand.saffron.withValues(alpha: 0.18),
                        backgroundImage: p.avatarUrl != null
                            ? CachedNetworkImageProvider(p.avatarUrl!)
                            : null,
                        child: p.avatarUrl == null
                            ? Text(initial,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: GameOnBrand.saffron,
                                    fontSize: 18))
                            : null,
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GameOnBrand.saffron,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Theme.of(context).cardTheme.color ??
                                    Colors.transparent,
                                width: 2),
                          ),
                          child: Text(
                            '${p.count}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: GameOnBrand.slateDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

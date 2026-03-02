import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import 'game_on_logo.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final bool isJoined;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onTap;

  const MatchCard({
    super.key,
    required this.match,
    required this.isJoined,
    required this.onJoin,
    required this.onLeave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? GameOnBrand.slateCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: _sportColor(match.sportType), width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(match: match),
              const SizedBox(height: 10),
              _InfoRow(match: match),
              const SizedBox(height: 14),
              _Footer(
                  match: match,
                  isJoined: isJoined,
                  onJoin: onJoin,
                  onLeave: onLeave),
            ],
          ),
        ),
      ),
    );
  }

  Color _sportColor(SportType sport) => switch (sport) {
        SportType.padel      => const Color(0xFF00C2A8),
        SportType.football   => const Color(0xFF4CAF50),
        SportType.basketball => const Color(0xFFFF6B2B),
        SportType.tennis     => const Color(0xFFD4E157),
        SportType.running    => const Color(0xFF42A5F5),
        SportType.cycling    => const Color(0xFFAB47BC),
        SportType.other      => GameOnBrand.saffron,
      };
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Match match;
  const _Header({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(match.sportType.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.sportType.label,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      match.locationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(match: match),
            const SizedBox(height: 4),
            _SkillBadge(level: match.skillLevel),
          ],
        ),
      ],
    );
  }
}

// ─── Info row ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final Match match;
  const _InfoRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final distKm =
        context.watch<MatchProvider>().distanceFromUser(match);

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              DateFormat('EEE d MMM  •  HH:mm').format(match.dateTime),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              match.durationLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (distKm != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.near_me_rounded, size: 13, color: color),
              const SizedBox(width: 3),
              Text(
                distKm < 1
                    ? '${(distKm * 1000).round()}m'
                    : '${distKm.toStringAsFixed(1)}km',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
      ],
    );
  }
}

// ─── Footer ────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final Match match;
  final bool isJoined;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _Footer({
    required this.match,
    required this.isJoined,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SpotsIndicator(match: match)),
        const SizedBox(width: 12),
        _JoinButton(
            match: match, isJoined: isJoined, onJoin: onJoin, onLeave: onLeave),
      ],
    );
  }
}

// ─── Status badge ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final Match match;
  const _StatusBadge({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.isConfirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'CONFIRMED',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.green,
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    final isFull = match.status == MatchStatus.full;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.redAccent.withValues(alpha: 0.12)
            : GameOnBrand.saffron.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isFull ? 'FULL' : 'OPEN',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: isFull ? Colors.redAccent : GameOnBrand.saffron,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Skill badge ───────────────────────────────────────────────────────────

class _SkillBadge extends StatelessWidget {
  final SkillLevel level;
  const _SkillBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(level.emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            level.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: level.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Spots indicator ───────────────────────────────────────────────────────

class _SpotsIndicator extends StatelessWidget {
  final Match match;
  const _SpotsIndicator({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (match.isUnlimited) {
      return Row(
        children: [
          Icon(Icons.all_inclusive_rounded,
              size: 16,
              color: GameOnBrand.saffron.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            'Open to all',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final taken = match.spotsTaken;
    final total = match.totalSpots!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$taken / $total players',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: List.generate(total, (i) {
            final filled = i < taken;
            return Container(
              margin: const EdgeInsets.only(right: 5),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? GameOnBrand.saffron
                    : GameOnBrand.saffron.withValues(alpha: 0.18),
                border: Border.all(
                  color: GameOnBrand.saffron.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Join / Leave button ───────────────────────────────────────────────────

class _JoinButton extends StatelessWidget {
  final Match match;
  final bool isJoined;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _JoinButton({
    required this.match,
    required this.isJoined,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    if (isJoined) {
      return OutlinedButton(
        onPressed: onLeave,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: GameOnBrand.saffron),
          foregroundColor: GameOnBrand.saffron,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child:
            const Text('Leave', style: TextStyle(fontWeight: FontWeight.w700)),
      );
    }

    return FilledButton(
      onPressed: match.isFull ? null : onJoin,
      style: FilledButton.styleFrom(
        backgroundColor: GameOnBrand.saffron,
        foregroundColor: GameOnBrand.slateDark,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        disabledBackgroundColor: GameOnBrand.saffron.withValues(alpha: 0.25),
      ),
      child: Text(
        match.isFull ? 'Full' : 'Join',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

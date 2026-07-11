import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import 'game_on_logo.dart';

class MatchCard extends StatefulWidget {
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
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sportColor = widget.match.sportType.color;
    final baseColor = isDark ? GameOnBrand.slateCard : Colors.white;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            // Faded sport-coloured wash over the card surface
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(baseColor, sportColor, isDark ? 0.20 : 0.10)!,
                Color.lerp(baseColor, sportColor, isDark ? 0.06 : 0.03)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: sportColor, width: 4),
            ),
            boxShadow: [
              // Sport-tinted glow
              BoxShadow(
                color: sportColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              // Ambient
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Big faded sport icon watermark
              Positioned(
                right: -18,
                bottom: -22,
                child: Transform.rotate(
                  angle: -math.pi / 14,
                  child: PhosphorIcon(
                    widget.match.sportType.icon,
                    size: 120,
                    color: sportColor.withValues(alpha: isDark ? 0.09 : 0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(match: widget.match),
                    if (widget.match.creatorUsername != null) ...[
                      const SizedBox(height: 8),
                      _CreatorBadge(
                        username: widget.match.creatorUsername!,
                        avatarUrl: widget.match.creatorAvatarUrl,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _InfoRow(match: widget.match),
                    const SizedBox(height: 14),
                    _Footer(
                      match: widget.match,
                      isJoined: widget.isJoined,
                      onJoin: widget.onJoin,
                      onLeave: widget.onLeave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Creator badge ──────────────────────────────────────────────────────────

class _CreatorBadge extends StatelessWidget {
  final String username;
  final String? avatarUrl;

  const _CreatorBadge({required this.username, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GameOnBrand.slateLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: GameOnBrand.slateLight.withValues(alpha: 0.3),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person_rounded,
                    size: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))
                : null,
          ),
          const SizedBox(width: 5),
          Text(
            '@$username',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Match match;
  const _Header({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTitle = match.title != null && match.title!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhosphorIcon(match.sportType.icon,
            size: 36, color: match.sportType.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasTitle
                    ? match.sportType.l10nLabel(context).toUpperCase()
                    : match.sportType.l10nLabel(context),
                style: hasTitle
                    ? theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.45),
                        letterSpacing: 0.5,
                      )
                    : theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
              ),
              if (hasTitle)
                Text(
                  match.title!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.95),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      match.locationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.70),
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
            if (match.isGenderRestricted) ...[
              const SizedBox(height: 4),
              _GenderBadge(match: match),
            ],
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
    final distKm = context.watch<MatchProvider>().distanceFromUser(match);

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
            const SizedBox(width: 4),
            Text(
              DateFormat(
                      'EEE d MMM  •  HH:mm',
                      Localizations.localeOf(context).languageCode)
                  .format(match.dateTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                size: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
            const SizedBox(width: 3),
            Text(
              match.durationLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (distKm != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.near_me_rounded,
                  size: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
              const SizedBox(width: 3),
              Text(
                distKm < 1
                    ? '${(distKm * 1000).round()}m'
                    : '${distKm.toStringAsFixed(1)}km',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
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
            match: match,
            isJoined: isJoined,
            onJoin: onJoin,
            onLeave: onLeave),
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
        isFull
            ? AppLocalizations.of(context)!.fullBadge
            : AppLocalizations.of(context)!.open,
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
          PhosphorIcon(level.icon, size: 10, color: level.color),
          const SizedBox(width: 3),
          Text(
            level.l10nLabel(context),
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

// ─── Gender badge ─────────────────────────────────────────────────────────

class _GenderBadge extends StatelessWidget {
  final Match match;
  const _GenderBadge({required this.match});

  @override
  Widget build(BuildContext context) {
    const badgeColor = Color(0xFFAB47BC);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PhosphorIcon(PhosphorIconsLight.genderIntersex,
              size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            match.genderRestrictionLabel(context),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: badgeColor,
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

  static const _maxCircles = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final participants =
        context.watch<MatchProvider>().participantsFor(match.id);

    if (match.isUnlimited) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (participants.isNotEmpty) ...[
            _avatarWrap(context, participants, participants.length),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(Icons.all_inclusive_rounded,
                  size: 16,
                  color: GameOnBrand.saffron.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                l.openToAll,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      );
    }

    final taken = match.spotsTaken;
    final total = match.totalSpots!;
    final remaining = (total - taken).clamp(0, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.spotsAvailable,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        _avatarWrap(context, participants, total, taken: taken),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded,
                size: 14,
                color: remaining > 0
                    ? GameOnBrand.saffron
                    : Colors.redAccent.withValues(alpha: 0.8)),
            const SizedBox(width: 5),
            Text(
              l.spotsRemaining(remaining),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: remaining > 0
                    ? GameOnBrand.saffron
                    : Colors.redAccent.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// One circle per spot: participant avatar (golden ring), generic icon for
  /// unclaimed guest spots, outlined empty circle for free spots.
  Widget _avatarWrap(BuildContext context, List<FeedParticipant> participants,
      int total,
      {int? taken}) {
    final circles = <Widget>[];
    final shown = math.min(total, _maxCircles);
    for (var i = 0; i < shown; i++) {
      if (i < participants.length) {
        circles.add(_ParticipantDot(participant: participants[i]));
      } else if (taken != null && i < taken) {
        // Participants not loaded yet (or optimistic join): filled fallback
        circles.add(const _ParticipantDot(participant: null));
      } else {
        circles.add(const _EmptyDot());
      }
    }
    if (total > _maxCircles) {
      circles.add(_OverflowDot(count: total - _maxCircles));
    }
    return Wrap(spacing: 5, runSpacing: 5, children: circles);
  }
}

class _ParticipantDot extends StatelessWidget {
  final FeedParticipant? participant; // null = filled fallback
  const _ParticipantDot({required this.participant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuest = participant?.isGuest ?? false;
    final avatarUrl = participant?.avatarUrl;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isGuest
              ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
              : GameOnBrand.saffron,
          width: 1.5,
        ),
        color: isGuest
            ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
            : GameOnBrand.saffron.withValues(alpha: 0.18),
        image: avatarUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(avatarUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? Icon(
              isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
              size: 13,
              color: isGuest
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                  : GameOnBrand.saffron,
            )
          : null,
    );
  }
}

class _EmptyDot extends StatelessWidget {
  const _EmptyDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
    );
  }
}

class _OverflowDot extends StatelessWidget {
  final int count;
  const _OverflowDot({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
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
        child: Text(AppLocalizations.of(context)!.leave,
            style: const TextStyle(fontWeight: FontWeight.w700)),
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
        match.isFull
            ? AppLocalizations.of(context)!.full
            : AppLocalizations.of(context)!.join,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

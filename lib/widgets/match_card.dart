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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: const Alignment(0.6, 1.0),
              colors: [
                Color.lerp(baseColor, sportColor, 0.05)!,
                baseColor,
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
          child: Padding(
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
            AppLocalizations.of(context)!.openToAll,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
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
          AppLocalizations.of(context)!.spotsCount(taken, total),
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                theme.colorScheme.onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w700,
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

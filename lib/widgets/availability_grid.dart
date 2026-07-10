import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import 'game_on_logo.dart';

// Day keys (DB) + reference dates for locale-aware abbreviations (Mon = 6 Jan 2025)
const _dayKeys = [
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
];
final _dayDates = [
  DateTime(2025, 1, 6), DateTime(2025, 1, 7), DateTime(2025, 1, 8),
  DateTime(2025, 1, 9), DateTime(2025, 1, 10), DateTime(2025, 1, 11),
  DateTime(2025, 1, 12),
];

// Slot keys (DB) + icons (no hardcoded labels — use l10n in build)
const _slotKeys = ['morning', 'afternoon', 'evening'];
const _slotIcons = [
  PhosphorIconsLight.sun,
  PhosphorIconsLight.cloudSun,
  PhosphorIconsLight.moon,
];

/// Reusable weekly availability grid — calendar-screen aesthetic.
/// Reads from [ProfileProvider] via context; handles loading state internally.
class AvailabilityGrid extends StatelessWidget {
  const AvailabilityGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<ProfileProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    final dayFmt = DateFormat('EEE', locale);
    final slotLabels = [l.morning, l.afternoon, l.evening];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l.weeklyAvailability),
        const SizedBox(height: 4),
        Text(
          l.whenFreeToPlay,
          style: TextStyle(
              fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 14),
        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: GameOnBrand.saffron),
            ),
          )
        else ...[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(_dayKeys.length, (i) {
                final dayKey = _dayKeys[i];
                final dayLabel = dayFmt.format(_dayDates[i]);
                final isWeekend =
                    dayKey == 'saturday' || dayKey == 'sunday';
                final isLast = i == _dayKeys.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 34,
                            child: Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isWeekend
                                    ? GameOnBrand.saffron
                                        .withValues(alpha: 0.75)
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: List.generate(_slotKeys.length,
                                  (j) {
                                final active = provider.isAvailable(
                                    dayKey, _slotKeys[j]);
                                return _SlotChip(
                                  icon: _slotIcons[j],
                                  active: active,
                                  onTap: () => provider.toggleSlot(
                                      dayKey, _slotKeys[j]),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: GameOnBrand.slateLight.withValues(alpha: 0.25),
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slotKeys.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    PhosphorIcon(_slotIcons[i],
                        size: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)),
                    const SizedBox(width: 4),
                    Text(
                      slotLabels[i],
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ─── Slot chip ────────────────────────────────────────────────────────────────

class _SlotChip extends StatelessWidget {
  final PhosphorIconData icon;
  final bool active;
  final VoidCallback onTap;

  const _SlotChip({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 38,
        decoration: BoxDecoration(
          color: active
              ? GameOnBrand.saffron.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? GameOnBrand.saffron.withValues(alpha: 0.6)
                : GameOnBrand.slateLight.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: PhosphorIcon(
            icon,
            size: 18,
            color: active
                ? GameOnBrand.saffron
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
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

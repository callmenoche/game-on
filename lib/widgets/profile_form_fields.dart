import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import 'game_on_logo.dart';

// ─── Date field ───────────────────────────────────────────────────────────────

/// Tappable date field that shows the selected date or a placeholder.
/// Displays computed age as a badge when a date is selected.
class DateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const DateField({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final hasValue = value != null;
    final displayText = hasValue
        ? DateFormat('d MMM yyyy', locale).format(value!)
        : l.selectDate;

    int? ageDisplay;
    if (hasValue) {
      final today = DateTime.now();
      int years = today.year - value!.year;
      if (today.month < value!.month ||
          (today.month == value!.month && today.day < value!.day)) {
        years--;
      }
      ageDisplay = years;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? GameOnBrand.saffron.withValues(alpha: 0.4)
                : GameOnBrand.slateLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_rounded,
              size: 18,
              color: hasValue
                  ? GameOnBrand.saffron
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
            if (ageDisplay != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GameOnBrand.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$ageDisplay',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: GameOnBrand.saffron,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gender picker ────────────────────────────────────────────────────────────

/// Three-chip gender selector (M / F / X). Tapping the active chip deselects.
class GenderPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const GenderPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = [('M', l.male), ('F', l.female), ('X', l.nonBinary)];
    return Row(
      children: List.generate(options.length, (i) {
        final code  = options[i].$1;
        final label = options[i].$2;
        final isSelected = value == code;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(isSelected ? null : code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GameOnBrand.saffron.withValues(alpha: 0.2)
                      : GameOnBrand.slateCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? GameOnBrand.saffron.withValues(alpha: 0.6)
                        : GameOnBrand.slateLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? GameOnBrand.saffron
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? GameOnBrand.saffron.withValues(alpha: 0.7)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Privacy toggle ───────────────────────────────────────────────────────────

/// Small visibility toggle row used for profile field privacy settings.
class PrivacyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PrivacyToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.visibility_rounded,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: GameOnBrand.saffron,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

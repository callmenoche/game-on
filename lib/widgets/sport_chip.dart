import 'package:flutter/material.dart';
import '../models/match.dart';
import 'game_on_logo.dart';

class SportChip extends StatelessWidget {
  final SportType sport;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const SportChip({
    super.key,
    required this.sport,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      avatar: Text(sport.emoji, style: const TextStyle(fontSize: 14)),
      label: Text(sport.label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: GameOnBrand.saffron.withValues(alpha: 0.2),
      checkmarkColor: GameOnBrand.saffron,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected
            ? GameOnBrand.saffron
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      side: BorderSide(
        color: selected
            ? GameOnBrand.saffron
            : theme.colorScheme.onSurface.withValues(alpha: 0.15),
      ),
      backgroundColor: Colors.transparent,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

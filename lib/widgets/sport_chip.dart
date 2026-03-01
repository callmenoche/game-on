// Filter chip used in the Feed to filter by sport type
import 'package:flutter/material.dart';
import '../models/match.dart';

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
    return FilterChip(
      avatar: Text(sport.emoji),
      label: Text(sport.label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

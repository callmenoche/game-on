// TODO: Implement MatchCard widget
// Shows: sport emoji + name, location, date/time, spots remaining, Join button
import 'package:flutter/material.dart';
import '../models/match.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onJoin;

  const MatchCard({super.key, required this.match, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(match.sportType.emoji, style: const TextStyle(fontSize: 28)),
        title: Text('${match.sportType.label} @ ${match.locationName}'),
        subtitle: Text('${match.playersNeeded} spots left'),
        trailing: ElevatedButton(
          onPressed: match.isFull ? null : onJoin,
          child: Text(match.isFull ? 'Full' : 'Join'),
        ),
      ),
    );
  }
}

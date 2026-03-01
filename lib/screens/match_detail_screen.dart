// TODO: Implement Match Detail + real-time participant list
// Depends on: MatchService.watchMatch, MatchService.watchParticipants
import 'package:flutter/material.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Detail')),
      body: Center(child: Text('Match $matchId – coming next')),
    );
  }
}

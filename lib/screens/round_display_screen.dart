import 'package:flutter/material.dart';
import '../models/round.dart';
import '../widgets/match_card.dart';

class RoundDisplayScreen extends StatelessWidget {
  final Round round;

  const RoundDisplayScreen({super.key, required this.round});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Runde ${round.roundNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Display all matches
          ...round.matches.map((match) => MatchCard(match: match)),

          // Display players on break
          if (round.playersOnBreak.isNotEmpty)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pause_circle, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Pause',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: round.playersOnBreak
                          .map((player) => Chip(label: Text(player.name)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

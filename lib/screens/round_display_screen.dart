import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/persistence_service.dart';
import '../widgets/match_card.dart';
import 'setup_screen.dart';

class RoundDisplayScreen extends StatefulWidget {
  final Tournament tournament;

  const RoundDisplayScreen({super.key, required this.tournament});

  @override
  State<RoundDisplayScreen> createState() => _RoundDisplayScreenState();
}

class _RoundDisplayScreenState extends State<RoundDisplayScreen> {
  final PersistenceService _persistenceService = PersistenceService();

  Future<void> _resetTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nulstil Turnering'),
        content: const Text(
          'Er du sikker på at du vil nulstille turneringen? '
          'Alt data vil blive slettet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Nulstil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _persistenceService.clearTournament();
      
      // Navigate to setup screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SetupScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.tournament.currentRound;
    
    if (round == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Turnering'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetTournament,
              tooltip: 'Nulstil turnering',
            ),
          ],
        ),
        body: const Center(
          child: Text('Ingen runder genereret endnu'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Runde ${round.roundNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTournament,
            tooltip: 'Nulstil turnering',
          ),
        ],
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

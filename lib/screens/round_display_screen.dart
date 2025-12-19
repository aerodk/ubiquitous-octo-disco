import 'package:flutter/material.dart';
import '../models/round.dart';
import '../models/player.dart';
import '../models/court.dart';
import '../widgets/match_card.dart';
import '../services/tournament_service.dart';
import 'score_input_screen.dart';

class RoundDisplayScreen extends StatefulWidget {
  final Round round;
  final List<Player> players;
  final List<Court> courts;
  final List<Round> previousRounds;
  final TournamentService tournamentService;

  const RoundDisplayScreen({
    super.key,
    required this.round,
    required this.players,
    required this.courts,
    required this.previousRounds,
    required this.tournamentService,
  });

  @override
  State<RoundDisplayScreen> createState() => _RoundDisplayScreenState();
}

class _RoundDisplayScreenState extends State<RoundDisplayScreen> {
  late Round _currentRound;
  late List<Round> _allRounds;

  @override
  void initState() {
    super.initState();
    _currentRound = widget.round;
    _allRounds = [...widget.previousRounds, _currentRound];
  }

  Future<void> _inputScore(int matchIndex) async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreInputScreen(
          match: _currentRound.matches[matchIndex],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentRound.matches[matchIndex].team1Score = result['team1Score'];
        _currentRound.matches[matchIndex].team2Score = result['team2Score'];
      });
    }
  }

  void _generateNextRound() {
    if (!_currentRound.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle kampe skal have indtastet score først'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nextRound = widget.tournamentService.generateNextRound(
      players: widget.players,
      courts: widget.courts,
      previousRounds: _allRounds,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoundDisplayScreen(
          round: nextRound,
          players: widget.players,
          courts: widget.courts,
          previousRounds: _allRounds,
          tournamentService: widget.tournamentService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Runde ${_currentRound.roundNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Display all matches
          ..._currentRound.matches.asMap().entries.map(
                (entry) => MatchCard(
                  match: entry.value,
                  onTap: !entry.value.isCompleted
                      ? () => _inputScore(entry.key)
                      : null,
                ),
              ),

          // Display players on break
          if (_currentRound.playersOnBreak.isNotEmpty)
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
                      children: _currentRound.playersOnBreak
                          .map((player) => Chip(label: Text(player.name)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Generate next round button
          if (_currentRound.isCompleted)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateNextRound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Generer Næste Runde',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

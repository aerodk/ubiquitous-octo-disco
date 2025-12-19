import 'package:flutter/material.dart';
import '../models/match.dart';
import '../widgets/score_button_grid.dart';

class ScoreInputScreen extends StatefulWidget {
  final Match match;

  const ScoreInputScreen({super.key, required this.match});

  @override
  State<ScoreInputScreen> createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  int? team1Score;
  int? team2Score;

  void _onTeam1ScoreSelected(int score) {
    setState(() {
      team1Score = score;
      // Auto-calculate team2 score (total is 24)
      team2Score = 24 - score;
    });
  }

  void _onTeam2ScoreSelected(int score) {
    setState(() {
      team2Score = score;
      // Auto-calculate team1 score (total is 24)
      team1Score = 24 - score;
    });
  }

  void _saveScore() {
    Navigator.pop(context, {
      'team1Score': team1Score,
      'team2Score': team2Score,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indtast Score'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Par 1 info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Par 1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.match.team1.player1.name} & ${widget.match.team1.player2.name}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (team1Score != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Score: $team1Score',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ScoreButtonGrid(
              selectedScore: team1Score,
              onScoreSelected: _onTeam1ScoreSelected,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Par 2 info
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Par 2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.match.team2.player1.name} & ${widget.match.team2.player2.name}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (team2Score != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Score: $team2Score',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ScoreButtonGrid(
              selectedScore: team2Score,
              onScoreSelected: _onTeam2ScoreSelected,
              color: Colors.red,
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: team1Score != null && team2Score != null
                  ? _saveScore
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Gem Score',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

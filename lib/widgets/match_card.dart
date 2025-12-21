import 'package:flutter/material.dart';
import '../models/match.dart';

class MatchCard extends StatefulWidget {
  final Match match;
  final VoidCallback? onScoreChanged;
  final int maxPoints;

  const MatchCard({
    super.key,
    required this.match,
    this.onScoreChanged,
    this.maxPoints = 24,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  void _showScoreInput() {
    showDialog(
      context: context,
      builder: (context) => ScoreInputDialog(
        match: widget.match,
        maxPoints: widget.maxPoints,
      ),
    ).then((result) {
      if (result != null && result is Map && mounted) {
        final team1 = result['team1Score'] as int?;
        final team2 = result['team2Score'] as int?;
        if (team1 != null && team2 != null) {
          setState(() {
            widget.match.team1Score = team1;
            widget.match.team2Score = team2;
          });
          // Notify parent that score changed
          widget.onScoreChanged?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasScores = widget.match.team1Score != null && widget.match.team2Score != null;
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: _showScoreInput,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sports_tennis, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    widget.match.court.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (hasScores)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    const Icon(Icons.edit, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              _buildTeam('Par 1', widget.match.team1, widget.match.team1Score),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'VS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              _buildTeam('Par 2', widget.match.team2, widget.match.team2Score),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(String label, Team team, int? score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${team.player1.name} & ${team.player2.name}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class ScoreInputDialog extends StatefulWidget {
  final Match match;
  final int maxPoints;

  const ScoreInputDialog({
    super.key,
    required this.match,
    this.maxPoints = 24,
  });

  @override
  State<ScoreInputDialog> createState() => _ScoreInputDialogState();
}

class _ScoreInputDialogState extends State<ScoreInputDialog> {
  int? _team1Score;
  int? _team2Score;

  @override
  void initState() {
    super.initState();
    _team1Score = widget.match.team1Score;
    _team2Score = widget.match.team2Score;
  }

  void _selectScore(bool isTeam1, int score) {
    setState(() {
      if (isTeam1) {
        _team1Score = score;
        // Auto-calculate team 2 score (total points - team1)
        _team2Score = widget.maxPoints - score;
      } else {
        _team2Score = score;
        // Auto-calculate team 1 score (total points - team2)
        _team1Score = widget.maxPoints - score;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Indtast Score - ${widget.match.court.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team 1
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Par 1',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.match.team1.player1.name} & ${widget.match.team1.player2.name}',
                    ),
                    const SizedBox(height: 8),
                    if (_team1Score != null)
                      Text(
                        'Score: $_team1Score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(widget.maxPoints + 1, (index) {
                final isSelected = _team1Score == index;
                return SizedBox(
                  width: 50,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _selectScore(true, index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text('$index'),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Team 2
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Par 2',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.match.team2.player1.name} & ${widget.match.team2.player2.name}',
                    ),
                    const SizedBox(height: 8),
                    if (_team2Score != null)
                      Text(
                        'Score: $_team2Score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: _team1Score != null && _team2Score != null
              ? () {
                  Navigator.pop(context, {
                    'team1Score': _team1Score,
                    'team2Score': _team2Score,
                  });
                }
              : null,
          child: const Text('Gem Score'),
        ),
      ],
    );
  }
}

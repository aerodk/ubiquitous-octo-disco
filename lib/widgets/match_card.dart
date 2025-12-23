import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../utils/colors.dart';
import 'court_visualization/team_side.dart';
import 'court_visualization/net_divider.dart';

/// Match card with court visualization layout
/// F-018, F-019: Court Visualization with Side-by-Side Layout & Match Card Redesign
class MatchCard extends StatefulWidget {
  final Match match;
  final VoidCallback? onScoreChanged;
  final int maxPoints;
  final Function(Player)? onPlayerForceToPause;

  const MatchCard({
    super.key,
    required this.match,
    this.onScoreChanged,
    this.maxPoints = 24,
    this.onPlayerForceToPause,
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
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.courtBorder, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section - Court Name & Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.courtHeader,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sports_tennis, color: AppColors.textLight, size: 24),
                const SizedBox(width: 8),
                Text(
                  widget.match.court.name,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.textLight),
                  onPressed: _showScoreInput,
                  tooltip: 'Indtast score',
                ),
              ],
            ),
          ),
          
          // Court Body Layout - Three-Column Layout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.courtBackgroundLight,
                  AppColors.courtBackgroundDark,
                ],
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Par 1 (Left side) - 40%
                  Expanded(
                    flex: 4,
                    child: TeamSide(
                      team: widget.match.team1,
                      label: 'PAR 1',
                      score: widget.match.team1Score,
                    ),
                  ),
                  
                  // Net (Center) - 20%
                  const Expanded(
                    flex: 2,
                    child: NetDivider(),
                  ),
                  
                  // Par 2 (Right side) - 40%
                  Expanded(
                    flex: 4,
                    child: TeamSide(
                      team: widget.match.team2,
                      label: 'PAR 2',
                      score: widget.match.team2Score,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Optional: Player override section (only shown when onPlayerForceToPause is provided)
          if (widget.onPlayerForceToPause != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tving spillere til pause:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPlayerOverrideChip(widget.match.team1.player1),
                      _buildPlayerOverrideChip(widget.match.team1.player2),
                      _buildPlayerOverrideChip(widget.match.team2.player1),
                      _buildPlayerOverrideChip(widget.match.team2.player2),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerOverrideChip(Player player) {
    return ActionChip(
      label: Text(player.name),
      avatar: const Icon(Icons.pause, size: 16),
      onPressed: () => widget.onPlayerForceToPause!(player),
      visualDensity: VisualDensity.compact,
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
      popClose();
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
        )
      ],
    );
  }

  void popClose() {
    Navigator.pop(context, {
                    'team1Score': _team1Score,
                    'team2Score': _team2Score,
                  });
  }
}

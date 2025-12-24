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
  void _showScoreInput({bool isTeam1 = true}) {
    showDialog(
      context: context,
      builder: (context) => ScoreInputDialog(
        match: widget.match,
        maxPoints: widget.maxPoints,
        selectedTeamIsTeam1: isTeam1,
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
      child: IntrinsicHeight(
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
                  onPressed: () => _showScoreInput(),
                  tooltip: 'Indtast score',
                ),
              ],
            ),
          ),
          
          // Court Body Layout - Three-Column Layout
          Flexible(
            child: Container(
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
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
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
                      onPlayerLongPress: widget.onPlayerForceToPause != null
                          ? _showPlayerOptionsMenu
                          : null,
                      onScoreTap: () => _showScoreInput(isTeam1: true),
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
                      onPlayerLongPress: widget.onPlayerForceToPause != null
                          ? _showPlayerOptionsMenu
                          : null,
                      onScoreTap: () => _showScoreInput(isTeam1: false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }

  void _showPlayerOptionsMenu(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: AppColors.playerIcon),
            const SizedBox(width: 8),
            Expanded(child: Text(player.name)),
          ],
        ),
        content: const Text(
          'Tving spilleren til at holde pause denne runde?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuller'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onPlayerForceToPause!(player);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.benchBorder,
              foregroundColor: AppColors.textLight,
            ),
            icon: const Icon(Icons.pause_circle, size: 20),
            label: const Text('Tving til pause'),
          ),
        ],
      ),
    );
  }
}

class ScoreInputDialog extends StatefulWidget {
  final Match match;
  final int maxPoints;
  final bool selectedTeamIsTeam1;

  const ScoreInputDialog({
    super.key,
    required this.match,
    this.maxPoints = 24,
    this.selectedTeamIsTeam1 = true,
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

  void _selectScore(int score) {
    setState(() {
      if (widget.selectedTeamIsTeam1) {
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
    final selectedTeam = widget.selectedTeamIsTeam1 ? widget.match.team1 : widget.match.team2;
    final selectedTeamLabel = widget.selectedTeamIsTeam1 ? 'Par 1' : 'Par 2';
    final selectedScore = widget.selectedTeamIsTeam1 ? _team1Score : _team2Score;
    
    final otherTeam = widget.selectedTeamIsTeam1 ? widget.match.team2 : widget.match.team1;
    final otherTeamLabel = widget.selectedTeamIsTeam1 ? 'Par 2' : 'Par 1';
    final otherScore = widget.selectedTeamIsTeam1 ? _team2Score : _team1Score;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.sports_tennis, color: AppColors.courtHeader),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Indtast Score - ${widget.match.court.name}'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Team (Active input)
            Card(
              color: AppColors.courtBackgroundLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.courtBorder, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedTeamLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.teamLabel,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.touch_app, size: 16, color: AppColors.courtHeader),
                        const SizedBox(width: 4),
                        const Text(
                          'Vælg score',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.courtHeader,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: AppColors.playerIcon),
                        const SizedBox(width: 4),
                        Text(selectedTeam.player1.name),
                        const Text(' & '),
                        const Icon(Icons.person, size: 16, color: AppColors.playerIcon),
                        const SizedBox(width: 4),
                        Text(selectedTeam.player2.name),
                      ],
                    ),
                    if (selectedScore != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.scoreEntered,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Score: $selectedScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(widget.maxPoints + 1, (index) {
                final isSelected = selectedScore == index;
                return SizedBox(
                  width: 50,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _selectScore(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.courtHeader : AppColors.scoreEmpty,
                      foregroundColor: isSelected ? AppColors.textLight : AppColors.textDark,
                      padding: EdgeInsets.zero,
                      elevation: isSelected ? 4 : 1,
                    ),
                    child: Text('$index'),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Other Team (Auto-calculated, read-only)
            Card(
              color: AppColors.scoreEmpty.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.courtBorder.withOpacity(0.3), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          otherTeamLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.teamLabel.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calculate, size: 16, color: AppColors.teamLabel),
                        const SizedBox(width: 4),
                        const Text(
                          'Automatisk',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.teamLabel,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: AppColors.playerIcon),
                        const SizedBox(width: 4),
                        Text(otherTeam.player1.name),
                        const Text(' & '),
                        const Icon(Icons.person, size: 16, color: AppColors.playerIcon),
                        const SizedBox(width: 4),
                        Text(otherTeam.player2.name),
                      ],
                    ),
                    if (otherScore != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.teamLabel.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Score: $otherScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../utils/colors.dart';
import 'player_marker.dart';
import 'score_display.dart';

/// Displays one side of the court with team label, players, and score
/// F-020: Team Side Component
class TeamSide extends StatelessWidget {
  final Team team;
  final String label;
  final int? score;
  final Function(Player)? onPlayerLongPress;

  const TeamSide({
    super.key,
    required this.team,
    required this.label,
    this.score,
    this.onPlayerLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Team label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.teamLabel,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // Player 1
        PlayerMarker(
          player: team.player1,
          onLongPress: onPlayerLongPress != null
              ? () => onPlayerLongPress!(team.player1)
              : null,
        ),
        const SizedBox(height: 12),
        // Player 2
        PlayerMarker(
          player: team.player2,
          onLongPress: onPlayerLongPress != null
              ? () => onPlayerLongPress!(team.player2)
              : null,
        ),
        const SizedBox(height: 20),
        // Score display
        ScoreDisplay(score: score),
      ],
    );
  }
}

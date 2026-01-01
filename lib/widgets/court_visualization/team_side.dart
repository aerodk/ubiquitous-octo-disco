import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'player_marker.dart';
import 'score_display.dart';

/// Displays one side of the court with team label, players, and score
/// F-020: Team Side Component
class TeamSide extends StatelessWidget {
  final Team team;
  final String label;
  final int? score;
  final Function(Player)? onPlayerLongPress;
  final VoidCallback? onScoreTap;
  final bool isDesktopMode;
  final double zoomFactor;

  const TeamSide({
    super.key,
    required this.team,
    required this.label,
    this.score,
    this.onPlayerLongPress,
    this.onScoreTap,
    this.isDesktopMode = false,
    this.zoomFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double baseFontScale = isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double baseSizeScale = isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double fontScale = baseFontScale * zoomFactor;
    final double sizeScale = baseSizeScale * zoomFactor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Team label
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w600,
            color: AppColors.teamLabel,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8 * sizeScale),
        // Clickable area for team side (players + score)
        GestureDetector(
          onTap: onScoreTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Player 1
              PlayerMarker(
                player: team.player1,
                isDesktopMode: isDesktopMode,
                zoomFactor: zoomFactor,
                onLongPress: onPlayerLongPress != null
                    ? () => onPlayerLongPress!(team.player1)
                    : null,
              ),
              SizedBox(height: 6 * sizeScale),
              // Player 2
              PlayerMarker(
                player: team.player2,
                isDesktopMode: isDesktopMode,
                zoomFactor: zoomFactor,
                onLongPress: onPlayerLongPress != null
                    ? () => onPlayerLongPress!(team.player2)
                    : null,
              ),
              SizedBox(height: 8 * sizeScale),
              // Score display
              ScoreDisplay(
                score: score,
                isDesktopMode: isDesktopMode,
                zoomFactor: zoomFactor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

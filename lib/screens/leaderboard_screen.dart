import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/player_standing.dart';
import '../services/standings_service.dart';

/// F-007: Live Leaderboard
/// Displays live tournament standings with detailed player statistics.
/// Features:
/// - Live updates after each score entry
/// - Visual highlighting for top 3 positions
/// - Detailed statistics per player
/// - Responsive design for mobile devices
class LeaderboardScreen extends StatelessWidget {
  final Tournament tournament;
  
  // Service is stateless and can be shared
  static final StandingsService _standingsService = StandingsService();

  const LeaderboardScreen({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final standings = _standingsService.calculateStandings(tournament);
    final hasMatches = standings.any((s) => s.matchesPlayed > 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !hasMatches
          ? const Center(
              child: Text(
                'No matches played yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: standings.length,
              itemBuilder: (context, index) {
                final standing = standings[index];
                return _buildStandingCard(context, standing, index);
              },
            ),
    );
  }

  Widget _buildStandingCard(
      BuildContext context, PlayerStanding standing, int index) {
    // Determine if this is a top 3 position for special styling
    final bool isTop3 = standing.rank <= 3 && standing.matchesPlayed > 0;
    final Color? cardColor = _getCardColor(standing.rank, standing.matchesPlayed);
    final IconData? medalIcon = _getMedalIcon(standing.rank, standing.matchesPlayed);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTop3 ? 4 : 2,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Rank, Medal, and Player Name
            Row(
              children: [
                // Rank badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isTop3
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${standing.rank}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isTop3 ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Medal icon for top 3
                if (medalIcon != null) ...[
                  Icon(
                    medalIcon,
                    size: 32,
                    color: _getMedalColor(standing.rank),
                  ),
                  const SizedBox(width: 12),
                ],
                // Player name
                Expanded(
                  child: Text(
                    standing.player.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isTop3 ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Statistics Grid
            _buildStatisticsGrid(context, standing, isTop3),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(
      BuildContext context, PlayerStanding standing, bool isTop3) {
    final textColor = isTop3 ? Colors.white : Colors.black87;
    final subtitleColor = isTop3 ? Colors.white70 : Colors.grey[600];

    return Column(
      children: [
        // Primary stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Points',
              standing.totalPoints.toString(),
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Wins',
              standing.wins.toString(),
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Losses',
              standing.losses.toString(),
              textColor,
              subtitleColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Secondary stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Matches Played',
              standing.matchesPlayed.toString(),
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Biggest Win',
              standing.biggestWinMargin == 0
                  ? '-'
                  : '+${standing.biggestWinMargin}',
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Smallest Loss',
              standing.smallestLossMargin == 999
                  ? '-'
                  : '-${standing.smallestLossMargin}',
              textColor,
              subtitleColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, Color? textColor, Color? subtitleColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color? _getCardColor(int rank, int matchesPlayed) {
    if (matchesPlayed == 0) {
      return null; // Default card color
    }
    switch (rank) {
      case 1:
        return Colors.amber[700]; // Gold
      case 2:
        return Colors.grey[400]; // Silver
      case 3:
        return Colors.brown[400]; // Bronze
      default:
        return null; // Default card color
    }
  }

  IconData? _getMedalIcon(int rank, int matchesPlayed) {
    if (matchesPlayed == 0) {
      return null;
    }
    switch (rank) {
      case 1:
      case 2:
      case 3:
        return Icons.emoji_events; // Trophy icon
      default:
        return null;
    }
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[200]!; // Gold
      case 2:
        return Colors.grey[100]!; // Silver
      case 3:
        return Colors.brown[200]!; // Bronze
      default:
        return Colors.grey;
    }
  }
}

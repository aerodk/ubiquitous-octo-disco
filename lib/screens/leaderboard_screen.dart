import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/player.dart';
import '../models/player_standing.dart';
import '../services/standings_service.dart';
import '../services/display_mode_service.dart';
import '../widgets/export_dialog.dart';
import '../utils/constants.dart';

/// F-007: Live Leaderboard
/// Displays live tournament standings with detailed player statistics.
/// Features:
/// - Live updates after each score entry
/// - Visual highlighting for top 3 positions
/// - Detailed statistics per player
/// - Compact view toggle for simplified standings
/// - Long press to view game history
/// - Responsive design for mobile devices
class LeaderboardScreen extends StatefulWidget {
  final Tournament tournament;
  final bool isReadOnly;

  const LeaderboardScreen({
    super.key,
    required this.tournament,
    this.isReadOnly = false,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Service is stateless and can be shared
  static final StandingsService _standingsService = StandingsService();
  final DisplayModeService _displayModeService = DisplayModeService();
  
  // Toggle for compact/detailed view
  bool _isCompactView = true;
  
  // Display mode (mobile/desktop)
  bool _isDesktopMode = false;

  @override
  void initState() {
    super.initState();
    _loadDisplayMode();
  }

  Future<void> _loadDisplayMode() async {
    final isDesktop = await _displayModeService.isDesktopMode();
    setState(() {
      _isDesktopMode = isDesktop;
    });
  }

  Future<void> _toggleDisplayMode() async {
    final newMode = await _displayModeService.toggleDisplayMode();
    setState(() {
      _isDesktopMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final standings = _standingsService.calculateStandings(widget.tournament);
    final hasMatches = standings.any((s) => s.matchesPlayed > 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Display mode toggle (mobile/desktop)
          IconButton(
            icon: Icon(_isDesktopMode ? Icons.desktop_windows : Icons.phone_android),
            tooltip: _isDesktopMode ? 'Skift til mobil visning' : 'Skift til desktop visning',
            onPressed: _toggleDisplayMode,
          ),
          // Toggle compact/detailed view
          if (hasMatches) ...[
            IconButton(
              icon: Icon(_isCompactView ? Icons.view_list : Icons.view_compact),
              tooltip: _isCompactView ? 'Detailed View' : 'Compact View',
              onPressed: () {
                setState(() {
                  _isCompactView = !_isCompactView;
                });
              },
            ),
          ],
          // Only show export if there are matches played
          if (hasMatches) ...[
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Eksporter Resultater',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ExportDialog(
                    standings: standings,
                    tournament: widget.tournament,
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: !hasMatches
          ? const Center(
              child: Text(
                'No matches played yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(_isDesktopMode 
                ? Constants.desktopModeCardPadding 
                : Constants.mobileModeCardPadding),
              itemCount: standings.length,
              itemBuilder: (context, index) {
                final standing = standings[index];
                return _isCompactView
                    ? _buildCompactStandingCard(context, standing)
                    : _buildStandingCard(context, standing, index);
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
    
    // Scale factors for desktop mode
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double cardPadding = _isDesktopMode ? Constants.desktopModeCardPadding : Constants.mobileModeCardPadding;

    return GestureDetector(
      onLongPress: () => _showGameHistoryDialog(context, standing),
      child: Card(
        margin: EdgeInsets.only(bottom: 12 * sizeScale),
        elevation: isTop3 ? 4 : 2,
        color: cardColor,
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Rank, Medal, and Player Name
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 40 * sizeScale,
                    height: 40 * sizeScale,
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
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                          color: isTop3 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * sizeScale),
                  // Medal icon for top 3
                  if (medalIcon != null) ...[
                    Icon(
                      medalIcon,
                      size: 32 * sizeScale,
                      color: _getMedalColor(standing.rank),
                    ),
                    SizedBox(width: 12 * sizeScale),
                  ],
                  // Player name
                  Expanded(
                    child: Text(
                      standing.player.name,
                      style: TextStyle(
                        fontSize: 20 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: isTop3 ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  // Position change indicator (shown from round 3 onwards)
                  if (standing.rankChange != null)
                    _buildPositionChangeIndicator(standing.rankChange!, isTop3),
                ],
              ),
              SizedBox(height: 16 * sizeScale),
              // Statistics Grid
              _buildStatisticsGrid(context, standing, isTop3),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a compact standings card
  /// Format: "Rank. Name - W/L - Points"
  Widget _buildCompactStandingCard(
      BuildContext context, PlayerStanding standing) {
    final bool isTop3 = standing.rank <= 3 && standing.matchesPlayed > 0;
    final Color? cardColor = _getCardColor(standing.rank, standing.matchesPlayed);
    
    // Scale factors for desktop mode
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double cardPaddingH = _isDesktopMode ? Constants.desktopModeCardPadding : 16.0;
    final double cardPaddingV = _isDesktopMode ? Constants.desktopModeCardPadding * 0.5 : 12.0;

    return GestureDetector(
      onLongPress: () => _showGameHistoryDialog(context, standing),
      child: Card(
        margin: EdgeInsets.only(bottom: 8 * sizeScale),
        elevation: isTop3 ? 3 : 1,
        color: cardColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: cardPaddingH, vertical: cardPaddingV),
          child: Row(
            children: [
              // Rank
              Text(
                '${standing.rank}.',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: isTop3 ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(width: 12 * sizeScale),
              // Player Name
              Expanded(
                child: Text(
                  standing.player.name,
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: isTop3 ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 12 * sizeScale),
              // Win/Loss
              Text(
                '${standing.wins}W/${standing.losses}L',
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  color: isTop3 ? Colors.white70 : Colors.grey[700],
                ),
              ),
              SizedBox(width: 12 * sizeScale),
              // Points
              Text(
                '${standing.totalPoints} pt',
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: isTop3 ? Colors.white : Colors.black87,
                ),
              ),
              // Position change indicator
              if (standing.rankChange != null) ...[
                SizedBox(width: 8 * sizeScale),
                _buildPositionChangeIndicator(standing.rankChange!, isTop3),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show game history dialog for a player
  void _showGameHistoryDialog(BuildContext context, PlayerStanding standing) {
    final gameHistory = _getGameHistoryForPlayer(standing.player);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${standing.player.name} - Game History'),
        content: SizedBox(
          width: double.maxFinite,
          child: gameHistory.isEmpty
              ? const Text('No games played yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: gameHistory.length,
                  itemBuilder: (context, index) {
                    final game = gameHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Round ${game['round']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Played with: ${game['partner']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Against: ${game['opponents']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${game['score']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: game['result'] == 'Won'
                                    ? Colors.green[700]
                                    : game['result'] == 'Lost'
                                        ? Colors.red[700]
                                        : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Result: ${game['result']}',
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Get game history for a specific player
  List<Map<String, dynamic>> _getGameHistoryForPlayer(Player player) {
    final List<Map<String, dynamic>> history = [];

    for (final round in widget.tournament.rounds) {
      for (final match in round.matches.where((m) => m.isCompleted)) {
        // isCompleted ensures both scores are non-null
        final team1Score = match.team1Score;
        final team2Score = match.team2Score;
        
        // Additional safety check (should never be null due to isCompleted check)
        if (team1Score == null || team2Score == null) continue;
        
        // Check if player is in this match
        final isInTeam1 = match.team1.player1.id == player.id ||
            match.team1.player2.id == player.id;
        final isInTeam2 = match.team2.player1.id == player.id ||
            match.team2.player2.id == player.id;

        if (isInTeam1 || isInTeam2) {
          // Determine partner and opponents
          String partner;
          String opponents;
          int playerScore;
          int opponentScore;
          String result;

          if (isInTeam1) {
            partner = match.team1.player1.id == player.id
                ? match.team1.player2.name
                : match.team1.player1.name;
            opponents =
                '${match.team2.player1.name} & ${match.team2.player2.name}';
            playerScore = team1Score;
            opponentScore = team2Score;
          } else {
            partner = match.team2.player1.id == player.id
                ? match.team2.player2.name
                : match.team2.player1.name;
            opponents =
                '${match.team1.player1.name} & ${match.team1.player2.name}';
            playerScore = team2Score;
            opponentScore = team1Score;
          }

          if (playerScore > opponentScore) {
            result = 'Won';
          } else if (playerScore < opponentScore) {
            result = 'Lost';
          } else {
            result = 'Draw';
          }

          history.add({
            'round': round.roundNumber,
            'partner': partner,
            'opponents': opponents,
            'score': '$playerScore - $opponentScore',
            'result': result,
          });
        }
      }
    }

    return history;
  }

  Widget _buildStatisticsGrid(
      BuildContext context, PlayerStanding standing, bool isTop3) {
    final textColor = isTop3 ? Colors.white : Colors.black87;
    final subtitleColor = isTop3 ? Colors.white70 : Colors.grey[600];
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;

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
        SizedBox(height: 12 * sizeScale),
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
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 4 * sizeScale),
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * fontScale,
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
  
  /// Build position change indicator widget
  /// Shows green +N for improvement, red -N for decline, black ±0 for no change
  Widget _buildPositionChangeIndicator(int change, bool isTop3) {
    final Color indicatorColor;
    final String prefix;
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    
    if (change > 0) {
      // Positive change = rank improvement (moved up)
      indicatorColor = Colors.green;
      prefix = '+';
    } else if (change < 0) {
      // Negative change = rank decline (moved down)
      indicatorColor = Colors.red;
      prefix = '';
    } else {
      // No change
      indicatorColor = Colors.black87;
      prefix = '±';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * sizeScale, vertical: 4 * sizeScale),
      decoration: BoxDecoration(
        color: isTop3 ? Colors.white.withOpacity(0.2) : indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * sizeScale),
        border: Border.all(
          color: indicatorColor,
          width: 1.5,
        ),
      ),
      child: Text(
        '$prefix$change',
        style: TextStyle(
          fontSize: 14 * fontScale,
          fontWeight: FontWeight.bold,
          color: isTop3 ? Colors.white : indicatorColor,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/round.dart';
import '../models/match.dart';
import '../services/display_mode_service.dart';
import '../widgets/export_dialog.dart';
import '../utils/constants.dart';
import '../services/standings_service.dart';
import 'leaderboard_screen.dart';

/// Screen to display tournament match history in a compact format
/// Features:
/// - Shows all completed matches organized by rounds
/// - Compact display without lane/court details
/// - Read-only view for shared links
/// - Toggle to switch to standings view
class MatchHistoryScreen extends StatefulWidget {
  final Tournament tournament;
  final bool isReadOnly;

  const MatchHistoryScreen({
    super.key,
    required this.tournament,
    this.isReadOnly = false,
  });

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  final DisplayModeService _displayModeService = DisplayModeService();
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

  void _navigateToStandings() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          tournament: widget.tournament,
          isReadOnly: widget.isReadOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedRounds = widget.tournament.rounds
        .where((r) => r.matches.any((m) => m.isCompleted))
        .toList();
    final hasMatches = completedRounds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamp Historik'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Display mode toggle (mobile/desktop)
          IconButton(
            icon: Icon(_isDesktopMode ? Icons.desktop_windows : Icons.phone_android),
            tooltip: _isDesktopMode ? 'Skift til mobil visning' : 'Skift til desktop visning',
            onPressed: _toggleDisplayMode,
          ),
          // Toggle to standings view (only in read-only mode)
          if (widget.isReadOnly) ...[
            IconButton(
              icon: const Icon(Icons.leaderboard),
              tooltip: 'Vis Stillinger',
              onPressed: _navigateToStandings,
            ),
          ],
          // Export functionality
          if (hasMatches) ...[
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Eksporter Resultater',
              onPressed: () {
                final standings = StandingsService().calculateStandings(widget.tournament);
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
                'Ingen kampe spillet endnu',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(_isDesktopMode 
                ? Constants.desktopModeCardPadding 
                : Constants.mobileModeCardPadding),
              itemCount: completedRounds.length,
              itemBuilder: (context, index) {
                final round = completedRounds[index];
                return _buildRoundCard(context, round);
              },
            ),
    );
  }

  Widget _buildRoundCard(BuildContext context, Round round) {
    final completedMatches = round.matches.where((m) => m.isCompleted).toList();
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double cardPadding = _isDesktopMode ? Constants.desktopModeCardPadding : 16.0;

    return Card(
      margin: EdgeInsets.only(bottom: 16 * sizeScale),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * sizeScale,
                vertical: 8 * sizeScale,
              ),
              decoration: BoxDecoration(
                color: round.isFinalRound 
                    ? Colors.amber.shade100 
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    round.isFinalRound ? Icons.emoji_events : Icons.sports_tennis,
                    size: 20 * sizeScale,
                    color: round.isFinalRound ? Colors.amber.shade900 : null,
                  ),
                  SizedBox(width: 8 * sizeScale),
                  Text(
                    round.isFinalRound ? 'Final Runde' : 'Runde ${round.roundNumber}',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: round.isFinalRound ? Colors.amber.shade900 : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${completedMatches.length} ${completedMatches.length == 1 ? "kamp" : "kampe"}',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * sizeScale),
            // Matches list
            ...completedMatches.map((match) => _buildMatchCard(context, match)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match) {
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;

    final team1Score = match.team1Score!;
    final team2Score = match.team2Score!;
    final team1Won = team1Score > team2Score;
    final team2Won = team2Score > team1Score;
    final isDraw = team1Score == team2Score;

    return Container(
      margin: EdgeInsets.only(bottom: 8 * sizeScale),
      padding: EdgeInsets.all(12 * sizeScale),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Team 1
          Row(
            children: [
              Expanded(
                child: Text(
                  '${match.team1.player1.name} & ${match.team1.player2.name}',
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: team1Won ? FontWeight.bold : FontWeight.normal,
                    color: team1Won ? Colors.green[800] : Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8 * sizeScale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * sizeScale,
                  vertical: 4 * sizeScale,
                ),
                decoration: BoxDecoration(
                  color: team1Won 
                      ? Colors.green[100] 
                      : isDraw 
                          ? Colors.grey[200] 
                          : Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$team1Score',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: team1Won 
                        ? Colors.green[900] 
                        : isDraw 
                            ? Colors.grey[700] 
                            : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * sizeScale),
          // VS divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[400])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * sizeScale),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[400])),
            ],
          ),
          SizedBox(height: 8 * sizeScale),
          // Team 2
          Row(
            children: [
              Expanded(
                child: Text(
                  '${match.team2.player1.name} & ${match.team2.player2.name}',
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: team2Won ? FontWeight.bold : FontWeight.normal,
                    color: team2Won ? Colors.green[800] : Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8 * sizeScale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * sizeScale,
                  vertical: 4 * sizeScale,
                ),
                decoration: BoxDecoration(
                  color: team2Won 
                      ? Colors.green[100] 
                      : isDraw 
                          ? Colors.grey[200] 
                          : Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$team2Score',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: team2Won 
                        ? Colors.green[900] 
                        : isDraw 
                            ? Colors.grey[700] 
                            : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

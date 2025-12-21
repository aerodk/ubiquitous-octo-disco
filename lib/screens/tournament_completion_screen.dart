import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/player_standing.dart';
import '../services/standings_service.dart';
import '../services/persistence_service.dart';
import '../widgets/export_dialog.dart';
import 'setup_screen.dart';

class TournamentCompletionScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentCompletionScreen({super.key, required this.tournament});

  @override
  State<TournamentCompletionScreen> createState() =>
      _TournamentCompletionScreenState();
}

class _TournamentCompletionScreenState
    extends State<TournamentCompletionScreen> with SingleTickerProviderStateMixin {
  final StandingsService _standingsService = StandingsService();
  final PersistenceService _persistenceService = PersistenceService();
  late List<PlayerStanding> _standings;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _standings = _standingsService.calculateStandings(widget.tournament);
    
    // Setup confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getTournamentDuration() {
    final duration = DateTime.now().difference(widget.tournament.createdAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours t ${minutes} min';
    } else {
      return '$minutes min';
    }
  }

  PlayerStanding? _getTopScorer() {
    if (_standings.isEmpty) return null;
    return _standings.reduce((a, b) => a.totalPoints > b.totalPoints ? a : b);
  }

  PlayerStanding? _getMostWins() {
    if (_standings.isEmpty) return null;
    return _standings.reduce((a, b) => a.wins > b.wins ? a : b);
  }

  int _getBiggestWinMargin() {
    if (_standings.isEmpty) return 0;
    return _standings
        .map((s) => s.biggestWinMargin)
        .reduce((a, b) => a > b ? a : b);
  }

  Future<void> _startNewTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Ny Turnering'),
        content: const Text(
          'Er du sikker på at du vil starte en ny turnering? '
          'Den nuværende turnering vil blive gemt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start Ny'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _persistenceService.clearTournament();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SetupScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMatches = widget.tournament.rounds
        .expand((r) => r.matches)
        .where((m) => m.isCompleted)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnering Afsluttet'),
        backgroundColor: Colors.amber[700],
        automaticallyImplyLeading: false,
        actions: [
          // Export button
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Eksporter Resultater',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ExportDialog(
                  standings: _standings,
                  tournament: widget.tournament,
                ),
              );
            },
          ),
          // Future options info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Se fremtidige eksport muligheder',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const FutureExportOptionsDialog(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Trophy icon with animation
                FadeTransition(
                  opacity: _confettiController,
                  child: const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🎉 Tillykke! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Podium (Top 3)
                _buildPodium(),
                const SizedBox(height: 32),

                // Tournament Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Turnerings Statistik',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildStatRow('Total kampe', '$totalMatches'),
                        _buildStatRow('Varighed', _getTournamentDuration()),
                        _buildStatRow(
                          'Top scorer',
                          _getTopScorer()?.player.name ?? '-',
                        ),
                        _buildStatRow(
                          'Flest sejre',
                          _getMostWins()?.player.name ?? '-',
                        ),
                        _buildStatRow(
                          'Største sejr',
                          '${_getBiggestWinMargin()} point',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Full leaderboard
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Endelig Stilling',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ..._standings.map((s) => ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: _getRankColor(s.rank),
                                child: Text(
                                  '${s.rank}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(s.player.name),
                              subtitle: Text(
                                '${s.wins}W-${s.losses}L • ${s.matchesPlayed} kampe',
                              ),
                              trailing: Text(
                                '${s.totalPoints}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startNewTournament,
                    icon: const Icon(Icons.add),
                    label: const Text('Start Ny Turnering'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Space for bottom padding
              ],
            ),
          ),

          // Confetti animation overlay (simple fade effect)
          if (_confettiController.isAnimating)
            IgnorePointer(
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: _confettiController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.amber.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _standings.take(3).toList();
    
    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (top3.length > 1) _buildPodiumPlace(top3[1], 2, 140, Colors.grey),
          const SizedBox(width: 8),
          // 1st place
          _buildPodiumPlace(top3[0], 1, 180, Colors.amber),
          const SizedBox(width: 8),
          // 3rd place
          if (top3.length > 2)
            _buildPodiumPlace(top3[2], 3, 120, Colors.brown),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    PlayerStanding standing,
    int place,
    double height,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Text(
            place == 1 ? '🥇' : place == 2 ? '🥈' : '🥉',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          standing.player.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${standing.totalPoints} pt',
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(8),
          child: Text(
            '$place',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}

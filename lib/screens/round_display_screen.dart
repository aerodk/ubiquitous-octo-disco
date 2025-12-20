import 'package:flutter/material.dart';
import 'package:star_cano/models/round.dart';
import '../models/tournament.dart';
import '../services/persistence_service.dart';
import '../services/standings_service.dart';
import '../widgets/match_card.dart';
import '../services/tournament_service.dart';
import 'setup_screen.dart';
import 'leaderboard_screen.dart';
import 'tournament_completion_screen.dart';

class RoundDisplayScreen extends StatefulWidget {
  final Tournament tournament;

  const RoundDisplayScreen({super.key, required this.tournament});

  @override
  State<RoundDisplayScreen> createState() => _RoundDisplayScreenState();
}

class _RoundDisplayScreenState extends State<RoundDisplayScreen> {
  final PersistenceService _persistenceService = PersistenceService();
  final TournamentService _tournamentService = TournamentService();
  final StandingsService _standingsService = StandingsService();
  late Tournament _tournament;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
  }

  Round get _currentRound => _tournament.currentRound!;
  
  bool get _canGoBack {
    // Returns true if no scores are entered in current round
    // Allows navigation back to Setup (Round 1) or previous round (Round 2+)
    final currentRound = _currentRound;
    final hasAnyScores = currentRound.matches.any(
      (match) => match.team1Score != null || match.team2Score != null
    );
    
    return !hasAnyScores;
  }

  bool get _canStartFinalRound {
    // Must have at least 3 completed rounds
    if (_tournament.completedRounds < 3) return false;
    
    // Current round must be completed
    if (!_currentRound.isCompleted) return false;
    
    // Cannot start if already in final round
    if (_currentRound.isFinalRound) return false;
    
    // Tournament must not be completed
    if (_tournament.isCompleted) return false;
    
    return true;
  }

  void _checkForTournamentCompletion() {
    // Check if final round is completed
    if (_currentRound.isFinalRound && _currentRound.isCompleted) {
      // Mark tournament as completed
      final completedTournament = _tournament.copyWith(isCompleted: true);
      
      // Navigate to completion screen after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentCompletionScreen(
                tournament: completedTournament,
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _resetTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nulstil Turnering'),
        content: const Text(
          'Er du sikker på at du vil nulstille turneringen? '
          'Alt data vil blive slettet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Nulstil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _persistenceService.clearTournament();
      
      // Navigate to setup screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SetupScreen()),
        (route) => false,
      );
    }
  }

  void _goToPreviousRound() {
    if (!_canGoBack) return;
    
    // If on first round, just pop back to setup screen
    if (_tournament.rounds.length <= 1) {
      Navigator.pop(context);
      return;
    }
    
    // Remove the current round and replace screen with previous round
    final updatedTournament = Tournament(
      id: _tournament.id,
      name: _tournament.name,
      players: _tournament.players,
      courts: _tournament.courts,
      rounds: _tournament.rounds.sublist(0, _tournament.rounds.length - 1),
      createdAt: _tournament.createdAt,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoundDisplayScreen(tournament: updatedTournament),
      ),
    );
  }

  void _generateNextRound() {
    // Simple next round generation (random for now, Version 2.0 will use Americano algorithm)
    final nextRoundNumber = _tournament.rounds.length + 1;
    final nextRound = _tournamentService.generateFirstRound(
      _tournament.players,
      _tournament.courts,
    );
    
    // Update round number
    final updatedRound = Round(
      roundNumber: nextRoundNumber,
      matches: nextRound.matches,
      playersOnBreak: nextRound.playersOnBreak,
    );
    
    final updatedTournament = Tournament(
      id: _tournament.id,
      name: _tournament.name,
      players: _tournament.players,
      courts: _tournament.courts,
      rounds: [..._tournament.rounds, updatedRound],
      createdAt: _tournament.createdAt,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoundDisplayScreen(tournament: updatedTournament),
      ),
    );
  }

  Future<void> _generateFinalRound() async {
    // Show confirmation dialog with leaderboard preview
    final standings = _standingsService.calculateStandings(_tournament);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('Start Sidste Runde'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dette starter den sidste runde. Er du sikker?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Nuværende top 5:'),
              const SizedBox(height: 8),
              ...standings.take(5).map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${s.rank}. ${s.player.name} - ${s.totalPoints} point',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Start Sidste Runde'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Generate final round
    final nextRoundNumber = _tournament.rounds.length + 1;
    final finalRound = _tournamentService.generateFinalRound(
      _tournament.courts,
      standings,
      nextRoundNumber,
    );
    
    final updatedTournament = Tournament(
      id: _tournament.id,
      name: _tournament.name,
      players: _tournament.players,
      courts: _tournament.courts,
      rounds: [..._tournament.rounds, finalRound],
      createdAt: _tournament.createdAt,
    );
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoundDisplayScreen(tournament: updatedTournament),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.tournament.currentRound;
    
    if (round == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Turnering'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetTournament,
              tooltip: 'Nulstil turnering',
            ),
          ],
        ),
        body: const Center(
          child: Text('Ingen runder genereret endnu'),
        ),
      );
    }

    return PopScope(
      canPop: _canGoBack,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && !_canGoBack) {
          // Show message that you can't go back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Du kan ikke gå tilbage når der er indtastet score'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _currentRound.isFinalRound
              ? const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('🏆 SIDSTE RUNDE'),
                  ],
                )
              : Text('Runde ${_currentRound.roundNumber}'),
          backgroundColor: _currentRound.isFinalRound
              ? Colors.amber[700]
              : Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(tournament: _tournament),
                ),
              );
            },
            tooltip: 'Vis stillinger',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTournament,
            tooltip: 'Nulstil turnering',
          ),
        ],
          leading: _tournament.rounds.length > 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _canGoBack ? _goToPreviousRound : null,
                )
              : null,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Display all matches
                  ..._currentRound.matches.map(
                    (match) => MatchCard(
                      key: ValueKey(match.id),
                      match: match,
                      onScoreChanged: () {
                        setState(() {});
                        _checkForTournamentCompletion();
                      },
                    ),
                  ),

                  // Display players on break
                  if (_currentRound.playersOnBreak.isNotEmpty)
                    Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.pause_circle, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  'Pause',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _currentRound.playersOnBreak
                                  .map((player) => Chip(label: Text(player.name)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bottom buttons section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Final round button (gold themed, shown when eligible)
                  if (_canStartFinalRound)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _generateFinalRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.black,
                          elevation: 8,
                        ),
                        icon: const Icon(Icons.emoji_events, size: 28),
                        label: const Text(
                          'Start Sidste Runde',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Regular next round button
                  if (!_currentRound.isFinalRound && !_canStartFinalRound)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _generateNextRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Generer Næste Runde (${_currentRound.roundNumber + 1})',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

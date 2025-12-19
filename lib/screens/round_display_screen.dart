import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/round.dart';
import '../widgets/match_card.dart';
import '../services/tournament_service.dart';

class RoundDisplayScreen extends StatefulWidget {
  final Tournament tournament;

  const RoundDisplayScreen({super.key, required this.tournament});

  @override
  State<RoundDisplayScreen> createState() => _RoundDisplayScreenState();
}

class _RoundDisplayScreenState extends State<RoundDisplayScreen> {
  final TournamentService _tournamentService = TournamentService();
  late Tournament _tournament;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
  }

  Round get _currentRound => _tournament.currentRound!;
  
  bool get _canGoBack {
    // Can only go back if:
    // 1. Not on the first round
    // 2. No scores entered in current round
    if (_tournament.rounds.length <= 1) return false;
    
    final currentRound = _currentRound;
    final hasAnyScores = currentRound.matches.any(
      (match) => match.team1Score != null || match.team2Score != null
    );
    
    return !hasAnyScores;
  }

  void _goToPreviousRound() {
    if (!_canGoBack) return;
    
    // Remove the current round and navigate back
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

  @override
  Widget build(BuildContext context) {
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
          title: Text('Runde ${_currentRound.roundNumber}'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  ..._currentRound.matches.map((match) => MatchCard(match: match)),

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
            
            // Next round button (for testing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/round.dart';
import '../models/tournament.dart';
import '../models/court.dart';
import '../services/persistence_service.dart';
import '../services/standings_service.dart';
import '../widgets/match_card.dart';
import '../widgets/court_visualization/bench_section.dart';
import '../widgets/save_tournament_dialog.dart';
import '../services/tournament_service.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import 'setup_screen.dart';
import 'leaderboard_screen.dart';
import 'tournament_completion_screen.dart';

class RoundDisplayScreen extends StatefulWidget {
  final Tournament tournament;
  final String? cloudCode;
  final String? cloudPasscode;

  const RoundDisplayScreen({
    super.key,
    required this.tournament,
    this.cloudCode,
    this.cloudPasscode,
  });

  @override
  State<RoundDisplayScreen> createState() => _RoundDisplayScreenState();
}

class _RoundDisplayScreenState extends State<RoundDisplayScreen> {
  final PersistenceService _persistenceService = PersistenceService();
  final TournamentService _tournamentService = TournamentService();
  final StandingsService _standingsService = StandingsService();
  final FirebaseService _firebaseService = FirebaseService();
  late Tournament _tournament;
  
  // Track cloud storage codes
  String? _cloudCode;
  String? _cloudPasscode;
  
  // Track players who were newly moved to pause after court adjustment
  Set<String> _newlyPausedPlayerIds = {};

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
    _cloudCode = widget.cloudCode;
    _cloudPasscode = widget.cloudPasscode;
  }

  /// Sync the current tournament to cloud if codes are known
  Future<void> _syncToCloudIfConfigured(Tournament tournament) async {
    if (_cloudCode == null || _cloudPasscode == null) return;

    final isAvailable = await _firebaseService.isFirebaseAvailable();
    if (!isAvailable) return;

    try {
      await _firebaseService.updateTournament(
        tournamentCode: _cloudCode!,
        passcode: _cloudPasscode!,
        tournament: tournament,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kunne ikke gemme til cloud: $e')),
        );
      }
    }
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
    // Must have at least the configured minimum completed rounds
    if (_tournament.completedRounds < _tournament.settings.minRoundsBeforeFinal) return false;
    
    // Current round must be completed
    if (!_currentRound.isCompleted) return false;
    
    // Cannot start if already in final round
    if (_currentRound.isFinalRound) return false;
    
    // Tournament must not be completed
    if (_tournament.isCompleted) return false;
    
    return true;
  }

  void _showTournamentCompletion() {
    // Mark tournament as completed
    final completedTournament = _tournament.copyWith(isCompleted: true);
    
    // Navigate to completion screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentCompletionScreen(
          tournament: completedTournament,
          cloudCode: _cloudCode,
          cloudPasscode: _cloudPasscode,
        ),
      ),
    );
  }

  Future<void> _resetTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nulstil turnering'),
        content: const Text(
          'Er du sikker på at du vil nulstille turneringen? '
          'Alt data vil blive slettet.',
        ),
        actions: [
          TextButton (
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

  Future<void> _saveToCloud() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveTournamentDialog(
        tournament: _tournament,
        existingCode: _cloudCode,
        existingPasscode: _cloudPasscode,
      ),
    );

    if (result != null) {
      setState(() {
        _cloudCode = result['code'] as String;
        _cloudPasscode = result['passcode'] as String;
      });
    }
  }

  void _goToPreviousRound() {
    if (!_canGoBack) return;
    
    // Save the full tournament state before going back (to preserve future rounds)
    _persistenceService.saveFullTournamentHistory(_tournament);
    
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
      settings: _tournament.settings,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoundDisplayScreen(
          tournament: updatedTournament,
          cloudCode: _cloudCode,
          cloudPasscode: _cloudPasscode,
        ),
      ),
    );
  }

  void _generateNextRound() async {
    // Check if all scores have been entered in current round
    if (!_currentRound.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle kampe skal have score før næste runde kan startes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final nextRoundNumber = _tournament.rounds.length + 1;
    
    // Try to load previously saved tournament history
    final savedHistory = await _persistenceService.loadFullTournamentHistory();
    
    Round? nextRound;
    
    // Check if we can restore the next round from history
    if (savedHistory != null && 
        savedHistory.rounds.length >= nextRoundNumber &&
        _roundsAreIdentical(savedHistory, _tournament)) {
      // We can restore the next round from history
      nextRound = savedHistory.rounds[nextRoundNumber - 1];
    }
    
    // If we couldn't restore from history, generate a new round
    if (nextRound == null) {
      // Calculate current standings to track pause history
      final standings = _standingsService.calculateStandings(_tournament);
      
      // Generate next round with pause fairness logic
      nextRound = _tournamentService.generateNextRound(
        _tournament.players,
        _tournament.courts,
        standings,
        nextRoundNumber,
        laneStrategy: _tournament.settings.laneAssignmentStrategy,
        format: _tournament.settings.format,
        previousRounds: _tournament.rounds,
      );
      
      // Clear history since we generated a new round
      await _persistenceService.clearFullTournamentHistory();
    }
    
    final updatedTournament = Tournament(
      id: _tournament.id,
      name: _tournament.name,
      players: _tournament.players,
      courts: _tournament.courts,
      rounds: [..._tournament.rounds, nextRound],
      createdAt: _tournament.createdAt,
      settings: _tournament.settings,
    );

    await _syncToCloudIfConfigured(updatedTournament);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoundDisplayScreen(
          tournament: updatedTournament,
          cloudCode: _cloudCode,
          cloudPasscode: _cloudPasscode,
        ),
      ),
    );
  }
  
  /// Check if the rounds in two tournaments are identical (same scores)
  /// Used to determine if we can safely restore a round from history
  bool _roundsAreIdentical(Tournament history, Tournament current) {
    if (history.rounds.length < current.rounds.length) return false;
    
    // Check that all existing rounds have identical scores
    for (int i = 0; i < current.rounds.length; i++) {
      final historyRound = history.rounds[i];
      final currentRound = current.rounds[i];
      
      if (historyRound.matches.length != currentRound.matches.length) return false;
      
      for (int j = 0; j < currentRound.matches.length; j++) {
        final historyMatch = historyRound.matches[j];
        final currentMatch = currentRound.matches[j];
        
        // Check if scores are different
        if (historyMatch.team1Score != currentMatch.team1Score ||
            historyMatch.team2Score != currentMatch.team2Score) {
          return false;
        }
      }
    }
    
    return true;
  }

  Future<void> _generateFinalRound() async {
    // Show confirmation dialog
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
        content: const Text(
          'Dette starter den sidste runde. Er du sikker?',
          style: TextStyle(fontWeight: FontWeight.bold),
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

    final nextRoundNumber = _tournament.rounds.length + 1;
    
    // Try to load previously saved tournament history
    final savedHistory = await _persistenceService.loadFullTournamentHistory();
    
    Round? finalRound;
    
    // Check if we can restore the final round from history
    if (savedHistory != null && 
        savedHistory.rounds.length >= nextRoundNumber &&
        _roundsAreIdentical(savedHistory, _tournament)) {
      // We can restore the final round from history
      finalRound = savedHistory.rounds[nextRoundNumber - 1];
    }
    
    // If we couldn't restore from history, generate a new final round
    if (finalRound == null) {
      final standings = _standingsService.calculateStandings(_tournament);
      finalRound = _tournamentService.generateFinalRound(
        _tournament.courts,
        standings,
        nextRoundNumber,
        strategy: _tournament.settings.finalRoundStrategy,
        laneStrategy: _tournament.settings.laneAssignmentStrategy,
      );
      
      // Clear history since we generated a new round
      await _persistenceService.clearFullTournamentHistory();
    }
    
    final updatedTournament = Tournament(
      id: _tournament.id,
      name: _tournament.name,
      players: _tournament.players,
      courts: _tournament.courts,
      rounds: [..._tournament.rounds, finalRound],
      createdAt: _tournament.createdAt,
      settings: _tournament.settings,
    );

    await _syncToCloudIfConfigured(updatedTournament);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoundDisplayScreen(
            tournament: updatedTournament,
            cloudCode: _cloudCode,
            cloudPasscode: _cloudPasscode,
          ),
        ),
      );
    }
  }

  /// Override a player's pause status
  /// If forceToActive is true, player is currently on pause and should be forced to active
  /// If forceToActive is false, player is currently active and should be forced to pause
  Future<void> _overridePlayerPauseStatus(Player player, bool forceToActive) async {
    // Don't allow overrides if any scores have been entered
    if (_currentRound.matches.any((m) => m.team1Score != null || m.team2Score != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kan ikke ændre spillere når der er indtastet score'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final String actionText = forceToActive ? 'spille' : 'pause';
    final String explanationText = forceToActive
        ? 'Dette vil tvinge ${player.name} til at spille og omarrangere de andre spillere.'
        : 'Dette vil tvinge ${player.name} til at holde pause og omarrangere de andre spillere.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tving ${player.name} til $actionText?'),
        content: Text(explanationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: forceToActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Tving til $actionText'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Calculate current standings for fairness-based player selection
    final standings = _standingsService.calculateStandings(_tournament);

    // Attempt to regenerate the round with the override
    final newRound = _tournamentService.regenerateRoundWithOverride(
      currentRound: _currentRound,
      allPlayers: _tournament.players,
      courts: _tournament.courts,
      overridePlayer: player,
      forceToActive: forceToActive,
      standings: standings,
      laneStrategy: _tournament.settings.laneAssignmentStrategy,
    );

    if (newRound == null) {
      // Override failed - show error
      final String errorMessage;
      if (!forceToActive && _currentRound.playersOnBreak.length >= 
          (_tournament.players.length - _tournament.courts.length * 4)) {
        errorMessage = 'Kan ikke sætte flere spillere på pause. '
            'Med ${_tournament.courts.length} baner og ${_tournament.players.length} spillere, '
            'kan maksimalt ${_tournament.players.length - _tournament.courts.length * 4} spillere være på pause.';
      } else {
        errorMessage = 'Kunne ikke ændre spillerstatus. Prøv igen.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // Update tournament with new round
    final updatedRounds = [..._tournament.rounds];
    updatedRounds[updatedRounds.length - 1] = newRound;

    final updatedTournament = Tournament(
      id: _tournament.id,
      name: _tournament.name,
      players: _tournament.players,
      courts: _tournament.courts,
      rounds: updatedRounds,
      createdAt: _tournament.createdAt,
      settings: _tournament.settings,
    );

    // Save and refresh
    await _persistenceService.saveTournament(updatedTournament);
    
    setState(() {
      _tournament = updatedTournament;
      // Clear newly paused tracking after manual override
      _newlyPausedPlayerIds.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${player.name} er nu ${forceToActive ? "på pause" : "sat til at spille"}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Add a new court to the tournament
  /// Regenerates the current round with the new court
  Future<void> _addCourt() async {
    // Don't allow court changes if any scores have been entered
    if (_currentRound.matches.any((m) => m.team1Score != null || m.team2Score != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kan ikke ændre baner når der er indtastet score'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if we're at max courts
    if (_tournament.courts.length >= Constants.maxCourts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kan ikke tilføje flere end ${Constants.maxCourts} baner'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if there are enough players on pause to fill an additional court
    // A court needs 4 players, so we need at least 4 players on pause
    if (_currentRound.playersOnBreak.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kan ikke tilføje bane: Kun ${_currentRound.playersOnBreak.length} spillere på pause. '
            'Der skal være mindst 4 spillere på pause for at tilføje en bane.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tilføj bane'),
        content: const Text(
          'Er du sikker på at du vil tilføje en ny bane? '
          'Dette vil omarrangere den nuværende runde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tilføj'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear newly paused players tracking when adding a court (reduces pause)
    setState(() {
      _newlyPausedPlayerIds.clear();
    });

    // Create new court
    final newCourtIndex = _tournament.courts.length;
    final newCourt = Court(
      id: 'court_${DateTime.now().millisecondsSinceEpoch}',
      name: Constants.getDefaultCourtName(newCourtIndex),
    );

    // Add court to tournament
    final updatedCourts = [..._tournament.courts, newCourt];

    // Regenerate current round with new court count
    final standings = _standingsService.calculateStandings(_tournament);
    final Round newRound;
    
    if (_currentRound.isFinalRound) {
      // Regenerate final round with new court
      newRound = _tournamentService.generateFinalRound(
        updatedCourts,
        standings,
        _currentRound.roundNumber,
        strategy: _tournament.settings.finalRoundStrategy,
        laneStrategy: _tournament.settings.laneAssignmentStrategy,
      );
    } else {
      // Regenerate regular round with new court
      final previousRounds = _tournament.rounds.sublist(0, _tournament.rounds.length - 1);
      newRound = _tournamentService.generateNextRound(
        _tournament.players,
        updatedCourts,
        standings,
        _currentRound.roundNumber,
        laneStrategy: _tournament.settings.laneAssignmentStrategy,
        format: _tournament.settings.format,
        previousRounds: previousRounds,
      );
    }

    // Update tournament
    final updatedRounds = [..._tournament.rounds];
    updatedRounds[updatedRounds.length - 1] = newRound;

    final updatedTournament = _tournament.copyWith(
      courts: updatedCourts,
      rounds: updatedRounds,
    );

    // Save and refresh
    await _persistenceService.saveTournament(updatedTournament);
    
    setState(() {
      _tournament = updatedTournament;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newCourt.name} tilføjet'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Remove a court from the tournament
  /// Regenerates the current round with fewer courts
  Future<void> _removeCourt() async {
    // Don't allow court changes if any scores have been entered
    if (_currentRound.matches.any((m) => m.team1Score != null || m.team2Score != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kan ikke ændre baner når der er indtastet score'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if we're at min courts
    if (_tournament.courts.length <= Constants.minCourts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skal have mindst 1 bane'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fjern bane'),
        content: Text(
          'Er du sikker på at du vil fjerne ${_tournament.courts.last.name}? '
          'Dette vil omarrangere den nuværende runde og kan sætte flere spillere på pause.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Fjern'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Track players currently on pause before removing the court
    final previouslyPausedIds = _currentRound.playersOnBreak.map((p) => p.id).toSet();

    // Remove last court
    final removedCourt = _tournament.courts.last;
    final updatedCourts = _tournament.courts.sublist(0, _tournament.courts.length - 1);

    // Regenerate current round with fewer courts
    final standings = _standingsService.calculateStandings(_tournament);
    final Round newRound;
    
    if (_currentRound.isFinalRound) {
      // Regenerate final round with fewer courts
      newRound = _tournamentService.generateFinalRound(
        updatedCourts,
        standings,
        _currentRound.roundNumber,
        strategy: _tournament.settings.finalRoundStrategy,
        laneStrategy: _tournament.settings.laneAssignmentStrategy,
      );
    } else {
      // Regenerate regular round with fewer courts
      final previousRounds = _tournament.rounds.sublist(0, _tournament.rounds.length - 1);
      newRound = _tournamentService.generateNextRound(
        _tournament.players,
        updatedCourts,
        standings,
        _currentRound.roundNumber,
        laneStrategy: _tournament.settings.laneAssignmentStrategy,
        format: _tournament.settings.format,
        previousRounds: previousRounds,
      );
    }

    // Update tournament
    final updatedRounds = [..._tournament.rounds];
    updatedRounds[updatedRounds.length - 1] = newRound;

    final updatedTournament = _tournament.copyWith(
      courts: updatedCourts,
      rounds: updatedRounds,
    );

    // Identify newly paused players (those on pause now but not before)
    final newlyPausedIds = newRound.playersOnBreak
        .map((p) => p.id)
        .where((id) => !previouslyPausedIds.contains(id))
        .toSet();

    // Save and refresh
    await _persistenceService.saveTournament(updatedTournament);
    
    setState(() {
      _tournament = updatedTournament;
      _newlyPausedPlayerIds = newlyPausedIds;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removedCourt.name} fjernet'),
          backgroundColor: Colors.green,
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
            icon: const Icon(Icons.cloud_upload),
            onPressed: _saveToCloud,
            tooltip: _cloudCode != null ? 'Opdater Cloud ($_cloudCode)' : 'Gem i Cloud',
          ),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine number of columns based on screen width
                  final int crossAxisCount;
                  if (constraints.maxWidth >= 1200) {
                    crossAxisCount = 3; // 3 columns on extra large screens
                  } else if (constraints.maxWidth >= 800) {
                    crossAxisCount = 2; // 2 columns on large screens
                  } else {
                    crossAxisCount = 1; // 1 column on small screens
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                      // Display matches in a responsive grid
                      if (_currentRound.matches.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            // Ensure enough vertical space for match content with scores
                            mainAxisExtent: 300,
                          ),
                          itemCount: _currentRound.matches.length,
                          itemBuilder: (context, index) {
                            final match = _currentRound.matches[index];
                            return MatchCard(
                              key: ValueKey(match.id),
                              match: match,
                              maxPoints: _tournament.settings.pointsPerMatch,
                              onScoreChanged: () async {
                                setState(() {});
                                // Save tournament immediately after score change
                                await _persistenceService.saveTournament(_tournament);
                                // Also save to full history to preserve scores on navigation back
                                await _persistenceService.saveFullTournamentHistory(_tournament);
                              },
                              onPlayerForceToPause: (player) => _overridePlayerPauseStatus(player, false),
                            );
                          },
                        ),

                      // Display players on break
                      if (_currentRound.playersOnBreak.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        BenchSection(
                          playersOnBreak: _currentRound.playersOnBreak,
                          standings: _standingsService.calculateStandings(_tournament),
                          onPlayerTap: (player) => _overridePlayerPauseStatus(player, true),
                        ),
                      ],

                      // Court management section
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sports_tennis, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Bane håndtering',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_tournament.courts.length} baner',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _tournament.courts.length < Constants.maxCourts &&
                                              !_currentRound.matches.any((m) => m.team1Score != null || m.team2Score != null) &&
                                              _currentRound.playersOnBreak.length >= 4
                                          ? _addCourt
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[100],
                                        foregroundColor: Colors.green[900],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add),
                                          SizedBox(width: 6),
                                          Text('Tilføj bane'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _tournament.courts.length > Constants.minCourts &&
                                              !_currentRound.matches.any((m) => m.team1Score != null || m.team2Score != null)
                                          ? _removeCourt
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[100],
                                        foregroundColor: Colors.red[900],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.remove),
                                          SizedBox(width: 6),
                                          Text('Fjern bane'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
                },
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
                  
                  // Add spacing between buttons when both are shown
                  if (_canStartFinalRound && !_currentRound.isFinalRound)
                    const SizedBox(height: 12),
                  
                  // Show result button when final round is completed
                  if (_currentRound.isFinalRound && _currentRound.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _showTournamentCompletion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.black,
                          elevation: 8,
                        ),
                        icon: const Icon(Icons.emoji_events, size: 28),
                        label: const Text(
                          'Vis Resultat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Regular next round button (shown when not in final round)
                  if (!_currentRound.isFinalRound)
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

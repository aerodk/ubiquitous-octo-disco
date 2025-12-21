import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/court.dart';
import '../models/tournament.dart';
import '../models/tournament_settings.dart';
import '../services/tournament_service.dart';
import '../services/persistence_service.dart';
import '../utils/constants.dart';
import '../widgets/tournament_settings_widget.dart';
import 'round_display_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _playerNameController = TextEditingController();
  final FocusNode _playerNameFocusNode = FocusNode();
  final List<Player> _players = [];
  int _courtCount = 1;
  TournamentSettings _tournamentSettings = const TournamentSettings();
  final TournamentService _tournamentService = TournamentService();
  final PersistenceService _persistenceService = PersistenceService();
  bool _isLoading = true;
  bool _isCourtCountAnimating = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadSavedState();
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _playerNameFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Load saved setup state from local storage
  Future<void> _loadSavedState() async {
    final savedState = await _persistenceService.loadSetupState();
    if (savedState != null && mounted) {
      setState(() {
        _players.addAll(savedState.players);
        _courtCount = savedState.courtCount;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save current setup state to local storage
  Future<void> _saveState() async {
    await _persistenceService.saveSetupState(_players, _courtCount);
  }

  /// Calculate suggested court count based on number of players
  /// Formula: 1 court per 4 players (only when full court can be filled)
  int _calculateSuggestedCourtCount(int playerCount) {
    if (playerCount == 0) return 1;
    // Only add courts when we have enough players to fill them (floor division)
    final suggested = playerCount ~/ 4;
    // Ensure at least 1 court
    final courtCount = suggested < 1 ? 1 : suggested;
    // Clamp to valid range
    return courtCount.clamp(Constants.minCourts, Constants.maxCourts);
  }

  /// Automatically adjust court count based on player count
  /// Returns true if adjustment was made
  bool _autoAdjustCourtCount() {
    final suggestedCount = _calculateSuggestedCourtCount(_players.length);
    if (suggestedCount != _courtCount) {
      setState(() {
        _courtCount = suggestedCount;
        _isCourtCountAnimating = true;
      });
      
      // Trigger animation
      _animationController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _isCourtCountAnimating = false;
          });
        }
      });
      
      return true;
    }
    return false;
  }

  /// Clear all players and reset court count
  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ryd alle'),
        content: const Text('Er du sikker på at du vil fjerne alle spillere?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ryd'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _players.clear();
        _courtCount = 1;
      });
      await _persistenceService.clearSetupState();
    }
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();

    // Validation: Empty name
    if (name.isEmpty) {
      _showError(Constants.emptyNameError);
      return;
    }

    // Validation: Duplicate name
    if (_players.any((player) => player.name.toLowerCase() == name.toLowerCase())) {
      _showError(Constants.duplicateNameError);
      return;
    }

    // Validation: Maximum players
    if (_players.length >= Constants.maxPlayers) {
      _showError(Constants.maxPlayersError);
      return;
    }

    setState(() {
      _players.add(Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ));
      _playerNameController.clear();
    });
    
    // Auto-adjust court count based on player count
    _autoAdjustCourtCount();
    
    // Save state in background - don't await to keep UI responsive
    unawaited(_saveState());
    
    // Request focus to allow for faster typing and adding of names
    _playerNameFocusNode.requestFocus();
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
    
    // Auto-adjust court count based on player count
    _autoAdjustCourtCount();
    
    // Save state in background - don't await to keep UI responsive
    unawaited(_saveState());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _generateFirstRound() async {
    // Validation: Minimum players
    if (_players.length < Constants.minPlayers) {
      _showError(Constants.minPlayersError);
      return;
    }

    // Generate courts
    final courts = List.generate(
      _courtCount,
      (index) => Court(
        id: (index + 1).toString(),
        name: Constants.getDefaultCourtName(index),
      ),
    );

    // Generate first round
    final firstRound = _tournamentService.generateFirstRound(_players, courts);

    // Create tournament
    final tournament = Tournament(
      name: 'Padel Turnering',
      players: _players,
      courts: courts,
      rounds: [firstRound],
      settings: _tournamentSettings,
    );

    // Save tournament to persistence
    await _persistenceService.saveTournament(tournament);
    
    // Clear setup state as we now have a tournament
    await _persistenceService.clearSetupState();

    // Navigate to round display
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoundDisplayScreen(tournament: tournament),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading saved state
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opsætning af Turnering'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          if (_players.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Ryd alle',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player registration section
                  Text(
                    'Spillere (${_players.length}/${Constants.maxPlayers})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _playerNameController,
                          focusNode: _playerNameFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Spiller navn',
                            suffixIcon: Icon(Icons.person_add),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addPlayer,
                        child: const Text('Tilføj'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Player list
                  _players.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'Ingen spillere tilføjet endnu.\nTilføj mindst 4 spillere for at starte.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(_players[index].name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removePlayer(index),
                                ),
                              ),
                            );
                          },
                        ),

                  const Divider(height: 32),

                  // Court registration section
                  Text(
                    'Baner',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Create a pulsing highlight effect
                      final highlightColor = _isCourtCountAnimating
                          ? Color.lerp(
                              Colors.transparent,
                              Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              (1 - (_animationController.value - 0.5).abs() * 2).clamp(0.0, 1.0),
                            )
                          : Colors.transparent;

                      return Container(
                        decoration: BoxDecoration(
                          color: highlightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _courtCount > Constants.minCourts
                              ? () {
                                  setState(() => _courtCount--);
                                  // Save state in background - don't await to keep UI responsive
                                  unawaited(_saveState());
                                }
                              : null,
                        ),
                        Text(
                          '$_courtCount ${_courtCount == 1 ? 'bane' : 'baner'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _courtCount < Constants.maxCourts
                              ? () {
                                  setState(() => _courtCount++);
                                  // Save state in background - don't await to keep UI responsive
                                  unawaited(_saveState());
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tournament Settings section
                  TournamentSettingsWidget(
                    initialSettings: _tournamentSettings,
                    onSettingsChanged: (settings) {
                      setState(() {
                        _tournamentSettings = settings;
                      });
                    },
                    enabled: true,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Generate button - fixed at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _players.length >= Constants.minPlayers ? _generateFirstRound : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Generer Første Runde',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

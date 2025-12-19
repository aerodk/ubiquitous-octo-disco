import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/court.dart';
import '../services/tournament_service.dart';
import '../utils/constants.dart';
import 'round_display_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  final List<Player> _players = [];
  int _courtCount = 1;
  final TournamentService _tournamentService = TournamentService();

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
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
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _generateFirstRound() {
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

    // Navigate to round display
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoundDisplayScreen(
          round: firstRound,
          players: _players,
          courts: courts,
          previousRounds: const [],
          tournamentService: _tournamentService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opsætning af Turnering'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
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
            Expanded(
              child: _players.isEmpty
                  ? Center(
                      child: Text(
                        'Ingen spillere tilføjet endnu.\nTilføj mindst 4 spillere for at starte.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
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
            ),

            const Divider(height: 32),

            // Court registration section
            Text(
              'Baner',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _courtCount > Constants.minCourts
                      ? () => setState(() => _courtCount--)
                      : null,
                ),
                Text(
                  '$_courtCount ${_courtCount == 1 ? 'bane' : 'baner'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _courtCount < Constants.maxCourts
                      ? () => setState(() => _courtCount++)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Generate button
            SizedBox(
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
          ],
        ),
      ),
    );
  }
}

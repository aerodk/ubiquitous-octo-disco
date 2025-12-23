import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/services/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PersistenceService - Tournament History', () {
    late PersistenceService service;
    late List<Player> players;
    late List<Court> courts;

    setUp(() async {
      // Initialize shared preferences with mock
      SharedPreferences.setMockInitialValues({});
      service = PersistenceService();
      
      players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
      ];

      courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];
    });

    test('should save and load tournament history', () async {
      // Create a tournament with 2 rounds
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            id: 'match1',
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
            team1Score: 15,
            team2Score: 10,
          ),
        ],
        playersOnBreak: [],
      );

      final round2 = Round(
        roundNumber: 2,
        matches: [
          Match(
            id: 'match2',
            court: courts[1],
            team1: Team(player1: players[0], player2: players[2]),
            team2: Team(player1: players[1], player2: players[3]),
          ),
        ],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round1, round2],
      );

      // Save tournament history
      await service.saveFullTournamentHistory(tournament);

      // Load tournament history
      final loadedTournament = await service.loadFullTournamentHistory();

      // Verify
      expect(loadedTournament, isNotNull);
      expect(loadedTournament!.rounds.length, equals(2));
      expect(loadedTournament.rounds[0].roundNumber, equals(1));
      expect(loadedTournament.rounds[1].roundNumber, equals(2));
      
      // Verify court assignments are preserved
      expect(loadedTournament.rounds[0].matches[0].court.id, equals('1'));
      expect(loadedTournament.rounds[1].matches[0].court.id, equals('2'));
      
      // Verify scores are preserved
      expect(loadedTournament.rounds[0].matches[0].team1Score, equals(15));
      expect(loadedTournament.rounds[0].matches[0].team2Score, equals(10));
    });

    test('should return null when no history exists', () async {
      final loadedTournament = await service.loadFullTournamentHistory();
      expect(loadedTournament, isNull);
    });

    test('should clear tournament history', () async {
      // Create and save a tournament
      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [],
      );

      await service.saveFullTournamentHistory(tournament);

      // Verify it was saved
      var loaded = await service.loadFullTournamentHistory();
      expect(loaded, isNotNull);

      // Clear history
      await service.clearFullTournamentHistory();

      // Verify it was cleared
      loaded = await service.loadFullTournamentHistory();
      expect(loaded, isNull);
    });

    test('should clear history when clearing tournament', () async {
      // Create and save both tournament and history
      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [],
      );

      await service.saveTournament(tournament);
      await service.saveFullTournamentHistory(tournament);

      // Verify both were saved
      var loaded = await service.loadTournament();
      expect(loaded, isNotNull);
      var loadedHistory = await service.loadFullTournamentHistory();
      expect(loadedHistory, isNotNull);

      // Clear tournament
      await service.clearTournament();

      // Verify both were cleared
      loaded = await service.loadTournament();
      expect(loaded, isNull);
      loadedHistory = await service.loadFullTournamentHistory();
      expect(loadedHistory, isNull);
    });

    test('should preserve match IDs and court assignments', () async {
      // Create a tournament with specific court assignments
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            id: 'unique-match-id-123',
            court: courts[1], // Deliberately use second court
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
          ),
        ],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round1],
      );

      // Save and load
      await service.saveFullTournamentHistory(tournament);
      final loaded = await service.loadFullTournamentHistory();

      // Verify exact preservation
      expect(loaded!.rounds[0].matches[0].id, equals('unique-match-id-123'));
      expect(loaded.rounds[0].matches[0].court.id, equals('2'));
      expect(loaded.rounds[0].matches[0].court.name, equals('Bane 2'));
    });
  });

  group('Round Comparison Logic', () {
    late List<Player> players;
    late List<Court> courts;

    setUp(() {
      players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
      ];

      courts = [
        Court(id: '1', name: 'Bane 1'),
      ];
    });

    // Helper function to simulate the _roundsAreIdentical logic
    bool roundsAreIdentical(Tournament history, Tournament current) {
      if (history.rounds.length < current.rounds.length) return false;
      
      for (int i = 0; i < current.rounds.length; i++) {
        final historyRound = history.rounds[i];
        final currentRound = current.rounds[i];
        
        if (historyRound.matches.length != currentRound.matches.length) return false;
        
        for (int j = 0; j < currentRound.matches.length; j++) {
          final historyMatch = historyRound.matches[j];
          final currentMatch = currentRound.matches[j];
          
          if (historyMatch.team1Score != currentMatch.team1Score ||
              historyMatch.team2Score != currentMatch.team2Score) {
            return false;
          }
        }
      }
      
      return true;
    }

    test('should detect identical rounds', () {
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
            team1Score: 15,
            team2Score: 10,
          ),
        ],
        playersOnBreak: [],
      );

      final tournament1 = Tournament(
        name: 'Test',
        players: players,
        courts: courts,
        rounds: [round1],
      );

      final round1Copy = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
            team1Score: 15,
            team2Score: 10,
          ),
        ],
        playersOnBreak: [],
      );

      final tournament2 = Tournament(
        name: 'Test',
        players: players,
        courts: courts,
        rounds: [round1Copy],
      );

      expect(roundsAreIdentical(tournament1, tournament2), isTrue);
    });

    test('should detect different scores', () {
      final tournament1 = Tournament(
        name: 'Test',
        players: players,
        courts: courts,
        rounds: [
          Round(
            roundNumber: 1,
            matches: [
              Match(
                court: courts[0],
                team1: Team(player1: players[0], player2: players[1]),
                team2: Team(player1: players[2], player2: players[3]),
                team1Score: 15,
                team2Score: 10,
              ),
            ],
            playersOnBreak: [],
          ),
        ],
      );

      final tournament2 = Tournament(
        name: 'Test',
        players: players,
        courts: courts,
        rounds: [
          Round(
            roundNumber: 1,
            matches: [
              Match(
                court: courts[0],
                team1: Team(player1: players[0], player2: players[1]),
                team2: Team(player1: players[2], player2: players[3]),
                team1Score: 12, // Different score
                team2Score: 10,
              ),
            ],
            playersOnBreak: [],
          ),
        ],
      );

      expect(roundsAreIdentical(tournament1, tournament2), isFalse);
    });

    test('should return false when history has fewer rounds', () {
      final tournament1 = Tournament(
        name: 'Test',
        players: players,
        courts: courts,
        rounds: [
          Round(roundNumber: 1, matches: [], playersOnBreak: []),
        ],
      );

      final tournament2 = Tournament(
        name: 'Test',
        players: players,
        courts: courts,
        rounds: [
          Round(roundNumber: 1, matches: [], playersOnBreak: []),
          Round(roundNumber: 2, matches: [], playersOnBreak: []),
        ],
      );

      expect(roundsAreIdentical(tournament1, tournament2), isFalse);
    });
  });
}

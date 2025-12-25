import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';

void main() {
  group('Player Model', () {
    test('should create player with id and name', () {
      final player = Player(id: '1', name: 'John Doe');
      
      expect(player.id, '1');
      expect(player.name, 'John Doe');
    });

    test('should serialize to and from JSON', () {
      final player = Player(id: '1', name: 'John Doe');
      final json = player.toJson();
      final fromJson = Player.fromJson(json);
      
      expect(fromJson.id, player.id);
      expect(fromJson.name, player.name);
    });

    test('should be equal when ids are equal', () {
      final player1 = Player(id: '1', name: 'John Doe');
      final player2 = Player(id: '1', name: 'Jane Doe');
      
      expect(player1, player2);
    });
  });

  group('Court Model', () {
    test('should create court with id and name', () {
      final court = Court(id: '1', name: 'Bane 1');
      
      expect(court.id, '1');
      expect(court.name, 'Bane 1');
    });

    test('should serialize to and from JSON', () {
      final court = Court(id: '1', name: 'Bane 1');
      final json = court.toJson();
      final fromJson = Court.fromJson(json);
      
      expect(fromJson.id, court.id);
      expect(fromJson.name, court.name);
    });
  });

  group('Match Model', () {
    test('should create match with teams and court', () {
      final court = Court(id: '1', name: 'Bane 1');
      final player1 = Player(id: '1', name: 'Player 1');
      final player2 = Player(id: '2', name: 'Player 2');
      final player3 = Player(id: '3', name: 'Player 3');
      final player4 = Player(id: '4', name: 'Player 4');

      final match = Match(
        court: court,
        team1: Team(player1: player1, player2: player2),
        team2: Team(player1: player3, player2: player4),
      );
      
      expect(match.court.name, 'Bane 1');
      expect(match.team1.player1.name, 'Player 1');
      expect(match.isCompleted, false);
    });

    test('should be completed when both scores are set', () {
      final court = Court(id: '1', name: 'Bane 1');
      final player1 = Player(id: '1', name: 'Player 1');
      final player2 = Player(id: '2', name: 'Player 2');
      final player3 = Player(id: '3', name: 'Player 3');
      final player4 = Player(id: '4', name: 'Player 4');

      final match = Match(
        court: court,
        team1: Team(player1: player1, player2: player2),
        team2: Team(player1: player3, player2: player4),
        team1Score: 10,
        team2Score: 15,
      );
      
      expect(match.isCompleted, true);
    });

    test('should serialize to and from JSON', () {
      final court = Court(id: '1', name: 'Bane 1');
      final player1 = Player(id: '1', name: 'Player 1');
      final player2 = Player(id: '2', name: 'Player 2');
      final player3 = Player(id: '3', name: 'Player 3');
      final player4 = Player(id: '4', name: 'Player 4');

      final match = Match(
        id: 'match1',
        court: court,
        team1: Team(player1: player1, player2: player2),
        team2: Team(player1: player3, player2: player4),
        team1Score: 10,
        team2Score: 15,
      );
      
      final json = match.toJson();
      final fromJson = Match.fromJson(json);
      
      expect(fromJson.id, match.id);
      expect(fromJson.team1Score, 10);
      expect(fromJson.team2Score, 15);
    });

    test('should include reasoning when provided', () {
      final court = Court(id: '1', name: 'Bane 1');
      final player1 = Player(id: '1', name: 'Player 1');
      final player2 = Player(id: '2', name: 'Player 2');
      final player3 = Player(id: '3', name: 'Player 3');
      final player4 = Player(id: '4', name: 'Player 4');

      final reasoning = MatchupReasoning(
        roundType: 'first',
        pairingMethod: 'Random pairing',
        laneAssignment: 'Sequential assignment',
        playerMetadata: {'Player 1': 'Rank 1', 'Player 2': 'Rank 2'},
      );

      final match = Match(
        id: 'match1',
        court: court,
        team1: Team(player1: player1, player2: player2),
        team2: Team(player1: player3, player2: player4),
        reasoning: reasoning,
      );
      
      expect(match.reasoning, isNotNull);
      expect(match.reasoning!.roundType, 'first');
      expect(match.reasoning!.pairingMethod, 'Random pairing');
      expect(match.reasoning!.laneAssignment, 'Sequential assignment');
    });

    test('should serialize reasoning to and from JSON', () {
      final court = Court(id: '1', name: 'Bane 1');
      final player1 = Player(id: '1', name: 'Player 1');
      final player2 = Player(id: '2', name: 'Player 2');
      final player3 = Player(id: '3', name: 'Player 3');
      final player4 = Player(id: '4', name: 'Player 4');

      final reasoning = MatchupReasoning(
        roundType: 'final',
        pairingMethod: 'Rank-based',
        laneAssignment: 'Random',
        playerMetadata: {'Player 1': 'Rank 1'},
      );

      final match = Match(
        id: 'match1',
        court: court,
        team1: Team(player1: player1, player2: player2),
        team2: Team(player1: player3, player2: player4),
        reasoning: reasoning,
      );
      
      final json = match.toJson();
      final fromJson = Match.fromJson(json);
      
      expect(fromJson.reasoning, isNotNull);
      expect(fromJson.reasoning!.roundType, 'final');
      expect(fromJson.reasoning!.pairingMethod, 'Rank-based');
      expect(fromJson.reasoning!.playerMetadata!['Player 1'], 'Rank 1');
    });
  });

  group('Round Model', () {
    test('should create round with matches and players on break', () {
      final court = Court(id: '1', name: 'Bane 1');
      final player1 = Player(id: '1', name: 'Player 1');
      final player2 = Player(id: '2', name: 'Player 2');
      final player3 = Player(id: '3', name: 'Player 3');
      final player4 = Player(id: '4', name: 'Player 4');
      final player5 = Player(id: '5', name: 'Player 5');

      final match = Match(
        court: court,
        team1: Team(player1: player1, player2: player2),
        team2: Team(player1: player3, player2: player4),
      );

      final round = Round(
        roundNumber: 1,
        matches: [match],
        playersOnBreak: [player5],
      );
      
      expect(round.roundNumber, 1);
      expect(round.matches.length, 1);
      expect(round.playersOnBreak.length, 1);
      expect(round.isCompleted, false);
    });
  });

  group('Tournament Model', () {
    test('should create tournament with players and courts', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
      ];

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
      );
      
      expect(tournament.name, 'Test Tournament');
      expect(tournament.players.length, 4);
      expect(tournament.courts.length, 2);
      expect(tournament.currentRound, null);
      expect(tournament.completedRounds, 0);
    });

    test('should serialize to and from JSON', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
      ];

      final courts = [
        Court(id: '1', name: 'Bane 1'),
      ];

      final tournament = Tournament(
        id: 'tournament1',
        name: 'Test Tournament',
        players: players,
        courts: courts,
      );
      
      final json = tournament.toJson();
      final fromJson = Tournament.fromJson(json);
      
      expect(fromJson.id, tournament.id);
      expect(fromJson.name, tournament.name);
      expect(fromJson.players.length, 2);
      expect(fromJson.courts.length, 1);
    });

    test('should create copy with updated fields using copyWith', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
      ];

      final courts = [
        Court(id: '1', name: 'Bane 1'),
      ];

      final tournament = Tournament(
        id: 'tournament1',
        name: 'Test Tournament',
        players: players,
        courts: courts,
      );
      
      final updatedTournament = tournament.copyWith(
        name: 'Updated Tournament',
      );
      
      expect(updatedTournament.id, tournament.id);
      expect(updatedTournament.name, 'Updated Tournament');
      expect(updatedTournament.players, tournament.players);
      expect(updatedTournament.courts, tournament.courts);
    });

    test('should handle null rounds in JSON', () {
      final json = {
        'id': 'tournament1',
        'name': 'Test Tournament',
        'players': [
          {'id': '1', 'name': 'Player 1'},
        ],
        'courts': [
          {'id': '1', 'name': 'Bane 1'},
        ],
        'rounds': null,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final tournament = Tournament.fromJson(json);
      
      expect(tournament.rounds, isEmpty);
      expect(tournament.currentRound, isNull);
    });
  });
}

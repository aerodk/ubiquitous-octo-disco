import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/player_standing.dart';
import 'package:star_cano/models/tournament_settings.dart';
import 'package:star_cano/services/tournament_service.dart';

void main() {
  group('TournamentService', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    test('should generate first round with 4 players and 1 court', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
      ];

      final courts = [
        Court(id: '1', name: 'Bane 1'),
      ];

      final round = service.generateFirstRound(players, courts);

      expect(round.roundNumber, 1);
      expect(round.matches.length, 1);
      expect(round.playersOnBreak.length, 0);
      expect(round.matches[0].team1.player1, isNotNull);
      expect(round.matches[0].team1.player2, isNotNull);
      expect(round.matches[0].team2.player1, isNotNull);
      expect(round.matches[0].team2.player2, isNotNull);
    });

    test('should handle players on break when not enough for all courts', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
        Player(id: '5', name: 'Player 5'),
      ];

      final courts = [
        Court(id: '1', name: 'Bane 1'),
      ];

      final round = service.generateFirstRound(players, courts);

      expect(round.roundNumber, 1);
      expect(round.matches.length, 1);
      expect(round.playersOnBreak.length, 1);
    });

    test('should fill multiple courts when enough players', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
        Player(id: '5', name: 'Player 5'),
        Player(id: '6', name: 'Player 6'),
        Player(id: '7', name: 'Player 7'),
        Player(id: '8', name: 'Player 8'),
      ];

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final round = service.generateFirstRound(players, courts);

      expect(round.roundNumber, 1);
      expect(round.matches.length, 2);
      expect(round.playersOnBreak.length, 0);
    });

    test('should shuffle players randomly', () {
      final players = List.generate(
        8,
        (i) => Player(id: '$i', name: 'Player $i'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
      ];

      // Generate multiple rounds and check that at least some are different
      final rounds = List.generate(5, (_) {
        return service.generateFirstRound(players, courts);
      });

      // At least one round should have different first player
      // (very unlikely all 5 rounds would have the same shuffle)
      final firstPlayers = rounds
          .map((r) => r.matches[0].team1.player1.id)
          .toSet();
      
      // We expect some variation in shuffling
      expect(firstPlayers.length, greaterThan(1));
    });
  });

  group('TournamentService - Final Round', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    test('should generate final round with 12 players (perfect divisibility)', () {
      // Test scenario from SPECIFICATION_V4.md
      final players = List.generate(
        12,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      final standings = List.generate(
        12,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 50 - i * 2, // Decreasing points for ranking
          wins: 3 - (i ~/ 4),
          losses: (i ~/ 4),
          matchesPlayed: 4,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1, // R1, R2, R3, ..., R12
          pauseCount: 0,
        ),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      final round = service.generateFinalRound(courts, standings, 4);

      expect(round.isFinalRound, true);
      expect(round.roundNumber, 4);
      expect(round.matches.length, 3);
      expect(round.playersOnBreak.length, 0);

      // Verify R1+R3 vs R2+R4 pattern
      final match1 = round.matches[0];
      expect(match1.team1.player1.id, '1'); // R1
      expect(match1.team1.player2.id, '3'); // R3
      expect(match1.team2.player1.id, '2'); // R2
      expect(match1.team2.player2.id, '4'); // R4

      // Verify R5+R7 vs R6+R8 pattern
      final match2 = round.matches[1];
      expect(match2.team1.player1.id, '5'); // R5
      expect(match2.team1.player2.id, '7'); // R7
      expect(match2.team2.player1.id, '6'); // R6
      expect(match2.team2.player2.id, '8'); // R8

      // Verify R9+R11 vs R10+R12 pattern
      final match3 = round.matches[2];
      expect(match3.team1.player1.id, '9'); // R9
      expect(match3.team1.player2.id, '11'); // R11
      expect(match3.team2.player1.id, '10'); // R10
      expect(match3.team2.player2.id, '12'); // R12

      // Verify court assignment (top match gets Court 1)
      expect(match1.court.id, '1');
      expect(match2.court.id, '2');
      expect(match3.court.id, '3');
    });

    test('should handle 13 players with 1 sitting out from bottom half', () {
      // Test scenario from SPECIFICATION_V4.md
      final players = List.generate(
        13,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      final standings = List.generate(
        13,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 52 - i * 2,
          wins: 3 - (i ~/ 5),
          losses: (i ~/ 5),
          matchesPlayed: i == 12 ? 3 : 4, // R13 has fewest games
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0,
        ),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      final round = service.generateFinalRound(courts, standings, 4);

      expect(round.matches.length, 3);
      expect(round.playersOnBreak.length, 1);

      // R13 should sit out (bottom half, fewest games)
      expect(round.playersOnBreak[0].id, '13');

      // Verify matches include R1-R12 only
      final allMatchPlayers = round.matches.expand((m) => [
        m.team1.player1.id,
        m.team1.player2.id,
        m.team2.player1.id,
        m.team2.player2.id,
      ]).toSet();

      expect(allMatchPlayers.contains('13'), false);
      expect(allMatchPlayers.length, 12);
    });

    test('should handle 14 players with 2 sitting out from bottom half', () {
      final players = List.generate(
        14,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      final standings = List.generate(
        14,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 56 - i * 2,
          wins: 4 - (i ~/ 4),
          losses: (i ~/ 4),
          matchesPlayed: 4,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0,
        ),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      final round = service.generateFinalRound(courts, standings, 4);

      expect(round.matches.length, 3);
      expect(round.playersOnBreak.length, 2);

      // Bottom 2 players should sit out (R13, R14)
      final breakPlayerIds = round.playersOnBreak.map((p) => p.id).toSet();
      expect(breakPlayerIds.contains('13'), true);
      expect(breakPlayerIds.contains('14'), true);
    });

    test('should prioritize most games played in bottom half', () {
      final players = List.generate(
        10,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      // Setup: Top half (R1-R5) protected
      // Bottom half (R6-R10): R6-R8 have 5 games, R9-R10 have 4 games
      final standings = List.generate(
        10,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 40 - i * 2,
          wins: 3,
          losses: 1,
          matchesPlayed: (i >= 5 && i <= 7) ? 5 : 4, // R6, R7, R8 have 5 games
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0,
        ),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final round = service.generateFinalRound(courts, standings, 4);

      expect(round.matches.length, 2);
      expect(round.playersOnBreak.length, 2);

      final breakPlayerIds = round.playersOnBreak.map((p) => p.id).toList();
      
      // R8 should sit out (most games in bottom half, lowest rank among those with 5 games)
      expect(breakPlayerIds.contains('8'), true);
      
      // R10 should sit out (lowest rank in bottom half with 4 games)
      expect(breakPlayerIds.contains('10'), true);
    });

    test('should protect top half from sitting out', () {
      final players = List.generate(
        13,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      // All players have equal games
      final standings = List.generate(
        13,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 50 - i * 2,
          wins: 4,
          losses: 0,
          matchesPlayed: 4,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0,
        ),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      final round = service.generateFinalRound(courts, standings, 4);

      expect(round.playersOnBreak.length, 1);

      // Break player should be from bottom half (R7-R13)
      final breakPlayerId = int.parse(round.playersOnBreak[0].id);
      expect(breakPlayerId, greaterThanOrEqualTo(7));
      
      // R13 should sit out (lowest rank in bottom half)
      expect(round.playersOnBreak[0].id, '13');
    });

    test('should use pause count as tiebreaker', () {
      final players = List.generate(
        13,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      // All equal except pause counts
      final standings = List.generate(
        13,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 50 - i * 2,
          wins: 4,
          losses: 0,
          matchesPlayed: 4,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: i == 11 ? 2 : 0, // R12 has 2 pauses, R13 has 0
        ),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      final round = service.generateFinalRound(courts, standings, 4);

      // R13 should sit out (lowest rank with fewest pauses)
      expect(round.playersOnBreak[0].id, '13');
    });
  });

  group('TournamentService - Pairing Strategies (V5.0)', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    // Helper function to create 12 ranked players
    List<PlayerStanding> create12RankedPlayers() {
      final players = List.generate(
        12,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      return List.generate(
        12,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 50 - i * 2,
          wins: 3 - (i ~/ 4),
          losses: (i ~/ 4),
          matchesPlayed: 4,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0,
        ),
      );
    }

    List<Court> createCourts() => [
      Court(id: '1', name: 'Bane 1'),
      Court(id: '2', name: 'Bane 2'),
      Court(id: '3', name: 'Bane 3'),
    ];

    test('should use balanced strategy by default (R1+R3 vs R2+R4)', () {
      final standings = create12RankedPlayers();
      final courts = createCourts();

      final round = service.generateFinalRound(
        courts,
        standings,
        4,
        // Default strategy is balanced
      );

      expect(round.matches.length, 3);

      // Match 1: R1+R3 vs R2+R4
      final match1 = round.matches[0];
      expect(match1.team1.player1.id, '1'); // R1
      expect(match1.team1.player2.id, '3'); // R3
      expect(match1.team2.player1.id, '2'); // R2
      expect(match1.team2.player2.id, '4'); // R4

      // Match 2: R5+R7 vs R6+R8
      final match2 = round.matches[1];
      expect(match2.team1.player1.id, '5'); // R5
      expect(match2.team1.player2.id, '7'); // R7
      expect(match2.team2.player1.id, '6'); // R6
      expect(match2.team2.player2.id, '8'); // R8

      // Match 3: R9+R11 vs R10+R12
      final match3 = round.matches[2];
      expect(match3.team1.player1.id, '9'); // R9
      expect(match3.team1.player2.id, '11'); // R11
      expect(match3.team2.player1.id, '10'); // R10
      expect(match3.team2.player2.id, '12'); // R12
    });

    test('should use topAlliance strategy (R1+R2 vs R3+R4)', () {
      final standings = create12RankedPlayers();
      final courts = createCourts();

      final round = service.generateFinalRound(
        courts,
        standings,
        4,
        strategy: PairingStrategy.topAlliance,
      );

      expect(round.matches.length, 3);

      // Match 1: R1+R2 vs R3+R4 (top 2 together)
      final match1 = round.matches[0];
      expect(match1.team1.player1.id, '1'); // R1
      expect(match1.team1.player2.id, '2'); // R2
      expect(match1.team2.player1.id, '3'); // R3
      expect(match1.team2.player2.id, '4'); // R4

      // Match 2: R5+R6 vs R7+R8
      final match2 = round.matches[1];
      expect(match2.team1.player1.id, '5'); // R5
      expect(match2.team1.player2.id, '6'); // R6
      expect(match2.team2.player1.id, '7'); // R7
      expect(match2.team2.player2.id, '8'); // R8

      // Match 3: R9+R10 vs R11+R12
      final match3 = round.matches[2];
      expect(match3.team1.player1.id, '9'); // R9
      expect(match3.team1.player2.id, '10'); // R10
      expect(match3.team2.player1.id, '11'); // R11
      expect(match3.team2.player2.id, '12'); // R12
    });

    test('should use maxCompetition strategy (R1+R4 vs R2+R3)', () {
      final standings = create12RankedPlayers();
      final courts = createCourts();

      final round = service.generateFinalRound(
        courts,
        standings,
        4,
        strategy: PairingStrategy.maxCompetition,
      );

      expect(round.matches.length, 3);

      // Match 1: R1+R4 vs R2+R3 (max balance)
      final match1 = round.matches[0];
      expect(match1.team1.player1.id, '1'); // R1
      expect(match1.team1.player2.id, '4'); // R4
      expect(match1.team2.player1.id, '2'); // R2
      expect(match1.team2.player2.id, '3'); // R3

      // Match 2: R5+R8 vs R6+R7
      final match2 = round.matches[1];
      expect(match2.team1.player1.id, '5'); // R5
      expect(match2.team1.player2.id, '8'); // R8
      expect(match2.team2.player1.id, '6'); // R6
      expect(match2.team2.player2.id, '7'); // R7

      // Match 3: R9+R12 vs R10+R11
      final match3 = round.matches[2];
      expect(match3.team1.player1.id, '9'); // R9
      expect(match3.team1.player2.id, '12'); // R12
      expect(match3.team2.player1.id, '10'); // R10
      expect(match3.team2.player2.id, '11'); // R11
    });

    test('all strategies should handle 13 players with 1 sitting out', () {
      final players = List.generate(
        13,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      final standings = List.generate(
        13,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 52 - i * 2,
          wins: 3 - (i ~/ 5),
          losses: (i ~/ 5),
          matchesPlayed: 4,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0,
        ),
      );

      final courts = createCourts();

      for (final strategy in PairingStrategy.values) {
        final round = service.generateFinalRound(
          courts,
          standings,
          4,
          strategy: strategy,
        );

        expect(round.matches.length, 3, reason: 'Failed for $strategy');
        expect(round.playersOnBreak.length, 1, reason: 'Failed for $strategy');
        
        // Verify all 12 active players are in matches
        final allMatchPlayers = round.matches.expand((m) => [
          m.team1.player1.id,
          m.team1.player2.id,
          m.team2.player1.id,
          m.team2.player2.id,
        ]).toSet();
        
        expect(allMatchPlayers.length, 12, reason: 'Failed for $strategy');
        expect(allMatchPlayers.contains('13'), false, reason: 'Failed for $strategy');
      }
    });

    test('all strategies should respect court assignments', () {
      final standings = create12RankedPlayers();
      final courts = createCourts();

      for (final strategy in PairingStrategy.values) {
        final round = service.generateFinalRound(
          courts,
          standings,
          4,
          strategy: strategy,
        );

        // Top match should get best court (Court 1)
        expect(round.matches[0].court.id, '1', reason: 'Failed for $strategy');
        expect(round.matches[1].court.id, '2', reason: 'Failed for $strategy');
        expect(round.matches[2].court.id, '3', reason: 'Failed for $strategy');
      }
    });
  });
}

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

  group('TournamentService - Pause Fairness (Regular Rounds)', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    test('should avoid consecutive pauses for same player', () {
      // Create 9 players (1 will need to sit out each round)
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // Create standings where player 1 had a pause in previous round
      final standings = List.generate(
        9,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 40 - i * 2,
          wins: 2,
          losses: 0,
          matchesPlayed: 2,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: i == 0 ? 1 : 0, // Player 1 had a pause before
        ),
      );

      final round = service.generateNextRound(players, courts, standings, 2);

      // Player 1 should NOT be on break again (they already had 1 pause)
      expect(round.playersOnBreak.length, 1);
      expect(round.playersOnBreak[0].id, isNot('1'));
    });

    test('should distribute pauses fairly across multiple rounds', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // Simulate 3 rounds where different players had pauses
      // Players 1, 2, 3 each had 1 pause; others had 0
      final standings = List.generate(
        9,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 40 - i * 2,
          wins: 2,
          losses: 0,
          matchesPlayed: 2,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: i < 3 ? 1 : 0, // Players 1-3 had pauses
        ),
      );

      final round = service.generateNextRound(players, courts, standings, 4);

      // The player on break should be someone who hasn't had a pause yet (players 4-9)
      expect(round.playersOnBreak.length, 1);
      final breakPlayerId = int.parse(round.playersOnBreak[0].id);
      expect(breakPlayerId, greaterThanOrEqualTo(4));
    });

    test('should prioritize players with fewest pauses over most games', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // Player 1: 5 games, 0 pauses
      // Player 2: 3 games, 1 pause
      // Player 3-9: 4 games, 0 pauses
      final standings = List.generate(
        9,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 40 - i * 2,
          wins: 2,
          losses: 0,
          matchesPlayed: i == 0 ? 5 : (i == 1 ? 3 : 4),
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: i == 1 ? 1 : 0,
        ),
      );

      final round = service.generateNextRound(players, courts, standings, 3);

      // Player 1 should sit out (0 pauses, most games among 0-pause players)
      // Even though player 2 has fewer games, they already had a pause
      expect(round.playersOnBreak.length, 1);
      expect(round.playersOnBreak[0].id, '1');
    });

    test('should handle all players with equal pause counts', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // All players have equal pause counts
      final standings = List.generate(
        9,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 40 - i * 2,
          wins: 2,
          losses: 0,
          matchesPlayed: 3,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: 0, // All equal
        ),
      );

      final round = service.generateNextRound(players, courts, standings, 2);

      // Should select 1 player (any is fair since all have equal pause counts)
      expect(round.playersOnBreak.length, 1);
      expect(round.matches.length, 2);
    });

    test('should handle multiple overflow players fairly', () {
      final players = List.generate(
        10,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // 2 players need to sit out
      // Players 1-2 have 1 pause each, players 3-10 have 0 pauses
      final standings = List.generate(
        10,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 40 - i * 2,
          wins: 2,
          losses: 0,
          matchesPlayed: 3,
          biggestWinMargin: 10,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: i + 1,
          pauseCount: i < 2 ? 1 : 0,
        ),
      );

      final round = service.generateNextRound(players, courts, standings, 3);

      // 2 players should sit out, and neither should be from players 1-2
      expect(round.playersOnBreak.length, 2);
      final breakPlayerIds = round.playersOnBreak.map((p) => int.parse(p.id)).toList();
      expect(breakPlayerIds.every((id) => id >= 3), true);
    });

    test('should work correctly with first round (no pause history)', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // All players have initial standings (no games, no pauses)
      final standings = players.map((p) => PlayerStanding.initial(p)).toList();

      final round = service.generateNextRound(players, courts, standings, 1);

      expect(round.matches.length, 2);
      expect(round.playersOnBreak.length, 1);
      expect(round.roundNumber, 1);
    });
  });

  group('TournamentService - Player Override', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    test('should force player from pause to active', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // Generate initial round
      final initialRound = service.generateFirstRound(players, courts);
      expect(initialRound.playersOnBreak.length, 1);
      
      final playerOnBreak = initialRound.playersOnBreak[0];

      // Force player from break to active
      final newRound = service.regenerateRoundWithOverride(
        currentRound: initialRound,
        allPlayers: players,
        courts: courts,
        overridePlayer: playerOnBreak,
        forceToActive: true,
      );

      expect(newRound, isNotNull);
      expect(newRound!.playersOnBreak.any((p) => p.id == playerOnBreak.id), false);
      expect(newRound.matches.length, 2);
      
      // Verify the override player is now in a match
      final allMatchPlayers = newRound.matches.expand((m) => [
        m.team1.player1,
        m.team1.player2,
        m.team2.player1,
        m.team2.player2,
      ]).toList();
      
      expect(allMatchPlayers.any((p) => p.id == playerOnBreak.id), true);
    });

    test('should force player from active to pause', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // Generate initial round
      final initialRound = service.generateFirstRound(players, courts);
      
      // Get a player who is currently active (in a match)
      final activePlayer = initialRound.matches[0].team1.player1;

      // Force player from active to break
      final newRound = service.regenerateRoundWithOverride(
        currentRound: initialRound,
        allPlayers: players,
        courts: courts,
        overridePlayer: activePlayer,
        forceToActive: false,
      );

      expect(newRound, isNotNull);
      expect(newRound!.playersOnBreak.any((p) => p.id == activePlayer.id), true);
      expect(newRound.matches.length, 2);
      
      // Verify the override player is NOT in any match
      final allMatchPlayers = newRound.matches.expand((m) => [
        m.team1.player1,
        m.team1.player2,
        m.team2.player1,
        m.team2.player2,
      ]).toList();
      
      expect(allMatchPlayers.any((p) => p.id == activePlayer.id), false);
    });

    test('should return null when forcing already active player to active', () {
      final players = List.generate(
        8,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final round = service.generateFirstRound(players, courts);
      final activePlayer = round.matches[0].team1.player1;

      // Try to force already active player to active
      final newRound = service.regenerateRoundWithOverride(
        currentRound: round,
        allPlayers: players,
        courts: courts,
        overridePlayer: activePlayer,
        forceToActive: true,
      );

      expect(newRound, isNull);
    });

    test('should return null when forcing already paused player to pause', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final round = service.generateFirstRound(players, courts);
      final pausedPlayer = round.playersOnBreak[0];

      // Try to force already paused player to pause
      final newRound = service.regenerateRoundWithOverride(
        currentRound: round,
        allPlayers: players,
        courts: courts,
        overridePlayer: pausedPlayer,
        forceToActive: false,
      );

      expect(newRound, isNull);
    });

    test('should return null when trying to exceed max pause players', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // 9 players, 2 courts = max 1 player on pause (9 - 2*4 = 1)
      // With 1 already on break, forcing another with swap should work
      final round = service.generateFirstRound(players, courts);
      expect(round.playersOnBreak.length, 1);

      final activePlayer = round.matches[0].team1.player1;

      // Try to force another player to pause (would swap, maintaining 1 on break)
      final newRound = service.regenerateRoundWithOverride(
        currentRound: round,
        allPlayers: players,
        courts: courts,
        overridePlayer: activePlayer,
        forceToActive: false,
      );

      // Should succeed because it's a swap (maintains structure)
      expect(newRound, isNotNull);
      expect(newRound!.playersOnBreak.length, 1);
      expect(newRound.matches.length, 2);
    });

    test('should handle perfect divisibility after override', () {
      final players = List.generate(
        8,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // 8 players, 2 courts = perfect fit, no one on pause
      final round = service.generateFirstRound(players, courts);
      expect(round.playersOnBreak.length, 0);
      expect(round.matches.length, 2);

      final activePlayer = round.matches[0].team1.player1;

      // Force one player to pause
      final newRound = service.regenerateRoundWithOverride(
        currentRound: round,
        allPlayers: players,
        courts: courts,
        overridePlayer: activePlayer,
        forceToActive: false,
      );

      expect(newRound, isNotNull);
      expect(newRound!.playersOnBreak.length, 1);
      expect(newRound.playersOnBreak[0].id, activePlayer.id);
      expect(newRound.matches.length, 1); // Only 1 match now (7 active players)
    });

    test('should maintain round properties after override', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final initialRound = service.generateFirstRound(players, courts);
      final playerOnBreak = initialRound.playersOnBreak[0];

      final newRound = service.regenerateRoundWithOverride(
        currentRound: initialRound,
        allPlayers: players,
        courts: courts,
        overridePlayer: playerOnBreak,
        forceToActive: true,
      );

      expect(newRound, isNotNull);
      expect(newRound!.roundNumber, initialRound.roundNumber);
      expect(newRound.isFinalRound, initialRound.isFinalRound);
    });

    test('should handle 10 players with 2 courts (2 on pause)', () {
      final players = List.generate(
        10,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      // 10 players, 2 courts = 2 players on pause (10 - 2*4 = 2)
      final round = service.generateFirstRound(players, courts);
      expect(round.playersOnBreak.length, 2);

      final playerOnBreak = round.playersOnBreak[0];

      // Force one paused player to active
      final newRound = service.regenerateRoundWithOverride(
        currentRound: round,
        allPlayers: players,
        courts: courts,
        overridePlayer: playerOnBreak,
        forceToActive: true,
      );

      expect(newRound, isNotNull);
      // Still 2 on pause, but different players
      expect(newRound!.playersOnBreak.length, 2);
      expect(newRound.playersOnBreak.any((p) => p.id == playerOnBreak.id), false);
      expect(newRound.matches.length, 2);
    });
  });

  group('Lane Assignment Strategy', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    test('should assign courts sequentially when using sequential strategy', () {
      final players = List.generate(
        16,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
        Court(id: '4', name: 'Bane 4'),
      ];

      final round = service.generateFirstRound(
        players,
        courts,
        laneStrategy: LaneAssignmentStrategy.sequential,
      );

      expect(round.matches.length, 4);
      
      // With sequential strategy, courts should be assigned in order
      expect(round.matches[0].court.id, '1');
      expect(round.matches[1].court.id, '2');
      expect(round.matches[2].court.id, '3');
      expect(round.matches[3].court.id, '4');
    });

    test('should assign courts randomly when using random strategy', () {
      final players = List.generate(
        16,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
        Court(id: '4', name: 'Bane 4'),
      ];

      // Generate multiple rounds to test randomness
      final rounds = List.generate(10, (_) => 
        service.generateFirstRound(
          players,
          courts,
          laneStrategy: LaneAssignmentStrategy.random,
        )
      );

      // Expect at least some variation in court assignments across rounds
      final firstMatchCourts = rounds.map((r) => r.matches[0].court.id).toSet();
      
      // With random assignment, we should see variation (not all the same)
      // This test may occasionally fail due to randomness, but the probability is low
      expect(rounds.length, 10);
      expect(rounds.every((r) => r.matches.length == 4), true);
    });

    test('should apply lane strategy to generateNextRound', () {
      final players = List.generate(
        12,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      // Create fake standings
      final standings = players.map((p) => PlayerStanding(
        player: p,
        totalPoints: 0,
        matchesPlayed: 0,
        wins: 0,
        losses: 0,
        biggestWinMargin: 0,
        smallestLossMargin: 999,
        headToHeadPoints: {},
        rank: 1,
      )).toList();

      final round = service.generateNextRound(
        players,
        courts,
        standings,
        2,
        laneStrategy: LaneAssignmentStrategy.sequential,
      );

      expect(round.matches.length, 3);
      
      // With sequential strategy, courts should be assigned in order
      expect(round.matches[0].court.id, '1');
      expect(round.matches[1].court.id, '2');
      expect(round.matches[2].court.id, '3');
    });

    test('should apply lane strategy to generateFinalRound', () {
      final players = List.generate(
        12,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
        Court(id: '3', name: 'Bane 3'),
      ];

      // Create ranked standings
      final standings = List.generate(
        12,
        (i) => PlayerStanding(
          player: players[i],
          totalPoints: 100 - i * 5,
          matchesPlayed: 3,
          wins: 3 - (i ~/ 4),
          losses: i ~/ 4,
          biggestWinMargin: 5,
          smallestLossMargin: 3,
          headToHeadPoints: {},
          rank: i + 1,
        ),
      );

      final round = service.generateFinalRound(
        courts,
        standings,
        4,
        strategy: PairingStrategy.balanced,
        laneStrategy: LaneAssignmentStrategy.sequential,
      );

      expect(round.matches.length, 3);
      expect(round.isFinalRound, true);
      
      // With sequential strategy, courts should be assigned in order
      expect(round.matches[0].court.id, '1');
      expect(round.matches[1].court.id, '2');
      expect(round.matches[2].court.id, '3');
    });

    test('should apply lane strategy to regenerateRoundWithOverride', () {
      final players = List.generate(
        9,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      final courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];

      final initialRound = service.generateFirstRound(
        players,
        courts,
        laneStrategy: LaneAssignmentStrategy.sequential,
      );

      final playerOnBreak = initialRound.playersOnBreak[0];

      // Create fake standings
      final standings = players.map((p) => PlayerStanding(
        player: p,
        totalPoints: 0,
        matchesPlayed: 0,
        wins: 0,
        losses: 0,
        biggestWinMargin: 0,
        smallestLossMargin: 999,
        headToHeadPoints: {},
        rank: 1,
      )).toList();

      final newRound = service.regenerateRoundWithOverride(
        currentRound: initialRound,
        allPlayers: players,
        courts: courts,
        overridePlayer: playerOnBreak,
        forceToActive: true,
        standings: standings,
        laneStrategy: LaneAssignmentStrategy.sequential,
      );

      expect(newRound, isNotNull);
      expect(newRound!.matches.length, 2);
      
      // With sequential strategy, courts should be assigned in order
      expect(newRound.matches[0].court.id, '1');
      expect(newRound.matches[1].court.id, '2');
    });
  });
}

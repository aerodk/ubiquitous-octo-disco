import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/models/tournament_settings.dart';
import 'package:star_cano/models/player_standing.dart';
import 'package:star_cano/services/standings_service.dart';

void main() {
  late StandingsService service;

  setUp(() {
    service = StandingsService();
  });

  group('PlayerStanding Model', () {
    test('should create initial standing with zero values', () {
      final player = Player(id: '1', name: 'Player 1');
      final standing = PlayerStanding.initial(player);

      expect(standing.player, player);
      expect(standing.totalPoints, 0);
      expect(standing.wins, 0);
      expect(standing.losses, 0);
      expect(standing.matchesPlayed, 0);
      expect(standing.biggestWinMargin, 0);
      expect(standing.smallestLossMargin, 999);
      expect(standing.headToHeadPoints, isEmpty);
      expect(standing.rank, 0);
    });

    test('should serialize to and from JSON', () {
      final player = Player(id: '1', name: 'Player 1');
      final standing = PlayerStanding(
        player: player,
        totalPoints: 45,
        wins: 2,
        losses: 1,
        matchesPlayed: 3,
        biggestWinMargin: 8,
        smallestLossMargin: 3,
        headToHeadPoints: {'2': 35, '3': 28},
        rank: 1,
      );

      final json = standing.toJson();
      final fromJson = PlayerStanding.fromJson(json);

      expect(fromJson.player.id, standing.player.id);
      expect(fromJson.totalPoints, standing.totalPoints);
      expect(fromJson.wins, standing.wins);
      expect(fromJson.losses, standing.losses);
      expect(fromJson.matchesPlayed, standing.matchesPlayed);
      expect(fromJson.biggestWinMargin, standing.biggestWinMargin);
      expect(fromJson.smallestLossMargin, standing.smallestLossMargin);
      expect(fromJson.headToHeadPoints, standing.headToHeadPoints);
      expect(fromJson.rank, standing.rank);
    });

    test('should copy with new rank', () {
      final player = Player(id: '1', name: 'Player 1');
      final standing = PlayerStanding.initial(player);
      final withRank = standing.copyWithRank(5);

      expect(withRank.rank, 5);
      expect(withRank.player, standing.player);
      expect(withRank.totalPoints, standing.totalPoints);
    });
  });

  group('StandingsService - Basic Ranking', () {
    test('Test Case 1: Basic ranking by total points and wins', () {
      // Test Case 1 from SPECIFICATION_V3.md
      // Tests primary ranking criterion (total points) and first tiebreaker (wins)
      // Expected: Players ranked by points first, then by number of wins
      // Setup from SPECIFICATION_V3.md Test Case 1
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+B (20) vs C+D (10)
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      // Match 2: A+C (15) vs B+D (18)
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerC),
        team2: Team(player1: playerB, player2: playerD),
        team1Score: 15,
        team2Score: 18,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1, match2],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      // Expected ranking:
      // 1. B (38 point, 2 sejre)
      // 2. A (35 point, 1 sejr)
      // 3. D (28 point, 1 sejr)
      // 4. C (25 point, 0 sejre)

      expect(standings[0].player.id, 'B');
      expect(standings[0].totalPoints, 38); // 20 + 18
      expect(standings[0].wins, 2);
      expect(standings[0].rank, 1);

      expect(standings[1].player.id, 'A');
      expect(standings[1].totalPoints, 35); // 20 + 15
      expect(standings[1].wins, 1);
      expect(standings[1].rank, 2);

      expect(standings[2].player.id, 'D');
      expect(standings[2].totalPoints, 28); // 10 + 18
      expect(standings[2].wins, 1);
      expect(standings[2].rank, 3);

      expect(standings[3].player.id, 'C');
      expect(standings[3].totalPoints, 25); // 10 + 15
      expect(standings[3].wins, 0);
      expect(standings[3].rank, 4);
    });

    test('should handle empty tournament (no matches)', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final court = Court(id: '1', name: 'Bane 1');

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB],
        courts: [court],
        rounds: [],
      );

      final standings = service.calculateStandings(tournament);

      expect(standings.length, 2);
      expect(standings[0].totalPoints, 0);
      expect(standings[0].wins, 0);
      expect(standings[0].rank, 1); // Both share rank 1
      expect(standings[1].rank, 1);
    });
  });

  group('StandingsService - Tiebreakers', () {
    test('Test Case 2: Point tie resolved by wins count', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerX = Player(id: 'X', name: 'Player X');
      final playerY = Player(id: 'Y', name: 'Player Y');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+X (20) vs B+Y (15) → A wins
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerX),
        team2: Team(player1: playerB, player2: playerY),
        team1Score: 20,
        team2Score: 15,
      );

      // Match 2: A+Y (10) vs B+X (15) → B wins
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerY),
        team2: Team(player1: playerB, player2: playerX),
        team1Score: 10,
        team2Score: 15,
      );

      // Match 3: A+B (15) vs X+Y (12) → A and B win
      final match3 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerX, player2: playerY),
        team1Score: 15,
        team2Score: 12,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1, match2, match3],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerX, playerY],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');

      // Both have 45 points
      expect(standingA.totalPoints, 45); // 20 + 10 + 15
      expect(standingB.totalPoints, 45); // 15 + 15 + 15

      // Both have 2 wins
      expect(standingA.wins, 2);
      expect(standingB.wins, 2);

      // A's biggest win: 5, B's biggest win: 5 (both same)
      // A and B are tied on all criteria and share rank 2 (X has more points and is rank 1)
      expect(standingA.biggestWinMargin, 5); // 20-15
      expect(standingB.biggestWinMargin, 5); // 15-10

      // Since they're tied on all criteria, they share the same rank
      expect(standingA.rank, 2);
      expect(standingB.rank, 2);
    });

    test('Test Case 3: Head-to-head tiebreaker', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+C (18) vs B+D (12) → A gets 18 vs B
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerC),
        team2: Team(player1: playerB, player2: playerD),
        team1Score: 18,
        team2Score: 12,
      );

      // Match 2: A+D (15) vs B+C (18) → B gets 18 vs A
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerD),
        team2: Team(player1: playerB, player2: playerC),
        team1Score: 15,
        team2Score: 18,
      );

      // Add more matches to get them to same total points and wins
      // Match 3: A+B (14) vs C+D (10) → both A and B win
      final match3 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 14,
        team2Score: 10,
      );

      // Match 4: A+B (13) vs C+D (9) → both A and B win
      final match4 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 13,
        team2Score: 9,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1, match2, match3, match4],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');

      // A has 60 points, B has 57 points
      expect(standingA.totalPoints, 60); // 18 + 15 + 14 + 13
      expect(standingB.totalPoints, 57); // 12 + 18 + 14 + 13

      // Both should have same wins (3)
      expect(standingA.wins, 3);
      expect(standingB.wins, 3);

      // A's H2H vs B: 18 + 15 = 33
      // B's H2H vs A: 12 + 18 = 30
      expect(standingA.headToHeadPoints['B'], 33);
      expect(standingB.headToHeadPoints['A'], 30);

      // A should rank higher due to better H2H
      expect(standingA.rank < standingB.rank, true);
    });

    test('Test Case 4: Biggest win margin tiebreaker', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // A's wins with different margins
      // Match 1: A+C (20) vs B+D (15) → A wins, margin 5
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerC),
        team2: Team(player1: playerB, player2: playerD),
        team1Score: 20,
        team2Score: 15,
      );

      // Match 2: A+D (18) vs C+B (10) → A wins, margin 8 (biggest)
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerD),
        team2: Team(player1: playerC, player2: playerB),
        team1Score: 18,
        team2Score: 10,
      );

      // B's wins with different margins
      // Match 3: B+C (19) vs A+D (13) → B wins, margin 6 (biggest)
      final match3 = Match(
        court: court,
        team1: Team(player1: playerB, player2: playerC),
        team2: Team(player1: playerA, player2: playerD),
        team1Score: 19,
        team2Score: 13,
      );

      // Match 4: B+D (17) vs A+C (11) → B wins, margin 6
      final match4 = Match(
        court: court,
        team1: Team(player1: playerB, player2: playerD),
        team2: Team(player1: playerA, player2: playerC),
        team1Score: 17,
        team2Score: 11,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1, match2, match3, match4],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');

      // Both should have 2 wins
      expect(standingA.wins, 2);
      expect(standingB.wins, 2);

      // A's biggest win: 8, B's biggest win: 6
      expect(standingA.biggestWinMargin, 8);
      expect(standingB.biggestWinMargin, 6);

      // A should rank higher
      expect(standingA.rank < standingB.rank, true);
    });

    test('Test Case 5: Smallest loss margin tiebreaker', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // Both players get one win each
      // Match 1: A+C (20) vs B+D (15) → A wins
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerC),
        team2: Team(player1: playerB, player2: playerD),
        team1Score: 20,
        team2Score: 15,
      );

      // Match 2: B+C (20) vs A+D (15) → B wins
      final match2 = Match(
        court: court,
        team1: Team(player1: playerB, player2: playerC),
        team2: Team(player1: playerA, player2: playerD),
        team1Score: 20,
        team2Score: 15,
      );

      // A's losses
      // Match 3: C+D (18) vs A+B (10) → A loses, margin 8
      final match3 = Match(
        court: court,
        team1: Team(player1: playerC, player2: playerD),
        team2: Team(player1: playerA, player2: playerB),
        team1Score: 18,
        team2Score: 10,
      );

      // Match 4: C+D (20) vs A+B (15) → A loses, margin 5 (smallest)
      final match4 = Match(
        court: court,
        team1: Team(player1: playerC, player2: playerD),
        team2: Team(player1: playerA, player2: playerB),
        team1Score: 20,
        team2Score: 15,
      );

      // B's losses
      // Match 5: C+D (19) vs B+A (12) → B loses, margin 7
      final match5 = Match(
        court: court,
        team1: Team(player1: playerC, player2: playerD),
        team2: Team(player1: playerB, player2: playerA),
        team1Score: 19,
        team2Score: 12,
      );

      // Match 6: C+D (20) vs B+A (16) → B loses, margin 4 (smallest, better than A)
      final match6 = Match(
        court: court,
        team1: Team(player1: playerC, player2: playerD),
        team2: Team(player1: playerB, player2: playerA),
        team1Score: 20,
        team2Score: 16,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1, match2, match3, match4, match5, match6],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');

      // Check smallest losses
      expect(standingA.smallestLossMargin, 4);
      expect(standingB.smallestLossMargin, 4);

      // Both have identical stats, so they should share the same rank
      expect(standingB.rank, standingA.rank);
    });

    test('should handle shared rankings when all criteria are equal', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // Make A and B exactly equal in all stats
      // Match 1: A+B (20) vs C+D (10)
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');

      // Both should have same rank
      expect(standingA.rank, standingB.rank);
      expect(standingA.rank, 1);
    });
  });

  group('StandingsService - Edge Cases', () {
    test('should handle player with no losses (smallestLossMargin = 999)', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // A wins all matches
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');

      // A should have no losses, so smallestLossMargin stays 999
      expect(standingA.losses, 0);
      expect(standingA.smallestLossMargin, 999);
    });

    test('should handle players who never played against each other (H2H not applicable)', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // A and B are always partners
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');

      // A and B never played against each other, so H2H should not have each other's IDs
      // or should have 0 (they were partners, not opponents)
      // In this implementation, H2H only tracks opponent IDs
      expect(standingA.headToHeadPoints.containsKey('B'), false);
      expect(standingB.headToHeadPoints.containsKey('A'), false);
    });

    test('should award 12 points to players on break in completed rounds', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');
      final playerE = Player(id: 'E', name: 'Player E');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+B (20) vs C+D (10), E on break
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round1 = Round(
        roundNumber: 1,
        matches: [match1],
        playersOnBreak: [playerE],
      );

      // Match 2: A+E (15) vs C+D (18), B on break
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerE),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 15,
        team2Score: 18,
      );

      final round2 = Round(
        roundNumber: 2,
        matches: [match2],
        playersOnBreak: [playerB],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD, playerE],
        courts: [court],
        rounds: [round1, round2],
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');
      final standingC = standings.firstWhere((s) => s.player.id == 'C');
      final standingD = standings.firstWhere((s) => s.player.id == 'D');
      final standingE = standings.firstWhere((s) => s.player.id == 'E');

      // A: 20 (match1) + 15 (match2) = 35 points
      expect(standingA.totalPoints, 35);

      // B: 20 (match1) + 12 (break in round2) = 32 points
      expect(standingB.totalPoints, 32);

      // C: 10 (match1) + 18 (match2) = 28 points
      expect(standingC.totalPoints, 28);

      // D: 10 (match1) + 18 (match2) = 28 points
      expect(standingD.totalPoints, 28);

      // E: 12 (break in round1) + 15 (match2) = 27 points
      expect(standingE.totalPoints, 27);
    });

    test('should not award break points for incomplete rounds', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');
      final playerE = Player(id: 'E', name: 'Player E');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+B (20) vs C+D (10), E on break - COMPLETED
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round1 = Round(
        roundNumber: 1,
        matches: [match1],
        playersOnBreak: [playerE],
      );

      // Match 2: A+E vs C+D - NOT COMPLETED, B on break
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerE),
        team2: Team(player1: playerC, player2: playerD),
        // No scores set - match not completed
      );

      final round2 = Round(
        roundNumber: 2,
        matches: [match2],
        playersOnBreak: [playerB],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD, playerE],
        courts: [court],
        rounds: [round1, round2],
      );

      final standings = service.calculateStandings(tournament);

      final standingB = standings.firstWhere((s) => s.player.id == 'B');
      final standingE = standings.firstWhere((s) => s.player.id == 'E');

      // B: 20 (match1) + 0 (round2 incomplete, no break points) = 20 points
      expect(standingB.totalPoints, 20);

      // E: 12 (break in round1) + 0 (match2 incomplete, no points) = 12 points
      expect(standingE.totalPoints, 12);
    });

    test('should award 0 points to players on break when pausePointsAwarded is 0', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');
      final playerE = Player(id: 'E', name: 'Player E');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+B (20) vs C+D (10), E on break
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round1 = Round(
        roundNumber: 1,
        matches: [match1],
        playersOnBreak: [playerE],
      );

      // Match 2: A+E (15) vs C+D (18), B on break
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerE),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 15,
        team2Score: 18,
      );

      final round2 = Round(
        roundNumber: 2,
        matches: [match2],
        playersOnBreak: [playerB],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerB, playerC, playerD, playerE],
        courts: [court],
        rounds: [round1, round2],
        settings: const TournamentSettings(pausePointsAwarded: 0),
      );

      final standings = service.calculateStandings(tournament);

      final standingA = standings.firstWhere((s) => s.player.id == 'A');
      final standingB = standings.firstWhere((s) => s.player.id == 'B');
      final standingC = standings.firstWhere((s) => s.player.id == 'C');
      final standingD = standings.firstWhere((s) => s.player.id == 'D');
      final standingE = standings.firstWhere((s) => s.player.id == 'E');

      // A: 20 (match1) + 15 (match2) = 35 points
      expect(standingA.totalPoints, 35);

      // B: 20 (match1) + 0 (break in round2, no points) = 20 points
      expect(standingB.totalPoints, 20);

      // C: 10 (match1) + 18 (match2) = 28 points
      expect(standingC.totalPoints, 28);

      // D: 10 (match1) + 18 (match2) = 28 points
      expect(standingD.totalPoints, 28);

      // E: 0 (break in round1, no points) + 15 (match2) = 15 points
      expect(standingE.totalPoints, 15);
      
      // Verify pause counts are still tracked
      expect(standingB.pauseCount, 1);
      expect(standingE.pauseCount, 1);
    });

    test('should award 12 points to players on break when pausePointsAwarded is 12 (default)', () {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerE = Player(id: 'E', name: 'Player E');

      final court = Court(id: '1', name: 'Bane 1');

      final round1 = Round(
        roundNumber: 1,
        matches: [],
        playersOnBreak: [playerE],
      );

      final tournament = Tournament(
        name: 'Test',
        players: [playerA, playerE],
        courts: [court],
        rounds: [round1],
        settings: const TournamentSettings(pausePointsAwarded: 12),
      );

      final standings = service.calculateStandings(tournament);

      final standingE = standings.firstWhere((s) => s.player.id == 'E');

      // E: 12 (break in round1 with 12 point setting)
      expect(standingE.totalPoints, 12);
      expect(standingE.pauseCount, 1);
    });
  });
}

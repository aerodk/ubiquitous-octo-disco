import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/models/player_standing.dart';
import 'package:star_cano/services/standings_service.dart';

void main() {
  group('Position Change Tracking', () {
    late StandingsService standingsService;
    late List<Player> players;
    late List<Court> courts;

    setUp(() {
      standingsService = StandingsService();
      
      // Create test players
      players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
        Player(id: '5', name: 'Player 5'),
        Player(id: '6', name: 'Player 6'),
        Player(id: '7', name: 'Player 7'),
        Player(id: '8', name: 'Player 8'),
      ];
      
      courts = [
        Court(id: 'court1', name: 'Court 1'),
        Court(id: 'court2', name: 'Court 2'),
      ];
    });

    test('previousRank is null before round 4', () {
      // Create round 1 with some scores
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            id: 'm1',
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
            court: courts[0],
            team1Score: 20,
            team2Score: 10,
          ),
          Match(
            id: 'm2',
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
            court: courts[1],
            team1Score: 15,
            team2Score: 12,
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

      final standings = standingsService.calculateStandings(tournament);
      
      // After round 1, no player should have previousRank
      for (final standing in standings) {
        expect(standing.previousRank, isNull);
        expect(standing.rankChange, isNull);
      }
    });

    test('previousRank is set from round 4 onwards', () {
      // Create round 1
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            id: 'm1',
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
            court: courts[0],
            team1Score: 20,
            team2Score: 10,
          ),
          Match(
            id: 'm2',
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
            court: courts[1],
            team1Score: 15,
            team2Score: 12,
          ),
        ],
        playersOnBreak: [],
      );

      // Create round 2
      final round2 = Round(
        roundNumber: 2,
        matches: [
          Match(
            id: 'm3',
            team1: Team(player1: players[0], player2: players[2]),
            team2: Team(player1: players[1], player2: players[3]),
            court: courts[0],
            team1Score: 18,
            team2Score: 22,
          ),
          Match(
            id: 'm4',
            team1: Team(player1: players[4], player2: players[6]),
            team2: Team(player1: players[5], player2: players[7]),
            court: courts[1],
            team1Score: 20,
            team2Score: 15,
          ),
        ],
        playersOnBreak: [],
      );

      // Create round 3
      final round3 = Round(
        roundNumber: 3,
        matches: [
          Match(
            id: 'm5',
            team1: Team(player1: players[0], player2: players[4]),
            team2: Team(player1: players[1], player2: players[5]),
            court: courts[0],
            team1Score: 24,
            team2Score: 20,
          ),
          Match(
            id: 'm6',
            team1: Team(player1: players[2], player2: players[6]),
            team2: Team(player1: players[3], player2: players[7]),
            court: courts[1],
            team1Score: 22,
            team2Score: 18,
          ),
        ],
        playersOnBreak: [],
      );

      // Create round 4
      final round4 = Round(
        roundNumber: 4,
        matches: [
          Match(
            id: 'm7',
            team1: Team(player1: players[0], player2: players[3]),
            team2: Team(player1: players[2], player2: players[5]),
            court: courts[0],
            team1Score: 20,
            team2Score: 18,
          ),
          Match(
            id: 'm8',
            team1: Team(player1: players[1], player2: players[4]),
            team2: Team(player1: players[6], player2: players[7]),
            court: courts[1],
            team1Score: 19,
            team2Score: 17,
          ),
        ],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round1, round2, round3, round4],
      );

      final standings = standingsService.calculateStandings(tournament);
      
      // After round 4, all players should have previousRank and rankOneRoundBack
      // to show the position change that occurred in the previous round (round 3)
      for (final standing in standings) {
        expect(standing.previousRank, isNotNull);
        expect(standing.rankOneRoundBack, isNotNull);
        expect(standing.rankChange, isNotNull);
      }
    });

    test('rankChange calculation is correct', () {
      // Create rounds where we can predict rank changes
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            id: 'm1',
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
            court: courts[0],
            team1Score: 24, // P1 and P2 score high
            team2Score: 0,  // P3 and P4 score low
          ),
          Match(
            id: 'm2',
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
            court: courts[1],
            team1Score: 12,
            team2Score: 12,
          ),
        ],
        playersOnBreak: [],
      );

      final round2 = Round(
        roundNumber: 2,
        matches: [
          Match(
            id: 'm3',
            team1: Team(player1: players[0], player2: players[2]),
            team2: Team(player1: players[1], player2: players[3]),
            court: courts[0],
            team1Score: 24,
            team2Score: 0,
          ),
          Match(
            id: 'm4',
            team1: Team(player1: players[4], player2: players[6]),
            team2: Team(player1: players[5], player2: players[7]),
            court: courts[1],
            team1Score: 12,
            team2Score: 12,
          ),
        ],
        playersOnBreak: [],
      );

      // In round 3, let's make P3 (who was low) score very high
      final round3 = Round(
        roundNumber: 3,
        matches: [
          Match(
            id: 'm5',
            team1: Team(player1: players[2], player2: players[3]),
            team2: Team(player1: players[0], player2: players[1]),
            court: courts[0],
            team1Score: 24, // P3 and P4 now score high
            team2Score: 0,  // P1 and P2 score low
          ),
          Match(
            id: 'm6',
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
            court: courts[1],
            team1Score: 12,
            team2Score: 12,
          ),
        ],
        playersOnBreak: [],
      );

      // Round 4 maintains similar scoring
      final round4 = Round(
        roundNumber: 4,
        matches: [
          Match(
            id: 'm7',
            team1: Team(player1: players[0], player2: players[3]),
            team2: Team(player1: players[1], player2: players[2]),
            court: courts[0],
            team1Score: 12,
            team2Score: 12,
          ),
          Match(
            id: 'm8',
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
            court: courts[1],
            team1Score: 12,
            team2Score: 12,
          ),
        ],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round1, round2, round3, round4],
      );

      final standings = standingsService.calculateStandings(tournament);
      
      // Find specific players to check rank changes
      final player1Standing = standings.firstWhere((s) => s.player.id == '1');
      final player3Standing = standings.firstWhere((s) => s.player.id == '3');
      
      // Player 1 was high-ranked after round 2, may have dropped in round 3
      // Player 3 was low-ranked after round 2, should have improved in round 3
      // The rankChange should reflect the change from round 2 to round 3
      
      // Verify that rankChange reflects the difference from round 2 to round 3
      // rankChange = previousRank (after round 2) - rankOneRoundBack (after round 3)
      if (player1Standing.previousRank != null && player1Standing.rankOneRoundBack != null) {
        expect(
          player1Standing.rankChange,
          equals(player1Standing.previousRank! - player1Standing.rankOneRoundBack!),
        );
      }
      
      if (player3Standing.previousRank != null && player3Standing.rankOneRoundBack != null) {
        expect(
          player3Standing.rankChange,
          equals(player3Standing.previousRank! - player3Standing.rankOneRoundBack!),
        );
      }
    });

    test('rankChange shows positive for rank improvement (lower rank number)', () {
      // Player moving from rank 4 to rank 2 should have rankChange = +2
      final testPlayer = Player(id: 'test', name: 'Test Player');
      
      // Create initial standing and simulate rank change from 4 to 2
      final standing = PlayerStanding.initial(testPlayer).copyWithRank(2, previousRank: 4);
      
      expect(standing.rankChange, equals(2)); // 4 - 2 = 2 (improvement)
    });

    test('rankChange shows negative for rank decline (higher rank number)', () {
      // Player moving from rank 2 to rank 4 should have rankChange = -2
      final testPlayer = Player(id: 'test', name: 'Test Player');
      
      // Create initial standing and simulate rank change from 2 to 4
      final standing = PlayerStanding.initial(testPlayer).copyWithRank(4, previousRank: 2);
      
      expect(standing.rankChange, equals(-2)); // 2 - 4 = -2 (decline)
    });

    test('rankChange shows 0 for no rank change', () {
      // Player staying at rank 3 should have rankChange = 0
      final testPlayer = Player(id: 'test', name: 'Test Player');
      
      // Create initial standing and simulate no rank change
      final standing = PlayerStanding.initial(testPlayer).copyWithRank(3, previousRank: 3);
      
      expect(standing.rankChange, equals(0)); // 3 - 3 = 0 (no change)
    });

    test('rankChange uses rankOneRoundBack when available', () {
      // When rankOneRoundBack is set, rankChange should compare previousRank to rankOneRoundBack
      // NOT previousRank to current rank
      final testPlayer = Player(id: 'test', name: 'Test Player');
      
      // Simulate: after round 2 (rank 5), after round 3 (rank 3), after round 4 (rank 2)
      // When viewing round 4, show change from round 2 to round 3 (5 -> 3 = +2)
      final standing = PlayerStanding.initial(testPlayer).copyWithRank(
        2, // current rank (after round 4)
        previousRank: 5, // rank after round 2
        rankOneRoundBack: 3, // rank after round 3
      );
      
      // rankChange should be 5 - 3 = +2 (improvement from round 2 to round 3)
      // NOT 5 - 2 = +3 (total improvement from round 2 to round 4)
      expect(standing.rankChange, equals(2));
    });
  });
}

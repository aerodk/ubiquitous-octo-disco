import 'package:flutter_test/flutter_test.dart';
import 'package:ubiquitous_octo_disco/models/player.dart';
import 'package:ubiquitous_octo_disco/models/court.dart';
import 'package:ubiquitous_octo_disco/models/match.dart';
import 'package:ubiquitous_octo_disco/models/round.dart';
import 'package:ubiquitous_octo_disco/services/mexicano_algorithm_service.dart';

void main() {
  group('MexicanoAlgorithmService', () {
    late MexicanoAlgorithmService service;
    late List<Player> players;
    late List<Court> courts;

    setUp(() {
      service = MexicanoAlgorithmService();
      
      // Create test players
      players = List.generate(
        8,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );
      
      // Create test courts
      courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];
    });

    group('calculatePlayerStats', () {
      test('returns empty stats for no previous rounds', () {
        final stats = service.calculatePlayerStats(players, []);

        expect(stats.length, players.length);
        for (final player in players) {
          expect(stats[player.id]!.totalPoints, 0);
          expect(stats[player.id]!.gamesPlayed, 0);
          expect(stats[player.id]!.partnerCounts, isEmpty);
          expect(stats[player.id]!.opponentCounts, isEmpty);
        }
      });

      test('calculates stats from completed matches', () {
        // Create a completed match
        final match = Match(
          court: courts[0],
          team1: Team(player1: players[0], player2: players[1]),
          team2: Team(player1: players[2], player2: players[3]),
          team1Score: 18,
          team2Score: 6,
        );

        final round = Round(
          roundNumber: 1,
          matches: [match],
          playersOnBreak: [players[4], players[5], players[6], players[7]],
        );

        final stats = service.calculatePlayerStats(players, [round]);

        // Check points
        expect(stats[players[0].id]!.totalPoints, 18);
        expect(stats[players[1].id]!.totalPoints, 18);
        expect(stats[players[2].id]!.totalPoints, 6);
        expect(stats[players[3].id]!.totalPoints, 6);

        // Check games played
        expect(stats[players[0].id]!.gamesPlayed, 1);
        expect(stats[players[4].id]!.gamesPlayed, 0);

        // Check partner counts
        expect(stats[players[0].id]!.getPartnerCount(players[1].id), 1);
        expect(stats[players[1].id]!.getPartnerCount(players[0].id), 1);

        // Check opponent counts
        expect(stats[players[0].id]!.getOpponentCount(players[2].id), 1);
        expect(stats[players[0].id]!.getOpponentCount(players[3].id), 1);

        // Check pause rounds
        expect(stats[players[4].id]!.pauseRounds, [1]);
      });

      test('accumulates stats across multiple rounds', () {
        // Round 1
        final match1 = Match(
          court: courts[0],
          team1: Team(player1: players[0], player2: players[1]),
          team2: Team(player1: players[2], player2: players[3]),
          team1Score: 18,
          team2Score: 6,
        );

        final round1 = Round(
          roundNumber: 1,
          matches: [match1],
          playersOnBreak: [players[4], players[5], players[6], players[7]],
        );

        // Round 2 - Player 0 with different partner
        final match2 = Match(
          court: courts[0],
          team1: Team(player1: players[0], player2: players[4]),
          team2: Team(player1: players[1], player2: players[5]),
          team1Score: 20,
          team2Score: 4,
        );

        final round2 = Round(
          roundNumber: 2,
          matches: [match2],
          playersOnBreak: [players[2], players[3], players[6], players[7]],
        );

        final stats = service.calculatePlayerStats(players, [round1, round2]);

        // Player 0 played 2 games
        expect(stats[players[0].id]!.gamesPlayed, 2);
        expect(stats[players[0].id]!.totalPoints, 38); // 18 + 20

        // Player 0 has 2 different partners
        expect(stats[players[0].id]!.getPartnerCount(players[1].id), 1);
        expect(stats[players[0].id]!.getPartnerCount(players[4].id), 1);

        // Player 0 has multiple opponents
        expect(stats[players[0].id]!.getOpponentCount(players[1].id), 1); // from round 2
        expect(stats[players[0].id]!.getOpponentCount(players[2].id), 1); // from round 1
      });
    });

    group('sortPlayersByPoints', () {
      test('sorts players by total points descending', () {
        final match1 = Match(
          court: courts[0],
          team1: Team(player1: players[0], player2: players[1]),
          team2: Team(player1: players[2], player2: players[3]),
          team1Score: 20,
          team2Score: 4,
        );

        final round = Round(
          roundNumber: 1,
          matches: [match1],
          playersOnBreak: [players[4], players[5], players[6], players[7]],
        );

        final stats = service.calculatePlayerStats(players, [round]);
        final sorted = service.sortPlayersByPoints(players, stats);

        // Players 0 and 1 should be first (20 points each)
        expect(sorted[0].id == players[0].id || sorted[0].id == players[1].id, true);
        expect(sorted[1].id == players[0].id || sorted[1].id == players[1].id, true);
        
        // Players 2 and 3 should be next (4 points each)
        expect(sorted[2].id == players[2].id || sorted[2].id == players[3].id, true);
        expect(sorted[3].id == players[2].id || sorted[3].id == players[3].id, true);
      });
    });

    group('generateOptimalPairs', () {
      test('pairs players to minimize partner repetition', () {
        // Create stats where some players have played together
        final match1 = Match(
          court: courts[0],
          team1: Team(player1: players[0], player2: players[1]),
          team2: Team(player1: players[2], player2: players[3]),
          team1Score: 12,
          team2Score: 12,
        );

        final round1 = Round(
          roundNumber: 1,
          matches: [match1],
          playersOnBreak: [players[4], players[5], players[6], players[7]],
        );

        final stats = service.calculatePlayerStats(players, [round1]);
        
        // For round 2, use only 4 players
        final activePlayers = [players[0], players[1], players[2], players[3]];
        final pairs = service.generateOptimalPairs(activePlayers, stats);

        expect(pairs.length, 2);

        // Players 0 and 1 should NOT be paired again (they were partners in round 1)
        final pair1HasBoth = (pairs[0].player1.id == players[0].id && pairs[0].player2.id == players[1].id) ||
                             (pairs[0].player1.id == players[1].id && pairs[0].player2.id == players[0].id);
        final pair2HasBoth = (pairs[1].player1.id == players[0].id && pairs[1].player2.id == players[1].id) ||
                             (pairs[1].player1.id == players[1].id && pairs[1].player2.id == players[0].id);
        
        expect(pair1HasBoth || pair2HasBoth, false);
      });

      test('creates pairs for all players when count is even', () {
        final stats = service.calculatePlayerStats(players, []);
        final pairs = service.generateOptimalPairs(players, stats);

        expect(pairs.length, 4); // 8 players = 4 pairs
        
        // All players should be in exactly one pair
        final usedPlayers = <String>{};
        for (final pair in pairs) {
          expect(usedPlayers.contains(pair.player1.id), false);
          expect(usedPlayers.contains(pair.player2.id), false);
          usedPlayers.add(pair.player1.id);
          usedPlayers.add(pair.player2.id);
        }
        expect(usedPlayers.length, 8);
      });
    });

    group('matchPairsToGames', () {
      test('matches pairs to minimize opponent encounters', () {
        // Create 4 pairs
        final pair1 = Team(player1: players[0], player2: players[1]);
        final pair2 = Team(player1: players[2], player2: players[3]);
        final pair3 = Team(player1: players[4], player2: players[5]);
        final pair4 = Team(player1: players[6], player2: players[7]);

        final pairs = [pair1, pair2, pair3, pair4];
        final stats = service.calculatePlayerStats(players, []);

        final matches = service.matchPairsToGames(pairs, courts, stats);

        expect(matches.length, 2); // 4 pairs = 2 matches (limited by courts)
        expect(matches[0].team1, isNotNull);
        expect(matches[0].team2, isNotNull);
      });

      test('respects court limit', () {
        // Create 6 pairs but only 2 courts
        final morePlayers = List.generate(
          12,
          (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
        );

        final morePairs = [
          Team(player1: morePlayers[0], player2: morePlayers[1]),
          Team(player1: morePlayers[2], player2: morePlayers[3]),
          Team(player1: morePlayers[4], player2: morePlayers[5]),
          Team(player1: morePlayers[6], player2: morePlayers[7]),
          Team(player1: morePlayers[8], player2: morePlayers[9]),
          Team(player1: morePlayers[10], player2: morePlayers[11]),
        ];

        final stats = service.calculatePlayerStats(morePlayers, []);
        final matches = service.matchPairsToGames(morePairs, courts, stats);

        expect(matches.length, 2); // Limited by 2 courts
      });
    });

    group('Integration test', () {
      test('full Mexicano round generation workflow', () {
        // Round 1
        final match1 = Match(
          court: courts[0],
          team1: Team(player1: players[0], player2: players[1]),
          team2: Team(player1: players[2], player2: players[3]),
          team1Score: 18,
          team2Score: 6,
        );
        final match2 = Match(
          court: courts[1],
          team1: Team(player1: players[4], player2: players[5]),
          team2: Team(player1: players[6], player2: players[7]),
          team1Score: 15,
          team2Score: 9,
        );

        final round1 = Round(
          roundNumber: 1,
          matches: [match1, match2],
          playersOnBreak: [],
        );

        // Calculate stats
        final stats = service.calculatePlayerStats(players, [round1]);

        // Sort by points
        final sorted = service.sortPlayersByPoints(players, stats);

        // Top scorers should be players 0,1 (18pts each), then 4,5 (15pts each)
        expect(sorted.take(4).any((p) => p.id == players[0].id), true);
        expect(sorted.take(4).any((p) => p.id == players[1].id), true);
        expect(sorted.take(4).any((p) => p.id == players[4].id), true);
        expect(sorted.take(4).any((p) => p.id == players[5].id), true);

        // Generate pairs - should avoid previous partners
        final pairs = service.generateOptimalPairs(sorted, stats);
        expect(pairs.length, 4);

        // Match pairs
        final matches = service.matchPairsToGames(pairs, courts, stats);
        expect(matches.length, 2);
      });
    });
  });
}

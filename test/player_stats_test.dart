import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/player_stats.dart';

void main() {
  group('PlayerStats', () {
    late Player testPlayer;

    setUp(() {
      testPlayer = Player(id: '1', name: 'Test Player');
    });

    test('initial creates stats with zero values', () {
      final stats = PlayerStats.initial(testPlayer);

      expect(stats.player, testPlayer);
      expect(stats.totalPoints, 0);
      expect(stats.gamesPlayed, 0);
      expect(stats.partnerCounts, isEmpty);
      expect(stats.opponentCounts, isEmpty);
      expect(stats.pauseRounds, isEmpty);
      expect(stats.averagePoints, 0.0);
    });

    test('averagePoints calculates correctly', () {
      final stats = PlayerStats(
        player: testPlayer,
        totalPoints: 60,
        gamesPlayed: 3,
        partnerCounts: {},
        opponentCounts: {},
        pauseRounds: [],
      );

      expect(stats.averagePoints, 20.0);
    });

    test('averagePoints returns 0 when no games played', () {
      final stats = PlayerStats.initial(testPlayer);
      expect(stats.averagePoints, 0.0);
    });

    test('getPartnerCount returns correct count', () {
      final stats = PlayerStats(
        player: testPlayer,
        totalPoints: 0,
        gamesPlayed: 0,
        partnerCounts: {'2': 2, '3': 1},
        opponentCounts: {},
        pauseRounds: [],
      );

      expect(stats.getPartnerCount('2'), 2);
      expect(stats.getPartnerCount('3'), 1);
      expect(stats.getPartnerCount('4'), 0);
    });

    test('getOpponentCount returns correct count', () {
      final stats = PlayerStats(
        player: testPlayer,
        totalPoints: 0,
        gamesPlayed: 0,
        partnerCounts: {},
        opponentCounts: {'2': 3, '3': 2, '4': 1},
        pauseRounds: [],
      );

      expect(stats.getOpponentCount('2'), 3);
      expect(stats.getOpponentCount('3'), 2);
      expect(stats.getOpponentCount('4'), 1);
      expect(stats.getOpponentCount('5'), 0);
    });

    test('copyWith creates new instance with updated values', () {
      final original = PlayerStats.initial(testPlayer);
      final updated = original.copyWith(
        totalPoints: 50,
        gamesPlayed: 2,
      );

      expect(updated.totalPoints, 50);
      expect(updated.gamesPlayed, 2);
      expect(updated.player, testPlayer);
      expect(updated.partnerCounts, isEmpty);
    });

    test('copyWith creates independent copies of maps and lists', () {
      final original = PlayerStats(
        player: testPlayer,
        totalPoints: 0,
        gamesPlayed: 0,
        partnerCounts: {'2': 1},
        opponentCounts: {'3': 1},
        pauseRounds: [1, 2],
      );

      final copy = original.copyWith();

      // Modify the copy
      copy.partnerCounts['4'] = 1;
      copy.opponentCounts['5'] = 1;
      copy.pauseRounds.add(3);

      // Original should be unchanged
      expect(original.partnerCounts.containsKey('4'), false);
      expect(original.opponentCounts.containsKey('5'), false);
      expect(original.pauseRounds.length, 2);
    });

    test('toString includes key information', () {
      final stats = PlayerStats(
        player: testPlayer,
        totalPoints: 48,
        gamesPlayed: 2,
        partnerCounts: {'2': 1, '3': 1},
        opponentCounts: {'4': 1, '5': 1, '6': 1, '7': 1},
        pauseRounds: [],
      );

      final str = stats.toString();
      expect(str, contains('Test Player'));
      expect(str, contains('48pts'));
      expect(str, contains('2games'));
      expect(str, contains('2 partners'));
      expect(str, contains('4 opponents'));
    });
  });
}

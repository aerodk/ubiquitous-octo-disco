import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/utils/constants.dart';

/// Unit tests for court auto-adjustment calculation logic
/// Formula: suggestedCourts = floor(playerCount / 4), minimum 1
/// Only adds courts when enough players to fill a full court (4 players)
/// Clamped to [Constants.minCourts, Constants.maxCourts]
void main() {
  group('Court auto-adjustment calculation', () {
    int calculateSuggestedCourtCount(int playerCount) {
      if (playerCount == 0) return 1;
      // Only add courts when we have enough players to fill them (floor division)
      final suggested = playerCount ~/ 4;
      // Ensure at least 1 court
      final courtCount = suggested < 1 ? 1 : suggested;
      // Clamp to valid range
      return courtCount.clamp(Constants.minCourts, Constants.maxCourts);
    }

    test('should return 1 court for 0 players', () {
      expect(calculateSuggestedCourtCount(0), 1);
    });

    test('should return 1 court for 1-7 players (less than 2 full courts)', () {
      expect(calculateSuggestedCourtCount(1), 1);
      expect(calculateSuggestedCourtCount(2), 1);
      expect(calculateSuggestedCourtCount(3), 1);
      expect(calculateSuggestedCourtCount(4), 1);
      expect(calculateSuggestedCourtCount(5), 1);
      expect(calculateSuggestedCourtCount(6), 1);
      expect(calculateSuggestedCourtCount(7), 1);
    });

    test('should return 2 courts for 8-11 players (2 full courts)', () {
      expect(calculateSuggestedCourtCount(8), 2);
      expect(calculateSuggestedCourtCount(9), 2);
      expect(calculateSuggestedCourtCount(10), 2);
      expect(calculateSuggestedCourtCount(11), 2);
    });

    test('should return 3 courts for 12-15 players (3 full courts)', () {
      expect(calculateSuggestedCourtCount(12), 3);
      expect(calculateSuggestedCourtCount(13), 3);
      expect(calculateSuggestedCourtCount(14), 3);
      expect(calculateSuggestedCourtCount(15), 3);
    });

    test('should return 4 courts for 16-19 players (4 full courts)', () {
      expect(calculateSuggestedCourtCount(16), 4);
      expect(calculateSuggestedCourtCount(17), 4);
      expect(calculateSuggestedCourtCount(18), 4);
      expect(calculateSuggestedCourtCount(19), 4);
    });

    test('should return 5 courts for 20-23 players (5 full courts)', () {
      expect(calculateSuggestedCourtCount(20), 5);
      expect(calculateSuggestedCourtCount(21), 5);
      expect(calculateSuggestedCourtCount(22), 5);
      expect(calculateSuggestedCourtCount(23), 5);
    });

    test('should return 6 courts for 24-27 players (6 full courts)', () {
      expect(calculateSuggestedCourtCount(24), 6);
      expect(calculateSuggestedCourtCount(25), 6);
      expect(calculateSuggestedCourtCount(26), 6);
      expect(calculateSuggestedCourtCount(27), 6);
    });

    test('should not exceed maxCourts (8)', () {
      // Even if we had more players (hypothetically), shouldn't exceed max
      expect(calculateSuggestedCourtCount(32), Constants.maxCourts);
      expect(calculateSuggestedCourtCount(40), Constants.maxCourts);
      expect(calculateSuggestedCourtCount(100), Constants.maxCourts);
    });

    test('should always return at least minCourts (1)', () {
      expect(calculateSuggestedCourtCount(0), Constants.minCourts);
      expect(calculateSuggestedCourtCount(-1), Constants.minCourts);
    });

    test('should correctly handle edge cases', () {
      // Boundary between 1 and 2 courts - now at 8 players
      expect(calculateSuggestedCourtCount(7), 1);
      expect(calculateSuggestedCourtCount(8), 2);
      
      // Boundary between 2 and 3 courts - now at 12 players
      expect(calculateSuggestedCourtCount(11), 2);
      expect(calculateSuggestedCourtCount(12), 3);
      
      // Boundary between 6 and 7 courts - at 28 players
      expect(calculateSuggestedCourtCount(27), 6);
      expect(calculateSuggestedCourtCount(28), 7);
      
      // Boundary between 7 and 8 courts - at 32 players
      expect(calculateSuggestedCourtCount(31), 7);
      expect(calculateSuggestedCourtCount(32), 8);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/utils/constants.dart';

/// Unit tests for court auto-adjustment calculation logic
/// Formula: suggestedCourts = ceil(playerCount / 4)
/// Clamped to [Constants.minCourts, Constants.maxCourts]
void main() {
  group('Court auto-adjustment calculation', () {
    int calculateSuggestedCourtCount(int playerCount) {
      if (playerCount == 0) return 1;
      // Round up: (playerCount + 3) / 4
      final suggested = ((playerCount + 3) ~/ 4);
      // Clamp to valid range
      return suggested.clamp(Constants.minCourts, Constants.maxCourts);
    }

    test('should return 1 court for 0 players', () {
      expect(calculateSuggestedCourtCount(0), 1);
    });

    test('should return 1 court for 1-4 players', () {
      expect(calculateSuggestedCourtCount(1), 1);
      expect(calculateSuggestedCourtCount(2), 1);
      expect(calculateSuggestedCourtCount(3), 1);
      expect(calculateSuggestedCourtCount(4), 1);
    });

    test('should return 2 courts for 5-8 players', () {
      expect(calculateSuggestedCourtCount(5), 2);
      expect(calculateSuggestedCourtCount(6), 2);
      expect(calculateSuggestedCourtCount(7), 2);
      expect(calculateSuggestedCourtCount(8), 2);
    });

    test('should return 3 courts for 9-12 players', () {
      expect(calculateSuggestedCourtCount(9), 3);
      expect(calculateSuggestedCourtCount(10), 3);
      expect(calculateSuggestedCourtCount(11), 3);
      expect(calculateSuggestedCourtCount(12), 3);
    });

    test('should return 4 courts for 13-16 players', () {
      expect(calculateSuggestedCourtCount(13), 4);
      expect(calculateSuggestedCourtCount(14), 4);
      expect(calculateSuggestedCourtCount(15), 4);
      expect(calculateSuggestedCourtCount(16), 4);
    });

    test('should return 5 courts for 17-20 players', () {
      expect(calculateSuggestedCourtCount(17), 5);
      expect(calculateSuggestedCourtCount(18), 5);
      expect(calculateSuggestedCourtCount(19), 5);
      expect(calculateSuggestedCourtCount(20), 5);
    });

    test('should return 6 courts for 21-24 players', () {
      expect(calculateSuggestedCourtCount(21), 6);
      expect(calculateSuggestedCourtCount(22), 6);
      expect(calculateSuggestedCourtCount(23), 6);
      expect(calculateSuggestedCourtCount(24), 6);
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
      // Boundary between 1 and 2 courts
      expect(calculateSuggestedCourtCount(4), 1);
      expect(calculateSuggestedCourtCount(5), 2);
      
      // Boundary between 2 and 3 courts
      expect(calculateSuggestedCourtCount(8), 2);
      expect(calculateSuggestedCourtCount(9), 3);
      
      // Boundary between 6 and 7 courts
      expect(calculateSuggestedCourtCount(24), 6);
      expect(calculateSuggestedCourtCount(25), 7);
      
      // Boundary between 7 and 8 courts
      expect(calculateSuggestedCourtCount(28), 7);
      expect(calculateSuggestedCourtCount(29), 8);
    });
  });
}

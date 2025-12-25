import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/tournament_settings.dart';

void main() {
  group('TournamentFormat', () {
    test('enum values are correctly defined', () {
      expect(TournamentFormat.values.length, 2);
      expect(TournamentFormat.values.contains(TournamentFormat.americano), true);
      expect(TournamentFormat.values.contains(TournamentFormat.mexicano), true);
    });
  });

  group('PairingStrategy', () {
    test('enum values are correctly defined', () {
      expect(PairingStrategy.values.length, 3);
      expect(PairingStrategy.values.contains(PairingStrategy.balanced), true);
      expect(PairingStrategy.values.contains(PairingStrategy.topAlliance), true);
      expect(PairingStrategy.values.contains(PairingStrategy.maxCompetition), true);
    });
  });

  group('LaneAssignmentStrategy', () {
    test('enum values are correctly defined', () {
      expect(LaneAssignmentStrategy.values.length, 2);
      expect(LaneAssignmentStrategy.values.contains(LaneAssignmentStrategy.sequential), true);
      expect(LaneAssignmentStrategy.values.contains(LaneAssignmentStrategy.random), true);
    });
  });

  group('TournamentSettings', () {
    test('default constructor creates settings with default values', () {
      const settings = TournamentSettings();
      
      expect(settings.format, TournamentFormat.mexicano);
      expect(settings.minRoundsBeforeFinal, 3);
      expect(settings.pointsPerMatch, 24);
      expect(settings.finalRoundStrategy, PairingStrategy.balanced);
      expect(settings.pausePointsAwarded, 12);
      expect(settings.laneAssignmentStrategy, LaneAssignmentStrategy.sequential);
    });

    test('constructor accepts custom values', () {
      const settings = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 0,
        laneAssignmentStrategy: LaneAssignmentStrategy.random,
      );
      
      expect(settings.format, TournamentFormat.americano);
      expect(settings.minRoundsBeforeFinal, 5);
      expect(settings.pointsPerMatch, 30);
      expect(settings.finalRoundStrategy, PairingStrategy.topAlliance);
      expect(settings.pausePointsAwarded, 0);
      expect(settings.laneAssignmentStrategy, LaneAssignmentStrategy.random);
    });

    test('copyWith creates new instance with updated values', () {
      const original = TournamentSettings(
        format: TournamentFormat.mexicano,
        minRoundsBeforeFinal: 3,
        pointsPerMatch: 24,
        finalRoundStrategy: PairingStrategy.balanced,
        laneAssignmentStrategy: LaneAssignmentStrategy.sequential,
      );
      
      final updated = original.copyWith(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 20,
        laneAssignmentStrategy: LaneAssignmentStrategy.random,
      );
      
      expect(updated.format, TournamentFormat.americano);
      expect(updated.minRoundsBeforeFinal, 5);
      expect(updated.pointsPerMatch, 20);
      expect(updated.finalRoundStrategy, PairingStrategy.balanced); // unchanged
      expect(updated.laneAssignmentStrategy, LaneAssignmentStrategy.random);
    });

    test('isCustomized returns false for default settings', () {
      const settings = TournamentSettings();
      expect(settings.isCustomized, false);
    });

    test('isCustomized returns true when any setting differs from default', () {
      const settings1 = TournamentSettings(pointsPerMatch: 30);
      expect(settings1.isCustomized, true);
      
      const settings2 = TournamentSettings(finalRoundStrategy: PairingStrategy.topAlliance);
      expect(settings2.isCustomized, true);
      
      const settings3 = TournamentSettings(pausePointsAwarded: 0);
      expect(settings3.isCustomized, true);

      const settings4 = TournamentSettings(laneAssignmentStrategy: LaneAssignmentStrategy.random);
      expect(settings4.isCustomized, true);
      
      const settings5 = TournamentSettings(format: TournamentFormat.americano);
      expect(settings5.isCustomized, true);
    });

    test('summary returns correctly formatted string', () {
      const settings1 = TournamentSettings();
      expect(settings1.summary, 'Mexicano • 24 point • Balanced • Pause: 12 pt • Sekventiel');
      
      const settings2 = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 0,
        laneAssignmentStrategy: LaneAssignmentStrategy.random,
      );
      expect(settings2.summary, 'Americano • 30 point • Top Alliance • Pause: 0 pt • Tilfældig');
      
      const settings3 = TournamentSettings(
        finalRoundStrategy: PairingStrategy.maxCompetition,
      );
      expect(settings3.summary, 'Mexicano • 24 point • Max Competition • Pause: 12 pt • Sekventiel');
    });

    test('isValid returns true for valid settings', () {
      const settings1 = TournamentSettings();
      expect(settings1.isValid(), true);
      
      const settings2 = TournamentSettings(
        minRoundsBeforeFinal: 2,
        pointsPerMatch: 18,
      );
      expect(settings2.isValid(), true);
      
      const settings3 = TournamentSettings(
        minRoundsBeforeFinal: 10,
        pointsPerMatch: 32,
      );
      expect(settings3.isValid(), true);
    });

    test('isValid returns false for invalid minRoundsBeforeFinal', () {
      const settings1 = TournamentSettings(minRoundsBeforeFinal: 1);
      expect(settings1.isValid(), false);
      
      const settings2 = TournamentSettings(minRoundsBeforeFinal: 11);
      expect(settings2.isValid(), false);
    });

    test('isValid returns false for invalid pointsPerMatch', () {
      // Below minimum
      const settings1 = TournamentSettings(pointsPerMatch: 16);
      expect(settings1.isValid(), false);
      
      // Above maximum
      const settings2 = TournamentSettings(pointsPerMatch: 34);
      expect(settings2.isValid(), false);
      
      // Odd number (must be even)
      const settings3 = TournamentSettings(pointsPerMatch: 23);
      expect(settings3.isValid(), false);
    });

    test('isValid returns false for invalid pausePointsAwarded', () {
      // Only 0 or 12 are valid
      const settings1 = TournamentSettings(pausePointsAwarded: 6);
      expect(settings1.isValid(), false);
      
      const settings2 = TournamentSettings(pausePointsAwarded: 24);
      expect(settings2.isValid(), false);
      
      const settings3 = TournamentSettings(pausePointsAwarded: -1);
      expect(settings3.isValid(), false);
    });

    test('isValid returns true for valid pausePointsAwarded', () {
      const settings1 = TournamentSettings(pausePointsAwarded: 0);
      expect(settings1.isValid(), true);
      
      const settings2 = TournamentSettings(pausePointsAwarded: 12);
      expect(settings2.isValid(), true);
    });

    test('toJson serializes correctly', () {
      const settings = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.maxCompetition,
        pausePointsAwarded: 0,
        laneAssignmentStrategy: LaneAssignmentStrategy.random,
      );
      
      final json = settings.toJson();
      
      expect(json['format'], 'americano');
      expect(json['minRoundsBeforeFinal'], 5);
      expect(json['pointsPerMatch'], 30);
      expect(json['finalRoundStrategy'], 'maxCompetition');
      expect(json['pausePointsAwarded'], 0);
      expect(json['laneAssignmentStrategy'], 'random');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'format': 'americano',
        'minRoundsBeforeFinal': 5,
        'pointsPerMatch': 30,
        'finalRoundStrategy': 'topAlliance',
        'pausePointsAwarded': 0,
        'laneAssignmentStrategy': 'random',
      };
      
      final settings = TournamentSettings.fromJson(json);
      
      expect(settings.format, TournamentFormat.americano);
      expect(settings.minRoundsBeforeFinal, 5);
      expect(settings.pointsPerMatch, 30);
      expect(settings.finalRoundStrategy, PairingStrategy.topAlliance);
      expect(settings.pausePointsAwarded, 0);
      expect(settings.laneAssignmentStrategy, LaneAssignmentStrategy.random);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};
      
      final settings = TournamentSettings.fromJson(json);
      
      expect(settings.format, TournamentFormat.mexicano);
      expect(settings.minRoundsBeforeFinal, 3);
      expect(settings.pointsPerMatch, 24);
      expect(settings.finalRoundStrategy, PairingStrategy.balanced);
      expect(settings.pausePointsAwarded, 12);
      expect(settings.laneAssignmentStrategy, LaneAssignmentStrategy.sequential);
    });

    test('fromJson handles invalid strategy gracefully', () {
      final json = {
        'format': 'invalidFormat',
        'finalRoundStrategy': 'invalidStrategy',
        'laneAssignmentStrategy': 'invalidLaneStrategy',
      };
      
      final settings = TournamentSettings.fromJson(json);
      
      // Should default to mexicano for invalid format
      expect(settings.format, TournamentFormat.mexicano);
      // Should default to balanced for invalid strategy
      expect(settings.finalRoundStrategy, PairingStrategy.balanced);
      // Should default to sequential for invalid lane strategy
      expect(settings.laneAssignmentStrategy, LaneAssignmentStrategy.sequential);
    });

    test('equality works correctly', () {
      const settings1 = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 0,
      );
      
      const settings2 = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 0,
      );
      
      const settings3 = TournamentSettings(
        format: TournamentFormat.mexicano, // Different
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 0,
      );
      
      const settings4 = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 24, // Different
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 0,
      );
      
      const settings5 = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
        pausePointsAwarded: 12, // Different
      );
      
      expect(settings1, settings2);
      expect(settings1 == settings3, false);
      expect(settings1 == settings4, false);
      expect(settings1 == settings5, false);
    });

    test('hashCode is consistent', () {
      const settings1 = TournamentSettings(
        format: TournamentFormat.mexicano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      const settings2 = TournamentSettings(
        format: TournamentFormat.mexicano,
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      expect(settings1.hashCode, settings2.hashCode);
    });

    test('JSON round-trip preserves data', () {
      const original = TournamentSettings(
        format: TournamentFormat.americano,
        minRoundsBeforeFinal: 7,
        pointsPerMatch: 28,
        finalRoundStrategy: PairingStrategy.maxCompetition,
        pausePointsAwarded: 0,
      );
      
      final json = original.toJson();
      final restored = TournamentSettings.fromJson(json);
      
      expect(restored, original);
    });
  });
}

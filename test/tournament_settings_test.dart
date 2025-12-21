import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/tournament_settings.dart';

void main() {
  group('PairingStrategy', () {
    test('enum values are correctly defined', () {
      expect(PairingStrategy.values.length, 3);
      expect(PairingStrategy.values.contains(PairingStrategy.balanced), true);
      expect(PairingStrategy.values.contains(PairingStrategy.topAlliance), true);
      expect(PairingStrategy.values.contains(PairingStrategy.maxCompetition), true);
    });
  });

  group('TournamentSettings', () {
    test('default constructor creates settings with default values', () {
      const settings = TournamentSettings();
      
      expect(settings.minRoundsBeforeFinal, 3);
      expect(settings.pointsPerMatch, 24);
      expect(settings.finalRoundStrategy, PairingStrategy.balanced);
    });

    test('constructor accepts custom values', () {
      const settings = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      expect(settings.minRoundsBeforeFinal, 5);
      expect(settings.pointsPerMatch, 30);
      expect(settings.finalRoundStrategy, PairingStrategy.topAlliance);
    });

    test('copyWith creates new instance with updated values', () {
      const original = TournamentSettings(
        minRoundsBeforeFinal: 3,
        pointsPerMatch: 24,
        finalRoundStrategy: PairingStrategy.balanced,
      );
      
      final updated = original.copyWith(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 20,
      );
      
      expect(updated.minRoundsBeforeFinal, 5);
      expect(updated.pointsPerMatch, 20);
      expect(updated.finalRoundStrategy, PairingStrategy.balanced); // unchanged
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
    });

    test('summary returns correctly formatted string', () {
      const settings1 = TournamentSettings();
      expect(settings1.summary, '24 point • Balanced');
      
      const settings2 = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      expect(settings2.summary, '30 point • Top Alliance');
      
      const settings3 = TournamentSettings(
        finalRoundStrategy: PairingStrategy.maxCompetition,
      );
      expect(settings3.summary, '24 point • Max Competition');
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

    test('toJson serializes correctly', () {
      const settings = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.maxCompetition,
      );
      
      final json = settings.toJson();
      
      expect(json['minRoundsBeforeFinal'], 5);
      expect(json['pointsPerMatch'], 30);
      expect(json['finalRoundStrategy'], 'maxCompetition');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'minRoundsBeforeFinal': 5,
        'pointsPerMatch': 30,
        'finalRoundStrategy': 'topAlliance',
      };
      
      final settings = TournamentSettings.fromJson(json);
      
      expect(settings.minRoundsBeforeFinal, 5);
      expect(settings.pointsPerMatch, 30);
      expect(settings.finalRoundStrategy, PairingStrategy.topAlliance);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};
      
      final settings = TournamentSettings.fromJson(json);
      
      expect(settings.minRoundsBeforeFinal, 3);
      expect(settings.pointsPerMatch, 24);
      expect(settings.finalRoundStrategy, PairingStrategy.balanced);
    });

    test('fromJson handles invalid strategy gracefully', () {
      final json = {
        'finalRoundStrategy': 'invalidStrategy',
      };
      
      final settings = TournamentSettings.fromJson(json);
      
      // Should default to balanced for invalid strategy
      expect(settings.finalRoundStrategy, PairingStrategy.balanced);
    });

    test('equality works correctly', () {
      const settings1 = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      const settings2 = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      const settings3 = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 24, // Different
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      expect(settings1, settings2);
      expect(settings1 == settings3, false);
    });

    test('hashCode is consistent', () {
      const settings1 = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      const settings2 = TournamentSettings(
        minRoundsBeforeFinal: 5,
        pointsPerMatch: 30,
        finalRoundStrategy: PairingStrategy.topAlliance,
      );
      
      expect(settings1.hashCode, settings2.hashCode);
    });

    test('JSON round-trip preserves data', () {
      const original = TournamentSettings(
        minRoundsBeforeFinal: 7,
        pointsPerMatch: 28,
        finalRoundStrategy: PairingStrategy.maxCompetition,
      );
      
      final json = original.toJson();
      final restored = TournamentSettings.fromJson(json);
      
      expect(restored, original);
    });
  });
}

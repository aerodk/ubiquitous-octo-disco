import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistenceService', () {
    late PersistenceService persistenceService;

    setUp(() {
      persistenceService = PersistenceService();
      // Clear any existing preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load setup state (players and courts)', () async {
      final players = [
        Player(id: '1', name: 'Alice'),
        Player(id: '2', name: 'Bob'),
        Player(id: '3', name: 'Charlie'),
      ];
      const courtCount = 2;

      // Save setup state
      await persistenceService.saveSetupState(players, courtCount);

      // Load setup state
      final loaded = await persistenceService.loadSetupState();

      expect(loaded, isNotNull);
      expect(loaded!.players.length, equals(3));
      expect(loaded.players[0].name, equals('Alice'));
      expect(loaded.players[1].name, equals('Bob'));
      expect(loaded.players[2].name, equals('Charlie'));
      expect(loaded.courtCount, equals(2));
      expect(loaded.courtCustomNames, isEmpty);
    });

    test('should save and load setup state with custom court names', () async {
      final players = [
        Player(id: '1', name: 'Alice'),
        Player(id: '2', name: 'Bob'),
      ];
      const courtCount = 2;
      final courtCustomNames = {
        0: 'Center Court',
        1: 'Side Court',
      };

      // Save setup state with custom names
      await persistenceService.saveSetupState(players, courtCount, courtCustomNames);

      // Load setup state
      final loaded = await persistenceService.loadSetupState();

      expect(loaded, isNotNull);
      expect(loaded!.players.length, equals(2));
      expect(loaded.courtCount, equals(2));
      expect(loaded.courtCustomNames.length, equals(2));
      expect(loaded.courtCustomNames[0], equals('Center Court'));
      expect(loaded.courtCustomNames[1], equals('Side Court'));
    });

    test('should return null when no setup state is saved', () async {
      final loaded = await persistenceService.loadSetupState();
      expect(loaded, isNull);
    });

    test('should clear setup state', () async {
      final players = [Player(id: '1', name: 'Alice')];
      await persistenceService.saveSetupState(players, 1);

      // Verify it was saved
      var loaded = await persistenceService.loadSetupState();
      expect(loaded, isNotNull);

      // Clear and verify it's gone
      await persistenceService.clearSetupState();
      loaded = await persistenceService.loadSetupState();
      expect(loaded, isNull);
    });

    test('should save and load tournament', () async {
      final players = [
        Player(id: '1', name: 'Alice'),
        Player(id: '2', name: 'Bob'),
      ];
      final courts = [
        Court(id: '1', name: 'Court 1'),
      ];
      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
      );

      // Save tournament
      await persistenceService.saveTournament(tournament);

      // Load tournament
      final loaded = await persistenceService.loadTournament();

      expect(loaded, isNotNull);
      expect(loaded!.name, equals('Test Tournament'));
      expect(loaded.players.length, equals(2));
      expect(loaded.courts.length, equals(1));
      expect(loaded.players[0].name, equals('Alice'));
    });

    test('should return null when no tournament is saved', () async {
      final loaded = await persistenceService.loadTournament();
      expect(loaded, isNull);
    });

    test('should clear tournament', () async {
      final tournament = Tournament(
        name: 'Test Tournament',
        players: [Player(id: '1', name: 'Alice')],
        courts: [Court(id: '1', name: 'Court 1')],
      );

      await persistenceService.saveTournament(tournament);

      // Verify it was saved
      var loaded = await persistenceService.loadTournament();
      expect(loaded, isNotNull);

      // Clear and verify it's gone
      await persistenceService.clearTournament();
      loaded = await persistenceService.loadTournament();
      expect(loaded, isNull);
    });

    test('should handle corrupted setup state gracefully', () async {
      // Manually set invalid JSON
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('setup_players', 'invalid json');

      // Should return null and clear corrupted data
      final loaded = await persistenceService.loadSetupState();
      expect(loaded, isNull);

      // Verify it was cleared
      final value = prefs.getString('setup_players');
      expect(value, isNull);
    });

    test('should handle corrupted tournament data gracefully', () async {
      // Manually set invalid JSON
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_tournament', 'invalid json');

      // Should return null and clear corrupted data
      final loaded = await persistenceService.loadTournament();
      expect(loaded, isNull);

      // Verify it was cleared
      final value = prefs.getString('current_tournament');
      expect(value, isNull);
    });

    test('should handle empty string tournament data gracefully', () async {
      // Manually set empty string
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_tournament', '');

      // Should return null
      final loaded = await persistenceService.loadTournament();
      expect(loaded, isNull);
    });

    test('should handle empty string setup data gracefully', () async {
      // Manually set empty string
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('setup_players', '');

      // Should return null
      final loaded = await persistenceService.loadSetupState();
      expect(loaded, isNull);
    });
  });
}

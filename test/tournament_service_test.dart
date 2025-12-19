import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
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
}

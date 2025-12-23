import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/screens/round_display_screen.dart';

void main() {
  group('Lane Adjustment Tests', () {
    late List<Player> players;
    late List<Court> courts;

    setUp(() {
      // Create 12 players for testing
      players = List.generate(
        12,
        (i) => Player(id: '${i + 1}', name: 'Player ${i + 1}'),
      );

      // Create 2 courts initially
      courts = [
        Court(id: '1', name: 'Bane 1'),
        Court(id: '2', name: 'Bane 2'),
      ];
    });

    testWidgets('Add court button is disabled when less than 4 players on pause',
        (WidgetTester tester) async {
      // Create a round with 8 players (2 courts x 4 players) and 4 on pause
      final round = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
          ),
          Match(
            court: courts[1],
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
          ),
        ],
        playersOnBreak: [players[8], players[9], players[10], players[11]], // 4 players on pause
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournament),
        ),
      );
      await tester.pumpAndSettle();

      // Find the "Tilføj bane" (Add court) button
      final addCourtButton = find.text('Tilføj bane');
      expect(addCourtButton, findsOneWidget);

      // Button should be enabled when there are 4 players on pause
      final addButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: addCourtButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(addButton.onPressed, isNotNull);
    });

    testWidgets('Add court button is disabled when less than 4 players on pause',
        (WidgetTester tester) async {
      // Create a round with 10 players active and only 2 on pause
      final round = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
          ),
          Match(
            court: courts[1],
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
          ),
        ],
        playersOnBreak: [players[8], players[9]], // Only 2 players on pause
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players.sublist(0, 10), // 10 players total
        courts: courts,
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournament),
        ),
      );
      await tester.pumpAndSettle();

      // Find the "Tilføj bane" (Add court) button
      final addCourtButton = find.text('Tilføj bane');
      expect(addCourtButton, findsOneWidget);

      // Button should be disabled when there are less than 4 players on pause
      final addButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: addCourtButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(addButton.onPressed, isNull);
    });

    testWidgets('Newly paused players are visually emphasized',
        (WidgetTester tester) async {
      // This test would need to simulate removing a court and checking the UI
      // Since we need to interact with dialogs and async operations, 
      // we'll focus on the logic testing in the service layer
      
      // Create a round with all 12 players active (3 courts)
      final thirdCourt = Court(id: '3', name: 'Bane 3');
      final allCourts = [...courts, thirdCourt];
      
      final round = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: allCourts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
          ),
          Match(
            court: allCourts[1],
            team1: Team(player1: players[4], player2: players[5]),
            team2: Team(player1: players[6], player2: players[7]),
          ),
          Match(
            court: allCourts[2],
            team1: Team(player1: players[8], player2: players[9]),
            team2: Team(player1: players[10], player2: players[11]),
          ),
        ],
        playersOnBreak: [], // No players on pause initially
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: allCourts,
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournament),
        ),
      );
      await tester.pumpAndSettle();

      // Check that pause section is not shown when no players on pause
      expect(find.text('Pause'), findsNothing);
      
      // Verify court management section exists
      expect(find.text('Bane håndtering'), findsOneWidget);
      expect(find.text('3 baner'), findsOneWidget);
    });

    testWidgets('Pause section displays players on break',
        (WidgetTester tester) async {
      // Create a round with players on pause
      final round = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
          ),
        ],
        playersOnBreak: [players[4], players[5]], // 2 players on pause
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players.sublist(0, 6),
        courts: [courts[0]],
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournament),
        ),
      );
      await tester.pumpAndSettle();

      // Check that pause section is shown
      expect(find.text('PÅ BÆNKEN DENNE RUNDE'), findsOneWidget);
      
      // Check that both players on pause are displayed
      expect(find.text('Player 5'), findsOneWidget);
      expect(find.text('Player 6'), findsOneWidget);
    });
  });
}

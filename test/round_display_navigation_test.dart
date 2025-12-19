import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/screens/round_display_screen.dart';

void main() {
  group('RoundDisplayScreen Navigation Tests', () {
    late List<Player> players;
    late List<Court> courts;
    late Tournament tournamentWithOneRound;
    late Tournament tournamentWithTwoRounds;

    setUp(() {
      players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
      ];

      courts = [
        Court(id: '1', name: 'Bane 1'),
      ];

      // Tournament with one round
      final round1 = Round(
        roundNumber: 1,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[1]),
            team2: Team(player1: players[2], player2: players[3]),
          ),
        ],
        playersOnBreak: [],
      );

      tournamentWithOneRound = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round1],
      );

      // Tournament with two rounds
      final round2 = Round(
        roundNumber: 2,
        matches: [
          Match(
            court: courts[0],
            team1: Team(player1: players[0], player2: players[2]),
            team2: Team(player1: players[1], player2: players[3]),
          ),
        ],
        playersOnBreak: [],
      );

      tournamentWithTwoRounds = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [round1, round2],
      );
    });

    testWidgets('should display round number correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithOneRound),
        ),
      );

      expect(find.text('Runde 1'), findsOneWidget);
    });

    testWidgets('should display next round button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithOneRound),
        ),
      );

      expect(find.text('Generer Næste Runde (2)'), findsOneWidget);
    });

    testWidgets('should show second round when tournament has two rounds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithTwoRounds),
        ),
      );

      expect(find.text('Runde 2'), findsOneWidget);
    });

    testWidgets('should allow back navigation when no scores entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithTwoRounds),
        ),
      );

      // Should have a back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Back button should be enabled (not null onPressed)
      final IconButton backButton = tester.widget(find.byIcon(Icons.arrow_back).first);
      expect(backButton.onPressed, isNotNull);
    });

    testWidgets('should disable back navigation when scores entered', (WidgetTester tester) async {
      // Add scores to the current round
      tournamentWithTwoRounds.rounds.last.matches.first.team1Score = 15;
      tournamentWithTwoRounds.rounds.last.matches.first.team2Score = 9;

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithTwoRounds),
        ),
      );

      // Should have a back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Back button should be disabled (null onPressed)
      final IconButton backButton = tester.widget(find.byIcon(Icons.arrow_back).first);
      expect(backButton.onPressed, isNull);
    });

    testWidgets('should not show back button on first round', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithOneRound),
        ),
      );

      // Should not have a custom back button in AppBar leading
      final AppBar appBar = tester.widget(find.byType(AppBar));
      expect(appBar.leading, isNull);
    });

    testWidgets('back button should be enabled when on second round with no scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithTwoRounds),
        ),
      );

      // Should have a back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Back button should be enabled (not null onPressed)
      final IconButton backButton = tester.widget(find.byIcon(Icons.arrow_back).first);
      expect(backButton.onPressed, isNotNull);
    });

    testWidgets('back button should be disabled when on second round with scores', (WidgetTester tester) async {
      // Add scores to the current round
      tournamentWithTwoRounds.rounds.last.matches.first.team1Score = 15;
      tournamentWithTwoRounds.rounds.last.matches.first.team2Score = 9;

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithTwoRounds),
        ),
      );

      // Should have a back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Back button should be disabled (null onPressed)
      final IconButton backButton = tester.widget(find.byIcon(Icons.arrow_back).first);
      expect(backButton.onPressed, isNull);
    });

    testWidgets('back button should be disabled when any match has partial scores', (WidgetTester tester) async {
      // Create a fresh tournament to avoid test pollution
      final freshTournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [
          Round(
            roundNumber: 1,
            matches: [
              Match(
                court: courts[0],
                team1: Team(player1: players[0], player2: players[1]),
                team2: Team(player1: players[2], player2: players[3]),
              ),
            ],
            playersOnBreak: [],
          ),
          Round(
            roundNumber: 2,
            matches: [
              Match(
                court: courts[0],
                team1: Team(player1: players[0], player2: players[2]),
                team2: Team(player1: players[1], player2: players[3]),
              ),
            ],
            playersOnBreak: [],
          ),
        ],
      );

      // Add score to only one team in one match
      freshTournament.rounds.last.matches.first.team1Score = 15;

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: freshTournament),
        ),
      );

      // Should have a back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Back button should be disabled (null onPressed) even with partial score
      final IconButton backButton = tester.widget(find.byIcon(Icons.arrow_back).first);
      expect(backButton.onPressed, isNull);
    });
  });
}

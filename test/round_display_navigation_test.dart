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
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
      
      // Back button should be enabled (not null onPressed)
      final IconButton backButton = tester.widget(
        find.widgetWithIcon(IconButton, Icons.arrow_back).first,
      );
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
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
      
      // Back button should be disabled (null onPressed)
      final IconButton backButton = tester.widget(
        find.widgetWithIcon(IconButton, Icons.arrow_back).first,
      );
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
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
      
      // Back button should be enabled (not null onPressed)
      final IconButton backButton = tester.widget(
        find.widgetWithIcon(IconButton, Icons.arrow_back).first,
      );
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
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
      
      // Back button should be disabled (null onPressed)
      final IconButton backButton = tester.widget(
        find.widgetWithIcon(IconButton, Icons.arrow_back).first,
      );
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
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
      
      // Back button should be disabled (null onPressed) even with partial score
      final IconButton backButton = tester.widget(
        find.widgetWithIcon(IconButton, Icons.arrow_back).first,
      );
      expect(backButton.onPressed, isNull);
    });

    testWidgets('should show warning when trying to generate next round without all scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithOneRound),
        ),
      );

      // Tap the next round button
      await tester.tap(find.text('Generer Næste Runde (2)'));
      await tester.pump();

      // Should show a snackbar warning
      expect(find.text('Alle kampe skal have score før næste runde kan startes'), findsOneWidget);
    });

    testWidgets('should show both next round and final round buttons after 3 completed rounds', (WidgetTester tester) async {
      // Create tournament with 3 completed rounds
      final completedMatch1 = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[1]),
        team2: Team(player1: players[2], player2: players[3]),
        team1Score: 15,
        team2Score: 9,
      );
      final completedMatch2 = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[2]),
        team2: Team(player1: players[1], player2: players[3]),
        team1Score: 12,
        team2Score: 12,
      );
      final completedMatch3 = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[3]),
        team2: Team(player1: players[1], player2: players[2]),
        team1Score: 18,
        team2Score: 6,
      );

      final tournamentWith3CompletedRounds = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [
          Round(roundNumber: 1, matches: [completedMatch1], playersOnBreak: []),
          Round(roundNumber: 2, matches: [completedMatch2], playersOnBreak: []),
          Round(roundNumber: 3, matches: [completedMatch3], playersOnBreak: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWith3CompletedRounds),
        ),
      );

      // Both buttons should be visible
      expect(find.text('Start Sidste Runde'), findsOneWidget);
      expect(find.text('Generer Næste Runde (4)'), findsOneWidget);
    });

    testWidgets('should only show next round button before 3 rounds are completed', (WidgetTester tester) async {
      // Create tournament with 2 completed rounds
      final completedMatch1 = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[1]),
        team2: Team(player1: players[2], player2: players[3]),
        team1Score: 15,
        team2Score: 9,
      );
      final completedMatch2 = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[2]),
        team2: Team(player1: players[1], player2: players[3]),
        team1Score: 12,
        team2Score: 12,
      );

      final tournamentWith2CompletedRounds = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [
          Round(roundNumber: 1, matches: [completedMatch1], playersOnBreak: []),
          Round(roundNumber: 2, matches: [completedMatch2], playersOnBreak: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWith2CompletedRounds),
        ),
      );

      // Only next round button should be visible
      expect(find.text('Generer Næste Runde (3)'), findsOneWidget);
      expect(find.text('Start Sidste Runde'), findsNothing);
    });

    testWidgets('should show "Vis Resultat" button when final round is completed', (WidgetTester tester) async {
      // Create tournament with completed final round
      final completedFinalMatch = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[1]),
        team2: Team(player1: players[2], player2: players[3]),
        team1Score: 15,
        team2Score: 9,
      );

      final finalRound = Round(
        roundNumber: 4,
        matches: [completedFinalMatch],
        playersOnBreak: [],
        isFinalRound: true,
      );

      final tournamentWithCompletedFinalRound = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [
          Round(roundNumber: 1, matches: [completedFinalMatch], playersOnBreak: []),
          Round(roundNumber: 2, matches: [completedFinalMatch], playersOnBreak: []),
          Round(roundNumber: 3, matches: [completedFinalMatch], playersOnBreak: []),
          finalRound,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithCompletedFinalRound),
        ),
      );

      // Should show "Vis Resultat" button
      expect(find.text('Vis Resultat'), findsOneWidget);
      // Should NOT show "Generer Næste Runde" button (in final round)
      expect(find.textContaining('Generer Næste Runde'), findsNothing);
    });

    testWidgets('should not show "Vis Resultat" button when final round is not completed', (WidgetTester tester) async {
      // Create tournament with incomplete final round
      final incompleteFinalMatch = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[1]),
        team2: Team(player1: players[2], player2: players[3]),
      );

      final finalRound = Round(
        roundNumber: 4,
        matches: [incompleteFinalMatch],
        playersOnBreak: [],
        isFinalRound: true,
      );

      final completedMatch = Match(
        court: courts[0],
        team1: Team(player1: players[0], player2: players[1]),
        team2: Team(player1: players[2], player2: players[3]),
        team1Score: 15,
        team2Score: 9,
      );

      final tournamentWithIncompleteFinalRound = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: courts,
        rounds: [
          Round(roundNumber: 1, matches: [completedMatch], playersOnBreak: []),
          Round(roundNumber: 2, matches: [completedMatch], playersOnBreak: []),
          Round(roundNumber: 3, matches: [completedMatch], playersOnBreak: []),
          finalRound,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoundDisplayScreen(tournament: tournamentWithIncompleteFinalRound),
        ),
      );

      // Should NOT show "Vis Resultat" button (final round not completed)
      expect(find.text('Vis Resultat'), findsNothing);
      // Should NOT show "Generer Næste Runde" button (in final round)
      expect(find.textContaining('Generer Næste Runde'), findsNothing);
    });
  });
}

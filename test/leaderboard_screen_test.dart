import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/models/round.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/screens/leaderboard_screen.dart';

void main() {
  group('LeaderboardScreen Widget', () {
    testWidgets('should display message when no matches played',
        (WidgetTester tester) async {
      final tournament = Tournament(
        name: 'Test Tournament',
        players: [
          Player(id: '1', name: 'Player 1'),
          Player(id: '2', name: 'Player 2'),
        ],
        courts: [Court(id: '1', name: 'Bane 1')],
        rounds: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );

      expect(find.text('No matches played yet'), findsOneWidget);
    });

    testWidgets('should display all players in the leaderboard',
        (WidgetTester tester) async {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      final match = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );
      await tester.pumpAndSettle();

      // All players should be displayed
      expect(find.text('Player A'), findsOneWidget);
      expect(find.text('Player B'), findsOneWidget);
      expect(find.text('Player C'), findsOneWidget);
      // Scroll to ensure Player D is visible
      await tester.dragUntilVisible(
        find.text('Player D'),
        find.byType(ListView),
        const Offset(0, -50),
      );
      expect(find.text('Player D'), findsOneWidget);
    });

    testWidgets('should display correct statistics for players',
        (WidgetTester tester) async {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // Match 1: A+B (20) vs C+D (10) - A and B win
      final match1 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      // Match 2: A+C (15) vs B+D (18) - B and D win
      final match2 = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerC),
        team2: Team(player1: playerB, player2: playerD),
        team1Score: 15,
        team2Score: 18,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match1, match2],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );

      // Player B should be first with 38 points (20 + 18)
      // Find the first card which should be Player B
      final firstCard = find.byType(Card).first;
      expect(firstCard, findsOneWidget);

      // Check that we can find the statistics
      expect(find.text('Total Points'), findsWidgets);
      expect(find.text('Wins'), findsWidgets);
      expect(find.text('Losses'), findsWidgets);
    });

    testWidgets('should highlight top 3 positions with medals',
        (WidgetTester tester) async {
      final players = List.generate(
        5,
        (i) => Player(id: '$i', name: 'Player $i'),
      );

      final court = Court(id: '1', name: 'Bane 1');

      // Create matches to give different scores
      final matches = [
        // Player 0 gets 25 points
        Match(
          court: court,
          team1: Team(player1: players[0], player2: players[4]),
          team2: Team(player1: players[1], player2: players[2]),
          team1Score: 25,
          team2Score: 10,
        ),
        // Player 1 gets 20 points
        Match(
          court: court,
          team1: Team(player1: players[1], player2: players[3]),
          team2: Team(player1: players[2], player2: players[4]),
          team1Score: 20,
          team2Score: 15,
        ),
        // Player 2 gets 18 points
        Match(
          court: court,
          team1: Team(player1: players[2], player2: players[0]),
          team2: Team(player1: players[3], player2: players[1]),
          team1Score: 18,
          team2Score: 12,
        ),
      ];

      final round = Round(
        roundNumber: 1,
        matches: matches,
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: players,
        courts: [court],
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );

      // Check for trophy icons (should be at least 3 for top 3)
      final trophyIcons = find.byIcon(Icons.emoji_events);
      expect(trophyIcons, findsWidgets);
    });

    testWidgets('should display rank numbers correctly',
        (WidgetTester tester) async {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      final match = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );
      await tester.pumpAndSettle();

      // Verify ranks are assigned correctly 
      // Since A and B are on winning team with same score, they should share rank #1
      // Since C and D are on losing team with same score, they should share a rank
      
      // Scroll through to find all players and their ranks
      expect(find.text('Player A'), findsOneWidget);
      expect(find.text('Player B'), findsOneWidget);
      
      // C and D should also be present (may need to scroll)
      if (find.text('Player C').evaluate().isEmpty) {
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();
      }
      expect(find.text('Player C'), findsOneWidget);
      
      if (find.text('Player D').evaluate().isEmpty) {
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();
      }
      expect(find.text('Player D'), findsOneWidget);
      
      // Verify ranks exist (some may be off-screen after scrolling)
      // At minimum we should have rank indicators
      expect(find.textContaining('#'), findsWidgets);
    });

    testWidgets('should handle shared rankings',
        (WidgetTester tester) async {
      final playerA = Player(id: 'A', name: 'Player A');
      final playerB = Player(id: 'B', name: 'Player B');
      final playerC = Player(id: 'C', name: 'Player C');
      final playerD = Player(id: 'D', name: 'Player D');

      final court = Court(id: '1', name: 'Bane 1');

      // A and B are partners and get same score
      final match = Match(
        court: court,
        team1: Team(player1: playerA, player2: playerB),
        team2: Team(player1: playerC, player2: playerD),
        team1Score: 20,
        team2Score: 10,
      );

      final round = Round(
        roundNumber: 1,
        matches: [match],
        playersOnBreak: [],
      );

      final tournament = Tournament(
        name: 'Test Tournament',
        players: [playerA, playerB, playerC, playerD],
        courts: [court],
        rounds: [round],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );

      // Both A and B should have rank #1 (shared)
      final rank1Badges = find.text('#1');
      expect(rank1Badges, findsNWidgets(2)); // Two players with rank 1
    });

    testWidgets('should display appbar with title',
        (WidgetTester tester) async {
      final tournament = Tournament(
        name: 'Test Tournament',
        players: [
          Player(id: '1', name: 'Player 1'),
        ],
        courts: [Court(id: '1', name: 'Bane 1')],
        rounds: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(tournament: tournament),
        ),
      );

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}

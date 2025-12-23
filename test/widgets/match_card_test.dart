import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/court.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/widgets/match_card.dart';

void main() {
  group('MatchCard Widget', () {
    testWidgets('should display court name', (WidgetTester tester) async {
      final match = Match(
        court: Court(id: '1', name: 'Bane 1'),
        team1: Team(
          player1: Player(id: '1', name: 'Player A'),
          player2: Player(id: '2', name: 'Player B'),
        ),
        team2: Team(
          player1: Player(id: '3', name: 'Player C'),
          player2: Player(id: '4', name: 'Player D'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard(match: match),
          ),
        ),
      );

      expect(find.text('Bane 1'), findsOneWidget);
    });

    testWidgets('should display all four player names',
        (WidgetTester tester) async {
      final match = Match(
        court: Court(id: '1', name: 'Bane 1'),
        team1: Team(
          player1: Player(id: '1', name: 'Player A'),
          player2: Player(id: '2', name: 'Player B'),
        ),
        team2: Team(
          player1: Player(id: '3', name: 'Player C'),
          player2: Player(id: '4', name: 'Player D'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard(match: match),
          ),
        ),
      );

      expect(find.text('Player A'), findsOneWidget);
      expect(find.text('Player B'), findsOneWidget);
      expect(find.text('Player C'), findsOneWidget);
      expect(find.text('Player D'), findsOneWidget);
    });

    testWidgets('should display team labels', (WidgetTester tester) async {
      final match = Match(
        court: Court(id: '1', name: 'Bane 1'),
        team1: Team(
          player1: Player(id: '1', name: 'Player A'),
          player2: Player(id: '2', name: 'Player B'),
        ),
        team2: Team(
          player1: Player(id: '3', name: 'Player C'),
          player2: Player(id: '4', name: 'Player D'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard(match: match),
          ),
        ),
      );

      expect(find.text('PAR 1'), findsOneWidget);
      expect(find.text('PAR 2'), findsOneWidget);
    });

    testWidgets('should display VS divider', (WidgetTester tester) async {
      final match = Match(
        court: Court(id: '1', name: 'Bane 1'),
        team1: Team(
          player1: Player(id: '1', name: 'Player A'),
          player2: Player(id: '2', name: 'Player B'),
        ),
        team2: Team(
          player1: Player(id: '3', name: 'Player C'),
          player2: Player(id: '4', name: 'Player D'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard(match: match),
          ),
        ),
      );

      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('should display scores when provided',
        (WidgetTester tester) async {
      final match = Match(
        court: Court(id: '1', name: 'Bane 1'),
        team1: Team(
          player1: Player(id: '1', name: 'Player A'),
          player2: Player(id: '2', name: 'Player B'),
        ),
        team2: Team(
          player1: Player(id: '3', name: 'Player C'),
          player2: Player(id: '4', name: 'Player D'),
        ),
        team1Score: 18,
        team2Score: 6,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard(match: match),
          ),
        ),
      );

      expect(find.text('18'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('should display edit button', (WidgetTester tester) async {
      final match = Match(
        court: Court(id: '1', name: 'Bane 1'),
        team1: Team(
          player1: Player(id: '1', name: 'Player A'),
          player2: Player(id: '2', name: 'Player B'),
        ),
        team2: Team(
          player1: Player(id: '3', name: 'Player C'),
          player2: Player(id: '4', name: 'Player D'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard(match: match),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.sports_tennis), findsOneWidget);
    });
  });
}

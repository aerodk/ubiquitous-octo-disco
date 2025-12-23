import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/match.dart';
import 'package:star_cano/widgets/court_visualization/team_side.dart';

void main() {
  group('TeamSide Widget', () {
    testWidgets('should display team label', (WidgetTester tester) async {
      final team = Team(
        player1: Player(id: '1', name: 'Player A'),
        player2: Player(id: '2', name: 'Player B'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamSide(
              team: team,
              label: 'PAR 1',
            ),
          ),
        ),
      );

      expect(find.text('PAR 1'), findsOneWidget);
    });

    testWidgets('should display both player names',
        (WidgetTester tester) async {
      final team = Team(
        player1: Player(id: '1', name: 'Player A'),
        player2: Player(id: '2', name: 'Player B'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamSide(
              team: team,
              label: 'PAR 1',
            ),
          ),
        ),
      );

      expect(find.text('Player A'), findsOneWidget);
      expect(find.text('Player B'), findsOneWidget);
    });

    testWidgets('should display score when provided',
        (WidgetTester tester) async {
      final team = Team(
        player1: Player(id: '1', name: 'Player A'),
        player2: Player(id: '2', name: 'Player B'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamSide(
              team: team,
              label: 'PAR 1',
              score: 18,
            ),
          ),
        ),
      );

      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('should display placeholder when score is null',
        (WidgetTester tester) async {
      final team = Team(
        player1: Player(id: '1', name: 'Player A'),
        player2: Player(id: '2', name: 'Player B'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamSide(
              team: team,
              label: 'PAR 1',
              score: null,
            ),
          ),
        ),
      );

      expect(find.text('--'), findsOneWidget);
    });
  });
}

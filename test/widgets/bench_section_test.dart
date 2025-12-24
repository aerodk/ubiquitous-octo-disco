import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/player_standing.dart';
import 'package:star_cano/widgets/court_visualization/bench_section.dart';

void main() {
  group('BenchSection Widget', () {
    testWidgets('should not display when no players on break',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BenchSection(
              playersOnBreak: [],
              standings: [],
            ),
          ),
        ),
      );

      expect(find.byType(BenchSection), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('should display header when players on break',
        (WidgetTester tester) async {
      final players = [
        Player(id: '1', name: 'Player A'),
      ];
      
      final standings = [
        PlayerStanding.initial(players[0]),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BenchSection(
              playersOnBreak: players,
              standings: standings,
            ),
          ),
        ),
      );

      expect(find.text('PÅ BÆNKEN DENNE RUNDE'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle), findsOneWidget);
    });

    testWidgets('should display all players on break',
        (WidgetTester tester) async {
      final players = [
        Player(id: '1', name: 'Player A'),
        Player(id: '2', name: 'Player B'),
        Player(id: '3', name: 'Player C'),
      ];
      
      final standings = players.map((p) => PlayerStanding.initial(p)).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BenchSection(
              playersOnBreak: players,
              standings: standings,
            ),
          ),
        ),
      );

      expect(find.text('Player A'), findsOneWidget);
      expect(find.text('Player B'), findsOneWidget);
      expect(find.text('Player C'), findsOneWidget);
    });

    testWidgets('should call onPlayerTap when player is tapped',
        (WidgetTester tester) async {
      final players = [
        Player(id: '1', name: 'Player A'),
      ];
      
      final standings = [
        PlayerStanding.initial(players[0]),
      ];
      
      Player? tappedPlayer;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BenchSection(
              playersOnBreak: players,
              standings: standings,
              onPlayerTap: (player) {
                tappedPlayer = player;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Player A'));
      await tester.pumpAndSettle();

      expect(tappedPlayer, isNotNull);
      expect(tappedPlayer!.name, equals('Player A'));
    });
  });
}

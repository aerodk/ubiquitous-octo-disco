import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/widgets/court_visualization/player_marker.dart';

void main() {
  group('PlayerMarker Widget', () {
    testWidgets('should display player name and person icon',
        (WidgetTester tester) async {
      final player = Player(id: '1', name: 'Test Player');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerMarker(player: player),
          ),
        ),
      );

      expect(find.text('Test Player'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should call onLongPress when long-pressed',
        (WidgetTester tester) async {
      final player = Player(id: '1', name: 'Test Player');
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerMarker(
              player: player,
              onLongPress: () {
                longPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('should not have GestureDetector when onLongPress is null',
        (WidgetTester tester) async {
      final player = Player(id: '1', name: 'Test Player');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerMarker(player: player),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}

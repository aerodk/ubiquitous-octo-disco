import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/widgets/court_visualization/score_display.dart';

void main() {
  group('ScoreDisplay Widget', () {
    testWidgets('should display "--" when score is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: null),
          ),
        ),
      );

      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('should display score value when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: 18),
          ),
        ),
      );

      expect(find.text('18'), findsOneWidget);
      expect(find.text('--'), findsNothing);
    });

    testWidgets('should display zero score correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: 0),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: null,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('should not have GestureDetector when onTap is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: null),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}

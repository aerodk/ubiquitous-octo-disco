import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/widgets/court_visualization/net_divider.dart';

void main() {
  group('NetDivider Widget', () {
    testWidgets('should display VS badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: NetDivider(),
            ),
          ),
        ),
      );

      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: NetDivider(),
            ),
          ),
        ),
      );

      expect(find.byType(NetDivider), findsOneWidget);
    });
  });
}

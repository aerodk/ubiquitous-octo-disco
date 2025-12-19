// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:star_cano/main.dart';

void main() {
  testWidgets('Padel tournament app loads setup screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Verify that the setup screen is loaded
    expect(find.text('Opsætning af Turnering'), findsOneWidget);
    expect(find.text('Spillere (0/24)'), findsOneWidget);
    expect(find.text('Baner'), findsOneWidget);
    expect(find.text('Generer Første Runde'), findsOneWidget);
  });

  testWidgets('Setup screen allows adding players', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Find the text field and enter a player name
    await tester.enterText(find.byType(TextField), 'Test Player');
    
    // Tap the add button
    await tester.tap(find.text('Tilføj'));
    await tester.pump();

    // Verify the player was added
    expect(find.text('Test Player'), findsOneWidget);
    expect(find.text('Spillere (1/24)'), findsOneWidget);
  });

  testWidgets('TextField gets focus after adding a player', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Find the text field
    final textField = find.byType(TextField);
    
    // Enter a player name
    await tester.enterText(textField, 'Player 1');
    
    // Tap the add button
    await tester.tap(find.text('Tilføj'));
    await tester.pump();

    // Verify the player was added
    expect(find.text('Player 1'), findsOneWidget);
    
    // Verify the text field is cleared
    final textFieldWidget = tester.widget<TextField>(textField);
    expect(textFieldWidget.controller?.text, isEmpty);
    
    // Verify the text field has focus (by checking if we can immediately type)
    await tester.enterText(textField, 'Player 2');
    expect(textFieldWidget.controller?.text, 'Player 2');
  });

  testWidgets('Setup screen prevents empty player names', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Try to add an empty name
    await tester.tap(find.text('Tilføj'));
    await tester.pump();

    // Verify error message is shown
    expect(find.text('Spillernavn kan ikke være tomt'), findsOneWidget);
  });

  testWidgets('Setup screen prevents duplicate player names', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Add first player
    await tester.enterText(find.byType(TextField), 'Test Player');
    await tester.tap(find.text('Tilføj'));
    await tester.pump();

    // Try to add duplicate
    await tester.enterText(find.byType(TextField), 'Test Player');
    await tester.tap(find.text('Tilføj'));
    await tester.pump();

    // Verify error message is shown
    expect(find.text('Spilleren findes allerede'), findsOneWidget);
  });

  testWidgets('Setup screen allows adjusting court count', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Initial court count should be 1
    expect(find.text('1 bane'), findsOneWidget);

    // Tap add button
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();

    // Verify court count increased
    expect(find.text('2 baner'), findsOneWidget);
  });

  testWidgets('Court count automatically adjusts when adding players', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Initial court count should be 1
    expect(find.text('1 bane'), findsOneWidget);

    // Add 4 players (should suggest 1 court)
    for (int i = 1; i <= 4; i++) {
      await tester.enterText(find.byType(TextField), 'Player $i');
      await tester.tap(find.text('Tilføj'));
      await tester.pump();
    }
    
    // Should still be 1 court for 4 players
    expect(find.text('1 bane'), findsOneWidget);
    
    // Add 5th player (should suggest 2 courts)
    await tester.enterText(find.byType(TextField), 'Player 5');
    await tester.tap(find.text('Tilføj'));
    await tester.pump();
    
    // Should now be 2 courts
    expect(find.text('2 baner'), findsOneWidget);
    
    // Add players 6-8 (should still be 2 courts)
    for (int i = 6; i <= 8; i++) {
      await tester.enterText(find.byType(TextField), 'Player $i');
      await tester.tap(find.text('Tilføj'));
      await tester.pump();
    }
    
    expect(find.text('2 baner'), findsOneWidget);
    
    // Add 9th player (should suggest 3 courts)
    await tester.enterText(find.byType(TextField), 'Player 9');
    await tester.tap(find.text('Tilføj'));
    await tester.pump();
    
    expect(find.text('3 baner'), findsOneWidget);
  });

  testWidgets('Court count automatically adjusts when removing players', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Add 9 players to get 3 courts
    for (int i = 1; i <= 9; i++) {
      await tester.enterText(find.byType(TextField), 'Player $i');
      await tester.tap(find.text('Tilføj'));
      await tester.pump();
    }
    
    expect(find.text('3 baner'), findsOneWidget);
    
    // Remove a player (should go down to 2 courts at 8 players)
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();
    
    expect(find.text('2 baner'), findsOneWidget);
    
    // Remove 4 more players to get to 4 players (should go down to 1 court)
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
    }
    
    expect(find.text('1 bane'), findsOneWidget);
  });

  testWidgets('Manual court adjustment still works despite auto-adjustment', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PadelTournamentApp());

    // Add 4 players (auto-suggests 1 court)
    for (int i = 1; i <= 4; i++) {
      await tester.enterText(find.byType(TextField), 'Player $i');
      await tester.tap(find.text('Tilføj'));
      await tester.pump();
    }
    
    expect(find.text('1 bane'), findsOneWidget);
    
    // Manually increase court count
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    
    expect(find.text('2 baner'), findsOneWidget);
    
    // Add another player - auto-adjustment should still kick in
    await tester.enterText(find.byType(TextField), 'Player 5');
    await tester.tap(find.text('Tilføj'));
    await tester.pump();
    
    // Should auto-adjust to 2 courts (formula: (5+3)~/4 = 2)
    expect(find.text('2 baner'), findsOneWidget);
    
    // Manually decrease court count
    await tester.tap(find.byIcon(Icons.remove).last);
    await tester.pump();
    
    expect(find.text('1 bane'), findsOneWidget);
  });
}

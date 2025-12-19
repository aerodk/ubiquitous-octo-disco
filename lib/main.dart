import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const PadelTournamentApp());
}

class PadelTournamentApp extends StatelessWidget {
  const PadelTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padel Turnering',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}

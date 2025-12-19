import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';
import 'screens/round_display_screen.dart';
import 'services/persistence_service.dart';

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
      home: const AppInitializer(),
    );
  }
}

/// Widget that checks for saved tournament and navigates accordingly
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final PersistenceService _persistenceService = PersistenceService();

  @override
  void initState() {
    super.initState();
    _checkSavedTournament();
  }

  Future<void> _checkSavedTournament() async {
    final tournament = await _persistenceService.loadTournament();
    
    if (mounted) {
      if (tournament != null) {
        // Navigate to round display if tournament exists
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RoundDisplayScreen(tournament: tournament),
          ),
        );
      } else {
        // Navigate to setup if no tournament exists
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SetupScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

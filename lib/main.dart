import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/setup_screen.dart';
import 'screens/round_display_screen.dart';
import 'screens/tournament_completion_screen.dart';
import 'services/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: Firebase config is loaded from environment variables
  // defined in GitHub Actions secrets or local .env
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed - app will work in local-only mode
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will run in local-only mode without cloud storage.');
  }
  
  runApp(const PadelTournamentApp());
}

class PadelTournamentApp extends StatelessWidget {
  const PadelTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padel Turnering',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
        // Navigate based on completion state
        final destination = tournament.isCompleted
            ? TournamentCompletionScreen(tournament: tournament)
            : RoundDisplayScreen(tournament: tournament);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destination),
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

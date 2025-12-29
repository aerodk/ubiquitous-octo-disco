import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/setup_screen.dart';
import 'screens/round_display_screen.dart';
import 'screens/tournament_completion_screen.dart';
import 'services/persistence_service.dart';
import 'services/share_service.dart';
import 'services/firebase_service.dart';
import 'models/tournament.dart';

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
  final ShareService _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // First, check if there's a tournament in the URL
    final tournamentInfo = _shareService.parseTournamentFromUrl(Uri.base);
    
    if (tournamentInfo != null) {
      // Load tournament from URL
      await _loadTournamentFromUrl(tournamentInfo);
    } else {
      // Check for saved tournament
      await _checkSavedTournament();
    }
  }

  Future<void> _loadTournamentFromUrl(Map<String, dynamic> tournamentInfo) async {
    final code = tournamentInfo['code'] as String;
    final passcode = tournamentInfo['passcode'] as String?;

    try {
      // Show loading indicator
      if (!mounted) return;
      
      // Create FirebaseService only when needed
      final firebaseService = FirebaseService();
      
      // Load tournament from Firebase
      Tournament tournament;
      if (passcode != null) {
        // Load with passcode (but still read-only)
        tournament = await firebaseService.loadTournament(
          tournamentCode: code,
          passcode: passcode,
        );
      } else {
        // Load in read-only mode
        tournament = await firebaseService.loadTournamentReadOnly(
          tournamentCode: code,
        );
      }

      if (!mounted) return;

      // Navigate to appropriate screen based on completion state
      final destination = tournament.isCompleted
          ? TournamentCompletionScreen(
              tournament: tournament,
              isReadOnly: true,
            )
          : RoundDisplayScreen(
              tournament: tournament,
              enableCloud: false, // Disable cloud sync for shared links
              isReadOnly: true,
            );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destination),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show error and navigate to setup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kunne ikke hente turnering: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SetupScreen(),
        ),
      );
    }
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

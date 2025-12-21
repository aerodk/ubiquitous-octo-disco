import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/player_standing.dart';
import '../services/standings_service.dart';
import '../services/persistence_service.dart';
import 'setup_screen.dart';

class TournamentCompletionScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentCompletionScreen({super.key, required this.tournament});

  @override
  State<TournamentCompletionScreen> createState() =>
      _TournamentCompletionScreenState();
}

class _TournamentCompletionScreenState
    extends State<TournamentCompletionScreen> with TickerProviderStateMixin {
  final StandingsService _standingsService = StandingsService();
  final PersistenceService _persistenceService = PersistenceService();
  late List<PlayerStanding> _standings;
  late AnimationController _confettiController;
  
  // Track which positions have been revealed
  final Set<int> _revealedPositions = {};
  final Map<int, AnimationController> _medalAnimations = {};
  final Map<int, AnimationController> _celebrationAnimations = {};
  bool _showAllPositions = false;

  @override
  void initState() {
    super.initState();
    _standings = _standingsService.calculateStandings(widget.tournament);
    
    // Setup confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    
    // Setup medal animations for top 3
    for (int i = 1; i <= 3 && i <= _standings.length; i++) {
      _medalAnimations[i] = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _celebrationAnimations[i] = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    for (final controller in _medalAnimations.values) {
      controller.dispose();
    }
    for (final controller in _celebrationAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getTournamentDuration() {
    final duration = DateTime.now().difference(widget.tournament.createdAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours t $minutes min';
    } else {
      return '$minutes min';
    }
  }

  PlayerStanding? _getTopScorer() {
    if (_standings.isEmpty) return null;
    return _standings.reduce((a, b) => a.totalPoints > b.totalPoints ? a : b);
  }

  PlayerStanding? _getMostWins() {
    if (_standings.isEmpty) return null;
    return _standings.reduce((a, b) => a.wins > b.wins ? a : b);
  }

  int _getBiggestWinMargin() {
    if (_standings.isEmpty) return 0;
    return _standings
        .map((s) => s.biggestWinMargin)
        .reduce((a, b) => a > b ? a : b);
  }

  Future<void> _startNewTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Ny Turnering'),
        content: const Text(
          'Er du sikker på at du vil starte en ny turnering? '
          'Den nuværende turnering vil blive gemt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start Ny'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _persistenceService.clearTournament();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SetupScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMatches = widget.tournament.rounds
        .expand((r) => r.matches)
        .where((m) => m.isCompleted)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnering Afsluttet'),
        backgroundColor: Colors.amber[700],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Trophy icon with animation
                FadeTransition(
                  opacity: _confettiController,
                  child: const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🎉 Tillykke! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Podium (Top 3)
                _buildPodium(),
                const SizedBox(height: 32),

                // Tournament Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Turnerings Statistik',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildStatRow('Total kampe', '$totalMatches'),
                        _buildStatRow('Varighed', _getTournamentDuration()),
                        _buildStatRow(
                          'Top scorer',
                          _getTopScorer()?.player.name ?? '-',
                        ),
                        _buildStatRow(
                          'Flest sejre',
                          _getMostWins()?.player.name ?? '-',
                        ),
                        _buildStatRow(
                          'Største sejr',
                          '${_getBiggestWinMargin()} point',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Full leaderboard
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Endelig Stilling',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ..._standings.map((s) => _buildLeaderboardTile(s)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startNewTournament,
                    icon: const Icon(Icons.add),
                    label: const Text('Start Ny Turnering'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Space for bottom padding
              ],
            ),
          ),

          // Confetti animation overlay (simple fade effect)
          if (_confettiController.isAnimating)
            IgnorePointer(
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: _confettiController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.amber.withValues(alpha: .3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _standings.take(3).toList();
    
    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    // Make podium larger on bigger screens
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth > 600 ? 1.5 : 1.0;
    final podiumHeight = 200.0 * scaleFactor;
    final firstPlaceHeight = 180.0 * scaleFactor;
    final secondPlaceHeight = 140.0 * scaleFactor;
    final thirdPlaceHeight = 120.0 * scaleFactor;

    return Column(
      children: [
        SizedBox(
          height: podiumHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              if (top3.length > 1) _buildPodiumPlace(top3[1], 2, secondPlaceHeight, Colors.grey, scaleFactor),
              SizedBox(width: 8 * scaleFactor),
              // 1st place
              _buildPodiumPlace(top3[0], 1, firstPlaceHeight, Colors.amber, scaleFactor),
              SizedBox(width: 8 * scaleFactor),
              // 3rd place
              if (top3.length > 2)
                _buildPodiumPlace(top3[2], 3, thirdPlaceHeight, Colors.brown, scaleFactor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Show All button for remaining positions
        if (_standings.length > 3 && !_showAllPositions)
          ElevatedButton.icon(
            onPressed: _revealAllPositions,
            icon: const Icon(Icons.visibility),
            label: const Text('Vis Alle Placeringer'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPodiumPlace(
    PlayerStanding standing,
    int place,
    double height,
    Color color,
    double scaleFactor,
  ) {
    final isRevealed = _revealedPositions.contains(place);
    final medalController = _medalAnimations[place];
    final celebrationController = _celebrationAnimations[place];
    
    return GestureDetector(
      onTap: () => _revealPodiumPlace(place),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main podium content
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Medal or revealed content
              Container(
                padding: EdgeInsets.all(8 * scaleFactor),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  place == 1 ? '🥇' : place == 2 ? '🥈' : '🥉',
                  style: TextStyle(fontSize: 24 * scaleFactor),
                ),
              ),
              SizedBox(height: 4 * scaleFactor),
              // Player name and points (revealed or hidden)
              SizedBox(
                height: 32 * scaleFactor, // Fixed height to prevent layout shift
                child: Stack(
                  children: [
                    // Revealed content
                    AnimatedOpacity(
                      opacity: isRevealed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            standing.player.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12 * scaleFactor,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${standing.totalPoints} pt',
                            style: TextStyle(fontSize: 11 * scaleFactor),
                          ),
                        ],
                      ),
                    ),
                    // Hidden placeholder
                    if (!isRevealed)
                      Column(
                        children: [
                          Text(
                            '???',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12 * scaleFactor,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '? pt',
                            style: TextStyle(fontSize: 11 * scaleFactor, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 4 * scaleFactor),
              Container(
                width: 80 * scaleFactor,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8 * scaleFactor),
                  ),
                ),
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(8 * scaleFactor),
                child: Text(
                  '$place',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32 * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Medal overlay that fades out when revealed
          if (!isRevealed && medalController != null)
            Positioned.fill(
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: medalController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .95),
                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                  ),
                  child: Center(
                    child: Text(
                      place == 1 ? '🥇' : place == 2 ? '🥈' : '🥉',
                      style: TextStyle(fontSize: 48 * scaleFactor),
                    ),
                  ),
                ),
              ),
            ),
          // Celebration particles when revealed
          if (isRevealed && celebrationController != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: celebrationController,
                  builder: (context, child) {
                    if (!celebrationController.isAnimating && 
                        celebrationController.value == 0) {
                      return const SizedBox.shrink();
                    }
                    return CustomPaint(
                      painter: _CelebrationPainter(
                        animationValue: celebrationController.value,
                        color: color,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  void _revealPodiumPlace(int place) {
    if (_revealedPositions.contains(place)) return;
    
    setState(() {
      _revealedPositions.add(place);
    });
    
    // Animate medal fade out
    _medalAnimations[place]?.forward();
    
    // Start celebration animation
    Future.delayed(const Duration(milliseconds: 400), () {
      _celebrationAnimations[place]?.forward().then((_) {
        _celebrationAnimations[place]?.reset();
      });
    });
  }
  
  void _revealAllPositions() {
    setState(() {
      _showAllPositions = true;
      // Reveal all top 3 positions
      for (int i = 1; i <= 3 && i <= _standings.length; i++) {
        if (!_revealedPositions.contains(i)) {
          _revealedPositions.add(i);
          _medalAnimations[i]?.forward();
        }
      }
    });
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
  
  Widget _buildLeaderboardTile(PlayerStanding s) {
    // All positions are hidden until revealed (including top 3)
    final isRevealed = _showAllPositions || _revealedPositions.contains(s.rank);
    
    return InkWell(
      onTap: isRevealed ? null : () => _revealLeaderboardPosition(s.rank),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isRevealed ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: isRevealed ? _getRankColor(s.rank) : Colors.grey,
            child: Text(
              isRevealed ? '${s.rank}' : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            isRevealed ? s.player.name : '???',
            style: TextStyle(
              color: isRevealed ? Colors.black : Colors.grey[600],
            ),
          ),
          subtitle: Text(
            isRevealed 
              ? '${s.wins}W-${s.losses}L • ${s.matchesPlayed} kampe'
              : 'Tryk for at afsløre',
            style: TextStyle(
              color: isRevealed ? null : Colors.grey[500],
              fontStyle: isRevealed ? null : FontStyle.italic,
            ),
          ),
          trailing: Text(
            isRevealed ? '${s.totalPoints}' : '?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isRevealed ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
  
  void _revealLeaderboardPosition(int rank) {
    setState(() {
      _revealedPositions.add(rank);
    });
  }
}

// Custom painter for celebration particles
class _CelebrationPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  
  _CelebrationPainter({
    required this.animationValue,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - animationValue) * 0.8)
      ..style = PaintingStyle.fill;
    
    final random = 42; // Fixed seed for consistent particle positions
    
    // Draw celebration particles (stars/sparkles)
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final distance = animationValue * size.width * 0.6;
      final x = size.width / 2 + distance * cos(angle + random);
      final y = size.height / 2 + distance * sin(angle + random);
      final particleSize = 4 * (1 - animationValue);
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

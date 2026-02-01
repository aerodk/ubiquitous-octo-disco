import 'dart:math';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/tournament.dart';
import '../models/player.dart';
import '../models/player_standing.dart';
import '../services/standings_service.dart';
import '../services/persistence_service.dart';
import '../services/display_mode_service.dart';
import '../widgets/export_dialog.dart';
import '../widgets/save_tournament_dialog.dart';
import '../widgets/share_tournament_dialog.dart';
import '../utils/constants.dart';
import 'setup_screen.dart';

class TournamentCompletionScreen extends StatefulWidget {
  final Tournament tournament;
  final String? cloudCode;
  final String? cloudPasscode;
  final bool isReadOnly;

  const TournamentCompletionScreen({
    super.key,
    required this.tournament,
    this.cloudCode,
    this.cloudPasscode,
    this.isReadOnly = false,
  });

  @override
  State<TournamentCompletionScreen> createState() =>
      _TournamentCompletionScreenState();
}

class _TournamentCompletionScreenState
    extends State<TournamentCompletionScreen> with TickerProviderStateMixin {
  final StandingsService _standingsService = StandingsService();
  final PersistenceService _persistenceService = PersistenceService();
  final FirebaseService _firebaseService = FirebaseService();
  final DisplayModeService _displayModeService = DisplayModeService();
  late List<PlayerStanding> _standings;
  late AnimationController _confettiController;
  
  // Track cloud storage codes
  String? _cloudCode;
  String? _cloudPasscode;
  
  // Track which positions have been revealed
  final Set<int> _revealedPositions = {};
  final Map<int, AnimationController> _medalAnimations = {};
  final Map<int, AnimationController> _celebrationAnimations = {};
  bool _showAllPositions = false;
  
  // Toggle for compact/detailed view
  bool _isCompactView = true;
  
  // Display mode (mobile/desktop)
  bool _isDesktopMode = false;

  @override
  void initState() {
    super.initState();
    _standings = _standingsService.calculateStandings(widget.tournament);
    _cloudCode = widget.cloudCode;
    _cloudPasscode = widget.cloudPasscode;
    
    // Setup confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    // Persist final standings locally so completion view is saved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistCompletion();
      _loadDisplayMode();
    });
    
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
  
  Future<void> _loadDisplayMode() async {
    final isDesktop = await _displayModeService.isDesktopMode();
    setState(() {
      _isDesktopMode = isDesktop;
    });
  }

  Future<void> _toggleDisplayMode() async {
    final newMode = await _displayModeService.toggleDisplayMode();
    setState(() {
      _isDesktopMode = newMode;
    });
  }

  Future<void> _persistCompletion() async {
    try {
      await _persistenceService.saveTournament(widget.tournament);
      // If cloud is configured, also update the cloud copy
      if (_cloudCode != null && _cloudPasscode != null) {
        final isAvailable = await _firebaseService.isFirebaseAvailable();
        if (isAvailable) {
          await _firebaseService.updateTournament(
            tournamentCode: _cloudCode!,
            passcode: _cloudPasscode!,
            tournament: widget.tournament,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to persist completed tournament: $e');
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

  Future<void> _saveToCloud() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveTournamentDialog(
        tournament: widget.tournament,
        existingCode: _cloudCode,
        existingPasscode: _cloudPasscode,
      ),
    );

    if (result != null) {
      setState(() {
        _cloudCode = result['code'] as String;
        _cloudPasscode = result['passcode'] as String;
      });
    }
  }

  Future<void> _showShareDialog() async {
    // Only allow sharing if tournament is saved to cloud
    if (_cloudCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gem turneringen i cloud først for at dele'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => ShareTournamentDialog(
        tournamentCode: _cloudCode!,
        passcode: _cloudPasscode,
      ),
    );
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
        title: Row(
          children: [
            const Text('Turnering afsluttet'),
            if (widget.isReadOnly) ...[
              const SizedBox(width: 8),
              const Text(
                '(Kun Visning)',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.amber[700], 
        automaticallyImplyLeading: false,
        actions: [
          // Display mode toggle (mobile/desktop)
          IconButton(
            icon: Icon(_isDesktopMode ? Icons.desktop_windows : Icons.phone_android),
            tooltip: _isDesktopMode ? 'Skift til mobil visning' : 'Skift til desktop visning',
            onPressed: _toggleDisplayMode,
          ),
          // Toggle compact/detailed view
          IconButton(
            icon: Icon(_isCompactView ? Icons.view_list : Icons.view_compact),
            tooltip: _isCompactView ? 'Detailed View' : 'Compact View',
            onPressed: () {
              setState(() {
                _isCompactView = !_isCompactView;
              });
            },
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Eksporter Resultater',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ExportDialog(
                  standings: _standings,
                  tournament: widget.tournament,
                ),
              );
            },
          ),
          // Share button (only if saved to cloud and not already read-only)
          if (_cloudCode != null && !widget.isReadOnly)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Del turnering',
              onPressed: _showShareDialog,
            ),
          // Future options info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Se fremtidige eksport muligheder',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const FutureExportOptionsDialog(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: EdgeInsets.all(_isDesktopMode 
              ? Constants.desktopModeCardPadding 
              : Constants.mobileModeCardPadding),
            child: Column(
              children: [
                // Trophy icon with animation
                FadeTransition(
                  opacity: _confettiController,
                  child: Icon(
                    Icons.emoji_events,
                    size: 80 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0),
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 8 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0)),
                Text(
                  '🎉 Tillykke! 🎉',
                  style: TextStyle(
                    fontSize: 24 * (_isDesktopMode ? Constants.desktopModeFontScale : 1.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0)),

                // Podium (Top 3)
                _buildPodium(),
                SizedBox(height: 32 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0)),

                // Tournament Statistics
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(_isDesktopMode 
                      ? Constants.desktopModeCardPadding 
                      : Constants.mobileModeCardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Turnerings Statistik',
                          style: TextStyle(
                            fontSize: 18 * (_isDesktopMode ? Constants.desktopModeFontScale : 1.0),
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
                        ..._standings.asMap().entries.map((entry) => 
                          _isCompactView 
                            ? _buildLeaderboardTile(entry.value) 
                            : _buildDetailedLeaderboardCard(entry.value, entry.key)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                if (!widget.isReadOnly) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveToCloud,
                          icon: Icon(
                            _cloudCode != null ? Icons.cloud_upload : Icons.cloud_upload_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            _cloudCode != null ? 'Opdater' : 'Gem Cloud',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ExportDialog(
                                tournament: widget.tournament,
                                standings: _standings,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text(
                            'Eksporter',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

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
                ],
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
                        Colors.amber.withOpacity(0.3),
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

    // Make podium significantly larger
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Increase scale factor for larger podiums or desktop mode
    // Reduce scale for smaller screens to ensure all 3 places fit
    final baseScaleFactor = screenWidth > 600 ? 2.5 : (screenHeight < 700 ? 1.2 : 1.5);
    final scaleFactor = _isDesktopMode 
      ? baseScaleFactor * Constants.desktopModeScaleFactor 
      : baseScaleFactor;
    // Leave extra headroom for medal/name so columns do not overflow the bottom
    final firstPlaceHeight = 180.0 * scaleFactor;
    final podiumHeight = firstPlaceHeight + (100.0 * scaleFactor); // Reduced vertical space for mobile
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
              SizedBox(width: 12 * scaleFactor),
              // 1st place
              _buildPodiumPlace(top3[0], 1, firstPlaceHeight, Colors.amber, scaleFactor),
              SizedBox(width: 12 * scaleFactor),
              // 3rd place
              if (top3.length > 2)
                _buildPodiumPlace(top3[2], 3, thirdPlaceHeight, Colors.brown, scaleFactor),
            ],
          ),
        ),
        SizedBox(height: 24 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0)),
        // Show All button for remaining positions
        if (_standings.length > 3 && !_showAllPositions)
          ElevatedButton.icon(
            onPressed: _revealAllPositions,
            icon: Icon(Icons.visibility, size: 24 * (_isDesktopMode ? Constants.desktopModeFontScale : 1.0)),
            label: Text(
              'Vis Alle Placeringer',
              style: TextStyle(fontSize: 16 * (_isDesktopMode ? Constants.desktopModeFontScale : 1.0)),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0),
                vertical: 12 * (_isDesktopMode ? Constants.desktopModeScaleFactor : 1.0),
              ),
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
                padding: EdgeInsets.all(12 * scaleFactor), // Increased padding
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8 * scaleFactor,
                      offset: Offset(0, 4 * scaleFactor),
                    ),
                  ],
                ),
                child: Text(
                  place == 1 ? '🥇' : place == 2 ? '🥈' : '🥉',
                  style: TextStyle(fontSize: 36 * scaleFactor), // Significantly larger emoji
                ),
              ),
              SizedBox(height: 8 * scaleFactor), // More spacing
              // Player name and points (revealed or hidden)
              SizedBox(
                height: 50 * scaleFactor, // Increased height for larger text
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
                              fontSize: 16 * scaleFactor, // Larger text
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2 * scaleFactor),
                          Text(
                            '${standing.totalPoints} pt',
                            style: TextStyle(
                              fontSize: 14 * scaleFactor, // Larger text
                              fontWeight: FontWeight.w600,
                            ),
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
                              fontSize: 16 * scaleFactor,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2 * scaleFactor),
                          Text(
                            '? pt',
                            style: TextStyle(
                              fontSize: 14 * scaleFactor, 
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8 * scaleFactor), // More spacing
              Container(
                width: 100 * scaleFactor, // Wider podium
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12 * scaleFactor),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10 * scaleFactor,
                      offset: Offset(0, 5 * scaleFactor),
                    ),
                  ],
                ),
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(12 * scaleFactor),
                child: Text(
                  '$place',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48 * scaleFactor, // Larger place number
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4 * scaleFactor,
                        offset: Offset(2 * scaleFactor, 2 * scaleFactor),
                      ),
                    ],
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
                    color: color.withOpacity(0.95),
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
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * sizeScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14 * fontScale),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14 * fontScale,
            ),
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
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    
    return InkWell(
      onTap: isRevealed ? null : () => _revealLeaderboardPosition(s.rank),
      onLongPress: isRevealed ? () => _showGameHistoryDialog(context, s) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isRevealed ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(4 * sizeScale),
        ),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 20 * sizeScale,
            backgroundColor: isRevealed ? _getRankColor(s.rank) : Colors.grey,
            child: Text(
              isRevealed ? '${s.rank}' : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * fontScale,
              ),
            ),
          ),
          title: Text(
            isRevealed ? s.player.name : '???',
            style: TextStyle(
              color: isRevealed ? Colors.black : Colors.grey[600],
              fontSize: 16 * fontScale,
            ),
          ),
          subtitle: Text(
            isRevealed 
              ? '${s.wins}W-${s.losses}L • ${s.matchesPlayed} kampe'
              : 'Tryk for at afsløre',
            style: TextStyle(
              color: isRevealed ? null : Colors.grey[500],
              fontStyle: isRevealed ? null : FontStyle.italic,
              fontSize: 12 * fontScale,
            ),
          ),
          trailing: Text(
            isRevealed ? '${s.totalPoints}' : '?',
            style: TextStyle(
              fontSize: 18 * fontScale,
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
  
  /// Build detailed leaderboard card with full statistics (like LeaderboardScreen)
  Widget _buildDetailedLeaderboardCard(PlayerStanding standing, int index) {
    // All positions are hidden until revealed (including top 3)
    final isRevealed = _showAllPositions || _revealedPositions.contains(standing.rank);
    
    // Determine if this is a top 3 position for special styling
    final bool isTop3 = standing.rank <= 3;
    final Color? cardColor = _getCardColor(standing.rank);
    final IconData? medalIcon = _getMedalIcon(standing.rank);
    
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double cardPadding = _isDesktopMode ? Constants.desktopModeCardPadding : Constants.mobileModeCardPadding;
    
    return GestureDetector(
      onTap: isRevealed ? null : () => _revealLeaderboardPosition(standing.rank),
      onLongPress: isRevealed ? () => _showGameHistoryDialog(context, standing) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isRevealed ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(4 * sizeScale),
        ),
        child: Card(
          margin: EdgeInsets.only(bottom: 12 * sizeScale),
          elevation: isTop3 ? 4 : 2,
          color: isRevealed ? cardColor : Colors.grey[200],
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: isRevealed 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Rank, Medal, and Player Name
                    Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 40 * sizeScale,
                          height: 40 * sizeScale,
                          decoration: BoxDecoration(
                            color: isTop3
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#${standing.rank}',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: isTop3 ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * sizeScale),
                        // Medal icon for top 3
                        if (medalIcon != null) ...[
                          Icon(
                            medalIcon,
                            size: 32 * sizeScale,
                            color: _getMedalColor(standing.rank),
                          ),
                          SizedBox(width: 12 * sizeScale),
                        ],
                        // Player name
                        Expanded(
                          child: Text(
                            standing.player.name,
                            style: TextStyle(
                              fontSize: 20 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: isTop3 ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * sizeScale),
                    // Statistics Grid
                    _buildStatisticsGrid(context, standing, isTop3),
                  ],
                )
              : ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 20 * sizeScale,
                    backgroundColor: Colors.grey,
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                  ),
                  title: Text(
                    '???',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16 * fontScale,
                    ),
                  ),
                  subtitle: Text(
                    'Tryk for at afsløre',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                      fontSize: 12 * fontScale,
                    ),
                  ),
                  trailing: Text(
                    '?',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
  
  /// Build statistics grid for detailed view
  Widget _buildStatisticsGrid(
      BuildContext context, PlayerStanding standing, bool isTop3) {
    final textColor = isTop3 ? Colors.white : Colors.black87;
    final subtitleColor = isTop3 ? Colors.white70 : Colors.grey[600];
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;

    return Column(
      children: [
        // Primary stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Points',
              standing.totalPoints.toString(),
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Wins',
              standing.wins.toString(),
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Losses',
              standing.losses.toString(),
              textColor,
              subtitleColor,
            ),
          ],
        ),
        SizedBox(height: 12 * sizeScale),
        // Secondary stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Matches Played',
              standing.matchesPlayed.toString(),
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Biggest Win',
              standing.biggestWinMargin == 0
                  ? '-'
                  : '+${standing.biggestWinMargin}',
              textColor,
              subtitleColor,
            ),
            _buildStatItem(
              'Smallest Loss',
              standing.smallestLossMargin == 999
                  ? '-'
                  : '-${standing.smallestLossMargin}',
              textColor,
              subtitleColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, Color? textColor, Color? subtitleColor) {
    final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 4 * sizeScale),
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * fontScale,
            color: subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Show game history dialog for a player
  void _showGameHistoryDialog(BuildContext context, PlayerStanding standing) {
    final gameHistory = _getGameHistoryForPlayer(standing.player);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${standing.player.name} - Game History'),
        content: SizedBox(
          width: double.maxFinite,
          child: gameHistory.isEmpty
              ? const Text('No games played yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: gameHistory.length,
                  itemBuilder: (context, index) {
                    final game = gameHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Round ${game['round']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Played with: ${game['partner']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Against: ${game['opponents']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${game['score']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: game['result'] == 'Won'
                                    ? Colors.green[700]
                                    : game['result'] == 'Lost'
                                        ? Colors.red[700]
                                        : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Result: ${game['result']}',
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Get game history for a specific player
  List<Map<String, dynamic>> _getGameHistoryForPlayer(Player player) {
    final List<Map<String, dynamic>> history = [];

    for (final round in widget.tournament.rounds) {
      for (final match in round.matches.where((m) => m.isCompleted)) {
        // isCompleted ensures both scores are non-null
        final team1Score = match.team1Score;
        final team2Score = match.team2Score;
        
        // Additional safety check (should never be null due to isCompleted check)
        if (team1Score == null || team2Score == null) continue;
        
        // Check if player is in this match
        final isInTeam1 = match.team1.player1.id == player.id ||
            match.team1.player2.id == player.id;
        final isInTeam2 = match.team2.player1.id == player.id ||
            match.team2.player2.id == player.id;

        if (isInTeam1 || isInTeam2) {
          // Determine partner and opponents
          String partner;
          String opponents;
          int playerScore;
          int opponentScore;
          String result;

          if (isInTeam1) {
            partner = match.team1.player1.id == player.id
                ? match.team1.player2.name
                : match.team1.player1.name;
            opponents =
                '${match.team2.player1.name} & ${match.team2.player2.name}';
            playerScore = team1Score;
            opponentScore = team2Score;
          } else {
            partner = match.team2.player1.id == player.id
                ? match.team2.player2.name
                : match.team2.player1.name;
            opponents =
                '${match.team1.player1.name} & ${match.team1.player2.name}';
            playerScore = team2Score;
            opponentScore = team1Score;
          }

          if (playerScore > opponentScore) {
            result = 'Won';
          } else if (playerScore < opponentScore) {
            result = 'Lost';
          } else {
            result = 'Draw';
          }

          history.add({
            'round': round.roundNumber,
            'partner': partner,
            'opponents': opponents,
            'score': '$playerScore - $opponentScore',
            'result': result,
          });
        }
      }
    }

    return history;
  }
  
  Color? _getCardColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]; // Gold
      case 2:
        return Colors.grey[400]; // Silver
      case 3:
        return Colors.brown[400]; // Bronze
      default:
        return null; // Default card color
    }
  }

  IconData? _getMedalIcon(int rank) {
    switch (rank) {
      case 1:
      case 2:
      case 3:
        return Icons.emoji_events; // Trophy icon
      default:
        return null;
    }
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[200]!; // Gold
      case 2:
        return Colors.grey[100]!; // Silver
      case 3:
        return Colors.brown[200]!; // Bronze
      default:
        return Colors.grey;
    }
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
      ..color = color.withOpacity((1 - animationValue) * 0.8)
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

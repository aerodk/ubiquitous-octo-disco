import '../models/player.dart';
import '../models/court.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/player_stats.dart';

/// Service implementing the Social-Mexicano algorithm for strategic partner/opponent pairing
/// Based on Specification F-006
/// 
/// The Social-Mexicano algorithm:
/// 1. Sorts players by total points (highest first)
/// 2. Pairs players to minimize partner repetition (PRIORITY 1), preferring similar rankings (PRIORITY 2)
/// 3. Matches pairs to minimize opponent repetition (PRIORITY 1), preferring sequential pairs (PRIORITY 2)
/// 4. Creates socially diverse games, though may be competitively unbalanced
/// 
/// Note: This was the original "Mexicano" implementation, renamed to clarify it prioritizes
/// social variety (meeting different people) over competitive balance.
class SocialMexicanoAlgorithmService {
  /// Calculate player statistics from all previous rounds
  /// Returns a map of player ID to PlayerStats
  Map<String, PlayerStats> calculatePlayerStats(
    List<Player> allPlayers,
    List<Round> previousRounds,
  ) {
    final stats = <String, PlayerStats>{};
    
    // Initialize stats for all players
    for (final player in allPlayers) {
      stats[player.id] = PlayerStats.initial(player);
    }
    
    // Process each round
    for (final round in previousRounds) {
      // Update stats from completed matches
      for (final match in round.matches.where((m) => m.isCompleted)) {
        _updateStatsFromMatch(match, stats);
      }
      
      // Track pause rounds
      for (final player in round.playersOnBreak) {
        final currentStats = stats[player.id]!;
        stats[player.id] = currentStats.copyWith(
          pauseRounds: [...currentStats.pauseRounds, round.roundNumber],
        );
      }
    }
    
    return stats;
  }
  
  /// Update player statistics from a single match
  void _updateStatsFromMatch(Match match, Map<String, PlayerStats> stats) {
    final team1Score = match.team1Score!;
    final team2Score = match.team2Score!;
    
    // Get all four players
    final t1p1 = match.team1.player1;
    final t1p2 = match.team1.player2;
    final t2p1 = match.team2.player1;
    final t2p2 = match.team2.player2;
    
    // Update team 1 players
    _updatePlayerFromMatch(stats, t1p1.id, team1Score, t1p2.id, [t2p1.id, t2p2.id]);
    _updatePlayerFromMatch(stats, t1p2.id, team1Score, t1p1.id, [t2p1.id, t2p2.id]);
    
    // Update team 2 players
    _updatePlayerFromMatch(stats, t2p1.id, team2Score, t2p2.id, [t1p1.id, t1p2.id]);
    _updatePlayerFromMatch(stats, t2p2.id, team2Score, t2p1.id, [t1p1.id, t1p2.id]);
  }
  
  /// Update a single player's stats from one match
  void _updatePlayerFromMatch(
    Map<String, PlayerStats> stats,
    String playerId,
    int score,
    String partnerId,
    List<String> opponentIds,
  ) {
    final current = stats[playerId]!;
    
    // Update partner count
    final newPartnerCounts = Map<String, int>.from(current.partnerCounts);
    newPartnerCounts[partnerId] = (newPartnerCounts[partnerId] ?? 0) + 1;
    
    // Update opponent counts
    final newOpponentCounts = Map<String, int>.from(current.opponentCounts);
    for (final opponentId in opponentIds) {
      newOpponentCounts[opponentId] = (newOpponentCounts[opponentId] ?? 0) + 1;
    }
    
    stats[playerId] = current.copyWith(
      totalPoints: current.totalPoints + score,
      gamesPlayed: current.gamesPlayed + 1,
      partnerCounts: newPartnerCounts,
      opponentCounts: newOpponentCounts,
    );
  }
  
  /// Generate optimal pairs from sorted players
  /// Prioritizes: 1) Fewest times played together, 2) Closest in ranking
  List<Team> generateOptimalPairs(
    List<Player> sortedPlayers,
    Map<String, PlayerStats> stats,
  ) {
    final pairs = <Team>[];
    final usedPlayers = <String>{};
    
    // Iterate through players in ranking order
    for (int i = 0; i < sortedPlayers.length; i++) {
      final player1 = sortedPlayers[i];
      
      if (usedPlayers.contains(player1.id)) continue;
      
      // Find best partner for this player
      Player? bestPartner;
      int minPartnerCount = 999;
      int bestRankingDiff = 999;
      
      for (int j = i + 1; j < sortedPlayers.length; j++) {
        final player2 = sortedPlayers[j];
        
        if (usedPlayers.contains(player2.id)) continue;
        
        final partnerCount = stats[player1.id]!.getPartnerCount(player2.id);
        final rankingDiff = (j - i).abs();
        
        // Priority 1: Fewest times played together
        // Priority 2: Closest in ranking
        if (partnerCount < minPartnerCount ||
            (partnerCount == minPartnerCount && rankingDiff < bestRankingDiff)) {
          bestPartner = player2;
          minPartnerCount = partnerCount;
          bestRankingDiff = rankingDiff;
        }
      }
      
      if (bestPartner != null) {
        pairs.add(Team(player1: player1, player2: bestPartner));
        usedPlayers.add(player1.id);
        usedPlayers.add(bestPartner.id);
      }
    }
    
    return pairs;
  }
  
  /// Match pairs to create games
  /// Prioritizes: 1) Fewest opponent encounters, 2) Sequential pairs
  List<Match> matchPairsToGames(
    List<Team> pairs,
    List<Court> courts,
    Map<String, PlayerStats> stats,
  ) {
    final matches = <Match>[];
    final usedPairs = <int>{};
    
    // Match pairs in order
    for (int i = 0; i < pairs.length - 1; i++) {
      if (usedPairs.contains(i)) continue;
      
      final team1 = pairs[i];
      
      // Find best opponent pair
      Team? bestOpponent;
      int bestOpponentIndex = -1;
      int minOpponentCount = 999;
      
      for (int j = i + 1; j < pairs.length; j++) {
        if (usedPairs.contains(j)) continue;
        
        final team2 = pairs[j];
        
        // Count total opponent encounters (all 4 combinations)
        final opponentCount = _countPreviousOpponents(team1, team2, stats);
        
        if (opponentCount < minOpponentCount) {
          bestOpponent = team2;
          bestOpponentIndex = j;
          minOpponentCount = opponentCount;
        }
      }
      
      if (bestOpponent != null && matches.length < courts.length) {
        // Create match with temporary court (will be assigned later)
        matches.add(Match(
          court: courts[0],
          team1: team1,
          team2: bestOpponent,
        ));
        
        usedPairs.add(i);
        usedPairs.add(bestOpponentIndex);
      }
    }
    
    return matches;
  }
  
  /// Count total previous opponent encounters between two teams
  int _countPreviousOpponents(Team team1, Team team2, Map<String, PlayerStats> stats) {
    int count = 0;
    
    // Team 1 player 1 vs Team 2 players
    count += stats[team1.player1.id]!.getOpponentCount(team2.player1.id);
    count += stats[team1.player1.id]!.getOpponentCount(team2.player2.id);
    
    // Team 1 player 2 vs Team 2 players
    count += stats[team1.player2.id]!.getOpponentCount(team2.player1.id);
    count += stats[team1.player2.id]!.getOpponentCount(team2.player2.id);
    
    return count;
  }
  
  /// Sort players by total points (descending)
  List<Player> sortPlayersByPoints(
    List<Player> players,
    Map<String, PlayerStats> stats,
  ) {
    final sortedPlayers = List<Player>.from(players);
    sortedPlayers.sort((a, b) {
      final aPoints = stats[a.id]?.totalPoints ?? 0;
      final bPoints = stats[b.id]?.totalPoints ?? 0;
      return bPoints.compareTo(aPoints); // Descending order
    });
    return sortedPlayers;
  }
}

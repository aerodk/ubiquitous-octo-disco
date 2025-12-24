import '../models/match.dart';
import '../models/tournament.dart';
import '../models/player_standing.dart';
import '../models/player.dart';
import '../models/round.dart';

/// Service for calculating tournament standings and rankings.
/// Implements the hierarchical ranking algorithm from SPECIFICATION_V3.md (F-008).
class StandingsService {
  /// Calculate standings for all players in the tournament.
  /// Returns a list of PlayerStanding objects sorted by rank.
  /// For rounds after the 3rd, includes previousRank for position change tracking.
  List<PlayerStanding> calculateStandings(Tournament tournament) {
    final currentRoundNumber = tournament.rounds.isEmpty ? 0 : tournament.rounds.last.roundNumber;
    
    // Calculate current standings
    final standings = _calculateStandingsForRounds(
      tournament.rounds,
      pausePointsAwarded: tournament.settings.pausePointsAwarded,
    );
    
    // If we have 3+ completed rounds, calculate previous standings for comparison
    Map<String, int>? previousRanks;
    if (currentRoundNumber >= 3 && tournament.completedRounds >= 2) {
      // Calculate standings up to (but not including) the current round
      final previousRounds = tournament.rounds.sublist(0, tournament.rounds.length - 1);
      final previousStandings = _calculateStandingsForRounds(
        previousRounds,
        pausePointsAwarded: tournament.settings.pausePointsAwarded,
      );
      
      // Create map of player ID to previous rank
      previousRanks = {
        for (var standing in previousStandings)
          standing.player.id: standing.rank
      };
    }
    
    // Apply previous ranks if available
    if (previousRanks != null) {
      for (int i = 0; i < standings.length; i++) {
        final prevRank = previousRanks[standings[i].player.id];
        standings[i] = standings[i].copyWithRank(standings[i].rank, previousRank: prevRank);
      }
    }
    
    return standings;
  }
  
  /// Internal method to calculate standings for a specific set of rounds
  List<PlayerStanding> _calculateStandingsForRounds(
    List<Round> rounds, {
    required int pausePointsAwarded,
  }) {
    // Get all players from first round (all rounds have same player set)
    if (rounds.isEmpty) return [];
    
    final allPlayers = <Player>[];
    if (rounds.first.matches.isNotEmpty) {
      for (final match in rounds.first.matches) {
        allPlayers.addAll([
          match.team1.player1,
          match.team1.player2,
          match.team2.player1,
          match.team2.player2,
        ]);
      }
    }
    // Always add players on break, even if there are no matches
    allPlayers.addAll(rounds.first.playersOnBreak);
    
    // Initialize standings for all players
    final standings = <String, PlayerStanding>{};
    for (final player in allPlayers) {
      standings[player.id] = PlayerStanding.initial(player);
    }

    // Calculate statistics from all completed matches and breaks
    for (final round in rounds) {
      // Process completed matches
      for (final match in round.matches.where((m) => m.isCompleted)) {
        _processMatch(match, standings);
      }
      
      // Award points to players on break based on tournament settings (only for completed rounds)
      if (round.isCompleted) {
        for (final player in round.playersOnBreak) {
          // Only award if player is in standings (safety check)
          if (standings.containsKey(player.id)) {
            standings[player.id] = _awardBreakPoints(
              standings[player.id]!,
              pausePointsAwarded,
            );
          }
        }
      }
    }

    // Convert to list and sort by ranking criteria
    final standingsList = standings.values.toList();
    _rankPlayers(standingsList);

    return standingsList;
  }

  /// Process a single match to update player statistics
  void _processMatch(Match match, Map<String, PlayerStanding> standings) {
    final team1Score = match.team1Score!;
    final team2Score = match.team2Score!;

    // Get all four players
    final team1Player1 = match.team1.player1;
    final team1Player2 = match.team1.player2;
    final team2Player1 = match.team2.player1;
    final team2Player2 = match.team2.player2;

    // Update team 1 players
    standings[team1Player1.id] = _updatePlayerStats(
      standings[team1Player1.id]!,
      team1Score,
      team2Score,
      [team2Player1.id, team2Player2.id],
    );
    standings[team1Player2.id] = _updatePlayerStats(
      standings[team1Player2.id]!,
      team1Score,
      team2Score,
      [team2Player1.id, team2Player2.id],
    );

    // Update team 2 players
    standings[team2Player1.id] = _updatePlayerStats(
      standings[team2Player1.id]!,
      team2Score,
      team1Score,
      [team1Player1.id, team1Player2.id],
    );
    standings[team2Player2.id] = _updatePlayerStats(
      standings[team2Player2.id]!,
      team2Score,
      team1Score,
      [team1Player1.id, team1Player2.id],
    );
  }

  /// Award points to a player on break
  /// Returns a new PlayerStanding with updated points and incremented pause count
  /// Note: pauseCount tracks cumulative breaks throughout tournament and never decrements
  PlayerStanding _awardBreakPoints(PlayerStanding standing, int points) {
    return PlayerStanding(
      player: standing.player,
      totalPoints: standing.totalPoints + points,
      wins: standing.wins,
      losses: standing.losses,
      matchesPlayed: standing.matchesPlayed,
      biggestWinMargin: standing.biggestWinMargin,
      smallestLossMargin: standing.smallestLossMargin,
      headToHeadPoints: standing.headToHeadPoints,
      rank: standing.rank,
      pauseCount: standing.pauseCount + 1,
    );
  }

  /// Update statistics for a single player from one match
  /// Returns a new PlayerStanding with updated values
  PlayerStanding _updatePlayerStats(
    PlayerStanding standing,
    int playerScore,
    int opponentScore,
    List<String> opponentIds,
  ) {
    // Calculate new values
    final newTotalPoints = standing.totalPoints + playerScore;
    final newMatchesPlayed = standing.matchesPlayed + 1;
    
    int newWins = standing.wins;
    int newLosses = standing.losses;
    int newBiggestWin = standing.biggestWinMargin;
    int newSmallestLoss = standing.smallestLossMargin;

    if (playerScore > opponentScore) {
      // Win
      newWins++;
      final margin = playerScore - opponentScore;
      if (margin > newBiggestWin) {
        newBiggestWin = margin;
      }
    } else if (playerScore < opponentScore) {
      // Loss
      newLosses++;
      final margin = opponentScore - playerScore;
      if (margin < newSmallestLoss) {
        newSmallestLoss = margin;
      }
    }
    // Note: Ties (playerScore == opponentScore) don't count as wins or losses

    // Update head-to-head records
    // H2H tracks cumulative points scored against each opponent across all matches
    // When players face each other multiple times, all points are summed
    final newH2H = Map<String, int>.from(standing.headToHeadPoints);
    for (final opponentId in opponentIds) {
      newH2H[opponentId] = (newH2H[opponentId] ?? 0) + playerScore;
    }

    // Return new standing with updated values
    return PlayerStanding(
      player: standing.player,
      totalPoints: newTotalPoints,
      wins: newWins,
      losses: newLosses,
      matchesPlayed: newMatchesPlayed,
      biggestWinMargin: newBiggestWin,
      smallestLossMargin: newSmallestLoss,
      headToHeadPoints: newH2H,
      rank: standing.rank,
      pauseCount: standing.pauseCount,
    );
  }

  /// Rank players according to the hierarchical criteria.
  /// Implements the 5-level tiebreaker system from the specification.
  void _rankPlayers(List<PlayerStanding> standings) {
    // Sort by all criteria in priority order
    standings.sort((a, b) {
      // 1. Total Points (primary, higher is better)
      final pointsCompare = b.totalPoints.compareTo(a.totalPoints);
      if (pointsCompare != 0) return pointsCompare;

      // 2. Number of Wins (first tiebreaker, higher is better)
      final winsCompare = b.wins.compareTo(a.wins);
      if (winsCompare != 0) return winsCompare;

      // 3. Head-to-Head (second tiebreaker)
      final h2hCompare = _compareHeadToHead(a, b);
      if (h2hCompare != 0) return h2hCompare;

      // 4. Biggest Win Margin (third tiebreaker, higher is better)
      final biggestWinCompare = b.biggestWinMargin.compareTo(a.biggestWinMargin);
      if (biggestWinCompare != 0) return biggestWinCompare;

      // 5. Smallest Loss Margin (fourth tiebreaker, lower is better)
      // Players with no losses have smallestLossMargin = 999, which is best
      final smallestLossCompare = a.smallestLossMargin.compareTo(b.smallestLossMargin);
      if (smallestLossCompare != 0) return smallestLossCompare;

      // If all criteria are equal, maintain current order (shared rank)
      return 0;
    });

    // Assign ranks, handling shared positions
    int currentRank = 1;
    for (int i = 0; i < standings.length; i++) {
      if (i > 0 && !_areStandingsEqual(standings[i - 1], standings[i])) {
        currentRank = i + 1;
      }
      standings[i] = standings[i].copyWithRank(currentRank);
    }
  }

  /// Compare two players' head-to-head record.
  /// Returns positive if 'a' should rank higher, negative if 'b' should rank higher, 0 if equal or not applicable.
  int _compareHeadToHead(PlayerStanding a, PlayerStanding b) {
    // Get head-to-head points between these two players
    final aPointsVsB = a.headToHeadPoints[b.player.id] ?? 0;
    final bPointsVsA = b.headToHeadPoints[a.player.id] ?? 0;

    // If they never played against each other, H2H doesn't apply
    if (aPointsVsB == 0 && bPointsVsA == 0) {
      return 0;
    }

    // Higher H2H points is better, so b's points vs a compared to a's points vs b
    return aPointsVsB.compareTo(bPointsVsA);
  }

  /// Check if two standings are completely equal in all ranking criteria.
  bool _areStandingsEqual(PlayerStanding a, PlayerStanding b) {
    return a.totalPoints == b.totalPoints &&
        a.wins == b.wins &&
        _compareHeadToHead(a, b) == 0 &&
        a.biggestWinMargin == b.biggestWinMargin &&
        a.smallestLossMargin == b.smallestLossMargin;
  }
}

import 'player.dart';

/// Represents a player's standing in the tournament with all statistics
/// used for ranking and display in the leaderboard.
class PlayerStanding {
  final Player player;
  final int totalPoints;
  final int wins;
  final int losses;
  final int matchesPlayed;
  final int biggestWinMargin;
  final int smallestLossMargin;
  final Map<String, int> headToHeadPoints; // playerId -> points scored against them
  final int rank;
  final int pauseCount; // Number of times player has been on break
  final int? previousRank; // Rank from previous round (null if no previous round)

  PlayerStanding({
    required this.player,
    required this.totalPoints,
    required this.wins,
    required this.losses,
    required this.matchesPlayed,
    required this.biggestWinMargin,
    required this.smallestLossMargin,
    required this.headToHeadPoints,
    this.rank = 0,
    this.pauseCount = 0,
    this.previousRank,
  });

  factory PlayerStanding.initial(Player player) {
    return PlayerStanding(
      player: player,
      totalPoints: 0,
      wins: 0,
      losses: 0,
      matchesPlayed: 0,
      biggestWinMargin: 0,
      smallestLossMargin: 999,
      headToHeadPoints: {},
      rank: 0,
      pauseCount: 0,
      previousRank: null,
    );
  }

  factory PlayerStanding.fromJson(Map<String, dynamic> json) {
    return PlayerStanding(
      player: Player.fromJson(json['player']),
      totalPoints: json['totalPoints'],
      wins: json['wins'],
      losses: json['losses'],
      matchesPlayed: json['matchesPlayed'],
      biggestWinMargin: json['biggestWinMargin'],
      smallestLossMargin: json['smallestLossMargin'],
      headToHeadPoints: Map<String, int>.from(json['headToHeadPoints'] ?? {}),
      rank: json['rank'] ?? 0,
      pauseCount: json['pauseCount'] ?? 0,
      previousRank: json['previousRank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player': player.toJson(),
      'totalPoints': totalPoints,
      'wins': wins,
      'losses': losses,
      'matchesPlayed': matchesPlayed,
      'biggestWinMargin': biggestWinMargin,
      'smallestLossMargin': smallestLossMargin,
      'headToHeadPoints': headToHeadPoints,
      'rank': rank,
      'pauseCount': pauseCount,
      'previousRank': previousRank,
    };
  }

  /// Create a copy with updated rank and optionally previousRank
  PlayerStanding copyWithRank(int newRank, {int? previousRank}) {
    return PlayerStanding(
      player: player,
      totalPoints: totalPoints,
      wins: wins,
      losses: losses,
      matchesPlayed: matchesPlayed,
      biggestWinMargin: biggestWinMargin,
      smallestLossMargin: smallestLossMargin,
      headToHeadPoints: headToHeadPoints,
      rank: newRank,
      pauseCount: pauseCount,
      previousRank: previousRank ?? this.previousRank,
    );
  }
  
  /// Get the rank change from previous round
  /// Returns null if there's no previous rank to compare to
  /// Returns positive number for rank improvement (lower number = better)
  /// Returns negative number for rank decline
  /// Returns 0 for no change
  int? get rankChange {
    if (previousRank == null) return null;
    // Lower rank is better, so previousRank 4 -> rank 2 = +2 improvement
    return previousRank! - rank;
  }
}

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
    };
  }

  /// Create a copy with updated rank
  PlayerStanding copyWithRank(int newRank) {
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
    );
  }
}

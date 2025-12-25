import 'player.dart';

/// Statistics for a player used in Mexicano algorithm
/// Tracks partner/opponent history for strategic pairing
class PlayerStats {
  final Player player;
  final int totalPoints;
  final int gamesPlayed;
  final Map<String, int> partnerCounts;   // playerId -> count
  final Map<String, int> opponentCounts;  // playerId -> count
  final List<int> pauseRounds;
  
  PlayerStats({
    required this.player,
    required this.totalPoints,
    required this.gamesPlayed,
    required this.partnerCounts,
    required this.opponentCounts,
    required this.pauseRounds,
  });
  
  /// Create initial stats for a player with zero history
  factory PlayerStats.initial(Player player) {
    return PlayerStats(
      player: player,
      totalPoints: 0,
      gamesPlayed: 0,
      partnerCounts: {},
      opponentCounts: {},
      pauseRounds: [],
    );
  }
  
  /// Average points per game (0.0 if no games played)
  double get averagePoints => gamesPlayed > 0 ? totalPoints / gamesPlayed : 0.0;
  
  /// Get the number of times this player has partnered with another player
  int getPartnerCount(String playerId) {
    return partnerCounts[playerId] ?? 0;
  }
  
  /// Get the number of times this player has faced another player as opponent
  int getOpponentCount(String playerId) {
    return opponentCounts[playerId] ?? 0;
  }
  
  /// Create a copy with updated values
  PlayerStats copyWith({
    Player? player,
    int? totalPoints,
    int? gamesPlayed,
    Map<String, int>? partnerCounts,
    Map<String, int>? opponentCounts,
    List<int>? pauseRounds,
  }) {
    return PlayerStats(
      player: player ?? this.player,
      totalPoints: totalPoints ?? this.totalPoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      partnerCounts: partnerCounts ?? Map.from(this.partnerCounts),
      opponentCounts: opponentCounts ?? Map.from(this.opponentCounts),
      pauseRounds: pauseRounds ?? List.from(this.pauseRounds),
    );
  }
  
  @override
  String toString() {
    return 'PlayerStats(${player.name}: ${totalPoints}pts, ${gamesPlayed}games, '
           '${partnerCounts.length} partners, ${opponentCounts.length} opponents)';
  }
}

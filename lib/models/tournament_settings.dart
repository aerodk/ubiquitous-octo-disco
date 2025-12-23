/// Pairing strategy for final round matches
/// Defines how top players are paired in the final round
enum PairingStrategy {
  /// Balanced pairing: R1+R3 vs R2+R4
  /// Top 2 face each other with different support players
  /// Most balanced and fair - default strategy
  balanced,

  /// Top Alliance pairing: R1+R2 vs R3+R4
  /// Top 2 players play together
  /// Strongest pair vs next strongest
  topAlliance,

  /// Maximum Competition pairing: R1+R4 vs R2+R3
  /// Top player with weakest in top 4
  /// Most competitively balanced match
  maxCompetition,
}

/// Lane assignment strategy for distributing matches to courts
/// Defines how matches are assigned to lanes/courts based on player rankings
enum LaneAssignmentStrategy {
  /// Sequential assignment: Best ranked players on first lanes
  /// R1+R2+R3+R4 → Lane 1, R5+R6+R7+R8 → Lane 2, etc.
  /// Default strategy - provides predictable court assignments
  sequential,

  /// Random assignment: Randomize lane distribution
  /// Mix best and worst ranked players across lanes
  /// Ensures no preference for specific courts
  random,
}

/// Settings for tournament configuration
/// Controls game rules and behavior
class TournamentSettings {
  /// Minimum number of rounds required before final round can start
  /// Default: 3, Range: 2-10
  final int minRoundsBeforeFinal;

  /// Points required to win a match
  /// Default: 24, Range: 18-32 (even numbers only)
  final int pointsPerMatch;

  /// Strategy for pairing players in final round
  /// Default: balanced (R1+R3 vs R2+R4)
  final PairingStrategy finalRoundStrategy;

  /// Points awarded to players on pause/break
  /// Default: 12, Options: 0 or 12
  final int pausePointsAwarded;

  /// Strategy for assigning matches to lanes/courts
  /// Default: sequential (best players on first lanes)
  final LaneAssignmentStrategy laneAssignmentStrategy;

  const TournamentSettings({
    this.minRoundsBeforeFinal = 3,
    this.pointsPerMatch = 24,
    this.finalRoundStrategy = PairingStrategy.balanced,
    this.pausePointsAwarded = 12,
    this.laneAssignmentStrategy = LaneAssignmentStrategy.sequential,
  });

  /// Create a copy with modified fields
  TournamentSettings copyWith({
    int? minRoundsBeforeFinal,
    int? pointsPerMatch,
    PairingStrategy? finalRoundStrategy,
    int? pausePointsAwarded,
    LaneAssignmentStrategy? laneAssignmentStrategy,
  }) {
    return TournamentSettings(
      minRoundsBeforeFinal: minRoundsBeforeFinal ?? this.minRoundsBeforeFinal,
      pointsPerMatch: pointsPerMatch ?? this.pointsPerMatch,
      finalRoundStrategy: finalRoundStrategy ?? this.finalRoundStrategy,
      pausePointsAwarded: pausePointsAwarded ?? this.pausePointsAwarded,
      laneAssignmentStrategy: laneAssignmentStrategy ?? this.laneAssignmentStrategy,
    );
  }

  /// Check if settings differ from defaults
  bool get isCustomized {
    return pointsPerMatch != 24 ||
        finalRoundStrategy != PairingStrategy.balanced ||
        pausePointsAwarded != 12 ||
        laneAssignmentStrategy != LaneAssignmentStrategy.sequential;
  }

  /// Get a short summary of settings for display
  String get summary {
    final points = '$pointsPerMatch point';
    final strategy = _strategyName(finalRoundStrategy);
    final pausePoints = 'Pause: $pausePointsAwarded pt';
    final laneStrategy = _laneStrategyName(laneAssignmentStrategy);
    return '$points • $strategy • $pausePoints • $laneStrategy';
  }

  String _strategyName(PairingStrategy strategy) {
    switch (strategy) {
      case PairingStrategy.balanced:
        return 'Balanced';
      case PairingStrategy.topAlliance:
        return 'Top Alliance';
      case PairingStrategy.maxCompetition:
        return 'Max Competition';
    }
  }

  String _laneStrategyName(LaneAssignmentStrategy strategy) {
    switch (strategy) {
      case LaneAssignmentStrategy.sequential:
        return 'Sekventiel';
      case LaneAssignmentStrategy.random:
        return 'Tilfældig';
    }
  }

  /// Validate settings are within acceptable ranges
  bool isValid() {
    if (minRoundsBeforeFinal < 2 || minRoundsBeforeFinal > 10) {
      return false;
    }
    if (pointsPerMatch < 18 || pointsPerMatch > 32 || pointsPerMatch % 2 != 0) {
      return false;
    }
    if (pausePointsAwarded != 0 && pausePointsAwarded != 12) {
      return false;
    }
    return true;
  }

  factory TournamentSettings.fromJson(Map<String, dynamic> json) {
    return TournamentSettings(
      minRoundsBeforeFinal: json['minRoundsBeforeFinal'] as int? ?? 3,
      pointsPerMatch: json['pointsPerMatch'] as int? ?? 24,
      finalRoundStrategy: _strategyFromString(
        json['finalRoundStrategy'] as String?,
      ),
      pausePointsAwarded: json['pausePointsAwarded'] as int? ?? 12,
      laneAssignmentStrategy: _laneStrategyFromString(
        json['laneAssignmentStrategy'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minRoundsBeforeFinal': minRoundsBeforeFinal,
      'pointsPerMatch': pointsPerMatch,
      'finalRoundStrategy': _strategyToString(finalRoundStrategy),
      'pausePointsAwarded': pausePointsAwarded,
      'laneAssignmentStrategy': _laneStrategyToString(laneAssignmentStrategy),
    };
  }

  static PairingStrategy _strategyFromString(String? value) {
    switch (value) {
      case 'topAlliance':
        return PairingStrategy.topAlliance;
      case 'maxCompetition':
        return PairingStrategy.maxCompetition;
      case 'balanced':
      default:
        return PairingStrategy.balanced;
    }
  }

  static String _strategyToString(PairingStrategy strategy) {
    switch (strategy) {
      case PairingStrategy.balanced:
        return 'balanced';
      case PairingStrategy.topAlliance:
        return 'topAlliance';
      case PairingStrategy.maxCompetition:
        return 'maxCompetition';
    }
  }

  static LaneAssignmentStrategy _laneStrategyFromString(String? value) {
    switch (value) {
      case 'random':
        return LaneAssignmentStrategy.random;
      case 'sequential':
      default:
        return LaneAssignmentStrategy.sequential;
    }
  }

  static String _laneStrategyToString(LaneAssignmentStrategy strategy) {
    switch (strategy) {
      case LaneAssignmentStrategy.sequential:
        return 'sequential';
      case LaneAssignmentStrategy.random:
        return 'random';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TournamentSettings &&
        other.minRoundsBeforeFinal == minRoundsBeforeFinal &&
        other.pointsPerMatch == pointsPerMatch &&
        other.finalRoundStrategy == finalRoundStrategy &&
        other.pausePointsAwarded == pausePointsAwarded &&
        other.laneAssignmentStrategy == laneAssignmentStrategy;
  }

  @override
  int get hashCode {
    return Object.hash(
      minRoundsBeforeFinal,
      pointsPerMatch,
      finalRoundStrategy,
      pausePointsAwarded,
      laneAssignmentStrategy,
    );
  }
}

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

  const TournamentSettings({
    this.minRoundsBeforeFinal = 3,
    this.pointsPerMatch = 24,
    this.finalRoundStrategy = PairingStrategy.balanced,
  });

  /// Create a copy with modified fields
  TournamentSettings copyWith({
    int? minRoundsBeforeFinal,
    int? pointsPerMatch,
    PairingStrategy? finalRoundStrategy,
  }) {
    return TournamentSettings(
      minRoundsBeforeFinal: minRoundsBeforeFinal ?? this.minRoundsBeforeFinal,
      pointsPerMatch: pointsPerMatch ?? this.pointsPerMatch,
      finalRoundStrategy: finalRoundStrategy ?? this.finalRoundStrategy,
    );
  }

  /// Check if settings differ from defaults
  bool get isCustomized {
    return minRoundsBeforeFinal != 3 ||
        pointsPerMatch != 24 ||
        finalRoundStrategy != PairingStrategy.balanced;
  }

  /// Get a short summary of settings for display
  String get summary {
    final rounds = '$minRoundsBeforeFinal runder';
    final points = '$pointsPerMatch point';
    final strategy = _strategyName(finalRoundStrategy);
    return '$rounds • $points • $strategy';
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

  /// Validate settings are within acceptable ranges
  bool isValid() {
    if (minRoundsBeforeFinal < 2 || minRoundsBeforeFinal > 10) {
      return false;
    }
    if (pointsPerMatch < 18 || pointsPerMatch > 32 || pointsPerMatch % 2 != 0) {
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minRoundsBeforeFinal': minRoundsBeforeFinal,
      'pointsPerMatch': pointsPerMatch,
      'finalRoundStrategy': _strategyToString(finalRoundStrategy),
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TournamentSettings &&
        other.minRoundsBeforeFinal == minRoundsBeforeFinal &&
        other.pointsPerMatch == pointsPerMatch &&
        other.finalRoundStrategy == finalRoundStrategy;
  }

  @override
  int get hashCode {
    return Object.hash(
      minRoundsBeforeFinal,
      pointsPerMatch,
      finalRoundStrategy,
    );
  }
}

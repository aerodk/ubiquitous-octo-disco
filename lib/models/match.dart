import 'player.dart';
import 'court.dart';

class Team {
  final Player player1;
  final Player player2;

  Team({required this.player1, required this.player2});

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        player1: Player.fromJson(json['player1']),
        player2: Player.fromJson(json['player2']),
      );

  Map<String, dynamic> toJson() => {
        'player1': player1.toJson(),
        'player2': player2.toJson(),
      };
}

/// Holds reasoning information about why a match was created
class MatchupReasoning {
  final String roundType; // 'first', 'regular', 'final'
  final String pairingMethod; // Description of how players were paired
  final String laneAssignment; // Description of lane assignment logic
  final Map<String, dynamic>? playerMetadata; // Additional player-specific info (ranks, pause counts, etc.)

  MatchupReasoning({
    required this.roundType,
    required this.pairingMethod,
    required this.laneAssignment,
    this.playerMetadata,
  });

  factory MatchupReasoning.fromJson(Map<String, dynamic> json) => MatchupReasoning(
        roundType: json['roundType'] ?? 'unknown',
        pairingMethod: json['pairingMethod'] ?? '',
        laneAssignment: json['laneAssignment'] ?? '',
        playerMetadata: json['playerMetadata'] != null
            ? Map<String, dynamic>.from(json['playerMetadata'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'roundType': roundType,
        'pairingMethod': pairingMethod,
        'laneAssignment': laneAssignment,
        'playerMetadata': playerMetadata,
      };
}

class Match {
  final String id;
  final Court court;
  final Team team1;
  final Team team2;
  int? team1Score;
  int? team2Score;
  final MatchupReasoning? reasoning;

  Match({
    String? id,
    required this.court,
    required this.team1,
    required this.team2,
    this.team1Score,
    this.team2Score,
    this.reasoning,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get isCompleted => team1Score != null && team2Score != null;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'],
        court: Court.fromJson(json['court']),
        team1: Team.fromJson(json['team1']),
        team2: Team.fromJson(json['team2']),
        team1Score: json['team1Score'],
        team2Score: json['team2Score'],
        reasoning: json['reasoning'] != null
            ? MatchupReasoning.fromJson(json['reasoning'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'court': court.toJson(),
        'team1': team1.toJson(),
        'team2': team2.toJson(),
        'team1Score': team1Score,
        'team2Score': team2Score,
        'reasoning': reasoning?.toJson(),
      };
}

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

class Match {
  final String id;
  final Court court;
  final Team team1;
  final Team team2;
  int? team1Score;
  int? team2Score;

  Match({
    String? id,
    required this.court,
    required this.team1,
    required this.team2,
    this.team1Score,
    this.team2Score,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get isCompleted => team1Score != null && team2Score != null;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'],
        court: Court.fromJson(json['court']),
        team1: Team.fromJson(json['team1']),
        team2: Team.fromJson(json['team2']),
        team1Score: json['team1Score'],
        team2Score: json['team2Score'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'court': court.toJson(),
        'team1': team1.toJson(),
        'team2': team2.toJson(),
        'team1Score': team1Score,
        'team2Score': team2Score,
      };
}

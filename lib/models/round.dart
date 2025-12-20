import 'match.dart';
import 'player.dart';

class Round {
  final int roundNumber;
  final List<Match> matches;
  final List<Player> playersOnBreak;
  final bool isFinalRound;

  Round({
    required this.roundNumber,
    required this.matches,
    required this.playersOnBreak,
    this.isFinalRound = false,
  });

  bool get isCompleted => matches.every((m) => m.isCompleted);

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        roundNumber: json['roundNumber'],
        matches: (json['matches'] as List).map((m) => Match.fromJson(m)).toList(),
        playersOnBreak: (json['playersOnBreak'] as List)
            .map((p) => Player.fromJson(p))
            .toList(),
        isFinalRound: json['isFinalRound'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'roundNumber': roundNumber,
        'matches': matches.map((m) => m.toJson()).toList(),
        'playersOnBreak': playersOnBreak.map((p) => p.toJson()).toList(),
        'isFinalRound': isFinalRound,
      };
}

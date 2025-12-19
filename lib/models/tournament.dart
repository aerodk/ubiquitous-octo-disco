import 'player.dart';
import 'court.dart';
import 'round.dart';

class Tournament {
  final String id;
  final String name;
  final List<Player> players;
  final List<Court> courts;
  final List<Round> rounds;
  final DateTime createdAt;

  Tournament({
    String? id,
    required this.name,
    required this.players,
    required this.courts,
    List<Round>? rounds,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        rounds = rounds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Round? get currentRound => rounds.isEmpty ? null : rounds.last;

  int get completedRounds => rounds.where((r) => r.isCompleted).length;

  /// Create a copy of this tournament with updated fields
  Tournament copyWith({
    String? id,
    String? name,
    List<Player>? players,
    List<Court>? courts,
    List<Round>? rounds,
    DateTime? createdAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
      courts: courts ?? this.courts,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
        id: json['id'],
        name: json['name'],
        players: (json['players'] as List)
            .map((p) => Player.fromJson(p))
            .toList(),
        courts:
            (json['courts'] as List).map((c) => Court.fromJson(c)).toList(),
        rounds: json['rounds'] != null
            ? (json['rounds'] as List).map((r) => Round.fromJson(r)).toList()
            : null,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'players': players.map((p) => p.toJson()).toList(),
        'courts': courts.map((c) => c.toJson()).toList(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };
}

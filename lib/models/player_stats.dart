import '../models/player.dart';

class PlayerStats {
  final Player player;
  int totalPoints;
  int gamesPlayed;
  Map<Player, int> partners;
  Map<Player, int> opponents;
  List<int> pauseRounds;

  PlayerStats({
    required this.player,
    required this.totalPoints,
    required this.gamesPlayed,
    required this.partners,
    required this.opponents,
    required this.pauseRounds,
  });

  double get averagePoints => gamesPlayed > 0 ? totalPoints / gamesPlayed : 0;
}

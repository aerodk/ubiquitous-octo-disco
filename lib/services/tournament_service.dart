import '../models/player.dart';
import '../models/court.dart';
import '../models/match.dart';
import '../models/round.dart';
import 'americano_algorithm.dart';

class TournamentService {
  final AmericanoAlgorithm _americanoAlgorithm = AmericanoAlgorithm();

  Round generateFirstRound(List<Player> players, List<Court> courts) {
    // Shuffle players randomly
    final shuffledPlayers = List<Player>.from(players)..shuffle();

    final matches = <Match>[];
    final playersOnBreak = <Player>[];

    int playerIndex = 0;
    for (int i = 0;
        i < courts.length && playerIndex + 3 < shuffledPlayers.length;
        i++) {
      final match = Match(
        court: courts[i],
        team1: Team(
          player1: shuffledPlayers[playerIndex],
          player2: shuffledPlayers[playerIndex + 1],
        ),
        team2: Team(
          player1: shuffledPlayers[playerIndex + 2],
          player2: shuffledPlayers[playerIndex + 3],
        ),
      );
      matches.add(match);
      playerIndex += 4;
    }

    // Remaining players on break
    while (playerIndex < shuffledPlayers.length) {
      playersOnBreak.add(shuffledPlayers[playerIndex]);
      playerIndex++;
    }

    return Round(
      roundNumber: 1,
      matches: matches,
      playersOnBreak: playersOnBreak,
    );
  }

  Round generateNextRound({
    required List<Player> players,
    required List<Court> courts,
    required List<Round> previousRounds,
  }) {
    final nextRoundNumber = previousRounds.length + 1;
    return _americanoAlgorithm.generateNextRound(
      players: players,
      courts: courts,
      previousRounds: previousRounds,
      roundNumber: nextRoundNumber,
    );
  }
}

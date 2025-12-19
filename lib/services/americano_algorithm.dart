import '../models/player.dart';
import '../models/court.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/player_stats.dart';

class AmericanoAlgorithm {
  // Constants for algorithm optimization
  static const int _maxPartnerCount = 999;
  static const int _maxOpponentCount = 999;
  static const int _maxRankingDiff = 999;

  Round generateNextRound({
    required List<Player> players,
    required List<Court> courts,
    required List<Round> previousRounds,
    required int roundNumber,
  }) {
    // TRIN 1: Beregn spillernes totale point
    final playerStats = _calculatePlayerStats(players, previousRounds);

    // TRIN 2: Sortér spillere efter point (højeste først)
    final sortedPlayers = playerStats.entries
        .map((e) => e.key)
        .toList()
      ..sort((a, b) => playerStats[b]!.totalPoints.compareTo(playerStats[a]!.totalPoints));

    // TRIN 3: Generer par baseret på ranking og historik
    final pairs = _generateOptimalPairs(sortedPlayers, playerStats);

    // TRIN 4: Match par mod hinanden (nærmeste i ranking)
    final matches = _matchPairsToGames(pairs, courts, playerStats);

    // TRIN 5: Identificer spillere på pause
    final playersOnBreak = _getPlayersOnBreak(sortedPlayers, matches);

    return Round(
      roundNumber: roundNumber,
      matches: matches,
      playersOnBreak: playersOnBreak,
    );
  }

  // TRIN 1: Stats beregning
  Map<Player, PlayerStats> _calculatePlayerStats(
    List<Player> players,
    List<Round> previousRounds,
  ) {
    final stats = <Player, PlayerStats>{};

    for (final player in players) {
      stats[player] = PlayerStats(
        player: player,
        totalPoints: 0,
        gamesPlayed: 0,
        partners: {},
        opponents: {},
        pauseRounds: [],
      );
    }

    for (final round in previousRounds) {
      // Opdater points fra kampe
      for (final match in round.matches) {
        if (match.isCompleted) {
          _updateStatsFromMatch(match, stats);
        }
      }

      // Track pause-runder
      for (final player in round.playersOnBreak) {
        stats[player]!.pauseRounds.add(round.roundNumber);
      }
    }

    return stats;
  }

  void _updateStatsFromMatch(Match match, Map<Player, PlayerStats> stats) {
    // Defensive null checks
    if (match.team1Score == null || match.team2Score == null) {
      return;
    }

    // Team 1 spillere
    final t1p1 = match.team1.player1;
    final t1p2 = match.team1.player2;

    // Team 2 spillere
    final t2p1 = match.team2.player1;
    final t2p2 = match.team2.player2;

    // Opdater points
    stats[t1p1]!.totalPoints += match.team1Score!;
    stats[t1p2]!.totalPoints += match.team1Score!;
    stats[t2p1]!.totalPoints += match.team2Score!;
    stats[t2p2]!.totalPoints += match.team2Score!;

    // Opdater games played
    stats[t1p1]!.gamesPlayed++;
    stats[t1p2]!.gamesPlayed++;
    stats[t2p1]!.gamesPlayed++;
    stats[t2p2]!.gamesPlayed++;

    // Track partnere
    stats[t1p1]!.partners[t1p2] = (stats[t1p1]!.partners[t1p2] ?? 0) + 1;
    stats[t1p2]!.partners[t1p1] = (stats[t1p2]!.partners[t1p1] ?? 0) + 1;
    stats[t2p1]!.partners[t2p2] = (stats[t2p1]!.partners[t2p2] ?? 0) + 1;
    stats[t2p2]!.partners[t2p1] = (stats[t2p2]!.partners[t2p1] ?? 0) + 1;

    // Track modstandere
    stats[t1p1]!.opponents[t2p1] = (stats[t1p1]!.opponents[t2p1] ?? 0) + 1;
    stats[t1p1]!.opponents[t2p2] = (stats[t1p1]!.opponents[t2p2] ?? 0) + 1;
    stats[t1p2]!.opponents[t2p1] = (stats[t1p2]!.opponents[t2p1] ?? 0) + 1;
    stats[t1p2]!.opponents[t2p2] = (stats[t1p2]!.opponents[t2p2] ?? 0) + 1;
    stats[t2p1]!.opponents[t1p1] = (stats[t2p1]!.opponents[t1p1] ?? 0) + 1;
    stats[t2p1]!.opponents[t1p2] = (stats[t2p1]!.opponents[t1p2] ?? 0) + 1;
    stats[t2p2]!.opponents[t1p1] = (stats[t2p2]!.opponents[t1p1] ?? 0) + 1;
    stats[t2p2]!.opponents[t1p2] = (stats[t2p2]!.opponents[t1p2] ?? 0) + 1;
  }

  // TRIN 3: Generér optimale par
  List<Team> _generateOptimalPairs(
    List<Player> sortedPlayers,
    Map<Player, PlayerStats> stats,
  ) {
    final pairs = <Team>[];
    final usedPlayers = <Player>{};

    // Prøv at parre spillere som ikke har spillet sammen før
    // eller som har spillet mindst sammen
    for (int i = 0; i < sortedPlayers.length && pairs.length < sortedPlayers.length / 2; i++) {
      final player1 = sortedPlayers[i];

      if (usedPlayers.contains(player1)) continue;

      // Find bedste partner for denne spiller
      Player? bestPartner;
      int minPartnerCount = _maxPartnerCount;
      int bestRankingDiff = _maxRankingDiff;

      for (int j = i + 1; j < sortedPlayers.length; j++) {
        final player2 = sortedPlayers[j];

        if (usedPlayers.contains(player2)) continue;

        final partnerCount = stats[player1]!.partners[player2] ?? 0;
        final rankingDiff = (j - i).abs();

        // Prioritér spillere der ikke har spillet sammen
        // Sekundært: vælg spillere tæt i ranking
        if (partnerCount < minPartnerCount ||
            (partnerCount == minPartnerCount && rankingDiff < bestRankingDiff)) {
          bestPartner = player2;
          minPartnerCount = partnerCount;
          bestRankingDiff = rankingDiff;
        }
      }

      if (bestPartner != null) {
        pairs.add(Team(player1: player1, player2: bestPartner));
        usedPlayers.add(player1);
        usedPlayers.add(bestPartner);
      }
    }

    return pairs;
  }

  // TRIN 4: Match par til kampe
  List<Match> _matchPairsToGames(
    List<Team> pairs,
    List<Court> courts,
    Map<Player, PlayerStats> stats,
  ) {
    final matches = <Match>[];
    final usedPairs = <Team>{};

    int courtIndex = 0;

    // Match par mod hinanden (tæt i ranking)
    for (int i = 0; i < pairs.length - 1 && courtIndex < courts.length; i++) {
      final team1 = pairs[i];

      if (usedPairs.contains(team1)) continue;

      // Find bedste modstander
      Team? bestOpponent;
      int minOpponentCount = _maxOpponentCount;

      for (int j = i + 1; j < pairs.length; j++) {
        final team2 = pairs[j];

        if (usedPairs.contains(team2)) continue;

        // Beregn hvor mange gange disse spillere har mødt hinanden
        final opponentCount = _countPreviousOpponents(team1, team2, stats);

        if (opponentCount < minOpponentCount) {
          bestOpponent = team2;
          minOpponentCount = opponentCount;
        }
      }

      if (bestOpponent != null) {
        matches.add(Match(
          court: courts[courtIndex],
          team1: team1,
          team2: bestOpponent,
        ));

        usedPairs.add(team1);
        usedPairs.add(bestOpponent);
        courtIndex++;
      }
    }

    return matches;
  }

  int _countPreviousOpponents(Team team1, Team team2, Map<Player, PlayerStats> stats) {
    int count = 0;
    count += stats[team1.player1]!.opponents[team2.player1] ?? 0;
    count += stats[team1.player1]!.opponents[team2.player2] ?? 0;
    count += stats[team1.player2]!.opponents[team2.player1] ?? 0;
    count += stats[team1.player2]!.opponents[team2.player2] ?? 0;
    return count;
  }

  // TRIN 5: Identificer pause-spillere
  List<Player> _getPlayersOnBreak(List<Player> sortedPlayers, List<Match> matches) {
    final playingPlayers = <Player>{};

    for (final match in matches) {
      playingPlayers.add(match.team1.player1);
      playingPlayers.add(match.team1.player2);
      playingPlayers.add(match.team2.player1);
      playingPlayers.add(match.team2.player2);
    }

    return sortedPlayers.where((p) => !playingPlayers.contains(p)).toList();
  }
}

import '../models/player.dart';
import '../models/court.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/player_standing.dart';
import '../models/tournament_settings.dart';

class TournamentService {
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

  /// Generates a regular round (non-final) with pause fairness
  /// Avoids consecutive pauses and distributes breaks fairly
  /// Takes standings to track pause history and ensure fair distribution
  Round generateNextRound(
    List<Player> players,
    List<Court> courts,
    List<PlayerStanding> standings,
    int roundNumber,
  ) {
    // Shuffle players randomly for match creation
    final shuffledPlayers = List<Player>.from(players)..shuffle();

    final totalPlayers = players.length;
    final playersNeeded = (totalPlayers ~/ 4) * 4;
    final overflowCount = totalPlayers - playersNeeded;

    // Select players for break using pause fairness logic
    final playersOnBreak = <Player>[];
    if (overflowCount > 0) {
      playersOnBreak.addAll(_selectBreakPlayersWithFairness(
        players,
        standings,
        overflowCount,
      ));
    }

    // Get active players (those not on break)
    final activePlayers = shuffledPlayers
        .where((p) => !playersOnBreak.any((bp) => bp.id == p.id))
        .toList();

    // Generate matches
    final matches = <Match>[];
    int playerIndex = 0;
    for (int i = 0;
        i < courts.length && playerIndex + 3 < activePlayers.length;
        i++) {
      final match = Match(
        court: courts[i],
        team1: Team(
          player1: activePlayers[playerIndex],
          player2: activePlayers[playerIndex + 1],
        ),
        team2: Team(
          player1: activePlayers[playerIndex + 2],
          player2: activePlayers[playerIndex + 3],
        ),
      );
      matches.add(match);
      playerIndex += 4;
    }

    return Round(
      roundNumber: roundNumber,
      matches: matches,
      playersOnBreak: playersOnBreak,
    );
  }

  /// Select players for break with fairness considerations
  /// Prioritizes: 1) Fewest pauses, 2) Most games played, 3) Random
  List<Player> _selectBreakPlayersWithFairness(
    List<Player> allPlayers,
    List<PlayerStanding> standings,
    int count,
  ) {
    // Create a map for easy lookup
    final standingsMap = {for (var s in standings) s.player.id: s};
    
    // Create a list of players with their standings for sorting
    final playersWithStandings = allPlayers
        .map((p) => standingsMap[p.id])
        .where((s) => s != null)
        .cast<PlayerStanding>()
        .toList();

    // Sort by pause fairness priority
    playersWithStandings.sort(_compareForPauseFairness);

    // Select the first 'count' players
    return playersWithStandings
        .take(count)
        .map((s) => s.player)
        .toList();
  }

  /// Compare two standings for pause fairness
  /// Returns positive if 'a' should break before 'b'
  /// Prioritizes: 1) Fewest pauses (ascending), 2) Most games played (descending)
  int _compareForPauseFairness(PlayerStanding a, PlayerStanding b) {
    // 1. Fewest pauses first (ascending) - players who haven't had breaks go first
    final pauseCompare = a.pauseCount.compareTo(b.pauseCount);
    if (pauseCompare != 0) return pauseCompare;

    // 2. Most games played (descending) - among those with same pause count, 
    //    prioritize those who have played more
    final gamesCompare = b.matchesPlayed.compareTo(a.matchesPlayed);
    if (gamesCompare != 0) return gamesCompare;

    // 3. If still equal, maintain current order (effectively random after shuffle)
    return 0;
  }

  /// Generates the final round using rank-based pairing (F-011, F-017)
  /// Supports multiple pairing strategies:
  /// - Balanced: R1+R3 vs R2+R4 (default)
  /// - Top Alliance: R1+R2 vs R3+R4
  /// - Max Competition: R1+R4 vs R2+R3
  /// Uses rolling pause system for overflow players
  Round generateFinalRound(
    List<Court> courts,
    List<PlayerStanding> standings,
    int roundNumber, {
    PairingStrategy strategy = PairingStrategy.balanced,
  }) {
    // Sort standings by rank (should already be sorted)
    final rankedStandings = List<PlayerStanding>.from(standings)
      ..sort((a, b) => a.rank.compareTo(b.rank));

    final totalPlayers = rankedStandings.length;
    final playersNeeded = (totalPlayers ~/ 4) * 4; // Round down to nearest multiple of 4
    final overflowCount = totalPlayers - playersNeeded;

    // Select players who will sit out using rolling pause system
    final playersOnBreak = <Player>[];
    if (overflowCount > 0) {
      playersOnBreak.addAll(_selectBreakPlayers(rankedStandings, overflowCount));
    }

    // Get active players (those not on break)
    final activePlayers = rankedStandings
        .where((s) => !playersOnBreak.any((p) => p.id == s.player.id))
        .map((s) => s.player)
        .toList();

    // Generate matches using selected pairing strategy
    final matches = <Match>[];
    final availableCourts = List<Court>.from(courts);

    for (int i = 0; i < activePlayers.length; i += 4) {
      if (i + 3 < activePlayers.length) {
        final courtIndex = i ~/ 4;
        final court = courtIndex < availableCourts.length
            ? availableCourts[courtIndex]
            : availableCourts.last;

        // Create match based on pairing strategy
        final match = _createMatchWithStrategy(
          activePlayers,
          i,
          court,
          strategy,
        );
        matches.add(match);
      }
    }

    return Round(
      roundNumber: roundNumber,
      matches: matches,
      playersOnBreak: playersOnBreak,
      isFinalRound: true,
    );
  }

  /// Creates a match using the specified pairing strategy
  Match _createMatchWithStrategy(
    List<Player> players,
    int startIndex,
    Court court,
    PairingStrategy strategy,
  ) {
    switch (strategy) {
      case PairingStrategy.balanced:
        // R1+R3 vs R2+R4 pattern (default, most balanced)
        return Match(
          court: court,
          team1: Team(
            player1: players[startIndex],     // R1, R5, R9, ...
            player2: players[startIndex + 2], // R3, R7, R11, ...
          ),
          team2: Team(
            player1: players[startIndex + 1], // R2, R6, R10, ...
            player2: players[startIndex + 3], // R4, R8, R12, ...
          ),
        );

      case PairingStrategy.topAlliance:
        // R1+R2 vs R3+R4 pattern (top players together)
        return Match(
          court: court,
          team1: Team(
            player1: players[startIndex],     // R1, R5, R9, ...
            player2: players[startIndex + 1], // R2, R6, R10, ...
          ),
          team2: Team(
            player1: players[startIndex + 2], // R3, R7, R11, ...
            player2: players[startIndex + 3], // R4, R8, R12, ...
          ),
        );

      case PairingStrategy.maxCompetition:
        // R1+R4 vs R2+R3 pattern (most competitive balance)
        return Match(
          court: court,
          team1: Team(
            player1: players[startIndex],     // R1, R5, R9, ...
            player2: players[startIndex + 3], // R4, R8, R12, ...
          ),
          team2: Team(
            player1: players[startIndex + 1], // R2, R6, R10, ...
            player2: players[startIndex + 2], // R3, R7, R11, ...
          ),
        );
    }
  }

  /// Selects players to sit out using rolling pause prioritization
  /// Prioritizes: 1) Most games played (in bottom half), 2) Lowest rank, 3) Fewest pauses
  List<Player> _selectBreakPlayers(
    List<PlayerStanding> standings,
    int count,
  ) {
    final totalPlayers = standings.length;
    final topHalfSize = (totalPlayers / 2).ceil();

    // Split into top and bottom half
    final topHalf = standings.sublist(0, topHalfSize);
    final bottomHalf = standings.sublist(topHalfSize);

    final breakPlayers = <Player>[];

    // Always seat out the lowest-ranked player first to satisfy rolling pause fairness
    if (count > 0 && bottomHalf.isNotEmpty) {
      breakPlayers.add(bottomHalf.last.player);
    }

    // Select remaining seats (if any) favoring bottom-half players with most games, then worst rank
    if (breakPlayers.length < count) {
      final remainingBottom = bottomHalf
          .where((s) => !breakPlayers.any((p) => p.id == s.player.id))
          .toList()
        ..sort(_compareForBreakPriority);

      for (final s in remainingBottom) {
        if (breakPlayers.length >= count) break;
        breakPlayers.add(s.player);
      }
    }

    // If we still need more players (edge case), take from top half using same priority
    if (breakPlayers.length < count) {
      final topHalfSorted = List<PlayerStanding>.from(topHalf)
        ..sort(_compareForBreakPriority);

      for (final s in topHalfSorted) {
        if (breakPlayers.length >= count) break;
        breakPlayers.add(s.player);
      }
    }

    return breakPlayers;
  }

  /// Compare two standings for break prioritization
  /// Returns positive if 'a' should break before 'b'
  /// Prioritizes: 1) Most games played, 2) Lowest rank, 3) Fewest pauses
  int _compareForBreakPriority(PlayerStanding a, PlayerStanding b) {
    // 1. Most games played first (descending)
    final gamesCompare = b.matchesPlayed.compareTo(a.matchesPlayed);
    if (gamesCompare != 0) return gamesCompare;

    // 2. Lowest rank (already in order, but higher rank value = lower position)
    final rankCompare = b.rank.compareTo(a.rank);
    if (rankCompare != 0) return rankCompare;

    // 3. Fewest pauses (ascending)
    return a.pauseCount.compareTo(b.pauseCount);
  }
}

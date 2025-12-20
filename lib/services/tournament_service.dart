import '../models/player.dart';
import '../models/court.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/player_standing.dart';

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

  /// Generates the final round using rank-based pairing (F-011)
  /// Pattern: R1+R3 vs R2+R4, R5+R7 vs R6+R8, etc.
  /// Uses rolling pause system for overflow players
  Round generateFinalRound(
    List<Court> courts,
    List<PlayerStanding> standings,
    int roundNumber,
  ) {
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

    // Generate matches using R1+R3 vs R2+R4 pattern
    final matches = <Match>[];
    final availableCourts = List<Court>.from(courts);

    for (int i = 0; i < activePlayers.length; i += 4) {
      if (i + 3 < activePlayers.length) {
        // Create match with R(i)+R(i+2) vs R(i+1)+R(i+3) pattern
        final courtIndex = i ~/ 4;
        final court = courtIndex < availableCourts.length
            ? availableCourts[courtIndex]
            : availableCourts.last;

        final match = Match(
          court: court,
          team1: Team(
            player1: activePlayers[i],     // R1, R5, R9, ...
            player2: activePlayers[i + 2], // R3, R7, R11, ...
          ),
          team2: Team(
            player1: activePlayers[i + 1], // R2, R6, R10, ...
            player2: activePlayers[i + 3], // R4, R8, R12, ...
          ),
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

    // Sort bottom half by break priority
    final bottomHalfSorted = List<PlayerStanding>.from(bottomHalf)
      ..sort((a, b) {
        // 1. Most games played first (descending)
        final gamesCompare = b.matchesPlayed.compareTo(a.matchesPlayed);
        if (gamesCompare != 0) return gamesCompare;

        // 2. Lowest rank (already in order, but higher rank value = lower position)
        final rankCompare = b.rank.compareTo(a.rank);
        if (rankCompare != 0) return rankCompare;

        // 3. Fewest pauses (ascending)
        return a.pauseCount.compareTo(b.pauseCount);
      });

    final breakPlayers = <Player>[];

    // Select from bottom half first
    for (int i = 0; i < count && i < bottomHalfSorted.length; i++) {
      breakPlayers.add(bottomHalfSorted[i].player);
    }

    // If we still need more players (edge case), take from top half
    if (breakPlayers.length < count) {
      final topHalfSorted = List<PlayerStanding>.from(topHalf)
        ..sort((a, b) {
          // Same prioritization for top half if needed
          final gamesCompare = b.matchesPlayed.compareTo(a.matchesPlayed);
          if (gamesCompare != 0) return gamesCompare;
          final rankCompare = b.rank.compareTo(a.rank);
          if (rankCompare != 0) return rankCompare;
          return a.pauseCount.compareTo(b.pauseCount);
        });

      for (int i = 0;
          i < topHalfSorted.length && breakPlayers.length < count;
          i++) {
        breakPlayers.add(topHalfSorted[i].player);
      }
    }

    return breakPlayers;
  }
}

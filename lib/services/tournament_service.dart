import '../models/player.dart';
import '../models/court.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/player_standing.dart';
import '../models/tournament_settings.dart';

class TournamentService {
  /// Assigns courts to matches based on the lane assignment strategy
  /// Sequential: Best players on first lanes (default)
  /// Random: Randomize lane assignments
  List<Match> _assignCourtsToMatches(
    List<Match> matches,
    List<Court> courts,
    LaneAssignmentStrategy strategy,
  ) {
    if (matches.isEmpty || courts.isEmpty) return matches;

    final assignedMatches = <Match>[];
    
    switch (strategy) {
      case LaneAssignmentStrategy.sequential:
        // Sequential: assign courts in order (first match → first court, etc.)
        for (int i = 0; i < matches.length; i++) {
          final courtIndex = i % courts.length;
          assignedMatches.add(Match(
            id: matches[i].id,
            court: courts[courtIndex],
            team1: matches[i].team1,
            team2: matches[i].team2,
            team1Score: matches[i].team1Score,
            team2Score: matches[i].team2Score,
          ));
        }
        break;
        
      case LaneAssignmentStrategy.random:
        // Random: shuffle courts and assign randomly
        final shuffledCourts = List<Court>.from(courts)..shuffle();
        for (int i = 0; i < matches.length; i++) {
          final courtIndex = i % shuffledCourts.length;
          assignedMatches.add(Match(
            id: matches[i].id,
            court: shuffledCourts[courtIndex],
            team1: matches[i].team1,
            team2: matches[i].team2,
            team1Score: matches[i].team1Score,
            team2Score: matches[i].team2Score,
          ));
        }
        break;
    }
    
    return assignedMatches;
  }

  Round generateFirstRound(
    List<Player> players,
    List<Court> courts, {
    LaneAssignmentStrategy laneStrategy = LaneAssignmentStrategy.sequential,
  }) {
    // Shuffle players randomly
    final shuffledPlayers = List<Player>.from(players)..shuffle();

    final tempMatches = <Match>[];
    final playersOnBreak = <Player>[];

    int playerIndex = 0;
    // Create temporary matches without court assignments
    while (playerIndex + 3 < shuffledPlayers.length && 
           tempMatches.length < courts.length) {
      final match = Match(
        court: courts[0], // Temporary court assignment
        team1: Team(
          player1: shuffledPlayers[playerIndex],
          player2: shuffledPlayers[playerIndex + 1],
        ),
        team2: Team(
          player1: shuffledPlayers[playerIndex + 2],
          player2: shuffledPlayers[playerIndex + 3],
        ),
      );
      tempMatches.add(match);
      playerIndex += 4;
    }

    // Remaining players on break
    while (playerIndex < shuffledPlayers.length) {
      playersOnBreak.add(shuffledPlayers[playerIndex]);
      playerIndex++;
    }

    // Apply lane assignment strategy
    final matches = _assignCourtsToMatches(tempMatches, courts, laneStrategy);

    return Round(
      roundNumber: 1,
      matches: matches,
      playersOnBreak: playersOnBreak,
    );
  }

  /// Beregn hvor mange spillere der skal på pause ud fra banekapacitet og hele hold (4)
  int _computeOverflowCount(int totalPlayers, int courtCount) {
    final capacity = courtCount * 4;
    final playableByCount = (totalPlayers ~/ 4) * 4; // nærmeste nedre multiplum af 4
    final playable = capacity < playableByCount ? capacity : playableByCount;
    return totalPlayers - playable;
  }

  /// Generates a regular round (non-final) with pause fairness
  /// Avoids consecutive pauses and distributes breaks fairly
  /// Takes standings to track pause history and ensure fair distribution
  Round generateNextRound(
    List<Player> players,
    List<Court> courts,
    List<PlayerStanding> standings,
    int roundNumber, {
    LaneAssignmentStrategy laneStrategy = LaneAssignmentStrategy.sequential,
  }) {
    // Shuffle players randomly for match creation
    final shuffledPlayers = List<Player>.from(players)..shuffle();

    final totalPlayers = players.length;
    final overflowCount = _computeOverflowCount(totalPlayers, courts.length);

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

    // Generate temporary matches without court assignments
    final tempMatches = <Match>[];
    int playerIndex = 0;
    while (playerIndex + 3 < activePlayers.length && 
           tempMatches.length < courts.length) {
      final match = Match(
        court: courts[0], // Temporary court assignment
        team1: Team(
          player1: activePlayers[playerIndex],
          player2: activePlayers[playerIndex + 1],
        ),
        team2: Team(
          player1: activePlayers[playerIndex + 2],
          player2: activePlayers[playerIndex + 3],
        ),
      );
      tempMatches.add(match);
      playerIndex += 4;
    }

    // Apply lane assignment strategy
    final matches = _assignCourtsToMatches(tempMatches, courts, laneStrategy);

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
    LaneAssignmentStrategy laneStrategy = LaneAssignmentStrategy.sequential,
  }) {
    // Sort standings by rank (should already be sorted)
    final rankedStandings = List<PlayerStanding>.from(standings)
      ..sort((a, b) => a.rank.compareTo(b.rank));

    final totalPlayers = rankedStandings.length;
    final overflowCount = _computeOverflowCount(totalPlayers, courts.length);

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

    // Generate temporary matches using selected pairing strategy
    final tempMatches = <Match>[];

    for (int i = 0; i < activePlayers.length; i += 4) {
      if (i + 3 < activePlayers.length) {
        // Create match based on pairing strategy with temporary court
        final match = _createMatchWithStrategy(
          activePlayers,
          i,
          courts[0], // Temporary court
          strategy,
        );
        tempMatches.add(match);
      }
    }

    // Apply lane assignment strategy
    final matches = _assignCourtsToMatches(tempMatches, courts, laneStrategy);

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

  /// Regenerates the current round with a player override
  /// Allows forcing a player to active (from break) or to break (from active)
  /// Returns null if the override would violate constraints
  Round? regenerateRoundWithOverride({
    required Round currentRound,
    required List<Player> allPlayers,
    required List<Court> courts,
    required Player overridePlayer,
    required bool forceToActive,
    List<PlayerStanding>? standings,
    LaneAssignmentStrategy laneStrategy = LaneAssignmentStrategy.sequential,
  }) {
    // Validate the override request
    if (forceToActive) {
      // Player must currently be on break
      if (!currentRound.playersOnBreak.any((p) => p.id == overridePlayer.id)) {
        return null; // Player is not on break
      }
    } else {
      // Player must currently be active (in a match)
      if (currentRound.playersOnBreak.any((p) => p.id == overridePlayer.id)) {
        return null; // Player is already on break
      }
      
      // Can force to break if:
      // 1. No one on break yet (transitioning from 0→1), OR
      // 2. Someone on break (swap is OK as long as total doesn't increase beyond max)
      //
      // The key insight: if someone is on break, we swap, so the total doesn't change.
      // If no one is on break, we allow going from 0→1 as a special case.
      //
      // Simply: allow swaps if someone is on break, allow first transition from 0→1 anyway
      if (currentRound.playersOnBreak.isNotEmpty) {
        // Someone on break already - swapping is OK (maintains count)
        // No additional validation needed
      }
      // If no one on break, allow the transition from 0→1
    }
    
    // Create new lists for the override
    List<Player> newPlayersOnBreak;
    List<Player> newActivePlayers;
    
    if (forceToActive) {
      // Remove player from break, add to active
      newPlayersOnBreak = currentRound.playersOnBreak
          .where((p) => p.id != overridePlayer.id)
          .toList();
      
      // Get all currently active players
      final currentlyActive = allPlayers
          .where((p) => !currentRound.playersOnBreak.any((bp) => bp.id == p.id))
          .toList();
      
      // Add the override player to active
      currentlyActive.add(overridePlayer);
      
      // If we now have too many active players, move someone else to break
      final playersNeeded = (currentlyActive.length ~/ 4) * 4;
      final overflowCount = currentlyActive.length - playersNeeded;
      
      if (overflowCount > 0) {
        // Select someone to go on break using fairness logic if standings available
        if (standings != null) {
          // Get standings for only the active players (excluding override player)
          final candidatesStandings = standings
              .where((s) => currentlyActive.any((p) => p.id == s.player.id) && 
                           s.player.id != overridePlayer.id)
              .toList();
          
          // Use fairness logic to select who should take the break
          final toBreak = _selectBreakPlayersWithFairness(
            candidatesStandings.map((s) => s.player).toList(),
            candidatesStandings,
            overflowCount,
          );
          
          newPlayersOnBreak.addAll(toBreak);
        } else {
          // Fallback to random selection if no standings provided
          final candidatesForBreak = currentlyActive
              .where((p) => p.id != overridePlayer.id)
              .toList()..shuffle();
          
          newPlayersOnBreak.addAll(candidatesForBreak.take(overflowCount));
        }
        
        newActivePlayers = currentlyActive
            .where((p) => !newPlayersOnBreak.any((bp) => bp.id == p.id))
            .toList()..shuffle();
      } else {
        newActivePlayers = currentlyActive..shuffle();
      }
    } else {
      // Force player to break - swap with someone on break if possible to maintain structure
      newPlayersOnBreak = [...currentRound.playersOnBreak];
      
      // If there are players on break, swap the forced player with one of them
      if (newPlayersOnBreak.isNotEmpty) {
        // Select someone to swap with using fairness logic if available
        Player playerToReturn;
        
        if (standings != null) {
          // Get standings for players on break
          final breakStandings = standings
              .where((s) => newPlayersOnBreak.any((p) => p.id == s.player.id))
              .toList();
          
          if (breakStandings.isNotEmpty) {
            // Sort to find who has been on break the most (fairness)
            breakStandings.sort(_compareForPauseFairness);
            playerToReturn = breakStandings.last.player; // Last in list has most pauses
          } else {
            // Fallback to random
            newPlayersOnBreak.shuffle();
            playerToReturn = newPlayersOnBreak.first;
          }
        } else {
          // Random selection
          newPlayersOnBreak.shuffle();
          playerToReturn = newPlayersOnBreak.first;
        }
        
        // Perform the swap
        newPlayersOnBreak.remove(playerToReturn);
        newPlayersOnBreak.add(overridePlayer);
        
        // Active players include everyone except new break list
        newActivePlayers = allPlayers
            .where((p) => !newPlayersOnBreak.any((bp) => bp.id == p.id))
            .toList()..shuffle();
      } else {
        // No one currently on break, so just add the override player to break
        newPlayersOnBreak.add(overridePlayer);
        newActivePlayers = allPlayers
            .where((p) => !newPlayersOnBreak.any((bp) => bp.id == p.id))
            .toList()..shuffle();
      }
    }
    
    // Generate new temporary matches from active players
    final tempMatches = <Match>[];
    int playerIndex = 0;
    while (playerIndex + 3 < newActivePlayers.length && 
           tempMatches.length < courts.length) {
      final match = Match(
        court: courts[0], // Temporary court
        team1: Team(
          player1: newActivePlayers[playerIndex],
          player2: newActivePlayers[playerIndex + 1],
        ),
        team2: Team(
          player1: newActivePlayers[playerIndex + 2],
          player2: newActivePlayers[playerIndex + 3],
        ),
      );
      tempMatches.add(match);
      playerIndex += 4;
    }
    
    // Apply lane assignment strategy
    final matches = _assignCourtsToMatches(tempMatches, courts, laneStrategy);
    
    // Create new round with updated assignments
    return Round(
      roundNumber: currentRound.roundNumber,
      matches: matches,
      playersOnBreak: newPlayersOnBreak,
      isFinalRound: currentRound.isFinalRound,
    );
  }
}

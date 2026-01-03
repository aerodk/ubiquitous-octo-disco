# Tournament Matchup Algorithms - Americano vs Mexicano vs Social-Mexicano

This document provides a comprehensive explanation of the three matchup algorithms available in the Padel Tournament application.

## Terminology

The matchup algorithms are defined as follows:

- **Americano:** Random shuffling for partner/opponent selection (current implementation)
- **Mexicano:** Point-based competitive pairing (NEW - default, recommended)
- **Social-Mexicano:** Meeting-based variety pairing (formerly called "Mexicano")

## Executive Summary

### Americano (Random Shuffling)

The algorithm uses **random shuffling** for player assignment in all round types:
1. **First Round:** Players are randomly shuffled and grouped into matches of 4
2. **Regular Rounds:** Players are randomly shuffled again (after selecting who sits out)
3. **Final Round:** Uses rank-based pairing strategies

### Mexicano (Point-Based Competitive) - NEW DEFAULT

The Mexicano algorithm implements sophisticated point-based partner/opponent selection:
- Sort players by total points after each round
- Pair players with similar point totals (within threshold)
- Match teams with similar combined points for competitive balance
- Track partner/opponent history as secondary priority
- Creates balanced, competitive games throughout the tournament

### Social-Mexicano (Meeting-Based Variety)

The Social-Mexicano algorithm (formerly called "Mexicano") implements meeting-focused partner/opponent selection:
- Sort players by total points after each round
- Pair players to minimize partner repetition (PRIORITY 1), prefer similar rankings (PRIORITY 2)
- Track and rotate partners to avoid repetition
- Track and vary opponents to ensure variety
- May create unbalanced matches when top and bottom players haven't met yet

## Example Walkthrough: 14 Players, 3 Courts

### Setup
- **Players:** Player 1, Player 2, Player 3, ..., Player 14
- **Courts:** 3 courts available (Bane 1, Bane 2, Bane 3)
- **Capacity:** 3 courts × 4 players = 12 players can play at once
- **Overflow:** 14 - 12 = 2 players must sit out each round

---

## PART 1: AMERICANO ALGORITHM (Current Implementation)

The Americano algorithm is the current default setting, using random shuffling for simple, unpredictable matchups.

---

## Round 1: First Round Generation (Both Algorithms)

### Algorithm: `generateFirstRound()`

**Note:** Both Americano and Mexicano use the same first round algorithm - random shuffling ensures a fair start.

**Location:** `lib/services/tournament_service.dart` lines 79-132

### Step-by-Step Process:

#### Step 1: Random Shuffle
```
Input: [Player 1, Player 2, Player 3, ..., Player 14]
↓
After shuffle (example): [Player 7, Player 3, Player 12, Player 5, Player 1, 
                          Player 9, Player 14, Player 2, Player 8, Player 11, 
                          Player 4, Player 6, Player 13, Player 10]
```

#### Step 2: Group into Matches (4 players each)
```
Match 1 (positions 0-3):
  Team 1: Player 7 & Player 3
  Team 2: Player 12 & Player 5

Match 2 (positions 4-7):
  Team 1: Player 1 & Player 9
  Team 2: Player 14 & Player 2

Match 3 (positions 8-11):
  Team 1: Player 8 & Player 11
  Team 2: Player 4 & Player 6
```

#### Step 3: Identify Break Players
```
Remaining players (positions 12-13): Player 13, Player 10
→ These 2 players sit out this round
```

#### Step 4: Assign Courts
Based on `LaneAssignmentStrategy` setting:
- **Sequential (default):** Match 1 → Bane 1, Match 2 → Bane 2, Match 3 → Bane 3
- **Random:** Courts are shuffled before assignment

### Result for Round 1:
| Court | Team 1 | Team 2 | Break Players |
|-------|--------|--------|---------------|
| Bane 1 | Player 7 & Player 3 | Player 12 & Player 5 | Player 13 |
| Bane 2 | Player 1 & Player 9 | Player 14 & Player 2 | Player 10 |
| Bane 3 | Player 8 & Player 11 | Player 4 & Player 6 | |

### Key Characteristics:
- ✅ **Completely random** pairing
- ✅ **Fair start** - everyone has equal chance
- ❌ **No consideration** of skill level or previous experience
- ❌ **No pattern** - pure randomness

---

## Round 2+: Regular Round Generation - AMERICANO

### Algorithm: `generateNextRound()` with Americano Mode

**Location:** `lib/services/tournament_service.dart` lines 145-210

### Step-by-Step Process:

#### Step 1: Select Break Players (Fairness Logic)
```
For each player, calculate:
- Pause count (how many times they've sat out)
- Matches played

Sort priority (who sits out first):
1. Fewest pauses (ascending) - players with 0 pauses go first
2. Most games played (descending) - among equal pauses, those who played more
3. Current order (random)
```

**Example after Round 1:**
```
Player 13: pauseCount=1, matchesPlayed=0
Player 10: pauseCount=1, matchesPlayed=0
Player 7:  pauseCount=0, matchesPlayed=1
Player 3:  pauseCount=0, matchesPlayed=1
...all other players: pauseCount=0, matchesPlayed=1

Sorting for break selection:
1. Players with pauseCount=0 and matchesPlayed=1 (12 players)
2. Players with pauseCount=1 and matchesPlayed=0 (2 players: 13, 10)

Need 2 players to sit out:
→ Select first 2 from group 1 (those with 0 pauses but have played)
→ Let's say: Player 7, Player 3 (random from the equal-priority group)
```

#### Step 2: Random Shuffle of Active Players
```
Active players (12 total, excluding Player 7 and Player 3):
[Player 1, Player 2, Player 4, Player 5, Player 6, Player 8, 
 Player 9, Player 10, Player 11, Player 12, Player 13, Player 14]

After shuffle (example):
[Player 14, Player 6, Player 2, Player 11, Player 13, Player 5,
 Player 10, Player 12, Player 8, Player 4, Player 1, Player 9]
```

#### Step 3: Group into Matches
```
Match 1: Player 14 & Player 6 vs Player 2 & Player 11
Match 2: Player 13 & Player 5 vs Player 10 & Player 12
Match 3: Player 8 & Player 4 vs Player 1 & Player 9
```

#### Step 4: Assign Courts
Sequential or random assignment to Bane 1, 2, 3

### Result for Round 2:
| Court | Team 1 | Team 2 | Break Players |
|-------|--------|--------|---------------|
| Bane 1 | Player 14 & Player 6 | Player 2 & Player 11 | Player 7 |
| Bane 2 | Player 13 & Player 5 | Player 10 & Player 12 | Player 3 |
| Bane 3 | Player 8 & Player 4 | Player 1 & Player 9 | |

### Key Characteristics of Americano:
- ✅ **Fair break distribution** - uses pause count and games played
- ✅ **Avoids consecutive breaks** for the same player
- ❌ **Random partner assignment** - no consideration of previous partners
- ❌ **Random opponent matching** - no consideration of point totals or rankings
- ❌ **No skill balancing** - teams are formed randomly

---

## Round 3 and Beyond - AMERICANO: Same as Round 2

Regular rounds continue using the same Americano algorithm:
1. Fair break selection based on pause history
2. Random shuffle of active players
3. Group into matches sequentially
4. Assign courts

**What's Missing in Americano (compared to Mexicano Specification F-006):**
- ❌ Sorting players by total points
- ❌ Pairing players with similar rankings
- ❌ Tracking partner history to ensure rotation
- ❌ Tracking opponent history to avoid repetition
- ❌ Matching teams with similar combined rankings

---

## PART 2: MEXICANO ALGORITHM (Point-Based Competitive - NEW DEFAULT)

The Mexicano algorithm implements sophisticated point-based partner/opponent selection for competitive balance.

---

## Round 2+: Regular Round Generation - MEXICANO

### Algorithm: `generateNextRound()` with Mexicano Mode

**Location:** `lib/services/tournament_service.dart` and `lib/services/mexicano_algorithm_service.dart`

### Step-by-Step Process:

#### Step 1: Calculate Player Statistics
```
For each player, calculate from all previous rounds:
- Total points scored
- Games played
- Partner history: Map<Player, int> (times played together)
- Opponent history: Map<Player, int> (times faced)
- Pause rounds: List<int> (which rounds sat out)

Example after Round 1:
Player 5:  totalPoints=18, gamesPlayed=1, partners={Player 12: 1}, opponents={Player 3: 1, Player 7: 1}
Player 12: totalPoints=18, gamesPlayed=1, partners={Player 5: 1}, opponents={Player 3: 1, Player 7: 1}
Player 3:  totalPoints=6,  gamesPlayed=1, partners={Player 7: 1}, opponents={Player 5: 1, Player 12: 1}
Player 7:  totalPoints=6,  gamesPlayed=1, partners={Player 3: 1}, opponents={Player 5: 1, Player 12: 1}
...
```

#### Step 2: Sort Players by Total Points (Descending)
```
Sorted ranking after Round 1 (example):
1. Player 5  (18 points)
2. Player 12 (18 points)
3. Player 9  (18 points)
4. Player 1  (16 points)
5. Player 14 (16 points)
6. Player 2  (14 points)
7. Player 8  (12 points)
8. Player 11 (12 points)
9. Player 4  (10 points)
10. Player 6 (10 points)
11. Player 13 (8 points)
12. Player 10 (8 points)
13. Player 3 (6 points)
14. Player 7 (6 points)
```

#### Step 3: Select Break Players (Same Fairness Logic)
```
Priority for sitting out:
1. Fewest pauses (ascending)
2. Most games played (descending)
3. Random among equals

For 2 overflow in Round 2:
→ Player 13 and Player 10 sat out in Round 1 (pauseCount=1)
→ All others have pauseCount=0
→ Select 2 from those with pauseCount=0
→ Among equals, random selection
→ Example: Player 7 (rank 14) and Player 3 (rank 13)
```

#### Step 4: Generate Optimal Pairs (Point-Difference Constraints)
```
Active players (12 total): Ranks 1-6, 8-12 (excluding ranks 13-14)
[Player 5, Player 12, Player 9, Player 1, Player 14, Player 2,
 Player 8, Player 11, Player 4, Player 6, Player 13, Player 10]

Pair Generation Algorithm (NEW):
For each player (in ranking order):
  If player not yet paired:
    Find best partner from remaining players:
      Priority 1: Point difference ≤ threshold (Round 2: 8 points)
                  Filter out partners with too large point difference
      Priority 2: Among valid partners, minimize ranking difference
      Priority 3: Among equal rank differences, minimize partner count
    
    Create pair and mark both players as used

Point Difference Thresholds:
- Round 2-3: 8 points (early rounds, tight pairing)
- Round 4-5: 12 points (mid rounds, moderate pairing)
- Round 6+: 16 points (late rounds, allow tier formation)

Example pairs (Round 2):
Pair 1: Player 5 (R1, 18pts) + Player 12 (R2, 18pts) [0pt diff ✅]
Pair 2: Player 9 (R3, 18pts) + Player 1 (R4, 16pts)  [2pt diff ✅]
Pair 3: Player 14 (R5, 16pts) + Player 2 (R6, 14pts) [2pt diff ✅]
Pair 4: Player 8 (R7, 12pts) + Player 11 (R8, 12pts) [0pt diff ✅]
Pair 5: Player 4 (R9, 10pts) + Player 6 (R10, 10pts) [0pt diff ✅]
Pair 6: Player 13 (R11, 8pts) + Player 10 (R12, 8pts) [0pt diff ✅]

NOTE: Top players (18pts) NOT paired with bottom players (6-8pts) due to point threshold!
```

#### Step 5: Match Pairs to Games (Team Balance Priority)
```
Match Generation Algorithm (NEW):
For each pair (in order):
  If pair not yet matched:
    Calculate combined points for current pair
    Find best opponent pair from remaining pairs:
      Priority 1: Minimize combined points difference between teams
                  Ensures competitive matches
      Priority 2: Among similar combined points, minimize opponent history
      Priority 3: Sequential (next pair in list)
    
    Create match and mark both pairs as used

Example matches (Round 2):
Match 1: Pair 1 (36pts combined) vs Pair 2 (34pts combined)
  Team 1: Player 5 (18) & Player 12 (18) = 36pts
  Team 2: Player 9 (18) & Player 1 (16) = 34pts
  [2pt team difference ✅ Competitive!]

Match 2: Pair 3 (30pts combined) vs Pair 4 (24pts combined)
  Team 1: Player 14 (16) & Player 2 (14) = 30pts
  Team 2: Player 8 (12) & Player 11 (12) = 24pts
  [6pt team difference ✅ Reasonable balance]

Match 3: Pair 5 (20pts combined) vs Pair 6 (16pts combined)
  Team 1: Player 4 (10) & Player 6 (10) = 20pts
  Team 2: Player 13 (8) & Player 10 (8) = 16pts
  [4pt team difference ✅ Competitive!]
```

#### Step 6: Assign Courts
Sequential or random assignment to Bane 1, 2, 3

### Result for Round 2 - MEXICANO:
| Court | Team 1 | Team 2 | Break Players |
|-------|--------|--------|---------------|
| Bane 1 | Player 5 (18) & Player 12 (18) | Player 9 (18) & Player 1 (16) | Player 7 (6) |
| Bane 2 | Player 14 (16) & Player 2 (14) | Player 8 (12) & Player 11 (12) | Player 3 (6) |
| Bane 3 | Player 4 (10) & Player 6 (10) | Player 13 (8) & Player 10 (8) | |

### Key Characteristics of Mexicano:
- ✅ **Fair break distribution** - same pause fairness as Americano and Social-Mexicano
- ✅ **Point-based pairing** - players sorted by performance
- ✅ **Competitive balance** - point-difference thresholds enforced
- ✅ **Team balance** - teams matched by combined points
- ✅ **Engaging matches** - similar-skilled players compete together
- ✅ **Adaptive thresholds** - tighter early, looser late as tiers form
- ⚠️ **Less social variety** - may play with/against same people if skill levels differ significantly

---

## PART 3: SOCIAL-MEXICANO ALGORITHM (Meeting-Based Variety)

The Social-Mexicano algorithm (formerly called "Mexicano") implements meeting-focused partner/opponent selection.

---

## Round 2+: Regular Round Generation - SOCIAL-MEXICANO

### Algorithm: `generateNextRound()` with Social-Mexicano Mode

**Location:** `lib/services/tournament_service.dart` and `lib/services/social_mexicano_algorithm_service.dart`

### Step-by-Step Process:

#### Step 1: Calculate Player Statistics
```
For each player, calculate from all previous rounds:
- Total points scored
- Games played
- Partner history: Map<Player, int> (times played together)
- Opponent history: Map<Player, int> (times faced)
- Pause rounds: List<int> (which rounds sat out)

Example after Round 1:
Player 5:  totalPoints=18, gamesPlayed=1, partners={Player 12: 1}, opponents={Player 3: 1, Player 7: 1}
Player 12: totalPoints=18, gamesPlayed=1, partners={Player 5: 1}, opponents={Player 3: 1, Player 7: 1}
Player 3:  totalPoints=6,  gamesPlayed=1, partners={Player 7: 1}, opponents={Player 5: 1, Player 12: 1}
Player 7:  totalPoints=6,  gamesPlayed=1, partners={Player 3: 1}, opponents={Player 5: 1, Player 12: 1}
...
```

#### Step 2: Sort Players by Total Points (Descending)
```
Sorted ranking after Round 1 (example):
1. Player 5  (18 points)
2. Player 12 (18 points)
3. Player 9  (18 points)
4. Player 1  (16 points)
5. Player 14 (16 points)
6. Player 2  (14 points)
7. Player 8  (12 points)
8. Player 11 (12 points)
9. Player 4  (10 points)
10. Player 6 (10 points)
#### Step 1: Calculate Player Statistics
Same as Mexicano - track all player stats including partner/opponent history.

#### Step 2: Sort Players by Total Points (Descending)
Same as Mexicano - create ranking based on performance.

#### Step 3: Select Break Players (Same Fairness Logic)
Same as Mexicano and Americano.

#### Step 4: Generate Optimal Pairs (History-Aware, NO Point Constraints)
```
Active players (12 total): Ranks 1-6, 8-12 (excluding ranks 13-14)
[Player 5, Player 12, Player 9, Player 1, Player 14, Player 2,
 Player 8, Player 11, Player 4, Player 6, Player 13, Player 10]

Pair Generation Algorithm (ORIGINAL):
For each player (in ranking order):
  If player not yet paired:
    Find best partner from remaining players:
      Priority 1: Fewest times played together (partner history)
      Priority 2: Closest in ranking (minimize rank difference)
    
    Create pair and mark both players as used

Example pairs (Round 2) - PROBLEM SCENARIO:
Player 5 (R1, 18pts) has never partnered with Player 13 (R11, 8pts)
Player 5 HAS partnered with Player 12 (R2, 18pts) in Round 1

Social-Mexicano chooses: Player 5 + Player 13 [10pt diff ⚠️ Unbalanced!]
Instead of: Player 5 + Player 12 [0pt diff ✅ Balanced]

This is the CORE PROBLEM addressed by the new Mexicano algorithm!
```

#### Step 5: Match Pairs to Games (Opponent History Priority)
```
Match Generation Algorithm (ORIGINAL):
For each pair (in order):
  If pair not yet matched:
    Find best opponent pair from remaining pairs:
      Priority 1: Fewest total opponent encounters (all 4 players)
      Priority 2: Sequential (next pair in list)
    
    Create match and mark both pairs as used

Focus is on meeting variety, NOT competitive balance.
```

### Key Characteristics of Social-Mexicano:
- ✅ **Fair break distribution** - same pause fairness as other formats
- ✅ **Point-based ranking** - players sorted by performance
- ✅ **Partner rotation** - tracks history, avoids repetition (PRIORITY 1)
- ✅ **Opponent variety** - tracks history, ensures diverse matchups
- ✅ **Maximum social mixing** - everyone plays with/against different people
- ❌ **Can be unbalanced** - top + bottom players paired if they haven't met
- ❌ **Frustrating for competitive players** - skill gaps can be too large

---

## Round 3+: Both Algorithms Continue Their Strategies

Each subsequent round:
- **Mexicano**: Recalculates stats, enforces point thresholds, creates balanced matches
- **Social-Mexicano**: Recalculates stats, maximizes meeting variety, may create unbalanced matches

---

## PART 3: FINAL ROUND (Both Algorithms)

Both Americano and Mexicano use the same final round algorithm.

### Algorithm: `generateFinalRound()`

**Location:** `lib/services/tournament_service.dart` lines 261-341

### When It Triggers:
- After completing minimum rounds (default: 3)
- User explicitly starts the final round
- One-time only per tournament

### Step-by-Step Process:

#### Step 1: Get Ranked Standings
```
After 3+ rounds, players are ranked by:
1. Total points (highest first)
2. Wins (tiebreaker)
3. Head-to-head (tiebreaker)
4. Biggest win margin (tiebreaker)
5. Smallest loss margin (tiebreaker)

Example standings:
Rank 1: Player 5  (72 points, 3 wins)
Rank 2: Player 12 (68 points, 3 wins)
Rank 3: Player 9  (65 points, 2 wins)
Rank 4: Player 1  (64 points, 2 wins)
Rank 5: Player 8  (62 points, 2 wins)
Rank 6: Player 2  (60 points, 2 wins)
Rank 7: Player 14 (58 points, 1 win)
Rank 8: Player 11 (56 points, 1 win)
Rank 9: Player 6  (54 points, 1 win)
Rank 10: Player 4 (52 points, 1 win)
Rank 11: Player 13 (48 points, 0 wins)
Rank 12: Player 10 (46 points, 0 wins)
Rank 13: Player 3 (44 points, 0 wins)
Rank 14: Player 7 (42 points, 0 wins)
```

#### Step 2: Select Break Players (Rolling Pause)
```
Priority for sitting out:
1. Always the lowest-ranked player (Player 7)
2. Among bottom half, those with most games played
3. Lower rank
4. Fewest pauses

For 2 overflow:
→ Player 7 (rank 14, lowest)
→ Player 3 (rank 13, second-lowest in bottom half)
```

#### Step 3: Apply Pairing Strategy

**Three strategies available (configurable in settings):**

##### Strategy 1: Balanced (Default)
Pattern: R1+R3 vs R2+R4
```
Active players: Ranks 1-12 (excluding 13, 14)

Match 1: (R1 + R3) vs (R2 + R4)
  Team 1: Player 5 (R1) & Player 9 (R3)
  Team 2: Player 12 (R2) & Player 1 (R4)

Match 2: (R5 + R7) vs (R6 + R8)
  Team 1: Player 8 (R5) & Player 14 (R7)
  Team 2: Player 2 (R6) & Player 11 (R8)

Match 3: (R9 + R11) vs (R10 + R12)
  Team 1: Player 6 (R9) & Player 13 (R11)
  Team 2: Player 4 (R10) & Player 10 (R12)
```

##### Strategy 2: Top Alliance
Pattern: R1+R2 vs R3+R4
```
Match 1: Player 5 (R1) & Player 12 (R2) vs Player 9 (R3) & Player 1 (R4)
Match 2: Player 8 (R5) & Player 2 (R6) vs Player 14 (R7) & Player 11 (R8)
Match 3: Player 6 (R9) & Player 4 (R10) vs Player 13 (R11) & Player 10 (R12)
```

##### Strategy 3: Max Competition
Pattern: R1+R4 vs R2+R3
```
Match 1: Player 5 (R1) & Player 1 (R4) vs Player 12 (R2) & Player 9 (R3)
Match 2: Player 8 (R5) & Player 11 (R8) vs Player 2 (R6) & Player 14 (R7)
Match 3: Player 6 (R9) & Player 10 (R12) vs Player 4 (R10) & Player 13 (R11)
```

#### Step 4: Assign Courts
Sequential (default) assigns best matches to first courts

### Result for Final Round (Balanced Strategy):
| Court | Team 1 | Team 2 | Break Players |
|-------|--------|--------|---------------|
| Bane 1 | Player 5 (R1) & Player 9 (R3) | Player 12 (R2) & Player 1 (R4) | Player 7 (R14) |
| Bane 2 | Player 8 (R5) & Player 14 (R7) | Player 2 (R6) & Player 11 (R8) | Player 3 (R13) |
| Bane 3 | Player 6 (R9) & Player 13 (R11) | Player 4 (R10) & Player 10 (R12) | |

### Key Characteristics:
- ✅ **Rank-based pairing** - uses tournament standings
- ✅ **Strategic team formation** - configurable patterns
- ✅ **Fair for finale** - best players get competitive matches
- ✅ **Predictable** - based on performance, not random
- ⚠️ **Only applies to final round** - not used throughout tournament

---

---

## PART 4: COMPARISON & IMPLEMENTATION PLAN

---

## Algorithm Comparison Summary

### Americano (Current Default)

| Round Type | Partner Selection | Opponent Selection | Based On |
|------------|-------------------|--------------------| ---------|
| First | Random | Random | Shuffle |
| Regular (2-N) | Random | Random | Shuffle |
| Final | Rank-based pattern | Rank-based pattern | Tournament standings |

**Pros:**
- ✅ Simple and fast
- ✅ Unpredictable and varied
- ✅ Easy to understand
- ✅ Fair break distribution

**Cons:**
- ❌ Can repeat partners
- ❌ Can repeat opponents
- ❌ No skill balancing
- ❌ Games can be imbalanced

### Mexicano (Planned, Will Be New Default)

| Round Type | Partner Selection | Opponent Selection | Based On |
|------------|-------------------|--------------------| ---------|
| First | Random | Random | Shuffle |
| Regular (2-N) | **History-aware + rank** | **History-aware + rank** | **Points, partners, opponents** |
| Final | Rank-based pattern | Rank-based pattern | Tournament standings |

**Pros:**
- ✅ Partner rotation guaranteed
- ✅ Opponent variety enforced
- ✅ Skill-based balancing
- ✅ Competitive games
- ✅ Strategic depth
- ✅ Authentic Mexicano format

**Cons:**
- ⚠️ More complex algorithm
- ⚠️ Slightly slower computation
- ⚠️ Less random/unpredictable

---

## Implementation Plan

### Phase 1: Data Model Updates

#### 1.1 Add Tournament Format Enum
**File:** `lib/models/tournament_settings.dart`

```dart
/// Tournament matchup format
enum TournamentFormat {
  /// Americano: Random partner/opponent selection (simple)
  americano,
  
  /// Mexicano: Strategic pairing with history tracking (default)
  mexicano,
}
```

#### 1.2 Update TournamentSettings Model
**File:** `lib/models/tournament_settings.dart`

Add new field:
```dart
final TournamentFormat format;

// Default to Mexicano (new standard)
const TournamentSettings({
  // ... existing fields ...
  this.format = TournamentFormat.mexicano,
});
```

Update:
- `copyWith()` method
- `toJson()` / `fromJson()` methods
- `isCustomized` getter
- `summary` getter

#### 1.3 Create PlayerStats Model
**File:** `lib/models/player_stats.dart` (new file)

```dart
/// Statistics for a player used in Mexicano algorithm
class PlayerStats {
  final Player player;
  final int totalPoints;
  final int gamesPlayed;
  final Map<String, int> partnerCounts;   // playerId -> count
  final Map<String, int> opponentCounts;  // playerId -> count
  final List<int> pauseRounds;
  
  PlayerStats({
    required this.player,
    required this.totalPoints,
    required this.gamesPlayed,
    required this.partnerCounts,
    required this.opponentCounts,
    required this.pauseRounds,
  });
  
  factory PlayerStats.initial(Player player) {
    return PlayerStats(
      player: player,
      totalPoints: 0,
      gamesPlayed: 0,
      partnerCounts: {},
      opponentCounts: {},
      pauseRounds: [],
    );
  }
  
  double get averagePoints => gamesPlayed > 0 ? totalPoints / gamesPlayed : 0.0;
}
```

### Phase 2: Service Layer Implementation

#### 2.1 Create Mexicano Algorithm Service
**File:** `lib/services/mexicano_algorithm_service.dart` (new file)

Implement methods from Specification F-006:
- `calculatePlayerStats()` - Build stats from previous rounds
- `generateOptimalPairs()` - Create pairs with partner rotation
- `matchPairsToGames()` - Match pairs with opponent variety
- `countPreviousPartners()` - Helper for partner history
- `countPreviousOpponents()` - Helper for opponent history

#### 2.2 Update TournamentService
**File:** `lib/services/tournament_service.dart`

Modify `generateNextRound()`:
```dart
Round generateNextRound(
  List<Player> players,
  List<Court> courts,
  List<PlayerStanding> standings,
  int roundNumber, {
  TournamentFormat format = TournamentFormat.mexicano,
  LaneAssignmentStrategy laneStrategy = LaneAssignmentStrategy.sequential,
  List<Round> previousRounds = const [],
}) {
  if (format == TournamentFormat.mexicano) {
    return _generateNextRoundMexicano(...);
  } else {
    return _generateNextRoundAmericano(...);
  }
}

Round _generateNextRoundAmericano(...) {
  // Current implementation (random shuffle)
}

Round _generateNextRoundMexicano(...) {
  // New implementation using MexicanoAlgorithmService
}
```

### Phase 3: UI Updates

#### 3.1 Settings Screen - Add Format Selector
**File:** `lib/widgets/tournament_settings_widget.dart`

Add radio button group:
```dart
RadioListTile<TournamentFormat>(
  title: Text('Mexicano (Anbefalet)'),
  subtitle: Text('Strategisk parring baseret på point og historik'),
  value: TournamentFormat.mexicano,
  groupValue: _format,
  onChanged: (value) => setState(() => _format = value!),
),
RadioListTile<TournamentFormat>(
  title: Text('Americano'),
  subtitle: Text('Tilfældig parring (simpel)'),
  value: TournamentFormat.americano,
  groupValue: _format,
  onChanged: (value) => setState(() => _format = value!),
),
```

#### 3.2 Match Card - Show Algorithm Info
**File:** `lib/widgets/match_card.dart`

Update `MatchupReasoning` display to show which algorithm was used.

### Phase 4: Testing

#### 4.1 Unit Tests
**Files:**
- `test/models/player_stats_test.dart` (new)
- `test/services/mexicano_algorithm_service_test.dart` (new)
- `test/services/tournament_service_test.dart` (update)

Test cases:
- Partner rotation works correctly
- Opponent variety is enforced
- Point-based sorting is accurate
- Edge cases (few players, many overflow, etc.)
- Both algorithms produce valid rounds
- Settings persistence works

#### 4.2 Integration Tests
**File:** `test/integration/tournament_format_test.dart` (new)

Test scenarios:
- Complete tournament with Americano format
- Complete tournament with Mexicano format
- Switching formats mid-tournament (should not be allowed)
- Verify partner/opponent distributions

#### 4.3 Manual Testing
**Scenarios:**
1. Create tournament with Americano, verify random behavior
2. Create tournament with Mexicano, verify strategic pairing
3. 14 players, 3 courts scenario (from user example)
4. Track partner/opponent encounters across multiple rounds
5. Verify UI shows correct format in settings
6. Test save/load with both formats

### Phase 5: Documentation

#### 5.1 Update Existing Docs
- Update `README.md` with format options
- Update `GETTING_STARTED.md` with format selection guide
- Update `SPECIFICATION.md` with terminology changes

#### 5.2 Create User Guide
**File:** `docs/TOURNAMENT_FORMATS.md` (new)

User-facing documentation:
- When to use Americano vs Mexicano
- How each algorithm works (simplified)
- Benefits and trade-offs
- Examples and scenarios

---

## Implementation Checklist

### Sprint 1: Data Models & Core Algorithm
- [ ] Add `TournamentFormat` enum to `tournament_settings.dart`
- [ ] Update `TournamentSettings` model with `format` field
- [ ] Create `PlayerStats` model in `lib/models/player_stats.dart`
- [ ] Implement `MexicanoAlgorithmService` in `lib/services/`
- [ ] Add unit tests for `PlayerStats` model
- [ ] Add unit tests for `MexicanoAlgorithmService`

### Sprint 2: Service Integration
- [ ] Update `TournamentService.generateNextRound()` to support both formats
- [ ] Extract current random logic to `_generateNextRoundAmericano()`
- [ ] Implement `_generateNextRoundMexicano()` using new service
- [ ] Update `MatchupReasoning` to include format information
- [ ] Update unit tests for `TournamentService`
- [ ] Verify backward compatibility with existing tournaments

### Sprint 3: UI Updates
- [ ] Add format selector to `TournamentSettingsWidget`
- [ ] Update settings summary to show format
- [ ] Add format indicator in match cards (optional)
- [ ] Update default format to Mexicano in settings
- [ ] Test UI flows for both formats
- [ ] Verify settings persistence works correctly

### Sprint 4: Testing & Documentation
- [ ] Create integration tests for both formats
- [ ] Manual testing with 14 players, 3 courts scenario
- [ ] Verify partner/opponent rotation in Mexicano
- [ ] Verify randomness in Americano
- [ ] Update all documentation files
- [ ] Create user guide for tournament formats
- [ ] Code review and cleanup

### Sprint 5: Validation & Deployment
- [ ] Run full test suite (`flutter test`)
- [ ] Run analyzer (`flutter analyze`)
- [ ] Manual testing on web and mobile
- [ ] Performance testing (algorithm speed)
- [ ] Update CHANGELOG
- [ ] Deploy to test environment
- [ ] User acceptance testing
- [ ] Deploy to production

---

## Technical Considerations

### Performance
- Mexicano algorithm is O(n²) for pairing generation
- Should be fast enough for up to 72 players
- Consider caching player stats if needed

### Data Migration
- Existing tournaments use Americano (random)
- Default new tournaments to Mexicano
- No migration needed - format is per-tournament setting

### Backward Compatibility
- Old tournaments without `format` field default to Americano
- Preserve existing behavior for saved games
- JSON serialization handles missing fields

### Edge Cases
- Very few players (4-8): both algorithms work
- Many overflow players: pause fairness handles both
- Mid-tournament format change: should be prevented (or warning shown)

---

## Success Criteria

### Functional Requirements
✅ Americano format produces random matchups (current behavior)
✅ Mexicano format tracks partner/opponent history
✅ Mexicano format rotates partners effectively
✅ Mexicano format ensures opponent variety
✅ Both formats respect pause fairness rules
✅ Settings UI clearly shows format selection
✅ Default format is Mexicano for new tournaments

### Quality Requirements
✅ All tests pass (unit + integration)
✅ Code coverage > 80% for new code
✅ Flutter analyze shows no errors
✅ Documentation is complete and accurate
✅ User guide is clear and helpful

### User Experience
✅ Format selection is intuitive
✅ Algorithm choice is clear in UI
✅ Performance is acceptable (< 2 seconds per round)
✅ Users understand difference between formats

---

## Timeline Estimate

- **Sprint 1 (Data Models):** 2-3 days
- **Sprint 2 (Service Layer):** 3-4 days
- **Sprint 3 (UI Updates):** 2-3 days
- **Sprint 4 (Testing):** 2-3 days
- **Sprint 5 (Validation):** 1-2 days

**Total:** 10-15 days for complete implementation

---

## Next Steps

1. **Review this plan** - Confirm approach and scope
2. **Create GitHub issue** - Track implementation progress
3. **Start Sprint 1** - Begin with data models
4. **Iterative development** - Test after each sprint
5. **Deploy incrementally** - Test environment first

This plan provides a clear roadmap for implementing both Americano and Mexicano tournament formats with proper testing and documentation.

# Mexicano Algorithm Comparison

## Overview

This document describes the Mexicano matching algorithms before and after the proposed changes to address unbalanced game issues.

## Problem Statement

The current Mexicano algorithm prioritizes avoiding partner/opponent repetition, which can lead to very unbalanced games when top players and bottom players have not yet met each other. Players with large point differences may be matched together simply because they haven't played before, resulting in non-competitive matches.

## Solution

Introduce two distinct algorithms:
1. **Social-Mexicano** (current implementation): Prioritizes meeting variety over competitive balance
2. **Mexicano** (new default): Prioritizes competitive balance with point-difference limits

---

## Current Implementation: Social-Mexicano Algorithm

### Philosophy
Social-Mexicano focuses on social variety - ensuring all players get to play with and against different people throughout the tournament, even if it means some games are unbalanced.

### Algorithm Steps (Round 2+)

#### Step 1: Calculate Player Statistics
For each player, calculate from all previous rounds:
- Total points scored
- Games played
- Partner history: Map<Player, int> (times played together)
- Opponent history: Map<Player, int> (times faced)
- Pause rounds: List<int> (which rounds sat out)

#### Step 2: Sort Players by Total Points (Descending)
```
Example after Round 1:
Rank 1: Player A (24 points)
Rank 2: Player B (22 points)
Rank 3: Player C (20 points)
...
Rank 12: Player L (8 points)
Rank 13: Player M (6 points)
Rank 14: Player N (4 points)
```

#### Step 3: Select Break Players
Uses pause fairness logic:
1. Fewest pauses (ascending)
2. Most games played (descending)
3. Random among equals

#### Step 4: Generate Optimal Pairs
**Priority Order:**
1. **HIGHEST PRIORITY**: Fewest times played together (partner history)
2. **LOWER PRIORITY**: Closest in ranking (minimize rank difference)

```
Pairing Algorithm:
For each player (in ranking order):
  If player not yet paired:
    Find best partner from remaining players:
      Priority 1: Minimize partner count (0 is best, 1 is worse than 0, etc.)
      Priority 2: If partner counts are equal, minimize ranking difference
    Create pair and mark both players as used
```

**Example Scenario (The Problem):**
```
Round 2:
Player A (Rank 1, 24 pts) has partnered with: [B]
Player B (Rank 2, 22 pts) has partnered with: [A]
Player M (Rank 13, 6 pts) has partnered with: [N]
Player N (Rank 14, 4 pts) has partnered with: [M]

When pairing Player A:
- Best partner by history: Player M or N (partner count = 0)
- Even though rank difference is huge (Rank 1 to Rank 13 = 12 positions!)
- Result: Player A + Player M vs Player B + Player N
- Combined team points: Team 1 = 30pts, Team 2 = 26pts
- But skill gap within teams is massive!
```

#### Step 5: Match Pairs to Games
**Priority Order:**
1. **HIGHEST PRIORITY**: Fewest total opponent encounters (all 4 players)
2. **LOWER PRIORITY**: Sequential pairs

```
Matching Algorithm:
For each pair (in order):
  If pair not yet matched:
    Find best opponent pair from remaining pairs:
      Priority 1: Minimize opponent encounter count
      Priority 2: Sequential (next pair in list)
    Create match and mark both pairs as used
```

### Pros and Cons

**Pros:**
✅ Maximum social variety - everyone plays with/against different people
✅ Ensures all players interact throughout the tournament
✅ Great for social/casual tournaments where networking matters

**Cons:**
❌ Can create very unbalanced games (top + bottom vs middle players)
❌ Frustrating for competitive players when skill gaps are too large
❌ May lead to non-competitive matches that are predictable
❌ Partner skill difference can be unfair

---

## New Implementation: Mexicano Algorithm

### Philosophy
Mexicano prioritizes competitive balance - players with similar skill levels (point totals) play together, creating more engaging and fair matches. Meeting variety is secondary.

### Algorithm Steps (Round 2+)

#### Step 1: Calculate Player Statistics
Same as Social-Mexicano:
- Total points scored
- Games played
- Partner history (tracked but lower priority)
- Opponent history (tracked but lower priority)
- Pause rounds

#### Step 2: Sort Players by Total Points (Descending)
Same as Social-Mexicano - create ranking based on performance.

#### Step 3: Select Break Players
Same fairness logic as Social-Mexicano.

#### Step 4: Generate Optimal Pairs
**NEW Priority Order:**
1. **HIGHEST PRIORITY**: Point difference within acceptable range
2. **MEDIUM PRIORITY**: Closest in ranking (minimize rank difference)
3. **LOWER PRIORITY**: Fewest times played together (partner history)

```
Pairing Algorithm:
For each player (in ranking order):
  If player not yet paired:
    Find best partner from remaining players:
      Priority 1: Point difference ≤ threshold (e.g., 8 points)
                  Filter out partners with too large point difference
      Priority 2: Among valid partners, minimize ranking difference
      Priority 3: Among equal rank differences, minimize partner count
    Create pair and mark both players as used
    
Point Difference Threshold:
- Round 2-3: 8 points (early rounds, less separation)
- Round 4-5: 12 points (mid tournament, more separation)
- Round 6+: 16 points (late tournament, clear tiers)
- Fallback: If no valid partner within threshold, use closest available
```

**Example Scenario (The Solution):**
```
Round 2:
Player A (Rank 1, 24 pts)
Player B (Rank 2, 22 pts)
Player C (Rank 3, 20 pts)
Player M (Rank 13, 6 pts)
Player N (Rank 14, 4 pts)

When pairing Player A:
- Filter by point difference ≤ 8: [B: 2pts diff, C: 4pts diff]
- Exclude M (18pts diff) and N (20pts diff) - too far!
- Best partner: Player B or C (both within range)
- Choose closest in rank with lowest partner count
- Result: More balanced teams
```

#### Step 5: Match Pairs to Games
**NEW Priority Order:**
1. **HIGHEST PRIORITY**: Similar combined team points (competitive balance)
2. **MEDIUM PRIORITY**: Fewest total opponent encounters
3. **LOWER PRIORITY**: Sequential pairs

```
Matching Algorithm:
For each pair (in order):
  If pair not yet matched:
    Calculate combined points for current pair
    Find best opponent pair from remaining pairs:
      Priority 1: Minimize combined points difference between teams
                  Ensures competitive matches
      Priority 2: Among similar combined points, minimize opponent history
      Priority 3: Sequential (next pair in list)
    Create match and mark both pairs as used

Example:
Pair 1: Player A (24) + Player C (20) = 44 combined points
Pair 2: Player B (22) + Player D (18) = 40 combined points
Pair 3: Player M (6) + Player N (4) = 10 combined points

Matching:
- Pair 1 (44pts) vs Pair 2 (40pts) → 4pt difference ✅ Competitive!
- NOT Pair 1 (44pts) vs Pair 3 (10pts) → 34pt difference ❌ Unbalanced!
```

### Pros and Cons

**Pros:**
✅ Competitive, balanced matches throughout the tournament
✅ Players matched with similar skill levels
✅ More engaging for competitive players
✅ Fairer partner distribution
✅ Predictable competitive structure

**Cons:**
⚠️ Less social variety - may play with/against same people more often
⚠️ Top and bottom players may rarely interact
⚠️ Requires more complex algorithm with dynamic thresholds

---

## Comparison Table

| Aspect | Social-Mexicano (Current) | Mexicano (New) |
|--------|---------------------------|----------------|
| **Primary Goal** | Social variety | Competitive balance |
| **Partner Selection** | Avoid repetition first | Point similarity first |
| **Opponent Matching** | Avoid repetition first | Team balance first |
| **Point Difference** | Not considered | Hard limit enforced |
| **Skill Balance** | Can be very unbalanced | Tightly controlled |
| **Social Mixing** | Maximum | Moderate |
| **Best For** | Social/casual events | Competitive tournaments |
| **Match Quality** | Variable | Consistent |

---

## Implementation Details

### Point Difference Thresholds

The point difference threshold adapts based on tournament progress:

```dart
int _getPointDifferenceThreshold(int roundNumber) {
  if (roundNumber <= 3) return 8;   // Early rounds
  if (roundNumber <= 5) return 12;  // Mid rounds
  return 16;                         // Late rounds
}
```

**Rationale:**
- Early rounds: Players haven't separated much yet, use tight threshold
- Mid rounds: Some separation, allow moderate differences
- Late rounds: Clear tiers emerge, allow larger differences within tiers

### Fallback Handling

If no valid partner exists within the point threshold:
1. Gradually increase threshold by 4 points
2. Repeat until partner found
3. Log warning for unbalanced pairing
4. Ensure tournament can always continue

### Edge Cases

**Few Players (4-8):**
- Thresholds may need to be relaxed
- Accept that some imbalance is unavoidable
- Social-Mexicano might be better choice

**Many Players (40+):**
- Thresholds work well - plenty of options
- Creates clear competitive tiers
- Mexicano shines in this scenario

**Uneven Skill Distribution:**
- One very strong or very weak player
- May be isolated in their tier
- Algorithm finds closest available matches

---

## Migration Strategy

### Default Format Change

**New Tournaments:**
- Default to **Mexicano** (point-based)
- Recommended for most competitive scenarios

**Existing Tournaments:**
- Continue using their selected format
- No automatic migration needed

### User Selection

Both formats available in settings:
```
○ Mexicano (Anbefalet)
  Konkurrencedygtig balance baseret på point-forskel

○ Social-Mexicano
  Maksimal social variation, undgår gentagelse
```

### Format Lock

Once a tournament starts:
- Format cannot be changed mid-tournament
- Prevents confusion and maintains consistency
- Must complete or restart to change format

---

## Testing Requirements

### Unit Tests

1. **Point Difference Thresholds**
   - Verify correct thresholds per round
   - Test fallback when no valid partners

2. **Pairing with Point Limits**
   - Pairs respect point difference limits
   - Fallback works when limits can't be met

3. **Team Balance Matching**
   - Teams matched by combined points
   - Competitive matches created

4. **Edge Cases**
   - Very few players
   - One outlier player
   - All players equal points

### Integration Tests

1. **Complete Tournament (Mexicano)**
   - Verify balanced matches throughout
   - Check point differences stay within limits

2. **Complete Tournament (Social-Mexicano)**
   - Verify maximum partner/opponent variety
   - Check all players interact

3. **Comparison Test**
   - Same initial setup
   - Run both algorithms
   - Verify different pairing strategies

### Manual Testing

1. **14 Players, 3 Courts (from issue)**
   - Run multiple rounds with both formats
   - Verify Mexicano creates balanced matches
   - Verify Social-Mexicano maximizes variety

2. **Extreme Scenarios**
   - Top heavy (few good players, many weak)
   - Bottom heavy (few weak players, many good)
   - Even distribution

---

## Documentation Updates Required

### Files to Update

1. **README.md**
   - Update format descriptions
   - Clarify which to use when

2. **CURRENT_MATCHUP_ALGORITHM.md**
   - Split into two sections
   - Document both algorithms fully

3. **SPECIFICATION.md**
   - Add Social-Mexicano as F-006b
   - Update Mexicano as F-006a

4. **User Guide (New)**
   - When to use each format
   - Examples and scenarios
   - Visual comparisons

### Code Comments

Update inline documentation:
- `MexicanoAlgorithmService` → `SocialMexicanoAlgorithmService`
- Create new `MexicanoAlgorithmService` with point-based logic
- Clear comments explaining priority order in both

---

## Success Criteria

### Functional

✅ Social-Mexicano behaves like current Mexicano (meeting-based)
✅ New Mexicano enforces point difference limits
✅ Both algorithms produce valid rounds
✅ Settings UI clearly distinguishes formats
✅ Default is new Mexicano for competitive balance

### Quality

✅ All tests pass
✅ No regression in existing functionality
✅ Code is well documented
✅ User-facing descriptions are clear

### User Experience

✅ Users understand the difference
✅ Can choose appropriate format for their event
✅ Matches feel more balanced with new Mexicano
✅ Social events can still use Social-Mexicano

---

## Conclusion

The rename from "Mexicano" to "Social-Mexicano" for the current implementation, combined with a new "Mexicano" algorithm that prioritizes competitive balance through point-difference limits, provides users with clear choices:

- **Mexicano**: For competitive tournaments where balanced, fair matches are the priority
- **Social-Mexicano**: For social events where meeting variety and interaction are the priority

This change addresses the issue of unbalanced games while preserving the existing variety-focused algorithm for those who prefer it.

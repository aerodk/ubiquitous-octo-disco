# Mexicano Matching Algorithm - Before and After Changes

This document describes the full Mexicano algorithm in steps, before and after the proposed change, as requested in the issue.

---

## BEFORE: Original Mexicano Algorithm (Now Called "Social-Mexicano")

### Algorithm Name: Social-Mexicano (Meeting-Based Variety Pairing)

### Purpose
Maximize social interaction by ensuring players meet and play with/against different people throughout the tournament, even if matches become unbalanced.

### Full Algorithm Steps

#### Step 1: Initialize Player Statistics
For each player, track from all previous rounds:
- Total points scored
- Number of games played
- Partner history: Map of (player ID → times played together)
- Opponent history: Map of (player ID → times faced)
- Pause rounds: List of round numbers when player sat out

#### Step 2: Sort Players by Total Points
- Calculate total points for each player from all completed matches
- Sort all players in descending order (highest points first)
- This creates the current tournament ranking

#### Step 3: Select Break Players (Pause Fairness)
Determine which players sit out based on fair rotation:
1. **Primary criteria**: Fewest pauses (ascending)
   - Players who have sat out less should sit out now
2. **Secondary criteria**: Most games played (descending)
   - Among players with equal pauses, those who played more sit out
3. **Tertiary criteria**: Random selection among equals

Calculate overflow: `overflow = total_players - (courts × 4)`
Select top `overflow` players by these criteria.

#### Step 4: Generate Player Pairs (Meeting-Based)
**Priority Order:**
1. **HIGHEST PRIORITY**: Minimize partner repetition count
2. **LOWER PRIORITY**: Minimize ranking difference (prefer adjacent ranks)

```
For each player P1 in sorted order (rank 1, 2, 3, ...):
    If P1 is not yet paired:
        Find best partner P2 from remaining unpaired players:
            
            Best = player with LOWEST partner_count(P1, P2)
            
            If multiple players have same partner_count:
                Choose player with SMALLEST rank_difference(P1, P2)
            
        Create pair: (P1, P2)
        Mark both as paired
```

**Problem**: This can pair Rank 1 (24 points) with Rank 14 (4 points) if they've never partnered before, creating a 20-point skill gap!

#### Step 5: Match Pairs to Create Games (Opponent History)
**Priority Order:**
1. **HIGHEST PRIORITY**: Minimize total opponent encounters
2. **LOWER PRIORITY**: Sequential pairing (next available pair)

```
For each pair PAIR1 in order:
    If PAIR1 is not yet matched:
        Find best opponent PAIR2 from remaining unmatched pairs:
            
            Calculate opponent_count = sum of:
                - PAIR1.player1 vs PAIR2.player1 encounters
                - PAIR1.player1 vs PAIR2.player2 encounters
                - PAIR1.player2 vs PAIR2.player1 encounters
                - PAIR1.player2 vs PAIR2.player2 encounters
            
            Best = pair with LOWEST opponent_count
            
        Create match: PAIR1 vs PAIR2
        Mark both as matched
```

**Problem**: No consideration of combined team strengths, leading to unbalanced matches!

#### Step 6: Assign Courts
- Sequential: Match 1 → Court 1, Match 2 → Court 2, etc.
- Random: Shuffle court assignments

### Example Scenario Showing The Problem

**Round 2 Setup:**
- Player 1: 24 points (top player)
- Player 2: 22 points
- Player 13: 6 points (weak player)
- Player 14: 4 points (weakest player)

**Round 1 partners:**
- Player 1 partnered with Player 2
- Player 13 partnered with Player 14

**Social-Mexicano Decision for Round 2:**
```
Player 1 seeks partner:
  - Player 2: partner_count = 1 (played together in Round 1)
  - Player 13: partner_count = 0 (never played together)
  
  Result: Pairs Player 1 (24pts) with Player 13 (6pts)
  Skill gap: 18 points! ⚠️
```

**Result:**
- Very unbalanced teams
- Frustrating for competitive players
- One strong + one weak player vs two medium players

---

## AFTER: New Mexicano Algorithm (Point-Based Competitive Pairing)

### Algorithm Name: Mexicano (Point-Based Competitive Pairing)

### Purpose
Create balanced, competitive matches by pairing players with similar skill levels (point totals), ensuring fair and engaging games throughout the tournament.

### Full Algorithm Steps

#### Step 1: Initialize Player Statistics
Same as Social-Mexicano:
- Total points scored
- Number of games played
- Partner history
- Opponent history
- Pause rounds

#### Step 2: Sort Players by Total Points
Same as Social-Mexicano:
- Calculate and sort by total points (descending)

#### Step 3: Select Break Players (Pause Fairness)
Same as Social-Mexicano:
- Fair rotation based on pause history and games played

#### Step 4: Generate Player Pairs (Point-Difference Constrained)
**NEW Priority Order:**
1. **HIGHEST PRIORITY**: Point difference within threshold
2. **MEDIUM PRIORITY**: Minimize ranking difference (prefer adjacent ranks)
3. **LOWER PRIORITY**: Minimize partner repetition count

```
Determine threshold based on round number:
    If round <= 3: threshold = 8 points
    If round <= 5: threshold = 12 points
    If round >= 6: threshold = 16 points

For each player P1 in sorted order:
    If P1 is not yet paired:
        current_threshold = threshold
        best_partner = null
        
        While best_partner is null AND current_threshold <= (threshold × 4):
            For each unpaired player P2:
                point_diff = |P1.points - P2.points|
                
                If point_diff <= current_threshold:
                    rank_diff = |P1.rank - P2.rank|
                    partner_count = partner_count(P1, P2)
                    
                    If P2 is better than current best:
                        (smaller rank_diff, or same rank_diff but lower partner_count)
                        best_partner = P2
            
            If best_partner is null:
                current_threshold += 4  # Relax constraint if needed
        
        If best_partner is still null:
            best_partner = closest available player (fallback)
        
        Create pair: (P1, best_partner)
        Mark both as paired
```

**Key Difference**: Point difference threshold BLOCKS pairing players too far apart in skill!

#### Step 5: Match Pairs to Create Games (Team Balance)
**NEW Priority Order:**
1. **HIGHEST PRIORITY**: Minimize combined team points difference
2. **MEDIUM PRIORITY**: Minimize total opponent encounters
3. **LOWER PRIORITY**: Sequential pairing

```
For each pair PAIR1 in order:
    If PAIR1 is not yet matched:
        combined1 = PAIR1.player1.points + PAIR1.player2.points
        
        Find best opponent PAIR2 from remaining unmatched pairs:
            For each unmatched PAIR2:
                combined2 = PAIR2.player1.points + PAIR2.player2.points
                points_diff = |combined1 - combined2|
                opponent_count = [calculate as before]
                
                Best = pair with:
                    1. LOWEST points_diff
                    2. If points_diff equal, LOWEST opponent_count
            
        Create match: PAIR1 vs PAIR2
        Mark both as matched
```

**Key Difference**: Teams are matched to ensure competitive balance!

#### Step 6: Assign Courts
Same as Social-Mexicano:
- Sequential or random assignment

### Example Scenario Showing The Solution

**Round 2 Setup:**
- Player 1: 24 points (top player)
- Player 2: 22 points
- Player 3: 20 points
- Player 13: 6 points (weak player)
- Player 14: 4 points (weakest player)

**Round 1 partners:**
- Player 1 partnered with Player 2
- Player 13 partnered with Player 14

**New Mexicano Decision for Round 2:**
```
Player 1 seeks partner:
  Threshold = 8 points (Round 2)
  
  - Player 2: point_diff = 2 ✅ (within threshold)
  - Player 3: point_diff = 4 ✅ (within threshold)
  - Player 13: point_diff = 18 ❌ (exceeds threshold - BLOCKED!)
  - Player 14: point_diff = 20 ❌ (exceeds threshold - BLOCKED!)
  
  Among valid candidates (Player 2, Player 3):
    - Player 2: rank_diff = 1, partner_count = 1
    - Player 3: rank_diff = 2, partner_count = 0
  
  Result: Pairs Player 1 (24pts) with Player 2 (22pts)
  Skill gap: 2 points ✅ Balanced!
```

**Result:**
- Balanced teams (top players together)
- Competitive matches
- Fair for all skill levels

### Point Difference Thresholds Explained

**Why thresholds increase over time:**
- **Early rounds (2-3)**: 8 points
  - Players haven't separated much yet
  - Keep pairing tight for fair matches
  
- **Mid rounds (4-5)**: 12 points
  - Some skill separation has occurred
  - Allow moderate differences within emerging tiers
  
- **Late rounds (6+)**: 16 points
  - Clear skill tiers have formed
  - Allow pairing within tiers
  - Still prevents extreme mismatches

**Fallback mechanism:**
- If no partner found within threshold, gradually increase by 4 points
- Ensures tournament can always continue
- Prevents deadlock in edge cases

---

## Comparison Summary

| Aspect | Social-Mexicano (Before) | Mexicano (After) |
|--------|--------------------------|------------------|
| **Primary Goal** | Social variety | Competitive balance |
| **Partner Priority 1** | Avoid repetition | Point difference ≤ threshold |
| **Partner Priority 2** | Close ranking | Close ranking |
| **Partner Priority 3** | N/A | Avoid repetition |
| **Opponent Matching** | Minimize encounters | Balance team points |
| **Point Constraints** | None | Enforced thresholds |
| **Can Pair Extremes?** | Yes (18+ point gap) | No (max ~8-16 pts) |
| **Match Balance** | Variable | Consistent |
| **Social Mixing** | Maximum | Moderate |
| **Best Use Case** | Social events | Competitive tournaments |

---

## When to Use Each Algorithm

### Use Mexicano (New Default) When:
✅ Tournament is competitive in nature
✅ Players care about fair, balanced matches
✅ Skill levels vary significantly
✅ Match quality matters more than variety
✅ Running a league or ranked tournament

### Use Social-Mexicano When:
✅ Tournament is primarily social
✅ Meeting new people is the main goal
✅ Players are casual/recreational
✅ Variety matters more than balance
✅ Running a mixer or social event

### Use Americano When:
✅ Quick, simple setup needed
✅ Pure random fun
✅ Very casual setting
✅ First-time organizers
✅ Small group of friends

---

## Implementation Notes

### Code Files Changed
- **New**: `lib/services/mexicano_algorithm_service.dart` (point-based)
- **Renamed**: `lib/services/social_mexicano_algorithm_service.dart` (meeting-based)
- **Updated**: `lib/services/tournament_service.dart` (supports all 3)
- **Updated**: `lib/models/tournament_settings.dart` (enum updated)
- **Updated**: `lib/widgets/tournament_settings_widget.dart` (UI for 3 formats)

### User Selection
In tournament settings, users now see:
```
○ Mexicano (Anbefalet)
  Konkurrencedygtig balance baseret på point-forskel

○ Social-Mexicano
  Maksimal social variation, undgår gentagelse

○ Americano
  Tilfældig parring
```

### Backward Compatibility
- Existing tournaments continue with their selected format
- Old saved tournaments without explicit format default to Mexicano
- No data migration required

---

## Conclusion

The rename from "Mexicano" to "Social-Mexicano" for the meeting-based algorithm, combined with the new point-based "Mexicano" algorithm, provides users with:

1. **Clarity**: Names clearly indicate the purpose (social vs competitive)
2. **Choice**: Three distinct formats for different tournament styles
3. **Quality**: Better default (Mexicano) for most use cases
4. **Flexibility**: Social-Mexicano still available for social events

This change directly addresses the issue: top and bottom players are no longer paired together just because they haven't met, preventing unbalanced matches in competitive tournaments.

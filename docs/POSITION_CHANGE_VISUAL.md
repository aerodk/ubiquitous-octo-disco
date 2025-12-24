# Position Change Visual Feature

## Overview
This feature displays position/rank changes for players after round 4, helping participants track their tournament progress visually. The position change indicator shows how a player's rank changed in the PREVIOUS round (not the current round).

## Feature Details

### When Position Changes Are Shown
- **Starting from Round 4**: Position changes appear from round 4 onwards (requires at least 3 completed rounds)
- **Comparison**: Shows the rank change that occurred in the previous round (comparing ranks from round N-2 to round N-1)
- **Visual Indicators**: Color-coded badges show the change in ranking
- **One-Round Delay**: Changes from round N are displayed when viewing round N+1

### Visual Design

#### Leaderboard Screen
Position change indicators appear next to player names on the leaderboard:

1. **Green Badge with +N**: Player moved up in rankings in the previous round
   - Example: Player moved from rank 4 to rank 2 in round 3 → Shows green `+2` in round 4
   - Lower rank number = better position
   
2. **Red Badge with -N**: Player moved down in rankings in the previous round
   - Example: Player moved from rank 5 to rank 7 in round 3 → Shows red `-2` in round 4
   - Higher rank number = worse position
   
3. **Black Badge with ±0**: Player maintained same ranking in the previous round
   - Example: Player stayed at rank 3 in round 3 → Shows black `±0` in round 4
   - No change in position

#### Bench/Lane View
The same position change indicators also appear in the bench section for players who are on pause, helping them see how their ranking has changed even while sitting out.

## Implementation Details

### Model Changes
- `PlayerStanding` model now includes:
  - `previousRank`: Optional field storing the player's rank from 2 rounds back (round N-2)
  - `rankOneRoundBack`: Optional field storing the player's rank from 1 round back (round N-1)
  - `rankChange`: Computed getter that calculates the difference (previousRank - rankOneRoundBack)
  - Falls back to (previousRank - currentRank) when rankOneRoundBack is not set (legacy behavior)

### Service Changes
- `StandingsService.calculateStandings()`:
  - For rounds 4+, calculates three sets of standings:
    - Current standings (after all rounds)
    - Standings from 1 round back (for rankOneRoundBack)
    - Standings from 2 rounds back (for previousRank)
  - Maps ranks from both previous rounds to player IDs
  - Applies both previous ranks to current standings for comparison
  
### UI Changes
- **LeaderboardScreen**: 
  - Displays position change badge next to player name
  - Badge styling adapts to top 3 (colored backgrounds) vs regular positions
  
- **BenchPlayerChip**: 
  - Displays position change badge for players on bench
  - Maintains consistent visual language with leaderboard

## Example Scenarios

### Scenario 1: Player Improvement in Round 3, Viewed in Round 4
```
Round 2 Rank: 4
Round 3 Rank: 2
Round 4 Display: Green badge with "+2" (showing the improvement from round 2 to round 3)
Current Rank (Round 4): Could be any rank
```

### Scenario 2: Player Decline in Round 4, Viewed in Round 5
```
Round 3 Rank: 5
Round 4 Rank: 7
Round 5 Display: Red badge with "-2" (showing the decline from round 3 to round 4)
Current Rank (Round 5): Could be any rank
```

### Scenario 3: No Change
```
Round 2 Rank: 3
Round 3 Rank: 3
Round 4 Display: Black badge with "±0"
```

### Scenario 4: Early Rounds
```
Round 1: No badge (need at least 3 completed rounds)
Round 2: No badge (need at least 3 completed rounds)
Round 3: No badge (need at least 3 completed rounds)
Round 4+: Badge appears showing change from round N-2 to round N-1
```

## Technical Notes

### Rank Calculation
- Lower rank number = better position (1st place = rank 1)
- Formula when rankOneRoundBack is set: `rankChange = previousRank - rankOneRoundBack`
- Formula when rankOneRoundBack is null: `rankChange = previousRank - currentRank` (legacy)
  - Positive value = improvement (moved up)
  - Negative value = decline (moved down)
  - Zero = no change

### Data Flow
1. Tournament service generates rounds
2. Standings service calculates current standings
3. If round 4+, standings service also calculates:
   - Standings from 2 rounds back (for previousRank)
   - Standings from 1 round back (for rankOneRoundBack)
4. Both previous ranks are attached to current standings
5. UI components display rank changes using the `rankChange` getter

## Testing
- Unit tests verify rank change calculation logic
- Tests cover edge cases: first rounds, no change, improvements, declines
- Tests verify the one-round delay behavior
- Widget tests ensure proper display of position change indicators

## Future Enhancements
Potential improvements could include:
- Historical rank tracking across all rounds (not just previous two)
- Trend indicators (consistently improving/declining over multiple rounds)
- Position change animations
- Detailed rank history view per player

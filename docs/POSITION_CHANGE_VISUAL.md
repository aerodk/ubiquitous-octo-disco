# Position Change Visual Feature

## Overview
This feature displays position/rank changes for players after round 3, helping participants track their tournament progress visually.

## Feature Details

### When Position Changes Are Shown
- **Starting from Round 3**: Position changes appear from round 3 onwards
- **Comparison**: Each player's current rank is compared with their rank from the previous round
- **Visual Indicators**: Color-coded badges show the change in ranking

### Visual Design

#### Leaderboard Screen
Position change indicators appear next to player names on the leaderboard:

1. **Green Badge with +N**: Player moved up in rankings
   - Example: Player moved from rank 4 to rank 2 → Shows green `+2`
   - Lower rank number = better position
   
2. **Red Badge with -N**: Player moved down in rankings
   - Example: Player moved from rank 5 to rank 7 → Shows red `-2`
   - Higher rank number = worse position
   
3. **Black Badge with ±0**: Player maintained same ranking
   - Example: Player stayed at rank 3 → Shows black `±0`
   - No change in position

#### Bench/Lane View
The same position change indicators also appear in the bench section for players who are on pause, helping them see how their ranking has changed even while sitting out.

## Implementation Details

### Model Changes
- `PlayerStanding` model now includes:
  - `previousRank`: Optional field storing the player's rank from the previous round
  - `rankChange`: Computed getter that calculates the difference (previousRank - currentRank)

### Service Changes
- `StandingsService.calculateStandings()`:
  - For rounds 3+, calculates standings for the previous round
  - Maps previous ranks to player IDs
  - Applies previous ranks to current standings for comparison
  
### UI Changes
- **LeaderboardScreen**: 
  - Displays position change badge next to player name
  - Badge styling adapts to top 3 (colored backgrounds) vs regular positions
  
- **BenchPlayerChip**: 
  - Displays position change badge for players on bench
  - Maintains consistent visual language with leaderboard

## Example Scenarios

### Scenario 1: Player Improvement
```
Round 2 Rank: 4
Round 3 Rank: 2
Display: Green badge with "+2"
```

### Scenario 2: Player Decline
```
Round 2 Rank: 5
Round 3 Rank: 7
Display: Red badge with "-2"
```

### Scenario 3: No Change
```
Round 2 Rank: 3
Round 3 Rank: 3
Display: Black badge with "±0"
```

### Scenario 4: Early Rounds
```
Round 1: No badge (no previous rank)
Round 2: No badge (only shown from round 3+)
Round 3+: Badge appears showing change from previous round
```

## Technical Notes

### Rank Calculation
- Lower rank number = better position (1st place = rank 1)
- Formula: `rankChange = previousRank - currentRank`
  - Positive value = improvement (moved up)
  - Negative value = decline (moved down)
  - Zero = no change

### Data Flow
1. Tournament service generates rounds
2. Standings service calculates current standings
3. If round 3+, standings service also calculates previous standings
4. Previous ranks are attached to current standings
5. UI components display rank changes using the `rankChange` getter

## Testing
- Unit tests verify rank change calculation logic
- Tests cover edge cases: first rounds, no change, improvements, declines
- Widget tests ensure proper display of position change indicators

## Future Enhancements
Potential improvements could include:
- Historical rank tracking across all rounds (not just previous)
- Trend indicators (consistently improving/declining over multiple rounds)
- Position change animations
- Detailed rank history view per player

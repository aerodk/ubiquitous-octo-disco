# Lane Matchup Reasoning Feature

## Overview
This feature adds the ability to view detailed reasoning about why players were paired together in a specific match and why the match was assigned to a particular court/lane.

## How to Use

### Viewing Matchup Reasoning
There is an information icon (ℹ️) button in the header of each match card. Click this button to view:

1. **Round Type**: Whether this is the first round, a regular round, or the final round
2. **Player Pairing**: How and why these four players were grouped together
3. **Lane Assignment**: Why this match was placed on this specific court
4. **Player Details**: (For final rounds) The ranking of each player in the match

## Reasoning Details by Round Type

### First Round (🎲)
- **Pairing Method**: Players are shuffled randomly and grouped into teams of 4
- **Purpose**: Ensures a fair and unpredictable start to the tournament
- **Lane Assignment**: Either sequential (best for organization) or random (for variety)

### Regular Round (🔄)
- **Pairing Method**: Players are shuffled after selecting who should pause
- **Pause Selection**: Based on fairness - players with fewer pauses and more games played get priority to sit out
- **Purpose**: Distributes breaks fairly among all players
- **Lane Assignment**: Either sequential or random based on tournament settings

### Final Round (🏆)
- **Pairing Method**: Rank-based pairing using one of three strategies:
  - **Balanced** (Default): Rank 1+3 vs Rank 2+4
  - **Top Alliance**: Rank 1+2 vs Rank 3+4
  - **Max Competition**: Rank 1+4 vs Rank 2+3
- **Player Rankings**: Shows each player's current rank in the tournament
- **Purpose**: Creates exciting and competitive final matches based on tournament standings
- **Lane Assignment**: Either sequential (top-ranked players on first courts) or random

## Lane Assignment Strategies

### Sequential Assignment
- Matches are assigned to courts in order
- Top-ranked players (in final round) or first matches get the first courts
- Provides consistency and makes it easy to find matches

### Random Assignment
- Courts are shuffled before assignment
- Adds variety and ensures no positional bias
- All courts are used equally over time

## Manual Overrides
If a player is manually forced to play or pause during a round, the reasoning will indicate:
- Which player was moved
- Whether they were forced to play or pause
- That this was a manual adjustment

## Benefits
- **Transparency**: Understand the tournament algorithm
- **Fairness**: See that pairing and breaks are distributed equitably
- **Learning**: Understand different pairing strategies in final rounds
- **Trust**: Build confidence in the automated tournament management

## Technical Details
- Reasoning is generated when matches are created
- Stored with each match for future reference
- Persists across tournament saves/loads
- Accessible at any time during the tournament

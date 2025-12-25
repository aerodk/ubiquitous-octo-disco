# Standings Feature Guide

## Overview
This document describes the improved standings view features added to the Leaderboard screen.

## New Features

### 1. Compact View Toggle

A toggle button has been added to the app bar that allows users to switch between detailed and compact views of the standings.

**Location:** App bar (top right, before the export button)

**Icons:**
- Detailed view active: Shows `view_compact` icon
- Compact view active: Shows `view_list` icon

### 2. Compact Standings View

When compact view is enabled, each player's standing is displayed in a single line with essential information.

**Format:** `Rank. Name - W/L - Points`

**Example:**
```
3. John - 2W/1L - 32 pt
```

**Features:**
- Rank number followed by a period
- Player name
- Win/Loss record (e.g., "2W/1L")
- Total points with "pt" suffix
- Position change indicator (if applicable)
- Same color coding for top 3 positions as detailed view

### 3. Game History Dialog

Long pressing on any player card (in either detailed or compact view) opens a dialog showing that player's complete game history.

**How to use:** Long press on any player's name card

**Dialog Contents:**
- Dialog title: "[Player Name] - Game History"
- List of all games played by that player
- Each game shows:
  - Round number
  - Partner's name (who they played with)
  - Opponents' names (who they played against)
  - Match score
  - Result (Won/Lost/Draw) with color coding:
    - Green for wins
    - Red for losses
    - Grey for draws

**Example Game Entry:**
```
Round 1
Played with: Sarah
Against: Mike & Tom
Score: 20 - 15
Result: Won (in green)
```

## Implementation Details

### File Modified
- `lib/screens/leaderboard_screen.dart`

### Key Changes

1. **StatefulWidget Conversion**
   - Changed from `StatelessWidget` to `StatefulWidget` to manage toggle state

2. **New State Variable**
   - `_isCompactView`: Boolean flag to track current view mode

3. **New Methods**
   - `_buildCompactStandingCard()`: Renders the compact view card
   - `_showGameHistoryDialog()`: Displays the game history dialog
   - `_getGameHistoryForPlayer()`: Gathers game history data for a specific player

4. **Modified Methods**
   - `_buildStandingCard()`: Wrapped in `GestureDetector` for long press handling
   - `build()`: Added toggle button and conditional rendering based on view mode

## Testing

New tests have been added to verify:
1. View toggle functionality works correctly
2. Compact view displays the correct format
3. Game history dialog appears on long press
4. Game history shows correct information (rounds, partners, opponents, scores)

**Test File:** `test/leaderboard_screen_test.dart`

## User Experience

### Detailed View (Default)
- Shows comprehensive statistics
- Large cards with multiple rows of information
- Ideal for in-depth analysis

### Compact View
- Shows only essential information
- Smaller cards, more players visible at once
- Ideal for quick overview of standings

### Game History
- Available in both views via long press
- Provides complete match history for any player
- Helps users understand individual player performance
- Shows partnership patterns and head-to-head results

## Future Enhancements (Potential)

- Filter game history by round range
- Export individual player statistics
- Compare two players side-by-side
- Show win rate against specific opponents
- Graph of performance over rounds

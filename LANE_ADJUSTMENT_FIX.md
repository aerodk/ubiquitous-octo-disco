# Lane Adjustment Issue Fix

## Problem Statement

When lanes (courts) are adjusted in the round display screen:
1. **Decreasing lanes**: Players moved to pause were not visually emphasized in the pause box
2. **Adding lanes**: No validation to ensure enough players are available to fill the additional lane

## Solution

### 1. Visual Emphasis for Newly Paused Players

When a court is removed and players are moved to pause, they are now highlighted with:
- **Bold text** for the player name
- **Orange background** on the ActionChip (using `Colors.orange[200]`)
- **"New releases" icon** (🔶) next to the player name

This makes it immediately clear which players were just moved to pause due to the court removal.

### 2. Validation for Adding Courts

Before allowing a court to be added, the system now checks:
- Must have at least **4 players on pause** (enough to fill a new court with 2 teams of 2)
- If less than 4 players are on pause, the "Tilføj bane" (Add court) button is disabled
- A clear error message is shown if the user tries to add a court without enough paused players

### 3. Implementation Details

**State Tracking:**
- Added `_newlyPausedPlayerIds` Set to track which players were just moved to pause
- This set is populated when a court is removed
- It's cleared when:
  - A court is added (reducing pause)
  - A player's status is manually overridden
  - A new round is generated (new screen instance)

**UI Changes:**
- Updated the pause section to check if each player is in the newly paused set
- Applied conditional styling based on the newly paused status
- Updated the "Tilføj bane" button condition to include the pause count check

**Code Location:**
- File: `lib/screens/round_display_screen.dart`
- Key methods:
  - `_addCourt()`: Added validation check
  - `_removeCourt()`: Added tracking of newly paused players
  - `_overridePlayerPauseStatus()`: Clear tracking after manual override
  - Build method: Updated pause section UI

## Testing

Created comprehensive tests in `test/lane_adjustment_test.dart`:
- ✅ Test that add court button is enabled when 4+ players on pause
- ✅ Test that add court button is disabled when <4 players on pause
- ✅ Test pause section display functionality
- ✅ Test newly paused player visual emphasis

## User Experience

### Before Court Removal:
```
Baner: 3
Pause: (empty)
[Tilføj bane] [Fjern bane]
```

### After Removing 1 Court:
```
Baner: 2
Pause: 
  [**Player 9** 🔶] [**Player 10** 🔶] [**Player 11** 🔶] [**Player 12** 🔶]
  (orange background, bold text, new icon)
[Tilføj bane] [Fjern bane]
```

### When Adding Court Is Not Possible:
```
Baner: 2
Pause: [Player 5] [Player 6]  (only 2 players)
[Tilføj bane (disabled)] [Fjern bane]

Error message: "Kan ikke tilføje bane: Kun 2 spillere på pause. 
Der skal være mindst 4 spillere på pause for at tilføje en bane."
```

## Backward Compatibility

- All changes are backward compatible
- No data model changes required
- Visual emphasis is purely UI-based and doesn't affect tournament logic
- Existing tournaments will work without any migration

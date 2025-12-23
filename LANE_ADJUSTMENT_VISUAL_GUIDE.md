# Lane Adjustment Feature - Visual Guide

## Overview
This document provides a visual description of how the lane adjustment feature improvements work.

## Issue #1: Validation When Adding Courts

### Before the Fix
Users could attempt to add a court even when there weren't enough players on pause to fill it, leading to confusion.

### After the Fix
The "Tilføj bane" (Add court) button is now **disabled** when there are fewer than 4 players on pause.

#### UI State Examples:

**Scenario 1: Enough players on pause (4+) - Button ENABLED**
```
┌─────────────────────────────────────────┐
│ 🎾 Bane håndtering          2 baner     │
│                                         │
│ [✓ Tilføj bane] [✓ Fjern bane]         │
│   (green)         (red)                 │
└─────────────────────────────────────────┘

Pause section shows:
┌─────────────────────────────────────────┐
│ ⏸ Pause                                 │
│                                         │
│ [Player 9] [Player 10] [Player 11] [Player 12] │
└─────────────────────────────────────────┘
```

**Scenario 2: Not enough players (2) - Button DISABLED**
```
┌─────────────────────────────────────────┐
│ 🎾 Bane håndtering          2 baner     │
│                                         │
│ [✗ Tilføj bane] [✓ Fjern bane]         │
│   (grayed out)    (red)                 │
└─────────────────────────────────────────┘

Pause section shows:
┌─────────────────────────────────────────┐
│ ⏸ Pause                                 │
│                                         │
│ [Player 9] [Player 10]                  │
└─────────────────────────────────────────┘

If user tries to click (shouldn't be possible):
⚠️ "Kan ikke tilføje bane: Kun 2 spillere på pause. 
    Der skal være mindst 4 spillere på pause for at tilføje en bane."
```

## Issue #2: Visual Emphasis for Newly Paused Players

### Before the Fix
When a court was removed, players moved to pause looked identical to players who were already on pause. Users couldn't tell who was just moved.

### After the Fix
Newly paused players are highlighted with:
1. **Bold text** for the name
2. **Orange background** (Colors.orange[200])
3. **🔶 New icon** next to the name

#### Visual Comparison:

**Before Removing a Court:**
```
Baner: 3

Pause section: (empty)
```

**Immediately After Removing a Court:**
```
Baner: 2

┌─────────────────────────────────────────────────────────┐
│ ⏸ Pause                                                 │
│                                                         │
│ [▶ **Player 9** 🔶]  [▶ **Player 10** 🔶]             │
│    (orange bg, bold)     (orange bg, bold)             │
│                                                         │
│ [▶ **Player 11** 🔶] [▶ **Player 12** 🔶]             │
│    (orange bg, bold)     (orange bg, bold)             │
└─────────────────────────────────────────────────────────┘
```

**After Another Action (emphasis cleared):**
```
If user manually moves a player or generates next round,
the orange highlighting is cleared:

┌─────────────────────────────────────────────────────────┐
│ ⏸ Pause                                                 │
│                                                         │
│ [▶ Player 9]  [▶ Player 10]  [▶ Player 11]  [▶ Player 12] │
│    (normal)       (normal)       (normal)       (normal)│
└─────────────────────────────────────────────────────────┘
```

**Mixed Scenario (some already on pause, some newly paused):**
```
Starting state:
- 2 courts
- 2 players already on pause (Player 5, Player 6)

After removing 1 court:
- 1 court
- 6 players on pause (2 original + 4 new)

┌──────────────────────────────────────────────────────────────┐
│ ⏸ Pause                                                      │
│                                                              │
│ [▶ Player 5]     [▶ Player 6]     [▶ **Player 7** 🔶]       │
│    (normal)         (normal)          (orange, bold)        │
│                                                              │
│ [▶ **Player 8** 🔶]  [▶ **Player 9** 🔶]  [▶ **Player 10** 🔶] │
│    (orange, bold)       (orange, bold)       (orange, bold) │
└──────────────────────────────────────────────────────────────┘

Legend:
- Normal chips: Players who were already on pause
- Orange chips with 🔶: Players just moved to pause due to court removal
```

## User Interaction Flow

### Adding a Court (Success)
1. User sees "Bane håndtering" section
2. Checks that 4+ players are on pause
3. "Tilføj bane" button is enabled (green)
4. User clicks button
5. Confirmation dialog appears: "Er du sikker på at du vil tilføje en ny bane?"
6. User confirms
7. Round is regenerated with new court
8. Some paused players are now playing
9. Success message: "Bane 3 tilføjet"

### Adding a Court (Validation Failure)
1. User sees "Bane håndtering" section
2. Only 2-3 players are on pause
3. "Tilføj bane" button is disabled (grayed out)
4. User cannot click (button is inactive)
5. If they somehow trigger it, error message appears:
   "Kan ikke tilføje bane: Kun X spillere på pause. 
    Der skal være mindst 4 spillere på pause for at tilføje en bane."

### Removing a Court
1. User clicks "Fjern bane" (always enabled if >1 court and no scores)
2. Confirmation dialog: "Er du sikker på at du vil fjerne Bane X?"
3. User confirms
4. Round is regenerated with fewer courts
5. **4 players are moved to pause** (highlighted with orange + 🔶)
6. Success message: "Bane X fjernet"
7. User can clearly see which players were just moved to pause

## Technical Implementation

### State Variable
```dart
Set<String> _newlyPausedPlayerIds = {};
```
- Stores player IDs of newly paused players
- Cleared when: adding court, manual override, or new round

### Validation Logic
```dart
// In _addCourt():
if (_currentRound.playersOnBreak.length < 4) {
  // Show error and return
}
```

### UI Rendering
```dart
// In pause section:
final isNewlyPaused = _newlyPausedPlayerIds.contains(player.id);
ActionChip(
  label: Row(
    children: [
      Text(
        player.name,
        style: TextStyle(
          fontWeight: isNewlyPaused ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      if (isNewlyPaused) ...[
        SizedBox(width: 4),
        Icon(Icons.new_releases, size: 16, color: Colors.deepOrange),
      ],
    ],
  ),
  backgroundColor: isNewlyPaused ? Colors.orange[200] : null,
  ...
)
```

## Accessibility Notes

- Bold text makes newly paused players easier to spot for users with visual impairments
- Orange background provides clear color distinction
- Icon provides visual redundancy (not just color-dependent)
- All chips remain interactive (can click to force player to play)

## Edge Cases Handled

1. **No players on pause**: Pause section not shown, add button disabled
2. **Exactly 4 players on pause**: Add button enabled
3. **All players on pause**: Cannot happen (need minimum players for matches)
4. **Manual override after court change**: Clears newly paused highlighting
5. **Next round generation**: New screen instance, highlighting resets
6. **Multiple court removals**: Each removal tracks its newly paused players

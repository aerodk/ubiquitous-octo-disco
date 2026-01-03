# Edit Button Removal from Match Card Header

## Issue
The edit button in the match card header was causing confusion by providing an additional way to enter scores that defaulted to Team 1. This was not intuitive and could lead to users accidentally opening the score dialog when they intended to just read the court name.

## Change Made
Removed the edit IconButton from the match card header, leaving only the info button for viewing matchup reasoning.

## Visual Change

### BEFORE
```
╔═══════════════════════════════════════════════╗
║ 🎾 BANE 1                   [✏️] [ℹ️]        ║  ← Edit + Info buttons
╠═══════════════════════════════════════════════╣
```

### AFTER
```
╔═══════════════════════════════════════════════╗
║ 🎾 BANE 1                        [ℹ️]        ║  ← Info button only
╠═══════════════════════════════════════════════╣
```

## Score Entry Methods (After Change)

Users can still enter/edit scores by tapping on:

1. **Team 1 (left side)**: Tap anywhere on the left team section (players or score)
   - Opens score dialog with Team 1 as the active input
   - Other team's score is calculated automatically

2. **Team 2 (right side)**: Tap anywhere on the right team section (players or score)
   - Opens score dialog with Team 2 as the active input
   - Other team's score is calculated automatically

## Technical Details

### Files Modified
- `lib/widgets/match_card.dart` (5 lines removed)
  - Removed edit IconButton from header (lines 107-111)
- `test/widgets/match_card_test.dart` (2 lines changed)
  - Updated test to verify info button instead of edit button

### Code Changes
The edit button code was removed from the header Row:
```dart
// REMOVED:
IconButton(
  icon: Icon(Icons.edit, color: AppColors.textLight, size: 24 * sizeScale),
  onPressed: () => _showScoreInput(),
  tooltip: 'Indtast score',
),
```

Score entry functionality is preserved through `TeamSide` widget's `onScoreTap` callback:
- Team 1: `onScoreTap: widget.isReadOnly ? null : () => _showScoreInput(isTeam1: true)`
- Team 2: `onScoreTap: widget.isReadOnly ? null : () => _showScoreInput(isTeam1: false)`

## Benefits
1. **Simpler UI**: One less button in the header reduces visual clutter
2. **Clearer Intent**: Users tap on the team they want to score for, making the interaction more intuitive
3. **Prevents Confusion**: No default team selection when opening score dialog
4. **Consistent UX**: Score entry is always contextual to the team being tapped

## Backwards Compatibility
- Read-only mode still prevents score entry (via `isReadOnly` flag)
- All existing score entry functionality is preserved
- No breaking changes to the public API

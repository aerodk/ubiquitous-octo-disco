# Score Entry Fix - Implementation Summary

## Issue Description
When pressing on a match card to enter a score, the score dialog always showed both teams' input buttons regardless of which side was pressed. Users expected that:
- Pressing on the **left side (Team 1)** should focus on Team 1's score entry
- Pressing on the **right side (Team 2)** should focus on Team 2's score entry
- The other team's score should be automatically calculated

## Solution Overview
Made the score entry dialog **context-aware** by:
1. Tracking which team's score display was tapped
2. Showing focused input for the selected team
3. Displaying the calculated score for the other team (read-only)

## Changes Made

### 1. Modified `_showScoreInput` Method
**File**: `lib/widgets/match_card.dart`

```dart
// Before
void _showScoreInput() {
  showDialog(
    context: context,
    builder: (context) => ScoreInputDialog(
      match: widget.match,
      maxPoints: widget.maxPoints,
    ),
  ).then(...);
}

// After
void _showScoreInput({bool isTeam1 = true}) {
  showDialog(
    context: context,
    builder: (context) => ScoreInputDialog(
      match: widget.match,
      maxPoints: widget.maxPoints,
      selectedTeamIsTeam1: isTeam1,  // NEW: Pass which team was selected
    ),
  ).then(...);
}
```

### 2. Updated Team Side Callbacks
**File**: `lib/widgets/match_card.dart`

```dart
// Team 1 (Left side)
TeamSide(
  team: widget.match.team1,
  label: 'PAR 1',
  score: widget.match.team1Score,
  onScoreTap: () => _showScoreInput(isTeam1: true),  // NEW: Specify team 1
),

// Team 2 (Right side)
TeamSide(
  team: widget.match.team2,
  label: 'PAR 2',
  score: widget.match.team2Score,
  onScoreTap: () => _showScoreInput(isTeam1: false),  // NEW: Specify team 2
),
```

### 3. Enhanced ScoreInputDialog
**File**: `lib/widgets/match_card.dart`

#### Added Parameter
```dart
class ScoreInputDialog extends StatefulWidget {
  final Match match;
  final int maxPoints;
  final bool selectedTeamIsTeam1;  // NEW: Track selected team

  const ScoreInputDialog({
    super.key,
    required this.match,
    this.maxPoints = 24,
    this.selectedTeamIsTeam1 = true,  // NEW: Default to team 1
  });
```

#### Updated UI Logic
The dialog now:
- Shows **active input** section for the selected team with visual indicators:
  - "Vælg score" (Select score) label with touch icon
  - Full color scheme
  - Interactive score buttons
  
- Shows **auto-calculated** section for the other team:
  - "Automatisk" (Automatic) label with calculator icon
  - Dimmed/transparent styling
  - Read-only score display
  - No interactive buttons

#### Simplified Score Selection
```dart
// Before
void _selectScore(bool isTeam1, int score) {
  setState(() {
    if (isTeam1) {
      _team1Score = score;
      _team2Score = widget.maxPoints - score;
    } else {
      _team2Score = score;
      _team1Score = widget.maxPoints - score;
    }
    popClose();
  });
}

// After
void _selectScore(int score) {
  setState(() {
    if (widget.selectedTeamIsTeam1) {
      _team1Score = score;
      _team2Score = widget.maxPoints - score;
    } else {
      _team2Score = score;
      _team1Score = widget.maxPoints - score;
    }
    popClose();
  });
}
```

### 4. Added Tests
**File**: `test/widgets/match_card_test.dart`

Added new widget tests:
1. `should open score dialog for team 1 when team 1 score is tapped` - Verifies dialog opens with correct context
2. `should calculate other team score automatically when score is selected` - Verifies automatic calculation and dialog closure

## User Experience Improvements

### Before
1. User taps on left side (Team 1)
2. Dialog shows TWO sets of score buttons (Team 1 AND Team 2)
3. Confusing which team's score to enter
4. User must manually select the correct team's buttons

### After
1. User taps on **left side (Team 1)**
2. Dialog shows ONLY Team 1's score buttons with "Vælg score" indicator
3. Team 2's calculated score shown in dimmed section with "Automatisk" label
4. Clear and intuitive - user knows exactly what to do

1. User taps on **right side (Team 2)**
2. Dialog shows ONLY Team 2's score buttons with "Vælg score" indicator
3. Team 1's calculated score shown in dimmed section with "Automatisk" label
4. Consistent experience across both teams

## Technical Details

### Auto-calculation Logic
- Total points per match is configurable (default 24)
- When user selects score X for selected team:
  - Selected team score = X
  - Other team score = (maxPoints - X)
- Example: If maxPoints=24 and user selects 18:
  - Team 1 score = 18
  - Team 2 score = 6

### Visual Indicators
The dialog uses different styling to clearly distinguish:

**Active (Selected) Team:**
- Full brightness colors
- Border: `AppColors.courtBorder` (solid)
- Background: `AppColors.courtBackgroundLight`
- Score display: `AppColors.scoreEntered` (green)
- Icon: Touch app icon
- Label: "Vælg score" (italic, highlighted)

**Automatic (Calculated) Team:**
- Dimmed colors (with `.withOpacity(0.5)` and `.withOpacity(0.3)`)
- Border: `AppColors.courtBorder.withOpacity(0.3)` (transparent)
- Background: `AppColors.scoreEmpty.withOpacity(0.5)` (semi-transparent)
- Score display: `AppColors.teamLabel.withOpacity(0.3)` (dimmed)
- Icon: Calculator icon
- Label: "Automatisk" (italic, muted)

## Backwards Compatibility
- The header "Edit" button still defaults to Team 1 (`isTeam1: true`)
- Existing behavior preserved for programmatic dialog opening
- No breaking changes to public API

## Testing Notes
Due to Flutter SDK not being available in the CI environment, manual testing is recommended:
1. Run the app: `flutter run -d chrome`
2. Create a tournament and start a round
3. Tap on the **left** team's score → verify Team 1 input is active
4. Tap on the **right** team's score → verify Team 2 input is active
5. Select a score → verify other team's score is calculated correctly
6. Verify dialog closes automatically after selection

## Specification Compliance
This implementation aligns with the specification in `docs/SPECIFICATION.md`:

> **F-005: Score Input per Kamp**
> - Der skal vises runde knapper med score fra 0-24 efter tryk på en side af banen.
> - Den anden side skal udregnes automatisk.

Translation: "Round buttons with scores from 0-24 should be shown after pressing on one side of the court. The other side should be calculated automatically."

✅ **Fully implemented** - The dialog now shows buttons only for the selected team, and the other team's score is calculated automatically.

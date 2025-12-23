# Lane Adjustment Feature - Implementation Summary

## Overview
This document describes the implementation of the lane adjustment feature, which allows users to control how matches are distributed across courts (lanes) and dynamically adjust the number of courts during a tournament.

## Features Implemented

### 1. Lane Assignment Strategies

Two strategies have been implemented for assigning matches to courts:

#### Sequential Assignment (Default)
- Best ranked players are assigned to the first lanes
- Match 1 → Lane 1, Match 2 → Lane 2, etc.
- Provides predictable court assignments
- Useful when certain courts are preferred (e.g., better lighting, visibility)

#### Random Assignment
- Matches are randomly distributed across lanes
- Ensures fair court distribution over time
- No court preferences are given
- Useful when all courts are equal quality

### 2. Dynamic Court Adjustment

Users can now add or remove courts during a tournament:

#### Add Court
- Adds a new court to the tournament
- Regenerates the current round with more courts
- May reduce the number of players on pause
- Disabled when scores have been entered

#### Remove Court
- Removes the last court from the tournament
- Regenerates the current round with fewer courts
- May increase the number of players on pause
- Disabled when scores have been entered
- Cannot go below minimum court count (1)

## Implementation Details

### Model Changes

#### `lib/models/tournament_settings.dart`

Added new enum:
```dart
enum LaneAssignmentStrategy {
  sequential,  // Best players on first lanes (default)
  random,      // Random lane distribution
}
```

Updated `TournamentSettings` class:
- Added `laneAssignmentStrategy` field with default value `LaneAssignmentStrategy.sequential`
- Updated JSON serialization to include lane assignment strategy
- Updated `copyWith`, `isCustomized`, `summary`, and equality methods
- Added helper methods `_laneStrategyName`, `_laneStrategyFromString`, `_laneStrategyToString`

### Service Changes

#### `lib/services/tournament_service.dart`

Added new method:
```dart
List<Match> _assignCourtsToMatches(
  List<Match> matches,
  List<Court> courts,
  LaneAssignmentStrategy strategy,
)
```

Updated existing methods to accept `laneStrategy` parameter:
- `generateFirstRound(players, courts, {laneStrategy})`
- `generateNextRound(players, courts, standings, roundNumber, {laneStrategy})`
- `generateFinalRound(courts, standings, roundNumber, {strategy, laneStrategy})`
- `regenerateRoundWithOverride({..., laneStrategy})`

### UI Changes

#### `lib/widgets/tournament_settings_widget.dart`

Added new section for lane assignment:
```dart
Widget _buildLaneAssignmentSection(ThemeData theme)
```

Features:
- Radio buttons for selecting strategy
- Danish translations
- Integrated into tournament settings widget

#### `lib/screens/round_display_screen.dart`

Added court management section with:
- Display of current court count
- "Tilføj bane" (Add court) button
- "Fjern bane" (Remove court) button
- Visual feedback and confirmations
- Automatic round regeneration

Added new methods:
```dart
Future<void> _addCourt()
Future<void> _removeCourt()
```

### Test Coverage

#### `test/tournament_settings_test.dart`

Added tests for:
- LaneAssignmentStrategy enum validation
- Default values include sequential strategy
- Custom values can be set
- JSON serialization includes lane strategy
- Deserialization handles missing/invalid values
- Summary includes lane strategy display

#### `test/tournament_service_test.dart`

Added comprehensive test group "Lane Assignment Strategy":
- Sequential strategy assigns courts in order
- Random strategy varies court assignments
- Lane strategy applies to `generateNextRound`
- Lane strategy applies to `generateFinalRound`
- Lane strategy applies to `regenerateRoundWithOverride`

## User Guide

### Configuring Lane Assignment

1. On the setup screen, expand "Turnering indstillinger" (Tournament settings)
2. Scroll to "Bane fordeling" (Lane distribution)
3. Select your preferred strategy:
   - **Sekventiel**: Best players on lane 1, next best on lane 2, etc.
   - **Tilfældig**: Random distribution across all lanes

### Adding a Court

1. Navigate to the round display screen
2. Locate the "Bane håndtering" (Lane management) section
3. Click "Tilføj bane" (Add court)
4. Confirm the action in the dialog
5. The current round will be regenerated with the new court

**Note**: This can only be done before any scores are entered in the current round.

### Removing a Court

1. Navigate to the round display screen
2. Locate the "Bane håndtering" (Lane management) section
3. Click "Fjern bane" (Remove court)
4. Confirm the action in the dialog
5. The current round will be regenerated with fewer courts

**Note**: This can only be done before any scores are entered in the current round.

## Backward Compatibility

- All changes are backward compatible
- Existing tournaments will default to sequential lane assignment
- JSON serialization includes default values for missing fields
- No data migration required

## Technical Notes

### Lane Assignment Algorithm

The `_assignCourtsToMatches` method:
1. Takes a list of matches and courts
2. Based on strategy, assigns courts:
   - **Sequential**: Matches assigned to courts in order (match index % court count)
   - **Random**: Courts are shuffled, then assigned in order
3. Returns a new list of matches with court assignments

### Round Regeneration

When courts are added or removed:
1. Validation checks (no scores entered, within min/max limits)
2. Confirmation dialog shown
3. Current standings calculated
4. New round generated with updated court list
5. Tournament updated with new court list and round
6. Changes persisted to storage
7. UI refreshed

## Future Enhancements

Potential improvements for future versions:
- Custom court ordering (drag and drop)
- Court quality ratings
- Court-specific statistics
- Court availability scheduling
- Named court preferences per player

## Testing Recommendations

When testing this feature:
1. Test lane assignment in first round
2. Test lane assignment in regular rounds
3. Test lane assignment in final round
4. Test adding courts with different player counts
5. Test removing courts with different player counts
6. Test boundary conditions (min/max courts)
7. Test with scores entered (should be disabled)
8. Test persistence across app restarts

## Related Files

- `lib/models/tournament_settings.dart`
- `lib/services/tournament_service.dart`
- `lib/widgets/tournament_settings_widget.dart`
- `lib/screens/round_display_screen.dart`
- `lib/screens/setup_screen.dart`
- `test/tournament_settings_test.dart`
- `test/tournament_service_test.dart`

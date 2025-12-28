# Lane/Court Naming Feature

## Overview
This feature allows users to customize court/lane names on the setup screen. The custom names are used throughout the tournament and persist across sessions.

## User Guide

### How to Rename Courts

1. **Setup Screen**: After adding players and selecting the number of courts, a list of courts appears below the court count selector.

2. **Court List Display**:
   - Each court is shown with its current name (default: "Bane 1", "Bane 2", etc.)
   - Courts with custom names have a blue background
   - An edit icon button appears on the right side of each court

3. **Rename Dialog**:
   - Click the edit icon (pencil) next to any court
   - A dialog appears with the current name pre-filled
   - Enter a new custom name (e.g., "Center Court", "Main Court", "Court A")
   - Click "Gem" (Save) to apply the new name
   - Click "Nulstil til standard" (Reset to default) to restore the default name
   - Click "Annuller" (Cancel) to close without changes

4. **Persistence**:
   - Custom court names are automatically saved to local storage
   - Names persist when you close and reopen the app
   - Names are cleared when you use "Ryd alle" (Clear all) button
   - Custom names are used when generating the first round

5. **Usage in Tournament**:
   - Renamed courts appear in the round display screen
   - Court names are shown in the header of each match card
   - Custom names remain consistent throughout all rounds

## Technical Implementation

### Key Components

#### Setup Screen (`lib/screens/setup_screen.dart`)
- **`_courtCustomNames`**: Map<int, String> tracking custom names by court index
- **`_renameCourtDialog(int courtIndex)`**: Shows dialog for renaming a specific court
- **Court List UI**: ListView.builder displaying courts with edit buttons
- **Visual Indicator**: Blue background for courts with custom names

#### Persistence Service (`lib/services/persistence_service.dart`)
- **Storage Key**: `setup_court_names` (SharedPreferences)
- **Save**: Converts Map<int, String> to JSON for storage
- **Load**: Restores custom names when loading saved state
- **Clear**: Removes custom names when clearing setup state

#### Court Model (`lib/models/court.dart`)
- No changes needed - already supports custom names via `name` property
- Courts are created with custom names when tournament starts

### Data Flow

1. **User Renames Court**:
   ```
   User clicks edit → Dialog opens → User enters name → 
   State updated → Auto-saved to SharedPreferences
   ```

2. **Loading Saved State**:
   ```
   App starts → Load from SharedPreferences → 
   Restore players, court count, and custom names → Display in UI
   ```

3. **Starting Tournament**:
   ```
   User clicks "Generer Første Runde" → 
   Generate courts with custom or default names → 
   Create tournament → Navigate to round display
   ```

## Testing

### Manual Test Cases

#### Test 1: Basic Renaming
1. Open setup screen
2. Add 4+ players
3. Set courts to 2
4. Click edit icon on "Bane 1"
5. Enter "Center Court"
6. Click "Gem"
7. **Verify**: Court shows "Center Court" with blue background

#### Test 2: Multiple Renames
1. Continue from Test 1
2. Rename "Bane 2" to "Side Court"
3. **Verify**: Both courts show custom names with blue backgrounds

#### Test 3: Reset to Default
1. Continue from Test 2
2. Click edit on "Center Court"
3. Click "Nulstil til standard"
4. **Verify**: Court shows "Bane 1" without blue background

#### Test 4: Persistence
1. Continue from Test 2
2. Close/refresh the app
3. **Verify**: Custom court names are restored

#### Test 5: Clear All
1. Continue from Test 4
2. Click "Ryd alle" button
3. Confirm the action
4. **Verify**: Custom court names are cleared

#### Test 6: Tournament Usage
1. Set up tournament with custom court names
2. Click "Generer Første Runde"
3. Navigate to round display
4. **Verify**: Match cards show custom court names

#### Test 7: Court Count Changes
1. Rename "Bane 1" to "Main Court"
2. Increase court count to 3
3. **Verify**: "Main Court" name persists, new court has default name
4. Decrease court count to 1
5. **Verify**: "Main Court" still shows custom name

## Code Examples

### Using Custom Names When Generating Tournament

```dart
// In _generateFirstRound method
final courts = List.generate(
  _courtCount,
  (index) => Court(
    id: (index + 1).toString(),
    name: _courtCustomNames[index] ?? Constants.getDefaultCourtName(index),
  ),
);
```

### Saving Custom Names

```dart
// Automatically called after renaming
await _persistenceService.saveSetupState(
  _players, 
  _courtCount, 
  _courtCustomNames
);
```

### Loading Custom Names

```dart
final savedState = await _persistenceService.loadSetupState();
if (savedState != null) {
  _players.addAll(savedState.players);
  _courtCount = savedState.courtCount;
  _courtCustomNames.addAll(savedState.courtCustomNames);
}
```

## UI/UX Details

### Court List Appearance
- **Default Court**: White background, shows "Bane X", edit icon
- **Custom Court**: Blue background (`Colors.blue[50]`), shows custom name, subtitle "Brugerdefineret navn", edit icon
- **Tennis Icon**: Each court has a `sports_tennis` icon on the left

### Rename Dialog
- **Title**: "Omdøb [current court name]"
- **Text Field**: Pre-filled with current name, auto-focused
- **Submit on Enter**: Pressing Enter saves the name
- **Three Actions**:
  - "Annuller" (Cancel) - gray text button
  - "Nulstil til standard" (Reset to default) - text button
  - "Gem" (Save) - elevated button (primary action)

## Known Behavior

1. **Empty Names**: If user enters empty name, it's ignored (no change)
2. **Duplicate Names**: Allowed - users can give multiple courts the same name
3. **Special Characters**: Allowed - any string is valid
4. **Maximum Length**: Not restricted (but recommended to keep reasonable)
5. **State Cleanup**: Custom names are cleared when:
   - Using "Ryd alle" (Clear all)
   - Starting a new tournament (old tournament starts)

## Future Enhancements

Possible improvements for future versions:
- Validation for duplicate court names (optional warning)
- Preset name templates (e.g., "Court A", "Court B", "Court 1", "Court 2")
- Bulk rename option for multiple courts
- Import/export court naming schemes
- Court name history/favorites
- Maximum character length validation

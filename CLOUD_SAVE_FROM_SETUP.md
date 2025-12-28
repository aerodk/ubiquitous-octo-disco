# Cloud Save from Setup Screen

## Feature Overview

This feature allows users to save their tournament setup (players, courts, and settings) to the cloud **before generating the first round**. This addresses the use case where organizers want to prepare a tournament at home and load it later at the venue.

## User Story

> "When preparing a tournament from home before going, an option to save from the settings screen is needed in order to not create first round before being able to save."

## How It Works

### 1. Setup Phase (At Home)
- User opens the app and navigates to the Setup Screen
- User adds players (minimum 4 required)
- User configures courts and tournament settings
- User clicks the **cloud upload icon** in the AppBar (appears when ≥4 players)

### 2. Save to Cloud
- SaveTournamentDialog appears
- User enters tournament name
- System generates:
  - 8-digit tournament code (e.g., 12345678)
  - 6-digit passcode (e.g., 654321)
- Tournament is saved to Firebase with:
  - All players
  - All courts (with custom names if set)
  - Tournament settings
  - **Empty rounds list** (no matches yet)

### 3. Load at Venue
- User arrives at the venue
- User clicks **"Hent Turnering fra Cloud"** (cloud download icon)
- User enters the 8-digit code and 6-digit passcode
- Setup is restored with all players and courts
- User can now click **"Generer Første Runde"** to start the tournament

## Technical Implementation

### Changes Made

**File: `lib/screens/setup_screen.dart`**

1. Added import for `SaveTournamentDialog`
2. Created `_saveToCloud()` method:
   - Validates minimum player count
   - Creates Tournament object with empty rounds
   - Shows SaveTournamentDialog
   - Displays success message
3. Added cloud upload button to AppBar:
   - Icon: `Icons.cloud_upload`
   - Tooltip: "Gem til Cloud"
   - Visibility: Only when `_players.length >= Constants.minPlayers`

### Code Structure

```dart
Future<void> _saveToCloud() async {
  // Validation: Minimum players
  if (_players.length < Constants.minPlayers) {
    _showError('Du skal have mindst ${Constants.minPlayers} spillere for at gemme til cloud.');
    return;
  }

  // Generate courts with custom names
  final courts = List.generate(...);

  // Create tournament with empty rounds list
  final tournament = Tournament(
    name: 'Padel Turnering',
    players: _players,
    courts: courts,
    rounds: [], // Empty - tournament not started
    settings: _tournamentSettings,
  );

  // Show save dialog
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => SaveTournamentDialog(tournament: tournament),
  );

  // Show success message
  if (result != null && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

### AppBar Integration

The cloud upload button is conditionally displayed:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.cloud_download),
    onPressed: _loadFromCloud,
    tooltip: 'Hent Turnering fra Cloud',
  ),
  if (_players.length >= Constants.minPlayers)
    IconButton(
      icon: const Icon(Icons.cloud_upload),
      onPressed: _saveToCloud,
      tooltip: 'Gem til Cloud',
    ),
  if (_players.isNotEmpty)
    IconButton(
      icon: const Icon(Icons.delete_sweep),
      onPressed: _clearAll,
      tooltip: 'Ryd alle',
    ),
],
```

## Benefits

1. **Preparation Flexibility**: Set up tournaments in advance
2. **No Wasted Rounds**: Save before generating first round
3. **Cross-Device Support**: Prepare on one device, run on another
4. **Data Safety**: Cloud backup of setup in case of device issues
5. **Team Coordination**: Share tournament code with co-organizers

## Validation

- ✅ All 229 existing tests pass
- ✅ Flutter analyze passes with no new issues
- ✅ No changes needed to Firebase service (already supports empty rounds)
- ✅ Compatible with existing save/load infrastructure

## Example Workflow

```
┌─────────────────────────────────────────┐
│           AT HOME (Preparation)         │
├─────────────────────────────────────────┤
│ 1. Add 8 players                        │
│ 2. Configure 2 courts                   │
│ 3. Set tournament settings              │
│ 4. Click cloud upload icon              │
│ 5. Get code: 12345678                   │
│ 6. Get passcode: 654321                 │
│ 7. Write down codes                     │
└─────────────────────────────────────────┘
                    ↓
                 Travel
                    ↓
┌─────────────────────────────────────────┐
│          AT VENUE (Tournament)          │
├─────────────────────────────────────────┤
│ 1. Click cloud download icon            │
│ 2. Enter code: 12345678                 │
│ 3. Enter passcode: 654321               │
│ 4. Setup restored!                      │
│ 5. Click "Generer Første Runde"         │
│ 6. Start tournament                     │
└─────────────────────────────────────────┘
```

## Related Features

- **Load Tournament** (F-027): Load saved tournament from cloud
- **Save from Settings** (F-026.1): Save during tournament (after rounds started)
- **Save from Completion** (F-026.2): Save final results

## Future Enhancements

- Auto-save setup to cloud when minimum players reached
- Quick save option with default name
- List of saved tournaments for easy selection
- Share tournament code via QR code

# Share Link Feature - Implementation Guide

## Overview
This feature allows users to share tournament links directly with others. The share links can be created with or without passcodes, enabling both view-only and secure access modes.

## Key Components

### 1. ShareService (`lib/services/share_service.dart`)
Handles URL generation and parsing for tournament sharing.

**Key Methods:**
- `generateShareLink()` - Generates shareable URLs with optional passcode
- `parseTournamentFromUrl()` - Extracts tournament info from URLs
- `hasTournamentInUrl()` - Checks if URL contains tournament data

**URL Format:**
- Without passcode: `https://aerodk.github.io/ubiquitous-octo-disco/#/tournament/12345678`
- With passcode: `https://aerodk.github.io/ubiquitous-octo-disco/#/tournament/12345678?p=123456`

### 2. ShareTournamentDialog (`lib/widgets/share_tournament_dialog.dart`)
User-facing dialog for generating and sharing tournament links.

**Features:**
- Radio buttons for selecting share mode (with/without passcode)
- Live link generation and display
- One-click copy to clipboard
- Clear explanations of each share mode

### 3. Read-Only Mode
When tournaments are accessed via share links without passcode, they open in read-only mode.

**Restrictions in Read-Only Mode:**
- No score entry or editing
- No round generation (Next Round/Final Round buttons hidden)
- No player position overrides
- No tournament settings changes
- No cloud save/update
- "Kun Visning" (View Only) indicator in AppBar

**Allowed in Read-Only Mode:**
- View all tournament data
- View leaderboard and standings
- View match history
- Export tournament results
- Zoom and display mode toggles

## User Workflow

### Sharing a Tournament

1. **Save Tournament to Cloud** (required)
   - User must first save tournament using "Cloud Lagring" button
   - Tournament receives 8-digit code and 6-digit passcode

2. **Access Share Dialog**
   - Click the share icon (📤) in the AppBar
   - Available in RoundDisplayScreen and TournamentCompletionScreen

3. **Choose Share Mode**
   - **Kun Visning (View Only):** Link without passcode
     - Recipients can view but not edit
     - No login required
     - Perfect for sharing results publicly
   
   - **Med Adgangskode (With Passcode):** Link includes passcode
     - Still view-only
     - Passcode embedded in URL for convenience
     - Recipients don't need to manually enter passcode

4. **Copy and Share**
   - Click "Kopiér Link" to copy to clipboard
   - Share via any communication channel

### Accessing a Shared Tournament

1. **Open Shared Link**
   - Click the shared URL
   - App automatically detects tournament in URL

2. **Automatic Loading**
   - Without passcode: Loads in read-only mode
   - With passcode: Loads in read-only mode (no verification needed)

3. **View Tournament**
   - All data is viewable
   - Clear "Kun Visning" indicator shown
   - Edit/save functions disabled

## Technical Implementation Details

### URL Routing (`lib/main.dart`)
The app initializer checks for tournament info in the URL on startup:

```dart
1. Parse URL using ShareService
2. If tournament found:
   - Load from Firebase (read-only or with passcode)
   - Navigate to appropriate screen
3. If no tournament:
   - Check for saved local tournament
   - Navigate to SetupScreen if none
```

### Firebase Integration
Added `loadTournamentReadOnly()` method to FirebaseService:
- Loads tournament data without passcode verification
- Used when share link doesn't include passcode
- Allows public viewing of tournament results

### Screen Updates
All three main screens support read-only mode:

- **RoundDisplayScreen:** 
  - `isReadOnly` parameter
  - Hides editing buttons
  - Disables score input
  - Shows read-only indicator

- **TournamentCompletionScreen:**
  - `isReadOnly` parameter  
  - Hides "Start Ny Turnering" button
  - Hides cloud save buttons
  - Shows read-only indicator

- **LeaderboardScreen:**
  - `isReadOnly` parameter
  - (Mostly view-only already)

### Widget Updates
- **MatchCard:** Added `isReadOnly` parameter to disable score input
- Disabled player override functionality in read-only mode

## Security Considerations

1. **Passcode Hashing:** Passcodes are hashed (SHA-256) in Firestore
2. **Read-Only Enforcement:** Firebase rules should enforce read-only access
3. **No Passcode Exposure:** View-only links don't expose passcode
4. **Optional Passcode Sharing:** Users choose whether to include passcode

## Testing

Created comprehensive unit tests in `test/services/share_service_test.dart`:
- 18 tests covering all scenarios
- URL parsing validation
- Link generation
- Edge cases (leading zeros, invalid formats, etc.)

All tests passing ✅

## Future Enhancements

Potential improvements for future versions:
1. QR code generation for easy mobile sharing
2. Social media integration
3. Share with expiration dates
4. Share analytics (view counts)
5. Custom share messages
6. Mobile app deep linking support

## Usage Examples

### Example 1: Sharing Tournament Results
```
Scenario: Tournament organizer wants to share final results with all participants

1. Tournament is completed
2. Click share button in TournamentCompletionScreen
3. Select "Kun Visning" (no passcode)
4. Copy link
5. Send to participants via email/WhatsApp
6. Participants can view results without any login
```

### Example 2: Sharing Live Tournament
```
Scenario: Spectators want to follow ongoing tournament

1. Tournament in progress
2. Click share button in RoundDisplayScreen
3. Select "Kun Visning"
4. Copy link
5. Share on social media
6. Anyone can view live standings and scores
7. Only organizer can update scores
```

### Example 3: Sharing with Passcode
```
Scenario: Share with specific group but include passcode for convenience

1. Click share button
2. Select "Med Adgangskode"
3. Link includes embedded passcode
4. Recipients can view without manually entering code
5. Still read-only access
```

## Error Handling

The feature includes comprehensive error handling:

1. **Tournament Not Found:** Clear error message if code invalid
2. **Firebase Unavailable:** Fallback message with instructions
3. **Invalid URL Format:** Silently ignores and proceeds to normal flow
4. **Network Issues:** Standard error reporting

## Localization

All UI text is in Danish (dansk) to match the existing app:
- "Kun Visning" - View Only
- "Med Adgangskode" - With Passcode
- "Del Turnering" - Share Tournament
- "Kopiér Link" - Copy Link

## Performance

- Minimal impact on app startup
- URL parsing is fast (<1ms)
- Firebase loading same as existing load feature
- No additional network calls for view-only mode

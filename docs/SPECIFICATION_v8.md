# Padel Tournament App - Version 8.0 Specification
## Cloud Storage & Tournament Persistence

---

## Prerequisites

Version 8.0 builds upon:
- ✅ V1.0-V7.0: Complete tournament system with visual redesign

---

## Overview

Version 8.0 focuses on integrating Firebase for cloud-based tournament storage, enabling tournament persistence and recovery across devices and sessions.

**Key Design Decisions:**
- **Anonymous Authentication**: No user accounts required - anyone can create a tournament
- **8-Digit Tournament Code**: Each tournament gets a unique 8-digit identifier
- **6-Digit Passcode Protection**: Tournament data protected by numeric passcode
- **Priority**: Saving tournament results and setup to cloud
- **Save Points**: From Settings screen (anytime) and Tournament Completion screen (end)

---

## Feature F-025: Firebase Cloud Storage

### Purpose
Enable tournament data to persist in the cloud using Firebase Firestore, allowing organizers to save and restore tournament state.

### Requirements

**FR-025.1: Firebase Project Setup**
- Integrate Firebase into Flutter app
- Configure Firestore database
- Set up security rules for anonymous access
- Support web and mobile platforms

**FR-025.2: Anonymous Tournament Creation**
- No authentication required
- Auto-generate unique 8-digit tournament code (e.g., "12345678")
- Generate 6-digit numeric passcode for protection
- Store tournament metadata in Firestore

**FR-025.3: Tournament Data Structure**
```dart
// Firestore collection: tournaments/{tournamentCode}
{
  "tournamentCode": "12345678",      // 8-digit unique identifier
  "passcode": "123456",              // 6-digit numeric passcode (hashed)
  "name": "Saturday Tournament",     // Tournament name
  "createdAt": Timestamp,
  "lastModified": Timestamp,
  "organizerDeviceId": "device-uuid", // Optional device identifier
  
  // Tournament data
  "players": [...],                  // List of players
  "courts": [...],                   // Court configuration
  "rounds": [...],                   // All rounds with matches
  "settings": {...},                 // Tournament settings
  "isCompleted": false,
  "completedAt": null
}
```

**FR-025.4: Security**
- Passcode must be provided to read/write tournament data
- Store hashed passcode in Firestore (use SHA-256)
- Client validates passcode before accessing data
- No public read access without passcode

---

## Feature F-026: Save Tournament to Cloud

### Purpose
Allow organizers to save tournament state to Firebase at any time.

### Requirements

**FR-026.1: Save from Settings Screen**
- Add "Gem Turnering i Cloud" button in Settings screen
- Show dialog to enter/confirm tournament name
- Display generated tournament code and passcode
- Save current tournament state to Firestore
- Show success confirmation with code to write down

**FR-026.2: Save from Tournament Completion Screen**
- Add "Gem Resultat i Cloud" button on completion screen
- Same flow as settings screen
- Saves final tournament results and statistics
- Mark tournament as completed in Firestore

**FR-026.3: Save Dialog Flow**
```
┌─────────────────────────────────────┐
│  Gem Turnering i Cloud              │
├─────────────────────────────────────┤
│  Turnerings Navn:                   │
│  [________________________]         │
│                                     │
│  [Generer Kode]  [Annuller]       │
└─────────────────────────────────────┘

After generation:
┌─────────────────────────────────────┐
│  Turnering Gemt!                    │
├─────────────────────────────────────┤
│  Turnerings Kode: 12345678          │
│  Adgangskode:     654321            │
│                                     │
│  ⚠️ Skriv disse koder ned!          │
│  Du skal bruge dem for at          │
│  hente turneringen senere.          │
│                                     │
│  [Kopiér Kode]  [Færdig]           │
└─────────────────────────────────────┘
```

**FR-026.4: Update Existing Tournament**
- If tournament was previously saved, show option to update
- Use same tournament code and passcode
- Update lastModified timestamp
- Preserve createdAt timestamp

---

## Feature F-027: Load Tournament from Cloud

### Purpose
Allow organizers to restore a previously saved tournament.

### Requirements

**FR-027.1: Load Tournament Dialog**
- Add "Hent Turnering fra Cloud" option on main/setup screen
- Prompt for 8-digit tournament code
- Prompt for 6-digit passcode
- Validate and load from Firestore

**FR-027.2: Load Dialog Flow**
```
┌─────────────────────────────────────┐
│  Hent Turnering                     │
├─────────────────────────────────────┤
│  Turnerings Kode:                   │
│  [________] (8 cifre)               │
│                                     │
│  Adgangskode:                       │
│  [______] (6 cifre)                 │
│                                     │
│  [Hent]  [Annuller]                │
└─────────────────────────────────────┘
```

**FR-027.3: Validation**
- Verify tournament code exists in Firestore
- Verify passcode matches (compare hashes)
- Show error if code not found or passcode incorrect
- Load tournament data if validation passes

**FR-027.4: Tournament Restoration**
- Replace current tournament state with loaded data
- Restore all players, courts, rounds, scores
- Restore settings and configuration
- Navigate to appropriate screen (setup if not started, round display if in progress)

---

## Feature F-028: Firebase Service Architecture

### Purpose
Create clean service layer for Firebase operations.

### Requirements

**FR-028.1: FirebaseService Class**
```dart
class FirebaseService {
  // Initialize Firebase
  Future<void> initialize();
  
  // Generate unique tournament code (8 digits)
  String generateTournamentCode();
  
  // Generate passcode (6 digits)
  String generatePasscode();
  
  // Hash passcode for storage
  String hashPasscode(String passcode);
  
  // Save tournament to Firestore
  Future<void> saveTournament({
    required Tournament tournament,
    required String tournamentCode,
    required String passcode,
  });
  
  // Load tournament from Firestore
  Future<Tournament> loadTournament({
    required String tournamentCode,
    required String passcode,
  });
  
  // Check if tournament exists
  Future<bool> tournamentExists(String tournamentCode);
  
  // Update existing tournament
  Future<void> updateTournament({
    required String tournamentCode,
    required String passcode,
    required Tournament tournament,
  });
}
```

**FR-028.2: Error Handling**
- Handle network errors gracefully
- Show user-friendly error messages
- Implement retry logic for transient failures
- Offline mode: Allow local-only operation if Firebase unavailable

**FR-028.3: Code Generation**
- Tournament code: Random 8-digit number (10000000 - 99999999)
- Passcode: Random 6-digit number (100000 - 999999)
- Ensure uniqueness of tournament codes (check Firestore before using)
- Use cryptographically secure random number generator

---

## Feature F-029: UI Integration

### Purpose
Integrate cloud save/load functionality into existing screens.

### Requirements

**FR-029.1: Settings Screen Updates**
- Add "Cloud Lagring" section in settings
- "Gem Turnering i Cloud" button
- Show current tournament code if already saved
- "Opdater Cloud" button if tournament previously saved

**FR-029.2: Tournament Completion Screen Updates**
- Add "Gem Resultat i Cloud" button
- Prominent placement after podium display
- Optional but recommended

**FR-029.3: Setup Screen Updates**
- Add "Hent Turnering" button/option
- Allow loading before creating new tournament
- Clear indication when tournament is loaded vs. newly created

**FR-029.4: Visual Feedback**
- Loading spinners during save/load operations
- Success animations/confirmations
- Clear error messages with retry options
- Offline indicator if Firebase unavailable

---

## Technical Implementation Details

### Dependencies Required
```yaml
dependencies:
  firebase_core: ^latest
  cloud_firestore: ^latest
  crypto: ^latest  # For passcode hashing
```

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tournaments/{tournamentCode} {
      // Allow read/write only with valid passcode
      // Note: Actual validation happens client-side
      // Server-side validation would require Cloud Functions
      allow read, write: if request.auth == null;  // Anonymous access
    }
  }
}
```

### Data Migration
- Existing local tournaments remain in SharedPreferences
- Cloud save is optional, not required
- No automatic migration of existing tournaments
- Users must manually save if they want cloud backup

---

## Testing Requirements

### Unit Tests
- [ ] FirebaseService code generation (uniqueness, format)
- [ ] Passcode hashing
- [ ] Tournament serialization/deserialization for Firestore
- [ ] Error handling scenarios

### Integration Tests
- [ ] Save tournament to Firestore
- [ ] Load tournament from Firestore
- [ ] Update existing tournament
- [ ] Passcode validation
- [ ] Error scenarios (network failure, wrong passcode, etc.)

### Manual Testing
- [ ] Complete save/load flow
- [ ] Cross-device tournament access
- [ ] Offline behavior
- [ ] UI feedback and error messages

---

## Future Enhancements (Post-V8.0)

Deferred to future versions:
- **F-030: Tournament Sharing** - Share codes for player self-registration
- **F-031: Self-Registration** - Players join via link
- **F-032: Organizer Dashboard** - Live player management
- **F-033: QR Code Generation** - Easy tournament sharing
- **F-034: Facebook Login** - Social authentication
- **F-035: Real-time Sync** - Multi-device live updates
- **F-036: Tournament Search** - Browse public tournaments

---

## Acceptance Criteria

### V8.0 is complete when:
1. ✅ Firebase is integrated and configured
2. ✅ Tournaments can be saved to Firestore from Settings screen
3. ✅ Tournaments can be saved to Firestore from Completion screen
4. ✅ Tournaments can be loaded using code + passcode
5. ✅ 8-digit tournament codes are generated uniquely
6. ✅ 6-digit passcodes protect tournament access
7. ✅ UI provides clear feedback for all operations
8. ✅ Error handling works gracefully
9. ✅ All tests pass
10. ✅ Documentation is complete

---

## Implementation Phases

### Phase 1: Firebase Setup & Service Layer
- Set up Firebase project
- Add Firebase dependencies
- Create FirebaseService class
- Implement code generation and hashing

### Phase 2: Save Functionality
- Add save dialog component
- Integrate with Settings screen
- Integrate with Completion screen
- Implement Firestore write operations

### Phase 3: Load Functionality
- Add load dialog component
- Integrate with Setup screen
- Implement Firestore read operations
- Handle tournament restoration

### Phase 4: Testing & Polish
- Write unit and integration tests
- Manual testing across scenarios
- UI polish and error handling
- Documentation updates
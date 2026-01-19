# Firebase Cloud Storage - Quick Visual Guide

## Overview

This guide provides a visual walkthrough of the Firebase cloud storage feature implementation.

---

## 1. Setup Screen - Load Tournament

**Location**: Setup Screen → AppBar → Cloud Download Icon (☁️⬇️)

```
┌─────────────────────────────────────────────┐
│  Opsætning af turnering              [☁️⬇️] │
├─────────────────────────────────────────────┤
│                                             │
│  User clicks cloud download icon           │
│         ↓                                   │
│  LoadTournamentDialog opens                 │
│                                             │
└─────────────────────────────────────────────┘
```

### Load Tournament Dialog

```
┌─────────────────────────────────────┐
│  [☁️] Hent Turnering                │
├─────────────────────────────────────┤
│  Indtast turnerings kode og         │
│  adgangskode for at hente din       │
│  gemte turnering.                   │
│                                     │
│  Turnerings Kode                    │
│  [12345678]                         │
│  8 cifre                            │
│                                     │
│  Adgangskode                        │
│  [••••••]                           │
│  6 cifre                            │
│                                     │
│  [Annuller]  [Hent]                │
└─────────────────────────────────────┘
```

**Features**:
- Numeric-only input
- Auto-length limiting (8 and 6 digits)
- Passcode obscured for security
- Real-time validation
- Error messages in Danish

---

## 2. Round Display Screen - Save Tournament

**Location**: Round Display Screen → AppBar → Cloud Upload Icon (☁️)

```
┌─────────────────────────────────────────────┐
│  [←] Runde 1           [☁️] [📊] [⋮]        │
├─────────────────────────────────────────────┤
│                                             │
│  User clicks cloud upload icon              │
│         ↓                                   │
│  SaveTournamentDialog opens                 │
│                                             │
└─────────────────────────────────────────────┘
```

### Save Tournament Dialog - Input Phase

```
┌─────────────────────────────────────┐
│  Gem Turnering i Cloud              │
├─────────────────────────────────────┤
│  Turnerings Navn:                   │
│  [Padel turnering 03-01-2026___]    │
│                                     │
│  [Annuller]  [Generer Kode]        │
└─────────────────────────────────────┘
```

### Save Tournament Dialog - Success Phase

```
┌─────────────────────────────────────┐
│  [✓] Turnering Gemt!                │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ Turnerings Kode:      [📋] │   │
│  │ 12345678                    │   │
│  │                             │   │
│  │ Adgangskode:          [📋] │   │
│  │ 654321                      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⚠️ Skriv disse koder ned!   │   │
│  │ Du skal bruge dem for at    │   │
│  │ hente turneringen senere.   │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Kopiér Begge]  [Færdig]          │
└─────────────────────────────────────┘
```

**Features**:
- Two-phase UI (input → success)
- Clear visual hierarchy
- Copy to clipboard buttons
- Warning message
- Generated codes displayed prominently

---

## 3. Tournament Completion Screen - Save Results

**Location**: Tournament Completion Screen → After Podium

```
┌─────────────────────────────────────────────┐
│  🏆 Turnering Afsluttet                     │
├─────────────────────────────────────────────┤
│                                             │
│  🥇 Alice - 72 point                        │
│  🥈 Bob - 68 point                          │
│  🥉 Charlie - 64 point                      │
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │ Gem i Cloud  │  │  Eksporter   │        │
│  │     ☁️       │  │      ⬇️      │        │
│  └──────────────┘  └──────────────┘        │
│                                             │
│  ┌──────────────────────────────┐          │
│  │   Start Ny Turnering         │          │
│  └──────────────────────────────┘          │
│                                             │
└─────────────────────────────────────────────┘
```

**Features**:
- Dual button layout
- Blue "Gem i Cloud" button
- Green "Eksporter" button
- Consistent styling with V7 design

---

## 4. User Flow - Complete Save/Load Cycle

### Scenario: Save and Load on Different Device

```
Device A (Desktop):
┌─────────────────────────────────────┐
│ 1. Create Tournament                │
│    - Add 8 players                  │
│    - Set up courts                  │
│    - Generate first round           │
│                                     │
│ 2. Play Rounds                      │
│    - Enter scores                   │
│    - Generate next rounds           │
│                                     │
│ 3. Save to Cloud                    │
│    - Click ☁️ icon                  │
│    - Enter name                     │
│    - Get codes: 12345678 / 654321   │
│    - Write down codes               │
└─────────────────────────────────────┘
         │
         │ Codes written down
         ↓
Device B (Mobile):
┌─────────────────────────────────────┐
│ 1. Open App                         │
│    - Navigate to Setup Screen       │
│                                     │
│ 2. Load from Cloud                  │
│    - Click ☁️⬇️ icon                │
│    - Enter code: 12345678           │
│    - Enter passcode: 654321         │
│    - Click "Hent"                   │
│                                     │
│ 3. Tournament Loaded!               │
│    - All players present            │
│    - All scores preserved           │
│    - Continue playing               │
└─────────────────────────────────────┘
```

---

## 5. Update Existing Tournament Flow

```
Tournament Already Saved (Code: 12345678)
┌─────────────────────────────────────┐
│ User makes changes:                 │
│ - Enters more scores                │
│ - Completes more rounds             │
│                                     │
│ Clicks ☁️ icon again                │
│         ↓                           │
│ SaveTournamentDialog opens          │
│         ↓                           │
│ Dialog shows:                       │
│ "Opdater Turnering i Cloud"         │
│ "Turnerings Kode: 12345678"         │
│         ↓                           │
│ User clicks "Opdater"               │
│         ↓                           │
│ Same codes used                     │
│ No new codes generated              │
│ Tournament updated in Firebase      │
└─────────────────────────────────────┘
```

**Key Point**: Update uses same codes - no new codes generated!

---

## 6. Error Handling Examples

### Wrong Passcode

```
┌─────────────────────────────────────┐
│  [☁️] Hent Turnering                │
├─────────────────────────────────────┤
│  Code: 12345678                     │
│  Passcode: 999999 (wrong)           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ❌ Forkert adgangskode      │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Annuller]  [Hent]                │
└─────────────────────────────────────┘
```

### Tournament Not Found

```
┌─────────────────────────────────────┐
│  [☁️] Hent Turnering                │
├─────────────────────────────────────┤
│  Code: 99999999 (doesn't exist)     │
│  Passcode: 123456                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ❌ Turnering ikke fundet.   │   │
│  │    Kontroller koden.        │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Annuller]  [Hent]                │
└─────────────────────────────────────┘
```

### No Internet Connection

```
┌─────────────────────────────────────┐
│  Gem Turnering i Cloud              │
├─────────────────────────────────────┤
│  Name: Saturday Tournament          │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ❌ Firebase er ikke         │   │
│  │    tilgængelig. Kontroller  │   │
│  │    din internetforbindelse. │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Annuller]  [Generer Kode]        │
└─────────────────────────────────────┘
```

---

## 7. Icon Meanings

| Icon | Location | Purpose |
|------|----------|---------|
| ☁️⬇️ | SetupScreen AppBar | Load tournament from cloud |
| ☁️ | RoundDisplayScreen AppBar | Save/update tournament to cloud |
| ☁️ | TournamentCompletionScreen | Save final results to cloud |
| 📋 | SaveTournamentDialog | Copy code/passcode to clipboard |
| ✓ | SaveTournamentDialog | Success indicator |
| ❌ | Error messages | Error indicator |
| ⚠️ | Warning messages | Warning indicator |

---

## 8. Data Security Flow

```
User enters passcode: "123456"
         ↓
SHA-256 Hash
         ↓
"8d969eef6ecad3c29a3a629280e686cf0c3f5d5a..."
         ↓
Stored in Firebase
         ↓
(Original passcode NEVER stored)


When loading:
User enters passcode: "123456"
         ↓
SHA-256 Hash
         ↓
Compare with stored hash
         ↓
Match? → Load tournament
No match? → Show error
```

---

## 9. Firebase Firestore Structure

```
Collection: tournaments
├── Document: "12345678" (tournament code)
│   ├── tournamentCode: "12345678"
│   ├── passcode: "8d969eef..." (hashed)
│   ├── name: "Saturday Tournament"
│   ├── createdAt: Timestamp
│   ├── lastModified: Timestamp
│   └── tournamentData: {
│       ├── id: "..."
│       ├── name: "Saturday Tournament"
│       ├── players: [...]
│       ├── courts: [...]
│       ├── rounds: [...]
│       ├── settings: {...}
│       └── isCompleted: false
│   }
├── Document: "87654321"
│   └── ...
└── ...
```

---

## 10. Color Scheme

### Dialogs
- **Save Dialog Header**: Blue (cloud upload)
- **Load Dialog Header**: Blue (cloud download)
- **Success Icons**: Green
- **Error Containers**: Red background
- **Warning Containers**: Orange background

### Buttons
- **Primary Action (Save/Load)**: Blue
- **Export**: Green
- **Cancel**: Default gray
- **Copy**: Icon buttons

### Consistent with V7 Design
- Blue theme for courts and cloud features
- Orange theme for warnings
- Green for success/export actions

---

## Quick Reference: Code Locations

| Component | File | Lines |
|-----------|------|-------|
| SaveTournamentDialog | `lib/widgets/save_tournament_dialog.dart` | 319 |
| LoadTournamentDialog | `lib/widgets/load_tournament_dialog.dart` | 226 |
| FirebaseService | `lib/services/firebase_service.dart` | 236 |
| SetupScreen (load) | `lib/screens/setup_screen.dart` | +40 |
| RoundDisplayScreen (save) | `lib/screens/round_display_screen.dart` | +50 |
| CompletionScreen (save) | `lib/screens/tournament_completion_screen.dart` | +60 |

---

**Total Implementation**: ~800 lines of code + 500 lines of documentation

**Status**: ✅ Complete and ready for testing

---

*For detailed testing instructions, see [MANUAL_TESTING_FIREBASE.md](MANUAL_TESTING_FIREBASE.md)*

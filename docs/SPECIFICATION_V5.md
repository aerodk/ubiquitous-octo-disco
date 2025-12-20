# Padel Turnering App - Version 5.0 Specifikation
## Tournament Settings & Configuration

---

## Forudsætninger

Version 5.0 bygger videre på:
- ✅ V1.0-V4.0: Komplet turnering system med final round

---

## Oversigt

Version 5.0 introducerer konfigurerbare turnering indstillinger der gives organisatorer fleksibilitet til at tilpasse turneringen til deres behov og præferencer.

**Placering:** Indstillinger skal være tilgængelige på setup screen (hvor spillere og baner indtastes).

---

## Feature F-014: Tournament Settings UI

### Placering & Interaktion

**Settings Container:**
- Collapsible/expandable sektion på SetupScreen
- Placeret efter spiller og bane input, før "Generer Første Runde" knap
- Default: Foldet sammen (collapsed)
- Vis ikon og label: "⚙️ Turnering Indstillinger" med expand/collapse ikon

**UI States:**
```
Collapsed (default):
┌────────────────────────────────┐
│ ⚙️ Turnering Indstillinger  ▼  │
└────────────────────────────────┘

Expanded:
┌────────────────────────────────┐
│ ⚙️ Turnering Indstillinger  ▲  │
├────────────────────────────────┤
│ [Settings content here]        │
│ • Minimum runder               │
│ • Point per kamp               │
│ • Sidste runde strategi        │
└────────────────────────────────┘
```

### Design Approach

**Option 1: ExpansionTile (Anbefalet for Flutter)**
- Native Flutter widget
- Smooth animation
- Standard interaction pattern

**Option 2: Card med IconButton**
- More custom control
- Can add badge indicators (fx "3 indstillinger ændret")

**Anbefaling:** Start med ExpansionTile, nemt og standard.

---

## Feature F-015: Minimum Rounds Setting

### Setting Details

**Navn:** "Minimum Runder Før Sidste Runde"

**Type:** Nummer selector (stepper eller dropdown)

**Default:** 3 runder

**Range:** 2-50 runder

**Beskrivelse:**
"Antal runder der skal spilles før sidste runde kan startes. Standard er 3 runder."

### UI Component

```dart
// Stepper style
Row(
  children: [
    Text('Minimum Runder'),
    Spacer(),
    IconButton(icon: Icon(Icons.remove), onPressed: decrement),
    Text('3', style: bold),
    IconButton(icon: Icon(Icons.add), onPressed: increment),
  ],
)
```

### Validation

- Minimum: 2 runder (skal have mindst nogle data før final)
- Maximum: 50 runder (praktisk grænse)
- Bruges i `Tournament.canStartFinalRound()` check

### Impact

Hvis sat til 5 runder:
- "Start Sidste Runde" knap vises først efter 5. runde er completed
- Giver længere turneringer med mere data før final

---

## Feature F-016: Points Per Match Setting

### Setting Details

**Navn:** "Point Per Kamp"

**Type:** Nummer selector

**Default:** 24 point

**Range:** 16-40 point (spring af 2)

**Beskrivelse:**
"Hvor mange point der spilles til i hver kamp. Standard er 24."

### UI Component

```dart
// Dropdown eller stepper med 2-spring
DropdownButton<int>(
  value: 24,
  items: [18, 20, 22, 24, 26, 28, 30, 32].map((points) =>
    DropdownMenuItem(
      value: points,
      child: Text('$points point'),
    ),
  ).toList(),
)
```

### Validation

- Minimum: 16 point (skal være mindst en anstændig kamp)
- Maximum: 40 point (praktisk grænse for tidsramme)
- Lige tal kun (standard padel konvention)

### Impact

**Score Input Screen:**
- ScoreButtonGrid skal dynamisk vise 0 til [selectedPoints]
- Ikke længere hardcoded til 24

**Display:**
- Vis "Spilles til X point" i round display
- Opdater alle steder hvor "24" er hardcoded

---

## Feature F-017: Final Round Pairing Strategy

### Setting Details

**Navn:** "Sidste Runde Pairing"

**Type:** Radio buttons / Segmented control

**Options:**

#### Option 1: "Balanced" (Default)
**Pattern:** R1+R3 vs R2+R4
- Top 2 mødes med forskellige støttespillere
- Mest afbalanceret og fair
- **Default fra V4**

#### Option 2: "Top Alliance"  
**Pattern:** R1+R2 vs R3+R4
- Top 2 spiller sammen
- Stærkeste par vs næststærkeste
- Mere forudsigelig, mindre spændende

#### Option 3: "Maximum Competition"
**Pattern:** R1+R4 vs R2+R3
- Top spiller med svageste i top 4
- Mest konkurrencedygtig balance
- Alle får jævnbyrdige partnere

### UI Component

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Sidste Runde Pairing', style: subtitle),
    RadioListTile(
      title: Text('Balanced (1+3 vs 2+4)'),
      subtitle: Text('Standard - mest afbalanceret'),
      value: PairingStrategy.balanced,
      groupValue: selectedStrategy,
      onChanged: (value) => setState(...),
    ),
    RadioListTile(
      title: Text('Top Alliance (1+2 vs 3+4)'),
      subtitle: Text('Top 2 spiller sammen'),
      value: PairingStrategy.topAlliance,
      groupValue: selectedStrategy,
      onChanged: (value) => setState(...),
    ),
    RadioListTile(
      title: Text('Max Competition (1+4 vs 2+3)'),
      subtitle: Text('Mest konkurrencedygtig'),
      value: PairingStrategy.maxCompetition,
      groupValue: selectedStrategy,
      onChanged: (value) => setState(...),
    ),
  ],
)
```

### Pattern Extension

**Vigtigt:** Valgte pattern skal anvendes gennemgående:

**Balanced (1+3 vs 2+4):**
```
Kamp 1: R1+R3 vs R2+R4
Kamp 2: R5+R7 vs R6+R8
Kamp 3: R9+R11 vs R10+R12
```

**Top Alliance (1+2 vs 3+4):**
```
Kamp 1: R1+R2 vs R3+R4
Kamp 2: R5+R6 vs R7+R8
Kamp 3: R9+R10 vs R11+R12
```

**Max Competition (1+4 vs 2+3):**
```
Kamp 1: R1+R4 vs R2+R3
Kamp 2: R5+R8 vs R6+R7
Kamp 3: R9+R12 vs R10+R11
```

### Impact

- Opdater `TournamentService.generateFinalRound()` til at bruge valgt strategi
- Alle kampe følger samme pattern (ikke kun første)

---

## Data Model Updates

### Tournament Settings Model

```dart
class TournamentSettings {
  final int minRoundsBeforeFinal;    // Default: 3
  final int pointsPerMatch;          // Default: 24
  final PairingStrategy finalRoundStrategy; // Default: balanced
  
  TournamentSettings({
    this.minRoundsBeforeFinal = 3,
    this.pointsPerMatch = 24,
    this.finalRoundStrategy = PairingStrategy.balanced,
  });
  
  // JSON serialization
  Map<String, dynamic> toJson();
  factory TournamentSettings.fromJson(Map<String, dynamic> json);
}

enum PairingStrategy {
  balanced,        // 1+3 vs 2+4
  topAlliance,     // 1+2 vs 3+4
  maxCompetition,  // 1+4 vs 2+3
}
```

### Tournament Model Update

```dart
class Tournament {
  // ... existing fields
  final TournamentSettings settings; // NEW
  
  Tournament({
    // ... existing params
    TournamentSettings? settings,
  }) : settings = settings ?? TournamentSettings();
  
  // Update canStartFinalRound to use settings.minRoundsBeforeFinal
  bool canStartFinalRound() {
    if (rounds.length < settings.minRoundsBeforeFinal) return false;
    // ... rest of logic
  }
}
```

---

## Implementation Guide

### Copilot Prompts

#### Prompt 1: Settings Data Model
```
@workspace Create tournament settings model for V5.0.

Create lib/models/tournament_settings.dart with:

1. TournamentSettings class:
   - minRoundsBeforeFinal (int, default: 3, range: 2-10)
   - pointsPerMatch (int, default: 24, range: 18-32)
   - finalRoundStrategy (PairingStrategy enum, default: balanced)
   - JSON serialization

2. PairingStrategy enum with three values:
   - balanced (1+3 vs 2+4) - default
   - topAlliance (1+2 vs 3+4)
   - maxCompetition (1+4 vs 2+3)

3. Update Tournament model to include TournamentSettings field
   - Default to TournamentSettings() if not provided
   - Update canStartFinalRound() to use settings.minRoundsBeforeFinal

Include validation helpers and descriptive comments.
```

#### Prompt 2: Settings UI Component
```
@workspace Create settings UI component for SetupScreen.

Create lib/widgets/tournament_settings_widget.dart:

1. TournamentSettingsWidget - collapsible settings section
   - Use ExpansionTile for collapse/expand
   - Title: "⚙️ Turnering Indstillinger"
   - Default: collapsed
   - Callback: onSettingsChanged(TournamentSettings)

2. Inside expanded view, show three settings:
   
   a) Minimum Rounds Setting:
      - Label: "Minimum Runder Før Sidste Runde"
      - Stepper with -/+ buttons (range: 2-10)
      - Display current value prominently
   
   b) Points Per Match Setting:
      - Label: "Point Per Kamp"
      - DropdownButton with values: 18, 20, 22, 24, 26, 28, 30, 32
      - Format: "X point"
   
   c) Final Round Pairing Strategy:
      - Label: "Sidste Runde Pairing"
      - RadioListTile for each strategy
      - Include subtitle explaining each option

3. Styling:
   - Card background for settings content
   - Proper spacing between settings
   - Help text/descriptions for clarity

Return updated TournamentSettings when any setting changes.
```

#### Prompt 3: Integrate Settings in SetupScreen
```
@workspace Integrate TournamentSettingsWidget into SetupScreen.

Update lib/screens/setup_screen.dart:

1. Add TournamentSettings state variable with default values

2. Place TournamentSettingsWidget after court input section,
   before "Generer Første Runde" button

3. Pass settings to Tournament when creating:
   - When generating first round, include settings in Tournament constructor

4. Layout order:
   - Player registration section
   - Court registration section
   - TournamentSettingsWidget (collapsible)
   - "Generer Første Runde" button

Ensure settings are saved with tournament.
```

#### Prompt 4: Dynamic Score Input
```
@workspace Update score input to use dynamic points from settings.

Update lib/screens/score_input_screen.dart and lib/widgets/score_button_grid.dart:

1. ScoreButtonGrid should accept maxPoints parameter
   - Generate buttons from 0 to maxPoints (instead of hardcoded 24)
   - Maintain same layout and styling

2. ScoreInputScreen should get maxPoints from tournament.settings.pointsPerMatch
   - Pass to both ScoreButtonGrid widgets

3. Update any displays showing "24 point" to use tournament.settings.pointsPerMatch

Ensure backward compatibility if settings not present (default to 24).
```

#### Prompt 5: Pairing Strategy Implementation
```
@workspace Implement final round pairing strategies.

Update lib/services/tournament_service.dart generateFinalRound():

1. Read tournament.settings.finalRoundStrategy

2. Implement three pairing algorithms:

   a) Balanced (1+3 vs 2+4):
      - Current default behavior
      - R1+R3 vs R2+R4, R5+R7 vs R6+R8, etc.
   
   b) Top Alliance (1+2 vs 3+4):
      - R1+R2 vs R3+R4, R5+R6 vs R7+R8, etc.
      - Pair consecutive ranks
   
   c) Max Competition (1+4 vs 2+3):
      - R1+R4 vs R2+R3, R5+R8 vs R6+R7, etc.
      - Top with bottom of group vs middle two

3. Apply pattern consistently across ALL matches in final round

4. Break selection (rolling pause) remains same across all strategies

Add detailed comments explaining each pairing logic.
```

---

## UI/UX Details

### Settings Visibility

**Visual Indicator when Changed:**
- If any setting differs from default, show badge: "⚙️ Turnering Indstillinger (Tilpasset)"
- Or change icon color to indicate customization

**Settings Summary (Collapsed State):**
Show key settings inline when collapsed:
```
⚙️ Turnering Indstillinger (3 runder • 24 point • Balanced) ▼
```

### Validation & Feedback

**Real-time Validation:**
- Disable increment/decrement when at limits
- Show helper text: "Minimum 2 runder" / "Maximum 10 runder"

**Impact Preview:**
- When changing points: "Kampe spilles til 20 point i stedet for 24"
- When changing strategy: Show visual of pairing pattern

### Mobile Optimization

- Ensure touch targets are 44x44 minimum
- Stepper buttons should be easy to tap
- Radio buttons should be large enough
- Consider bottom sheet for settings on mobile as alternative

---

## Testing Scenarios

### Test 1: Default Settings
```
Setup tournament with defaults:
- minRoundsBeforeFinal: 3
- pointsPerMatch: 24
- finalRoundStrategy: balanced

Expected: Behaves exactly like V4 (backward compatible)
```

### Test 2: Modified Minimum Rounds
```
Setup: minRoundsBeforeFinal = 5

Expected:
- "Start Sidste Runde" button hidden until 5 rounds completed
- Works as normal otherwise
```

### Test 3: Lower Points
```
Setup: pointsPerMatch = 18

Expected:
- Score input shows buttons 0-18 only
- All displays show "18 point"
- Ranking and stats work correctly with lower scores
```

### Test 4: Top Alliance Strategy
```
Setup: finalRoundStrategy = topAlliance
12 players

Expected Final Round:
- Kamp 1: R1+R2 vs R3+R4
- Kamp 2: R5+R6 vs R7+R8
- Kamp 3: R9+R10 vs R11+R12
```

### Test 5: Max Competition Strategy
```
Setup: finalRoundStrategy = maxCompetition
12 players

Expected Final Round:
- Kamp 1: R1+R4 vs R2+R3
- Kamp 2: R5+R8 vs R6+R7
- Kamp 3: R9+R12 vs R10+R11
```

---

## Edge Cases

### Settings Change Mid-Tournament
**Prevention:** Settings should be read-only once first round is generated
- Show settings grayed out with "Kan ikke ændres efter turneringen er startet"
- Consider "Reset Turnering" option if user wants to change

### Backward Compatibility
**Old Tournaments:** If loading tournament without settings field
- Use default TournamentSettings()
- Continue working as before

### Invalid Settings
**Validation:**
- If settings somehow invalid (out of range), fall back to defaults
- Log warning for debugging

---

## Visual Design

### Settings Section Styling

**Collapsed:**
```
┌─────────────────────────────────────────┐
│ ⚙️ Turnering Indstillinger           ▼ │
│ 3 runder • 24 point • Balanced          │
└─────────────────────────────────────────┘
```

**Expanded:**
```
┌─────────────────────────────────────────┐
│ ⚙️ Turnering Indstillinger           ▲ │
├─────────────────────────────────────────┤
│                                         │
│ Minimum Runder Før Sidste Runde        │
│ Antal runder der skal spilles...       │
│     ➖  [  3  ]  ➕                     │
│                                         │
│ ────────────────────────────────────── │
│                                         │
│ Point Per Kamp                          │
│ Hvor mange point der spilles til       │
│     [ 24 point            ▼ ]          │
│                                         │
│ ────────────────────────────────────── │
│                                         │
│ Sidste Runde Pairing                   │
│ ○ Balanced (1+3 vs 2+4)                │
│   Standard - mest afbalanceret         │
│ ○ Top Alliance (1+2 vs 3+4)            │
│   Top 2 spiller sammen                 │
│ ○ Max Competition (1+4 vs 2+3)         │
│   Mest konkurrencedygtig               │
│                                         │
└─────────────────────────────────────────┘
```

### Color Scheme
- Settings section: Light gray background
- Active/selected: Primary tournament color
- Disabled: Gray with reduced opacity
- Separators: Subtle divider lines

---

## Success Criteria

Version 5.0 er succesfuld når:

- [ ] Settings UI er tilgængelig på SetupScreen
- [ ] Default collapsed, smooth expand animation
- [ ] Alle tre indstillinger kan ændres
- [ ] Settings gemmes med tournament
- [ ] Minimum rounds setting påvirker final round availability
- [ ] Points setting ændrer score input dynamisk
- [ ] Alle tre pairing strategier implementeret korrekt
- [ ] Backward compatibility med V1-V4 turneringer
- [ ] Settings kan ikke ændres efter turnering startet
- [ ] Mobile-venlig UI
- [ ] Clear visual feedback for customized settings

---

## Implementation Timeline

**Estimated: 4-6 timer**

- Data models (1 time)
- Settings UI widget (2 timer)
- Integration i SetupScreen (30 min)
- Dynamic score input (1 time)
- Pairing strategies (1-1.5 timer)
- Testing (30 min)

---

## Future Settings (V5.5+)

Potentielle fremtidige indstillinger:
- **Pause Strategy:** Rolling pause vs wildcard match
- **Time per Match:** Tidsbegrænsning per kamp
- **Tiebreaker Rules:** Custom tiebreaker prioritering
- **Auto-advance:** Automatisk gå til næste runde ved completion
- **Sound Effects:** Enable/disable lyde og notifikationer
- **Theme:** Light/dark mode toggle

---

## Notes

- Settings skal være intuitive og have gode defaults
- Ikke overvælde brugeren - tre settings er passende for V5
- ExpansionTile gør det nemt at ignorere hvis man bare vil bruge defaults
- Hver setting har klar beskrivelse og hjælpetekst
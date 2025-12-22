# Player Pause Override - Visual Feature Guide

## 🎯 What This Feature Does

Allows tournament organizers to manually control which players are on pause during a round by simply clicking on player names.

## 📱 How It Looks (Visual Description)

### Before This Feature
```
┌─────────────────────────────────────┐
│ Pause Section                       │
├─────────────────────────────────────┤
│ 🟠 Pause                           │
│                                     │
│ [Player 5]  (plain chip, not       │
│              clickable)             │
└─────────────────────────────────────┘
```

### After This Feature
```
┌─────────────────────────────────────┐
│ Pause Section                       │
├─────────────────────────────────────┤
│ 🟠 Pause                           │
│                                     │
│ [▶️ Player 5]  ← ActionChip with   │
│                  play icon          │
│                  CLICKABLE!         │
└─────────────────────────────────────┘
```

## 🎮 User Interactions

### Scenario 1: Force Player from Pause to Active

```
Step 1: Click on player in pause section
┌─────────────────────────┐
│ 🟠 Pause               │
│ [▶️ Player 5] ← CLICK  │
└─────────────────────────┘
         ↓
Step 2: Confirmation dialog appears
┌─────────────────────────────────┐
│ Tving Player 5 til spille?     │
│                                 │
│ Dette vil tvinge Player 5      │
│ til at spille og omarrangere   │
│ de andre spillere.             │
│                                 │
│  [Annuller] [🟢 Tving til      │
│              spille]            │
└─────────────────────────────────┘
         ↓
Step 3: After confirmation
┌─────────────────────────────────┐
│ ✅ Player 5 er nu sat til at   │
│    spille                      │
└─────────────────────────────────┘
         ↓
Result: Round regenerates
┌─────────────────────────────────┐
│ Bane 1                         │
│ Par 1: Player 5 & Player 2     │ ← Player 5 now playing
│ Par 2: Player 3 & Player 4     │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ 🟠 Pause                       │
│ [▶️ Player 7]                  │ ← Different player on pause
└─────────────────────────────────┘
```

### Scenario 2: Force Player from Active to Pause

```
Step 1: Click on player name in match
┌─────────────────────────────────┐
│ 🎾 Bane 1                      │
│ ─────────────────────────────   │
│ Par 1                          │
│ [⏸️ Player 1] & [⏸️ Player 2]  │
│      ↑ CLICK                   │
└─────────────────────────────────┘
         ↓
Step 2: Confirmation dialog
┌─────────────────────────────────┐
│ Tving Player 1 til pause?      │
│                                 │
│ Dette vil tvinge Player 1      │
│ til at holde pause og          │
│ omarrangere de andre spillere. │
│                                 │
│  [Annuller] [🟠 Tving til      │
│              pause]             │
└─────────────────────────────────┘
         ↓
Step 3: Result
┌─────────────────────────────────┐
│ 🟠 Pause                       │
│ [▶️ Player 1]                  │ ← Player 1 now on pause
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ 🎾 Bane 1                      │
│ Par 1: Player 2 & Player 6     │ ← Regenerated match
└─────────────────────────────────┘
```

## ⚠️ Validation Examples

### Error 1: Scores Already Entered
```
User clicks player name
         ↓
┌─────────────────────────────────┐
│ ❌ Kan ikke ændre spillere når │
│    der er indtastet score      │
└─────────────────────────────────┘
No changes made (prevents data loss)
```

### Error 2: Max Pause Constraint
```
Setup: 9 players, 2 courts, 1 already on pause
User tries to force another to pause
         ↓
┌─────────────────────────────────────────┐
│ ❌ Kan ikke sætte flere spillere på   │
│    pause. Med 2 baner og 9 spillere,  │
│    kan maksimalt 1 spillere være på   │
│    pause.                              │
└─────────────────────────────────────────┘
Override blocked - constraint explained
```

## 🧮 The Math Behind It

### Maximum Pause Formula
```
maxPause = totalPlayers - (numberOfCourts × 4)
```

### Visual Examples

#### Example 1: 9 Players, 2 Courts
```
Players:  ●●●●●●●●●  (9 total)
Courts:   🎾🎾        (2 courts)
Needed:   ●●●● ●●●●  (8 players, 2 courts × 4)
Overflow: ●           (1 player)

Max on pause: 1
```

#### Example 2: 10 Players, 2 Courts
```
Players:  ●●●●●●●●●●  (10 total)
Courts:   🎾🎾          (2 courts)
Needed:   ●●●● ●●●●    (8 players)
Overflow: ●●            (2 players)

Max on pause: 2
```

#### Example 3: 13 Players, 3 Courts
```
Players:  ●●●●●●●●●●●●●  (13 total)
Courts:   🎾🎾🎾          (3 courts)
Needed:   ●●●● ●●●● ●●●● (12 players, 3 courts × 4)
Overflow: ●               (1 player)

Max on pause: 1
```

## 🎨 Visual Indicators

### Icons Used
- **▶️ Play Arrow** = "Force this player to active/play"
- **⏸️ Pause Icon** = "Force this player to pause"
- **🟢 Green Button** = "Force to active" action
- **🟠 Orange Button** = "Force to pause" action
- **✅ Green Snackbar** = Success message
- **❌ Red Snackbar** = Error message

### Color Coding
```
Action Chips in Pause:  [▶️ Name]  Orange background
Action Chips in Matches: [⏸️ Name]  Default background
Success Messages:         🟢 Green
Error Messages:           🔴 Red
Confirmation (Active):    🟢 Green button
Confirmation (Pause):     🟠 Orange button
```

## 🔄 Complete Flow Diagram

```
                    START
                      │
        ┌─────────────┴─────────────┐
        │                           │
   User sees                   User sees
  paused player              active player
  in pause section          in match card
        │                           │
        ├─── Click [▶️ Name] ───┐  │
        │                        │  │
        │    Click [⏸️ Name] ───┼──┘
        │                        │
        └────────────┬───────────┘
                     │
            Confirmation Dialog
                     │
        ┌────────────┼────────────┐
        │            │            │
    [Cancel]   [Confirm Force] [Confirm Force]
        │        to Active       to Pause
        │            │            │
        └──── No Change          │
                     │            │
              ┌──────┴──────┬─────┘
              │             │
         Validation    Validation
          Checks        Checks
              │             │
        ┌─────┼─────┐  ┌────┼────┐
        │     │     │  │    │    │
      Pass  Fail  Pass│  Fail   │
        │     │     │  │    │    │
        │   Error   │  │  Error  │
        │     │     │  │    │    │
        └─────┤     │  │    ├────┘
              │     │  │    │
         Regenerate │  │ Regenerate
           Round    │  │   Round
              │     │  │    │
              │     │  │    │
           Success  │  │ Success
           Message  │  │ Message
              │     │  │    │
              └─────┴──┴────┘
                     │
                   END
```

## 📱 Recommended Testing Flow

1. **Create Tournament**
   - 9 players, 2 courts (ensures 1 on pause)

2. **Test Force to Active**
   - Click paused player
   - Confirm action
   - Verify player now in a match

3. **Test Force to Pause**
   - Click active player
   - Confirm action
   - Verify player now on pause

4. **Test Validation**
   - Enter a score
   - Try to override → See error
   - Try to exceed max pause → See error

## 🎯 Key Takeaways

✅ **Simple**: Just click a player's name
✅ **Safe**: Confirmation before changes
✅ **Smart**: Validates constraints automatically
✅ **Clear**: Informative error messages
✅ **Instant**: No page reloads needed
✅ **Fair**: Maintains tournament balance rules

---

This visual guide should help understand the feature without seeing the actual UI.

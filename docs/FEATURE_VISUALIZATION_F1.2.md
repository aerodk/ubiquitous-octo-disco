# Feature Visualization: F.1.2 - Automatic Court Adjustment

## User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    SETUP SCREEN                                  │
│                                                                  │
│  Spillere (0/24)                                                │
│  ┌──────────────────────────────────────┬────────┐             │
│  │ Spiller navn                     [+] │ Tilføj │             │
│  └──────────────────────────────────────┴────────┘             │
│                                                                  │
│  (Empty list - no players added)                                │
│                                                                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                │
│                                                                  │
│  Baner                                                           │
│     [-]  1 bane  [+]  ← Normal state                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Automatic Adjustment Flow

### Scenario 1: Adding 5th Player (Triggers Auto-Adjustment)

```
STEP 1: User has 4 players, 1 court
┌─────────────────────────────────────────────┐
│  Spillere (4/24)                            │
│  • Player 1                                 │
│  • Player 2                                 │
│  • Player 3                                 │
│  • Player 4                                 │
│                                             │
│  Baner                                      │
│     [-]  1 bane  [+]                        │
└─────────────────────────────────────────────┘

↓ User adds "Player 5"

STEP 2: Auto-adjustment triggered
┌─────────────────────────────────────────────┐
│  Spillere (5/24)                            │
│  • Player 1                                 │
│  • Player 2                                 │
│  • Player 3                                 │
│  • Player 4                                 │
│  • Player 5 ← New                           │
│                                             │
│  Baner                                      │
│  ╔═════════════════════════╗                │
│  ║  [-]  2 baner  [+]     ║ ← ANIMATED     │
│  ╚═════════════════════════╝    HIGHLIGHT  │
└─────────────────────────────────────────────┘
                ▲
                │
        600ms pulsing effect
        Primary color @ 20% opacity
```

### Scenario 2: Removing Players (Auto-Adjusts Down)

```
BEFORE: 9 players → 3 courts
┌─────────────────────────────────────────────┐
│  Spillere (9/24)                            │
│  • Player 1 ... Player 9                    │
│                                             │
│  Baner                                      │
│     [-]  3 baner  [+]                       │
└─────────────────────────────────────────────┘

↓ Remove 1 player

AFTER: 8 players → 2 courts (ANIMATED)
┌─────────────────────────────────────────────┐
│  Spillere (8/24)                            │
│  • Player 1 ... Player 8                    │
│                                             │
│  Baner                                      │
│  ╔═════════════════════════╗                │
│  ║  [-]  2 baner  [+]     ║ ← ANIMATED     │
│  ╚═════════════════════════╝                │
└─────────────────────────────────────────────┘
```

### Scenario 3: Manual Override

```
USER ACTION: Manual adjustment
┌─────────────────────────────────────────────┐
│  Spillere (4/24)                            │
│  • 4 players                                │
│                                             │
│  Baner                                      │
│     [-]  1 bane  [+] ← User clicks [+]      │
└─────────────────────────────────────────────┘

↓ Manual increase

RESULT: No animation (manual change)
┌─────────────────────────────────────────────┐
│  Spillere (4/24)                            │
│  • 4 players                                │
│                                             │
│  Baner                                      │
│     [-]  2 baner  [+] ← No animation        │
└─────────────────────────────────────────────┘

↓ Add 5th player

AUTO-ADJUST: Back to suggested count
┌─────────────────────────────────────────────┐
│  Spillere (5/24)                            │
│  • 5 players                                │
│                                             │
│  Baner                                      │
│  ╔═════════════════════════╗                │
│  ║  [-]  2 baner  [+]     ║ ← ANIMATED     │
│  ╚═════════════════════════╝    (same value)│
└─────────────────────────────────────────────┘
```

## Calculation Logic Visualization

```
Player Count → Suggested Courts
────────────────────────────────
     0       →       1       (minimum)
    1-4      →       1       ┐
                              │ Same court
     5       →       2       ┘ (trigger animation)
    6-8      →       2       ┐
                              │ Same courts
     9       →       3       ┘ (trigger animation)
   10-12     →       3       
   13-16     →       4       
   17-20     →       5       
   21-24     →       6       
   25-28     →       7       
   29-32     →       8       (maximum)
```

## Animation Timeline

```
Time:    0ms        150ms       300ms       450ms       600ms
         │           │           │           │           │
Opacity: 0% ────▶  10% ────▶  20% ────▶  10% ────▶   0%
         │           │           │           │           │
Effect:  Start       Fade In     Peak        Fade Out    End
         │           │           │           │           │
Visual:  ░           ▒           █           ▒           ░
         transparent             highlight                transparent

Formula: (1 - |controller.value - 0.5| * 2) * 0.2
         Creates triangle wave: 0 → 1 → 0
```

## State Machine

```
                    ┌──────────────┐
                    │  Initial     │
                    │  State       │
                    └──────┬───────┘
                           │
                           ▼
          ┌────────────────────────────────┐
          │  Player Count Changed          │
          │  (Add or Remove Player)        │
          └────────┬───────────────────────┘
                   │
                   ▼
          ┌────────────────────────────────┐
          │  Calculate Suggested Count     │
          │  formula: (count + 3) ~/ 4    │
          └────────┬───────────────────────┘
                   │
                   ▼
          ┌────────────────────────────────┐
     ┌───│  Suggested != Current?          │───┐
     │   └────────────────────────────────┘   │
     │ YES                                  NO │
     ▼                                         ▼
┌────────────────┐                    ┌───────────────┐
│ Update Court   │                    │ No Change     │
│ Count          │                    │ No Animation  │
├────────────────┤                    └───────────────┘
│ Set Animating  │
│ = true         │
├────────────────┤
│ Start          │
│ Animation      │
│ (600ms)        │
├────────────────┤
│ Visual         │
│ Highlight      │
└────┬───────────┘
     │
     ▼
┌────────────────┐
│ Animation Done │
│ Set Animating  │
│ = false        │
└────────────────┘
```

## Key Behaviors Summary

| User Action | Court Change | Animation | Notes |
|-------------|-------------|-----------|-------|
| Add 1st-4th player | No change (stays 1) | ❌ No | Stays at minimum |
| Add 5th player | 1 → 2 courts | ✅ Yes | First threshold |
| Add 6th-8th player | No change (stays 2) | ❌ No | Same bracket |
| Add 9th player | 2 → 3 courts | ✅ Yes | New threshold |
| Remove player | May decrease | ✅ If changed | Automatic |
| Manual [+] button | +1 court | ❌ No | Manual action |
| Manual [-] button | -1 court | ❌ No | Manual action |

## Design Decisions

### Why Animation?
- **User Awareness**: Shows system made a change
- **Non-intrusive**: 600ms is noticeable but not annoying
- **Professional**: Smooth, polished user experience
- **Accessibility**: Visual feedback for state change

### Why Pulsing Effect?
- **Attention-grabbing**: Triangle wave draws eye
- **Natural**: Mimics breathing/pulsing pattern
- **Temporary**: Doesn't persist, just highlights change
- **Theme-aware**: Uses primary color from app theme

### Why Allow Manual Override?
- **Flexibility**: Users might have special needs
- **Trust**: Users have final control
- **Temporary**: Auto-adjustment will resume on next player change
- **Predictable**: Clear behavior pattern

---

**Feature Status:** ✅ Fully Implemented  
**Visual Design:** Complete with animation  
**User Testing:** Ready for manual verification

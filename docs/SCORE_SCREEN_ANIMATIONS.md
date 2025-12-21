# Score Screen Animations

## Overview
The tournament completion screen now features interactive animations that build anticipation and make revealing the final standings more engaging and fun.

## Features

### 🥇 Top 3 Podium Reveal
When the tournament ends, the top 3 positions are initially hidden behind medal overlays:
- **1st Place**: Hidden behind a large gold medal (🥇)
- **2nd Place**: Hidden behind a large silver medal (🥈)
- **3rd Place**: Hidden behind a large bronze medal (🥉)

**How to reveal:**
1. Tap on any medal to reveal that position
2. The medal fades out smoothly
3. Player name and points appear with a fade-in animation
4. Celebration particles appear briefly (stars/sparkles effect)

### 📊 Other Positions (4+)
All positions below the top 3 are also hidden initially:
- Shown with a grey background
- "?" displayed instead of rank, name, and points
- "Tryk for at afsløre" (Tap to reveal) message

**How to reveal:**
- Tap on any hidden position to reveal it individually
- Smooth transition animation when revealing

### 🚀 Quick Reveal
Don't want to tap each position individually?
- **"Vis Alle Placeringer"** button appears below the podium
- One tap reveals ALL positions at once
- Top 3 medals fade out simultaneously
- All leaderboard positions become visible

## User Experience Flow

1. **Tournament Ends** → Automatic navigation to completion screen
2. **Initial View** → All positions hidden, building anticipation
3. **Interact** → Tap medals and positions to reveal results
4. **Celebrate** → See animations as each position is revealed
5. **Quick Reveal** → Optional button to show everything at once

## Technical Details

### Animations
- **Medal Fade**: 800ms smooth fade-out
- **Text Reveal**: 500ms opacity transition
- **Celebration**: 1500ms particle animation
- **Position Reveal**: 300ms container animation

### Performance
- All animations use Flutter's hardware-accelerated rendering
- Particles are drawn with custom painter for efficiency
- Animation controllers are properly disposed to prevent memory leaks

### Accessibility
- All interactive elements have clear tap targets
- Visual feedback on tap
- Works without animations if reduced motion is enabled

## Danish Text
- "Vis Alle Placeringer" = Show All Positions
- "Tryk for at afsløre" = Tap to reveal

## Future Enhancements
Potential improvements for future versions:
- Sound effects on reveal
- Different celebration patterns (confetti, fireworks)
- Leaderboard animation (positions sliding in)
- Share screenshot of final standings
- Trophy/medal rotation animation

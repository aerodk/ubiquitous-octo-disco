# Padel Tournament App - Logo Options

Three comic-style logo options with vibrant colors and focus on padel:

## Logo Option 1: Playful Padel Racket with Ball
**Style:** Dynamic and energetic  
**Colors:** Orange gradient racket (#FF6B35 to #FF9F1C), Teal ball (#2EC4B6), Yellow burst (#FFD23F)  
**Elements:** 
- Large comic-style padel racket with perforated face
- Dynamic ball with motion lines
- "PADEL!" text in bold comic font
- Action burst lines for energy

**Best for:** Main app icon, splash screen, energetic branding

![Logo Option 1](logo_option_1.svg)

---

## Logo Option 2: Tournament Trophy with Padel Theme
**Style:** Celebratory and prestigious  
**Colors:** Gold trophy (#FFD700), Teal & Red crossed rackets (#2EC4B6, #E63946), Orange burst (#FF6B35)  
**Elements:**
- Golden trophy cup with shine effects
- Crossed padel rackets behind trophy
- Ball on top of trophy
- "CHAMPION" text
- Confetti and star decorations
- Celebration burst background

**Best for:** Achievement badges, tournament completion screens, winners

![Logo Option 2](logo_option_2.svg)

---

## Logo Option 3: Dynamic Action Scene with Players
**Style:** Active and social  
**Colors:** Teal court (#4ECDC4), Red & Teal players, Yellow ball (#FFD700)  
**Elements:**
- Padel court with net and lines
- Two comic-style players in action poses
- Ball in mid-flight with motion blur
- Comic action words: "POW!" and "SMASH!"
- "PADEL!" title text
- Speed lines for dynamic effect

**Best for:** Social sharing, tournament promotion, action-oriented marketing

![Logo Option 3](logo_option_3.svg)

---

## Implementation Notes

All logos are created as SVG (Scalable Vector Graphics) for:
- Perfect scaling at any size
- Small file size
- Crisp display on all devices
- Easy color customization if needed

### To Use in Flutter App:

1. **Update `pubspec.yaml`** to include assets:
```yaml
flutter:
  assets:
    - assets/logos/
```

2. **Display SVG in Flutter** (requires `flutter_svg` package):
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/logos/logo_option_1.svg',
  width: 200,
  height: 200,
)
```

3. **For web favicon/icons**, convert SVG to PNG at different sizes (16x16, 192x192, 512x512)

### Color Palette Reference

**Primary Colors:**
- Orange: #FF6B35, #FF9F1C
- Teal: #2EC4B6, #4ECDC4
- Red: #E63946, #FF6B6B
- Yellow/Gold: #FFD700, #FFD23F

**Accent Colors:**
- Dark Gray: #4A4A4A, #2D2D2D
- Skin Tone: #FFD4A3
- Brown (bases): #8B4513

These vibrant, comic-style colors create an energetic and fun brand identity perfect for a social padel tournament app!

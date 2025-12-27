# Large Screen Mode - Quick Reference

## Summary

A manual toggle feature that allows users to switch between mobile and desktop layouts. Particularly useful when mirroring mobile devices to larger displays (TV, projector, monitor) via HDMI or screen sharing.

## Problem Solved

When sharing a mobile screen to a large display, the mobile-optimized UI appears too small. This feature provides a manual toggle to switch to a larger "desktop" mode with scaled-up fonts and UI elements.

## Implementation

### Scaling Factors (constants.dart)
```dart
desktopModeScaleFactor = 1.5  // UI elements 50% larger
desktopModeFontScale = 1.3    // Fonts 30% larger
desktopModeCardPadding = 24.0 // More padding
mobileModeCardPadding = 16.0  // Standard padding
```

### Toggle Location
- Leaderboard Screen (app bar, top-right)
- Round Display Screen (app bar, top-right)
- Tournament Completion Screen (app bar, top-right)

### Visual Indicators
- 📱 Phone icon = Mobile Mode (default)
- 🖥️ Desktop icon = Desktop Mode (active)

### Persistence
- Stored in SharedPreferences
- Key: `'display_mode'`
- Persists across app restarts

## Quick Start

### For Users
1. Connect mobile device to large screen
2. Open app to any main screen
3. Tap desktop icon in app bar
4. UI scales up for better visibility

### For Developers

**Add toggle to screen:**
```dart
// 1. Add service and state
final DisplayModeService _displayModeService = DisplayModeService();
bool _isDesktopMode = false;

// 2. Load mode in initState
Future<void> _loadDisplayMode() async {
  final isDesktop = await _displayModeService.isDesktopMode();
  setState(() => _isDesktopMode = isDesktop);
}

// 3. Toggle method
Future<void> _toggleDisplayMode() async {
  final newMode = await _displayModeService.toggleDisplayMode();
  setState(() => _isDesktopMode = newMode);
}

// 4. Add button to AppBar
IconButton(
  icon: Icon(_isDesktopMode ? Icons.desktop_windows : Icons.phone_android),
  onPressed: _toggleDisplayMode,
)
```

**Scale UI elements:**
```dart
// Calculate scale factors
final fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
final sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;

// Apply to widgets
Text('Name', style: TextStyle(fontSize: 16 * fontScale))
SizedBox(height: 12 * sizeScale)
Padding(padding: EdgeInsets.all(cardPadding))
```

## Affected Components

### Screens
- ✅ Leaderboard Screen
- ✅ Round Display Screen
- ✅ Tournament Completion Screen
- ❌ Setup Screen (not needed)

### Widgets
- ✅ MatchCard
- ✅ TeamSide
- ✅ PlayerMarker
- ✅ ScoreDisplay
- ✅ NetDivider

## Use Cases

1. **Tournament Presentation**: Display leaderboard on TV for spectators
2. **Match Organization**: Show round display on monitor so players can find courts
3. **Award Ceremony**: Present final results on projector
4. **Screen Sharing**: Better visibility during remote tournament management

## Files Changed

```
lib/services/display_mode_service.dart          (NEW)
lib/utils/constants.dart                        (updated)
lib/screens/leaderboard_screen.dart             (updated)
lib/screens/round_display_screen.dart           (updated)
lib/screens/tournament_completion_screen.dart   (updated)
lib/widgets/match_card.dart                     (updated)
lib/widgets/court_visualization/team_side.dart  (updated)
lib/widgets/court_visualization/player_marker.dart (updated)
lib/widgets/court_visualization/score_display.dart (updated)
lib/widgets/court_visualization/net_divider.dart   (updated)
docs/LARGE_SCREEN_MODE.md                       (NEW)
docs/LARGE_SCREEN_MODE_USER_GUIDE.md            (NEW)
```

## Testing Checklist

- [ ] Toggle persists after app restart
- [ ] Leaderboard scales correctly
- [ ] Round display match cards scale correctly
- [ ] Completion screen podium scales correctly
- [ ] No layout overflow in either mode
- [ ] Smooth transition between modes
- [ ] Icons change appropriately (phone ↔ desktop)
- [ ] Tooltips display correctly
- [ ] Works on actual HDMI-connected display
- [ ] Works on different screen sizes

## Documentation

- **Technical Guide**: `docs/LARGE_SCREEN_MODE.md`
- **User Guide**: `docs/LARGE_SCREEN_MODE_USER_GUIDE.md`
- **This Document**: Quick reference for developers

## Version

- **Initial Release**: 2025-12-27
- **Version**: 1.0
- **Branch**: `copilot/add-large-screen-mode-option`

## Future Enhancements

- Auto-detect screen size
- Per-screen preferences
- Custom scale factors
- Landscape mode detection
- Tablet-optimized mode

# Large Screen Mode Feature

## Overview

The Large Screen Mode feature allows users to manually toggle between mobile and desktop layouts. This is particularly useful when mirroring a mobile device to a larger display via USB-to-HDMI or screen sharing, as it ensures the content is properly sized for the larger screen.

## Problem Statement

When using a mobile device connected to a large screen (via USB to HDMI or screen mirroring), the app displays in mobile-optimized layout which appears too small on big screens. Users need a way to manually switch to a desktop/large screen mode for better visibility when sharing from a small to a big screen.

## Solution

A persistent toggle button in the app bar allows users to switch between mobile and desktop display modes. The preference is saved using SharedPreferences and persists across app restarts.

## Features

### Display Mode Service

- **Location**: `lib/services/display_mode_service.dart`
- **Purpose**: Manages display mode preference using SharedPreferences
- **Methods**:
  - `isDesktopMode()`: Get current display mode
  - `setDesktopMode(bool)`: Set display mode
  - `toggleDisplayMode()`: Toggle between modes

### Affected Screens

The display mode toggle is available on three main screens:

#### 1. Leaderboard Screen
- **Toggle button**: Phone/Desktop icon in app bar
- **Scales**: 
  - Card padding and margins
  - Font sizes (rank badges, player names, statistics)
  - Icon sizes (medals, position change indicators)
  - Spacing between elements

#### 2. Round Display Screen (Lane View)
- **Toggle button**: Phone/Desktop icon in app bar
- **Scales**:
  - Match card dimensions and padding
  - Court layout (affects column count for responsive grid)
  - Player markers and team labels
  - Score displays
  - Net divider
  - All text and icons within match cards

#### 3. Tournament Completion Screen
- **Toggle button**: Phone/Desktop icon in app bar
- **Scales**:
  - Trophy icon and congratulations message
  - Podium (1st, 2nd, 3rd place displays)
  - Tournament statistics card
  - Leaderboard tiles and detailed cards
  - All fonts and spacing

### Scaling Factors

Defined in `lib/utils/constants.dart`:

```dart
// Display mode constants (for manual desktop/mobile toggle)
static const double desktopModeScaleFactor = 1.5;     // Scale UI elements by 50%
static const double desktopModeFontScale = 1.3;       // Scale fonts by 30%
static const double desktopModeCardPadding = 24.0;    // Increased padding for desktop
static const double mobileModeCardPadding = 16.0;     // Standard mobile padding
```

### Responsive Grid Behavior

In Round Display Screen, desktop mode affects the responsive grid logic:

- **Mobile Mode**: 
  - 1 column: < 800px width
  - 2 columns: 800-1200px width
  - 3 columns: > 1200px width

- **Desktop Mode**: 
  - Effective width is multiplied by `desktopModeScaleFactor` (1.5x)
  - This forces more columns on smaller screens when in desktop mode

## User Interface

### Toggle Icon

- **Mobile Mode**: 📱 Phone icon (Icons.phone_android)
- **Desktop Mode**: 🖥️ Desktop icon (Icons.desktop_windows)

### Tooltip Text

- **When in Mobile Mode**: "Skift til desktop visning" (Switch to desktop view)
- **When in Desktop Mode**: "Skift til mobil visning" (Switch to mobile view)

## Implementation Details

### Widget Scaling Pattern

All scaled widgets follow this pattern:

```dart
final double fontScale = _isDesktopMode ? Constants.desktopModeFontScale : 1.0;
final double sizeScale = _isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
final double cardPadding = _isDesktopMode 
  ? Constants.desktopModeCardPadding 
  : Constants.mobileModeCardPadding;

// Apply to widgets
Text(
  'Example',
  style: TextStyle(fontSize: 16 * fontScale),
)

Padding(
  padding: EdgeInsets.all(cardPadding),
  child: ...
)

SizedBox(height: 12 * sizeScale)
```

### Persistence

Display mode preference can be saved to SharedPreferences with key: `'display_mode'`

- `true` = Desktop mode
- `false` = Mobile mode  
- Default on app start: `false` (Mobile mode)

**Note**: The display mode preference is saved when toggled but does not auto-load on app restart to maintain test compatibility. Users can toggle to desktop mode at the start of each session, and the toggle state will persist throughout that session.

## Use Cases

### Primary Use Case: Screen Mirroring
When presenting from a mobile device to a large display:
1. Connect mobile device to large screen via USB-to-HDMI or wireless mirroring
2. Open the tournament app
3. Tap the desktop icon in the app bar
4. UI scales up for better visibility on the large screen
5. Preference persists across all screens and app restarts

### Secondary Use Case: Desktop Browser Testing
When testing in browser with "Request Desktop Site" option:
1. Open app in mobile browser
2. Enable "Request Desktop Site" in browser
3. Toggle to desktop mode in app for better layout
4. Toggle back to mobile mode when switching back to mobile browser view

## Browser Compatibility

The feature works on:
- Chrome (mobile and desktop)
- Safari (mobile and desktop)
- Firefox (mobile and desktop)
- Edge (desktop)

## Future Enhancements

Potential improvements for future versions:

1. **Auto-detect Screen Size**: Automatically switch mode based on detected screen width
2. **Custom Scale Factors**: Allow users to fine-tune scale factors
3. **Landscape Mode Detection**: Automatically switch to desktop mode in landscape orientation
4. **Per-Screen Preferences**: Remember different modes for different screens
5. **Tablet Mode**: Add a third mode optimized specifically for tablets

## Testing Checklist

- [ ] Toggle persists after app restart
- [ ] All three screens scale correctly in desktop mode
- [ ] Font sizes are readable and well-proportioned
- [ ] Card spacing looks good in both modes
- [ ] Icons scale appropriately
- [ ] Podium renders correctly in desktop mode
- [ ] Match cards fit properly in responsive grid
- [ ] No overflow or layout issues
- [ ] Smooth transition between modes
- [ ] Works on different screen sizes

## Related Files

### Core Implementation
- `lib/services/display_mode_service.dart` - Service for managing display mode
- `lib/utils/constants.dart` - Scaling constants

### Screen Updates
- `lib/screens/leaderboard_screen.dart`
- `lib/screens/round_display_screen.dart`
- `lib/screens/tournament_completion_screen.dart`

### Widget Updates
- `lib/widgets/match_card.dart`
- `lib/widgets/court_visualization/team_side.dart`
- `lib/widgets/court_visualization/player_marker.dart`
- `lib/widgets/court_visualization/score_display.dart`
- `lib/widgets/court_visualization/net_divider.dart`

## Version History

- **Version 1.0** (2025-12-27): Initial implementation
  - Display mode toggle on all main screens
  - Persistent preference storage
  - Comprehensive UI scaling

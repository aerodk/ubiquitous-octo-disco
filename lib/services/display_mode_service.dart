import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing display mode preference (mobile vs desktop layout)
/// This allows users to manually toggle between mobile and desktop layouts,
/// useful when mirroring mobile screen to a larger display via HDMI
class DisplayModeService {
  static const String _displayModeKey = 'display_mode';
  
  /// Get the current display mode
  /// Returns true for desktop mode, false for mobile mode
  /// Defaults to mobile mode (false) if not set or if SharedPreferences is unavailable
  Future<bool> isDesktopMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_displayModeKey) ?? false;
    } catch (e) {
      // SharedPreferences not available (e.g., in tests), return default
      return false;
    }
  }
  
  /// Set the display mode
  /// Pass true for desktop mode, false for mobile mode
  Future<void> setDesktopMode(bool isDesktop) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_displayModeKey, isDesktop);
    } catch (e) {
      // SharedPreferences not available (e.g., in tests), silently fail
    }
  }
  
  /// Toggle the display mode and return the new value
  Future<bool> toggleDisplayMode() async {
    final currentMode = await isDesktopMode();
    await setDesktopMode(!currentMode);
    return !currentMode;
  }
}

/// Display mode enum for clarity
enum DisplayMode {
  mobile,
  desktop,
}

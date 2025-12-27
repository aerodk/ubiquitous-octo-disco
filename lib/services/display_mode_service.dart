import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing display mode preference (mobile vs desktop layout)
/// This allows users to manually toggle between mobile and desktop layouts,
/// useful when mirroring mobile screen to a larger display via HDMI
class DisplayModeService {
  static const String _displayModeKey = 'display_mode';
  
  /// Get the current display mode
  /// Returns true for desktop mode, false for mobile mode
  /// Defaults to mobile mode (false) if not set
  Future<bool> isDesktopMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_displayModeKey) ?? false;
  }
  
  /// Set the display mode
  /// Pass true for desktop mode, false for mobile mode
  Future<void> setDesktopMode(bool isDesktop) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayModeKey, isDesktop);
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

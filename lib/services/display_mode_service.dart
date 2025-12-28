import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing display mode preference (mobile vs desktop layout)
/// This allows users to manually toggle between mobile and desktop layouts,
/// useful when mirroring mobile screen to a larger display via HDMI
class DisplayModeService {
  static const String _displayModeKey = 'display_mode';
  static const String _zoomFactorKey = 'display_zoom_factor';

  // Zoom bounds for manual scaling
  static const double defaultZoomFactor = 1.0;
  static const double minZoomFactor = 0.8;
  static const double maxZoomFactor = 1.5;
  
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

  /// Get the current zoom factor for display scaling
  /// Defaults to [defaultZoomFactor] and clamps to valid range
  Future<double> getZoomFactor() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_zoomFactorKey);
    return _clampZoom(saved ?? defaultZoomFactor);
  }

  /// Persist the zoom factor (will be clamped to valid range)
  Future<double> setZoomFactor(double zoom) async {
    final clamped = _clampZoom(zoom);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_zoomFactorKey, clamped);
    return clamped;
  }

  double _clampZoom(double zoom) {
    if (zoom < minZoomFactor) return minZoomFactor;
    if (zoom > maxZoomFactor) return maxZoomFactor;
    return zoom;
  }
}

/// Display mode enum for clarity
enum DisplayMode {
  mobile,
  desktop,
}

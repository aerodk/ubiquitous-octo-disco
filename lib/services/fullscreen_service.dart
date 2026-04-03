import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

// Conditional import: real web implementation on web, stub elsewhere.
import '../utils/fullscreen_stub.dart'
    if (dart.library.html) '../utils/fullscreen_web.dart';

/// Service for managing fullscreen / immersive mode.
///
/// On mobile platforms the system status bar and navigation bar are hidden
/// using [SystemChrome].  On web the browser Fullscreen API is used.
class FullscreenService {
  bool _isFullscreen = false;

  /// Whether the app is currently in fullscreen mode.
  bool get isFullscreen => _isFullscreen;

  /// Toggle fullscreen mode and return the new state.
  Future<bool> toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
    } else {
      await _enterFullscreen();
    }
    return _isFullscreen;
  }

  /// Enter fullscreen / immersive mode.
  Future<void> enterFullscreen() => _enterFullscreen();

  /// Exit fullscreen / immersive mode.
  Future<void> exitFullscreen() => _exitFullscreen();

  Future<void> _enterFullscreen() async {
    if (kIsWeb) {
      await enterBrowserFullscreen();
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _isFullscreen = true;
  }

  Future<void> _exitFullscreen() async {
    if (kIsWeb) {
      await exitBrowserFullscreen();
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _isFullscreen = false;
  }

  /// Restore the default system UI when the service is no longer needed.
  /// Called from [State.dispose], so must be synchronous (fire-and-forget).
  void dispose() {
    if (_isFullscreen) {
      _isFullscreen = false;
      if (kIsWeb) {
        exitBrowserFullscreen();
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
  }
}

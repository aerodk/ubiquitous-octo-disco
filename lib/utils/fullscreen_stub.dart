// Stub implementation of browser fullscreen API for non-web platforms.
// Used via conditional import:
//   import 'fullscreen_stub.dart' if (dart.library.html) 'fullscreen_web.dart';

Future<void> enterBrowserFullscreen() async {}

Future<void> exitBrowserFullscreen() async {}

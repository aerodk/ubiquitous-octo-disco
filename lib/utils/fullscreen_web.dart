// Web implementation of browser fullscreen API using package:web.
// Used via conditional import:
//   import 'fullscreen_stub.dart' if (dart.library.html) 'fullscreen_web.dart';

import 'package:web/web.dart' as web;

Future<void> enterBrowserFullscreen() async {
  try {
    final elem = web.document.documentElement;
    if (elem != null) {
      elem.requestFullscreen();
    }
  } catch (_) {
    // Browser may deny fullscreen if not triggered by a user gesture.
  }
}

Future<void> exitBrowserFullscreen() async {
  try {
    if (web.document.fullscreenElement != null) {
      web.document.exitFullscreen();
    }
  } catch (_) {
    // Ignore errors when exiting fullscreen.
  }
}

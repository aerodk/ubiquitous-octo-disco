// Web implementation of browser fullscreen API using dart:html.
// Used via conditional import:
//   import 'fullscreen_stub.dart' if (dart.library.html) 'fullscreen_web.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> enterBrowserFullscreen() async {
  try {
    final elem = html.document.documentElement;
    if (elem != null) {
      elem.requestFullscreen();
    }
  } catch (_) {
    // Browser may deny fullscreen if not triggered by a user gesture.
  }
}

Future<void> exitBrowserFullscreen() async {
  try {
    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
    }
  } catch (_) {
    // Ignore errors when exiting fullscreen.
  }
}

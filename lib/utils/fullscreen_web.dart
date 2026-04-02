// Web implementation of browser fullscreen API using dart:html.
// Used via conditional import:
//   import 'fullscreen_stub.dart' if (dart.library.html) 'fullscreen_web.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> enterBrowserFullscreen() async {
  final elem = html.document.documentElement;
  if (elem != null) {
    elem.requestFullscreen();
  }
}

Future<void> exitBrowserFullscreen() async {
  if (html.document.fullscreenElement != null) {
    html.document.exitFullscreen();
  }
}

bool isBrowserFullscreen() {
  return html.document.fullscreenElement != null;
}

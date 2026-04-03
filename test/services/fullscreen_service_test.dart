import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/services/fullscreen_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FullscreenService', () {
    late FullscreenService service;

    setUp(() {
      service = FullscreenService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initial state is not fullscreen', () {
      expect(service.isFullscreen, isFalse);
    });

    test('toggleFullscreen enters fullscreen and returns true', () async {
      final result = await service.toggleFullscreen();
      expect(result, isTrue);
      expect(service.isFullscreen, isTrue);
    });

    test('toggleFullscreen twice returns to non-fullscreen', () async {
      await service.toggleFullscreen();
      final result = await service.toggleFullscreen();
      expect(result, isFalse);
      expect(service.isFullscreen, isFalse);
    });

    test('enterFullscreen sets isFullscreen to true', () async {
      await service.enterFullscreen();
      expect(service.isFullscreen, isTrue);
    });

    test('exitFullscreen sets isFullscreen to false', () async {
      await service.enterFullscreen();
      await service.exitFullscreen();
      expect(service.isFullscreen, isFalse);
    });

    test('dispose resets isFullscreen flag', () async {
      await service.enterFullscreen();
      service.dispose();
      expect(service.isFullscreen, isFalse);
    });

    test('dispose when not in fullscreen does nothing', () {
      expect(() => service.dispose(), returnsNormally);
      expect(service.isFullscreen, isFalse);
    });
  });
}

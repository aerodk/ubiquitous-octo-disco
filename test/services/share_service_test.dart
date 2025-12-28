import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/services/share_service.dart';

void main() {
  group('ShareService', () {
    late ShareService shareService;

    setUp(() {
      shareService = ShareService();
    });

    group('generateShareLink', () {
      test('should generate link without passcode', () {
        final link = shareService.generateShareLink(
          tournamentCode: '12345678',
          includePasscode: false,
        );

        expect(link, contains('/#/tournament/12345678'));
        expect(link, isNot(contains('?p=')));
      });

      test('should generate link with passcode', () {
        final link = shareService.generateShareLink(
          tournamentCode: '12345678',
          includePasscode: true,
          passcode: '123456',
        );

        expect(link, contains('/#/tournament/12345678?p=123456'));
      });

      test('should throw error when passcode is required but not provided', () {
        expect(
          () => shareService.generateShareLink(
            tournamentCode: '12345678',
            includePasscode: true,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error when passcode is empty and includePasscode is true', () {
        expect(
          () => shareService.generateShareLink(
            tournamentCode: '12345678',
            includePasscode: true,
            passcode: '',
          ),
          throwsArgumentError,
        );
      });
    });

    group('parseTournamentFromUrl', () {
      test('should parse tournament code from URL without passcode', () {
        final uri = Uri.parse('https://example.com/#/tournament/12345678');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNotNull);
        expect(result!['code'], equals('12345678'));
        expect(result['passcode'], isNull);
        expect(result['isReadOnly'], isTrue);
      });

      test('should parse tournament code and passcode from URL', () {
        final uri = Uri.parse('https://example.com/#/tournament/12345678?p=123456');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNotNull);
        expect(result!['code'], equals('12345678'));
        expect(result['passcode'], equals('123456'));
        expect(result['isReadOnly'], isFalse);
      });

      test('should return null for URL without tournament', () {
        final uri = Uri.parse('https://example.com/');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNull);
      });

      test('should return null for invalid tournament code format', () {
        final uri = Uri.parse('https://example.com/#/tournament/abc');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNull);
      });

      test('should return null for tournament code with wrong length', () {
        final uri = Uri.parse('https://example.com/#/tournament/123456');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNull);
      });

      test('should return null for invalid passcode format', () {
        final uri = Uri.parse('https://example.com/#/tournament/12345678?p=abc');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNull);
      });

      test('should return null for passcode with wrong length', () {
        final uri = Uri.parse('https://example.com/#/tournament/12345678?p=1234');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNull);
      });

      test('should handle URLs with different paths before tournament', () {
        final uri = Uri.parse('https://example.com/some/path#/tournament/12345678');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNotNull);
        expect(result!['code'], equals('12345678'));
      });
    });

    group('hasTournamentInUrl', () {
      test('should return true for URL with valid tournament', () {
        final uri = Uri.parse('https://example.com/#/tournament/12345678');
        final result = shareService.hasTournamentInUrl(uri);

        expect(result, isTrue);
      });

      test('should return false for URL without tournament', () {
        final uri = Uri.parse('https://example.com/');
        final result = shareService.hasTournamentInUrl(uri);

        expect(result, isFalse);
      });

      test('should return false for URL with invalid tournament code', () {
        final uri = Uri.parse('https://example.com/#/tournament/invalid');
        final result = shareService.hasTournamentInUrl(uri);

        expect(result, isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle URL with query parameters and fragment', () {
        final uri = Uri.parse('https://example.com/?foo=bar#/tournament/12345678?p=123456');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNotNull);
        expect(result!['code'], equals('12345678'));
        expect(result['passcode'], equals('123456'));
      });

      test('should handle tournament code with leading zeros', () {
        final uri = Uri.parse('https://example.com/#/tournament/00000001');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNotNull);
        expect(result!['code'], equals('00000001'));
      });

      test('should handle passcode with leading zeros', () {
        final uri = Uri.parse('https://example.com/#/tournament/12345678?p=000001');
        final result = shareService.parseTournamentFromUrl(uri);

        expect(result, isNotNull);
        expect(result!['passcode'], equals('000001'));
      });
    });
  });
}

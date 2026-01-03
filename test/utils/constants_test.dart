import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/utils/constants.dart';

void main() {
  group('Constants', () {
    test('getDefaultTournamentName returns name with date', () {
      final name = Constants.getDefaultTournamentName();
      
      // Should start with "Padel turnering"
      expect(name, startsWith('Padel turnering'));
      
      // Should contain a date in DD-MM-YYYY format
      // The pattern should match: "Padel turnering DD-MM-YYYY"
      final datePattern = RegExp(r'Padel turnering \d{2}-\d{2}-\d{4}$');
      expect(name, matches(datePattern));
    });

    test('getDefaultTournamentName includes current date', () {
      final name = Constants.getDefaultTournamentName();
      final now = DateTime.now();
      
      // Extract the date part
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      
      final expectedDate = '$day-$month-$year';
      expect(name, contains(expectedDate));
    });

    test('getDefaultCourtName returns correct court name', () {
      expect(Constants.getDefaultCourtName(0), 'Bane 1');
      expect(Constants.getDefaultCourtName(1), 'Bane 2');
      expect(Constants.getDefaultCourtName(10), 'Bane 11');
    });
  });
}

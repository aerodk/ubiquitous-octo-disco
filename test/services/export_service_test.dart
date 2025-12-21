import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/services/export_service.dart';
import 'package:star_cano/models/player.dart';
import 'package:star_cano/models/player_standing.dart';
import 'package:star_cano/models/tournament.dart';
import 'package:star_cano/models/court.dart';

void main() {
  group('ExportService', () {
    late List<PlayerStanding> standings;
    late Tournament tournament;

    setUp(() {
      final player1 = Player(id: '1', name: 'Alice');
      final player2 = Player(id: '2', name: 'Bob');
      final player3 = Player(id: '3', name: 'Charlie');

      standings = [
        PlayerStanding(
          player: player1,
          totalPoints: 48,
          wins: 2,
          losses: 0,
          matchesPlayed: 2,
          biggestWinMargin: 10,
          smallestLossMargin: 999,
          headToHeadPoints: {},
          rank: 1,
          pauseCount: 0,
        ),
        PlayerStanding(
          player: player2,
          totalPoints: 40,
          wins: 1,
          losses: 1,
          matchesPlayed: 2,
          biggestWinMargin: 5,
          smallestLossMargin: 5,
          headToHeadPoints: {},
          rank: 2,
          pauseCount: 1,
        ),
        PlayerStanding(
          player: player3,
          totalPoints: 36,
          wins: 0,
          losses: 2,
          matchesPlayed: 2,
          biggestWinMargin: 0,
          smallestLossMargin: 10,
          headToHeadPoints: {},
          rank: 3,
          pauseCount: 0,
        ),
      ];

      tournament = Tournament(
        name: 'Test Tournament',
        players: [player1, player2, player3],
        courts: [Court(id: 'c1', name: 'Court 1')],
        createdAt: DateTime(2025, 1, 15, 10, 0),
      );
    });

    group('CSV Export', () {
      test('should export standings to CSV format with correct headers', () {
        final csvData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.csv,
        );

        expect(csvData, contains('Rank'));
        expect(csvData, contains('Player Name'));
        expect(csvData, contains('Total Points'));
        expect(csvData, contains('Wins'));
        expect(csvData, contains('Losses'));
        expect(csvData, contains('Matches Played'));
        expect(csvData, contains('Win Rate (%)'));
        expect(csvData, contains('Biggest Win Margin'));
        expect(csvData, contains('Smallest Loss Margin'));
        expect(csvData, contains('Pause Count'));
      });

      test('should export player data correctly in CSV format', () {
        final csvData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.csv,
        );

        // Check Alice's data
        expect(csvData, contains('1,Alice,48,2,0,2,100.0,10,'));
        
        // Check Bob's data
        expect(csvData, contains('2,Bob,40,1,1,2,50.0,5,5,1'));
        
        // Check Charlie's data
        expect(csvData, contains('3,Charlie,36,0,2,2,0.0,0,10,0'));
      });

      test('should handle empty standings list', () {
        final csvData = ExportService.exportStandings(
          standings: [],
          tournament: tournament,
          format: ExportFormat.csv,
        );

        // Should still have headers
        expect(csvData, contains('Rank'));
        
        // Should not have player data
        expect(csvData.split('\n').length, equals(2)); // Header + empty line
      });

      test('should calculate win rate correctly', () {
        final csvData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.csv,
        );

        // Alice: 2/2 = 100%
        expect(csvData, contains('100.0'));
        
        // Bob: 1/2 = 50%
        expect(csvData, contains('50.0'));
        
        // Charlie: 0/2 = 0%
        expect(csvData, contains('0.0'));
      });

      test('should handle player with no losses showing dash for smallest loss', () {
        final csvData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.csv,
        );

        // Alice has no losses, so smallest loss should be represented as '-'
        final lines = csvData.split('\n');
        final aliceLine = lines.firstWhere((line) => line.contains('Alice'));
        
        // The CSV should have '-' for smallest loss margin when it's 999
        expect(aliceLine, contains(',-,'));
      });
    });

    group('JSON Export', () {
      test('should export standings to JSON format with tournament info', () {
        final jsonData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.json,
        );

        expect(jsonData, contains('"tournament"'));
        expect(jsonData, contains('"name": "Test Tournament"'));
        expect(jsonData, contains('"totalRounds"'));
        expect(jsonData, contains('"totalPlayers"'));
      });

      test('should export player standings in JSON format', () {
        final jsonData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.json,
        );

        expect(jsonData, contains('"standings"'));
        expect(jsonData, contains('"playerName": "Alice"'));
        expect(jsonData, contains('"playerName": "Bob"'));
        expect(jsonData, contains('"playerName": "Charlie"'));
        expect(jsonData, contains('"rank": 1'));
        expect(jsonData, contains('"totalPoints": 48'));
      });

      test('should calculate win rate in JSON export', () {
        final jsonData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.json,
        );

        // Check for win rates
        expect(jsonData, contains('"winRate": 1.0')); // Alice 100%
        expect(jsonData, contains('"winRate": 0.5')); // Bob 50%
        expect(jsonData, contains('"winRate": 0')); // Charlie 0%
      });

      test('should handle null smallest loss margin in JSON', () {
        final jsonData = ExportService.exportStandings(
          standings: standings,
          tournament: tournament,
          format: ExportFormat.json,
        );

        // Alice has 999 smallest loss, should be null in JSON
        expect(jsonData, contains('"smallestLossMargin": null'));
      });
    });

    group('File Naming', () {
      test('should generate correct file name for CSV', () {
        final fileName = ExportService.getFileName(
          tournament: tournament,
          format: ExportFormat.csv,
        );

        expect(fileName, contains('Test Tournament'));
        expect(fileName, endsWith('.csv'));
        expect(fileName, matches(RegExp(r'\d{4}-\d{2}-\d{2}')));
      });

      test('should generate correct file name for JSON', () {
        final fileName = ExportService.getFileName(
          tournament: tournament,
          format: ExportFormat.json,
        );

        expect(fileName, contains('Test Tournament'));
        expect(fileName, endsWith('.json'));
      });

      test('should sanitize tournament name in file name', () {
        final tournamentWithSpecialChars = Tournament(
          name: 'Test/Tournament*2025?',
          players: [],
          courts: [],
        );

        final fileName = ExportService.getFileName(
          tournament: tournamentWithSpecialChars,
          format: ExportFormat.csv,
        );

        // Special characters should be removed
        expect(fileName, isNot(contains('/')));
        expect(fileName, isNot(contains('*')));
        expect(fileName, isNot(contains('?')));
      });
    });

    group('MIME Types', () {
      test('should return correct MIME type for CSV', () {
        final mimeType = ExportService.getMimeType(ExportFormat.csv);
        expect(mimeType, equals('text/csv'));
      });

      test('should return correct MIME type for JSON', () {
        final mimeType = ExportService.getMimeType(ExportFormat.json);
        expect(mimeType, equals('application/json'));
      });
    });

    group('Available Formats', () {
      test('should return available export formats', () {
        final formats = ExportService.getAvailableFormats();
        
        expect(formats, isNotEmpty);
        expect(formats, contains(ExportFormat.csv));
        expect(formats, contains(ExportFormat.json));
      });

      test('should not include unimplemented formats', () {
        final formats = ExportService.getAvailableFormats();
        
        // PDF and Excel are not yet implemented
        expect(formats, isNot(contains(ExportFormat.pdf)));
        expect(formats, isNot(contains(ExportFormat.excel)));
      });
    });

    group('Unimplemented Formats', () {
      test('should throw UnimplementedError for PDF export', () {
        expect(
          () => ExportService.exportStandings(
            standings: standings,
            tournament: tournament,
            format: ExportFormat.pdf,
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should throw UnimplementedError for Excel export', () {
        expect(
          () => ExportService.exportStandings(
            standings: standings,
            tournament: tournament,
            format: ExportFormat.excel,
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}

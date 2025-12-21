import 'dart:convert';
import 'package:csv/csv.dart';
import '../models/player_standing.dart';
import '../models/tournament.dart';
import '../utils/constants.dart';

/// Supported export formats
enum ExportFormat {
  csv('CSV', 'Comma-Separated Values'),
  json('JSON', 'JavaScript Object Notation'),
  pdf('PDF', 'Portable Document Format'),
  excel('Excel', 'Microsoft Excel Spreadsheet');

  const ExportFormat(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Abstract base class for export strategies
/// This allows for easy addition of new export formats in the future
abstract class ExportStrategy {
  String get fileExtension;
  String get mimeType;
  
  /// Export tournament standings to the specific format
  String exportStandings(List<PlayerStanding> standings, Tournament tournament);
}

/// CSV export strategy implementation
class CsvExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'csv';
  
  @override
  String get mimeType => 'text/csv';
  
  @override
  String exportStandings(List<PlayerStanding> standings, Tournament tournament) {
    // Create CSV data
    List<List<dynamic>> rows = [];
    
    // Add header row
    rows.add([
      'Rank',
      'Player Name',
      'Total Points',
      'Wins',
      'Losses',
      'Matches Played',
      'Win Rate (%)',
      'Biggest Win Margin',
      'Smallest Loss Margin',
      'Pause Count',
    ]);
    
    // Add data rows
    for (final standing in standings) {
      final winRate = standing.matchesPlayed > 0
          ? (standing.wins / standing.matchesPlayed * 100).toStringAsFixed(1)
          : '0.0';
      
      rows.add([
        standing.rank,
        standing.player.name,
        standing.totalPoints,
        standing.wins,
        standing.losses,
        standing.matchesPlayed,
        winRate,
        standing.biggestWinMargin,
        standing.smallestLossMargin == Constants.noLossesSentinel 
            ? '-' 
            : standing.smallestLossMargin,
        standing.pauseCount,
      ]);
    }
    
    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
  }
}

/// JSON export strategy implementation (placeholder for future)
class JsonExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'json';
  
  @override
  String get mimeType => 'application/json';
  
  @override
  String exportStandings(List<PlayerStanding> standings, Tournament tournament) {
    final data = {
      'tournament': {
        'name': tournament.name,
        'id': tournament.id,
        'createdAt': tournament.createdAt.toIso8601String(),
        'totalRounds': tournament.rounds.length,
        'totalPlayers': tournament.players.length,
      },
      'standings': standings.map((s) => {
        'rank': s.rank,
        'playerName': s.player.name,
        'playerId': s.player.id,
        'totalPoints': s.totalPoints,
        'wins': s.wins,
        'losses': s.losses,
        'matchesPlayed': s.matchesPlayed,
        'winRate': s.matchesPlayed > 0 ? s.wins / s.matchesPlayed : 0,
        'biggestWinMargin': s.biggestWinMargin,
        'smallestLossMargin': s.smallestLossMargin == Constants.noLossesSentinel 
            ? null 
            : s.smallestLossMargin,
        'pauseCount': s.pauseCount,
      }).toList(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

/// Main export service that coordinates export operations
class ExportService {
  // Factory pattern for creating export strategies
  static ExportStrategy _getStrategy(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return CsvExportStrategy();
      case ExportFormat.json:
        return JsonExportStrategy();
      case ExportFormat.pdf:
        throw UnimplementedError('PDF export not yet implemented');
      case ExportFormat.excel:
        throw UnimplementedError('Excel export not yet implemented');
    }
  }
  
  /// Export standings in the specified format
  /// Returns the exported data as a string
  static String exportStandings({
    required List<PlayerStanding> standings,
    required Tournament tournament,
    required ExportFormat format,
  }) {
    final strategy = _getStrategy(format);
    return strategy.exportStandings(standings, tournament);
  }
  
  /// Get the file name for the export
  static String getFileName({
    required Tournament tournament,
    required ExportFormat format,
  }) {
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final strategy = _getStrategy(format);
    
    // Sanitize the tournament name for use in filename
    // Keep only alphanumeric characters, spaces, hyphens, and underscores
    var sanitizedName = tournament.name.replaceAll(RegExp(r'[^\w\s-]'), '');
    
    // Replace spaces with underscores and remove multiple consecutive underscores
    sanitizedName = sanitizedName.replaceAll(RegExp(r'\s+'), '_');
    sanitizedName = sanitizedName.replaceAll(RegExp(r'_+'), '_');
    
    // Trim underscores and hyphens from start/end
    sanitizedName = sanitizedName.replaceAll(RegExp(r'^[-_]+|[-_]+$'), '');
    
    // If sanitization resulted in empty string, use a default name
    if (sanitizedName.isEmpty) {
      sanitizedName = 'tournament';
    }
    
    return '${sanitizedName}_$timestamp.${strategy.fileExtension}';
  }
  
  /// Get MIME type for the export format
  static String getMimeType(ExportFormat format) {
    final strategy = _getStrategy(format);
    return strategy.mimeType;
  }
  
  /// Get list of available export formats
  static List<ExportFormat> getAvailableFormats() {
    return [
      ExportFormat.csv,
      ExportFormat.json,
      // PDF and Excel are planned for future implementation
      // ExportFormat.pdf,
      // ExportFormat.excel,
    ];
  }
}

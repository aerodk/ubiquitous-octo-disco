# Export Functionality Documentation

## Overview
The application now includes an extensible export system that allows users to save tournament results in various formats.

## Currently Available Export Formats

### 1. CSV (Comma-Separated Values)
- **Format**: Plain text file with comma-separated values
- **File Extension**: `.csv`
- **Use Case**: Import into Excel, Google Sheets, or other spreadsheet applications
- **Data Included**:
  - Rank
  - Player Name
  - Total Points
  - Wins
  - Losses
  - Matches Played
  - Win Rate (%)
  - Biggest Win Margin
  - Smallest Loss Margin
  - Pause Count

### 2. JSON (JavaScript Object Notation)
- **Format**: Structured JSON data
- **File Extension**: `.json`
- **Use Case**: Data analysis, integration with other systems, or archiving
- **Data Included**:
  - Tournament metadata (name, ID, creation date, total rounds, total players)
  - Complete player standings with all statistics
  - Calculated win rates

## Planned Future Export Formats

### 3. PDF (Portable Document Format)
- **Status**: Planned
- **Description**: Professionally formatted report with graphs and statistics
- **Use Case**: Sharing results, printing, archiving

### 4. Excel (Microsoft Excel Spreadsheet)
- **Status**: Planned
- **Description**: Spreadsheet with formulas and charts
- **Use Case**: Advanced data analysis, custom reporting

### 5. Image Export
- **Status**: Planned
- **Description**: PNG/JPEG image of the leaderboard
- **Use Case**: Sharing on social media

### 6. Direct Sharing
- **Status**: Planned
- **Description**: Share results via email, SMS, or social media
- **Use Case**: Quick sharing with participants

## How to Use

### From Tournament Completion Screen
1. Navigate to the Tournament Completion Screen (after tournament ends)
2. Click the download icon (📥) in the top-right corner of the AppBar
3. Select your preferred export format from the dialog
4. Click "Eksporter" to download the file
5. The file will be saved to your downloads folder

### From Leaderboard Screen
1. Navigate to the Leaderboard Screen during the tournament
2. Click the download icon (📥) in the top-right corner of the AppBar
3. Select your preferred export format from the dialog
4. Click "Eksporter" to download the file
5. The file will be saved to your downloads folder

### Viewing Future Export Options
From the Tournament Completion Screen, click the info icon (ℹ️) to see details about planned export formats.

## Technical Implementation

### Architecture
The export system uses the **Strategy Pattern** for extensibility:

```dart
// Abstract base class
abstract class ExportStrategy {
  String get fileExtension;
  String get mimeType;
  String exportStandings(List<PlayerStanding> standings, Tournament tournament);
}

// Concrete implementations
class CsvExportStrategy implements ExportStrategy { ... }
class JsonExportStrategy implements ExportStrategy { ... }
```

### Adding New Export Formats
To add a new export format:

1. Create a new enum value in `ExportFormat`:
```dart
enum ExportFormat {
  csv('CSV', 'Comma-Separated Values'),
  json('JSON', 'JavaScript Object Notation'),
  pdf('PDF', 'Portable Document Format'),  // Add new format
}
```

2. Implement the `ExportStrategy` interface:
```dart
class PdfExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'pdf';
  
  @override
  String get mimeType => 'application/pdf';
  
  @override
  String exportStandings(List<PlayerStanding> standings, Tournament tournament) {
    // Implementation
  }
}
```

3. Update the factory method in `ExportService`:
```dart
static ExportStrategy _getStrategy(ExportFormat format) {
  switch (format) {
    case ExportFormat.csv:
      return CsvExportStrategy();
    case ExportFormat.json:
      return JsonExportStrategy();
    case ExportFormat.pdf:
      return PdfExportStrategy();  // Add new case
  }
}
```

4. Add the format to available formats:
```dart
static List<ExportFormat> getAvailableFormats() {
  return [
    ExportFormat.csv,
    ExportFormat.json,
    ExportFormat.pdf,  // Add to available list
  ];
}
```

## File Naming Convention
Files are named using the pattern:
```
{tournament_name}_{date}.{extension}
```

Example: `Test_Tournament_2025-12-21.csv`

Special characters in the tournament name are sanitized (removed).

## Dependencies
- `csv: ^6.0.0` - CSV file generation

## Testing
Comprehensive unit tests are available in `test/services/export_service_test.dart` covering:
- CSV export with correct headers and data
- JSON export with tournament metadata
- File naming and sanitization
- MIME type handling
- Available formats listing
- Empty standings handling
- Win rate calculations
- Special value handling (e.g., "no losses" scenario)

## Browser Compatibility
The export functionality is currently optimized for web platforms and uses the HTML5 download API:
- Creates a Blob from the exported data
- Triggers download using an anchor element
- Supports all modern browsers (Chrome, Firefox, Safari, Edge)

### Platform Support
- **Web**: ✅ Full support with automatic file downloads
- **Mobile (Android/iOS)**: ⚠️ Limited support - Shows a message that export is only available on web
  - Future enhancement: Will use platform-specific file saving (share API, file picker)

### Conditional Import Strategy
The code uses Dart's conditional imports to handle platform differences:
```dart
import '../utils/html_stub.dart'
    if (dart.library.html) 'dart:html' as html;
```
This ensures the code compiles on all platforms without errors.

## Future Enhancements
- Server-side export generation for large datasets
- Custom export templates
- Scheduled automatic exports
- Cloud storage integration (Google Drive, Dropbox)
- Email delivery option
- Multi-language support for export formats

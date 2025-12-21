# Export Feature - Quick Reference

## ✅ Currently Available

### CSV Export
- **File Format**: `.csv` (Comma-Separated Values)
- **Best For**: Opening in Excel, Google Sheets, or other spreadsheet applications
- **Data Included**:
  - Rank
  - Player Name
  - Total Points
  - Wins/Losses
  - Matches Played
  - Win Rate (%)
  - Biggest Win Margin
  - Smallest Loss Margin
  - Pause Count

**Example CSV Output**:
```csv
Rank,Player Name,Total Points,Wins,Losses,Matches Played,Win Rate (%),Biggest Win Margin,Smallest Loss Margin,Pause Count
1,Alice,48,2,0,2,100.0,10,-,0
2,Bob,40,1,1,2,50.0,5,5,1
3,Charlie,36,0,2,2,0.0,0,10,0
```

### JSON Export
- **File Format**: `.json` (JavaScript Object Notation)
- **Best For**: Data archiving, integration with other systems, developers
- **Data Included**:
  - Tournament metadata (name, ID, dates, totals)
  - Complete player standings
  - Calculated statistics

**Example JSON Output**:
```json
{
  "tournament": {
    "name": "Summer Tournament",
    "id": "abc123",
    "createdAt": "2025-12-21T10:00:00.000Z",
    "totalRounds": 5,
    "totalPlayers": 12
  },
  "standings": [
    {
      "rank": 1,
      "playerName": "Alice",
      "totalPoints": 48,
      "wins": 2,
      "losses": 0,
      "winRate": 1.0
    }
  ]
}
```

## 📍 Where to Find Export Buttons

### Tournament Completion Screen
- Located in the **top-right corner** of the AppBar
- **Download icon** (📥) - Opens export dialog
- **Info icon** (ℹ️) - Shows future export options

### Leaderboard Screen
- Located in the **top-right corner** of the AppBar
- **Download icon** (📥) - Opens export dialog
- Only appears when at least one match has been played

## 🎯 How to Export

1. Click the **download icon** (📥) in the AppBar
2. Select your preferred format (CSV or JSON)
3. Click **"Eksporter"**
4. File will download to your browser's downloads folder

## 🔮 Planned Export Formats

### PDF Export
- **Status**: Planned for future release
- **Description**: Professionally formatted tournament report
- **Features**:
  - Formatted tables and charts
  - Tournament statistics graphs
  - Player performance visualizations
  - Print-ready layout

### Excel Export
- **Status**: Planned for future release
- **Description**: Microsoft Excel spreadsheet with advanced features
- **Features**:
  - Pre-built formulas
  - Charts and graphs
  - Pivot tables
  - Conditional formatting

### Image Export
- **Status**: Planned for future release
- **Description**: PNG/JPEG image of the leaderboard
- **Use Cases**:
  - Share on social media
  - Include in presentations
  - Print as poster

### Direct Sharing
- **Status**: Planned for future release
- **Description**: Share results directly from the app
- **Channels**:
  - Email
  - SMS
  - WhatsApp
  - Social media platforms

## 💻 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Web (Chrome, Firefox, Safari, Edge) | ✅ Full support | Automatic file download |
| Android | ⚠️ Planned | Will use Android share API |
| iOS | ⚠️ Planned | Will use iOS share sheet |

## 🛠️ Technical Details

### Export Service Architecture
- **Pattern**: Strategy Pattern for extensibility
- **Current Strategies**: CSV, JSON
- **Easy to Extend**: Add new formats by implementing `ExportStrategy` interface

### File Naming
Files are automatically named with:
```
{tournament_name}_{date}.{extension}
```
Example: `Summer_Tournament_2025-12-21.csv`

Special characters in tournament names are automatically removed for file system compatibility.

## ❓ FAQ

**Q: Can I export during the tournament?**
A: Yes! Use the Leaderboard Screen to export current standings at any time.

**Q: What if I'm on mobile?**
A: Mobile export will show a message that it's currently web-only. Mobile support is planned.

**Q: Can I customize what data is exported?**
A: Currently, all available statistics are exported. Custom export templates are planned for future releases.

**Q: How do I open the CSV file?**
A: CSV files can be opened with:
- Microsoft Excel
- Google Sheets
- Apple Numbers
- LibreOffice Calc
- Any text editor

**Q: Is my data secure?**
A: Yes! Export happens entirely in your browser. No data is sent to any server.

## 📚 More Information

For detailed technical documentation, see [EXPORT_FUNCTIONALITY.md](EXPORT_FUNCTIONALITY.md)

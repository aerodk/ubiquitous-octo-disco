# Padel Tournament App - Americano/Mexicano Format

🌐 **Live Demo:** [https://aerodk.github.io/ubiquitous-octo-disco/](https://aerodk.github.io/ubiquitous-octo-disco/)

A Flutter mobile application that helps organize and run Padel tournaments in Americano/Mexicano format.

## Version 1.0 - MVP Implementation

This implementation includes the core features needed to set up and start a Padel tournament.

### Features Implemented

#### 1. Player Registration (F-001)
- Add players with validation for empty names and duplicates
- Minimum 4 players, maximum 24 players
- Display player list with numbering
- Remove players functionality
- Real-time player count display

#### 2. Court Registration (F-002)
- Adjustable court count with increment/decrement buttons
- Minimum 1 court, maximum 8 courts
- Automatic naming (Bane 1, Bane 2, etc.)

#### 3. First Round Generation (F-003)
- Random player distribution into pairs
- Automatic court assignment
- Handles pause players when not enough players for all courts
- Fair distribution of players across available courts

#### 4. Round Display (F-004)
- Visual display of all matches with court assignments
- Clear team composition showing both players per team
- Display of players on break (if any)
- Professional card-based UI

### Project Structure

```
lib/
├── main.dart                       # App entry point with theme configuration
├── models/                         # Data models
│   ├── player.dart                 # Player model with JSON serialization
│   ├── court.dart                  # Court model
│   ├── match.dart                  # Match and Team models with score tracking
│   ├── round.dart                  # Round model with matches and break players
│   └── tournament.dart             # Tournament model for complete tournament state
├── services/                       # Business logic
│   └── tournament_service.dart     # Round generation and player distribution
├── screens/                        # UI screens
│   ├── setup_screen.dart          # Player and court registration
│   └── round_display_screen.dart  # Round display with matches
└── widgets/                        # Reusable widgets
    └── match_card.dart            # Card widget for displaying match details
```

### Testing

Comprehensive test coverage includes:
- Unit tests for all data models
- JSON serialization/deserialization tests
- Tournament service logic tests
- Widget tests for setup screen
- Validation tests for player and court registration

Run tests with:
```bash
flutter test
```

### Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### How to Use

1. **Setup Screen**
   - Enter player names (minimum 4 required)
   - Adjust the number of courts using +/- buttons
   - Click "Generer Første Runde" to start

2. **Round Display**
   - View all matches with court assignments
   - See which players are paired together
   - Check which players are on break (if any)

### Technical Details

- **Framework:** Flutter 3.0+
- **Language:** Dart
- **Platforms:** iOS and Android
- **State Management:** StatefulWidget (simple state management for MVP)
- **Data Persistence:** In-memory (no persistence in Version 1.0)

### Validation Rules

#### Players
- Name cannot be empty
- No duplicate names (case-insensitive)
- Minimum 4 players required to generate round
- Maximum 24 players allowed

#### Courts
- Minimum 1 court
- Maximum 8 courts
- Automatically named sequentially

### Future Enhancements (Version 2.0)

See `docs/SPECIFICATION.md` for Version 2.0 features including:
- Score input system (0-24 points)
- Americano algorithm for subsequent rounds
- Leaderboard and statistics
- Tournament persistence
- Multiple simultaneous tournaments

## Specification

For complete feature specifications and future roadmap, see [docs/SPECIFICATION.md](docs/SPECIFICATION.md).

## For Developers

### GitHub Copilot

This repository is optimized for use with GitHub Copilot and coding agents. See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for:
- Project architecture and conventions
- How to build, test, and run the project
- Code patterns and best practices
- Examples of effective prompts

### Getting Started

For detailed development setup and Copilot usage patterns, see [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md).

## License

This project is currently private.

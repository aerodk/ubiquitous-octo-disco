# Padel Tournament App - Americano/Mexicano Format

A Flutter mobile application that helps organize and run Padel tournaments in Americano/Mexicano format.

## Current Version: 2.0 - Score Input & Americano Algorithm

This implementation includes all MVP features plus score input and intelligent round generation using the Americano algorithm.

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
- Tap matches to input scores
- Display completed matches with scores
- Visual indicators for completed/incomplete matches

#### 5. Score Input (F-005) - Version 2.0
- Interactive score input screen with 0-24 point buttons
- Automatic score calculation (total always equals 24)
- Color-coded teams (blue vs red)
- Clear display of team names and selected scores
- Save score and return to round display
- Visual feedback for score selection

#### 6. Americano Algorithm (F-006) - Version 2.0
- Generate subsequent rounds based on player performance
- Smart player pairing to avoid repeating partnerships
- Match players with similar point totals
- Rotate opponents for variety
- Balance break rounds across players
- Track player statistics (points, games played, partners, opponents)
- Optimize matchups based on tournament history

### Project Structure

```
lib/
├── main.dart                       # App entry point with theme configuration
├── models/                         # Data models
│   ├── player.dart                 # Player model with JSON serialization
│   ├── player_stats.dart           # Player statistics for Americano algorithm
│   ├── court.dart                  # Court model
│   ├── match.dart                  # Match and Team models with score tracking
│   ├── round.dart                  # Round model with matches and break players
│   └── tournament.dart             # Tournament model for complete tournament state
├── services/                       # Business logic
│   ├── tournament_service.dart     # Round generation and player distribution
│   └── americano_algorithm.dart    # Americano algorithm implementation
├── screens/                        # UI screens
│   ├── setup_screen.dart          # Player and court registration
│   ├── round_display_screen.dart  # Round display with matches and score tracking
│   └── score_input_screen.dart    # Score input interface with button grid
└── widgets/                        # Reusable widgets
    ├── match_card.dart            # Card widget for displaying match details
    └── score_button_grid.dart     # Grid of score buttons (0-24)
```

### Testing

Comprehensive test coverage includes:
- Unit tests for all data models
- JSON serialization/deserialization tests
- Tournament service logic tests
- Americano algorithm tests
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

3. **Score Input** (Version 2.0)
   - Tap on any match card to input scores
   - Select score for one team (0-24)
   - Other team's score auto-calculates (always totals 24)
   - Tap "Gem Score" to save

4. **Next Round Generation** (Version 2.0)
   - Complete all match scores in current round
   - Click "Generer Næste Runde" button
   - Algorithm creates optimal pairings based on:
     - Player point totals
     - Previous partnerships
     - Previous opponents
     - Break round history

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

#### Scores (Version 2.0)
- Each match must have scores for both teams
- Score range: 0-24 points per team
- Total score always equals 24
- All matches must be completed before generating next round

### Americano Algorithm Details (Version 2.0)

The algorithm prioritizes match quality through several factors:

1. **Point Balance** (Highest Priority)
   - Players with similar point totals are matched together
   - Creates competitive and fair matches

2. **Partner Rotation**
   - Avoids pairing the same players repeatedly
   - Tracks partnership history across rounds

3. **Opponent Variation**
   - Players face different opponents each round
   - Minimizes repeated matchups

4. **Break Balance**
   - Distributes break rounds fairly among all players
   - Tracks which players have had breaks

### Future Enhancements (Version 3.0+)

See `docs/SPECIFICATION.md` for future features including:
- Tournament persistence and resume functionality
- Leaderboard with detailed statistics
- Multiple simultaneous tournaments
- Export results to PDF
- Dark mode
- Push notifications for match starts

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

# Padel Tournament App - Americano/Mexicano/Social-Mexicano Format

🌐 **Live Demo:** [https://aerodk.github.io/ubiquitous-octo-disco/](https://aerodk.github.io/ubiquitous-octo-disco/)

> **Note:** If the live demo shows this README instead of the app, see [GitHub Pages Setup Guide](GITHUB_PAGES_SETUP.md) for configuration instructions.

A Flutter mobile application that helps organize and run Padel tournaments in Americano, Mexicano, and Social-Mexicano formats.

## Latest Features - Version 8.0: Firebase Cloud Storage ☁️

**Save and access your tournaments from anywhere!**

- **Cloud Storage**: Save tournaments to Firebase Firestore
- **8-Digit Tournament Codes**: Unique identifier for each tournament
- **6-Digit Passcode Protection**: Secure access with SHA-256 hashed passcodes
- **Cross-Device Access**: Load tournaments on any device with your codes
- **No Login Required**: Anonymous access - no user accounts needed
- **Update Tournaments**: Save changes to existing tournaments
- **Offline Support**: Graceful handling when Firebase is unavailable

### How to Use Cloud Storage

1. **Save**: Click the cloud upload icon (☁️) in the app
2. **Get Codes**: Note your 8-digit tournament code and 6-digit passcode
3. **Load**: Click cloud download (☁️⬇️) and enter your codes on any device
4. **Update**: Make changes and save again with the same codes

See [Firebase Setup Guide](docs/FIREBASE_SETUP.md) for deployment configuration.

## Tournament Formats

The app supports three tournament formats for different play styles:

### 🏆 Mexicano (Recommended - Competitive)
**Point-based competitive pairing** - Creates balanced, competitive matches by prioritizing players with similar skill levels (point totals). Players with large point differences won't be paired together, ensuring fair and engaging games throughout the tournament.

**Best for:** Competitive tournaments where match balance is important.

### 👥 Social-Mexicano (Social Variety)
**Meeting-based variety pairing** - Maximizes social interaction by ensuring all players get to play with and against different people. Prioritizes avoiding partner/opponent repetition, though matches may be unbalanced if top and bottom players meet.

**Best for:** Social events where meeting variety matters more than competitive balance.

### 🎲 Americano (Random)
**Random pairing** - Simple, unpredictable matchups using random shuffling. Quick and easy, but may repeat partners and opponents.

**Best for:** Casual play and equal opportunity for all.

See [Algorithm Comparison](docs/MEXICANO_ALGORITHM_COMPARISON.md) for detailed technical documentation.

## Version 1.0 - MVP Implementation

This implementation includes the core features needed to set up and start a Padel tournament.

### Features Implemented

#### 1. Player Registration (F-001)
- Add players with validation for empty names and duplicates
- Minimum 4 players, maximum 72 players
- Display player list with numbering
- Remove players functionality
- Real-time player count display

#### 2. Court Registration (F-002)
- Adjustable court count with increment/decrement buttons
- Minimum 1 court, maximum 18 courts
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

#### 5. Export Functionality (NEW)
- **CSV Export**: Export tournament results to CSV format for spreadsheet applications
- **JSON Export**: Export structured data for integration and archiving
- **Extensible Design**: Easy to add new export formats (PDF, Excel planned)
- **Platform Support**: Full support on web, with mobile support planned
- **Available on**:
  - Tournament Completion Screen (final results)
  - Leaderboard Screen (live standings)
- See [Export Documentation](docs/EXPORT_FUNCTIONALITY.md) for details

### Project Structure

```
lib/
├── main.dart                       # App entry point with theme configuration
├── models/                         # Data models
│   ├── player.dart                 # Player model with JSON serialization
│   ├── court.dart                  # Court model
│   ├── match.dart                  # Match and Team models with score tracking
│   ├── round.dart                  # Round model with matches and break players
│   ├── tournament.dart             # Tournament model for complete tournament state
│   └── player_standing.dart        # Player standings with statistics
├── services/                       # Business logic
│   ├── tournament_service.dart     # Round generation and player distribution
│   ├── standings_service.dart      # Leaderboard and ranking calculations
│   ├── persistence_service.dart    # Tournament data persistence
│   └── export_service.dart         # Export functionality (CSV, JSON, etc.)
├── screens/                        # UI screens
│   ├── setup_screen.dart          # Player and court registration
│   ├── round_display_screen.dart  # Round display with matches
│   ├── leaderboard_screen.dart    # Live tournament standings
│   └── tournament_completion_screen.dart  # Final results and statistics
├── widgets/                        # Reusable widgets
│   ├── match_card.dart            # Card widget for displaying match details
│   └── export_dialog.dart         # Export options dialog
└── utils/                          # Utilities
    ├── constants.dart              # App-wide constants
    └── html_stub.dart              # Platform compatibility stub
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

## Tournament Formats: Americano vs Mexicano

The app supports two tournament formats that differ in how players are paired for matches:

### Americano (Random Pairing)

**Current default format** - Uses random shuffling for simple, unpredictable matchups.

**How it works:**
- **First Round:** Players are randomly shuffled and grouped into matches of 4
- **Regular Rounds:** Players are randomly shuffled again (after selecting who sits out)
- **Final Round:** Uses rank-based pairing strategies

**Characteristics:**
- ✅ Simple and fast
- ✅ Unpredictable and varied
- ✅ Easy to understand
- ✅ Fair break distribution
- ❌ Can repeat partners and opponents
- ❌ No skill balancing

### Mexicano (Strategic Pairing)

**Planned implementation** - Uses sophisticated partner/opponent selection with history tracking.

**How it works:**
- **First Round:** Random shuffling (same as Americano)
- **Regular Rounds:** Strategic pairing based on:
  - Player rankings (sorted by total points)
  - Partner history (rotates to avoid repetition)
  - Opponent history (ensures variety)
  - Skill balancing (similar-ranked players paired together)
- **Final Round:** Rank-based pairing (same as Americano)

**Characteristics:**
- ✅ Partner rotation guaranteed
- ✅ Opponent variety enforced
- ✅ Skill-based balancing
- ✅ Competitive games
- ✅ Strategic depth
- ⚠️ More complex algorithm

For detailed algorithm explanations, see [docs/CURRENT_MATCHUP_ALGORITHM.md](docs/CURRENT_MATCHUP_ALGORITHM.md).

## Match-up Logic

### Break/Pause Fairness

When there are more players than available court slots, some players must sit out each round. The app ensures fairness using this priority system:

1. **Fewest pauses** (ascending) - Players with fewer breaks go first
2. **Most games played** (descending) - Among equal pauses, those who played more sit out
3. **Random selection** - Among players with equal priority

**Example:** With 14 players and 3 courts (12 slots), 2 players sit out each round. The algorithm ensures no player sits out consecutive rounds unless necessary.

### Lane/Court Assignment

Courts are assigned to matches using one of two strategies:

- **Sequential (default):** Best-ranked matches get first courts
- **Random:** Courts are shuffled for variety

### Final Round Pairing

After the minimum number of rounds (default: 3), you can start the final round with special pairing strategies:

1. **Balanced (default):** Rank 1+3 vs Rank 2+4
2. **Top Alliance:** Rank 1+2 vs Rank 3+4
3. **Max Competition:** Rank 1+4 vs Rank 2+3

These strategies create exciting finale matches based on tournament standings.

## Tie-Breaker System

The app uses a comprehensive 5-level hierarchical ranking system to determine player standings:

### 1. Total Points (Primary Criterion)
The sum of all points scored across all matches.

**Example:**
- Player A: Match 1 (15) + Match 2 (18) + Match 3 (12) = **45 points**
- Player B: Match 1 (20) + Match 2 (14) + Match 3 (11) = **45 points**

If tied → proceed to level 2

### 2. Number of Wins (1st Tie-breaker)
Count of matches won (team score higher than opponent).

**Example:**
- Player A: 2 wins, 1 loss
- Player B: 1 win, 2 losses

**Result:** Player A ranks higher

If tied → proceed to level 3

### 3. Head-to-Head Record (2nd Tie-breaker)
Direct results when players faced each other as opponents.

**How it works:**
- Find all matches where both players were opponents (not partners)
- Sum points scored in those matches
- Higher head-to-head points wins

**Special cases:**
- Players never met: Skip to next criterion
- Players were partners: Doesn't count for H2H
- Multiple meetings: Sum all H2H matches

If tied or not applicable → proceed to level 4

### 4. Biggest Win Margin (3rd Tie-breaker)
The largest margin of victory in any single match.

**Example:**
- Player A's wins: 18-12 (margin: 6), 20-15 (margin: 5) → **Biggest: 6**
- Player B's wins: 17-14 (margin: 3) → **Biggest: 3**

**Result:** Player A ranks higher

**Note:** Players with no wins have biggest win margin = 0

If tied → proceed to level 5

### 5. Smallest Loss Margin (4th Tie-breaker)
The smallest margin of defeat (closest loss = better performance).

**Example:**
- Player A's losses: 12-18 (margin: 6), 10-20 (margin: 10) → **Smallest: 6**
- Player B's losses: 14-17 (margin: 3), 11-19 (margin: 8) → **Smallest: 3**

**Result:** Player B ranks higher (3 < 6, closer match)

**Note:** Players with no losses have smallest loss margin = 0 (best possible)

If still tied → players share the same rank

### Validation Rules

#### Players
- Name cannot be empty
- No duplicate names (case-insensitive)
- Minimum 4 players required to generate round
- Maximum 72 players allowed

#### Courts
- Minimum 1 court
- Maximum 18 courts
- Automatically named sequentially

### Future Enhancements (Version 2.0)

See `docs/SPECIFICATION.md` for Version 2.0 features including:
- Score input system (0-24 points)
- Americano algorithm for subsequent rounds
- Leaderboard and statistics
- Tournament persistence
- Multiple simultaneous tournaments

## Deployment

This project supports two deployment environments:

- **Production**: Manual deployment from `main` branch to `https://aerodk.github.io/ubiquitous-octo-disco/`
- **Test/Staging**: Automatic deployment from `develop` branch (for testing before production)

**🚀 Quick Setup:** If GitHub Pages shows the README instead of the app, follow the [GitHub Pages Setup Guide](GITHUB_PAGES_SETUP.md).

**📖 Production Deployment:** See [deployment.MD](deployment.MD) for complete deployment instructions and troubleshooting.

**🧪 Test Deployment:** See [docs/TEST_DEPLOYMENT.md](docs/TEST_DEPLOYMENT.md) for test/develop deployment workflow.

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

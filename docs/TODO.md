# Development Roadmap

## Version 1.0 - MVP
- [ ] Setup project structure
- [ ] Create data models
  - [ ] Player model
  - [ ] Court model
  - [ ] Team model
  - [ ] Match model
  - [ ] Round model
- [ ] Implement services
  - [ ] TournamentService
- [ ] Create screens
  - [ ] SetupScreen (players + courts)
  - [ ] RoundDisplayScreen
- [ ] Create widgets
  - [ ] PlayerList
  - [ ] CourtList
  - [ ] MatchCard
- [ ] Testing & debugging

## Version 2.0 - Scoring & Algorithm
- [ ] Implement score input
  - [ ] ScoreInputScreen
  - [ ] ScoreButtonGrid widget
- [ ] Implement Americano algorithm
  - [ ] PlayerStats calculation
  - [ ] Optimal pairing logic
  - [ ] Match generation
- [ ] Add leaderboard view
- [ ] Testing & debugging

## Version 3.0 - Leaderboard & Ranking (SPECIFICATION_V3.md)
- [x] Create data models
  - [x] PlayerStanding model with all statistics
- [x] Implement services
  - [x] StandingsService with hierarchical ranking algorithm
    - [x] Total points calculation (primary ranking)
    - [x] Wins count (1st tiebreaker)
    - [x] Head-to-head records (2nd tiebreaker)
    - [x] Biggest win margin (3rd tiebreaker)
    - [x] Smallest loss margin (4th tiebreaker)
    - [x] Shared ranking support
- [x] Create screens
  - [x] LeaderboardScreen with live standings (F-007)
    - [x] Top 3 visual highlighting with medals
    - [x] Detailed player statistics display
    - [x] Responsive mobile design
- [x] Integration
  - [x] Add navigation from RoundDisplayScreen
  - [x] Real-time standings calculation
- [x] Testing & debugging
  - [x] Unit tests for PlayerStanding model
  - [x] Comprehensive unit tests for StandingsService (all test cases from spec)
  - [x] Widget tests for LeaderboardScreen

## Version 4.0 - Final Round System (SPECIFICATION_V4.md)
- [x] Data Model Updates (F-010, F-011, F-012, F-013)
  - [x] Add `isFinalRound` flag to Round model
  - [x] Add `isCompleted` flag to Tournament model
  - [x] Add `pauseCount` to PlayerStanding for break tracking
  - [x] Update JSON serialization for persistence
- [x] Final Round Pairing Algorithm (F-011)
  - [x] Implement `generateFinalRound()` in TournamentService
  - [x] Rank-based pairing (R1+R3 vs R2+R4 pattern)
  - [x] Rolling pause system for overflow players
  - [x] Hierarchical break selection (most games → lowest rank → fewest pauses)
  - [x] Top half protection from sitting out
  - [x] Court prioritization (best courts for top matches)
- [x] Final Round Detection & UI (F-010)
  - [x] "Start Sidste Runde" button (gold theme, larger)
  - [x] Show only after 3+ completed rounds
  - [x] Confirmation dialog with leaderboard preview
  - [x] Final round visual identification (trophy icon, gold AppBar)
  - [x] Validation to prevent premature activation
- [x] Tournament Completion (F-013)
  - [x] TournamentCompletionScreen with podium display
  - [x] Tournament statistics (matches, duration, top scorer, most wins, biggest win)
  - [x] Final leaderboard display
  - [x] Confetti animation
  - [x] Auto-navigation when final round completes
  - [x] Mark tournament as completed
  - [x] "Start Ny Turnering" option
- [x] Testing
  - [x] Unit tests for generateFinalRound (all spec scenarios)
  - [x] Tests for perfect divisibility (12 players)
  - [x] Tests for 1 overflow (13 players)
  - [x] Tests for 2 overflow (14 players)
  - [x] Tests for pause prioritization
  - [x] Tests for top half protection


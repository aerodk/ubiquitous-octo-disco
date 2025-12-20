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

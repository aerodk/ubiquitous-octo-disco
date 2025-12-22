# Copilot Instructions — Padel Tournament (star_cano)

Purpose: Help AI coding agents be immediately productive in this Flutter codebase.

**For best practices on using these instructions, see:** [GitHub Copilot Coding Agent Best Practices](https://gh.io/copilot-coding-agent-tips)

## Overview
- Flutter mobile app to run Americano/Mexicano Padel tournaments.
- Main layers: `lib/models/` (domain), `lib/services/` (business logic), `lib/screens/` (UI), `lib/widgets/` (reusable components), `lib/utils/` (constants/helpers).
- Entry point: `lib/main.dart` — use this to wire temporary screens while developing features.
- Source-of-truth spec: `docs/SPECIFICATION.md` — follow IDs like `F-001` when implementing features.

## Implemented Features (Versions 1.0-5.0)
- **Player & Court Registration (F-001, F-002)**: Add/remove players, configure courts, validation rules.
- **Round Generation (F-003, F-004)**: Automatic first round with random pairing, display matches.
- **Score Input (F-005)**: Configurable score grid (18-32 points), score tracking per match.
- **Leaderboard (F-007)**: Hierarchical ranking with detailed statistics (points, wins, head-to-head).
- **Final Round System (F-010-F-013)**: Rank-based pairing, tournament completion screen, podium display.
- **Tournament Settings (F-014-F-017)**: Configurable minimum rounds, points per match, pairing strategies.
- **Export Functionality**: CSV and JSON export for tournament results and standings.
- **Persistence**: Save/load tournament state using SharedPreferences.

## Where to start (priority)
- Review implemented code: Version 1.0-5.0 features are substantially complete.
- Check `docs/TODO.md` for current status and next tasks.
- Core models exist: `lib/models/player.dart`, `lib/models/court.dart`, `lib/models/match.dart`, `lib/models/round.dart`, `lib/models/tournament.dart`, `lib/models/player_standing.dart`, `lib/models/tournament_settings.dart`.
- Services implemented: `lib/services/tournament_service.dart` (round generation, final round logic), `lib/services/standings_service.dart` (leaderboard), `lib/services/persistence_service.dart` (data storage), `lib/services/export_service.dart` (CSV/JSON export).
- Primary screens exist: `lib/screens/setup_screen.dart`, `lib/screens/round_display_screen.dart`, `lib/screens/leaderboard_screen.dart`, `lib/screens/tournament_completion_screen.dart`.
- For detailed feature specifications, see `docs/SPECIFICATION.md` through `docs/SPECIFICATION_V5.md`.

## Key conventions & patterns (repo-specific)
- Use JSON serialization helpers (`fromJson`/`toJson`) on model classes for persistence and testing.
- Tournament generation follows the example in `docs/SPECIFICATION.md` (shuffle players, group into matches of 4, leftover players are `playersOnBreak`). Search for `generateFirstRound` in docs for the canonical algorithm snippet.
- Final round pairing uses rank-based strategies (balanced, top alliance, max competition) configurable in TournamentSettings.
- Scoring UI: `ScoreButtonGrid` concept (buttons 0–24 or configurable max) — prefer a `Wrap` of fixed-size `ElevatedButton`s that return an `int` score.
- State management: project uses `provider` (see `pubspec.yaml`). Prefer simple `ChangeNotifier` services for now; Riverpod may be used but is not required by existing code.
- Persistence: `shared_preferences` is used for tournament data storage. Use `PersistenceService` for all save/load operations.
- Export functionality: Use `ExportService` for CSV and JSON exports. Platform-specific handling implemented.
- Lints & analysis: `flutter_lints` is configured. Run `flutter analyze` and fix reported issues before committing.
- Dependencies: `provider` (state management), `shared_preferences` (storage), `uuid` (ID generation), `csv` (export functionality). Don't add new dependencies without justification.

## Build & developer workflows
- Install deps:
```bash
flutter pub get
```
- Static analysis (ALWAYS run before committing):
```bash
flutter analyze
```
- Run tests (verify before committing):
```bash
flutter test
```
- Run specific test file:
```bash
flutter test test/models/player_test.dart
```
- Run in Chrome (fast dev loop):
```bash
flutter run -d chrome
```
- List devices:
```bash
flutter devices
```
- Hot reload: press `r` in the running terminal; hot restart: `R`.

## Deployment
- Web deployment to GitHub Pages is configured for both production and test environments.
- Production deployment: Manual from `main` branch to `https://aerodk.github.io/ubiquitous-octo-disco/`
- Test deployment: Automatic from `develop` branch for testing.
- See `deployment.MD` and `docs/TEST_DEPLOYMENT.md` for complete deployment workflows.

## How to ask Copilot / Chat (examples proven in this repo)
- Always reference the spec for features:
```text
@workspace Based on docs/SPECIFICATION.md, create lib/models/player.dart with id,name and JSON serialization.
```
- Reference spec IDs for implementing features:
```text
@workspace Implement generateFirstRound in lib/services/tournament_service.dart per docs/SPECIFICATION.md F-003.
```
- For UI work, reference both spec and Flutter conventions:
```text
@workspace Create lib/screens/setup_screen.dart implementing player and court registration (F-001, F-002).
```
- When asking for tests:
```text
@workspace Create unit tests for TournamentService in test/services/tournament_service_test.dart covering all edge cases.
```
- When debugging:
```text
@workspace The player registration validation isn't working as specified in F-001. Review the code and fix it.
```

## Quick PR / commit guidance
- Break work into small commits (one feature/acceptance ID per commit). Use spec IDs in commit messages, e.g. `Implement player registration (F-001)`.
- Update `docs/TODO.md` when adding major features.
- Run the complete verification workflow before committing:
  1. `flutter analyze` - must pass with no issues
  2. `flutter test` - all tests must pass
  3. Manual testing of changed functionality
  4. Review changed files to ensure only intended changes are included

## Files to inspect for context
- `docs/SPECIFICATION.md` through `docs/SPECIFICATION_V5.md` — canonical requirements and code snippets for all versions.
- `docs/TODO.md` — current development status and task tracking.
- `docs/GETTING_STARTED.md` — Copilot usage patterns and local dev steps.
- `lib/main.dart` — app entry point and navigation setup.
- `README.md` — project overview, features, and deployment information.
- `pubspec.yaml` — dependencies and project configuration.

## Notes for agents
- Only implement behavior that is discoverable from the repo (spec, code, or docs). If a decision is ambiguous, propose an option and add a one-line TODO referencing the spec ID.
- Prefer minimal, well-tested changes. Add or update unit tests under `test/` for business logic in `lib/services/`.
- ALWAYS run `flutter analyze` before completing a task to ensure code quality.
- ALWAYS run `flutter test` to verify existing tests still pass after making changes.
- Create PRs against both develop branch and main branch when making changes to enable easy test on develop 

## Testing conventions
- Unit tests for models: Test JSON serialization, equality, and edge cases.
- Unit tests for services: Test business logic, algorithm correctness, and edge cases.
- Widget tests for screens: Test user interactions and state changes.
- Test files mirror the lib/ structure (e.g., `lib/models/player.dart` → `test/models/player_test.dart`).
- Use descriptive test names: `test('should return error when player name is empty')`.

## Common pitfalls to avoid
- Don't modify model classes without updating corresponding tests.
- Don't skip JSON serialization methods - they're required for persistence.
- Don't forget to handle edge cases (empty lists, null values, invalid input).
- Don't ignore linting warnings from `flutter analyze`.
- Always validate user input in UI screens per the spec validation rules.

---

## Questions or Need Clarification?

If anything here is unclear or you want me to expand examples (serialization templates, a starter `tournament_service.dart`, or PR checklist), tell me which section to elaborate.

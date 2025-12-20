# Copilot Instructions — Padel Tournament (star_cano)

Purpose: Help AI coding agents be immediately productive in this Flutter codebase.

**For best practices on using these instructions, see:** [GitHub Copilot Coding Agent Best Practices](https://gh.io/copilot-coding-agent-tips)

## Overview
- Flutter mobile app to run Americano/Mexicano Padel tournaments.
- Main layers: `lib/models/` (domain), `lib/services/` (business logic), `lib/screens/` (UI), `lib/widgets/` (reusable components), `lib/utils/` (constants/helpers).
- Entry point: `lib/main.dart` — use this to wire temporary screens while developing features.
- Source-of-truth spec: `docs/SPECIFICATION.md` — follow IDs like `F-001` when implementing features.

## Where to start (priority)
- Review implemented code: Most Version 1.0 MVP models and screens are complete.
- Check `docs/TODO.md` for current status and next tasks.
- Core models exist: `lib/models/player.dart`, `lib/models/court.dart`, `lib/models/match.dart`, `lib/models/round.dart`, `lib/models/tournament.dart`.
- Core service exists: `lib/services/tournament_service.dart` (round generation implemented).
- Primary screens exist: `lib/screens/setup_screen.dart`, `lib/screens/round_display_screen.dart`.
- For Version 2.0 features (scoring, Americano algorithm), see `docs/SPECIFICATION.md` sections F-005 and F-006.

## Key conventions & patterns (repo-specific)
- Use JSON serialization helpers (`fromJson`/`toJson`) on model classes for persistence and testing.
- Tournament generation follows the example in `docs/SPECIFICATION.md` (shuffle players, group into matches of 4, leftover players are `playersOnBreak`). Search for `generateFirstRound` in docs for the canonical algorithm snippet.
- Scoring UI: `ScoreButtonGrid` concept (buttons 0–24) — prefer a `Wrap` of fixed-size `ElevatedButton`s that return an `int` score.
- State management: project uses `provider` (see `pubspec.yaml`). Prefer simple `ChangeNotifier` services for now; Riverpod may be used but is not required by existing code.
- Persistence: `shared_preferences` is the expected lightweight storage for MVP data.
- Lints & analysis: `flutter_lints` is configured. Run `flutter analyze` and fix reported issues before committing.
- Dependencies: `provider` (state management), `shared_preferences` (storage), `uuid` (ID generation). Don't add new dependencies without justification.

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
- `docs/SPECIFICATION.md` — canonical requirements and code snippets.
- `docs/GETTING_STARTED.md` — Copilot usage patterns and local dev steps.
- `lib/main.dart` — temporary home screen wiring for manual testing.

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

# Copilot Instructions — Padel Tournament (star_cano)

Purpose: Help AI coding agents be immediately productive in this Flutter codebase.

Big picture
- Flutter mobile app to run Americano/Mexicano Padel tournaments.
- Main layers: `lib/models/` (domain), `lib/services/` (business logic), `lib/screens/` (UI), `lib/widgets/` (reusable components), `lib/utils/` (constants/helpers).
- Entry point: `lib/main.dart` — use this to wire temporary screens while developing features.
- Source-of-truth spec: `docs/SPECIFICATION.md` — follow IDs like `F-001` when implementing features.

Where to start (priority)
- Implement models first: `lib/models/player.dart`, `lib/models/court.dart`, `lib/models/match.dart`, `lib/models/round.dart`, `lib/models/tournament.dart`.
- Add core service: `lib/services/tournament_service.dart` (round generation, persistence helpers).
- Primary screens: `lib/screens/setup_screen.dart`, `lib/screens/round_display_screen.dart`, `lib/screens/score_input_screen.dart`.

Key conventions & patterns (repo-specific)
- Use JSON serialization helpers (`fromJson`/`toJson`) on model classes for persistence and testing.
- Tournament generation follows the example in `docs/SPECIFICATION.md` (shuffle players, group into matches of 4, leftover players are `playersOnBreak`). Search for `generateFirstRound` in docs for the canonical algorithm snippet.
- Scoring UI: `ScoreButtonGrid` concept (buttons 0–24) — prefer a `Wrap` of fixed-size `ElevatedButton`s that return an `int` score.
- State management: project uses `provider` (see `pubspec.yaml`). Prefer simple `ChangeNotifier` services for now; Riverpod may be used but is not required by existing code.
- Persistence: `shared_preferences` is the expected lightweight storage for MVP data.
- Lints & analysis: `flutter_lints` is configured. Run `flutter analyze` and fix reported issues before committing.

Build & developer workflows (PowerShell examples)
- Install deps:
```powershell
flutter pub get
```
- Static analysis:
```powershell
flutter analyze
```
- Run in Chrome (fast dev loop):
```powershell
flutter run -d chrome
```
- List devices:
```powershell
flutter devices
```
- Run tests:
```powershell
flutter test
```
- Hot reload: press `r` in the running terminal; hot restart: `R`.

How to ask Copilot / Chat (examples proven in this repo)
- Generate a model from the spec:
```text
@workspace Based on docs/SPECIFICATION.md, create lib/models/player.dart with id,name and JSON serialization.
```
- Implement first-round algorithm:
```text
@workspace Implement generateFirstRound in lib/services/tournament_service.dart per docs/SPECIFICATION.md F-003.
```
- Create the setup screen:
```text
@workspace Create lib/screens/setup_screen.dart implementing player and court registration (F-001, F-002).
```

Quick PR / commit guidance
- Break work into small commits (one feature/acceptance ID per commit). Use spec IDs in commit messages, e.g. `Implement player registration (F-001)`.
- Update `docs/TODO.md` when adding major features.

Files to inspect for context
- `docs/SPECIFICATION.md` — canonical requirements and code snippets.
- `docs/GETTING_STARTED.md` — Copilot usage patterns and local dev steps.
- `lib/main.dart` — temporary home screen wiring for manual testing.

Notes for agents
- Only implement behavior that is discoverable from the repo (spec, code, or docs). If a decision is ambiguous, propose an option and add a one-line TODO referencing the spec ID.
- Prefer minimal, well-tested changes. Add or update unit tests under `test/` for business logic in `lib/services/`.

If anything here is unclear or you want me to expand examples (serialization templates, a starter `tournament_service.dart`, or PR checklist), tell me which section to elaborate.

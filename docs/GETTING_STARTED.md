# Getting Started Guide - Padel Tournament App
## For Windows Development with GitHub Copilot

---

## Forudsætninger

### Software du skal have installeret:
- ✅ Flutter SDK (https://flutter.dev/docs/get-started/install/windows)
- ✅ Git for Windows (https://git-scm.com/download/win)
- ✅ VS Code (https://code.visualstudio.com/)
- ✅ Android Studio eller Chrome (til testing)
- ✅ GitHub account med Copilot adgang

---

## 1. Initial Setup (Allerede gjort ✓)

Du har allerede:
- ✅ Oprettet GitHub repository
- ✅ Kørt `flutter create`

---

## 2. Klon eller Åbn Dit Projekt

### Hvis projektet er på GitHub:
```powershell
# Åbn PowerShell eller Command Prompt
cd C:\Users\[DIT_BRUGERNAVN]\Documents\

# Klon repository (erstat med dit repo URL)
git clone https://github.com/[DIT_BRUGERNAVN]/padel_tournament_app.git
cd padel_tournament_app
```

### Hvis projektet allerede er lokalt:
```powershell
# Naviger til projekt mappen
cd C:\path\to\padel_tournament_app
```

---

## 3. Opret Specifikations-fil

```powershell
# Opret docs mappe
mkdir docs

# Opret SPECIFICATION.md fil
notepad docs\SPECIFICATION.md
```

**I Notepad:**
- Kopier hele specifikationen jeg lavede tidligere
- Gem filen (Ctrl+S)
- Luk Notepad

---

## 4. Installer VS Code Extensions

### Åbn VS Code:
```powershell
code .
```

### Installer nødvendige extensions:

**Via VS Code UI:**
1. Tryk `Ctrl+Shift+X` for at åbne Extensions
2. Søg og installer:
   - **GitHub Copilot** (GitHub)
   - **GitHub Copilot Chat** (GitHub)
   - **Flutter** (Dart Code)
   - **Dart** (Dart Code)

**Eller via Command Palette:**
1. Tryk `Ctrl+Shift+P`
2. Skriv: `Extensions: Install Extensions`
3. Installer ovenstående

### Verificer Copilot er aktiv:
1. Se i bunden af VS Code - der skal stå Copilot ikon
2. Hvis ikke aktiv: `Ctrl+Shift+P` → "GitHub Copilot: Sign In"

---

## 5. Projekt Struktur Setup

### Opret manglende mapper:
```powershell
# Åbn PowerShell terminal i VS Code (Ctrl+Shift+`)
mkdir lib\models
mkdir lib\services
mkdir lib\screens
mkdir lib\widgets
mkdir lib\utils
```

### Verificer struktur:
```
padel_tournament_app/
├── docs/
│   └── SPECIFICATION.md
├── lib/
│   ├── models/
│   ├── services/
│   ├── screens/
│   ├── widgets/
│   ├── utils/
│   └── main.dart
├── test/
└── pubspec.yaml
```

---

## 6. Opdater pubspec.yaml

Åbn `pubspec.yaml` og tilføj dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # State management
  shared_preferences: ^2.2.2 # Local storage
  uuid: ^4.3.3              # Generate IDs

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

### Installer dependencies:
```powershell
flutter pub get
```

---

## 7. Opret TODO Tracking Fil

```powershell
notepad docs\TODO.md
```

**Kopier dette indhold:**

```markdown
# Development Roadmap - Padel Tournament App

## Version 1.0 - MVP
### Models (lib/models/)
- [ ] player.dart - Player model med JSON serialization
- [ ] court.dart - Court model med JSON serialization
- [ ] match.dart - Team og Match models
- [ ] round.dart - Round model
- [ ] tournament.dart - Tournament model

### Services (lib/services/)
- [ ] tournament_service.dart - Generate første runde logik

### Screens (lib/screens/)
- [ ] setup_screen.dart - Spiller og bane registration
- [ ] round_display_screen.dart - Vis runde oversigt

### Widgets (lib/widgets/)
- [ ] player_list.dart - Liste over spillere
- [ ] court_list.dart - Liste over baner
- [ ] match_card.dart - Kamp kort widget

### Testing
- [ ] Test player registration
- [ ] Test court registration
- [ ] Test første runde generation
- [ ] Test på Android emulator
- [ ] Test på Chrome web

---

## Version 2.0 - Scoring & Algorithm
### Features
- [ ] score_input_screen.dart - Score input UI
- [ ] score_button_grid.dart - 0-24 knapper widget
- [ ] americano_algorithm.dart - Implementer algoritme
- [ ] leaderboard_screen.dart - Vis standings
- [ ] Persistent storage med SharedPreferences

### Algorithm Components
- [ ] _calculatePlayerStats - Point og historik tracking
- [ ] _generateOptimalPairs - Partner matching
- [ ] _matchPairsToGames - Opponent matching
- [ ] _getPlayersOnBreak - Pause rotation

### Testing
- [ ] Test score input
- [ ] Test algoritme med 8 spillere
- [ ] Test algoritme med 12 spillere
- [ ] Test pause rotation
- [ ] Test partner variation

---

## Bugs & Issues
<!-- Track bugs here as they come up -->

---

## Notes
<!-- Development notes, decisions, etc. -->
```

Gem og luk Notepad.

---

## 8. Arbejde med GitHub Copilot

### Start Copilot Chat:
**Metode 1 (Quick Chat):**
- Tryk `Ctrl+Shift+I` for quick chat overlay

**Metode 2 (Chat Panel):**
- Tryk `Ctrl+Alt+I` for persistent chat panel i sidebaren

**Metode 3 (Command Palette):**
- `Ctrl+Shift+P` → skriv "Chat: Focus on Chat View"

---

## 9. Din Første Implementation med Copilot

### Step 1: Generer Player Model

**I Copilot Chat, skriv:**
```
@workspace Based on docs/SPECIFICATION.md, create the Player model 
in lib/models/player.dart. Include:
- id and name fields
- JSON serialization (fromJson and toJson methods)
- Follow the exact structure shown in the specification
```

**Copilot vil generere kode. For at acceptere:**
1. Review koden i preview
2. Klik "Apply" eller tryk `Ctrl+Enter`
3. Filen oprettes automatisk

### Step 2: Generer Court Model

```
@workspace Create the Court model in lib/models/court.dart 
following the same pattern as Player model from SPECIFICATION.md
```

### Step 3: Generer Match Models

```
@workspace Create lib/models/match.dart with Team and Match classes 
as specified in SPECIFICATION.md. Include all fields and JSON serialization.
```

### Step 4: Verificer koden kompilerer

```powershell
# I VS Code terminal
flutter analyze
```

Hvis der er fejl, spørg Copilot:
```
@workspace Fix the compilation errors in lib/models/match.dart
```

---

## 10. Implementer Setup Screen

### Generer screen fil:

```
@workspace Create lib/screens/setup_screen.dart implementing F-001 and F-002 
from SPECIFICATION.md. Include:
- StatefulWidget with player and court registration
- TextField for player names
- ListView.builder to show players
- Add/remove player functionality
- Court number picker
- "Generate First Round" button
- All validation as specified
```

### Test screen:

Opdater `lib/main.dart`:
```
@workspace Update lib/main.dart to show SetupScreen as the home screen. 
Use Material Design with a proper theme.
```

Kør appen:
```powershell
flutter run -d chrome
```

---

## 11. Iterativ Udvikling Pattern

### For hver feature, følg dette mønster:

**1. Bed Copilot om implementation:**
```
@workspace Implement [FEATURE_NAME] from SPECIFICATION.md section [F-XXX]
```

**2. Review koden:**
- Læs gennem genereret kode
- Tjek at den matcher spec
- Test compilation

**3. Test funktionalitet:**
```powershell
flutter run -d chrome
# eller
flutter run -d emulator-5554  # Android emulator
```

**4. Hvis noget er forkert:**
```
@workspace This doesn't match SPECIFICATION.md F-XXX. 
The spec says [QUOTE FROM SPEC]. Please fix.
```

**5. Commit når det virker:**
```powershell
git add .
git commit -m "Implement player registration (F-001)"
git push
```

---

## 12. Nyttige Copilot Kommandoer

### Få forklaring på kode:
```
@workspace Explain how the generateFirstRound method works
```

### Generer tests:
```
@workspace Create unit tests for TournamentService in test/tournament_service_test.dart
```

### Debug hjælp:
```
@workspace I'm getting this error: [PASTE ERROR]. How do I fix it?
```

### Refactor kode:
```
@workspace Refactor the SetupScreen to separate player registration 
into its own widget for better code organization
```

### Code review:
```
@workspace Review lib/screens/setup_screen.dart against SPECIFICATION.md F-001. 
Does it meet all acceptance criteria?
```

---

## 13. Testing Workflow

### Kør på Chrome (hurtigst til development):
```powershell
flutter run -d chrome
```

### Kør på Android Emulator:
```powershell
# List available devices
flutter devices

# Start emulator hvis ikke kørende
# (Åbn Android Studio → Device Manager → Start emulator)

# Kør på emulator
flutter run -d emulator-5554
```

### Hot Reload (mens appen kører):
- Tryk `r` i terminalen for hot reload
- Tryk `R` for hot restart
- Tryk `q` for quit

---

## 14. Common Issues & Solutions

### Issue: "Flutter command not found"
**Fix:**
```powershell
# Verificer Flutter i PATH
flutter --version

# Hvis ikke fundet, tilføj til PATH:
# Windows: Search "Environment Variables" → Edit Path → Add Flutter bin directory
```

### Issue: "Copilot ikke aktiveret"
**Fix:**
1. `Ctrl+Shift+P` → "GitHub Copilot: Sign In"
2. Log ind med din GitHub account
3. Verificer Copilot subscription er aktiv på github.com

### Issue: "Android licenses not accepted"
**Fix:**
```powershell
flutter doctor --android-licenses
# Tryk 'y' for alle
```

### Issue: "Compilation errors"
**Fix:**
```powershell
# Clean og rebuild
flutter clean
flutter pub get
flutter run
```

---

## 15. Daily Development Workflow

### Morgen Setup:
```powershell
# 1. Naviger til projekt
cd C:\path\to\padel_tournament_app

# 2. Pull latest changes
git pull

# 3. Åbn VS Code
code .

# 4. Check TODO
# Åbn docs\TODO.md og vælg næste task
```

### Development Loop:
```
1. Åbn Copilot Chat (Ctrl+Alt+I)
2. Reference SPECIFICATION.md og TODO.md
3. Bed Copilot implementere næste feature
4. Review og test
5. Commit changes
6. Opdater TODO.md
7. Repeat
```

### Aften Wrap-up:
```powershell
# 1. Commit alt arbejde
git add .
git commit -m "Progress on [FEATURE]: [WHAT YOU DID]"
git push

# 2. Opdater TODO.md med noter
notepad docs\TODO.md

# 3. Commit TODO updates
git add docs\TODO.md
git commit -m "Update TODO"
git push
```

---

## 16. Pro Tips for Windows

### PowerShell Aliases (Gør ting hurtigere):
Opret profil fil:
```powershell
notepad $PROFILE
```

Tilføj aliases:
```powershell
# Flutter aliases
function frun { flutter run -d chrome }
function ftest { flutter test }
function fget { flutter pub get }
function fclean { flutter clean; flutter pub get }

# Git aliases
function gst { git status }
function gaa { git add . }
function gcm { param($msg) git commit -m $msg }
function gp { git push }
```

Gem og genstart PowerShell.

### VS Code Keyboard Shortcuts (Windows):
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+Shift+I` - Copilot Quick Chat
- `Ctrl+Alt+I` - Copilot Chat Panel
- `Ctrl+` ` - Toggle Terminal
- `Ctrl+B` - Toggle Sidebar
- `Ctrl+Shift+F` - Find in Files
- `F5` - Start Debugging
- `Ctrl+K Ctrl+C` - Comment lines
- `Ctrl+K Ctrl+U` - Uncomment lines

---

## 17. Næste Steps - Start Din Implementation

### Dag 1: Models (2-3 timer)
```
@workspace Create all data models from SPECIFICATION.md in this order:
1. lib/models/player.dart
2. lib/models/court.dart  
3. lib/models/match.dart (Team + Match)
4. lib/models/round.dart
5. lib/models/tournament.dart

Follow the exact specifications including JSON serialization.
```

### Dag 2: Setup Screen (3-4 timer)
```
@workspace Implement the complete SetupScreen from SPECIFICATION.md F-001 and F-002:
- Player registration with validation
- Court registration
- Generate First Round button
- All UI elements as specified
```

### Dag 3: Tournament Service (2-3 timer)
```
@workspace Implement TournamentService.generateFirstRound() from 
SPECIFICATION.md F-003 with the complete algorithm for:
- Random player shuffling
- Pairing into teams
- Assigning to courts
- Handling players on break
```

### Dag 4: Round Display (2-3 timer)
```
@workspace Implement RoundDisplayScreen and MatchCard widget from 
SPECIFICATION.md F-004 to display the generated round beautifully.
```

### Dag 5: Testing & Refinement (2-3 timer)
- Test på forskellige devices
- Fix bugs
- Refine UI
- Commit Version 1.0

**Total: ~12-15 timer for Version 1.0 MVP**

---

## 18. When You're Ready for Version 2.0

Start en ny branch:
```powershell
git checkout -b feature/version-2.0
```

Begyn med score input:
```
@workspace Implement score input functionality from SPECIFICATION.md F-005:
- ScoreInputScreen with 0-24 button grids
- ScoreButtonGrid widget
- Score persistence in Match model
```

Implementer Americano algoritmen:
```
@workspace Implement the Americano algorithm from SPECIFICATION.md F-006.
Start with the PlayerStats calculation and work through each step of the algorithm.
```

---

## 19. Getting Help

### Fra Copilot:
```
@workspace I'm stuck on [PROBLEM]. According to SPECIFICATION.md [SECTION], 
I need to [REQUIREMENT]. How should I implement this?
```

### Fra Community:
- Flutter Discord: https://discord.gg/flutter
- Flutter Reddit: r/FlutterDev
- Stack Overflow: Tag [flutter]

### Debug Info til at dele:
```powershell
# Få system info
flutter doctor -v

# Få error logs
flutter logs
```

---

## 20. Quick Reference Commands

```powershell
# Development
flutter run -d chrome           # Kør på Chrome
flutter run -d windows          # Kør som Windows desktop app
flutter analyze                 # Check for issues
flutter test                    # Run tests
flutter clean                   # Clean build files

# Git
git status                      # Se ændringer
git add .                       # Stage alle ændringer
git commit -m "message"         # Commit
git push                        # Push til GitHub
git log --oneline              # Se commit historik

# Copilot (i VS Code)
Ctrl+Shift+I                   # Quick Chat
Ctrl+Alt+I                     # Chat Panel
Ctrl+Enter                     # Accept suggestion
```

---

## Success Checklist

Når du har gennemført setup, skal du kunne:

- [ ] Åbne projektet i VS Code
- [ ] Se SPECIFICATION.md i docs/
- [ ] Copilot Chat virker (Ctrl+Alt+I)
- [ ] `flutter run -d chrome` starter appen
- [ ] Copilot kan generere kode fra spec
- [ ] Git commits virker
- [ ] TODO.md bruges til tracking

---

## You're Ready! 🚀

Start med denne kommando i Copilot Chat:

```
@workspace Hello! I'm ready to start implementing the Padel Tournament App. 
I have the complete specification in docs/SPECIFICATION.md. 

Let's start with Version 1.0. Please help me create the Player model 
in lib/models/player.dart following the specification exactly.

After that, we'll work through the TODO list step by step.
```

**Held og lykke med udviklingen!** 🎾
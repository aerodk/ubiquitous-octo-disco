
# Padel Turnering App - Americano/Mexicano Format
## Version 1.0 & 2.0 - Komplet Specifikation

## Overordnet Beskrivelse
En Flutter mobil-applikation der hjælper med at organisere og køre Padel turneringer i Americano/Mexicano format.

---

## TEKNISK STACK

### Platform
- **Framework:** Flutter (Dart)
- **Minimum SDK:** Flutter 3.0+
- **Target Platforms:** iOS og Android (primært)
- **State Management:** Provider eller Riverpod (anbefalet)
- **Local Storage:** SharedPreferences eller Hive for persistens

### Projekt Struktur
```
lib/
├── main.dart
├── models/
│   ├── player.dart
│   ├── court.dart
│   ├── match.dart
│   ├── round.dart
│   └── tournament.dart
├── services/
│   ├── tournament_service.dart
│   └── americano_algorithm.dart
├── screens/
│   ├── setup_screen.dart
│   ├── round_display_screen.dart
│   └── score_input_screen.dart
├── widgets/
│   ├── player_list.dart
│   ├── court_list.dart
│   ├── match_card.dart
│   └── score_button_grid.dart
└── utils/
    └── constants.dart
```

---

## VERSION 1.0 - MVP

### 1. Spiller Registration
**Feature ID:** F-001

**Beskrivelse:**
Brugeren skal kunne indtaste navne på alle deltagere i turneringen.

**Acceptkriterier:**
- TextField til at tilføje spillere
- FloatingActionButton til at tilføje spiller
- ListView.builder til at vise spillere
- Swipe-to-delete eller IconButton til at fjerne spillere
- Minimum 4 spillere, maksimum 72 spillere
- Validering: Ingen tomme navne, ingen duplikater
- SnackBar feedback ved fejl

**Flutter Widgets:**
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Spiller navn',
    suffixIcon: Icon(Icons.person_add),
  ),
)

ListView.builder(
  itemCount: players.length,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text(players[index].name),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => removePlayer(index),
      ),
    );
  },
)
```

---

### 2. Bane Registration
**Feature ID:** F-002

**Beskrivelse:**
Brugeren skal kunne registrere baner.
Antal af baner bliver skal automatisk justeres under registrering af navne, så der tilføjes eller fjernes baner, per hele bane med fire deltagere.

**Acceptkriterier:**
- NumberPicker eller Stepper til antal baner
- Editérbar liste over baner
- Standard: "Bane 1", "Bane 2", etc.
- Minimum 1 bane, maksimum 8 baner


**Flutter Implementation:**
```dart
Row(
  children: [
    IconButton(
      icon: Icon(Icons.remove),
      onPressed: courtCount > 1 ? () => setState(() => courtCount--) : null,
    ),
    Text('$courtCount baner', style: Theme.of(context).textTheme.headline6),
    IconButton(
      icon: Icon(Icons.add),
      onPressed: courtCount < 8 ? () => setState(() => courtCount++) : null,
    ),
  ],
)
```

---

### 3. Generering af Første Runde
**Feature ID:** F-003

**Acceptkriterier:**
- ElevatedButton "Generer Første Runde"
- Tilfældig fordeling af spillere i par
- Tildeling til baner
- Håndtering af pause-spillere

**Dart Logik:**
```dart
class TournamentService {
  Round generateFirstRound(List<Player> players, List<Court> courts) {
    // Bland spillere tilfældigt
    final shuffledPlayers = List<Player>.from(players)..shuffle();
    
    final matches = <Match>[];
    final playersOnBreak = <Player>[];
    
    int playerIndex = 0;
    for (int i = 0; i < courts.length && playerIndex + 3 < shuffledPlayers.length; i++) {
      final match = Match(
        court: courts[i],
        team1: Team(
          player1: shuffledPlayers[playerIndex],
          player2: shuffledPlayers[playerIndex + 1],
        ),
        team2: Team(
          player1: shuffledPlayers[playerIndex + 2],
          player2: shuffledPlayers[playerIndex + 3],
        ),
      );
      matches.add(match);
      playerIndex += 4;
    }
    
    // Resterende spillere på pause
    while (playerIndex < shuffledPlayers.length) {
      playersOnBreak.add(shuffledPlayers[playerIndex]);
      playerIndex++;
    }
    
    return Round(
      roundNumber: 1,
      matches: matches,
      playersOnBreak: playersOnBreak,
    );
  }
}
```

---

### 4. Visning af Første Runde
**Feature ID:** F-004

**Flutter UI:**
```dart
class RoundDisplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Runde ${round.roundNumber}')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ...round.matches.map((match) => MatchCard(match: match)),
          if (round.playersOnBreak.isNotEmpty)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pause_circle, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Pause', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: round.playersOnBreak.map((player) =>
                        Chip(label: Text(player.name))
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final Match match;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_tennis, color: Colors.green),
                SizedBox(width: 8),
                Text(match.court.name, 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(height: 24),
            _buildTeam('Par 1', match.team1),
            SizedBox(height: 12),
            Center(child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 12),
            _buildTeam('Par 2', match.team2),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTeam(String label, Team team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 4),
        Text('${team.player1.name} & ${team.player2.name}',
          style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
```

---

## DEPLOYMENT TIL GITHUB PAGES
**Feature ID:** F-2.5

### Beskrivelse
Applikationen skal kunne deployes til GitHub Pages så den kan bruges i en browser uden installation.

### Konfiguration Krav

#### GitHub Repository Settings (Engangskonfiguration)

**Vigtigt:** GitHub Pages skal konfigureres til at bruge GitHub Actions som kilde, ellers vises kun README.md filen.

**Trin 1: Aktivér GitHub Pages med GitHub Actions**
1. Gå til repository settings: `https://github.com/[brugernavn]/[repo-navn]/settings/pages`
2. Under **Build and deployment**:
   - **Source**: Vælg **"GitHub Actions"** (IKKE "Deploy from a branch")
3. Gem indstillingerne

**Trin 2: Konfigurer Workflow Permissions**
1. Gå til `Settings → Actions → General`
2. Under **Workflow permissions**:
   - Vælg **"Read and write permissions"**
   - Aktivér ✅ **"Allow GitHub Actions to create and approve pull requests"**
3. Klik **Save**

### Workflow Konfiguration

**Fil:** `.github/workflows/deploy-pages.yml`

**Triggers:**
- Automatisk: Ved push til `main` branch
- Manuel: Via "Run workflow" i GitHub Actions UI

**Build Process:**
1. Setup Flutter 3.24.0 (stable channel)
2. Install dependencies: `flutter pub get`
3. Build: `flutter build web --release --base-href /[repo-navn]/`
4. Deploy til GitHub Pages fra `build/web` directory

**URL efter deployment:**
```
https://[brugernavn].github.io/[repo-navn]/
```

### Acceptkriterier
- ✅ Workflow bygger Flutter web app i release mode
- ✅ Deployment sker automatisk ved push til main
- ✅ Flutter applikationen (ikke README.md) vises på GitHub Pages URL
- ✅ App er funktionel i browser uden installation
- ✅ Base-href matcher repository navn for korrekt routing

### Tekniske Detaljer
- Bruger `actions/upload-pages-artifact@v3` til at uploade build
- Bruger `actions/deploy-pages@v4` til deployment
- Kræver GitHub Pages source sat til "GitHub Actions"
- Deployment tid: 2-3 minutter efter workflow completion

### Troubleshooting
Se `deployment.MD` fil i repository root for detaljerede troubleshooting instruktioner.

---

## VERSION 2.0 - SCORE & NÆSTE RUNDER

### 5. Score Input per Kamp
**Feature ID:** F-005

**Beskrivelse:**
Efter hver kamp skal brugeren kunne indtaste score med knap-interface.

**Acceptkriterier:**
- Score range: 0-24 point for hvert par
- To rækker af knapper (0-24) - én for hvert par
- Aktiv knap viser valgt score tydeligt
- "Gem Score" knap som gemmer og går videre
- Validering: Begge par skal have score før gem
- Der skal vises runde knapper med score fra 0-24 efter tryk på en side af banen. Den anden side skal udregnes automatisk.

**Flutter Implementation:**
```dart
class ScoreInputScreen extends StatefulWidget {
  final Match match;
  
  @override
  _ScoreInputScreenState createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  int? team1Score;
  int? team2Score;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indtast Score')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Par 1 info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Par 1', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.match.team1.player1.name} & ${widget.match.team1.player2.name}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            ScoreButtonGrid(
              selectedScore: team1Score,
              onScoreSelected: (score) => setState(() => team1Score = score),
              color: Colors.blue,
            ),
            
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),
            
            // Par 2 info
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Par 2', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.match.team2.player1.name} & ${widget.match.team2.player2.name}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            ScoreButtonGrid(
              selectedScore: team2Score,
              onScoreSelected: (score) => setState(() => team2Score = score),
              color: Colors.red,
            ),
            
            Spacer(),
            
            ElevatedButton(
              onPressed: team1Score != null && team2Score != null
                ? () => _saveScore()
                : null,
              child: Text('Gem Score'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveScore() {
    // Gem score og naviger tilbage
    Navigator.pop(context, {
      'team1Score': team1Score,
      'team2Score': team2Score,
    });
  }
}

class ScoreButtonGrid extends StatelessWidget {
  final int? selectedScore;
  final Function(int) onScoreSelected;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(25, (index) {
        final isSelected = selectedScore == index;
        return SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
            onPressed: () => onScoreSelected(index),
            child: Text('$index', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? color : Colors.grey[300],
              foregroundColor: isSelected ? Colors.white : Colors.black87,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }),
    );
  }
}
```

---

### 6. Americano Algoritme for Næste Runder
**Feature ID:** F-006

**Beskrivelse:**
Generer næste runde baseret på spillernes nuværende point og tidligere par-kombinationer.

## AMERICANO ALGORITME - DETALJERET SPEC

### Mål
- Spillere med samme point skal møde hinanden
- Spillere skal rotere partnere (ikke spille med samme partner for ofte)
- Spillere skal møde forskellige modstandere
- Balanceret fordeling af pause-runder

### Algoritme Trin-for-Trin

```dart
class AmericanoAlgorithm {
  Round generateNextRound({
    required List<Player> players,
    required List<Court> courts,
    required List<Round> previousRounds,
    required int roundNumber,
  }) {
    
    // TRIN 1: Beregn spillernes totale point
    final playerStats = _calculatePlayerStats(players, previousRounds);
    
    // TRIN 2: Sortér spillere efter point (højeste først)
    final sortedPlayers = playerStats.entries
      .map((e) => e.key)
      .toList()
      ..sort((a, b) => playerStats[b]!.totalPoints.compareTo(playerStats[a]!.totalPoints));
    
    // TRIN 3: Generer par baseret på ranking og historik
    final pairs = _generateOptimalPairs(sortedPlayers, playerStats);
    
    // TRIN 4: Match par mod hinanden (nærmeste i ranking)
    final matches = _matchPairsToGames(pairs, courts, playerStats);
    
    // TRIN 5: Identificer spillere på pause
    final playersOnBreak = _getPlayersOnBreak(sortedPlayers, matches);
    
    return Round(
      roundNumber: roundNumber,
      matches: matches,
      playersOnBreak: playersOnBreak,
    );
  }
  
  // TRIN 1: Stats beregning
  Map<Player, PlayerStats> _calculatePlayerStats(
    List<Player> players,
    List<Round> previousRounds,
  ) {
    final stats = <Player, PlayerStats>{};
    
    for (final player in players) {
      stats[player] = PlayerStats(
        player: player,
        totalPoints: 0,
        gamesPlayed: 0,
        partners: {},
        opponents: {},
        pauseRounds: [],
      );
    }
    
    for (final round in previousRounds) {
      // Opdater points fra kampe
      for (final match in round.matches) {
        if (match.isCompleted) {
          _updateStatsFromMatch(match, stats);
        }
      }
      
      // Track pause-runder
      for (final player in round.playersOnBreak) {
        stats[player]!.pauseRounds.add(round.roundNumber);
      }
    }
    
    return stats;
  }
  
  void _updateStatsFromMatch(Match match, Map<Player, PlayerStats> stats) {
    // Team 1 spillere
    final t1p1 = match.team1.player1;
    final t1p2 = match.team1.player2;
    
    // Team 2 spillere
    final t2p1 = match.team2.player1;
    final t2p2 = match.team2.player2;
    
    // Opdater points
    stats[t1p1]!.totalPoints += match.team1Score!;
    stats[t1p2]!.totalPoints += match.team1Score!;
    stats[t2p1]!.totalPoints += match.team2Score!;
    stats[t2p2]!.totalPoints += match.team2Score!;
    
    // Opdater games played
    stats[t1p1]!.gamesPlayed++;
    stats[t1p2]!.gamesPlayed++;
    stats[t2p1]!.gamesPlayed++;
    stats[t2p2]!.gamesPlayed++;
    
    // Track partnere
    stats[t1p1]!.partners[t1p2] = (stats[t1p1]!.partners[t1p2] ?? 0) + 1;
    stats[t1p2]!.partners[t1p1] = (stats[t1p2]!.partners[t1p1] ?? 0) + 1;
    stats[t2p1]!.partners[t2p2] = (stats[t2p1]!.partners[t2p2] ?? 0) + 1;
    stats[t2p2]!.partners[t2p1] = (stats[t2p2]!.partners[t2p1] ?? 0) + 1;
    
    // Track modstandere
    stats[t1p1]!.opponents[t2p1] = (stats[t1p1]!.opponents[t2p1] ?? 0) + 1;
    stats[t1p1]!.opponents[t2p2] = (stats[t1p1]!.opponents[t2p2] ?? 0) + 1;
    stats[t1p2]!.opponents[t2p1] = (stats[t1p2]!.opponents[t2p1] ?? 0) + 1;
    stats[t1p2]!.opponents[t2p2] = (stats[t1p2]!.opponents[t2p2] ?? 0) + 1;
    // ... og vice versa for team 2
  }
  
  // TRIN 3: Generér optimale par
  List<Team> _generateOptimalPairs(
    List<Player> sortedPlayers,
    Map<Player, PlayerStats> stats,
  ) {
    final pairs = <Team>[];
    final usedPlayers = <Player>{};
    
    // Prøv at parre spillere som ikke har spillet sammen før
    // eller som har spillet mindst sammen
    for (int i = 0; i < sortedPlayers.length && pairs.length < sortedPlayers.length / 2; i++) {
      final player1 = sortedPlayers[i];
      
      if (usedPlayers.contains(player1)) continue;
      
      // Find bedste partner for denne spiller
      Player? bestPartner;
      int minPartnerCount = 999;
      int bestRankingDiff = 999;
      
      for (int j = i + 1; j < sortedPlayers.length; j++) {
        final player2 = sortedPlayers[j];
        
        if (usedPlayers.contains(player2)) continue;
        
        final partnerCount = stats[player1]!.partners[player2] ?? 0;
        final rankingDiff = (j - i).abs();
        
        // Prioritér spillere der ikke har spillet sammen
        // Sekundært: vælg spillere tæt i ranking
        if (partnerCount < minPartnerCount ||
            (partnerCount == minPartnerCount && rankingDiff < bestRankingDiff)) {
          bestPartner = player2;
          minPartnerCount = partnerCount;
          bestRankingDiff = rankingDiff;
        }
      }
      
      if (bestPartner != null) {
        pairs.add(Team(player1: player1, player2: bestPartner));
        usedPlayers.add(player1);
        usedPlayers.add(bestPartner);
      }
    }
    
    return pairs;
  }
  
  // TRIN 4: Match par til kampe
  List<Match> _matchPairsToGames(
    List<Team> pairs,
    List<Court> courts,
    Map<Player, PlayerStats> stats,
  ) {
    final matches = <Match>[];
    final usedPairs = <Team>{};
    
    int courtIndex = 0;
    
    // Match par mod hinanden (tæt i ranking)
    for (int i = 0; i < pairs.length - 1 && courtIndex < courts.length; i++) {
      final team1 = pairs[i];
      
      if (usedPairs.contains(team1)) continue;
      
      // Find bedste modstander
      Team? bestOpponent;
      int minOpponentCount = 999;
      
      for (int j = i + 1; j < pairs.length; j++) {
        final team2 = pairs[j];
        
        if (usedPairs.contains(team2)) continue;
        
        // Beregn hvor mange gange disse spillere har mødt hinanden
        final opponentCount = _countPreviousOpponents(team1, team2, stats);
        
        if (opponentCount < minOpponentCount) {
          bestOpponent = team2;
          minOpponentCount = opponentCount;
        }
      }
      
      if (bestOpponent != null) {
        matches.add(Match(
          court: courts[courtIndex],
          team1: team1,
          team2: bestOpponent,
        ));
        
        usedPairs.add(team1);
        usedPairs.add(bestOpponent);
        courtIndex++;
      }
    }
    
    return matches;
  }
  
  int _countPreviousOpponents(Team team1, Team team2, Map<Player, PlayerStats> stats) {
    int count = 0;
    count += stats[team1.player1]!.opponents[team2.player1] ?? 0;
    count += stats[team1.player1]!.opponents[team2.player2] ?? 0;
    count += stats[team1.player2]!.opponents[team2.player1] ?? 0;
    count += stats[team1.player2]!.opponents[team2.player2] ?? 0;
    return count;
  }
  
  // TRIN 5: Identificer pause-spillere
  List<Player> _getPlayersOnBreak(List<Player> sortedPlayers, List<Match> matches) {
    final playingPlayers = <Player>{};
    
    for (final match in matches) {
      playingPlayers.add(match.team1.player1);
      playingPlayers.add(match.team1.player2);
      playingPlayers.add(match.team2.player1);
      playingPlayers.add(match.team2.player2);
    }
    
    return sortedPlayers.where((p) => !playingPlayers.contains(p)).toList();
  }
}

class PlayerStats {
  final Player player;
  int totalPoints;
  int gamesPlayed;
  Map<Player, int> partners;  // Hvor mange gange spillet med hver
  Map<Player, int> opponents; // Hvor mange gange spillet imod hver
  List<int> pauseRounds;
  
  PlayerStats({
    required this.player,
    required this.totalPoints,
    required this.gamesPlayed,
    required this.partners,
    required this.opponents,
    required this.pauseRounds,
  });
  
  double get averagePoints => gamesPlayed > 0 ? totalPoints / gamesPlayed : 0;
}
```

### Algoritme Prioritering
1. **Point-balance** (højeste prioritet): Spillere med samme/lignende point mødes
2. **Partner-rotation**: Undgå samme partner flere gange
3. **Modstander-variation**: Møde forskellige modstandere
4. **Pause-balance**: Fordel pauser jævnt

---

## DATA MODELLER

```dart
// models/player.dart
class Player {
  final String id;
  final String name;
  
  Player({
    required this.id,
    required this.name,
  });
  
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

// models/court.dart
class Court {
  final String id;
  final String name;
  
  Court({required this.id, required this.name});
  
  factory Court.fromJson(Map<String, dynamic> json) => Court(
    id: json['id'],
    name: json['name'],
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

// models/match.dart
class Team {
  final Player player1;
  final Player player2;
  
  Team({required this.player1, required this.player2});
  
  factory Team.fromJson(Map<String, dynamic> json) => Team(
    player1: Player.fromJson(json['player1']),
    player2: Player.fromJson(json['player2']),
  );
  
  Map<String, dynamic> toJson() => {
    'player1': player1.toJson(),
    'player2': player2.toJson(),
  };
}

class Match {
  final String id;
  final Court court;
  final Team team1;
  final Team team2;
  int? team1Score;
  int? team2Score;
  
  Match({
    String? id,
    required this.court,
    required this.team1,
    required this.team2,
    this.team1Score,
    this.team2Score,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  bool get isCompleted => team1Score != null && team2Score != null;
  
  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json['id'],
    court: Court.fromJson(json['court']),
    team1: Team.fromJson(json['team1']),
    team2: Team.fromJson(json['team2']),
    team1Score: json['team1Score'],
    team2Score: json['team2Score'],
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'court': court.toJson(),
    'team1': team1.toJson(),
    'team2': team2.toJson(),
    'team1Score': team1Score,
    'team2Score': team2Score,
  };
}

// models/round.dart
class Round {
  final int roundNumber;
  final List<Match> matches;
  final List<Player> playersOnBreak;
  
  Round({
    required this.roundNumber,
    required this.matches,
    required this.playersOnBreak,
  });
  
  bool get isCompleted => matches.every((m) => m.isCompleted);
  
  factory Round.fromJson(Map<String, dynamic> json) => Round(
    roundNumber: json['roundNumber'],
    matches: (json['matches'] as List).map((m) => Match.fromJson(m)).toList(),
    playersOnBreak: (json['playersOnBreak'] as List).map((p) => Player.fromJson(p)).toList(),
  );
  
  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'matches': matches.map((m) => m.toJson()).toList(),
    'playersOnBreak': playersOnBreak.map((p) => p.toJson()).toList(),
  };
}

// models/tournament.dart
class Tournament {
  final String id;
  final String name;
  final List<Player> players;
  final List<Court> courts;
  final List<Round> rounds;
  final DateTime createdAt;
  
  Tournament({
    String? id,
    required this.name,
    required this.players,
    required this.courts,
    List<Round>? rounds,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       rounds = rounds ?? [],
       createdAt = createdAt ?? DateTime.now();
  
  Round? get currentRound => rounds.isEmpty ? null : rounds.last;
  
  int get completedRounds => rounds.where((r) => r.isCompleted).length;
  
  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    id: json['id'],
    name: json['name'],
    players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
    courts: (json['courts'] as List).map((c) => Court.fromJson(c)).toList(),
    rounds: (json['rounds'] as List).map((r) => Round.fromJson(r)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'players': players.map((p) => p.toJson()).toList(),
    'courts': courts.map((c) => c.toJson()).toList(),
    'rounds': rounds.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}
```

---

## USER FLOW (Version 2.0)

```
1. START
   ↓
2. SETUP (Spillere + Baner)
   ↓
3. GENERER RUNDE 1
   ↓
4. VIS RUNDE 1
   ↓
5. INDTAST SCORE (for hver kamp)
   ↓
6. SE LEADERBOARD (mellemresultat)
   ↓
7. GENERER NÆSTE RUNDE (baseret på Americano algoritme)
   ↓
8. GENTAG 4-7 indtil turnering er slut
   ↓
9. VIS FINAL LEADERBOARD

---
```
## SUCCESS METRICS

### Version 1.0
- Setup af turnering under 2 minutter
- Første runde genereres korrekt
- UI fungerer intuitivt på mobile

### Version 2.0
- Score input er hurtigt (< 10 sekunder per kamp)
- Næste runde algoritme kører på < 2 sekunder
- Spillere møder varierede modstandere (max 2 gange samme modstander)
- Spillere får varierede partnere (max 2 gange samme partner)

---

## FREMTIDIGE FEATURES (Version 3.0+)
- Gem og genoptag turneringer
- Multiple turneringer samtidig
- Statistik og historik per spiller
- Export til PDF/dele via social media
- Dark mode
- Notifikationer når det er din tur
- QR-code sharing til turnering

# Padel Turnering App - Version 7.0 Specifikation
## Visual Redesign - Court & Match Display

---

## Forudsætninger

Version 7.0 bygger videre på:
- ✅ V1.0-V6.0: Komplet turnering system med indstillinger

---

## Oversigt

Version 7.0 fokuserer på at forbedre den visuelle præsentation af kampe og baner med en intuitiv, padel-inspireret grafisk fremstilling der gør det nemt at se hvem der spiller mod hvem.

---

## Feature F-018: Court Visualization with Side-by-Side Layout

### Design Koncept

**Bane som container med blå nuancer:**
- Ligner en rigtig padel bane set oppefra
- Blå/cyan farvetema (som padel bagglas)
- Net visualiseret i midten som divider
- Spillere placeret på hver side af nettet

### Visual Layout

```
┌────────────────────────────────────────────────┐
│  🎾 BANE 1                              [✏️]   │
├────────────────────────────────────────────────┤
│                                                │
│   PAR 1              │              PAR 2      │
│                      │                         │
│   👤 H               │               👤 DE     │
│   👤 B               │               👤 W      │
│                      │                         │
│      [Score]         │         [Score]         │
│                      │                         │
└────────────────────────────────────────────────┘
```

### Color Scheme

**Court Colors (Blå nuancer):**
- Primær baggrund: `Colors.blue[50]` (meget lys blå)
- Court border: `Colors.blue[700]` (mørk blå)
- Net/divider: `Colors.blue[900]` (næsten sort-blå)
- Accent: `Colors.cyan[600]` for highlights

**Player Markers:**
- Generisk person ikon: `Icons.person` eller 👤 emoji
- Neutral grå/hvid baggrund
- Mørk tekst for kontrast

---

## Feature F-019: Match Card Component Redesign

### Card Structure

**Outer Card:**
```dart
Card(
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: Colors.blue[700]!, width: 3),
  ),
  child: CourtLayout(...),
)
```

### Header Section

**Court Name & Actions:**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue[700],
    borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
  ),
  child: Row(
    children: [
      Icon(Icons.sports_tennis, color: Colors.white, size: 24),
      SizedBox(width: 8),
      Text(
        court.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Spacer(),
      IconButton(
        icon: Icon(Icons.edit, color: Colors.white),
        onPressed: () => navigateToScoreInput(),
      ),
    ],
  ),
)
```

### Court Body Layout

**Three-Column Layout:**
1. Par 1 (Left side) - 40%
2. Net (Center) - 20%
3. Par 2 (Right side) - 40%

```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue[50]!,
        Colors.blue[100]!,
      ],
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Par 1 (Left side)
      Expanded(
        flex: 4,
        child: TeamSide(team: match.team1, label: 'PAR 1'),
      ),
      
      // Net (Center)
      Expanded(
        flex: 2,
        child: NetDivider(),
      ),
      
      // Par 2 (Right side)
      Expanded(
        flex: 4,
        child: TeamSide(team: match.team2, label: 'PAR 2'),
      ),
    ],
  ),
)
```

---

## Feature F-020: Team Side Component

### Team Side Widget

**Composition:**
- Team label (Par 1 / Par 2)
- Player 1 with icon
- Player 2 with icon
- Score display (if entered)

```dart
class TeamSide extends StatelessWidget {
  final Team team;
  final String label;
  final int? score;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Team label
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
            letterSpacing: 1.2,
          ),
        ),
        
        SizedBox(height: 16),
        
        // Player 1
        PlayerMarker(player: team.player1),
        
        SizedBox(height: 12),
        
        // Player 2
        PlayerMarker(player: team.player2),
        
        SizedBox(height: 20),
        
        // Score display
        ScoreDisplay(score: score),
      ],
    );
  }
}
```

---

## Feature F-021: Player Marker Component

### Design Specification

**Visual:**
- Generisk person ikon 👤 eller `Icons.person`
- Spillernavn ved siden af
- Kompakt, nem at scanne

```dart
class PlayerMarker extends StatelessWidget {
  final Player player;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Person icon
          Icon(
            Icons.person,
            size: 20,
            color: Colors.blue[700],
          ),
          
          SizedBox(width: 8),
          
          // Player name
          Flexible(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Alternative - Emoji Version:**
```dart
Row(
  children: [
    Text('👤', style: TextStyle(fontSize: 20)),
    SizedBox(width: 8),
    Text(player.name, style: ...),
  ],
)
```

---

## Feature F-022: Net Divider Component

### Visual Design

**Koncept:** Vertikal divider der ligner et net

```dart
class NetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[700]!,
                  Colors.blue[900]!,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Optional: "VS" label in middle
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              shape: BoxShape.circle,
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[700]!,
                  Colors.blue[900]!,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Alternative - Simple Version:**
```dart
VerticalDivider(
  width: 20,
  thickness: 4,
  color: Colors.blue[900],
)
```

---

## Feature F-023: Score Display Component

### Design Specification

**Two states:**
1. **No score entered:** Placeholder
2. **Score entered:** Display score prominently

```dart
class ScoreDisplay extends StatelessWidget {
  final int? score;
  
  @override
  Widget build(BuildContext context) {
    final hasScore = score != null;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: hasScore ? Colors.green[600] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: hasScore ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ] : null,
      ),
      child: hasScore
        ? Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        : Text(
            '--',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.grey[600],
            ),
          ),
    );
  }
}
```

---

## Feature F-024: Bench (Pause) Section Redesign

### Design Concept

**Visual metaphor:** Spillere sidder på en bænk og venter

```
╔════════════════════════════════════════════════╗
║  ⏸️  PÅ BÆNKEN DENNE RUNDE                    ║
╠════════════════════════════════════════════════╣
║                                                ║
║     🪑 👤 Spiller C                            ║
║                                                ║
╚════════════════════════════════════════════════╝
```

### Implementation

```dart
class BenchSection extends StatelessWidget {
  final List<Player> playersOnBreak;
  
  @override
  Widget build(BuildContext context) {
    if (playersOnBreak.isEmpty) return SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange[700]!, width: 2),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange[50]!,
              Colors.orange[100]!,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.pause_circle, 
                     color: Colors.orange[800], 
                     size: 24),
                SizedBox(width: 8),
                Text(
                  'PÅ BÆNKEN DENNE RUNDE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Players on bench
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: playersOnBreak.map((player) =>
                BenchPlayerChip(player: player),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Bench Player Chip

```dart
class BenchPlayerChip extends StatelessWidget {
  final Player player;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bench emoji
          Text('🪑', style: TextStyle(fontSize: 20)),
          
          SizedBox(width: 8),
          
          // Person icon
          Icon(Icons.person, 
               size: 18, 
               color: Colors.orange[700]),
          
          SizedBox(width: 6),
          
          // Player name
          Text(
            player.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Complete Visual Mock-up

### Full Match Card (No Scores)

```
╔═══════════════════════════════════════════════════╗
║  🎾 BANE 1                                  [✏️] ║ ← Dark blue header
╠═══════════════════════════════════════════════════╣
║                                                   ║
║        PAR 1         ║         PAR 2              ║ ← Light blue background
║                      ║                            ║
║   ┌─────────────┐   ║   ┌─────────────┐         ║
║   │ 👤  H       │   ║   │ 👤  DE      │         ║
║   └─────────────┘   ║   └─────────────┘         ║
║                      ║                            ║
║   ┌─────────────┐   ║   ┌─────────────┐         ║
║   │ 👤  B       │   ║   │ 👤  W       │         ║
║   └─────────────┘   ║   └─────────────┘         ║
║                      ║                            ║
║      ┌────┐          VS          ┌────┐          ║
║      │ -- │         ⚫          │ -- │          ║
║      └────┘          ║          └────┘          ║
║                      ║                            ║
╚═══════════════════════════════════════════════════╝
```

### Full Match Card (With Scores)

```
╔═══════════════════════════════════════════════════╗
║  🎾 BANE 1                                  [✏️] ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║        PAR 1         ║         PAR 2              ║
║                      ║                            ║
║   ┌─────────────┐   ║   ┌─────────────┐         ║
║   │ 👤  H       │   ║   │ 👤  DE      │         ║
║   └─────────────┘   ║   └─────────────┘         ║
║                      ║                            ║
║   ┌─────────────┐   ║   ┌─────────────┐         ║
║   │ 👤  B       │   ║   │ 👤  W       │         ║
║   └─────────────┘   ║   └─────────────┘         ║
║                      ║                            ║
║      ┌────┐          VS          ┌────┐          ║
║      │ 18 │         ⚫          │ 21 │          ║ ← Green if winner
║      └────┘          ║          └────┘          ║
║                      ║                            ║
╚═══════════════════════════════════════════════════╝
```

### Bench Section

```
╔═══════════════════════════════════════════════════╗
║  ⏸️  PÅ BÆNKEN DENNE RUNDE                       ║ ← Orange header
╠═══════════════════════════════════════════════════╣
║                                                   ║ ← Light orange background
║  ┌──────────────┐  ┌──────────────┐             ║
║  │ 🪑 👤 C     │  │ 🪑 👤 D     │             ║
║  └──────────────┘  └──────────────┘             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

---

## Color Palette Reference

### Court/Match Colors (Blue Theme)
```dart
// Header
headerBackground: Color(0xFF1565C0)     // Colors.blue[800]
headerText: Colors.white

// Court body
courtBackground: LinearGradient([
  Color(0xFFE3F2FD),  // Colors.blue[50]
  Color(0xFFBBDEFB),  // Colors.blue[100]
])

// Border
courtBorder: Color(0xFF1976D2)          // Colors.blue[700]

// Net/divider
netColor: Color(0xFF0D47A1)             // Colors.blue[900]
netAccent: Color(0xFF1565C0)            // Colors.blue[800]

// Player markers
playerBackground: Colors.white
playerBorder: Color(0xFF64B5F6)         // Colors.blue[300]
playerIcon: Color(0xFF1976D2)           // Colors.blue[700]

// Score (no score)
scoreEmpty: Color(0xFFEEEEEE)           // Colors.grey[300]

// Score (entered)
scoreEntered: Color(0xFF43A047)         // Colors.green[600]
```

### Bench Colors (Orange Theme)
```dart
// Header
benchHeaderIcon: Color(0xFFE65100)      // Colors.orange[900]
benchHeaderText: Color(0xFFE65100)

// Background
benchBackground: LinearGradient([
  Color(0xFFFFF3E0),  // Colors.orange[50]
  Color(0xFFFFE0B2),  // Colors.orange[100]
])

// Border
benchBorder: Color(0xFFE64A19)          // Colors.orange[700]

// Player chips
benchChipBackground: Colors.white
benchChipBorder: Color(0xFFFFB74D)      // Colors.orange[300]
benchChipIcon: Color(0xFFE64A19)        // Colors.orange[700]
```

---

## Responsive Considerations

### Mobile (< 600px width)
- Stack Par 1 and Par 2 vertically instead of side-by-side
- Net becomes horizontal divider
- Reduce padding and font sizes slightly
- Player markers smaller

### Tablet (600-1200px)
- Use layout as specified
- Optimal viewing experience

### Desktop (> 1200px)
- Can show multiple matches side-by-side
- Maintain aspect ratio

---

  Before/After Comparison
Before (V5)
Plain card design
Vertical list of players
Generic "vs" text separator
Text-heavy pause section
After (V6)
Court-inspired visual design
Players positioned on sides of net
Visual net divider with VS badge
Bench metaphor with icons and emojis
Blue color theme matching padel aesthetic
Clear spatial organization
More engaging and intuitive
# Padel Turnering App - Version 3.0 Specifikation
## Leaderboard & Ranking System

---

## Forudsætninger

Version 3.0 bygger videre på:
- ✅ Version 1.0: Setup, spillere, baner, første runde generation
- ✅ Version 2.0: Score input, Americano algoritme, næste runder

---

## VERSION 3.0 - LEADERBOARD & RANKING

### Oversigt

Version 3.0 introducerer et komplet ranking system der viser spillernes nuværende placering baseret på deres præstationer gennem turneringen. Systemet håndterer point-lighed gennem en sofistikeret tiebreaker-mekanisme.

---

## Feature F-007: Live Leaderboard

### Beskrivelse
En live opdateret rangliste der viser alle spilleres placering, statistikker og nuværende standing i turneringen.

### Acceptkriterier
- Live opdatering efter hver gemt score
- Viser alle spillere sorteret efter placering
- Tydelig visuel præsentation af top 3
- Detaljeret statistik for hver spiller
- Support for point-lighed med tiebreakers
- Kan åbnes når som helst under turneringen
- Responsive design der fungerer på mobile enheder

---

## Feature F-008: Ranking Algoritme

### Beskrivelse
Sofistikeret ranking system der placerer spillere baseret på præstationer med hierarkisk tiebreaker-system.

### Ranking Kriterier (Prioriteret Rækkefølge)

#### 1. Total Point (Primær)
**Definition:** Summen af alle point scoret gennem alle kampe.

**Beregning:**
```dart
int totalPoints = 0;
for (round in tournament.rounds) {
  for (match in round.matches where match.isCompleted) {
    if (match involverer denne spiller) {
      totalPoints += spillerens score i denne kamp;
    }
  }
}
```

**Eksempel:**
- Spiller A: Kamp 1 (15), Kamp 2 (18), Kamp 3 (12) = **45 point**
- Spiller B: Kamp 1 (20), Kamp 2 (14), Kamp 3 (11) = **45 point**

→ Point-lighed! Gå til næste kriterium.

---

#### 2. Antal Sejre (Første Tiebreaker)
**Definition:** Antal kampe vundet (højeste score i kampen).

**Beregning:**
```dart
int wins = 0;
for (match in spillerens kampe) {
  if (spillerens team score > modstander team score) {
    wins++;
  }
}
```

**Vigtigt:** En sejr tæller som 1, uanset margin.

**Eksempel (med point-lighed fra før):**
- Spiller A: 3 kampe → 2 sejre, 1 nederlag
- Spiller B: 3 kampe → 1 sejr, 2 nederlag

→ Spiller A rangerer højere (2 > 1 sejre)

**Hvis stadig lige:** Gå til næste kriterium.

---

#### 3. Interne Opgør (Anden Tiebreaker)
**Definition:** Direkte resultater mellem de spillere der er i point-lighed.

**Beregning:**
```dart
// Find alle kampe hvor begge spillere var involveret
List<Match> headToHeadMatches = [];
for (match in tournament.rounds.expand((r) => r.matches)) {
  if (match involverer både spiller A og spiller B) {
    headToHeadMatches.add(match);
  }
}

// Beregn head-to-head score
int playerAPointsInH2H = 0;
int playerBPointsInH2H = 0;

for (match in headToHeadMatches) {
  if (player A og B var partnere) {
    // De spillede sammen - ikke relevant for H2H
    continue;
  } else {
    // De spillede mod hinanden
    playerAPointsInH2H += As team score;
    playerBPointsInH2H += Bs team score;
  }
}

// Højeste H2H point vinder
```

**Eksempel:**
- Spiller A og B har mødt hinanden én gang:
  - Kamp: A+C (18) vs B+D (12)
  - A's H2H point: 18
  - B's H2H point: 12
  
→ Spiller A rangerer højere

**Særlige cases:**
- **Aldrig mødt:** Skip dette kriterium, gå til næste
- **Mødt flere gange:** Sum alle H2H kampe
- **Spillede sammen som partnere:** Tæller ikke i H2H

**Hvis stadig lige eller ikke relevant:** Gå til næste kriterium.

---

#### 4. Største Sejr (Tredje Tiebreaker)
**Definition:** Den største margin en spiller har vundet med i en enkelt kamp.

**Beregning:**
```dart
int biggestWinMargin = 0;

for (match in spillerens kampe) {
  if (spillerens team vandt) {
    int margin = spillerens team score - modstander team score;
    if (margin > biggestWinMargin) {
      biggestWinMargin = margin;
    }
  }
}
```

**Eksempel:**
- Spiller A's sejre: 18-12 (margin: 6), 20-15 (margin: 5) → **Største sejr: 6**
- Spiller B's sejre: 17-14 (margin: 3) → **Største sejr: 3**

→ Spiller A rangerer højere (6 > 3)

**Særlige cases:**
- **Ingen sejre:** Største sejr = 0

**Hvis stadig lige:** Gå til næste kriterium.

---

#### 5. Mindste Nederlag (Fjerde Tiebreaker)
**Definition:** Den mindste margin en spiller har tabt med (nærmeste kamp).

**Beregning:**
```dart
int smallestLossMargin = 999; // Start med meget højt

for (match in spillerens kampe) {
  if (spillerens team tabte) {
    int margin = modstander team score - spillerens team score;
    if (margin < smallestLossMargin) {
      smallestLossMargin = margin;
    }
  }
}

// Laveste margin er bedre (tættere kamp = bedre præstation i nederlag)
```

**Eksempel:**
- Spiller A's nederlag: 12-18 (margin: 6), 10-20 (margin: 10) → **Mindste nederlag: 6**
- Spiller B's nederlag: 14-17 (margin: 3), 11-19 (margin: 8) → **Mindste nederlag: 3**

→ Spiller B rangerer højere (3 < 6, tættere kamp)

**Særlige cases:**
- **Ingen nederlag:** Mindste nederlag = 0 (perfekt - højeste ranking)

**Hvis stadig lige:** Spillere deler placering.

---

## Testing & Validation

### Test Cases

**Test Case 1: Basic Ranking**
```
Spillere: A, B, C, D
Kampe:
- Kamp 1: A+B (20) vs C+D (10)
- Kamp 2: A+C (15) vs B+D (18)

Forventet ranking:
1. B (38 point, 2 sejre)
2. A (35 point, 1 sejr)
3. D (28 point, 1 sejr)
4. C (25 point, 0 sejre)
```

**Test Case 2: Point Lighed - Sejre afgør**
```
Spillere: A, B
Kampe:
- Kamp 1: A+X (20) vs B+Y (15) → A vinder
- Kamp 2: A+Y (10) vs B+X (15) → B vinder
- Kamp 3: A+Z (15) vs X+Y (12) → A vinder
- Kamp 4: B+Z (15) vs X+Y (10) → B vinder

Resultat:
- A: 45 point (2 sejre, 1 nederlag)
- B: 45 point (2 sejre, 1 nederlag)

Men kigger vi nærmere:
- A's sejre margins: +5, +3 = Største sejr: 5
- B's sejre margins: +5, +5 = Største sejr: 5

Stadig lige → Går til mindste nederlag:
- A's nederlag: -5
- B's nederlag: -5

→ Delt 1. plads (begge får rank 1)
```

**Test Case 3: Head-to-Head afgør**
```
Spillere: A, B, C, D (alle 60 point)

Head-to-Head mellem A og B:
- Kamp 1: A+C (18) vs B+D (12) → A +6
- Kamp 2: A+D (15) vs B+C (18) → B +3
- A's H2H: 33 point
- B's H2H: 30 point

→ A rangerer over B pga. bedre H2H
```

**Test Case 4: Største sejr afgør**
```
Spillere: A, B (begge 50 point, begge 2 sejre, aldrig mødt)

A's sejre:
- 20-15 (margin: 5)
- 18-10 (margin: 8) ← Største

B's sejre:
- 19-13 (margin: 6) ← Største
- 17-11 (margin: 6)

→ A rangerer over B (8 > 6)
```

**Test Case 5: Mindste nederlag afgør**
```
Spillere: A, B (begge 45 point, begge 1 sejr, ingen H2H forskel)

A's nederlag:
- 15-20 (margin: 5) ← Mindste
- 10-18 (margin: 8)

B's nederlag:
- 16-20 (margin: 4) ← Mindste
- 12-19 (margin: 7)

→ B rangerer over A (4 < 5, tættere nederlag er bedre)
```

---
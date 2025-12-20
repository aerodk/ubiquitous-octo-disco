# Padel Turnering App - Version 4.0 Specifikation
## Final Round System

---

## Forudsætninger

Version 4.0 bygger videre på:
- ✅ V1.0: Setup og første runde
- ✅ V2.0: Score input og Americano algoritme
- ✅ V3.0: Leaderboard og ranking system

---

## Oversigt

Version 4.0 introducerer en **Final Round** - en afsluttende runde hvor spillere matcher baseret på deres nuværende placering i turneringen. Dette giver en spændende afslutning hvor top-spillere mødes og alle kæmper om deres endelige placering.

---

## Feature F-010: Final Round Detection

### Formål
Systemet skal kunne identificere hvornår turneringen er klar til en sidste runde.

### Kriterier for Final Round
- Turneringen har haft minimum 3 runder
- Administrator vælger aktivt "Start Sidste Runde"

### UI/UX
- Efter en runde afsluttes, vis **"Start Sidste Runde"** knap
- Knappen skal være visuelt distinkt (fx guld farve, større)
- Vis bekræftelsesdialog: "Dette starter den sidste runde. Er du sikker?"
- Leaderboard vises automatisk før final round starter

---

## Feature F-011: Final Round Pairing Algorithm

### Overordnet Princip
**Match spillere baseret på nuværende ranking for mest konkurrencedygtige kampe.**

### Basis Regler

#### 1. Top vs. Top Pairing
- **Rank 1 + Rank 3** vs **Rank 2 + Rank 4**
- **Rank 5 + Rank 7** vs **Rank 6 + Rank 8**
- Osv.

**Rationale:** 
- Top 2 mødes for at afgøre førstepladsen
- Men de får forskellige partnere (3 og 4) for at udfordre dem
- Giver spændende og konkurrencedygtige kampe

#### 2. Pattern
```
Kamp 1: Rank 1 + Rank 3  vs  Rank 2 + Rank 4
Kamp 2: Rank 5 + Rank 7  vs  Rank 6 + Rank 8
Kamp 3: Rank 9 + Rank 11 vs  Rank 10 + Rank 12
...
```

### Håndtering af Overskydende Spillere ⭐

**Problem:** Hvis spillere ikke er delelige med 4, hvad gør man?

**Løsning: Rolling Pause System**

### Pause Prioritering (Hierarkisk)

Når der er overskydende spillere, vælg dem der skal sidde over baseret på:

#### 1. Mest Spillede Kampe (Primær)
- Spillere der har spillet flest kampe sidder over først
- **Undtagelse:** Top halvdel af stillingen er beskyttet

#### 2. Laveste Ranking (Sekundær)
- Blandt spillere med samme antal kampe, vælg lavest ranked
- Undgå at toppen af leaderboard sidder over i sidste runde

#### 3. Tidligere Pauser (Tertiær)
- Hvis stadig lige, vælg dem der har siddet færrest gange over
- Sikrer fair rotation gennem turneringen

### Eksempler

**13 spillere:**
```
Ranking: R1, R2, R3, ..., R13
Kamp count: Alle har spillet 4 kampe, undtagen R10 (5 kampe) og R13 (3 kampe)

Pause logic:
1. R10 har spillet flest → Kandidat til pause
2. Men R10 er ikke i bund halvdel (13/2 = 6.5, R10 er #10)
3. Næste: Find i bund halvdel med flest kampe
4. R11, R12, R13 har alle 4 kampe (R13: 3)
5. R13 sidder over (lavest ranked i bund halvdel)

Final round matches:
- Kamp 1: R1+R3 vs R2+R4
- Kamp 2: R5+R7 vs R6+R8  
- Kamp 3: R9+R11 vs R10+R12
Pause: R13
```

**14 spillere (2 overskydende):**
```
Pause candidates i bund halvdel (R8-R14):
- Find 2 spillere med flest kampe eller lavest ranking
- Eksempel: R13 og R14 sidder over

Matches: R1-R12 i 3 kampe
Pause: R13, R14
```

**15 spillere (3 overskydende):**
```
Pause: R13, R14, R15 (bund 3 spillere)
Matches: R1-R12 i 3 kampe
```

### Beskyttelse af Top Spillere

**Top halvdel sidder ALDRIG over i sidste runde** (medmindre absolut nødvendigt).

Rationale:
- Final round afgør topplaceringer
- Unfair hvis top spillere ikke kan kæmpe om deres position
- Bundkampe påvirker ikke top rankings væsentligt

### Algoritme Pseudo-kode

```
1. Beregn hvor mange skal sidde over (spillere % 4)
2. Split spillere i top halvdel og bund halvdel
3. For hver pause position:
   a. Find spillere i bund halvdel med flest kampe
   b. Blandt dem, vælg lavest ranked
   c. Hvis ingen i bund, vælg fra top (edge case)
4. Resterende spillere pair efter R1+R3 vs R2+R4 mønster
```

### V5 Preview: Wildcard Match Option

I Version 5.0 vil der være en turnering setting:
- **"Final Round Strategy"**: Rolling Pause (default) eller Wildcard Match
- Giver fleksibilitet til turneringer med mere tid

Men V4 fokuserer på rolling pause da det passer til tidsrammen i de fleste turneringer.

---

## Feature F-012: Final Round Special Rules

### Scoring
- Normal scoring (0-24 point)
- Alle point tæller til final ranking

### Visuel Identifikation
- Final round markeres tydeligt: **"🏆 SIDSTE RUNDE"**
- Guld farve tema
- Special animation/confetti når runde startes

### Bane Tildeling
- Top kamp (R1+R3 vs R2+R4) tildeles "Court 1" eller bedste bane
- Vigtighed prioriteret: Top kampe får bedste baner

---

## Feature F-013: Tournament Completion

### Efter Final Round
Når alle scores er indtastet:

1. **Beregn Final Ranking**
   - Kør ranking algoritme med alle kampe inkl. final round
   
2. **Vis Final Leaderboard**
   - Special "Tournament Complete" view
   - Podium visning (1., 2., 3. plads)
   - Konfetti animation
   - "Del Resultat" knap

3. **Tournament Summary**
   - Total kampe spillet
   - Turnerings varighed
   - Top scorer (flest point total)
   - Most wins (flest sejre)
   - Biggest win (største sejr margin)

### Arkivering
- Gem turneringen som "Completed"
- Mulighed for at starte ny turnering
- Kan ikke ændre completed tournament

---



## User Flow

```
1. Spillere spiller normale runder (V2.0 Americano algoritme)
   ↓
2. Efter 3+ runder, "Start Sidste Runde" knap vises
   ↓
3. Admin klikker → Bekræftelsesdialog vises med leaderboard preview
   ↓
4. Bekræfter → Final round genereres med special pairing
   ↓
5. Final round vises med guld tema og "🏆 SIDSTE RUNDE" header
   ↓
6. Kampe spilles og scores indtastes (normal flow)
   ↓
7. Når sidste score gemmes → Automatic navigation til completion screen
   ↓
8. Vis podium, final leaderboard, statistik
   ↓
9. Mulighed for at dele resultat eller starte ny turnering
```

---

## Edge Cases & Validation

### Edge Case 1: Ulige Antal Spillere
**Håndteres af:** Hybrid approach i pairing algorithm
- 1 over: Pause
- 2 over: Wildcard match
- 3 over: Pause

### Edge Case 2: Ikke Nok Baner
**Løsning:** Prioritér top kampe på tilgængelige baner
- R1+R3 vs R2+R4 får bane 1
- Næste vigtigste får bane 2, osv.
- Bundkampe kan evt. spilles sekventielt

### Edge Case 3: Point Lighed i Top 4
**Løsning:** Brug eksisterende tiebreaker (V3.0)
- Ranking er altid deterministisk
- Selv ved delt placering, sortér konsistent

### Edge Case 4: Ufuldstændig Tournament
**Validation:** 
- Kan ikke starte final round hvis aktuel runde ikke er completed
- Må have minimum 3 runder
- Alle spillere skal have spillet minimum 2 kampe

---

## Success Criteria

Version 4.0 er succesfuld når:

- [ ] Final round kan startes efter 3+ runder
- [ ] Pairing algoritme matcher korrekt (R1+R3 vs R2+R4 pattern)
- [ ] Overskydende spillere håndteres fair og konsistent
- [ ] Final round er visuelt distinkt (guld tema, trofæ)
- [ ] Tournament completion screen viser korrekt statistik
- [ ] Podium animation for top 3
- [ ] Completed tournaments kan ikke ændres
- [ ] Kan starte ny turnering efter completion

---

## Testing Scenarios

### Test 1: 12 Spillere (Perfekt)
```
12 spillere (3 kampe)
- Kamp 1: R1+R3 vs R2+R4
- Kamp 2: R5+R7 vs R6+R8
- Kamp 3: R9+R11 vs R10+R12
```

### Test 2: 13 Spillere (1 Over)
```
13 spillere
Setup: R1-R12 har spillet 4 kampe, R13 har spillet 3 kampe

Break selection:
- Top half (R1-R6): Protected, never sit out
- Bottom half (R7-R13): Candidates
- R13 has fewest games (3) and lowest rank → Sits out

Final round matches:
- Kamp 1: R1+R3 vs R2+R4
- Kamp 2: R5+R7 vs R6+R8
- Kamp 3: R9+R11 vs R10+R12
Pause: R13
```

### Test 3: 14 Spillere (2 Over)
```
14 spillere
Setup: All played 4 games

Break selection:
- Top half (R1-R7): Protected
- Bottom half (R8-R14): Candidates
- Select 2 lowest: R13, R14

Final round matches:
- Kamp 1: R1+R3 vs R2+R4
- Kamp 2: R5+R7 vs R6+R8
- Kamp 3: R9+R11 vs R10+R12
Pause: R13, R14
```

### Test 4: 10 Spillere (Different Game Counts)
```
10 spillere
Game counts: R1-R5 (4 games), R6-R8 (5 games), R9-R10 (4 games)

Break selection:
- Top half (R1-R5): Protected even though some have 4 games
- Bottom half (R6-R10): Candidates
- R6, R7, R8 have 5 games (most played)
- Select lowest ranked of these: R8
- Need 2 total, next: R10 (lowest in bottom half with 4 games)

Final round matches:
- Kamp 1: R1+R3 vs R2+R4
- Kamp 2: R5+R7 vs R6+R9
Pause: R8, R10
```

---

## Future Enhancements (V5.0+)

### Tournament Settings (Pre-Game Configuration)
- **Final Round Strategy:** Rolling Pause (default) / Wildcard Match
- **Minimum Rounds:** Set minimum rounds before final round (default: 3)
- **Time Limits:** Set match duration limits
- **Pause Rotation:** Force equal breaks or allow optimization

### Additional Features
- **Semi-finals mode:** Top 8 spillere i knock-out format
- **Best-of-three finals:** Top 2 par spiller bedst af 3
- **Live spectator mode:** QR kode til at følge final round live
- **Tournament brackets:** Visualisering af slutspil

---

## Implementation Timeline

**Estimated: 4-6 timer**

- Final round detection (1 time)
- Pairing algorithm (2 timer)
- UI updates (1-2 timer)
- Completion screen (1 time)

---

## Migration Note

Eksisterende turneringer (fra V1-V3) skal have:
- `isFinalRound = false` for alle runder
- `isCompleted = false` for tournament

Ingen breaking changes i datamodeller.

---

## Spørgsmål & Design Decisions

### Beslutning: Rolling Pause System ✅

**Valgt løsning:** Rolling pause med beskyttelse af top halvdel

**Rationale:**
- Turneringer er tidsbegrænsede - ekstra kampe er sjældent mulige
- Fair rotation sikrer alle får nogenlunde lige mange kampe
- Top spillere SKAL spille for at konkurrere om placeringer
- Simple og klar regel alle forstår

**V5 Preview:** 
Wildcard match tilføjes som valgfri indstilling i tournament setup, så organisatorer kan vælge baseret på deres tid og præferencer.
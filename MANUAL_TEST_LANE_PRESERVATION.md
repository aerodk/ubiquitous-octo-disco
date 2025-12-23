# Manual Testing Guide: Lane Preservation Feature

## Overview
This guide helps verify that court/lane assignments are preserved when navigating back and forward between rounds without changing scores.

## Prerequisites
- Flutter development environment set up
- App running on a device or emulator

## Test Case 1: Basic Back/Forward Navigation (No Score Changes)

### Steps:
1. Start a new tournament with 8 players and 2 courts
2. Generate Round 1
3. Enter scores for all matches in Round 1 (e.g., 15-10 for each match)
4. Generate Round 2
5. **Note the court assignments** for Round 2:
   - Match 1: Which court? (e.g., "Bane 1")
   - Match 2: Which court? (e.g., "Bane 2")
6. Press the back button (should show Round 1)
7. Press "Generate Next Round" button to return to Round 2
8. **Verify the court assignments match exactly** what was noted in step 5

### Expected Result:
✅ Court assignments in Round 2 should be IDENTICAL to the original assignments

### Failure Case:
❌ If court assignments are different, the feature is NOT working correctly

---

## Test Case 2: Back/Forward with Score Changes

### Steps:
1. Continue from Test Case 1 (currently viewing Round 2)
2. Press back button to view Round 1
3. **Change a score** in Round 1 (e.g., change 15-10 to 12-12)
4. Press "Generate Next Round" button
5. Observe the court assignments for the newly generated Round 2

### Expected Result:
✅ Court assignments should be REGENERATED (likely different from original)
✅ This is correct behavior because scores were changed

### Rationale:
When scores change, standings change, which may affect future round generation logic.
Therefore, regeneration is expected and correct.

---

## Test Case 3: Multiple Back/Forward Cycles

### Steps:
1. Start fresh: New tournament with 8 players, 2 courts
2. Complete Round 1 with scores
3. Generate Round 2, note court assignments
4. Complete Round 2 with scores
5. Generate Round 3, note court assignments
6. Press back twice to reach Round 1
7. Press "Generate Next Round" twice to reach Round 3
8. Verify court assignments match original Round 3

### Expected Result:
✅ Both Round 2 and Round 3 should have identical court assignments to their originals

---

## Test Case 4: Deep Navigation with Partial Score Entry

### Steps:
1. Continue from Test Case 3
2. View Round 3 (no scores entered yet)
3. Press back to Round 2
4. Press back to Round 1
5. Press "Generate Next Round" to Round 2
6. Verify Round 2 court assignments match original
7. Press "Generate Next Round" to Round 3
8. Verify Round 3 court assignments match original

### Expected Result:
✅ All rounds preserve their original court assignments when no scores changed

---

## Test Case 5: Court Adjustment During Round

### Steps:
1. Start new tournament with 12 players, 2 courts
2. Generate Round 1, complete with scores
3. Generate Round 2
4. Note initial court assignments
5. Press back to Round 1
6. Press "Generate Next Round"
7. Verify court assignments restored correctly

### Expected Result:
✅ Court assignments preserved even with players on break

---

## Debugging Tips

### If tests fail:
1. Check browser console / app logs for errors
2. Verify `saveFullTournamentHistory()` is being called in `_goToPreviousRound()`
3. Verify `loadFullTournamentHistory()` is being called in `_generateNextRound()`
4. Check SharedPreferences to ensure history is being saved:
   - Key: `full_tournament_history`
   - Should contain tournament JSON with all rounds

### Console Debugging:
Add these print statements to verify behavior:

```dart
// In _goToPreviousRound():
print('Saving tournament history with ${_tournament.rounds.length} rounds');

// In _generateNextRound():
print('Loaded history: ${savedHistory != null}');
print('History has ${savedHistory?.rounds.length ?? 0} rounds');
print('Rounds identical: ${savedHistory != null && _roundsAreIdentical(savedHistory, _tournament)}');
print('Restored from history: $restoredFromHistory');
```

---

## Success Criteria

All test cases should pass with:
- ✅ Court assignments preserved when navigating back/forward without score changes
- ✅ Court assignments regenerated when scores are modified
- ✅ Multiple navigation cycles work correctly
- ✅ No errors or crashes during navigation

# Manual Testing Guide: Player Pause Override Feature

## Feature Overview
This feature allows users to manually override which players are on pause during a round by clicking on player names.

## Prerequisites
- Flutter environment set up
- App running in browser or on device

## Test Scenarios

### Scenario 1: Force Player from Pause to Active

**Setup:**
1. Create a tournament with 9 players and 2 courts
2. Generate the first round
3. Observe that 1 player is on pause (9 - 2*4 = 1)

**Steps:**
1. In the "Pause" section (orange card), click on the player name
2. A confirmation dialog should appear with:
   - Title: "Tving [Player Name] til spille?"
   - Explanation text about forcing the player to play
   - Green "Tving til spille" button
   - "Annuller" button
3. Click "Tving til spille"
4. The round should regenerate with:
   - The clicked player now in a match
   - A different player on pause
5. A green success message should appear

**Expected Result:**
✅ Player moves from pause to active
✅ Matches are regenerated
✅ A different player goes on pause to maintain the constraint

### Scenario 2: Force Player from Active to Pause

**Setup:**
1. Create a tournament with 8 players and 2 courts
2. Generate the first round
3. Observe that all players are active (8 = 2*4, perfect fit)

**Steps:**
1. In a match card, click on one of the player names (they now have pause icons)
2. A confirmation dialog should appear with:
   - Title: "Tving [Player Name] til pause?"
   - Explanation text about forcing the player to pause
   - Orange "Tving til pause" button
   - "Annuller" button
3. Click "Tving til pause"
4. The round should regenerate with:
   - The clicked player now on pause
   - Only 1 match showing (7 active players can only fill 1 court)
5. A green success message should appear

**Expected Result:**
✅ Player moves from active to pause
✅ Matches are regenerated
✅ Number of matches adjusts based on available players

### Scenario 3: Validation - Max Pause Players

**Setup:**
1. Create a tournament with 9 players and 2 courts
2. Generate the first round (1 player on pause)

**Steps:**
1. Click on a player name in a match to force them to pause
2. An error message should appear:
   - Red background
   - Message: "Kan ikke sætte flere spillere på pause. Med 2 baner og 9 spillere, kan maksimalt 1 spillere være på pause."

**Expected Result:**
✅ Override is rejected
✅ Clear error message explains the constraint
✅ No changes to the round

### Scenario 4: Validation - Scores Already Entered

**Setup:**
1. Create a tournament with 9 players and 2 courts
2. Generate the first round
3. Enter scores for at least one match

**Steps:**
1. Try to click on a player name (either in pause or in a match)
2. An error message should appear:
   - Red background
   - Message: "Kan ikke ændre spillere når der er indtastet score"

**Expected Result:**
✅ Override is rejected
✅ Error message explains why
✅ No changes to the round
✅ This prevents data loss of entered scores

### Scenario 5: UI Visual Indicators

**Setup:**
1. Create any tournament and generate a round

**Visual Checks:**
1. **Pause Section:**
   - Player names appear as ActionChips (not plain Chips)
   - Each chip has a play arrow icon (►)
   - Chips are clickable/interactive
   
2. **Match Cards:**
   - Player names appear as ActionChips
   - Each chip has a pause icon (⏸)
   - Chips are separated by " & "
   - Chips are clickable/interactive

**Expected Result:**
✅ Clear visual distinction between clickable and non-clickable elements
✅ Icons convey the action (play arrow = go to play, pause = go to pause)
✅ Consistent styling with the rest of the app

### Scenario 6: Multiple Players on Pause

**Setup:**
1. Create a tournament with 10 players and 2 courts
2. Generate the first round (2 players on pause)

**Steps:**
1. Click on one of the paused players to force them to active
2. Confirm the action
3. Observe the result:
   - The clicked player is now in a match
   - 2 players are still on pause (one is new, one remained)

**Expected Result:**
✅ Correct player is moved to active
✅ Total pause count remains correct (2 in this case)
✅ At least one pause spot is filled by a different player

### Scenario 7: Cancel Override Action

**Setup:**
1. Create any tournament and generate a round

**Steps:**
1. Click on any player name to trigger override
2. In the confirmation dialog, click "Annuller"
3. Observe no changes occur

**Expected Result:**
✅ Dialog closes
✅ No changes to player assignments
✅ No error or success messages

## Edge Cases to Test

### Edge Case 1: Rapid Clicking
- Click multiple player names rapidly before confirmation
- Only one dialog should be shown at a time

### Edge Case 2: Final Round
- Test override functionality in final rounds
- Should work the same way as regular rounds

### Edge Case 3: First Round
- Test override in the very first round
- No previous scores to worry about

### Edge Case 4: Persistence
- After overriding a player status
- Navigate away and back to the round
- Changes should be persisted

## Screenshot Checklist

Capture screenshots of:
- [ ] Pause section with clickable player chips (play arrow icon visible)
- [ ] Match card with clickable player chips (pause icon visible)
- [ ] Confirmation dialog for forcing to active
- [ ] Confirmation dialog for forcing to pause
- [ ] Success message after override
- [ ] Error message for max pause constraint
- [ ] Error message for scores already entered
- [ ] Before and after states of a successful override

## Performance Checks

- [ ] Override action completes quickly (< 1 second)
- [ ] No UI freezing during regeneration
- [ ] Smooth transitions and animations

## Accessibility Notes

- Player chips should be keyboard accessible
- Confirmation dialogs should be screen reader friendly
- Color coding (green/orange/red) should not be the only indicator

## Notes for Developers

If any test fails, check:
1. `TournamentService.regenerateRoundWithOverride()` logic
2. `RoundDisplayScreen._overridePlayerToPause()` method
3. MatchCard's `onPlayerForceToPause` callback wiring
4. Validation logic for max pause players calculation

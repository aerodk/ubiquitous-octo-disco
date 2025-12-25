# Manual Testing Guide: Improved Standings Features

## Prerequisites
- Flutter development environment set up
- Repository cloned and dependencies installed (`flutter pub get`)
- Ability to run the app on a device or emulator

## Test Scenarios

### Scenario 1: Compact View Toggle

**Setup:**
1. Start a new tournament with 4+ players
2. Complete at least one round with scores entered
3. Navigate to the Leaderboard screen

**Test Steps:**
1. Verify you're in detailed view (should show "Total Points", "Matches Played", etc.)
2. Locate the toggle button in the app bar (next to export button)
3. Verify the button shows the "view_compact" icon
4. Tap the toggle button
5. Verify the view changes to compact format
6. Verify each player shows: "Rank. Name - W/L - Points"
7. Tap the toggle button again
8. Verify it returns to detailed view

**Expected Results:**
- Toggle button visible when matches have been played
- Icon changes between view_compact (📋) and view_list (📝)
- Tooltip shows appropriate text
- View switches smoothly between formats
- All player data displayed correctly in both views
- Top 3 color coding maintained in both views

### Scenario 2: Compact View Format Verification

**Setup:**
1. Continue from Scenario 1, switch to compact view
2. Have players with different W/L records

**Test Steps:**
1. Find a player ranked 3rd (e.g., "John")
2. Verify format matches: "3. John - XW/YL - ZZ pt"
3. Check multiple players for correct formatting
4. Verify rank numbers are correct
5. Verify wins and losses match detailed view
6. Verify points match detailed view

**Expected Results:**
- Format exactly matches: "Rank. Name - W/L - Points"
- Example: "3. John - 2W/1L - 32 pt"
- No extra spaces or missing separators
- All data accurate

### Scenario 3: Game History Dialog - Basic Display

**Setup:**
1. Have a tournament with at least 2 completed rounds
2. Navigate to Leaderboard screen (either view)

**Test Steps:**
1. Long press on any player card
2. Verify dialog appears with title "[Player Name] - Game History"
3. Verify each game entry shows:
   - Round number
   - Partner name
   - Opponents' names (formatted as "Name1 & Name2")
   - Score (formatted as "XX - YY")
   - Result (Won/Lost/Draw)
4. Verify result color coding:
   - Won: Green text
   - Lost: Red text
   - Draw: Grey text
5. Tap "Close" button
6. Verify dialog closes

**Expected Results:**
- Dialog appears on long press
- All matches player participated in are shown
- Information is accurate
- Color coding correct
- Dialog closes properly

### Scenario 4: Game History Dialog - Data Accuracy

**Setup:**
1. Tournament with known match results
2. Track which players were partners and opponents

**Test Steps:**
1. Open game history for a specific player
2. For each round shown:
   - Verify the partner is correct
   - Verify the opponents are correct
   - Verify the score matches the actual match result
   - Verify Won/Lost is correct based on the score
3. Check that rounds are listed in order
4. Verify no duplicate entries

**Expected Results:**
- Partner names match tournament records
- Opponent names match tournament records
- Scores accurate
- Won/Lost determination correct
- No missing or duplicate games

### Scenario 5: Game History - Edge Cases

**Setup:**
1. Test various edge cases

**Test Steps:**

**Case A: Player with no matches**
1. Add a player who was on break all rounds
2. Long press their card
3. Verify dialog shows "No games played yet."

**Case B: Player with only one match**
1. Find/create player with one match
2. Long press their card
3. Verify exactly one game shown

**Case C: Player who lost all matches**
1. Find player with 0 wins
2. Long press their card
3. Verify all results show "Lost" in red

**Case D: Match with tied score**
1. Create a match with equal scores (if allowed)
2. Long press participant's card
3. Verify result shows "Draw" in grey

**Expected Results:**
- Empty state message for players with no matches
- Correct display for any number of matches
- Accurate result determination in all cases

### Scenario 6: Both Views - Long Press

**Setup:**
1. Tournament with completed rounds

**Test Steps:**
1. In detailed view, long press on a player card
2. Verify game history dialog appears
3. Close dialog
4. Switch to compact view
5. Long press on the same player card
6. Verify game history dialog appears
7. Verify same information shown

**Expected Results:**
- Long press works in both views
- Same game history data shown regardless of view
- Dialog behavior consistent

### Scenario 7: Toggle Persistence Check

**Setup:**
1. Tournament with matches

**Test Steps:**
1. Switch to compact view
2. Navigate away from leaderboard
3. Return to leaderboard
4. Verify view state (may reset to detailed - check expected behavior)

**Expected Results:**
- Document actual behavior
- View state handling is consistent
- No crashes or errors

### Scenario 8: Visual Verification

**Setup:**
1. Tournament with 8+ players
2. Different ranks and statistics

**Test Steps:**
1. **Detailed View:**
   - Count how many players visible without scrolling
   - Verify top 3 have colored backgrounds
   - Verify layout is not broken

2. **Compact View:**
   - Count how many players visible without scrolling
   - Verify more players visible than detailed view
   - Verify top 3 have colored backgrounds
   - Verify text alignment is good
   - Verify no text overflow

**Expected Results:**
- Compact view shows significantly more players (5-6 vs 2-3)
- Both views visually appealing
- No layout issues
- Color coding works in both

## Performance Testing

### Test: Large Tournament

**Setup:**
1. Create tournament with 16+ players
2. Complete 5+ rounds

**Test Steps:**
1. Navigate to leaderboard
2. Toggle between views multiple times
3. Open game history for various players
4. Scroll through standings
5. Check for lag or stuttering

**Expected Results:**
- Smooth transitions
- No noticeable lag
- Game history opens quickly
- Scrolling smooth

## Regression Testing

**Test Steps:**
1. Verify existing features still work:
   - Export functionality
   - Position change indicators
   - Rank badges
   - Trophy icons for top 3
   - Statistical calculations (wins, losses, points)

**Expected Results:**
- All existing features work as before
- No regressions introduced

## Screenshot Checklist

Take screenshots of:
1. ✓ Detailed view with 4+ players
2. ✓ Compact view with same players
3. ✓ Toggle button in app bar (both states)
4. ✓ Game history dialog (player with multiple games)
5. ✓ Top 3 in compact view (showing color coding)
6. ✓ Long press interaction hint (if possible)

## Bug Report Template

If issues found, report with:
- Scenario being tested
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device/emulator info
- Flutter version

## Test Completion

- [ ] All scenarios tested
- [ ] Screenshots taken
- [ ] Performance verified
- [ ] Regression tests passed
- [ ] Any bugs documented
- [ ] Feature ready for review

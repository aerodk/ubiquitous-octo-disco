# Manual Testing Guide - Position Change Visual

## Purpose
This guide helps verify that the position change visual indicators work correctly.

## Prerequisites
- Flutter development environment set up
- Ability to run the app in Chrome or on a device

## Test Scenarios

### Scenario 1: Verify No Indicators Before Round 3

**Steps:**
1. Start a new tournament with 8+ players and 2 courts
2. Complete Round 1 with various scores
3. Navigate to Leaderboard
4. **Expected**: No position change indicators visible
5. Generate and complete Round 2
6. Navigate to Leaderboard again
7. **Expected**: Still no position change indicators

### Scenario 2: Verify Indicators Appear on Round 3

**Steps:**
1. Continue from Scenario 1 (with 2 completed rounds)
2. Generate and complete Round 3
3. Navigate to Leaderboard
4. **Expected**: All players now show position change indicators
5. Indicators should be one of:
   - Green `+N` (player improved rank)
   - Red `-N` (player declined rank)
   - Black `±0` (player maintained rank)

### Scenario 3: Verify Position Improvement (Green +N)

**Setup:**
1. Create tournament with known players
2. In Round 1-2: Give Player A low scores
3. In Round 3: Give Player A very high scores

**Expected Results:**
- Player A should have a worse rank after Round 2
- Player A should improve rank after Round 3
- Leaderboard should show green badge with positive number next to Player A
- Example: If moved from rank 6 to rank 2, should show green `+4`

### Scenario 4: Verify Position Decline (Red -N)

**Setup:**
1. Create tournament with known players
2. In Round 1-2: Give Player B high scores
3. In Round 3: Give Player B very low scores

**Expected Results:**
- Player B should have a good rank after Round 2
- Player B should decline in rank after Round 3
- Leaderboard should show red badge with negative number next to Player B
- Example: If moved from rank 2 to rank 6, should show red `-4`

### Scenario 5: Verify No Change (Black ±0)

**Setup:**
1. Create tournament where a player maintains exact same rank
2. This is tricky - may need to engineer scores carefully
3. Give multiple players identical statistics

**Expected Results:**
- Player maintaining position should show black badge with `±0`

### Scenario 6: Verify Bench/Lane View Display

**Steps:**
1. Create tournament with players who will be on pause
2. Complete 3+ rounds
3. Navigate to Round Display screen
4. Check the "På Bænken Denne Runde" (On Bench) section
5. **Expected**: Players on bench also show position change indicators
6. Styling should match leaderboard indicators

### Scenario 7: Verify Visual Styling

**Check on Leaderboard:**
- Green badge: `+` prefix, green text, green border, light green background
- Red badge: `-` number, red text, red border, light red background
- Black badge: `±0`, black text, black border, light gray background
- Badge should be visible but not overwhelming
- Badge should appear to the right of player name

**Check on Bench Section:**
- Same color scheme as leaderboard
- Slightly smaller to fit within player chip
- Should not overflow or break layout

### Scenario 8: Verify Top 3 Styling

**Steps:**
1. Complete 3+ rounds
2. Navigate to Leaderboard
3. Check top 3 players (gold, silver, bronze backgrounds)
4. **Expected**: Position change indicators should still be visible on colored backgrounds
5. Indicator styling should adapt to maintain readability

### Scenario 9: Verify Multiple Rounds

**Steps:**
1. Complete 5+ rounds
2. Check that position changes are always relative to previous round only
3. Round 4 should compare to Round 3
4. Round 5 should compare to Round 4
5. Not cumulative from Round 3

## Edge Cases to Test

### Edge Case 1: All Players Same Score
- If multiple players tie with exact same statistics
- They should share same rank
- Position change should still calculate correctly

### Edge Case 2: Player Always on Bench
- If a player is on bench in round 2 and round 3
- Their rank may still change due to pause points
- Indicator should reflect this

### Edge Case 3: Tournament Completion
- Complete the tournament (final round)
- Navigate to Tournament Completion screen
- Check if position indicators appear (or don't)
- Document behavior

## Visual Verification Checklist

- [ ] No indicators visible in Round 1
- [ ] No indicators visible in Round 2
- [ ] Indicators appear starting Round 3
- [ ] Green `+N` shows for rank improvements
- [ ] Red `-N` shows for rank declines
- [ ] Black `±0` shows for no change
- [ ] Indicators visible on Leaderboard screen
- [ ] Indicators visible on Bench section
- [ ] Styling works on top 3 colored backgrounds
- [ ] Styling works on regular white backgrounds
- [ ] Layout doesn't break with indicators
- [ ] Font size and weight are appropriate
- [ ] Colors match specification (green/red/black)

## Known Limitations

1. Position change only shows difference from previous round (not cumulative)
2. Only appears from Round 3 onwards (by design)
3. Requires at least 2 completed rounds to calculate previous rank

## Reporting Issues

When reporting issues, please include:
- Screenshot showing the problem
- Round number where issue occurred
- Expected vs actual indicator display
- Player rankings before and after
- Full tournament state (if possible)

## Success Criteria

✅ All visual indicators display correctly
✅ Colors match specification (green/red/black)
✅ Indicators appear from Round 3 onwards
✅ Numbers accurately reflect rank changes
✅ Layout remains intact with indicators
✅ Works on both Leaderboard and Bench views
✅ Unit tests pass

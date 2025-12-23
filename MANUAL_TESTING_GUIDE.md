# Manual Testing Guide - Lane Adjustment Feature

## Prerequisites
- Flutter 3.24.0 or later installed
- Dart SDK
- Device/emulator running

## Setup Instructions

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Create a test tournament:**
   - Add 12 players (Player 1 through Player 12)
   - Set to 3 courts (Bane 1, 2, 3)
   - Generate first round

## Test Case 1: Visual Emphasis for Newly Paused Players

### Steps:
1. Navigate to the round display screen
2. Verify that all 12 players are playing (3 courts × 4 players = 12 players)
3. Verify that the pause section is **NOT** shown (no players on break)
4. Click "Fjern bane" (Remove court) button
5. Confirm the removal in the dialog

### Expected Results:
- ✅ Round is regenerated with 2 courts
- ✅ 8 players are now playing (2 courts × 4 players)
- ✅ 4 players are now on pause
- ✅ The pause section appears with 4 players
- ✅ All 4 paused players have:
  - Orange background on their chips
  - Bold text for their names
  - 🔶 Icon next to their names

### Screenshot Locations:
- `screenshots/test1_before_removal.png` - Before removing court
- `screenshots/test1_after_removal.png` - After removing court (showing orange highlighted players)

## Test Case 2: Add Court Validation - Success

### Steps:
1. Start from Test Case 1 final state (2 courts, 4 players on pause)
2. Verify that "Tilføj bane" (Add court) button is **enabled**
3. Click "Tilføj bane" button
4. Confirm the addition in the dialog

### Expected Results:
- ✅ Button is enabled (not grayed out)
- ✅ Confirmation dialog appears
- ✅ After confirmation, round is regenerated with 3 courts
- ✅ All 12 players are playing again
- ✅ Pause section is hidden (no players on break)
- ✅ Orange highlighting is cleared

### Screenshot Locations:
- `screenshots/test2_button_enabled.png` - Button enabled state
- `screenshots/test2_after_addition.png` - After adding court

## Test Case 3: Add Court Validation - Failure

### Steps:
1. Create a tournament with 10 players and 2 courts
2. Generate first round
3. Verify 8 players are playing, 2 are on pause
4. Check the "Tilføj bane" button state

### Expected Results:
- ✅ Button is **disabled** (grayed out)
- ✅ Button cannot be clicked
- ✅ Tooltip/state indicates insufficient players

### Screenshot Locations:
- `screenshots/test3_button_disabled.png` - Button disabled with only 2 players on pause

## Test Case 4: Remove Court Multiple Times

### Steps:
1. Start with 12 players and 3 courts (all playing)
2. Remove 1 court → 4 players move to pause
3. Note which 4 players are highlighted
4. Remove another court → 4 more players move to pause

### Expected Results:
- ✅ After first removal: 4 players highlighted in orange
- ✅ After second removal: 4 new players highlighted in orange (8 total on pause)
- ✅ The first 4 players should now show **normal styling** (no longer highlighted)
- ✅ Only the most recently paused players have orange highlighting

### Screenshot Locations:
- `screenshots/test4_first_removal.png` - After first court removal
- `screenshots/test4_second_removal.png` - After second court removal

## Test Case 5: Manual Override Clears Highlighting

### Steps:
1. Start with newly paused players (from Test Case 1)
2. Verify 4 players are highlighted in orange
3. Click one of the orange-highlighted players to force them to play
4. Confirm the override

### Expected Results:
- ✅ Player is moved from pause to active (match regenerates)
- ✅ **All** orange highlighting is cleared
- ✅ All remaining paused players now show normal styling

### Screenshot Locations:
- `screenshots/test5_before_override.png` - Before manual override
- `screenshots/test5_after_override.png` - After override (highlighting cleared)

## Test Case 6: Edge Case - Maximum Courts

### Steps:
1. Check Constants.maxCourts value (likely 8)
2. Create tournament with enough players for max courts
3. Add courts until maximum is reached
4. Try to add one more court

### Expected Results:
- ✅ Button becomes disabled at max courts
- ✅ Error message: "Kan ikke tilføje flere end X baner"

### Screenshot Locations:
- `screenshots/test6_max_courts.png` - At maximum courts

## Test Case 7: Edge Case - Minimum Courts

### Steps:
1. Start with any tournament with >1 court
2. Remove courts until only 1 remains
3. Try to remove the last court

### Expected Results:
- ✅ "Fjern bane" button becomes disabled
- ✅ Error message: "Skal have mindst 1 bane"

### Screenshot Locations:
- `screenshots/test7_min_courts.png` - At minimum courts (1)

## Test Case 8: Score Entry Blocks Court Changes

### Steps:
1. Start with any tournament in progress
2. Enter a score for any match (e.g., Team 1: 24, Team 2: 18)
3. Try to add or remove a court

### Expected Results:
- ✅ Both "Tilføj bane" and "Fjern bane" buttons are disabled
- ✅ Clicking shows error: "Kan ikke ændre baner når der er indtastet score"

### Screenshot Locations:
- `screenshots/test8_scores_entered.png` - Buttons disabled after scoring

## Accessibility Testing

### Visual Checks:
1. **Color Contrast:**
   - ✅ Orange background is distinct from normal chips
   - ✅ Text remains readable on orange background
   - ✅ Icon is visible and recognizable

2. **Text Styling:**
   - ✅ Bold text is noticeably different from normal weight
   - ✅ Font size remains consistent

3. **Icon Clarity:**
   - ✅ 🔶 Icon is large enough to see (16px)
   - ✅ Icon color (deepOrange) contrasts with orange background

### Screenshot Locations:
- `screenshots/accessibility_contrast.png` - Color contrast check

## Performance Testing

### Check for:
- ✅ No lag when removing/adding courts
- ✅ Smooth transitions
- ✅ No memory leaks (monitor with Flutter DevTools)
- ✅ State updates correctly and consistently

## Regression Testing

Verify existing functionality still works:
1. ✅ Score entry still works
2. ✅ Next round generation works
3. ✅ Leaderboard still displays correctly
4. ✅ Tournament persistence (save/load) works
5. ✅ Final round generation works

## Test Results Template

Copy this template for each test:

```
Test Case: [Number and Name]
Tester: [Your Name]
Date: [YYYY-MM-DD]
Platform: [iOS/Android/Web]
Flutter Version: [e.g., 3.24.0]

Steps Executed:
[ ] Step 1
[ ] Step 2
[ ] Step 3

Results:
[ ] PASS - All expected results matched
[ ] FAIL - See notes below

Notes/Issues:
[Any deviations, bugs, or observations]

Screenshots:
[List screenshot files]
```

## Automated Test Verification

Before manual testing, run automated tests:

```bash
# Run all tests
flutter test

# Run only lane adjustment tests
flutter test test/lane_adjustment_test.dart

# Run with coverage
flutter test --coverage
```

Expected output:
```
✓ Lane Adjustment Tests Add court button is enabled when 4+ players on pause
✓ Lane Adjustment Tests Add court button is disabled when less than 4 players on pause  
✓ Lane Adjustment Tests Newly paused players are visually emphasized
✓ Lane Adjustment Tests Pause section displays players on break

All tests passed!
```

## Reporting Issues

If you find any issues during testing:

1. **Create a bug report** with:
   - Test case number
   - Expected vs. actual behavior
   - Screenshots
   - Device/platform details
   - Steps to reproduce

2. **Check for edge cases** not covered in tests

3. **Suggest improvements** to UX or functionality

## Success Criteria

All test cases must pass with:
- ✅ No crashes or errors
- ✅ Expected visual styling appears correctly
- ✅ Validation logic works as specified
- ✅ No regression in existing features
- ✅ Good performance (no lag)
- ✅ Accessibility standards met

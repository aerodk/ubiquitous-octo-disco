# Manual Testing Guide - Version 8.0 Firebase Integration

This guide provides step-by-step instructions for manually testing the Firebase cloud storage features.

## Prerequisites

1. Firebase project must be configured with valid credentials
2. GitHub Secrets must be set up (see FIREBASE_SETUP.md)
3. App must be deployed to a web environment (GitHub Pages or local flutter run)
4. Internet connection required for Firebase operations

## Test Scenarios

### Test 1: Save New Tournament to Cloud

**Objective**: Verify that a tournament can be saved to Firebase with generated codes

**Steps**:
1. Navigate to Setup Screen
2. Add at least 4 players (e.g., "Alice", "Bob", "Charlie", "David")
3. Set court count to 1
4. Click "Generer Første Runde"
5. In RoundDisplayScreen, click the cloud upload icon (☁️) in the AppBar
6. In the SaveTournamentDialog:
   - Verify default tournament name is "Padel Turnering"
   - Change name if desired (e.g., "Test Tournament 1")
   - Click "Generer Kode"
7. Wait for loading to complete
8. Verify success dialog shows:
   - 8-digit tournament code (e.g., "12345678")
   - 6-digit passcode (e.g., "654321")
   - Warning message to write codes down
   - Copy buttons for both codes
9. Click "Kopiér Begge" and verify both codes are copied to clipboard
10. Write down the codes for next test
11. Click "Færdig"
12. Verify tooltip on cloud icon now shows the tournament code

**Expected Results**:
- ✅ Dialog opens without errors
- ✅ Codes are generated successfully
- ✅ Data is saved to Firebase Firestore
- ✅ Success message displays with codes
- ✅ Copy to clipboard works
- ✅ Cloud icon tooltip updates with code

**Error Scenarios to Test**:
- No tournament name entered → Should show error "Indtast venligst et turnerings navn"
- No internet connection → Should show Firebase unavailable error

---

### Test 2: Load Tournament from Cloud

**Objective**: Verify that a saved tournament can be loaded using codes

**Steps**:
1. Clear browser cache or open in incognito/private window
2. Navigate to Setup Screen
3. Click cloud download icon (☁️⬇️) in AppBar
4. In LoadTournamentDialog:
   - Enter the 8-digit tournament code from Test 1
   - Enter the 6-digit passcode from Test 1
   - Click "Hent"
5. Wait for loading to complete
6. Verify app navigates to RoundDisplayScreen
7. Verify tournament data is loaded:
   - Correct player names
   - Correct number of courts
   - Matches are displayed
   - Round number is shown
8. Verify cloud icon tooltip shows the tournament code

**Expected Results**:
- ✅ Dialog opens without errors
- ✅ Input fields only accept numeric characters
- ✅ Tournament loads successfully from Firebase
- ✅ All data is correctly restored
- ✅ Navigation to RoundDisplayScreen occurs
- ✅ Cloud icon shows tournament is linked to cloud

**Error Scenarios to Test**:
- Wrong tournament code → "Turnering ikke fundet"
- Wrong passcode → "Forkert adgangskode"
- Code too short/long → Validation error
- Non-numeric input → Should be prevented by input filter
- No internet connection → "Netværksfejl"

---

### Test 3: Update Existing Tournament

**Objective**: Verify that changes to a loaded tournament can be saved back to cloud

**Steps**:
1. Continue from Test 2 with loaded tournament
2. Enter scores for some matches
3. Click cloud upload icon (☁️) in AppBar
4. In SaveTournamentDialog:
   - Verify title shows "Opdater Turnering i Cloud"
   - Verify existing tournament code is displayed
   - Change tournament name if desired
   - Click "Opdater"
5. Wait for loading to complete
6. Verify success dialog shows:
   - Same tournament code as before
   - Same passcode as before
   - Success message
7. Click "Færdig"
8. Open in new browser window/tab
9. Load tournament using same codes (Test 2 steps)
10. Verify updated scores are loaded

**Expected Results**:
- ✅ Update flow uses same codes
- ✅ Tournament data updates in Firebase
- ✅ Changes persist across sessions
- ✅ No new codes are generated

---

### Test 4: Save from Tournament Completion Screen

**Objective**: Verify tournament can be saved after completion

**Steps**:
1. Start a new tournament with 4 players
2. Complete all matches in first round
3. Generate at least 3 more rounds and complete them
4. Start final round and complete all matches
5. Tournament Completion Screen should appear
6. Click "Gem i Cloud" button (blue button on left)
7. Enter tournament name
8. Click "Generer Kode"
9. Note the codes
10. Click "Færdig"
11. Click "Start Ny Turnering"
12. Load the saved tournament (Test 2 steps)
13. Verify completed tournament loads correctly
14. Verify isCompleted flag is true (tournament shows as completed)

**Expected Results**:
- ✅ Save button is visible on completion screen
- ✅ Tournament saves with isCompleted: true
- ✅ All final standings are preserved
- ✅ Statistics are preserved

---

### Test 5: Cross-Device Access

**Objective**: Verify tournament can be accessed from different devices

**Steps**:
1. On Device A (e.g., desktop browser):
   - Create and save a tournament (Test 1)
   - Note the codes
2. On Device B (e.g., mobile browser or different computer):
   - Navigate to the app
   - Load tournament using codes (Test 2)
   - Verify all data loads correctly
3. On Device B:
   - Make changes (enter scores)
   - Update tournament to cloud
4. On Device A:
   - Refresh or reload app
   - Load tournament again
   - Verify changes from Device B are present

**Expected Results**:
- ✅ Tournament accessible from any device with codes
- ✅ Updates sync across devices via manual load
- ✅ Data consistency maintained

---

### Test 6: Offline Behavior

**Objective**: Verify graceful handling when Firebase is unavailable

**Steps**:
1. Disconnect from internet or block Firebase URLs
2. Try to save tournament to cloud
3. Verify error message: "Firebase er ikke tilgængelig"
4. Try to load tournament from cloud
5. Verify error message: "Netværksfejl" or similar
6. Reconnect to internet
7. Retry save/load operations
8. Verify they work correctly

**Expected Results**:
- ✅ Clear error messages when offline
- ✅ App doesn't crash
- ✅ User can continue using local features
- ✅ Retry works after reconnecting

---

### Test 7: UI/UX Validation

**Objective**: Verify user interface elements work correctly

**Steps**:
1. Check all dialogs:
   - Verify loading spinners appear during operations
   - Verify success/error messages are clear
   - Verify buttons are disabled during loading
   - Verify dialog can be cancelled
2. Check cloud icons:
   - Setup Screen: Download icon present
   - RoundDisplayScreen: Upload icon present with tooltip
   - Completion Screen: Save button present and styled correctly
3. Test clipboard functionality:
   - Copy individual codes
   - Copy both codes together
   - Verify SnackBar confirmation appears
4. Test input validation:
   - Tournament code field: 8 digits only
   - Passcode field: 6 digits only
   - Numeric keyboard on mobile
   - Max length enforcement

**Expected Results**:
- ✅ All UI elements render correctly
- ✅ Loading states are clear
- ✅ Icons and buttons are accessible
- ✅ Validation works as specified
- ✅ Consistent with V7 design language

---

### Test 8: Edge Cases

**Objective**: Test boundary conditions and edge cases

**Test Cases**:

1. **Very long tournament name**:
   - Enter 100+ character name
   - Verify it saves and loads correctly

2. **Special characters in name**:
   - Use emojis, accented characters (æ, ø, å)
   - Verify they are preserved

3. **Large tournament**:
   - Create tournament with 20+ players
   - Multiple rounds with scores
   - Save and load
   - Verify performance is acceptable

4. **Rapid save/update**:
   - Save tournament
   - Immediately update
   - Update again quickly
   - Verify all updates succeed

5. **Code uniqueness**:
   - Generate multiple tournament codes
   - Verify they are all unique

**Expected Results**:
- ✅ Edge cases handled gracefully
- ✅ No data loss
- ✅ Reasonable performance

---

## Checklist for Complete Testing

Before marking V8.0 as complete, verify:

- [ ] All 8 test scenarios pass
- [ ] No console errors in browser DevTools
- [ ] Firebase Firestore shows tournaments collection with data
- [ ] Passcodes are hashed (not stored in plain text)
- [ ] Tournament codes are 8 digits
- [ ] Passcodes are 6 digits
- [ ] UI is responsive on mobile and desktop
- [ ] Error messages are user-friendly (Danish)
- [ ] Copy to clipboard works on all browsers tested
- [ ] Cloud icons display correctly
- [ ] Loading states are clear
- [ ] Offline behavior is graceful

---

## Browser Testing Matrix

Test on these browsers to ensure compatibility:

- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest) - if available
- [ ] Edge (latest)
- [ ] Mobile Chrome (Android)
- [ ] Mobile Safari (iOS) - if available

---

## Debugging Tips

### Firebase Connection Issues

1. Check browser console for errors
2. Verify Firebase config is correct in GitHub Secrets
3. Check Firestore security rules allow anonymous access
4. Verify network tab shows requests to Firebase

### Tournament Not Found

1. Verify code is exactly 8 digits
2. Check Firestore console for tournaments collection
3. Verify document with that code exists

### Passcode Issues

1. Passcode must match exactly (case-sensitive hashing)
2. Check stored hash in Firestore matches SHA-256 of input
3. Verify no extra spaces in input

---

## Reporting Issues

When reporting issues, include:

1. Browser and version
2. Device type (desktop/mobile)
3. Steps to reproduce
4. Expected vs actual behavior
5. Screenshot if UI-related
6. Browser console errors
7. Tournament code (if safe to share)

---

*Last updated: Version 8.0 Implementation - December 2024*

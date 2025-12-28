# Share Link Feature - Manual Testing Guide

## Prerequisites
- Tournament saved to Firebase cloud with code and passcode
- Access to browser (preferably Chrome for web deployment)
- Two devices or browser windows for testing sharing

## Test Scenarios

### Test 1: Share Link Generation (View-Only)
**Goal:** Verify link generation without passcode

**Steps:**
1. Open tournament in RoundDisplayScreen
2. Ensure tournament is saved to cloud (check for cloud code in tooltip)
3. Click share button (📤 icon in AppBar)
4. Select "Kun Visning" radio button
5. Verify link is displayed without `?p=` parameter
6. Click "Kopiér Link" button
7. Verify success message appears
8. Paste link in text editor to verify it copied

**Expected Result:**
- Link format: `https://aerodk.github.io/ubiquitous-octo-disco/#/tournament/12345678`
- No passcode in URL
- Success message shown
- Link copied to clipboard

---

### Test 2: Share Link Generation (With Passcode)
**Goal:** Verify link generation with passcode

**Steps:**
1. Open tournament in RoundDisplayScreen
2. Click share button
3. Select "Med Adgangskode (Kun Visning)" radio button
4. Verify link includes `?p=` parameter with 6-digit passcode
5. Click "Kopiér Link"
6. Verify link copied successfully

**Expected Result:**
- Link format: `https://aerodk.github.io/ubiquitous-octo-disco/#/tournament/12345678?p=123456`
- Passcode visible in URL
- Link copied successfully

---

### Test 3: Share Button Visibility
**Goal:** Verify share button only appears when appropriate

**Steps:**
1. Create new tournament (not saved to cloud)
2. Verify NO share button in AppBar
3. Save tournament to cloud
4. Verify share button NOW appears
5. Navigate to TournamentCompletionScreen
6. Verify share button appears there too
7. Open tournament via share link (read-only)
8. Verify share button does NOT appear (read-only mode)

**Expected Result:**
- Share button only visible when:
  - Tournament is saved to cloud
  - NOT in read-only mode

---

### Test 4: Access View-Only Link
**Goal:** Verify read-only access via link without passcode

**Steps:**
1. Generate view-only share link (Test 1)
2. Open link in new browser window/incognito
3. Verify tournament loads
4. Check for "Kun Visning" indicator in title
5. Try to click on a score to edit
6. Verify score dialog does NOT open
7. Check that round generation buttons are hidden
8. Verify cloud save button is hidden
9. Verify leaderboard is accessible
10. Verify export functionality works

**Expected Result:**
- Tournament data visible
- "Kun Visning" shown in AppBar
- All editing functions disabled
- Viewing functions still work

---

### Test 5: Access Link with Passcode
**Goal:** Verify access via link with embedded passcode

**Steps:**
1. Generate share link with passcode (Test 2)
2. Open link in new browser window
3. Verify tournament loads WITHOUT asking for passcode
4. Verify still in read-only mode
5. Verify "Kun Visning" indicator shown

**Expected Result:**
- Automatic loading without passcode prompt
- Read-only mode enforced
- All data visible

---

### Test 6: Invalid Link Handling
**Goal:** Verify error handling for invalid links

**Steps:**
1. Open URL with invalid tournament code: `/#/tournament/invalid`
2. Verify error message shown
3. Verify app navigates to SetupScreen
4. Open URL with wrong length code: `/#/tournament/123`
5. Verify graceful handling

**Expected Result:**
- Clear error messages
- App doesn't crash
- Fallback to SetupScreen

---

### Test 7: Read-Only Mode Restrictions
**Goal:** Thoroughly test all restrictions in read-only mode

**Steps:**
1. Open tournament via view-only link
2. Try to:
   - Click score input → Should be disabled
   - Click "Næste Runde" → Button should not exist
   - Click "Sidste Runde" → Button should not exist
   - Click player override (long press) → Should be disabled
   - Click cloud save → Button should not exist
   - Navigate to leaderboard → Should work
   - Export results → Should work
   - Zoom in/out → Should work

**Expected Result:**
- All edit functions: DISABLED
- All view functions: ENABLED
- Clear visual indicators of read-only status

---

### Test 8: Share from Completion Screen
**Goal:** Verify sharing works from completed tournament

**Steps:**
1. Complete a tournament (reach final round and complete all matches)
2. In TournamentCompletionScreen, click share button
3. Verify share dialog opens
4. Generate and copy link
5. Open link in new window
6. Verify completion screen shown in read-only mode

**Expected Result:**
- Share button visible in completion screen
- Generated link opens completion screen
- Read-only mode enforced
- Export and view functions work

---

### Test 9: Share Button Before Cloud Save
**Goal:** Verify helpful message when trying to share unsaved tournament

**Steps:**
1. Create tournament (not saved to cloud)
2. Try to click share button (if visible)
   - OR verify share button is hidden
3. Save to cloud
4. Verify share button becomes available

**Expected Result:**
- Share button hidden OR shows message to save first
- After saving, share button appears

---

### Test 10: URL Parsing Edge Cases
**Goal:** Test URL parsing with various formats

**Test URLs:**
```
1. https://example.com/#/tournament/12345678
2. https://example.com/#/tournament/00000001 (leading zeros)
3. https://example.com/?foo=bar#/tournament/12345678?p=123456
4. https://example.com/some/path#/tournament/12345678
```

**Steps:**
1. For each URL, manually construct and navigate to it
2. Verify tournament loads correctly
3. Verify leading zeros preserved
4. Verify query parameters don't interfere

**Expected Result:**
- All valid formats parse correctly
- Tournament loads in each case
- Extra parameters ignored

---

## Test Results Template

| Test # | Test Name | Status | Notes | Tester | Date |
|--------|-----------|--------|-------|--------|------|
| 1 | Share Link Generation (View-Only) | ⬜ Pass ⬜ Fail | | | |
| 2 | Share Link Generation (With Passcode) | ⬜ Pass ⬜ Fail | | | |
| 3 | Share Button Visibility | ⬜ Pass ⬜ Fail | | | |
| 4 | Access View-Only Link | ⬜ Pass ⬜ Fail | | | |
| 5 | Access Link with Passcode | ⬜ Pass ⬜ Fail | | | |
| 6 | Invalid Link Handling | ⬜ Pass ⬜ Fail | | | |
| 7 | Read-Only Mode Restrictions | ⬜ Pass ⬜ Fail | | | |
| 8 | Share from Completion Screen | ⬜ Pass ⬜ Fail | | | |
| 9 | Share Button Before Cloud Save | ⬜ Pass ⬜ Fail | | | |
| 10 | URL Parsing Edge Cases | ⬜ Pass ⬜ Fail | | | |

## Known Issues / Limitations

1. Share links only work after tournament is saved to cloud
2. Read-only mode is always enforced for shared links (even with passcode)
3. Mobile app deep linking not yet supported (web only)
4. Share analytics not implemented

## Browser Compatibility

Test on:
- ✅ Chrome/Edge (primary target)
- ✅ Firefox
- ✅ Safari
- ✅ Mobile browsers (iOS Safari, Chrome Android)

## Performance Metrics

Monitor:
- Time to generate link: < 100ms
- Time to parse URL: < 10ms
- Time to load shared tournament: ~same as regular load
- App startup delay: < 50ms additional

## Security Checklist

- ✅ Passcodes hashed in Firestore
- ✅ View-only links don't expose passcode
- ✅ Read-only mode enforced client-side
- ⬜ Firebase security rules enforce read-only (verify server-side)
- ✅ No sensitive data in URLs (only code/passcode)

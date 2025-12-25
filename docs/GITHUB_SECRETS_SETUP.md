# GitHub Secrets Configuration for Firebase

This guide explains how to configure GitHub secrets for Firebase deployment via GitHub Actions.

## Overview

The Padel Tournament App uses Firebase for cloud storage. To deploy the app via GitHub Actions, you need to configure Firebase credentials as GitHub repository secrets. This keeps your Firebase configuration secure and allows automated deployments.

---

## Prerequisites

- Firebase project created and configured (see `FIREBASE_SETUP.md`)
- Firebase web app registered
- Firebase configuration object from Firebase Console
- Repository admin access to configure secrets

---

## Step 1: Get Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (e.g., `padel-tournament-app`)
3. Click the gear icon (⚙️) → **Project Settings**
4. Scroll down to **Your apps** section
5. Find your web app
6. Click the **Config** radio button
7. You'll see the Firebase configuration object:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890"
};
```

**Copy all these values** - you'll need them for the next step.

---

## Step 2: Add Secrets to GitHub Repository

### Navigate to Repository Secrets

1. Go to your GitHub repository: `https://github.com/aerodk/ubiquitous-octo-disco`
2. Click **Settings** tab
3. In the left sidebar, expand **Secrets and variables** → Click **Actions**
4. Click **New repository secret** button

### Add Each Firebase Secret

Add the following secrets one by one. For each secret:
1. Click **New repository secret**
2. Enter the **Name** (exactly as shown below)
3. Enter the **Value** (from your Firebase config)
4. Click **Add secret**

#### Required Secrets:

| Secret Name | Value from Firebase Config | Example |
|-------------|---------------------------|---------|
| `FIREBASE_API_KEY` | `apiKey` | `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` |
| `FIREBASE_AUTH_DOMAIN` | `authDomain` | `your-project.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | `projectId` | `your-project-id` |
| `FIREBASE_STORAGE_BUCKET` | `storageBucket` | `your-project.appspot.com` |
| `FIREBASE_MESSAGING_SENDER_ID` | `messagingSenderId` | `123456789012` |
| `FIREBASE_APP_ID` | `appId` | `1:123456789012:web:abcdef1234567890` |

### Visual Guide:

```
GitHub Repository → Settings
  ↓
Secrets and variables → Actions
  ↓
New repository secret
  ↓
Name: FIREBASE_API_KEY
Value: AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ↓
Add secret
```

**Repeat for all 6 secrets.**

---

## Step 3: Verify Secrets Are Added

After adding all secrets, you should see:

```
Repository secrets (6)
├─ FIREBASE_API_KEY
├─ FIREBASE_AUTH_DOMAIN
├─ FIREBASE_PROJECT_ID
├─ FIREBASE_STORAGE_BUCKET
├─ FIREBASE_MESSAGING_SENDER_ID
└─ FIREBASE_APP_ID
```

**Note:** You can update secrets anytime, but you cannot view the values after they're saved.

---

## Step 4: Test the Deployment

### Trigger Manual Deployment

1. Go to **Actions** tab in your repository
2. Select **Deploy to GitHub Pages** workflow
3. Click **Run workflow**
4. Select branch: `main` (or your deployment branch)
5. Click **Run workflow** button

### Monitor the Build

1. Click on the running workflow
2. Click on the **build** job
3. Watch the **Build Flutter web app** step
4. It should pass without errors if secrets are configured correctly

### Verify Deployment

1. Once deployment completes, visit: `https://aerodk.github.io/ubiquitous-octo-disco/`
2. Open browser developer console (F12)
3. Look for Firebase initialization messages
4. App should load without Firebase errors

---

## Troubleshooting

### Common Issues

**1. Build fails with "Invalid Firebase configuration"**

**Cause:** Secrets not configured or have wrong values

**Solution:**
- Verify all 6 secrets are added
- Double-check values against Firebase Console
- Ensure no extra spaces in secret values
- Re-add the secret if needed

**2. Firebase initialization fails in deployed app**

**Cause:** Environment variables not passed to Flutter build

**Solution:**
- Check that workflow files have `--dart-define` flags
- Verify secrets are correctly referenced in workflow: `${{ secrets.SECRET_NAME }}`
- Check workflow logs for environment variable values (they'll be masked as ***)

**3. Secrets are added but still not working**

**Cause:** Workflow not updated or cache issues

**Solution:**
- Ensure workflow files are updated with Firebase environment variables
- Clear GitHub Actions cache
- Re-run the workflow

**4. "Permission denied" or Firestore errors**

**Cause:** Firestore security rules not configured

**Solution:**
- Follow `FIREBASE_SETUP.md` to configure Firestore rules
- Verify rules allow anonymous access
- Publish the rules in Firebase Console

---

## Local Development (Optional)

For local development with Firebase, you can:

### Option 1: Use a `.env` file (not committed to git)

1. Create `.env` file in project root:
```
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdef1234567890
```

2. Add to `.gitignore`:
```
.env
```

3. Run with environment variables:
```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  # ... etc
```

### Option 2: Hardcode temporarily (for testing only)

Edit `lib/firebase_options.dart` and replace environment variables with actual values:

```dart
static FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',  // Replace
  authDomain: 'your-project.firebaseapp.com',     // Replace
  // ... etc
);
```

⚠️ **WARNING:** Never commit hardcoded credentials to git!

---

## Security Best Practices

### ✅ DO:
- Use GitHub repository secrets for Firebase config
- Keep Firebase API keys in secrets, not in code
- Use Firestore security rules to protect data
- Rotate API keys if they're exposed

### ❌ DON'T:
- Commit Firebase config to git
- Share secrets in issues or pull requests
- Use production Firebase config for testing
- Expose secrets in logs or error messages

---

## Updating Secrets

To update a secret:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click on the secret name
3. Click **Update secret**
4. Enter new value
5. Click **Update secret**
6. Re-run failed workflows if needed

---

## Multiple Environments (Optional)

For separate test/production environments:

### Option 1: Use different secrets for test deployments

Add test-specific secrets:
- `FIREBASE_TEST_API_KEY`
- `FIREBASE_TEST_AUTH_DOMAIN`
- etc.

Update `deploy-test.yml` to use test secrets.

### Option 2: Use GitHub Environments

1. Go to **Settings** → **Environments**
2. Create `production` and `test` environments
3. Add environment-specific secrets
4. Update workflows to use environment contexts

---

## Quick Reference

### Copy-Paste Template for Secrets

From Firebase Console config, map to GitHub secrets:

```
apiKey           → FIREBASE_API_KEY
authDomain       → FIREBASE_AUTH_DOMAIN
projectId        → FIREBASE_PROJECT_ID
storageBucket    → FIREBASE_STORAGE_BUCKET
messagingSenderId → FIREBASE_MESSAGING_SENDER_ID
appId            → FIREBASE_APP_ID
```

### Workflow Files Using Secrets

- `.github/workflows/deploy-pages.yml` - Production deployment
- `.github/workflows/deploy-test.yml` - Test deployment

Both files use the same secrets by default.

---

## Need Help?

- Firebase Console: https://console.firebase.google.com/
- GitHub Secrets Docs: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- Firebase Setup Guide: `docs/FIREBASE_SETUP.md`
- V8 Specification: `docs/SPECIFICATION_v8.md`

---

*Last updated: Version 8.0 - December 2024*

# Firebase Setup Guide for Padel Tournament App

This guide provides step-by-step instructions for setting up Firebase for the Padel Tournament App (Version 8.0).

---

## Overview

You will need to:
1. Create a Firebase project
2. Register your web app (and optionally mobile apps)
3. Enable Firestore database
4. Configure security rules
5. Obtain configuration files
6. Add configuration to the Flutter app

---

## Part 1: Create Firebase Project

### Option A: Using Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project details:
   - **Project name**: `padel-tournament-app` (or your preferred name)
   - Click "Continue"
4. **Google Analytics**: You can disable it for now (optional for tournaments)
   - Toggle off "Enable Google Analytics for this project"
   - Click "Create project"
5. Wait for project creation to complete
6. Click "Continue" to go to project overview

### Option B: Using Gemini in Firebase Console

If you prefer to use Gemini AI assistant in Firebase Console:

1. Navigate to [Firebase Console](https://console.firebase.google.com/)
2. Look for Gemini/AI assistant icon
3. Ask: "Create a new Firebase project named padel-tournament-app with Firestore database enabled"
4. Follow the AI assistant's guidance

---

## Part 2: Register Web App

### Manual Steps:

1. In Firebase Console, click the **Web icon** (`</>`) to add a web app
2. Register app:
   - **App nickname**: `Padel Tournament Web`
   - ✅ Check "Also set up Firebase Hosting" (if you want to use Firebase Hosting)
   - Click "Register app"
3. **Add Firebase SDK**:
   - You'll see Firebase configuration object like this:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "padel-tournament-app.firebaseapp.com",
     projectId: "padel-tournament-app",
     storageBucket: "padel-tournament-app.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abcdef"
   };
   ```
   - **IMPORTANT**: Copy this configuration - you'll need it later
   - Click "Continue to console"

### Using Gemini:

Ask: "Register a web app called 'Padel Tournament Web' in my Firebase project and show me the configuration"

---

## Part 3: Enable Firestore Database

### Manual Steps:

1. In Firebase Console sidebar, click **"Firestore Database"**
2. Click **"Create database"**
3. **Security rules**: Select **"Start in production mode"**
   - We'll configure custom rules in the next step
   - Click "Next"
4. **Cloud Firestore location**: Choose location closest to your users
   - Europe: `eur3 (europe-west)`
   - US: `us-central`
   - Click "Enable"
5. Wait for database provisioning (usually takes 1-2 minutes)

### Using Gemini:

Ask: "Create a Firestore database in production mode with location europe-west"

---

## Part 4: Configure Firestore Security Rules

### Manual Steps:

1. In Firestore Database page, click **"Rules"** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Tournament collection
    match /tournaments/{tournamentCode} {
      // Allow anonymous read and write
      // Note: Client-side handles passcode validation
      // For production, consider using Cloud Functions for server-side validation
      allow read, write: if request.auth == null || request.auth != null;
      
      // Optionally, add rate limiting in production
      // allow write: if request.time > resource.data.lastWrite + duration.value(1, 's');
    }
    
    // Deny all other collections by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **"Publish"**
4. Confirm the rules update

### Using Gemini:

Ask: "Update Firestore security rules to allow anonymous read and write access to the tournaments collection"

---

## Part 5: Download Configuration Files

### For Web App:

1. Go to **Project Settings** (gear icon in sidebar)
2. Scroll down to **"Your apps"** section
3. Find your web app
4. Click on the config radio button
5. Copy the `firebaseConfig` object

**Save this configuration** - you'll add it to your Flutter web app.

### For Android App (Optional - if deploying to Android):

1. In Project Settings → Your apps
2. Click **Android icon** to add Android app
3. Register app:
   - **Android package name**: `com.example.star_cano` (or your package name)
   - **App nickname**: `Padel Tournament Android`
   - Click "Register app"
4. **Download `google-services.json`**
5. Place this file in `android/app/` directory

### For iOS App (Optional - if deploying to iOS):

1. In Project Settings → Your apps
2. Click **iOS icon** to add iOS app
3. Register app:
   - **iOS bundle ID**: `com.example.starCano` (or your bundle ID)
   - **App nickname**: `Padel Tournament iOS`
   - Click "Register app"
4. **Download `GoogleService-Info.plist`**
5. Place this file in `ios/Runner/` directory

---

## Part 6: Configure Flutter App

### Step 1: Add Firebase Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  crypto: ^3.0.3  # For passcode hashing
```

Run:
```bash
flutter pub get
```

### Step 2: Create Firebase Configuration File

Create `lib/firebase_options.dart`:

```dart
// File generated from Firebase Console configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration (from Firebase Console)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',  // Replace with your values
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    appId: 'YOUR_APP_ID',
  );

  // Android configuration (optional)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // iOS configuration (optional)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.starCano',
  );
}
```

**IMPORTANT**: Replace all `YOUR_*` placeholders with actual values from Firebase Console.

### Step 3: Initialize Firebase in Main

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

---

## Part 7: Test Firebase Connection

Create a simple test to verify Firebase is working:

```dart
// Add this to a test file or temporary screen
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebaseConnection() async {
  try {
    // Try to write a test document
    await FirebaseFirestore.instance
        .collection('test')
        .doc('connection_test')
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'Firebase is connected!',
    });
    
    print('✅ Firebase connection successful!');
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}
```

---

## Part 8: Enable Indexes (Optional but Recommended)

For better query performance:

1. Go to **Firestore Database** → **Indexes** tab
2. Create composite index:
   - **Collection**: `tournaments`
   - **Fields**: 
     - `createdAt` (Descending)
     - `tournamentCode` (Ascending)
   - Click "Create index"

### Using Gemini:

Ask: "Create a Firestore composite index on the tournaments collection for createdAt descending and tournamentCode ascending"

---

## Verification Checklist

Before proceeding with app development, verify:

- [ ] Firebase project created
- [ ] Web app registered in Firebase Console
- [ ] Firestore database enabled and running
- [ ] Security rules configured and published
- [ ] Firebase configuration copied from Console
- [ ] `firebase_core` and `cloud_firestore` dependencies added to `pubspec.yaml`
- [ ] `lib/firebase_options.dart` created with your configuration
- [ ] `main.dart` updated to initialize Firebase
- [ ] Test connection successful

---

## Troubleshooting

### Common Issues:

**1. "Firebase not initialized" error**
- Make sure `Firebase.initializeApp()` is called before `runApp()`
- Check that `WidgetsFlutterBinding.ensureInitialized()` is called first

**2. "Permission denied" in Firestore**
- Verify security rules are published
- Check that rules allow anonymous access
- Clear browser cache and retry

**3. Configuration errors**
- Double-check all values in `firebase_options.dart`
- Ensure no typos in API keys or project IDs
- Verify you're using the config for the correct platform (web/android/ios)

**4. Build errors for web**
- Run `flutter clean` and `flutter pub get`
- Check that Firebase SDK scripts are included (FlutterFire handles this automatically)

### Getting Help:

- Firebase Documentation: https://firebase.google.com/docs/flutter/setup
- FlutterFire Documentation: https://firebase.flutter.dev/
- Firebase Console: https://console.firebase.google.com/

---

## Security Considerations

### Important Notes:

1. **Passcode Validation**: Currently done client-side. For production, consider:
   - Using Firebase Cloud Functions for server-side passcode validation
   - Implementing rate limiting to prevent brute force attacks

2. **API Key Exposure**: The Firebase API key in `firebase_options.dart` will be visible in web builds
   - This is normal and expected for Firebase
   - Security is enforced by Firestore security rules, not the API key
   - API key restrictions can be set in Google Cloud Console

3. **Data Privacy**: 
   - Tournament data is accessible with code + passcode
   - Consider adding data retention policies
   - Inform users about data storage

---

## Next Steps

After completing this setup:

1. ✅ Firebase is ready to use
2. → Proceed with implementing FirebaseService in the app
3. → Implement save/load tournament functionality
4. → Test with real tournament data

For implementation details, see `docs/SPECIFICATION_v8.md`.

---

## Quick Reference: Gemini Prompts for Firebase Console

If using Gemini AI assistant in Firebase Console, here are useful prompts:

1. **Create project**: "Create a new Firebase project for a tournament management app"
2. **Add Firestore**: "Enable Firestore database in production mode"
3. **Security rules**: "Set Firestore rules to allow anonymous read/write to tournaments collection"
4. **Register web app**: "Register a web application and provide the configuration"
5. **Create indexes**: "Create a composite index for tournaments collection on createdAt and tournamentCode"

---

*Last updated: Version 8.0 - December 2024*

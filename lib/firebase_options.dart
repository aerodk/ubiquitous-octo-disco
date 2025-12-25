// Firebase configuration file
// This file uses environment variables for Firebase configuration
// to support GitHub Actions deployment with secrets

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

  // Web configuration
  // Values are injected via --dart-define during build
  static FirebaseOptions web = FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: '',
    ),
    authDomain: const String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: '',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: '',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '',
    ),
  );

  // Android configuration (optional - for future mobile deployment)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: ''),
  );

  // iOS configuration (optional - for future mobile deployment)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: ''),
    iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID', defaultValue: 'com.example.starCano'),
  );
}

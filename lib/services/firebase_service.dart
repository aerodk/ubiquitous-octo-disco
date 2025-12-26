import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/tournament.dart';
import '../firebase_options.dart';

/// Service for managing tournament data in Firebase Firestore
/// 
/// Features:
/// - Generate unique 8-digit tournament codes
/// - Generate 6-digit numeric passcodes
/// - Save/load tournaments to/from Firestore
/// - Passcode-based authentication
/// - Environment-based collection names (test vs production)
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random.secure();

  /// Get collection name based on environment
  /// - Production: 'tournaments'
  /// - Test: 'tournaments_test'
  /// Set via --dart-define=FIREBASE_ENV=test or FIREBASE_ENV=production
  String get tournamentsCollection {
    const env = String.fromEnvironment('FIREBASE_ENV', defaultValue: 'production');
    return env == 'test' ? 'tournaments_test' : 'tournaments';
  }

  /// Generate a unique 8-digit tournament code
  /// Returns a string like "12345678"
  String generateTournamentCode() {
    // Generate random 8-digit number (10000000 - 99999999)
    final code = 10000000 + _random.nextInt(90000000);
    return code.toString();
  }

  /// Generate a 6-digit numeric passcode
  /// Returns a string like "123456"
  String generatePasscode() {
    // Generate random 6-digit number (100000 - 999999)
    final passcode = 100000 + _random.nextInt(900000);
    return passcode.toString();
  }

  /// Hash a passcode using SHA-256
  /// This is used to securely store passcodes in Firestore
  String hashPasscode(String passcode) {
    final bytes = utf8.encode(passcode);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a tournament code already exists in Firestore
  Future<bool> tournamentExists(String tournamentCode) async {
    try {
      final doc = await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentCode)
          .get();
      return doc.exists;
    } catch (e) {
      // If there's an error, assume it doesn't exist
      return false;
    }
  }

  /// Generate a unique tournament code that doesn't exist in Firestore
  Future<String> generateUniqueTournamentCode() async {
    String code;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      code = generateTournamentCode();
      attempts++;
      
      if (attempts >= maxAttempts) {
        throw Exception('Failed to generate unique tournament code after $maxAttempts attempts');
      }
    } while (await tournamentExists(code));

    return code;
  }

  /// Save a tournament to Firestore
  /// 
  /// Parameters:
  /// - tournament: The tournament data to save
  /// - tournamentCode: The 8-digit tournament code
  /// - passcode: The 6-digit passcode (will be hashed)
  /// 
  /// Throws an exception if the save fails
  Future<void> saveTournament({
    required Tournament tournament,
    required String tournamentCode,
    required String passcode,
  }) async {
    try {
      final hashedPasscode = hashPasscode(passcode);
      
      final data = {
        'tournamentCode': tournamentCode,
        'passcode': hashedPasscode,
        'name': tournament.name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        
        // Tournament data
        'tournamentData': tournament.toJson(),
      };

      await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentCode)
          .set(data, SetOptions(merge: false));
    } catch (e) {
      throw Exception('Failed to save tournament: $e');
    }
  }

  /// Update an existing tournament in Firestore
  /// 
  /// Parameters:
  /// - tournamentCode: The 8-digit tournament code
  /// - passcode: The 6-digit passcode (for verification)
  /// - tournament: The updated tournament data
  /// 
  /// Throws an exception if:
  /// - The tournament doesn't exist
  /// - The passcode is incorrect
  /// - The update fails
  Future<void> updateTournament({
    required String tournamentCode,
    required String passcode,
    required Tournament tournament,
  }) async {
    try {
      // First, verify the passcode
      final isValid = await _verifyPasscode(tournamentCode, passcode);
      if (!isValid) {
        throw Exception('Invalid passcode');
      }

      final data = {
        'lastModified': FieldValue.serverTimestamp(),
        'tournamentData': tournament.toJson(),
      };

      await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentCode)
          .update(data);
    } catch (e) {
      if (e.toString().contains('Invalid passcode')) {
        rethrow;
      }
      throw Exception('Failed to update tournament: $e');
    }
  }

  /// Load a tournament from Firestore
  /// 
  /// Parameters:
  /// - tournamentCode: The 8-digit tournament code
  /// - passcode: The 6-digit passcode
  /// 
  /// Returns the tournament data if successful
  /// 
  /// Throws an exception if:
  /// - The tournament doesn't exist
  /// - The passcode is incorrect
  /// - The load fails
  Future<Tournament> loadTournament({
    required String tournamentCode,
    required String passcode,
  }) async {
    try {
      // Verify passcode
      final isValid = await _verifyPasscode(tournamentCode, passcode);
      if (!isValid) {
        throw Exception('Invalid passcode');
      }

      // Load tournament data
      final doc = await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentCode)
          .get();

      if (!doc.exists) {
        throw Exception('Tournament not found');
      }

      final data = doc.data()!;
      final tournamentData = data['tournamentData'] as Map<String, dynamic>;
      
      return Tournament.fromJson(tournamentData);
    } catch (e) {
      if (e.toString().contains('Invalid passcode') || 
          e.toString().contains('Tournament not found')) {
        rethrow;
      }
      throw Exception('Failed to load tournament: $e');
    }
  }

  /// Verify that a passcode matches the stored hash
  /// 
  /// Returns true if the passcode is correct, false otherwise
  Future<bool> _verifyPasscode(String tournamentCode, String passcode) async {
    try {
      final doc = await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentCode)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedHash = data['passcode'] as String;
      final inputHash = hashPasscode(passcode);

      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  /// Check if Firebase is properly initialized and accessible
  /// 
  /// Returns true if Firebase is working, false otherwise
  Future<bool> isFirebaseAvailable() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (kDebugMode) {
        // Log Firebase configuration for debugging
        debugPrint('=== Firebase Configuration Check ===');
        debugPrint('API Key: ${options.apiKey.isEmpty ? "MISSING" : "Present (${options.apiKey.substring(0, 10)}...)"}');
        debugPrint('Project ID: ${options.projectId.isEmpty ? "MISSING" : options.projectId}');
        debugPrint('Auth Domain: ${options.authDomain?.isEmpty ?? true ? "MISSING" : options.authDomain}');
        debugPrint('Storage Bucket: ${options.storageBucket?.isEmpty ?? true ? "MISSING" : options.storageBucket}');
        debugPrint('App ID: ${options.appId.isEmpty ? "MISSING" : "Present"}');
        debugPrint('Collection: $tournamentsCollection');
      }
      
      // Check if any required field is missing
      if (options.apiKey.isEmpty || options.projectId.isEmpty || options.appId.isEmpty) {
        debugPrint('❌ Firebase configuration is incomplete!');
        debugPrint('Make sure you are running with --dart-define flags or using the launch.json configuration.');
        return false;
      }
      
      if(kDebugMode){
        debugPrint('✅ Firebase configuration looks good, testing connection...');
      }
      
      // Try to access Firestore
      await _firestore.collection(tournamentsCollection).limit(1).get();
      if(kDebugMode){
        debugPrint('✅ Firebase connection successful!');
      }
      return true;
    } catch (e, stackTrace) {
      if(kDebugMode) {
        debugPrint('❌ Firebase error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }
}

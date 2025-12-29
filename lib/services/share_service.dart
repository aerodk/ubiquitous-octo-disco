import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for generating and parsing tournament share links
/// 
/// Features:
/// - Generate shareable URLs with tournament code
/// - Support including/excluding passcode
/// - Parse URL parameters to extract tournament info
class ShareService {
  /// Get the base URL for the application
  /// In production, this returns the GitHub Pages URL
  /// In development/test, returns a placeholder
  String getBaseUrl() {
    if (kIsWeb) {
      // Get the current URL from the browser
      // This will work for both production and test deployments
      return Uri.base.origin;
    }
    // Fallback for non-web platforms (should not be used in production)
    return 'https://aerodk.github.io/ubiquitous-octo-disco';
  }

  /// Generate a shareable link for a tournament
  /// 
  /// Parameters:
  /// - tournamentCode: The 8-digit tournament code
  /// - includePasscode: Whether to include the passcode in the URL
  /// - passcode: The 6-digit passcode (required if includePasscode is true)
  /// 
  /// Returns a complete URL that can be shared
  /// 
  /// Examples:
  /// - With passcode: https://example.com/#/tournament/12345678?p=123456
  /// - Without passcode: https://example.com/#/tournament/12345678
  String generateShareLink({
    required String tournamentCode,
    bool includePasscode = false,
    String? passcode,
  }) {
    if (includePasscode && (passcode == null || passcode.isEmpty)) {
      throw ArgumentError('Passcode is required when includePasscode is true');
    }

    final baseUrl = getBaseUrl();
    final buffer = StringBuffer(baseUrl);
    
    // Use hash routing for Flutter web
    buffer.write('/#/tournament/$tournamentCode');
    
    if (includePasscode && passcode != null) {
      buffer.write('?p=$passcode');
    }
    
    return buffer.toString();
  }

  /// Parse tournament information from the current URL
  /// 
  /// Returns a map with:
  /// - 'code': The tournament code (String)
  /// - 'passcode': The passcode if provided (String?)
  /// - 'isReadOnly': Whether the link is read-only (bool)
  /// 
  /// Returns null if no tournament information is found in the URL
  Map<String, dynamic>? parseTournamentFromUrl(Uri uri) {
    // Check for tournament in the fragment (hash routing)
    final fragment = uri.fragment;
    
    if (fragment.isEmpty) {
      return null;
    }
    
    // Parse the fragment as a path
    // Expected format: /tournament/12345678 or /tournament/12345678?p=123456
    final fragmentUri = Uri.parse(fragment);
    final pathSegments = fragmentUri.pathSegments;
    
    // Check if this is a tournament link
    if (pathSegments.length < 2 || pathSegments[0] != 'tournament') {
      return null;
    }
    
    final tournamentCode = pathSegments[1];
    
    // Validate tournament code format (8 digits)
    if (!RegExp(r'^\d{8}$').hasMatch(tournamentCode)) {
      return null;
    }
    
    // Extract passcode from query parameters
    final passcode = fragmentUri.queryParameters['p'];
    
    // If passcode is provided, validate it (6 digits)
    if (passcode != null && !RegExp(r'^\d{6}$').hasMatch(passcode)) {
      return null;
    }
    
    return {
      'code': tournamentCode,
      'passcode': passcode,
      // Read-only if no passcode is provided
      'isReadOnly': passcode == null,
    };
  }

  /// Check if the current URL contains tournament information
  bool hasTournamentInUrl(Uri uri) {
    return parseTournamentFromUrl(uri) != null;
  }
}

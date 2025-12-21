// Constants for the Padel Tournament App

class Constants {
  // Player constraints
  static const int minPlayers = 4;
  static const int maxPlayers = 24;

  // Court constraints
  static const int minCourts = 1;
  static const int maxCourts = 8;

  // Score constraints (for future Version 2.0)
  static const int minScore = 0;
  static const int maxScore = 24;

  // Default names
  static String getDefaultCourtName(int index) => 'Bane ${index + 1}';

  // Player standing constants
  static const int noLossesSentinel = 999; // Used to represent no losses in smallestLossMargin

  // Validation messages
  static const String emptyNameError = 'Spillernavn kan ikke være tomt';
  static const String duplicateNameError = 'Spilleren findes allerede';
  static const String maxPlayersError = 'Maksimum 24 spillere tilladt';
  static const String minPlayersError = 'Minimum 4 spillere påkrævet';
}

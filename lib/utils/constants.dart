// Constants for the Padel Tournament App

class Constants {
  // Player constraints
  static const int minPlayers = 4;
  static const int maxPlayers = 72;

  // Court constraints
  static const int minCourts = 1;
  static const int maxCourts = 18;

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
  static const String maxPlayersError = 'Maksimum 72 spillere tilladt';
  static const String minPlayersError = 'Minimum 4 spillere påkrævet';
  
  // Display mode constants (for manual desktop/mobile toggle)
  static const double desktopModeScaleFactor = 1.5; // Scale UI elements by 50% for desktop mode
  static const double desktopModeFontScale = 1.3; // Scale fonts by 30% for desktop mode
  static const double desktopModeCardPadding = 24.0; // Increased padding for desktop
  static const double mobileModeCardPadding = 16.0; // Standard mobile padding
  
  // Breakpoint for automatic responsive design (in logical pixels)
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 900.0;
}

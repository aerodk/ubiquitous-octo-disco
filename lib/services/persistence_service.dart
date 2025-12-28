import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import '../models/player.dart';

class PersistenceService {
  static const String _tournamentKey = 'current_tournament';
  static const String _setupPlayersKey = 'setup_players';
  static const String _setupCourtsKey = 'setup_courts';
  static const String _setupCourtNamesKey = 'setup_court_names';
  static const String _fullTournamentHistoryKey = 'full_tournament_history';

  /// Save the current tournament to local storage
  Future<void> saveTournament(Tournament tournament) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(tournament.toJson());
    await prefs.setString(_tournamentKey, json);
  }

  /// Load the current tournament from local storage
  Future<Tournament?> loadTournament() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_tournamentKey);
    if (json == null || json.isEmpty) return null;
    
    try {
      final Map<String, dynamic> data = jsonDecode(json);
      return Tournament.fromJson(data);
    } catch (e) {
      // If deserialization fails, clear the corrupted data
      await clearTournament();
      return null;
    }
  }

  /// Clear the saved tournament
  Future<void> clearTournament() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tournamentKey);
    await prefs.remove(_fullTournamentHistoryKey);
  }
  
  /// Save the full tournament history (used when navigating back to preserve future rounds)
  Future<void> saveFullTournamentHistory(Tournament tournament) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(tournament.toJson());
    await prefs.setString(_fullTournamentHistoryKey, json);
  }
  
  /// Load the full tournament history
  Future<Tournament?> loadFullTournamentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_fullTournamentHistoryKey);
    if (json == null || json.isEmpty) return null;
    
    try {
      final Map<String, dynamic> data = jsonDecode(json);
      return Tournament.fromJson(data);
    } catch (e) {
      // If deserialization fails, clear the corrupted data
      await prefs.remove(_fullTournamentHistoryKey);
      return null;
    }
  }
  
  /// Clear the full tournament history
  Future<void> clearFullTournamentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fullTournamentHistoryKey);
  }

  /// Save setup screen state (players, court count, and custom court names)
  Future<void> saveSetupState(
    List<Player> players, 
    int courtCount,
    [Map<int, String>? courtCustomNames]
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = jsonEncode(players.map((p) => p.toJson()).toList());
    await prefs.setString(_setupPlayersKey, playersJson);
    await prefs.setInt(_setupCourtsKey, courtCount);
    
    // Save court custom names if provided
    if (courtCustomNames?.isNotEmpty == true) {
      // Convert Map<int, String> to Map<String, String> for JSON encoding
      final courtNamesStringKeys = courtCustomNames!.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await prefs.setString(_setupCourtNamesKey, jsonEncode(courtNamesStringKeys));
    } else {
      await prefs.remove(_setupCourtNamesKey);
    }
  }

  /// Load setup screen state
  Future<({List<Player> players, int courtCount, Map<int, String> courtCustomNames})?> loadSetupState() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_setupPlayersKey);
    final courtCount = prefs.getInt(_setupCourtsKey);
    final courtNamesJson = prefs.getString(_setupCourtNamesKey);

    if (playersJson == null || playersJson.isEmpty) return null;

    try {
      final List<dynamic> playersList = jsonDecode(playersJson);
      final players = playersList.map((p) => Player.fromJson(p)).toList();
      
      // Load court custom names if available
      Map<int, String> courtCustomNames = {};
      if (courtNamesJson != null && courtNamesJson.isNotEmpty) {
        final Map<String, dynamic> courtNamesMap = jsonDecode(courtNamesJson);
        courtCustomNames = courtNamesMap.map(
          (key, value) => MapEntry(int.parse(key), value as String),
        );
      }
      
      return (
        players: players, 
        courtCount: courtCount ?? 1,
        courtCustomNames: courtCustomNames,
      );
    } catch (e) {
      // If deserialization fails, clear the corrupted data
      await clearSetupState();
      return null;
    }
  }

  /// Clear setup screen state
  Future<void> clearSetupState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_setupPlayersKey);
    await prefs.remove(_setupCourtsKey);
    await prefs.remove(_setupCourtNamesKey);
  }
}

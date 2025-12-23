import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import '../models/player.dart';

class PersistenceService {
  static const String _tournamentKey = 'current_tournament';
  static const String _setupPlayersKey = 'setup_players';
  static const String _setupCourtsKey = 'setup_courts';
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

  /// Save setup screen state (players and court count)
  Future<void> saveSetupState(List<Player> players, int courtCount) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = jsonEncode(players.map((p) => p.toJson()).toList());
    await prefs.setString(_setupPlayersKey, playersJson);
    await prefs.setInt(_setupCourtsKey, courtCount);
  }

  /// Load setup screen state
  Future<({List<Player> players, int courtCount})?> loadSetupState() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_setupPlayersKey);
    final courtCount = prefs.getInt(_setupCourtsKey);

    if (playersJson == null || playersJson.isEmpty) return null;

    try {
      final List<dynamic> playersList = jsonDecode(playersJson);
      final players = playersList.map((p) => Player.fromJson(p)).toList();
      return (players: players, courtCount: courtCount ?? 1);
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
  }
}

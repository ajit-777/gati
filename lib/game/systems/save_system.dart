import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for the game's persistent state:
/// best distance, total Sparks (currency), unlocked/selected character.
class SaveSystem {
  static const _kBestDistance = 'gati.best_distance';
  static const _kTotalSparks = 'gati.total_sparks';
  static const _kUnlocked = 'gati.unlocked_characters';
  static const _kSelected = 'gati.selected_character';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static double get bestDistance => _prefs?.getDouble(_kBestDistance) ?? 0;
  static Future<void> setBestDistanceIfHigher(double meters) async {
    if (meters > bestDistance) {
      await _prefs?.setDouble(_kBestDistance, meters);
    }
  }

  static int get totalSparks => _prefs?.getInt(_kTotalSparks) ?? 0;
  static Future<void> addSparks(int amount) async {
    await _prefs?.setInt(_kTotalSparks, totalSparks + amount);
  }

  static Future<bool> spendSparks(int amount) async {
    if (totalSparks < amount) return false;
    await _prefs?.setInt(_kTotalSparks, totalSparks - amount);
    return true;
  }

  static List<String> get unlockedCharacterIds =>
      _prefs?.getStringList(_kUnlocked) ?? const ['school_kid'];

  static Future<void> unlockCharacter(String id) async {
    final list = {...unlockedCharacterIds, id}.toList();
    await _prefs?.setStringList(_kUnlocked, list);
  }

  static String get selectedCharacterId => _prefs?.getString(_kSelected) ?? 'school_kid';
  static Future<void> selectCharacter(String id) async {
    await _prefs?.setString(_kSelected, id);
  }
}

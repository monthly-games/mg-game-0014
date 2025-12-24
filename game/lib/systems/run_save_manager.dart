import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/player/player_data.dart';
import '../features/stage/stage_manager.dart';
import '../features/skill/skill_manager.dart';

class RunSaveManager {
  final PlayerData playerData;
  final StageManager stageManager;
  final SkillManager skillManager;

  static const String _storageKey = 'lab_run_save';

  RunSaveManager({
    required this.playerData,
    required this.stageManager,
    required this.skillManager,
  });

  /// Save current run state
  Future<void> saveRun() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'player': playerData.toJson(),
      'stage': stageManager.toJson(),
      'skills': skillManager.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_storageKey, jsonEncode(data));
    print('💾 Run saved successfully.');
  }

  /// Load run state
  Future<bool> loadRun() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_storageKey)) return false;

    try {
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) return false;

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      playerData.load(data['player']);
      stageManager.load(data['stage']);
      skillManager.load(data['skills']);

      print('📂 Run loaded successfully.');
      return true;
    } catch (e) {
      print('❌ Failed to load run: $e');
      return false;
    }
  }

  static Future<bool> checkSaveExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_storageKey);
  }

  /// Check if a save exists
  Future<bool> hasSave() async {
    return checkSaveExists();
  }

  static Future<void> clearSaveStatic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Clear save (e.g., on death)
  Future<void> clearSave() async {
    return clearSaveStatic();
  }
}

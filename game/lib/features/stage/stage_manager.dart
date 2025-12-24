import 'package:flutter/foundation.dart';
import 'dart:math';

/// Game state enum
enum GameState {
  playing, // Active gameplay
  victory, // Enemy defeated, showing reward
  defeat, // Player died
  rewarding, // Choosing reward
}

/// Stage manager for roguelike progression
class StageManager extends ChangeNotifier {
  int _currentStage = 1;
  int get currentStage => _currentStage;

  GameState _gameState = GameState.playing;
  GameState get gameState => _gameState;

  int _totalKills = 0;
  int get totalKills => _totalKills;

  // Enemy scaling
  double getEnemyHp(int stage) {
    // Exponential scaling: Base 50, +15% per stage
    return 50.0 * pow(1.15, stage - 1);
  }

  double getEnemyDamage(int stage) {
    return 10.0 + (stage - 1) * 2.0; // 10, 12, 14, 16...
  }

  double getEnemyAttackSpeed(int stage) {
    final baseInterval = 5.0;
    final reduction = (stage - 1) * 0.2;
    return (baseInterval - reduction).clamp(
      2.0,
      5.0,
    ); // Faster over time, min 2s
  }

  /// Called when enemy is defeated
  void onEnemyDefeated() {
    _totalKills++;
    _gameState = GameState.victory;
    notifyListeners();

    print('🏆 Stage $currentStage cleared! Total kills: $_totalKills');
  }

  /// Called when player dies
  void onPlayerDeath() {
    _gameState = GameState.defeat;
    notifyListeners();

    print('💀 Game Over! Reached stage $currentStage with $_totalKills kills');
  }

  /// Proceed to next stage after reward selection
  void proceedToNextStage() {
    _currentStage++;
    _gameState = GameState.playing;
    notifyListeners();

    print('📈 Advancing to stage $_currentStage');
  }

  /// Show reward selection screen
  void showRewardScreen() {
    _gameState = GameState.rewarding;
    notifyListeners();
  }

  /// Reset game for new run
  void resetGame() {
    _currentStage = 1;
    _totalKills = 0;
    _gameState = GameState.playing;
    notifyListeners();

    print('🔄 New run started!');
  }

  /// Check if in active gameplay
  bool get isPlaying => _gameState == GameState.playing;

  /// Check if showing victory
  bool get isVictory => _gameState == GameState.victory;

  /// Check if showing defeat
  bool get isDefeat => _gameState == GameState.defeat;

  /// Check if showing reward screen
  bool get isRewarding => _gameState == GameState.rewarding;

  /// Get stage difficulty name
  String getStageDifficulty() {
    if (_currentStage <= 3) return 'Easy';
    if (_currentStage <= 7) return 'Normal';
    if (_currentStage <= 12) return 'Hard';
    if (_currentStage <= 20) return 'Very Hard';
    return 'Insane';
  }

  /// Get current stage color
  String getStageColor() {
    if (_currentStage <= 3) return '🟢';
    if (_currentStage <= 7) return '🟡';
    if (_currentStage <= 12) return '🟠';
    if (_currentStage <= 20) return '🔴';
    return '🟣';
  }

  // Persistence
  Map<String, dynamic> toJson() {
    return {
      'currentStage': _currentStage,
      'totalKills': _totalKills,
      'gameState': _gameState.index,
    };
  }

  void load(Map<String, dynamic> json) {
    _currentStage = (json['currentStage'] as num).toInt();
    _totalKills = (json['totalKills'] as num).toInt();
    _gameState = GameState.values[(json['gameState'] as num).toInt()];
    notifyListeners();
  }
}

/// Reward type enum
enum RewardType {
  skill, // New skill
  heal, // Restore HP
  maxHpUp, // Increase max HP
}

/// Reward data model
class RewardOption {
  final RewardType type;
  final String title;
  final String description;
  final dynamic value; // SkillData for skill, int for HP

  const RewardOption({
    required this.type,
    required this.title,
    required this.description,
    required this.value,
  });
}

/// Reward generator
class RewardGenerator {
  static final Random _rand = Random();

  /// Generate 3 random rewards
  static List<RewardOption> generateRewards(
    int stage,
    List<dynamic> availableSkills,
  ) {
    final rewards = <RewardOption>[];

    // Always offer at least 1 skill if available
    if (availableSkills.isNotEmpty) {
      final randomSkills = List.from(availableSkills)..shuffle(_rand);
      final skillCount = min(2, randomSkills.length);

      for (int i = 0; i < skillCount; i++) {
        final skill = randomSkills[i];
        rewards.add(
          RewardOption(
            type: RewardType.skill,
            title: '스킬: ${skill.name}',
            description: skill.description,
            value: skill,
          ),
        );
      }
    }

    // Fill remaining with stat boosts
    while (rewards.length < 3) {
      final choice = _rand.nextInt(2);

      if (choice == 0) {
        // Heal
        final healAmount = 30 + stage * 5;
        rewards.add(
          RewardOption(
            type: RewardType.heal,
            title: 'HP 회복',
            description: 'HP를 $healAmount 회복합니다',
            value: healAmount,
          ),
        );
      } else {
        // Max HP increase
        final hpIncrease = 10 + stage * 2;
        rewards.add(
          RewardOption(
            type: RewardType.maxHpUp,
            title: '최대 HP 증가',
            description: '최대 HP가 $hpIncrease 증가합니다',
            value: hpIncrease,
          ),
        );
      }
    }

    return rewards;
  }
}

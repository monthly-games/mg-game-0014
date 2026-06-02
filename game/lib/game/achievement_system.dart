import 'dart:math';
import 'package:flutter/foundation.dart';

/// Achievement definition with tracking criteria.
class Achievement {
  final String id;
  final String name;
  final String description;
  final int rewardGold;
  final int rewardXp;
  final AchievementCriteria criteria;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.rewardGold = 100,
    this.rewardXp = 50,
    required this.criteria,
  });

  /// Check if achievement is unlocked based on current stats.
  bool isUnlocked(Map<String, dynamic> stats) {
    return criteria.isSatisfied(stats);
  }
}

/// Achievement criteria interface.
abstract class AchievementCriteria {
  const AchievementCriteria();

  bool isSatisfied(Map<String, dynamic> stats);
}

/// Reach a specific stage milestone.
class StageMilestoneCriteria extends AchievementCriteria {
  final int targetStage;

  const StageMilestoneCriteria({required this.targetStage});

  @override
  bool isSatisfied(Map<String, dynamic> stats) {
    final currentStage = stats['highest_stage'] ?? 0;
    return currentStage >= targetStage;
  }
}

/// Achieve a specific combo chain count.
class ComboChainCriteria extends AchievementCriteria {
  final int targetChain;

  const ComboChainCriteria({required this.targetChain});

  @override
  bool isSatisfied(Map<String, dynamic> stats) {
    final highestChain = stats['highest_combo'] ?? 0;
    return highestChain >= targetChain;
  }
}

/// Defeat a total number of enemies.
class EnemyDefeatCriteria extends AchievementCriteria {
  final int targetKills;

  const EnemyDefeatCriteria({required this.targetKills});

  @override
  bool isSatisfied(Map<String, dynamic> stats) {
    final totalKills = stats['enemies_defeated'] ?? 0;
    return totalKills >= targetKills;
  }
}

/// Collect specific amount of resources (gold/xp).
class ResourceCollectionCriteria extends AchievementCriteria {
  final String resourceId;
  final int targetAmount;

  const ResourceCollectionCriteria({
    required this.resourceId,
    required this.targetAmount,
  });

  @override
  bool isSatisfied(Map<String, dynamic> stats) {
    final collected = stats['total_${resourceId}_collected'] ?? 0;
    return collected >= targetAmount;
  }
}

/// Achievement system tracking and rewards.
class AchievementSystem extends ChangeNotifier {
  final List<Achievement> _allAchievements = [];
  final Set<String> _unlockedAchievements = {};
  final Map<String, dynamic> _sessionStats = {};

  List<Achievement> get allAchievements => List.unmodifiable(_allAchievements);
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlockedAchievements);
  Map<String, dynamic> get sessionStats => Map.unmodifiable(_sessionStats);

  // Achievement progress callbacks
  final List<void Function(Achievement)> _unlockCallbacks = [];

  AchievementSystem() {
    _initializeAchievements();
    _initializeStats();
  }

  void _initializeAchievements() {
    _allAchievements.addAll([
      // Stage milestones
      Achievement(
        id: 'stage_5',
        name: 'Apprentice Witch',
        description: 'Reach Stage 5',
        rewardGold: 200,
        rewardXp: 100,
        criteria: const StageMilestoneCriteria(targetStage: 5),
      ),
      Achievement(
        id: 'stage_10',
        name: 'Skilled Alchemist',
        description: 'Reach Stage 10',
        rewardGold: 500,
        rewardXp: 250,
        criteria: const StageMilestoneCriteria(targetStage: 10),
      ),
      Achievement(
        id: 'stage_20',
        name: 'Master Witch',
        description: 'Reach Stage 20',
        rewardGold: 1500,
        rewardXp: 750,
        criteria: const StageMilestoneCriteria(targetStage: 20),
      ),

      // Combo achievements
      Achievement(
        id: 'combo_3',
        name: 'Getting Started',
        description: 'Achieve a 3x combo chain',
        rewardGold: 50,
        rewardXp: 25,
        criteria: const ComboChainCriteria(targetChain: 3),
      ),
      Achievement(
        id: 'combo_5',
        name: 'Combo Master',
        description: 'Achieve a 5x combo chain',
        rewardGold: 150,
        rewardXp: 75,
        criteria: const ComboChainCriteria(targetChain: 5),
      ),
      Achievement(
        id: 'combo_10',
        name: 'Legendary Combo',
        description: 'Achieve a 10x combo chain',
        rewardGold: 500,
        rewardXp: 250,
        criteria: const ComboChainCriteria(targetChain: 10),
      ),

      // Combat achievements
      Achievement(
        id: 'kills_10',
        name: 'Monster Hunter',
        description: 'Defeat 10 enemies',
        rewardGold: 100,
        rewardXp: 50,
        criteria: const EnemyDefeatCriteria(targetKills: 10),
      ),
      Achievement(
        id: 'kills_50',
        name: 'Enemy Slayer',
        description: 'Defeat 50 enemies',
        rewardGold: 400,
        rewardXp: 200,
        criteria: const EnemyDefeatCriteria(targetKills: 50),
      ),
      Achievement(
        id: 'kills_100',
        name: 'Legendary Witch',
        description: 'Defeat 100 enemies',
        rewardGold: 1000,
        rewardXp: 500,
        criteria: const EnemyDefeatCriteria(targetKills: 100),
      ),

      // Resource achievements
      Achievement(
        id: 'gold_1000',
        name: 'Wealth Accumulator',
        description: 'Collect 1,000 gold total',
        rewardGold: 200,
        rewardXp: 100,
        criteria: const ResourceCollectionCriteria(
          resourceId: 'gold',
          targetAmount: 1000,
        ),
      ),
      Achievement(
        id: 'xp_5000',
        name: 'Experience Seeker',
        description: 'Earn 5,000 XP total',
        rewardGold: 300,
        rewardXp: 150,
        criteria: const ResourceCollectionCriteria(
          resourceId: 'xp',
          targetAmount: 5000,
        ),
      ),
    ]);
  }

  void _initializeStats() {
    _sessionStats['highest_stage'] = 0;
    _sessionStats['highest_combo'] = 0;
    _sessionStats['enemies_defeated'] = 0;
    _sessionStats['total_gold_collected'] = 0;
    _sessionStats['total_xp_collected'] = 0;
    _sessionStats['matches_made'] = 0;
  }

  /// Update a stat value and check for new achievements.
  void updateStat(String key, dynamic value) {
    final current = _sessionStats[key] ?? 0;

    // Handle different value types
    if (value is int) {
      _sessionStats[key] = max(current as int, value);
    } else if (value is double) {
      _sessionStats[key] = max(current as double, value);
    } else {
      _sessionStats[key] = value;
    }

    _checkAchievements();
  }

  /// Increment a stat value (for counters like kills, matches).
  void incrementStat(String key, [int amount = 1]) {
    _sessionStats[key] = (_sessionStats[key] ?? 0) + amount;
    _checkAchievements();
  }

  /// Check for newly unlocked achievements.
  void _checkAchievements() {
    for (final achievement in _allAchievements) {
      if (!_unlockedAchievements.contains(achievement.id)) {
        if (achievement.isUnlocked(_sessionStats)) {
          _unlockAchievement(achievement);
        }
      }
    }
  }

  /// Unlock an achievement and trigger rewards.
  void _unlockAchievement(Achievement achievement) {
    _unlockedAchievements.add(achievement.id);

    // Add rewards to session stats
    _sessionStats['total_gold_collected'] =
        (_sessionStats['total_gold_collected'] ?? 0) + achievement.rewardGold;
    _sessionStats['total_xp_collected'] =
        (_sessionStats['total_xp_collected'] ?? 0) + achievement.rewardXp;

    // Notify listeners
    notifyListeners();

    // Trigger callbacks
    for (final callback in _unlockCallbacks) {
      callback(achievement);
    }
  }

  /// Register a callback for when achievements are unlocked.
  void onAchievementUnlocked(void Function(Achievement) callback) {
    _unlockCallbacks.add(callback);
  }

  /// Check if a specific achievement is unlocked.
  bool isUnlocked(String achievementId) {
    return _unlockedAchievements.contains(achievementId);
  }

  /// Get achievement by ID.
  Achievement? getAchievement(String id) {
    try {
      return _allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total reward stats from unlocked achievements.
  int get totalGoldEarned {
    int total = 0;
    for (final id in _unlockedAchievements) {
      final achievement = getAchievement(id);
      if (achievement != null) {
        total += achievement.rewardGold;
      }
    }
    return total;
  }

  int get totalXpEarned {
    int total = 0;
    for (final id in _unlockedAchievements) {
      final achievement = getAchievement(id);
      if (achievement != null) {
        total += achievement.rewardXp;
      }
    }
    return total;
  }

  /// Reset session stats (for new run).
  void resetStats() {
    _initializeStats();
    // Keep unlocked achievements persistent
    notifyListeners();
  }

  /// Full reset (including achievements - for testing).
  void fullReset() {
    _unlockedAchievements.clear();
    resetStats();
  }
}
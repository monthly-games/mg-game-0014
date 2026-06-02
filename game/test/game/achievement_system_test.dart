import 'package:flutter_test/flutter_test.dart';
import 'package:game/game/achievement_system.dart';
import 'package:game/game/combo_system.dart';

void main() {
  group('AchievementSystem Tests', () {
    late AchievementSystem achievementSystem;

    setUp(() {
      achievementSystem = AchievementSystem();
    });

    test('Initial state has no unlocked achievements', () {
      expect(achievementSystem.unlockedAchievements.isEmpty, true);
      expect(achievementSystem.allAchievements.isNotEmpty, true);
    });

    test('Stage milestone achievements unlock correctly', () {
      expect(achievementSystem.isUnlocked('stage_5'), false);

      achievementSystem.updateStat('highest_stage', 5);

      expect(achievementSystem.isUnlocked('stage_5'), true);
    });

    test('Combo achievements unlock on threshold', () {
      expect(achievementSystem.isUnlocked('combo_3'), false);

      achievementSystem.updateStat('highest_combo', 3);

      expect(achievementSystem.isUnlocked('combo_3'), true);
      expect(achievementSystem.isUnlocked('combo_5'), false);
    });

    test('Enemy defeat achievements track cumulative kills', () {
      expect(achievementSystem.isUnlocked('kills_10'), false);

      achievementSystem.incrementStat('enemies_defeated', 5);
      expect(achievementSystem.isUnlocked('kills_10'), false);

      achievementSystem.incrementStat('enemies_defeated', 5);
      expect(achievementSystem.isUnlocked('kills_10'), true);
    });

    test('Resource achievements unlock on collection milestones', () {
      expect(achievementSystem.isUnlocked('gold_1000'), false);

      achievementSystem.updateStat('total_gold_collected', 1000);

      expect(achievementSystem.isUnlocked('gold_1000'), true);
    });

    test('Achievement rewards are added to session stats', () {
      achievementSystem.updateStat('highest_stage', 5);

      // Achievement rewards: 200 gold, 100 XP
      final totalGold = achievementSystem.sessionStats['total_gold_collected'] ?? 0;
      final totalXp = achievementSystem.sessionStats['total_xp_collected'] ?? 0;

      expect(totalGold, greaterThanOrEqualTo(200));
      expect(totalXp, greaterThanOrEqualTo(100));
    });

    test('Multiple achievements can unlock simultaneously', () {
      // Set stats that should unlock multiple achievements
      achievementSystem.updateStat('highest_stage', 10);
      achievementSystem.updateStat('highest_combo', 5);

      expect(achievementSystem.isUnlocked('stage_5'), true);
      expect(achievementSystem.isUnlocked('stage_10'), true);
      expect(achievementSystem.isUnlocked('combo_3'), true);
      expect(achievementSystem.isUnlocked('combo_5'), true);
    });

    test('Achievement callback fires on unlock', () {
      Achievement? unlockedAchievement;

      achievementSystem.onAchievementUnlocked((achievement) {
        unlockedAchievement = achievement;
      });

      achievementSystem.updateStat('highest_stage', 5);

      expect(unlockedAchievement, isNotNull);
      expect(unlockedAchievement!.id, 'stage_5');
      expect(unlockedAchievement?.name, 'Apprentice Witch');
    });

    test('Get achievement returns correct data', () {
      final achievement = achievementSystem.getAchievement('combo_10');

      expect(achievement, isNotNull);
      expect(achievement!.id, 'combo_10');
      expect(achievement.name, 'Legendary Combo');
      expect(achievement.rewardGold, 500);
      expect(achievement.rewardXp, 250);
    });

    test('Get achievement returns null for invalid ID', () {
      final achievement = achievementSystem.getAchievement('invalid_id');
      expect(achievement, isNull);
    });

    test('Total rewards calculate correctly', () {
      achievementSystem.updateStat('highest_stage', 5);
      achievementSystem.updateStat('highest_combo', 3);
      achievementSystem.incrementStat('enemies_defeated', 10);

      // stage_5: 200 gold, 100 XP
      // combo_3: 50 gold, 25 XP
      // kills_10: 100 gold, 50 XP
      // Total: 350 gold, 175 XP
      expect(achievementSystem.totalGoldEarned, 350);
      expect(achievementSystem.totalXpEarned, 175);
    });

    test('Reset stats preserves unlocked achievements', () {
      achievementSystem.updateStat('highest_stage', 5);
      expect(achievementSystem.isUnlocked('stage_5'), true);

      achievementSystem.resetStats();

      expect(achievementSystem.isUnlocked('stage_5'), true);
      expect(achievementSystem.sessionStats['highest_stage'], 0);
    });

    test('Full reset clears everything', () {
      achievementSystem.updateStat('highest_stage', 5);
      expect(achievementSystem.isUnlocked('stage_5'), true);

      achievementSystem.fullReset();

      expect(achievementSystem.isUnlocked('stage_5'), false);
      expect(achievementSystem.totalGoldEarned, 0);
      expect(achievementSystem.totalXpEarned, 0);
    });

    test('Stat increment works correctly', () {
      achievementSystem.incrementStat('enemies_defeated', 3);
      expect(achievementSystem.sessionStats['enemies_defeated'], 3);

      achievementSystem.incrementStat('enemies_defeated', 2);
      expect(achievementSystem.sessionStats['enemies_defeated'], 5);
    });

    test('Stats track maximum values correctly', () {
      achievementSystem.updateStat('highest_stage', 5);
      expect(achievementSystem.sessionStats['highest_stage'], 5);

      achievementSystem.updateStat('highest_stage', 3);
      expect(achievementSystem.sessionStats['highest_stage'], 5); // Keeps max

      achievementSystem.updateStat('highest_stage', 10);
      expect(achievementSystem.sessionStats['highest_stage'], 10); // Updates to new max
    });
  });

  group('AchievementCriteria Tests', () {
    test('StageMilestoneCriteria evaluates correctly', () {
      const criteria = StageMilestoneCriteria(targetStage: 5);

      expect(criteria.isSatisfied({'highest_stage': 4}), false);
      expect(criteria.isSatisfied({'highest_stage': 5}), true);
      expect(criteria.isSatisfied({'highest_stage': 10}), true);
    });

    test('ComboChainCriteria evaluates correctly', () {
      const criteria = ComboChainCriteria(targetChain: 5);

      expect(criteria.isSatisfied({'highest_combo': 3}), false);
      expect(criteria.isSatisfied({'highest_combo': 5}), true);
      expect(criteria.isSatisfied({'highest_combo': 10}), true);
    });

    test('EnemyDefeatCriteria evaluates correctly', () {
      const criteria = EnemyDefeatCriteria(targetKills: 50);

      expect(criteria.isSatisfied({'enemies_defeated': 25}), false);
      expect(criteria.isSatisfied({'enemies_defeated': 50}), true);
      expect(criteria.isSatisfied({'enemies_defeated': 100}), true);
    });

    test('ResourceCollectionCriteria evaluates correctly', () {
      const criteria = ResourceCollectionCriteria(
        resourceId: 'gold',
        targetAmount: 1000,
      );

      expect(criteria.isSatisfied({'total_gold_collected': 500}), false);
      expect(criteria.isSatisfied({'total_gold_collected': 1000}), true);
      expect(criteria.isSatisfied({'total_gold_collected': 2000}), true);
    });
  });
}
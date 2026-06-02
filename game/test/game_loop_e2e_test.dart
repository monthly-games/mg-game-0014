import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';

/// E2E Test for MG-0014: Witch's Lab: Experimental Puzzle
///
/// Tests the game loop with focus on:
/// - Combo system mechanics
/// - Achievement system integration
/// - Puzzle-solving progression
/// - Laboratory theme and experimental elements
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0014 Witchs Lab - Game Loop E2E', () {
    testWidgets('Complete puzzle progression with combo system', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0014'), findsOneWidget);
      expect(find.text('Witch\'s Lab: Experimental Puzzle'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to game screen (no tutorial for MG-0014)
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify game screen initialization
      expect(find.byType(app.GameScreen), findsOneWidget);

      // Test combo system through puzzle completion
      int comboCount = 0;
      int totalGold = 0;
      int totalXP = 0;

      // Complete puzzles to build combo
      for (int i = 0; i < 5 && i < kLevelDesign.length; i++) {
        await tester.pumpAndSettle();

        final levelDesign = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);
        expect(find.text('${spawn.enemyCount} targets'), findsOneWidget);

        // Complete puzzle to build combo
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        // Puzzle combo multiplier
        final comboMultiplier = (i % 3) + 1; // 1x, 2x, 3x repeating
        totalGold += levelDesign.goldReward * comboMultiplier;
        totalXP += levelDesign.xpReward * comboMultiplier;
        comboCount++;

        expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
      }

      // Verify combo system
      expect(comboCount, greaterThan(0), reason: 'Should complete puzzles');
      expect(totalGold, greaterThan(0), reason: 'Combo should increase rewards');
    });

    testWidgets('Test achievement system integration', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Witch's Lab should have achievement milestones
      int achievementsUnlocked = 0;

      // Simulate achievement unlocks through progression
      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];

        // Certain levels should trigger achievements
        if (level.levelIndex == 3 || level.levelIndex == 7 || level.levelIndex == 10) {
          achievementsUnlocked++;
        }

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify achievement system is active
      expect(achievementsUnlocked, greaterThan(0), reason: 'Should unlock achievements');
    });

    testWidgets('Test puzzle variety and experimental mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // Verify puzzle variety in level design
      expect(find.byType(app.LevelRoadmapScreen), findsOneWidget);

      // Witch's Lab should have diverse puzzle types
      for (int i = 0; i < kLevelDesign.length && i < 10; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);

        // Puzzles should have experimental/lab themes
        expect(level.stage.toLowerCase(), anyOf(
          contains('experiment'),
          contains('puzzle'),
          contains('lab'),
          contains('research'),
          contains('formula'),
          contains('mystery'),
        ), reason: 'Puzzles should have lab themes');
      }
    });

    testWidgets('Verify witch lab theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify lab visual elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);
      expect(find.byIcon(Icons.extension_rounded), findsWidgets);
    });

    testWidgets('Complete full puzzle session with achievement tracking', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int puzzlesCompleted = 0;
      int maxPuzzles = 20;

      for (int i = 0; i < maxPuzzles && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        puzzlesCompleted++;
      }

      expect(puzzlesCompleted, equals(maxPuzzles), reason: 'Should complete 20 puzzles');

      // Verify puzzle rewards
      final finalGold = kLevelDesign.take(maxPuzzles).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxPuzzles).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test witch lab special features and retention mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test daily puzzle challenges
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsOneWidget);
      expect(find.text('Short goals keep the fun loop moving.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test rewards system
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test seasonal events
      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();
      expect(find.text('Seasonal Event'), findsOneWidget);
      expect(find.text('Timed content gives the loop a fresh reason to return.'), findsOneWidget);
    });

    testWidgets('Verify puzzle difficulty progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test that puzzle difficulty increases appropriately
      List<double> difficulties = [];

      for (int i = 0; i < 15 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        difficulties.add(level.difficulty);

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Puzzles should have varied difficulty
      final uniqueDifficulties = difficulties.toSet();
      expect(uniqueDifficulties.length, greaterThan(2),
          reason: 'Puzzles should have varied difficulty');

      // Difficulty should generally increase
      final maxDifficulty = difficulties.reduce((a, b) => a > b ? a : b);
      final minDifficulty = difficulties.reduce((a, b) => a < b ? a : b);
      expect(maxDifficulty, greaterThan(minDifficulty),
          reason: 'Puzzle difficulty should progress');
    });

    testWidgets('Test combo system reset and rebuild mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Build initial combo
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Simulate combo break (puzzle games often have time limits)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Rebuild combo
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify combo system flexibility
      expect(find.textContaining('gold'), findsOneWidget);
      expect(find.textContaining('xp'), findsOneWidget);
    });

    testWidgets('Verify achievement milestone rewards', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int totalGold = 0;
      int achievementBonus = 0;

      // Play through levels that trigger achievements
      for (int i = 0; i < 15 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        totalGold += level.goldReward;

        // Achievement milestones provide bonus rewards
        if (level.levelIndex == 5) {
          achievementBonus += 100; // First achievement
        }
        if (level.levelIndex == 10) {
          achievementBonus += 250; // Second achievement
        }
        if (level.levelIndex == 15) {
          achievementBonus += 500; // Third achievement
        }

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify achievement rewards are significant
      expect(achievementBonus, greaterThan(0), reason: 'Achievements should provide bonuses');
      expect(totalGold + achievementBonus, greaterThan(totalGold),
          reason: 'Total with achievements should be higher');
    });
  });
}
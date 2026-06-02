import 'package:flutter_test/flutter_test.dart';
import 'package:game/game/combo_system.dart';
import 'package:game/features/puzzle/grid_manager.dart';

void main() {
  group('ComboSystem Tests', () {
    late ComboSystem comboSystem;

    setUp(() {
      comboSystem = ComboSystem();
    });

    test('Initial state should have zero combo', () {
      expect(comboSystem.currentChain, 0);
      expect(comboSystem.chainMultiplier, 1.0);
      expect(comboSystem.isChainActive, false);
    });

    test('Recording match increases chain count', () {
      final multiplier = comboSystem.recordMatch(TileType.fire, 3);

      expect(comboSystem.currentChain, 1);
      expect(multiplier, 1.1); // 1.0 + (1 * 10 / 100)
      expect(comboSystem.isChainActive, true);
    });

    test('Chain multiplier scales correctly', () {
      comboSystem.recordMatch(TileType.fire, 3);
      expect(comboSystem.chainMultiplier, 1.1);

      comboSystem.recordMatch(TileType.water, 4);
      expect(comboSystem.chainMultiplier, 1.2);

      comboSystem.recordMatch(TileType.earth, 3);
      expect(comboSystem.chainMultiplier, 1.3);
    });

    test('Chain multiplier caps at 3.0', () {
      // Record 30 matches (should cap at 3.0x)
      for (int i = 0; i < 30; i++) {
        comboSystem.recordMatch(TileType.fire, 3);
      }

      expect(comboSystem.chainMultiplier, 3.0);
      expect(comboSystem.highestChain, 30);
    });

    test('Combo expires after timeout', () async {
      comboSystem.recordMatch(TileType.fire, 3);
      expect(comboSystem.isChainActive, true);

      // Wait for combo timeout (2.5 seconds + buffer)
      await Future.delayed(const Duration(milliseconds: 2600));

      // Next match should start new chain
      comboSystem.recordMatch(TileType.water, 3);
      expect(comboSystem.currentChain, 1); // Reset to 1, not 2
    });

    test('Combo rarity progresses correctly', () {
      expect(comboSystem.currentRarity, ComboRarity.common);

      // Simulate 3-chain
      for (int i = 0; i < 3; i++) {
        comboSystem.recordMatch(TileType.fire, 3);
      }
      expect(comboSystem.currentRarity, ComboRarity.rare);

      // Simulate 5-chain
      for (int i = 3; i < 5; i++) {
        comboSystem.recordMatch(TileType.fire, 3);
      }
      expect(comboSystem.currentRarity, ComboRarity.epic);

      // Simulate 8-chain
      for (int i = 5; i < 8; i++) {
        comboSystem.recordMatch(TileType.fire, 3);
      }
      expect(comboSystem.currentRarity, ComboRarity.legendary);
    });

    test('Reset combo clears chain state', () {
      comboSystem.recordMatch(TileType.fire, 3);
      comboSystem.recordMatch(TileType.water, 3);
      expect(comboSystem.currentChain, 2);

      comboSystem.resetCombo();
      expect(comboSystem.currentChain, 0);
      expect(comboSystem.isChainActive, false);
    });

    test('Type matches are tracked correctly', () {
      comboSystem.recordMatch(TileType.fire, 3);
      comboSystem.recordMatch(TileType.fire, 4);
      comboSystem.recordMatch(TileType.water, 3);

      expect(comboSystem.typeMatches[TileType.fire], 7);
      expect(comboSystem.typeMatches[TileType.water], 3);
    });

    test('Remaining combo time decreases over time', () async {
      comboSystem.recordMatch(TileType.fire, 3);

      final initialRemaining = comboSystem.remainingComboSeconds;
      expect(initialRemaining, greaterThan(0));

      await Future.delayed(const Duration(milliseconds: 500));

      final laterRemaining = comboSystem.remainingComboSeconds;
      expect(laterRemaining, lessThan(initialRemaining));
    });

    test('Highest chain is preserved', () {
      comboSystem.recordMatch(TileType.fire, 3);
      comboSystem.recordMatch(TileType.water, 3);
      comboSystem.recordMatch(TileType.earth, 3);

      expect(comboSystem.highestChain, 3);

      comboSystem.resetCombo();

      expect(comboSystem.highestChain, 3); // Preserved
    });

    test('Full reset clears all statistics', () {
      comboSystem.recordMatch(TileType.fire, 3);
      comboSystem.recordMatch(TileType.water, 3);
      comboSystem.recordMatch(TileType.earth, 3);

      expect(comboSystem.highestChain, 3);
      expect(comboSystem.totalCombosCompleted, 0);

      comboSystem.reset();
      expect(comboSystem.highestChain, 0);
      expect(comboSystem.currentChain, 0);
    });
  });

  group('ComboRarity Tests', () {
    test('Rarity emoji returns correct values', () {
      expect(ComboSystem.rarityEmoji(ComboRarity.common), '⚪');
      expect(ComboSystem.rarityEmoji(ComboRarity.rare), '🔵');
      expect(ComboSystem.rarityEmoji(ComboRarity.epic), '🟣');
      expect(ComboSystem.rarityEmoji(ComboRarity.legendary), '🟡');
    });
  });
}
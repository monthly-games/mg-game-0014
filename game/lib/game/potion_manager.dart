import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// PotionManager — Witch's Lab potion brewing & effects system
//
// Tracks brewed potions, active effects, and applies upgrade
// bonuses: potion_potency, effect_duration, special_chance.
// ============================================================

/// Types of special effects a potion can trigger.
enum SpecialEffect {
  none,
  doubleYield,
  bonusExperience,
  rareMaterialDrop,
  chainReaction,
}

/// A brewed potion with calculated stats.
class Potion {
  final String recipeId;
  final String name;
  final int potency;
  final int durationSeconds;
  final SpecialEffect specialEffect;
  final DateTime brewedAt;

  const Potion({
    required this.recipeId,
    required this.name,
    required this.potency,
    required this.durationSeconds,
    required this.specialEffect,
    required this.brewedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(brewedAt).inSeconds >= durationSeconds;

  double get remainingFraction {
    final elapsed = DateTime.now().difference(brewedAt).inSeconds;
    if (durationSeconds <= 0) return 0.0;
    return ((durationSeconds - elapsed) / durationSeconds).clamp(0.0, 1.0);
  }

  int get remainingSeconds {
    final elapsed = DateTime.now().difference(brewedAt).inSeconds;
    return (durationSeconds - elapsed).clamp(0, durationSeconds);
  }

  bool get hasSpecialEffect => specialEffect != SpecialEffect.none;
}

class PotionManager extends ChangeNotifier {
  /// Base potion effect duration in seconds.
  static const int _baseEffectDuration = 60;

  final UpgradeManager _upgradeManager = GetIt.I<UpgradeManager>();
  final Random _rng = Random();

  final List<Potion> _brewedPotions = [];
  final List<Potion> _activeEffects = [];
  int _totalBrewed = 0;
  int _specialsTriggered = 0;

  List<Potion> get brewedPotions => List.unmodifiable(_brewedPotions);
  List<Potion> get activeEffects =>
      List.unmodifiable(_activeEffects.where((p) => !p.isExpired).toList());
  int get totalBrewed => _totalBrewed;
  int get specialsTriggered => _specialsTriggered;

  // ── Upgrade-derived values ──────────────────────────────────

  /// Potion potency multiplier: 1.0 + (0.15 * potency_level).
  double get potencyMultiplier {
    final upgrade = _upgradeManager.getUpgrade('potion_potency');
    return 1.0 + (upgrade?.currentValue ?? 0.0);
  }

  /// Effect duration multiplier: 1.0 + (0.1 * duration_level).
  double get durationMultiplier {
    final upgrade = _upgradeManager.getUpgrade('effect_duration');
    return 1.0 + (upgrade?.currentValue ?? 0.0);
  }

  /// Chance to trigger a special effect (0.0 – 1.0).
  double get specialChance {
    final upgrade = _upgradeManager.getUpgrade('special_chance');
    return (upgrade?.currentValue ?? 0.0).clamp(0.0, 1.0);
  }

  // ── Potion brewing ─────────────────────────────────────────

  /// Brew a potion from a recipe.  Returns the resulting [Potion].
  Potion brewPotion({
    required String recipeId,
    required String recipeName,
    required int basePotency,
  }) {
    final potency = (basePotency * potencyMultiplier).round();
    final duration = (_baseEffectDuration * durationMultiplier).round();
    final special = _rollSpecialEffect();

    final potion = Potion(
      recipeId: recipeId,
      name: recipeName,
      potency: potency,
      durationSeconds: duration,
      specialEffect: special,
      brewedAt: DateTime.now(),
    );

    _brewedPotions.add(potion);
    _totalBrewed++;
    if (special != SpecialEffect.none) {
      _specialsTriggered++;
    }

    notifyListeners();
    return potion;
  }

  /// Roll for a special effect based on current [specialChance].
  SpecialEffect _rollSpecialEffect() {
    if (specialChance <= 0.0) return SpecialEffect.none;
    if (_rng.nextDouble() >= specialChance) return SpecialEffect.none;

    // Weight distribution among special effects
    const effects = [
      SpecialEffect.doubleYield,
      SpecialEffect.bonusExperience,
      SpecialEffect.rareMaterialDrop,
      SpecialEffect.chainReaction,
    ];
    return effects[_rng.nextInt(effects.length)];
  }

  // ── Effect activation ──────────────────────────────────────

  /// Activate a brewed potion (move to active effects).
  /// Returns false if potion not found in brewed list.
  bool activatePotion(int index) {
    if (index < 0 || index >= _brewedPotions.length) return false;

    final potion = _brewedPotions.removeAt(index);
    _activeEffects.add(potion);
    // Clean expired effects
    _activeEffects.removeWhere((p) => p.isExpired);

    notifyListeners();
    return true;
  }

  /// Get total active potency bonus from all non-expired effects.
  int get activePotencyBonus {
    _activeEffects.removeWhere((p) => p.isExpired);
    int total = 0;
    for (final potion in _activeEffects) {
      total += potion.potency;
    }
    return total;
  }

  /// Check if any active potion has a specific special effect.
  bool hasActiveSpecialEffect(SpecialEffect effect) {
    _activeEffects.removeWhere((p) => p.isExpired);
    return _activeEffects.any((p) => p.specialEffect == effect);
  }

  /// Get the label text for a special effect.
  static String specialEffectLabel(SpecialEffect effect) {
    switch (effect) {
      case SpecialEffect.none:
        return 'None';
      case SpecialEffect.doubleYield:
        return 'Double Yield';
      case SpecialEffect.bonusExperience:
        return 'Bonus XP';
      case SpecialEffect.rareMaterialDrop:
        return 'Rare Drop';
      case SpecialEffect.chainReaction:
        return 'Chain Reaction';
    }
  }

  // ── Inventory management ───────────────────────────────────

  /// Number of potions in storage (not yet activated).
  int get storedPotionCount => _brewedPotions.length;

  /// Discard a brewed potion from storage.
  bool discardPotion(int index) {
    if (index < 0 || index >= _brewedPotions.length) return false;
    _brewedPotions.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Reset all potion state (for prestige / new run).
  void reset() {
    _brewedPotions.clear();
    _activeEffects.clear();
    _totalBrewed = 0;
    _specialsTriggered = 0;
    notifyListeners();
  }
}

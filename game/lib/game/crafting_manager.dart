import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// CraftingManager — Witch's Lab ingredient crafting system
//
// Manages the cauldron crafting queue, material inventory, and
// applies upgrade effects: crafting_speed, material_efficiency,
// batch_size.
// ============================================================

/// Represents a single ingredient material in the witch's lab.
class LabMaterial {
  final String id;
  final String name;
  final int baseYield;

  const LabMaterial({
    required this.id,
    required this.name,
    this.baseYield = 1,
  });
}

/// A crafting slot tracking an in-progress cauldron brew.
class CraftingSlot {
  final LabMaterial material;
  final DateTime startTime;
  final int durationSeconds;
  final int batchCount;

  const CraftingSlot({
    required this.material,
    required this.startTime,
    required this.durationSeconds,
    required this.batchCount,
  });

  bool get isComplete =>
      DateTime.now().difference(startTime).inSeconds >= durationSeconds;

  double get progress {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    if (durationSeconds <= 0) return 1.0;
    return (elapsed / durationSeconds).clamp(0.0, 1.0);
  }

  int get remainingSeconds {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (durationSeconds - elapsed).clamp(0, durationSeconds);
  }
}

/// Default lab materials available to the witch.
class LabMaterials {
  static const moonPetal = LabMaterial(
    id: 'moon_petal',
    name: 'Moon Petal',
    baseYield: 2,
  );
  static const shadowRoot = LabMaterial(
    id: 'shadow_root',
    name: 'Shadow Root',
    baseYield: 1,
  );
  static const crystalDust = LabMaterial(
    id: 'crystal_dust',
    name: 'Crystal Dust',
    baseYield: 3,
  );
  static const emberSap = LabMaterial(
    id: 'ember_sap',
    name: 'Ember Sap',
    baseYield: 2,
  );
  static const spiritEssence = LabMaterial(
    id: 'spirit_essence',
    name: 'Spirit Essence',
    baseYield: 1,
  );

  static const List<LabMaterial> all = [
    moonPetal,
    shadowRoot,
    crystalDust,
    emberSap,
    spiritEssence,
  ];
}

class CraftingManager extends ChangeNotifier {
  /// Base crafting duration in seconds before upgrades.
  static const int _baseCraftDuration = 30;

  final UpgradeManager _upgradeManager = GetIt.I<UpgradeManager>();

  final Map<String, int> _inventory = {};
  final List<CraftingSlot> _activeSlots = [];
  Timer? _tickTimer;
  int _totalCrafted = 0;

  Map<String, int> get inventory => Map.unmodifiable(_inventory);
  List<CraftingSlot> get activeSlots => List.unmodifiable(_activeSlots);
  int get totalCrafted => _totalCrafted;

  CraftingManager() {
    // Seed starter materials
    for (final mat in LabMaterials.all) {
      _inventory[mat.id] = mat.baseYield * 2;
    }
    // Tick every second to refresh crafting progress UI
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeSlots.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  // ── Upgrade-derived values ──────────────────────────────────

  /// Crafting speed multiplier: 1.0 + (0.08 * craft_speed_level).
  double get craftSpeedMultiplier {
    final upgrade = _upgradeManager.getUpgrade('crafting_speed');
    return 1.0 + (upgrade?.currentValue ?? 0.0);
  }

  /// Material efficiency multiplier: 1.0 + (0.12 * efficiency_level).
  double get materialEfficiency {
    final upgrade = _upgradeManager.getUpgrade('material_efficiency');
    return 1.0 + (upgrade?.currentValue ?? 0.0);
  }

  /// Maximum simultaneous batch count: 1 + batch_size_level.
  int get maxBatchSize {
    final upgrade = _upgradeManager.getUpgrade('batch_size');
    return 1 + (upgrade?.currentValue.toInt() ?? 0);
  }

  // ── Crafting operations ─────────────────────────────────────

  /// Returns the adjusted crafting duration in seconds for current upgrades.
  int get adjustedCraftDuration =>
      (_baseCraftDuration / craftSpeedMultiplier).ceil();

  /// How many of [materialId] the player currently owns.
  int getMaterialCount(String materialId) => _inventory[materialId] ?? 0;

  /// Add materials to inventory (e.g. from puzzle rewards).
  void addMaterial(String materialId, int amount) {
    final effectiveAmount = (amount * materialEfficiency).floor();
    _inventory[materialId] = (_inventory[materialId] ?? 0) + effectiveAmount;
    notifyListeners();
  }

  /// Start crafting a material batch.  Returns false if insufficient stock.
  bool startCrafting(LabMaterial material, {int amount = 1}) {
    final batchCount = amount.clamp(1, maxBatchSize);
    final required = batchCount; // 1 material per batch item
    if (getMaterialCount(material.id) < required) return false;

    // Consume materials
    _inventory[material.id] = (_inventory[material.id] ?? 0) - required;

    _activeSlots.add(CraftingSlot(
      material: material,
      startTime: DateTime.now(),
      durationSeconds: adjustedCraftDuration,
      batchCount: batchCount,
    ));

    notifyListeners();
    return true;
  }

  /// Collect all completed crafting results and return yield count.
  int collectCompleted() {
    final completed = _activeSlots.where((s) => s.isComplete).toList();
    if (completed.isEmpty) return 0;

    int totalYield = 0;
    for (final slot in completed) {
      final yield_ = (slot.material.baseYield *
              slot.batchCount *
              materialEfficiency)
          .floor();
      _inventory[slot.material.id] =
          (_inventory[slot.material.id] ?? 0) + yield_;
      totalYield += yield_;
      _totalCrafted += slot.batchCount;
    }

    _activeSlots.removeWhere((s) => s.isComplete);
    notifyListeners();
    return totalYield;
  }

  /// Number of completed slots ready for collection.
  int get completedCount => _activeSlots.where((s) => s.isComplete).length;

  /// Reset crafting state (for prestige / new run).
  void reset() {
    _inventory.clear();
    _activeSlots.clear();
    _totalCrafted = 0;
    for (final mat in LabMaterials.all) {
      _inventory[mat.id] = mat.baseYield * 2;
    }
    notifyListeners();
  }
}

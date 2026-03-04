import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// RecipeManager — Witch's Lab recipe/grimoire system
//
// Manages discovered recipes, recipe slots, and ingredient
// substitution flexibility via upgrades: recipe_slots,
// ingredient_flex.
// ============================================================

/// Rarity tier for a recipe.
enum RecipeRarity { common, uncommon, rare, legendary }

/// A single recipe in the witch's grimoire.
class Recipe {
  final String id;
  final String name;
  final String description;
  final RecipeRarity rarity;
  final Map<String, int> ingredients; // materialId -> quantity
  final int resultPotency; // base potency of output

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.rarity = RecipeRarity.common,
    required this.ingredients,
    this.resultPotency = 10,
  });
}

/// Pre-defined recipe catalogue for the witch's lab.
class RecipeCatalogue {
  static const healingSalve = Recipe(
    id: 'healing_salve',
    name: 'Healing Salve',
    description: 'A soothing paste that mends minor wounds.',
    rarity: RecipeRarity.common,
    ingredients: {'moon_petal': 2, 'ember_sap': 1},
    resultPotency: 10,
  );

  static const shadowVeil = Recipe(
    id: 'shadow_veil',
    name: 'Shadow Veil',
    description: 'Cloaks the user in shifting darkness.',
    rarity: RecipeRarity.uncommon,
    ingredients: {'shadow_root': 3, 'crystal_dust': 1},
    resultPotency: 18,
  );

  static const crystalElixir = Recipe(
    id: 'crystal_elixir',
    name: 'Crystal Elixir',
    description: 'Purified essence that sharpens the mind.',
    rarity: RecipeRarity.uncommon,
    ingredients: {'crystal_dust': 2, 'spirit_essence': 1},
    resultPotency: 22,
  );

  static const emberblast = Recipe(
    id: 'emberblast',
    name: 'Emberblast Tonic',
    description: 'Volatile brew that ignites on contact.',
    rarity: RecipeRarity.rare,
    ingredients: {'ember_sap': 3, 'shadow_root': 2},
    resultPotency: 30,
  );

  static const spiritBind = Recipe(
    id: 'spirit_bind',
    name: 'Spirit Binding Draught',
    description: 'Anchors wandering spirits to the material plane.',
    rarity: RecipeRarity.rare,
    ingredients: {'spirit_essence': 3, 'moon_petal': 2},
    resultPotency: 35,
  );

  static const grandElixir = Recipe(
    id: 'grand_elixir',
    name: 'Grand Elixir',
    description: 'The pinnacle of alchemical achievement.',
    rarity: RecipeRarity.legendary,
    ingredients: {
      'moon_petal': 3,
      'shadow_root': 2,
      'crystal_dust': 2,
      'ember_sap': 2,
      'spirit_essence': 1,
    },
    resultPotency: 60,
  );

  static const List<Recipe> all = [
    healingSalve,
    shadowVeil,
    crystalElixir,
    emberblast,
    spiritBind,
    grandElixir,
  ];
}

class RecipeManager extends ChangeNotifier {
  /// Base number of active recipe slots before upgrades.
  static const int _baseRecipeSlots = 2;

  final UpgradeManager _upgradeManager = GetIt.I<UpgradeManager>();

  final Set<String> _discoveredRecipeIds = {};
  final List<String> _activeRecipeSlots = []; // recipe ids in active slots
  int _totalBrewed = 0;

  Set<String> get discoveredRecipeIds => Set.unmodifiable(_discoveredRecipeIds);
  List<String> get activeRecipeSlots => List.unmodifiable(_activeRecipeSlots);
  int get totalBrewed => _totalBrewed;

  RecipeManager() {
    // Start with the simplest recipe discovered
    _discoveredRecipeIds.add(RecipeCatalogue.healingSalve.id);
  }

  // ── Upgrade-derived values ──────────────────────────────────

  /// Maximum number of recipe slots: base + recipe_slots upgrade level.
  int get maxRecipeSlots {
    final upgrade = _upgradeManager.getUpgrade('recipe_slots');
    return _baseRecipeSlots + (upgrade?.currentValue.toInt() ?? 0);
  }

  /// Ingredient flexibility factor (0.0 – 1.0 range).
  /// Allows substituting up to [ingredientFlex]% of required ingredients.
  double get ingredientFlex {
    final upgrade = _upgradeManager.getUpgrade('ingredient_flex');
    return (upgrade?.currentValue ?? 0.0).clamp(0.0, 1.0);
  }

  // ── Recipe operations ───────────────────────────────────────

  /// Look up a recipe by its ID from the catalogue.
  Recipe? getRecipe(String id) {
    try {
      return RecipeCatalogue.all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// All recipes the player has discovered.
  List<Recipe> get discoveredRecipes => RecipeCatalogue.all
      .where((r) => _discoveredRecipeIds.contains(r.id))
      .toList();

  /// Discover a new recipe (e.g. from experimentation rewards).
  bool discoverRecipe(String recipeId) {
    if (_discoveredRecipeIds.contains(recipeId)) return false;
    final exists = RecipeCatalogue.all.any((r) => r.id == recipeId);
    if (!exists) return false;

    _discoveredRecipeIds.add(recipeId);
    notifyListeners();
    return true;
  }

  /// Equip a discovered recipe into an active slot.
  /// Returns false if slots full or recipe not discovered.
  bool equipRecipe(String recipeId) {
    if (!_discoveredRecipeIds.contains(recipeId)) return false;
    if (_activeRecipeSlots.contains(recipeId)) return false;
    if (_activeRecipeSlots.length >= maxRecipeSlots) return false;

    _activeRecipeSlots.add(recipeId);
    notifyListeners();
    return true;
  }

  /// Unequip a recipe from active slots.
  bool unequipRecipe(String recipeId) {
    final removed = _activeRecipeSlots.remove(recipeId);
    if (removed) notifyListeners();
    return removed;
  }

  /// Check if the player has enough materials (with flex substitution)
  /// to brew a recipe.  [availableMaterials] is materialId -> count.
  bool canBrew(
    Recipe recipe,
    Map<String, int> availableMaterials,
  ) {
    int totalRequired = 0;
    int totalAvailable = 0;

    for (final entry in recipe.ingredients.entries) {
      final have = availableMaterials[entry.key] ?? 0;
      totalRequired += entry.value;
      totalAvailable += have.clamp(0, entry.value);
    }

    if (totalRequired == 0) return false;
    final ratio = totalAvailable / totalRequired;
    // With ingredient_flex, the player can succeed even with partial stock
    return ratio >= (1.0 - ingredientFlex);
  }

  /// Record a successful brew.
  void recordBrew() {
    _totalBrewed++;
    notifyListeners();
  }

  /// Reset recipe progress (for prestige / new run).
  void reset() {
    _discoveredRecipeIds.clear();
    _activeRecipeSlots.clear();
    _totalBrewed = 0;
    // Re-grant starter recipe
    _discoveredRecipeIds.add(RecipeCatalogue.healingSalve.id);
    notifyListeners();
  }
}

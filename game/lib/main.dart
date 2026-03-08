import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/systems.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/systems/save_manager_helper.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'features/draft/draft_manager.dart';
import 'game/crafting_manager.dart';
import 'game/recipe_manager.dart';
import 'game/potion_manager.dart';
import 'screens/main_menu_screen.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/battlepass_screen.dart';
import 'screens/gacha_screen.dart';

// ============================================================
// Witch's Lab — MG-0014
// Genre: Puzzle (Crafting / Alchemy focus)
// Region: Africa
// Phase 1 Week 4: Mechanic Enhancement
//
// Core loop: Puzzle → Materials → Craft → Brew Potions → Apply Effects
// Subsystems: Recipes, Upgrades, Draft skills, Research
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSystems();

  // Unified Persistence
  await SaveManagerHelper.setupSaveManager(
    autoSaveEnabled: true,
    autoSaveIntervalSeconds: 30,
  );
  await SaveManagerHelper.legacyLoadAll();

  // Load saved upgrade levels
  final upgradeManager = GetIt.I<UpgradeManager>();
  await upgradeManager.loadUpgrades();

  // Apply saved upgrades to game managers
  _applyUpgradeEffects(upgradeManager);

  // DailyQuest 시스템
  GetIt.I.registerSingleton(DailyQuestManager());
  // Achievement 시스템
  GetIt.I.registerSingleton(AchievementManager());
  // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
    _registerCollections();
  }
  _registerAchievements();
  _registerDailyQuests();
  runApp(const WitchLabApp());
}

// ============================================================
// System Initialization — DI registration in dependency order
// ============================================================

/// Initialize all DI-registered systems in correct dependency order.
/// mg_common_game systems first, then game-specific managers.
Future<void> _initializeSystems() async {
  final di = GetIt.I;

  // ── mg_common_game core systems ──────────────────────────
  if (!di.isRegistered<AudioManager>()) {
    di.registerSingleton<AudioManager>(AudioManager());
    await di<AudioManager>().initialize();
  }

  if (!di.isRegistered<UpgradeManager>()) {
    final upgrades = UpgradeManager();
    di.registerSingleton<UpgradeManager>(upgrades);
    _registerWitchLabUpgrades(upgrades);
  }

  // ── Game-specific managers ───────────────────────────────
  if (!di.isRegistered<CraftingManager>()) {
    di.registerSingleton<CraftingManager>(CraftingManager());
  }

  if (!di.isRegistered<RecipeManager>()) {
    di.registerSingleton<RecipeManager>(RecipeManager());
  }

  if (!di.isRegistered<PotionManager>()) {
    di.registerSingleton<PotionManager>(PotionManager());
  }
}

// ============================================================
// Upgrade Registration — 8 witch-lab upgrades
// Categories: Crafting (3), Recipe (2), Potion (3)
// ============================================================

void _registerWitchLabUpgrades(UpgradeManager manager) {
  // ── Crafting upgrades (3) ──────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'crafting_speed',
    name: 'Swift Mortar',
    description: 'Reduce ingredient preparation time by 8% per level.',
    maxLevel: 15,
    baseCost: 50,
    costMultiplier: 1.4,
    valuePerLevel: 0.08,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'material_efficiency',
    name: 'Efficient Extraction',
    description: 'Increase material yield by 12% per level.',
    maxLevel: 12,
    baseCost: 80,
    costMultiplier: 1.45,
    valuePerLevel: 0.12,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'batch_size',
    name: 'Cauldron Expansion',
    description: 'Increase batch crafting capacity by 1 per level.',
    maxLevel: 8,
    baseCost: 150,
    costMultiplier: 1.6,
    valuePerLevel: 1.0,
  ));

  // ── Recipe upgrades (2) ────────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'recipe_slots',
    name: 'Grimoire Pages',
    description: 'Unlock additional recipe slots for experimentation.',
    maxLevel: 10,
    baseCost: 100,
    costMultiplier: 1.5,
    valuePerLevel: 1.0,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'ingredient_flex',
    name: 'Ingredient Intuition',
    description: 'Allow ingredient substitutions with 10% flexibility per level.',
    maxLevel: 8,
    baseCost: 120,
    costMultiplier: 1.55,
    valuePerLevel: 0.1,
  ));

  // ── Potion upgrades (3) ────────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'potion_potency',
    name: 'Concentrated Brew',
    description: 'Boost potion potency by 15% per level.',
    maxLevel: 10,
    baseCost: 60,
    costMultiplier: 1.4,
    valuePerLevel: 0.15,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'effect_duration',
    name: 'Lasting Enchantment',
    description: 'Extend potion effect duration by 10% per level.',
    maxLevel: 10,
    baseCost: 75,
    costMultiplier: 1.45,
    valuePerLevel: 0.1,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'special_chance',
    name: 'Mystic Catalyst',
    description: 'Increase chance of triggering special potion effects by 5% per level.',
    maxLevel: 10,
    baseCost: 200,
    costMultiplier: 1.6,
    valuePerLevel: 0.05,
  ));
}

// ============================================================
// Upgrade Effect Application — syncs upgrade state to managers
// ============================================================

/// Applies current upgrade levels to runtime managers.
/// Called after loading saved upgrades so managers reflect persisted state.
void _applyUpgradeEffects(UpgradeManager upgradeManager) {
  // Managers read upgrade values dynamically via GetIt<UpgradeManager>,
  // so notifyListeners propagates state.  This explicit call ensures
  // any manager that caches derived values refreshes after load.
  final craftingManager = GetIt.I<CraftingManager>();
  final recipeManager = GetIt.I<RecipeManager>();
  final potionManager = GetIt.I<PotionManager>();

  // Log current upgrade state for debugging
  debugPrint('[WitchLab] Upgrades loaded — '
      'craftSpeed=${craftingManager.craftSpeedMultiplier.toStringAsFixed(2)}, '
      'matEff=${craftingManager.materialEfficiency.toStringAsFixed(2)}, '
      'batch=${craftingManager.maxBatchSize}, '
      'recipeSlots=${recipeManager.maxRecipeSlots}, '
      'ingredientFlex=${recipeManager.ingredientFlex.toStringAsFixed(2)}, '
      'potency=${potionManager.potencyMultiplier.toStringAsFixed(2)}, '
      'duration=${potionManager.durationMultiplier.toStringAsFixed(2)}, '
      'special=${potionManager.specialChance.toStringAsFixed(2)}');
}

// ============================================================
// App Root — MultiProvider wraps all game state
// ============================================================

class WitchLabApp extends StatelessWidget {
  const WitchLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DraftManager()),
        ChangeNotifierProvider.value(value: GetIt.I<CraftingManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<RecipeManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<PotionManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<UpgradeManager>()),
      ],
      child: MaterialApp(
        title: "Witch's Lab",
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const MainMenuScreen(),
        routes: {
          '/daily-quests': (_) => const DailyQuestScreen(),
          '/achievements': (_) => const AchievementScreen(),
          '/daily_quest': (_) => const DailyQuestScreen(),
          '/achievement': (_) => const AchievementScreen(),
          '/battlepass': (_) => const BattlePassScreen(),
          '/gacha': (_) => const GachaScreen(),
        },
      ),
    );
  }

  /// Witch-lab themed dark mode with purple / gold accents.
  /// Uses MGColors.gold for Africa-region accent where applicable.
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1a0022),
      primaryColor: Colors.purple,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2a0038),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      dividerColor: Colors.white24,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF3a0050),
        contentTextStyle: const TextStyle(color: MGColors.textHighEmphasis),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ============================================================
// Upgrade Display Widget — shows upgrade tiles for the shop UI
// ============================================================

/// A reusable upgrade tile for listing purchasable upgrades.
/// Designed for integration into the Research Lab or a dedicated
/// Upgrades screen.
class UpgradeTileWidget extends StatelessWidget {
  final Upgrade upgrade;
  final int playerCurrency;
  final VoidCallback? onPurchase;

  const UpgradeTileWidget({
    super.key,
    required this.upgrade,
    required this.playerCurrency,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxed = upgrade.currentLevel >= upgrade.maxLevel;
    final cost = upgrade.costForNextLevel;
    final canAfford = !isMaxed && playerCurrency >= cost;

    return Card(
      color: isMaxed
          ? Colors.purple.withValues(alpha: 0.15)
          : const Color(0xFF2a0038),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isMaxed
              ? MGColors.gold
              : (canAfford ? Colors.purpleAccent : Colors.transparent),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Level indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMaxed
                    ? MGColors.gold.withValues(alpha: 0.2)
                    : Colors.purple.withValues(alpha: 0.3),
                border: Border.all(
                  color: isMaxed ? MGColors.gold : Colors.purpleAccent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${upgrade.currentLevel}',
                  style: TextStyle(
                    color: isMaxed ? MGColors.gold : Colors.purpleAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upgrade.name,
                    style: const TextStyle(
                      color: MGColors.textHighEmphasis,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    upgrade.description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMaxed
                        ? 'MAX LEVEL'
                        : 'Lv.${upgrade.currentLevel}/${upgrade.maxLevel}'
                            '  |  +${(upgrade.valuePerLevel * 100).toStringAsFixed(0)}% per level',
                    style: TextStyle(
                      color: isMaxed ? MGColors.gold : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Purchase button
            if (!isMaxed)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canAfford ? Colors.purpleAccent : Colors.grey[800],
                  foregroundColor: MGColors.textHighEmphasis,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: canAfford ? onPurchase : null,
                child: Text('$cost RP'),
              )
            else
              const Icon(Icons.check_circle, color: MGColors.gold, size: 28),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Upgrade List Widget — groups upgrades by category
// ============================================================

/// Displays all registered upgrades grouped into Crafting / Recipe / Potion
/// categories.  Intended for embedding in the Research Lab screen or a
/// standalone Upgrades tab.
class UpgradeListWidget extends StatelessWidget {
  final int playerCurrency;
  final void Function(String upgradeId) onPurchase;

  const UpgradeListWidget({
    super.key,
    required this.playerCurrency,
    required this.onPurchase,
  });

  static const _craftingIds = ['crafting_speed', 'material_efficiency', 'batch_size'];
  static const _recipeIds = ['recipe_slots', 'ingredient_flex'];
  static const _potionIds = ['potion_potency', 'effect_duration', 'special_chance'];

  @override
  Widget build(BuildContext context) {
    return Consumer<UpgradeManager>(
      builder: (context, upgradeManager, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCategoryHeader('Crafting Upgrades', Icons.build),
            ..._buildUpgradeTiles(upgradeManager, _craftingIds),
            const SizedBox(height: 16),

            _buildCategoryHeader('Recipe Upgrades', Icons.menu_book),
            ..._buildUpgradeTiles(upgradeManager, _recipeIds),
            const SizedBox(height: 16),

            _buildCategoryHeader('Potion Upgrades', Icons.science),
            ..._buildUpgradeTiles(upgradeManager, _potionIds),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.purpleAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUpgradeTiles(
    UpgradeManager upgradeManager,
    List<String> ids,
  ) {
    return ids.map((id) {
      final upgrade = upgradeManager.getUpgrade(id);
      if (upgrade == null) return const SizedBox.shrink();
      return UpgradeTileWidget(
        upgrade: upgrade,
        playerCurrency: playerCurrency,
        onPurchase: () => onPurchase(id),
      );
    }).toList();
  }
}


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'collect_gold',
    title: '골드 모으기',
    description: '골드 1000 획득',
    targetValue: 1000,
    goldReward: 500,
    xpReward: 10,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'play_games',
    title: '게임 플레이',
    description: '게임 5판 플레이',
    targetValue: 5,
    goldReward: 300,
    xpReward: 5,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'level_up',
    title: '레벨업',
    description: '레벨 1 상승',
    targetValue: 1,
    goldReward: 200,
    xpReward: 3,
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();
  
  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: '골드 1000 달성',
    description: '총 골드 1000을 모으세요',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: '레벨 10 달성',
    description: '레벨 10에 도달하세요',
    iconAsset: 'assets/achievements/level_10.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100판 플레이',
    description: '게임을 100판 플레이하세요',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters 컬렉션
  collection.registerCollection(const Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: CollectionReward(type: RewardType.gold, amount: 1000),
      50: CollectionReward(type: RewardType.gold, amount: 3000),
      75: CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}

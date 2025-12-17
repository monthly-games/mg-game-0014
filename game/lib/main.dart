import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'game/lab_game.dart';
import 'features/puzzle/grid_manager.dart';
import 'features/skill/skill_manager.dart';
import 'features/skill/skill_data.dart';
import 'features/synergy/synergy_manager.dart';
import 'features/stage/stage_manager.dart';
import 'features/player/player_data.dart';
import 'screens/reward_screen.dart';
import 'screens/game_over_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GridManager()),
        ChangeNotifierProvider(create: (_) => SkillManager()..initializeStarter()),
        ChangeNotifierProvider(create: (_) => SynergyManager()),
        ChangeNotifierProvider(create: (_) => StageManager()),
      ],
      child: const MaterialApp(title: 'Witchs Lab', home: LabScreen()),
    ),
  );
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  late LabGame _game;

  @override
  void initState() {
    super.initState();
    _game = LabGame();
  }

  @override
  Widget build(BuildContext context) {
    final skillManager = Provider.of<SkillManager>(context);
    final synergyManager = Provider.of<SynergyManager>(context);
    final stageManager = Provider.of<StageManager>(context);

    // Connect managers
    _game.skillManager = skillManager;
    _game.stageManager = stageManager;
    skillManager.synergyManager = synergyManager;

    // Show reward screen
    if (stageManager.isRewarding) {
      final availableSkills = Skills.getAllSkills()
          .where((s) => !skillManager.acquiredSkills.contains(s))
          .toList();

      final rewards = RewardGenerator.generateRewards(
        stageManager.currentStage,
        availableSkills,
      );

      return Scaffold(
        backgroundColor: AppColors.background,
        body: RewardScreen(
          rewards: rewards,
          currentStage: stageManager.currentStage,
          onSelect: (reward) {
            _handleReward(reward, skillManager);
            stageManager.proceedToNextStage();
            _game.respawnEnemy();
          },
        ),
      );
    }

    // Show game over screen
    if (stageManager.isDefeat) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: GameOverScreen(
          finalStage: stageManager.currentStage,
          totalKills: stageManager.totalKills,
          onRestart: () {
            stageManager.resetGame();
            skillManager.initializeStarter();
            _game.resetGame();
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GameWidget(game: _game),
          // Synergy display at top
          if (synergyManager.activeSynergies.isNotEmpty)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final synergy in synergyManager.activeSynergies)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          synergyManager.getSynergyInfo(synergy),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Skill Bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final skill in skillManager.activeSkills)
                    _buildSkillButton(skill, skillManager),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReward(RewardOption reward, SkillManager skillManager) {
    switch (reward.type) {
      case RewardType.skill:
        final skill = reward.value as SkillData;
        skillManager.acquireSkill(skill);
        print('📚 Acquired skill: ${skill.name}');
        break;
      case RewardType.heal:
        final healAmount = reward.value as int;
        _game.playerData.takeDamage(-healAmount.toDouble());
        print('💚 Healed $healAmount HP');
        break;
      case RewardType.maxHpUp:
        final hpIncrease = reward.value as int;
        _game.playerData.increaseMaxHp(hpIncrease.toDouble());
        print('❤️ Max HP increased by $hpIncrease');
        break;
    }
  }

  Widget _buildSkillButton(SkillData skill, SkillManager skillManager) {
    final canUse = skillManager.canUseSkill(skill, _game.playerData);
    final cooldownRatio = skillManager.getCooldownRatio(skill);

    return GestureDetector(
      onTap: () {
        if (canUse) {
          skillManager.useSkill(
            skill,
            _game.playerData,
            onDamage: (dmg) {
              _game.currentEnemy?.takeDamage(dmg);
              print("${skill.name} dealt $dmg damage!");
            },
            onHeal: (heal) {
              print("${skill.name} healed $heal HP!");
            },
          );
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: canUse ? _getElementColor(skill.element) : Colors.grey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                _getElementEmoji(skill.element),
                style: const TextStyle(fontSize: 30),
              ),
            ),
            // Cooldown overlay
            if (cooldownRatio > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      skillManager.getCooldown(skill).toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getElementColor(TileType type) {
    switch (type) {
      case TileType.fire:
        return Colors.redAccent;
      case TileType.water:
        return Colors.blueAccent;
      case TileType.earth:
        return Colors.greenAccent;
      case TileType.poison:
        return Colors.purpleAccent;
      case TileType.empty:
        return Colors.transparent;
    }
  }

  String _getElementEmoji(TileType type) {
    switch (type) {
      case TileType.fire:
        return '🔥';
      case TileType.water:
        return '💧';
      case TileType.earth:
        return '🌿';
      case TileType.poison:
        return '☠️';
      case TileType.empty:
        return '';
    }
  }
}

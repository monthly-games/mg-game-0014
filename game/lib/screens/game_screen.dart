import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import '../features/skill/ui/skill_hud.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:mg_common_game/core/ui/overlays/pause_game_overlay.dart';
import 'package:mg_common_game/core/ui/overlays/settings_game_overlay.dart';
import 'package:mg_common_game/core/ui/overlays/tutorial_game_overlay.dart';
import '../game/lab_game.dart';
import '../game/overlays/tutorial_overlay.dart';
import '../features/draft/draft_manager.dart';
import '../features/skill/skill_model.dart';
import '../systems/tutorial_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/core/localization/localization.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final LabGame _game;
  late final GameTutorialManager _tutorialManager;

  @override
  void initState() {
    super.initState();
    _game = LabGame();
    _tutorialManager = GameTutorialManager();
    _game.stageManager.addListener(_onStageChanged);
  }

  @override
  void dispose() {
    _game.stageManager.removeListener(_onStageChanged);
    super.dispose();
  }

  void _onStageChanged() {
    if (!mounted) return;

    final stageManager = _game.stageManager;
    // Use read inside callback is safe if context is valid
    final draftManager = Provider.of<DraftManager>(context, listen: false);

    if (stageManager.isRewarding && !draftManager.isDrafting) {
      draftManager.startDraft();
    }

    if (stageManager.isDefeat) {
      _game.pauseEngine();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("GAME OVER", style: TextStyle(color: MGColors.error)),
          content: Text(
            "You survived until Stage ${stageManager.currentStage}",
          ),
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(
            color: MGColors.error,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(color: MGColors.textHighEmphasis),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _game.resetGame();
                _game.resumeEngine();
              },
              child: Text(''),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Back to main menu
              },
              child: const Text("Quit"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can show the FlameGame in background
    return Scaffold(
      body: Stack(
        children: [
          // Background Game (Lab Visuals)
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'PauseGame': (context, LabGame game) => PauseGameOverlay(
                game: game,
                onResume: () {
                  game.resumeEngine();
                  game.overlays.remove('PauseGame');
                },
                onSettings: () {
                  game.overlays.add('SettingsGame');
                },
                onQuit: () {
                  game.resumeEngine();
                  game.overlays.remove('PauseGame');
                  Navigator.of(context).pop(); // Return to Main Menu
                },
              ),
              'SettingsGame': (context, LabGame game) => SettingsGameOverlay(
                game: game,
                onBack: () {
                  game.overlays.remove('SettingsGame');
                },
              ),
              'tutorial': (context, LabGame game) => GameTutorialOverlay(
                game: game,
                tutorialManager: _tutorialManager,
              ),
              'TutorialGame': (context, LabGame game) => TutorialGameOverlay(
                game: game,
                pages: const [
                  TutorialPage(
                    title: 'WITCH\'S LAB',
                    content:
                        'Brew potions and experiment with elements!\n\nCombine Skills to discover Synergies.',
                  ),
                  TutorialPage(
                    title: 'DRAFTING',
                    content:
                        'Draft new Skills to add to your collection.\n\nExperiment with combinations!',
                  ),
                ],
                onComplete: () {
                  game.overlays.remove('TutorialGame');
                  game.resumeEngine();
                },
              ),
            },
          ),

          // Foreground UI
          SafeArea(
            child: Consumer<DraftManager>(
              builder: (context, draftManager, child) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(MGSpacing.md),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Experiment In Progress",
                              style: TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 10, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.pause_circle_filled,
                              color: Colors.purpleAccent,
                              size: 32,
                            ),
                            onPressed: () {
                              _game.pauseEngine();
                              _game.overlays.add('PauseGame');
                            },
                          ),
                        ],
                      ),
                    ),

                    // Current Skills / Synergies
                    _buildInventory(draftManager),

                    const Spacer(),

                    // Skill HUD (Combat)
                    if (!draftManager.isDrafting)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: SkillHud(
                          skillManager: _game.skillManager,
                          playerData: _game.playerData,
                          onSkillUse: (skill) {
                            _game.spawnSkillEffect(skill);
                            _game.skillManager.useSkill(
                              skill,
                              _game.playerData,
                              onDamage: (dmg) {
                                _game.currentEnemy?.takeDamage(dmg);
                                if (_game.currentEnemy != null) {
                                  _game.spawnFloatingText(
                                    dmg.toInt().toString(),
                                    _game.currentEnemy!.position,
                                    MGColors.textHighEmphasis,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),

                    // Draft Area
                    if (draftManager.isDrafting)
                      _buildDraftOptions(context, draftManager)
                    else
                      const SizedBox.shrink(), // Replaced button with generic HUD area
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventory(DraftManager dm) {
    // Count synergies
    int fire = dm.mySkills.where((s) => s.type == SynergyType.fire).length;
    int ice = dm.mySkills.where((s) => s.type == SynergyType.ice).length;
    int poison = dm.mySkills.where((s) => s.type == SynergyType.poison).length;

    return Container(
      padding: const EdgeInsets.all(MGSpacing.xs),
      color: Colors.black54,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSynergyBadge(SynergyType.fire, fire),
              _buildSynergyBadge(SynergyType.ice, ice),
              _buildSynergyBadge(SynergyType.poison, poison),
            ],
          ),
          const SizedBox(height: MGSpacing.sm),
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dm.mySkills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Image.asset(
                    'assets/images/${dm.mySkills[index].iconPath}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynergyBadge(SynergyType type, int count) {
    Color color;
    String name;
    switch (type) {
      case SynergyType.fire:
        color = MGColors.warning;
        name = "Fire";
        break;
      case SynergyType.ice:
        color = Colors.cyan;
        name = "Ice";
        break;
      case SynergyType.poison:
        color = MGColors.success;
        name = "Poison";
        break;
    }

    bool active = count >= 3;

    return Column(
      children: [
        Text(
          "$name: $count/3",
          style: TextStyle(
            color: active ? color : MGColors.common,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (active)
          Text("ACTIVE", style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }

  Widget _buildDraftOptions(BuildContext context, DraftManager dm) {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: dm.draftOptions.map((skill) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                dm.pickSkill(skill);
                _game.stageManager.proceedToNextStage();
              },
              child: Card(
                color: Colors.grey[900],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/${skill.iconPath}',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: MGSpacing.sm),
                    Text(
                      skill.name,
                      style: const TextStyle(
                        color: MGColors.textHighEmphasis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      skill.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      skill.type.name.toUpperCase(),
                      style: const TextStyle(color: MGColors.common, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

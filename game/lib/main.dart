import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'game/lab_game.dart';
import 'features/puzzle/grid_manager.dart';
import 'features/skill/skill_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GridManager()),
        ChangeNotifierProvider(create: (_) => SkillManager()..initializeStarter()),
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
    _game.skillManager = skillManager;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GameWidget(game: _game),
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

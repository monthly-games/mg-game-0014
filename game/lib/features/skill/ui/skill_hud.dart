import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../skill_manager.dart';
import '../skill_data.dart';
import '../../player/player_data.dart';

class SkillHud extends StatelessWidget {
  final SkillManager skillManager;
  final PlayerData playerData;
  final Function(SkillData) onSkillUse;

  const SkillHud({
    super.key,
    required this.skillManager,
    required this.playerData,
    required this.onSkillUse,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([skillManager, playerData]),
      builder: (context, _) {
        final skills = skillManager.activeSkills;
        if (skills.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: skills.map((skill) => _buildSkillButton(skill)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSkillButton(SkillData skill) {
    // Check Status
    final cooldownRatio = skillManager.getCooldownRatio(skill);
    final hasMana = skillManager.canUseSkill(skill, playerData);
    final isOnCooldown = cooldownRatio > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          if (hasMana && !isOnCooldown) {
            onSkillUse(skill);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Stack
            Stack(
              alignment: Alignment.center,
              children: [
                // Base Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasMana
                          ? _getElementColor(skill.element)
                          : Colors.grey,
                      width: 2,
                    ),
                    boxShadow: hasMana && !isOnCooldown
                        ? [
                            BoxShadow(
                              color: _getElementColor(
                                skill.element,
                              ).withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/${skill.iconPath}',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      color: (!hasMana || isOnCooldown) ? Colors.black54 : null,
                      colorBlendMode: (!hasMana || isOnCooldown)
                          ? BlendMode.darken
                          : null,
                    ),
                  ),
                ),

                // Cooldown Overlay
                if (isOnCooldown)
                  CircularProgressIndicator(
                    value: 1.0 - cooldownRatio,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white70,
                    ),
                  ),

                // Mana Cost Badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${skill.manaCost}",
                      style: TextStyle(
                        color: _getElementColor(skill.element),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getElementColor(TileType type) {
    switch (type) {
      case TileType.fire:
        return Colors.orange;
      case TileType.water:
        return Colors.blue;
      case TileType.earth:
        return Colors.green;
      case TileType.poison:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

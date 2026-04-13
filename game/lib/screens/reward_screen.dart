import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import '../features/stage/stage_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class RewardScreen extends StatelessWidget {
  final List<RewardOption> rewards;
  final Function(RewardOption) onSelect;
  final int currentStage;

  const RewardScreen({
    super.key,
    required this.rewards,
    required this.onSelect,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(MGSpacing.lg),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                '🎉 스테이지 $currentStage 클리어!',
                style: const TextStyle(
                  color: MGColors.textHighEmphasis,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: MGSpacing.xs),
              const Text(
                '보상을 선택하세요',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: MGSpacing.xl),

              // Reward cards
              ...rewards.map(
                (reward) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildRewardCard(context, reward),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, RewardOption reward) {
    Color cardColor;
    IconData icon;

    switch (reward.type) {
      case RewardType.skill:
        cardColor = Colors.purple;
        icon = Icons.auto_fix_high;
        break;
      case RewardType.heal:
        cardColor = MGColors.success;
        icon = Icons.favorite;
        break;
      case RewardType.maxHpUp:
        cardColor = MGColors.info;
        icon = Icons.shield;
        break;
    }

    return InkWell(
      onTap: () => onSelect(reward),
      child: Container(
        padding: const EdgeInsets.all(MGSpacing.mdLg),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.2),
          border: Border.all(color: cardColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 36, color: MGColors.textHighEmphasis),
            ),
            const SizedBox(width: MGSpacing.md),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: TextStyle(
                      color: cardColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: MGSpacing.xxs),
                  Text(
                    reward.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.arrow_forward_ios, color: cardColor, size: 24),
          ],
        ),
      ),
    );
  }
}

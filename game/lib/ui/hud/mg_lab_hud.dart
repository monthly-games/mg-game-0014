import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_progress.dart';
import 'package:mg_common_game/core/ui/widgets/hud/resource_bar.dart';

/// MG-0014 Lab Game HUD
/// 실험실 액션 게임용 HUD - HP, 스킬 게이지, 스테이지 정보 표시
class MGLabHud extends StatelessWidget {
  final int hp;
  final int maxHp;
  final int energy;
  final int maxEnergy;
  final int stage;
  final int wave;
  final int score;
  final List<SkillInfo> skills;
  final VoidCallback? onPause;

  const MGLabHud({
    super.key,
    required this.hp,
    required this.maxHp,
    required this.energy,
    required this.maxEnergy,
    required this.stage,
    required this.wave,
    required this.score,
    this.skills = const [],
    this.onPause,
    this.onDailyHub,
    this.onGuildWar,
    this.onTournament,
    this.onSeasonalEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: HP/Energy 바
                Expanded(
                  flex: 2,
                  child: _buildStatusBars(),
                ),
                const SizedBox(width: MGSpacing.sm),
                // 중앙: 스테이지/웨이브 정보
                _buildStageInfo(),
                const SizedBox(width: MGSpacing.sm),
                // 오른쪽: 점수 & 일시정지
                _buildScoreAndPause(),
              ],
            ),
            const Spacer(),
            // 하단: 스킬 바
            if (skills.isNotEmpty) _buildSkillBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBars() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.xs),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HP Bar
          Row(
            children: [
              const Icon(Icons.favorite, color: MGColors.error, size: 16),
              const SizedBox(width: MGSpacing.xs),
              Expanded(
                child: MGLinearProgress(
                  value: hp / maxHp,
                  height: 12,
                  backgroundColor: MGColors.error.withValues(alpha: 0.3),
                  progressColor: MGColors.error,
                ),
              ),
              const SizedBox(width: MGSpacing.xs),
              Text(
                '$hp',
                style: MGTextStyles.caption.copyWith(
                  color: MGColors.textHighEmphasis,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: MGSpacing.xs),
          // Energy Bar
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.yellow, size: 16),
              const SizedBox(width: MGSpacing.xs),
              Expanded(
                child: MGLinearProgress(
                  value: energy / maxEnergy,
                  height: 10,
                  backgroundColor: Colors.yellow.withValues(alpha: 0.3),
                  progressColor: Colors.yellow,
                ),
              ),
              const SizedBox(width: MGSpacing.xs),
              Text(
                '$energy',
                style: MGTextStyles.caption.copyWith(
                  color: MGColors.textHighEmphasis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.primaryAction.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.primaryAction),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'STAGE $stage',
            style: MGTextStyles.buttonMedium.copyWith(
              color: MGColors.textHighEmphasis,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Wave $wave',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreAndPause() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 점수
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MGSpacing.sm,
            vertical: MGSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: MGColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(MGSpacing.xs),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.star, color: MGColors.gold, size: 16),
              const SizedBox(width: MGSpacing.xs),
              Text(
                '$score',
                style: MGTextStyles.buttonMedium.copyWith(
                  color: MGColors.textHighEmphasis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: MGSpacing.xs),
        // 일시정지
                if (onGuildWar != null)
                  MGIconButton(
                    icon: Icons.shield,
                    onPressed: onGuildWar!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onTournament != null)
                  MGIconButton(
                    icon: Icons.emoji_events,
                    onPressed: onTournament!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onSeasonalEvent != null)
                  MGIconButton(
                    icon: Icons.celebration,
                    onPressed: onSeasonalEvent!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onDailyHub != null)
                  MGIconButton(
                    icon: Icons.calendar_today,
                    onPressed: onDailyHub!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
        if (onPause != null)
          MGIconButton(
            icon: Icons.pause,
            onPressed: onPause!,
            buttonSize: MGIconButtonSize.small,
          ),
      ],
    );
  }

  Widget _buildSkillBar() {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: skills.map((skill) => _buildSkillButton(skill)).toList(),
      ),
    );
  }

  Widget _buildSkillButton(SkillInfo skill) {
    final bool canUse = skill.currentCooldown <= 0;

    return GestureDetector(
      onTap: canUse ? skill.onTap : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: canUse
              ? skill.color.withValues(alpha: 0.3)
              : MGColors.common.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(MGSpacing.sm),
          border: Border.all(
            color: canUse ? skill.color : MGColors.common,
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              skill.icon,
              color: canUse ? skill.color : MGColors.common,
              size: 28,
            ),
            if (!canUse)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(MGSpacing.sm),
                ),
                child: Center(
                  child: Text(
                    '${skill.currentCooldown}',
                    style: MGTextStyles.h3.copyWith(
                      color: MGColors.textHighEmphasis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SkillInfo {
  final String name;
  final IconData icon;
  final Color color;
  final int currentCooldown;
  final int maxCooldown;
  final VoidCallback? onTap;
  final VoidCallback? onDailyHub;
  final VoidCallback? onGuildWar;
  final VoidCallback? onTournament;
  final VoidCallback? onSeasonalEvent;

  const SkillInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.currentCooldown,
    required this.maxCooldown,
    this.onTap,
  });
}

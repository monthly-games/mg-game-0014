import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class GameOverScreen extends StatelessWidget {
  final int finalStage;
  final int totalKills;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.finalStage,
    required this.totalKills,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(MGSpacing.xl),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skull icon
              const Icon(
                Icons.sentiment_very_dissatisfied,
                size: 80,
                color: MGColors.error,
              ),
              const SizedBox(height: MGSpacing.md),

              // Title
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: MGColors.error,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: MGSpacing.xl),

              // Stats
              _buildStatRow('최종 스테이지', '$finalStage'),
              const SizedBox(height: MGSpacing.sm),
              _buildStatRow('처치한 적', '$totalKills'),
              const SizedBox(height: MGSpacing.sm),
              _buildStatRow('생존 시간', _getPlayTime()),

              const SizedBox(height: MGSpacing.xxl),

              // Restart button
              ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MGColors.info,
                  foregroundColor: MGColors.textHighEmphasis,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 28),
                    SizedBox(width: MGSpacing.sm),
                    Text(
                      '다시 시작',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: MGColors.textHighEmphasis.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: MGColors.textHighEmphasis,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlayTime() {
    // Estimate based on stage (avg 30s per stage)
    final seconds = finalStage * 30;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import '../../systems/tutorial_manager.dart';
import '../lab_game.dart';

class TutorialOverlay extends StatelessWidget {
  final LabGame game;
  final TutorialManager tutorialManager;

  const TutorialOverlay({
    Key? key,
    required this.game,
    required this.tutorialManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tutorialManager,
      builder: (context, child) {
        if (tutorialManager.isCompleted) return const SizedBox.shrink();

        final step = tutorialManager.currentStep;
        String title = '';
        String content = '';

        switch (step) {
          case TutorialStep.welcome:
            title = 'Welcome to the Lab!';
            content =
                'Match tiles to gather mana and defeat the failed experiments.';
            break;
          case TutorialStep.matchBasics:
            title = 'Matching';
            content =
                'Connect 3 or more tiles of the same color to attack.\nDiagonal matches work too!';
            break;
          case TutorialStep.skills:
            title = 'Skills';
            content =
                'Use gathered mana to cast powerful skills.\nCheck your skill bar below.';
            break;
          case TutorialStep.enemies:
            title = 'Enemies';
            content =
                'Enemies will attack you over time.\nDefeat them before your HP runs out!';
            break;
          case TutorialStep.completed:
            return const SizedBox.shrink();
        }

        return Container(
          color: Colors.black54,
          child: Center(
            child: Card(
              color: const Color(0xFF2A2A40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        tutorialManager.advance();
                        if (tutorialManager.isCompleted) {
                          game.resumeEngine(); // Unpause when done
                        }
                      },
                      child: Text(
                        step == TutorialStep.enemies
                            ? 'Start Experiment'
                            : 'Next',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

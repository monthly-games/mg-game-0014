import 'package:mg_common_game/systems/tutorial/tutorial.dart';

/// Tutorial configuration for MG-0014: Witch's Lab: Experimental Puzzle.
///
/// Placeholder tutorial steps — replace with localized strings
/// and add targetSelector for highlight positioning in production.
const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: "Witch's Lab: Experimental Puzzle Tutorial",
  steps: [
    TutorialStep(
      id: 'welcome',
      title: 'Welcome!',
      description: 'Solve puzzles and challenge your mind.',
      actionHint: 'Tap to continue',
    ),
    TutorialStep(
      id: 'basic_move',
      title: 'Make a Move',
      description: 'Tap or drag pieces to solve the puzzle.',
      actionHint: 'Tap to play',
      targetSelector: 'game_board',
    ),
    TutorialStep(
      id: 'scoring',
      title: 'Score Points',
      description: 'Clear more pieces for bigger combos.',
      actionHint: 'Tap to continue',
    ),
  ],
  skippable: true,
  showOnFirstLaunch: true,
  trigger: TutorialTrigger.firstLaunch,
);

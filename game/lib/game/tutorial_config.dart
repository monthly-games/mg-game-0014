import 'package:mg_common_game/systems/tutorial/tutorial.dart';

/// Tutorial configuration for MG-0014: Witch's Lab: Experimental Puzzle.
///
/// Placeholder tutorial steps -- replace with localized strings
/// and add targetKey for highlight positioning in production.
const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: "Witch's Lab: Experimental Puzzle Tutorial",
  skippable: true,
  steps: [
    TutorialStep(
      id: 'grid',
      title: '3개를 매치하세요',
      description: '같은 색 타일 3개를 연결하여 제거합니다.',
    ),
    TutorialStep(
      id: 'combo_area',
      title: '콤보를 만드세요',
      description: '연속 매치로 콤보 보너스를 획득하세요.',
    ),
    TutorialStep(
      id: 'powerup',
      title: '파워업을 사용하세요',
      description: '특수 타일을 만들어 강력한 효과를 발동하세요.',
    ),
    TutorialStep(
      id: 'goal_area',
      title: '보드를 클리어하세요',
      description: '목표를 달성하여 스테이지를 클리어하세요.',
    ),
  ],
);

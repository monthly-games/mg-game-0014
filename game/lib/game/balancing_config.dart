import 'package:mg_common_game/systems/balancing/balancing.dart';

/// Default balancing configuration for MG-0014: Witch's Lab: Experimental Puzzle.
///
/// Placeholder values -- override via RemoteConfig using
/// [BalancingManager.loadFromRemote] in production.
const kDefaultBalancingConfig = BalancingConfig(
  gameId: 'mg-0014',
  version: 1,
  currencies: [
    CurrencyConfig(id: 'gold', baseEarnRate: 5.0),
    CurrencyConfig(
      id: 'gems',
      baseEarnRate: 0.3,
    ),
  ],
  xpCurve: XpCurveConfig(baseXp: 100, maxLevel: 100),
  difficultyScaling: DifficultyScalingConfig(scalingFactor: 0.1),
  customParams: {
    'combo_multiplier': 1.5,
    'hint_cost': 10.0,
  },
);

import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Witch ────────────────────────────────────────────────────

const kWitchMeta = SpineAssetMeta(
  key: 'witch',
  path: 'spine/characters/witch',
  atlasPath: 'assets/spine/characters/witch/witch.atlas',
  skeletonPath: 'assets/spine/characters/witch/witch.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Golem ────────────────────────────────────────────────────

const kGolemMeta = SpineAssetMeta(
  key: 'golem',
  path: 'spine/characters/golem',
  atlasPath: 'assets/spine/characters/golem/golem.atlas',
  skeletonPath: 'assets/spine/characters/golem/golem.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Familiar ─────────────────────────────────────────────────

const kFamiliarMeta = SpineAssetMeta(
  key: 'familiar',
  path: 'spine/characters/familiar',
  atlasPath: 'assets/spine/characters/familiar/familiar.atlas',
  skeletonPath: 'assets/spine/characters/familiar/familiar.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

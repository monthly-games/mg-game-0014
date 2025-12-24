import '../puzzle/grid_manager.dart';

/// Skill types
enum SkillType {
  damage, // Direct damage to enemy
  heal, // Heal player
  buff, // Buff player stats
  debuff, // Debuff enemy
  aoe, // Area of effect damage
}

/// Skill data model
class SkillData {
  final String id;
  final String name;
  final String description;
  final TileType element; // Required element type
  final double manaCost; // Mana cost to use
  final SkillType type;
  final double baseValue; // Base effect value
  final double cooldown; // Cooldown in seconds
  final List<String> tags; // Tags for synergy system

  const SkillData({
    required this.id,
    required this.name,
    required this.description,
    required this.element,
    required this.manaCost,
    required this.type,
    required this.baseValue,
    required this.cooldown,
    required this.tags,
  });
}

/// Pre-defined skills (18 total)
class Skills {
  // === FIRE SKILLS (6) ===

  static const SkillData fireball = SkillData(
    id: 'fireball',
    name: '파이어볼',
    description: '적에게 불덩이를 던져 30 데미지를 줍니다.',
    element: TileType.fire,
    manaCost: 20,
    type: SkillType.damage,
    baseValue: 30,
    cooldown: 2.0,
    tags: ['fire', 'projectile'],
  );

  static const SkillData flameStorm = SkillData(
    id: 'flame_storm',
    name: '화염 폭풍',
    description: '불길이 휘몰아쳐 적에게 50 데미지를 줍니다.',
    element: TileType.fire,
    manaCost: 40,
    type: SkillType.aoe,
    baseValue: 50,
    cooldown: 5.0,
    tags: ['fire', 'aoe', 'strong'],
  );

  static const SkillData lavaField = SkillData(
    id: 'lava_field',
    name: '용암 장판',
    description: '용암 지대를 만들어 적에게 지속 피해를 줍니다.',
    element: TileType.fire,
    manaCost: 30,
    type: SkillType.debuff,
    baseValue: 15,
    cooldown: 8.0,
    tags: ['fire', 'dot', 'field'],
  );

  static const SkillData inferno = SkillData(
    id: 'inferno',
    name: '인페르노',
    description: '거대한 화염으로 적에게 80 데미지를 줍니다.',
    element: TileType.fire,
    manaCost: 60,
    type: SkillType.damage,
    baseValue: 80,
    cooldown: 10.0,
    tags: ['fire', 'ultimate', 'strong'],
  );

  static const SkillData fireShield = SkillData(
    id: 'fire_shield',
    name: '화염 보호막',
    description: '불의 장벽을 만들어 적의 공격을 반사합니다.',
    element: TileType.fire,
    manaCost: 25,
    type: SkillType.buff,
    baseValue: 10,
    cooldown: 12.0,
    tags: ['fire', 'defense', 'reflect'],
  );

  static const SkillData ignite = SkillData(
    id: 'ignite',
    name: '점화',
    description: '적을 불태워 화상 상태로 만듭니다.',
    element: TileType.fire,
    manaCost: 15,
    type: SkillType.debuff,
    baseValue: 8,
    cooldown: 3.0,
    tags: ['fire', 'dot', 'burn'],
  );

  // === WATER SKILLS (6) ===

  static const SkillData frostBolt = SkillData(
    id: 'frost_bolt',
    name: '냉기 화살',
    description: '얼음 화살로 적에게 25 데미지를 주고 감속시킵니다.',
    element: TileType.water,
    manaCost: 20,
    type: SkillType.damage,
    baseValue: 25,
    cooldown: 2.5,
    tags: ['water', 'projectile', 'slow'],
  );

  static const SkillData freeze = SkillData(
    id: 'freeze',
    name: '빙결',
    description: '적을 얼려 3초간 행동 불능 상태로 만듭니다.',
    element: TileType.water,
    manaCost: 35,
    type: SkillType.debuff,
    baseValue: 10,
    cooldown: 8.0,
    tags: ['water', 'cc', 'freeze'],
  );

  static const SkillData waterShield = SkillData(
    id: 'water_shield',
    name: '물의 방패',
    description: '물의 보호막으로 30 피해를 흡수합니다.',
    element: TileType.water,
    manaCost: 25,
    type: SkillType.buff,
    baseValue: 30,
    cooldown: 6.0,
    tags: ['water', 'defense', 'shield'],
  );

  static const SkillData iceSpike = SkillData(
    id: 'ice_spike',
    name: '얼음 창',
    description: '거대한 얼음 창으로 적에게 45 데미지를 줍니다.',
    element: TileType.water,
    manaCost: 35,
    type: SkillType.damage,
    baseValue: 45,
    cooldown: 4.0,
    tags: ['water', 'projectile', 'strong'],
  );

  static const SkillData blizzard = SkillData(
    id: 'blizzard',
    name: '블리자드',
    description: '눈보라로 적에게 60 데미지를 주고 감속시킵니다.',
    element: TileType.water,
    manaCost: 50,
    type: SkillType.aoe,
    baseValue: 60,
    cooldown: 10.0,
    tags: ['water', 'aoe', 'slow', 'ultimate'],
  );

  static const SkillData heal = SkillData(
    id: 'heal',
    name: '회복',
    description: 'HP를 40 회복합니다.',
    element: TileType.water,
    manaCost: 30,
    type: SkillType.heal,
    baseValue: 40,
    cooldown: 5.0,
    tags: ['water', 'heal'],
  );

  // === POISON SKILLS (3) ===

  static const SkillData poisonCloud = SkillData(
    id: 'poison_cloud',
    name: '독안개',
    description: '독 구름으로 적에게 지속 피해를 줍니다.',
    element: TileType.poison,
    manaCost: 25,
    type: SkillType.debuff,
    baseValue: 12,
    cooldown: 6.0,
    tags: ['poison', 'dot', 'aoe'],
  );

  static const SkillData toxicStrike = SkillData(
    id: 'toxic_strike',
    name: '맹독 주사',
    description: '맹독으로 적에게 35 데미지를 주고 중독시킵니다.',
    element: TileType.poison,
    manaCost: 30,
    type: SkillType.damage,
    baseValue: 35,
    cooldown: 4.0,
    tags: ['poison', 'projectile', 'dot'],
  );

  static const SkillData corrosion = SkillData(
    id: 'corrosion',
    name: '부식',
    description: '적의 방어력을 감소시키고 20 데미지를 줍니다.',
    element: TileType.poison,
    manaCost: 35,
    type: SkillType.debuff,
    baseValue: 20,
    cooldown: 7.0,
    tags: ['poison', 'debuff', 'defense_down'],
  );

  // === EARTH SKILLS (3) ===

  static const SkillData rockThrow = SkillData(
    id: 'rock_throw',
    name: '돌 투척',
    description: '돌을 던져 적에게 28 데미지를 줍니다.',
    element: TileType.earth,
    manaCost: 20,
    type: SkillType.damage,
    baseValue: 28,
    cooldown: 2.5,
    tags: ['earth', 'projectile'],
  );

  static const SkillData earthquake = SkillData(
    id: 'earthquake',
    name: '지진',
    description: '지진을 일으켜 적에게 55 데미지를 줍니다.',
    element: TileType.earth,
    manaCost: 45,
    type: SkillType.aoe,
    baseValue: 55,
    cooldown: 8.0,
    tags: ['earth', 'aoe', 'strong'],
  );

  static const SkillData regeneration = SkillData(
    id: 'regeneration',
    name: '재생',
    description: '지속적으로 HP를 회복합니다.',
    element: TileType.earth,
    manaCost: 40,
    type: SkillType.heal,
    baseValue: 30,
    cooldown: 10.0,
    tags: ['earth', 'heal', 'regen'],
  );

  /// Get all skills as a list
  static List<SkillData> getAllSkills() {
    return [
      // Fire
      fireball,
      flameStorm,
      lavaField,
      inferno,
      fireShield,
      ignite,
      // Water
      frostBolt,
      freeze,
      waterShield,
      iceSpike,
      blizzard,
      heal,
      // Poison
      poisonCloud,
      toxicStrike,
      corrosion,
      venomDart,
      plague,
      toxicExplosion,
      // Earth
      rockThrow,
      earthquake,
      regeneration,
      stoneSkin,
      mudSlide,
      meteor,
    ];
  }

  // === NEW POISON SKILLS ===

  static const SkillData venomDart = SkillData(
    id: 'venom_dart',
    name: '독침',
    description: '빠른 독침으로 20 데미지를 줍니다.',
    element: TileType.poison,
    manaCost: 15,
    type: SkillType.damage,
    baseValue: 20,
    cooldown: 1.5,
    tags: ['poison', 'projectile', 'fast'],
  );

  static const SkillData plague = SkillData(
    id: 'plague',
    name: '역병',
    description: '역병을 퍼뜨려 적을 약화시킵니다.',
    element: TileType.poison,
    manaCost: 45,
    type: SkillType.debuff,
    baseValue: 25,
    cooldown: 9.0,
    tags: ['poison', 'debuff', 'aoe'],
  );

  static const SkillData toxicExplosion = SkillData(
    id: 'toxic_explosion',
    name: '맹독 폭발',
    description: '축적된 독을 폭발시켜 70 데미지를 줍니다.',
    element: TileType.poison,
    manaCost: 55,
    type: SkillType.aoe,
    baseValue: 70,
    cooldown: 11.0,
    tags: ['poison', 'aoe', 'ultimate'],
  );

  // === NEW EARTH SKILLS ===

  static const SkillData stoneSkin = SkillData(
    id: 'stone_skin',
    name: '바위 피부',
    description: '방어력을 크게 높여 50 피해를 흡수합니다.',
    element: TileType.earth,
    manaCost: 35,
    type: SkillType.buff,
    baseValue: 50,
    cooldown: 12.0,
    tags: ['earth', 'defense', 'strong'],
  );

  static const SkillData mudSlide = SkillData(
    id: 'mud_slide',
    name: '진흙탕',
    description: '적의 속도를 크게 늦추고 15 데미지를 줍니다.',
    element: TileType.earth,
    manaCost: 25,
    type: SkillType.debuff,
    baseValue: 15,
    cooldown: 6.0,
    tags: ['earth', 'slow', 'aoe'],
  );

  static const SkillData meteor = SkillData(
    id: 'meteor',
    name: '메테오',
    description: '거대 운석을 소환해 90 데미지를 줍니다.',
    element: TileType.earth,
    manaCost: 70,
    type: SkillType.damage,
    baseValue: 90,
    cooldown: 15.0,
    tags: ['earth', 'ultimate', 'strong'],
  );

  /// Get skill by ID
  static SkillData? getSkillById(String id) {
    try {
      return getAllSkills().firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get skills by element
  static List<SkillData> getSkillsByElement(TileType element) {
    return getAllSkills().where((s) => s.element == element).toList();
  }

  /// Get skills by type
  static List<SkillData> getSkillsByType(SkillType type) {
    return getAllSkills().where((s) => s.type == type).toList();
  }
}

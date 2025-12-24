class EnemyData {
  final String id;
  final String name;
  final String spritePath; // Currently unused, for future sprite integration
  final double baseHp;
  final double baseDmg;
  final double attackInterval;
  final String description;

  const EnemyData({
    required this.id,
    required this.name,
    required this.spritePath,
    required this.baseHp,
    required this.baseDmg,
    required this.attackInterval,
    required this.description,
  });
}

class EnemyDatabase {
  static const EnemyData slime = EnemyData(
    id: 'slime',
    name: 'Slime',
    spritePath: 'enemy_slime.png',
    baseHp: 40.0,
    baseDmg: 5.0,
    attackInterval: 4.0,
    description: 'Weak but persistent.',
  );

  static const EnemyData bat = EnemyData(
    id: 'bat',
    name: 'Bat',
    spritePath: 'enemy_bat.png',
    baseHp: 30.0,
    baseDmg: 3.0,
    attackInterval: 2.5, // Fast attacker
    description: 'Fast annoying flyer.',
  );

  static const EnemyData golem = EnemyData(
    id: 'golem',
    name: 'Golem',
    spritePath: 'enemy_golem.png',
    baseHp: 120.0,
    baseDmg: 15.0,
    attackInterval: 6.0, // Slow attacker
    description: 'Tanky rock construct.',
  );

  static const EnemyData wolf = EnemyData(
    id: 'wolf',
    name: 'Dire Wolf',
    spritePath: 'enemy_wolf.png',
    baseHp: 60.0,
    baseDmg: 10.0,
    attackInterval: 3.5,
    description: 'Balanced predator.',
  );

  static const EnemyData skeleton = EnemyData(
    id: 'skeleton',
    name: 'Skeleton',
    spritePath: 'enemy_skeleton.png',
    baseHp: 50.0,
    baseDmg: 12.0,
    attackInterval: 4.5,
    description: 'Undead warrior.',
  );

  static const EnemyData bossDragon = EnemyData(
    id: 'boss_dragon',
    name: 'Red Dragon',
    spritePath: 'enemy_dragon.png',
    baseHp: 300.0,
    baseDmg: 20.0,
    attackInterval: 5.0,
    description: 'The master of the dungeon.',
  );

  static const List<EnemyData> allEnemies = [
    slime,
    bat,
    golem,
    wolf,
    skeleton,
    bossDragon,
  ];

  static EnemyData getEnemyForStage(int stage) {
    // Simple logic: Boss every 10 stages
    if (stage % 10 == 0) return bossDragon;

    // Logic: As stages progress, introduce harder enemies
    if (stage <= 2) return slime;
    if (stage <= 4) return bat;
    if (stage <= 6) return wolf;
    if (stage <= 8) return skeleton;

    // Random mix for higher stages (excluding boss)
    final list = [golem, wolf, skeleton, bat];
    return list[stage % list.length];
  }
}

enum SynergyType { fire, ice, poison }

class Skill {
  final String id;
  final String name;
  final String iconPath;
  final SynergyType type;
  final String description;

  const Skill({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.type,
    required this.description,
  });
}

class SkillDatabase {
  static const List<Skill> allSkills = [
    Skill(
      id: 'fire_ball',
      name: 'Fireball',
      iconPath: 'icon_skill_fire.png',
      type: SynergyType.fire,
      description: 'Deals fire damage.',
    ),
    Skill(
      id: 'ice_shard',
      name: 'Ice Shard',
      iconPath: 'icon_skill_ice.png',
      type: SynergyType.ice,
      description: 'Freezes enemies.',
    ),
    Skill(
      id: 'poison_cloud',
      name: 'Poison Cloud',
      iconPath: 'icon_skill_poison.png',
      type: SynergyType.poison,
      description: 'Poisons over time.',
    ),
    Skill(
      id: 'flame_pillar',
      name: 'Flame Pillar',
      iconPath: 'icon_skill_fire.png',
      type: SynergyType.fire,
      description: 'Vertical fire damage.',
    ),
    Skill(
      id: 'blizzard',
      name: 'Blizzard',
      iconPath: 'icon_skill_ice.png',
      type: SynergyType.ice,
      description: 'Slows entire screen.',
    ),
    Skill(
      id: 'toxic_sludge',
      name: 'Toxic Sludge',
      iconPath: 'icon_skill_poison.png',
      type: SynergyType.poison,
      description: 'Puddles of poison.',
    ),
  ];
}

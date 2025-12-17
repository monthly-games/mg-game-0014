import '../skill/skill_data.dart';

/// Synergy effect types
enum SynergyEffect {
  damageBoost, // Increase damage
  manaCostReduction, // Reduce mana cost
  cooldownReduction, // Reduce cooldown
  criticalChance, // Add critical hit chance
  lifeSteal, // Heal on damage
  areaExpansion, // Increase AOE range
  dotAmplify, // Increase damage over time
  shieldOnKill, // Gain shield when enemy dies
}

/// Synergy data model
class SynergyData {
  final String id;
  final String name;
  final String nameKr;
  final String description;
  final List<String> requiredTags; // Tags needed to activate
  final int minTagCount; // Minimum number of matching tags
  final SynergyEffect effect;
  final double effectValue; // Effect strength (e.g., 0.3 = 30% boost)

  const SynergyData({
    required this.id,
    required this.name,
    required this.nameKr,
    required this.description,
    required this.requiredTags,
    required this.minTagCount,
    required this.effect,
    required this.effectValue,
  });

  /// Check if synergy is active with given skills
  bool isActiveWith(List<SkillData> skills) {
    final allTags = skills.expand((s) => s.tags).toList();
    int matchCount = 0;

    for (final tag in requiredTags) {
      if (allTags.contains(tag)) {
        matchCount++;
      }
    }

    return matchCount >= minTagCount;
  }
}

/// Pre-defined synergies
class Synergies {
  // === ELEMENTAL MASTER SYNERGIES ===

  static const SynergyData fireMaster = SynergyData(
    id: 'fire_master',
    name: 'Pyromancer',
    nameKr: '화염 마스터',
    description: '화염 스킬 3개 이상 보유 시 모든 화염 데미지 +30%',
    requiredTags: ['fire', 'fire', 'fire'],
    minTagCount: 3,
    effect: SynergyEffect.damageBoost,
    effectValue: 0.3,
  );

  static const SynergyData waterMaster = SynergyData(
    id: 'water_master',
    name: 'Cryomancer',
    nameKr: '빙결 술사',
    description: '물 스킬 3개 이상 보유 시 마나 소비 -20%',
    requiredTags: ['water', 'water', 'water'],
    minTagCount: 3,
    effect: SynergyEffect.manaCostReduction,
    effectValue: 0.2,
  );

  static const SynergyData poisonMaster = SynergyData(
    id: 'poison_master',
    name: 'Toxicologist',
    nameKr: '독술사',
    description: '독 스킬 2개 이상 보유 시 지속 피해 +50%',
    requiredTags: ['poison', 'poison'],
    minTagCount: 2,
    effect: SynergyEffect.dotAmplify,
    effectValue: 0.5,
  );

  static const SynergyData earthMaster = SynergyData(
    id: 'earth_master',
    name: 'Geomancer',
    nameKr: '대지 술사',
    description: '대지 스킬 2개 이상 보유 시 치료 효과 +40%',
    requiredTags: ['earth', 'earth'],
    minTagCount: 2,
    effect: SynergyEffect.damageBoost, // Reuse for heal boost
    effectValue: 0.4,
  );

  // === PLAYSTYLE SYNERGIES ===

  static const SynergyData berserk = SynergyData(
    id: 'berserk',
    name: 'Berserker',
    nameKr: '광전사',
    description: '강력한 스킬 3개 보유 시 크리티컬 확률 +25%',
    requiredTags: ['strong', 'strong', 'strong'],
    minTagCount: 3,
    effect: SynergyEffect.criticalChance,
    effectValue: 0.25,
  );

  static const SynergyData rapidFire = SynergyData(
    id: 'rapid_fire',
    name: 'Quick Draw',
    nameKr: '속사포',
    description: '투사체 스킬 3개 보유 시 쿨다운 -30%',
    requiredTags: ['projectile', 'projectile', 'projectile'],
    minTagCount: 3,
    effect: SynergyEffect.cooldownReduction,
    effectValue: 0.3,
  );

  static const SynergyData aoeSpecialist = SynergyData(
    id: 'aoe_specialist',
    name: 'Area Master',
    nameKr: '광역 전문가',
    description: 'AOE 스킬 2개 보유 시 범위 피해 +35%',
    requiredTags: ['aoe', 'aoe'],
    minTagCount: 2,
    effect: SynergyEffect.areaExpansion,
    effectValue: 0.35,
  );

  static const SynergyData lifeLeech = SynergyData(
    id: 'life_leech',
    name: 'Vampire',
    nameKr: '흡혈',
    description: '독 스킬 + 화염 스킬 조합 시 피해의 15% 흡혈',
    requiredTags: ['poison', 'fire'],
    minTagCount: 2,
    effect: SynergyEffect.lifeSteal,
    effectValue: 0.15,
  );

  // === DEFENSIVE SYNERGIES ===

  static const SynergyData fortified = SynergyData(
    id: 'fortified',
    name: 'Fortified',
    nameKr: '방어 태세',
    description: '방어 스킬 2개 보유 시 적 처치 시 보호막 획득',
    requiredTags: ['defense', 'defense'],
    minTagCount: 2,
    effect: SynergyEffect.shieldOnKill,
    effectValue: 20, // Shield amount
  );

  static const SynergyData healingAura = SynergyData(
    id: 'healing_aura',
    name: 'Healing Aura',
    nameKr: '치유의 오라',
    description: '치유 스킬 2개 보유 시 치료량 +30%',
    requiredTags: ['heal', 'heal'],
    minTagCount: 2,
    effect: SynergyEffect.damageBoost, // Reuse for heal
    effectValue: 0.3,
  );

  /// Get all synergies
  static List<SynergyData> getAllSynergies() {
    return [
      // Elemental
      fireMaster,
      waterMaster,
      poisonMaster,
      earthMaster,
      // Playstyle
      berserk,
      rapidFire,
      aoeSpecialist,
      lifeLeech,
      // Defensive
      fortified,
      healingAura,
    ];
  }

  /// Get synergy by ID
  static SynergyData? getSynergyById(String id) {
    try {
      return getAllSynergies().firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get active synergies for skill set
  static List<SynergyData> getActiveSynergies(List<SkillData> skills) {
    return getAllSynergies().where((s) => s.isActiveWith(skills)).toList();
  }
}

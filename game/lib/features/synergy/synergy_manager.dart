import 'package:flutter/foundation.dart';
import 'synergy_data.dart';
import '../skill/skill_data.dart';

/// Manages active synergies and applies their effects
class SynergyManager extends ChangeNotifier {
  List<SynergyData> _activeSynergies = [];
  List<SynergyData> get activeSynergies => List.unmodifiable(_activeSynergies);

  /// Update synergies based on current skills
  void updateSynergies(List<SkillData> activeSkills) {
    final newSynergies = Synergies.getActiveSynergies(activeSkills);

    // Check if synergies changed
    if (!_synergiesEqual(newSynergies, _activeSynergies)) {
      _activeSynergies = newSynergies;
      notifyListeners();

      // Log synergy changes
      if (_activeSynergies.isNotEmpty) {
        print('🌟 Active Synergies (${_activeSynergies.length}):');
        for (final syn in _activeSynergies) {
          print('  - ${syn.nameKr}: ${syn.description}');
        }
      }
    }
  }

  /// Check if two synergy lists are equal
  bool _synergiesEqual(List<SynergyData> a, List<SynergyData> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((s) => s.id).toSet();
    final bIds = b.map((s) => s.id).toSet();
    return aIds.difference(bIds).isEmpty;
  }

  /// Apply synergy effects to skill damage
  double applyDamageBonus(SkillData skill, double baseDamage) {
    double totalBonus = 0.0;

    for (final synergy in _activeSynergies) {
      if (synergy.effect == SynergyEffect.damageBoost) {
        // Check if synergy applies to this skill
        if (_synergyAppliesToSkill(synergy, skill)) {
          totalBonus += synergy.effectValue;
        }
      }

      if (synergy.effect == SynergyEffect.areaExpansion &&
          skill.type == SkillType.aoe) {
        totalBonus += synergy.effectValue;
      }

      if (synergy.effect == SynergyEffect.dotAmplify &&
          skill.tags.contains('dot')) {
        totalBonus += synergy.effectValue;
      }
    }

    return baseDamage * (1.0 + totalBonus);
  }

  /// Apply synergy effects to mana cost
  double applyManaCostReduction(SkillData skill, double baseCost) {
    double totalReduction = 0.0;

    for (final synergy in _activeSynergies) {
      if (synergy.effect == SynergyEffect.manaCostReduction) {
        if (_synergyAppliesToSkill(synergy, skill)) {
          totalReduction += synergy.effectValue;
        }
      }
    }

    return baseCost * (1.0 - totalReduction.clamp(0.0, 0.8)); // Max 80% reduction
  }

  /// Apply synergy effects to cooldown
  double applyCooldownReduction(SkillData skill, double baseCooldown) {
    double totalReduction = 0.0;

    for (final synergy in _activeSynergies) {
      if (synergy.effect == SynergyEffect.cooldownReduction) {
        if (_synergyAppliesToSkill(synergy, skill)) {
          totalReduction += synergy.effectValue;
        }
      }
    }

    return baseCooldown * (1.0 - totalReduction.clamp(0.0, 0.7)); // Max 70% reduction
  }

  /// Get critical chance bonus
  double getCriticalChance() {
    double critChance = 0.0;

    for (final synergy in _activeSynergies) {
      if (synergy.effect == SynergyEffect.criticalChance) {
        critChance += synergy.effectValue;
      }
    }

    return critChance.clamp(0.0, 0.75); // Max 75% crit
  }

  /// Get life steal percentage
  double getLifeSteal() {
    double lifeSteal = 0.0;

    for (final synergy in _activeSynergies) {
      if (synergy.effect == SynergyEffect.lifeSteal) {
        lifeSteal += synergy.effectValue;
      }
    }

    return lifeSteal.clamp(0.0, 0.5); // Max 50% life steal
  }

  /// Check if shield on kill is active
  bool hasShieldOnKill() {
    return _activeSynergies.any((s) => s.effect == SynergyEffect.shieldOnKill);
  }

  /// Get shield amount on kill
  double getShieldOnKillAmount() {
    for (final synergy in _activeSynergies) {
      if (synergy.effect == SynergyEffect.shieldOnKill) {
        return synergy.effectValue;
      }
    }
    return 0.0;
  }

  /// Check if synergy applies to specific skill
  bool _synergyAppliesToSkill(SynergyData synergy, SkillData skill) {
    // Check if skill has any of the required tags
    for (final tag in synergy.requiredTags) {
      if (skill.tags.contains(tag)) {
        return true;
      }
    }
    return false;
  }

  /// Get synergy description with current bonus
  String getSynergyInfo(SynergyData synergy) {
    final effectStr = switch (synergy.effect) {
      SynergyEffect.damageBoost => '+${(synergy.effectValue * 100).toInt()}% 데미지',
      SynergyEffect.manaCostReduction =>
        '-${(synergy.effectValue * 100).toInt()}% 마나',
      SynergyEffect.cooldownReduction =>
        '-${(synergy.effectValue * 100).toInt()}% 쿨다운',
      SynergyEffect.criticalChance =>
        '+${(synergy.effectValue * 100).toInt()}% 크리티컬',
      SynergyEffect.lifeSteal => '+${(synergy.effectValue * 100).toInt()}% 흡혈',
      SynergyEffect.areaExpansion => '+${(synergy.effectValue * 100).toInt()}% 범위',
      SynergyEffect.dotAmplify => '+${(synergy.effectValue * 100).toInt()}% DOT',
      SynergyEffect.shieldOnKill => '+${synergy.effectValue.toInt()} 보호막',
    };

    return '${synergy.nameKr} ($effectStr)';
  }

  /// Check if specific synergy is active
  bool hasSynergy(String synergyId) {
    return _activeSynergies.any((s) => s.id == synergyId);
  }

  /// Get count of active synergies
  int get synergyCount => _activeSynergies.length;
}

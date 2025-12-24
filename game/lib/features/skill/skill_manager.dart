import 'package:flutter/foundation.dart';
import 'dart:math';
import 'skill_data.dart';
import '../player/player_data.dart';
import '../synergy/synergy_manager.dart';

/// Manages player skills, cooldowns, and skill usage
class SkillManager extends ChangeNotifier {
  // Acquired skills (unlocked through gameplay)
  final List<SkillData> _acquiredSkills = [];
  List<SkillData> get acquiredSkills => List.unmodifiable(_acquiredSkills);

  // Active skills (equipped skills, max 6)
  final List<SkillData> _activeSkills = [];
  List<SkillData> get activeSkills => List.unmodifiable(_activeSkills);
  final int maxActiveSkills = 6;

  // Cooldown tracking (skill id -> remaining time)
  final Map<String, double> _cooldowns = {};

  // Synergy manager reference
  SynergyManager? synergyManager;

  /// Add skill to acquired skills
  void acquireSkill(SkillData skill) {
    if (!_acquiredSkills.contains(skill)) {
      _acquiredSkills.add(skill);

      // Auto-equip if there's space
      if (_activeSkills.length < maxActiveSkills) {
        equipSkill(skill);
      }

      notifyListeners();
    }
  }

  /// Equip skill to active slot
  bool equipSkill(SkillData skill) {
    if (!_acquiredSkills.contains(skill)) return false;
    if (_activeSkills.contains(skill)) return false;
    if (_activeSkills.length >= maxActiveSkills) return false;

    _activeSkills.add(skill);
    _updateSynergies();
    notifyListeners();
    return true;
  }

  /// Unequip skill from active slot
  void unequipSkill(SkillData skill) {
    _activeSkills.remove(skill);
    _updateSynergies();
    notifyListeners();
  }

  /// Update synergies when skills change
  void _updateSynergies() {
    synergyManager?.updateSynergies(_activeSkills);
  }

  /// Check if skill can be used
  bool canUseSkill(SkillData skill, PlayerData player) {
    // Check if skill is active
    if (!_activeSkills.contains(skill)) return false;

    // Check mana (with synergy reduction)
    final actualCost =
        synergyManager?.applyManaCostReduction(skill, skill.manaCost) ??
        skill.manaCost;
    if (!player.mana.containsKey(skill.element)) return false;
    if (player.mana[skill.element]! < actualCost) return false;

    // Check cooldown
    if (_cooldowns.containsKey(skill.id)) {
      if (_cooldowns[skill.id]! > 0) return false;
    }

    return true;
  }

  /// Use skill and trigger effects
  void useSkill(
    SkillData skill,
    PlayerData player, {
    Function(double)? onDamage,
    Function(double)? onHeal,
  }) {
    if (!canUseSkill(skill, player)) return;

    // Apply synergy bonuses
    final actualCost =
        synergyManager?.applyManaCostReduction(skill, skill.manaCost) ??
        skill.manaCost;
    final actualCooldown =
        synergyManager?.applyCooldownReduction(skill, skill.cooldown) ??
        skill.cooldown;
    final critChance = synergyManager?.getCriticalChance() ?? 0.0;
    final lifeSteal = synergyManager?.getLifeSteal() ?? 0.0;

    // Consume mana
    player.consumeMana(skill.element, actualCost);

    // Calculate damage/heal with synergy bonuses
    double effectValue = skill.baseValue;

    // Apply damage bonus from synergies
    if (skill.type == SkillType.damage ||
        skill.type == SkillType.aoe ||
        skill.type == SkillType.debuff) {
      effectValue =
          synergyManager?.applyDamageBonus(skill, effectValue) ?? effectValue;
    }

    // Apply critical hit
    final rand = Random();
    bool isCrit = rand.nextDouble() < critChance;
    if (isCrit &&
        (skill.type == SkillType.damage || skill.type == SkillType.aoe)) {
      effectValue *= 2.0;
      print('💥 CRITICAL HIT! ${effectValue.toInt()} damage');
    }

    // Apply skill effect
    switch (skill.type) {
      case SkillType.damage:
      case SkillType.aoe:
        if (onDamage != null) onDamage(effectValue);

        // Apply life steal
        if (lifeSteal > 0) {
          final healAmount = effectValue * lifeSteal;
          player.takeDamage(-healAmount);
          print('💉 Life steal: ${healAmount.toInt()} HP');
        }
        break;
      case SkillType.heal:
        // Apply heal synergy bonus
        effectValue =
            synergyManager?.applyDamageBonus(skill, effectValue) ?? effectValue;
        if (onHeal != null) onHeal(effectValue);
        player.takeDamage(-effectValue); // Negative damage = heal
        break;
      case SkillType.buff:
        // TODO: Apply buff effects
        break;
      case SkillType.debuff:
        if (onDamage != null) onDamage(effectValue * 0.5);
        // TODO: Apply debuff effects
        break;
    }

    // Start cooldown (with synergy reduction)
    _cooldowns[skill.id] = actualCooldown;

    notifyListeners();
  }

  /// Update cooldowns each frame
  void updateCooldowns(double dt) {
    bool updated = false;

    for (final key in _cooldowns.keys.toList()) {
      _cooldowns[key] = (_cooldowns[key]! - dt).clamp(0, double.infinity);

      if (_cooldowns[key]! <= 0) {
        _cooldowns.remove(key);
        updated = true;
      }
    }

    if (updated) notifyListeners();
  }

  /// Get remaining cooldown for skill
  double getCooldown(SkillData skill) {
    return _cooldowns[skill.id] ?? 0.0;
  }

  /// Get cooldown ratio (0 = ready, 1 = just used)
  double getCooldownRatio(SkillData skill) {
    final remaining = getCooldown(skill);
    if (remaining <= 0) return 0.0;
    return (remaining / skill.cooldown).clamp(0.0, 1.0);
  }

  /// Check if skill is on cooldown
  bool isOnCooldown(SkillData skill) {
    return getCooldown(skill) > 0;
  }

  /// Initialize with starter skills
  void initializeStarter() {
    _acquiredSkills.clear();
    _activeSkills.clear();
    _cooldowns.clear();

    // Give 3 starter skills (one of each element)
    acquireSkill(Skills.fireball);
    acquireSkill(Skills.frostBolt);
    acquireSkill(Skills.rockThrow);

    notifyListeners();
  }

  /// Reset all cooldowns
  void resetCooldowns() {
    _cooldowns.clear();
    notifyListeners();
  }

  // Persistence
  Map<String, dynamic> toJson() {
    return {
      'acquiredSkills': _acquiredSkills.map((s) => s.id).toList(),
      'activeSkills': _activeSkills.map((s) => s.id).toList(),
      'cooldowns': _cooldowns,
    };
  }

  void load(Map<String, dynamic> json) {
    _acquiredSkills.clear();
    _activeSkills.clear();
    _cooldowns.clear();

    final acquiredIds = List<String>.from(json['acquiredSkills'] ?? []);
    final activeIds = List<String>.from(json['activeSkills'] ?? []);
    final savedCooldowns = Map<String, dynamic>.from(json['cooldowns'] ?? {});

    // Restore acquired skills
    for (final id in acquiredIds) {
      final skill = Skills.getAllSkills().firstWhere(
        (s) => s.id == id,
        orElse: () => Skills.fireball, // Safety fallback
      );
      if (!_acquiredSkills.contains(skill)) {
        _acquiredSkills.add(skill);
      }
    }

    // Restore active skills
    for (final id in activeIds) {
      final skill = Skills.getAllSkills().firstWhere(
        (s) => s.id == id,
        orElse: () => Skills.fireball, // Safety fallback
      );
      if (_acquiredSkills.contains(skill) && !_activeSkills.contains(skill)) {
        _activeSkills.add(skill);
      }
    }

    // Restore cooldowns
    savedCooldowns.forEach((key, value) {
      _cooldowns[key] = (value as num).toDouble();
    });

    notifyListeners();
  }
}

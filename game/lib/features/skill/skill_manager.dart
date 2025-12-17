import 'package:flutter/foundation.dart';
import 'skill_data.dart';
import '../puzzle/grid_manager.dart';
import '../player/player_data.dart';

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
    notifyListeners();
    return true;
  }

  /// Unequip skill from active slot
  void unequipSkill(SkillData skill) {
    _activeSkills.remove(skill);
    notifyListeners();
  }

  /// Check if skill can be used
  bool canUseSkill(SkillData skill, PlayerData player) {
    // Check if skill is active
    if (!_activeSkills.contains(skill)) return false;

    // Check mana
    if (!player.mana.containsKey(skill.element)) return false;
    if (player.mana[skill.element]! < skill.manaCost) return false;

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

    // Consume mana
    player.consumeMana(skill.element, skill.manaCost);

    // Apply skill effect
    switch (skill.type) {
      case SkillType.damage:
      case SkillType.aoe:
        if (onDamage != null) onDamage(skill.baseValue);
        break;
      case SkillType.heal:
        if (onHeal != null) onHeal(skill.baseValue);
        player.takeDamage(-skill.baseValue); // Negative damage = heal
        break;
      case SkillType.buff:
        // TODO: Apply buff effects
        break;
      case SkillType.debuff:
        if (onDamage != null) onDamage(skill.baseValue * 0.5);
        // TODO: Apply debuff effects
        break;
    }

    // Start cooldown
    _cooldowns[skill.id] = skill.cooldown;

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
}

import 'package:flutter/foundation.dart';
import 'dart:math';
import '../skill/skill_model.dart';

class DraftManager extends ChangeNotifier {
  final List<Skill> _mySkills = [];
  List<Skill> get mySkills => List.unmodifiable(_mySkills);

  // Draft State
  List<Skill> _draftOptions = [];
  List<Skill> get draftOptions => List.unmodifiable(_draftOptions);

  bool _isDrafting = false;
  bool get isDrafting => _isDrafting;

  final Random _rng = Random();

  void startDraft() {
    _isDrafting = true;
    _generateOptions();
    notifyListeners();
  }

  void _generateOptions() {
    // Pick 3 random unique skills
    final pool = List<Skill>.from(SkillDatabase.allSkills);
    pool.shuffle(_rng);
    _draftOptions = pool.take(3).toList();
  }

  void pickSkill(Skill skill) {
    _mySkills.add(skill);
    _isDrafting = false;
    _draftOptions = [];
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TutorialStep {
  welcome, // Intro dialog
  matchBasics, // Explain matching tiles
  skills, // Explain skills and mana
  enemies, // Explain enemy attacks
  completed, // Tutorial finished
}

class TutorialManager extends ChangeNotifier {
  TutorialStep _currentStep = TutorialStep.welcome;

  TutorialStep get currentStep => _currentStep;
  bool get isCompleted => _currentStep == TutorialStep.completed;

  static const String _storageKey = 'lab_tutorial_step';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_storageKey) ?? 0;
    if (index < TutorialStep.values.length) {
      _currentStep = TutorialStep.values[index];
    } else {
      _currentStep = TutorialStep.completed;
    }
    notifyListeners();
  }

  Future<void> advance() async {
    if (isCompleted) return;

    final nextIndex = _currentStep.index + 1;
    if (nextIndex < TutorialStep.values.length) {
      _currentStep = TutorialStep.values[nextIndex];
    } else {
      _currentStep = TutorialStep.completed;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, _currentStep.index);
  }

  Future<void> reset() async {
    _currentStep = TutorialStep.welcome;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, _currentStep.index);
  }
}

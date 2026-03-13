import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameTutorialStep {
  welcome, // Intro dialog
  matchBasics, // Explain matching tiles
  skills, // Explain skills and mana
  enemies, // Explain enemy attacks
  completed, // Tutorial finished
}

class GameTutorialManager extends ChangeNotifier {
  GameTutorialStep _currentStep = GameTutorialStep.welcome;

  GameTutorialStep get currentStep => _currentStep;
  bool get isCompleted => _currentStep == GameTutorialStep.completed;

  static const String _storageKey = 'lab_tutorial_step';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_storageKey) ?? 0;
    if (index < GameTutorialStep.values.length) {
      _currentStep = GameTutorialStep.values[index];
    } else {
      _currentStep = GameTutorialStep.completed;
    }
    notifyListeners();
  }

  Future<void> advance() async {
    if (isCompleted) return;

    final nextIndex = _currentStep.index + 1;
    if (nextIndex < GameTutorialStep.values.length) {
      _currentStep = GameTutorialStep.values[nextIndex];
    } else {
      _currentStep = GameTutorialStep.completed;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, _currentStep.index);
  }

  Future<void> reset() async {
    _currentStep = GameTutorialStep.welcome;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, _currentStep.index);
  }
}

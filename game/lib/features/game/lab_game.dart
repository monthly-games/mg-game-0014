import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LabGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF220033); // Dark Purple

  @override
  Future<void> onLoad() async {
    // Background
    add(
      SpriteComponent()
        ..sprite = await loadSprite('bg_witch_lab.png')
        ..size = size
        ..priority = 0,
    );

    // TODO: Add visual elements for the "Puzzle" or "Experiment"
    // For now, it's a visual backdrop for the drafted skills
  }
}

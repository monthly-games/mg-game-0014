import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'dart:math';
import 'components/particle_factory.dart';
import '../features/puzzle/grid_manager.dart';
import '../features/puzzle/tile_component.dart';
import '../features/player/player_data.dart';
import '../features/skill/skill_manager.dart';
import '../features/stage/stage_manager.dart';
import 'components/enemy_component.dart';
import 'components/skill_projectile.dart';
import '../features/skill/skill_data.dart';
import '../features/enemy/enemy_data.dart';
import '../systems/run_save_manager.dart';

import 'package:mg_common_game/core/ui/components/floating_text_component.dart';

class LabGame extends FlameGame {
  final GridManager gridManager = GridManager();
  final double tileSize = 50.0;
  final Vector2 gridOffset = Vector2(20, 100);

  // Roguelike Elements
  final PlayerData playerData = PlayerData();
  final SkillManager skillManager = SkillManager();
  final StageManager stageManager = StageManager();
  EnemyComponent? _currentEnemy;
  EnemyComponent? get currentEnemy => _currentEnemy;

  @override
  Color backgroundColor() => AppColors.background;

  // HUD
  late TextComponent _playerHpText;
  late TextComponent _manaText;
  late TextComponent _stageText;

  @override
  Future<void> onLoad() async {
    // Background
    add(
      SpriteComponent(
        sprite: await loadSprite('bg_witch_lab.png'),
        size: size,
        position: Vector2.zero(),
      ),
    );

    final audioManager = GetIt.I<AudioManager>();
    audioManager.playBgm('bgm_lab.mp3', volume: 0.5);

    skillManager.initializeStarter();

    await _initPersistence(); // Load save if exists
    await _initTutorial(); // Check tutorial status

    stageManager.addListener(_onStageStateChanged);

    _spawnGrid();
    _spawnEnemy();
    updateStageDisplay();

    // Stage display
    _stageText = TextComponent(
      text: "Stage 1",
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_stageText);

    _playerHpText = TextComponent(
      text: "HP: 100",
      position: Vector2(20, size.y - 50),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
    add(_playerHpText);

    _manaText = TextComponent(
      text: "Mana: 0/0/0/0",
      position: Vector2(20, size.y - 25),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.cyan, fontSize: 16),
      ),
    );
    add(_manaText);

    playerData.addListener(() {
      _playerHpText.text =
          "HP: ${playerData.hp.toInt()}/${playerData.maxHp.toInt()}";
      _manaText.text =
          "Mana: 🔥${playerData.mana[TileType.fire]!.toInt()} "
          "💧${playerData.mana[TileType.water]!.toInt()} "
          "☠${playerData.mana[TileType.poison]!.toInt()} "
          "🌿${playerData.mana[TileType.earth]!.toInt()}";
    });
  }

  void _onStageStateChanged() {
    if (stageManager.isPlaying) {
      if (_currentEnemy == null || _currentEnemy!.isRemoved) {
        respawnEnemy();
      }
    }
  }

  void updateStageDisplay() {
    final stage = stageManager.currentStage;
    final emoji = stageManager.getStageColor();
    _stageText.text = "$emoji Stage $stage";
  }

  @override
  void update(double dt) {
    super.update(dt);
    skillManager.updateCooldowns(dt);
  }

  void _spawnEnemy() {
    if (_currentEnemy != null) _currentEnemy!.removeFromParent();

    final stage = stageManager.currentStage;
    final enemyData = EnemyDatabase.getEnemyForStage(stage);

    // Scale stats from database
    final enemyHp =
        enemyData.baseHp * pow(1.2, stage - 1); // 20% increase per stage
    final enemyDmg = enemyData.baseDmg * pow(1.1, stage - 1); // 10% increase

    print(
      "Spawning ${enemyData.name} (HP: ${enemyHp.toInt()}, DMG: ${enemyDmg.toInt()})",
    );

    _currentEnemy = EnemyComponent(
      position: Vector2(size.x / 2, 80), // Top Center
      maxHp: enemyHp,
      damage: enemyDmg,
      attackInterval: enemyData.attackInterval, // Use unique speed
      onAttack: (dmg) {
        playerData.takeDamage(dmg);
        // print("Player Stats: HP ${playerData.hp}/${playerData.maxHp}");
        if (playerData.isDead()) {
          _saveManager.clearSave();
          stageManager.onPlayerDeath();
        }
      },
      onDeath: () {
        print("Enemy Slain!");
        stageManager.onEnemyDefeated();

        // Show reward screen after delay
        Future.delayed(const Duration(milliseconds: 500), () {
          stageManager.showRewardScreen();
        });
      },
    );
    // scale logic...
    add(_currentEnemy!);

    // Auto-save on new stage start (or end of previous)
    _saveGame();
  }

  /// Respawn enemy for next stage
  void respawnEnemy() {
    updateStageDisplay();
    _spawnEnemy();
  }

  /// Reset game for new run
  void resetGame() {
    playerData.reset();
    stageManager.resetGame();
    skillManager.resetCooldowns();
    _saveManager.clearSave(); // Clear old save
    _saveGame(); // Save new start
  }

  // Save/Load Logic
  late final RunSaveManager _saveManager;

  Future<void> _initPersistence() async {
    _saveManager = RunSaveManager(
      playerData: playerData,
      stageManager: stageManager,
      skillManager: skillManager,
    );

    if (await _saveManager.hasSave()) {
      await _saveManager.loadRun();
      // Sync UI and State
      updateStageDisplay();
      // If we loaded into a specific state, handle it?
      // For now, loading assumes we are at start of a stage or similar.
      // If we were mid-battle, enemy spawn needs to check loaded HP?
      // Simplified: We spawn enemy based on stage.
      // Ideally persistence saves enemy state too, but let's stick to Run persistence for now.
    }
  }

  Future<void> _saveGame() async {
    await _saveManager.saveRun();
  }

  void _spawnGrid() {
    children.whereType<TileComponent>().forEach((t) => t.removeFromParent());

    for (int r = 0; r < gridManager.rows; r++) {
      for (int c = 0; c < gridManager.cols; c++) {
        final tileType = gridManager.grid[r][c];
        final isSelected =
            _selectedTile != null &&
            _selectedTile!.x == r &&
            _selectedTile!.y == c;

        add(
          TileComponent(
            row: r,
            col: c,
            type: tileType,
            onTapTile: _onTileTapped,
            position:
                gridOffset +
                Vector2(c * tileSize, r * tileSize + 100), // Push grid down
            size: Vector2.all(tileSize),
            isSelected: isSelected,
          ),
        );
      }
    }
  }

  // Swap Logic
  Point<int>? _selectedTile;

  void _onTileTapped(int r, int c) {
    if (playerData.isDead()) return;

    if (_selectedTile == null) {
      _selectedTile = Point(r, c);
      _spawnGrid(); // Refresh to show selection
    } else {
      final r1 = _selectedTile!.x;
      final c1 = _selectedTile!.y;

      if (r1 == r && c1 == c) {
        // Deselect
        _selectedTile = null;
        _spawnGrid();
      } else {
        // Attempt Swap
        final success = gridManager.swap(r1, c1, r, c);
        if (success) {
          _selectedTile = null;

          // Match & Cascade Logic
          _handleMatches();
        } else {
          _selectedTile = Point(r, c); // Change selection
          _spawnGrid();
        }
      }
    }
  }

  void _handleMatches() async {
    bool hasMatches = true;
    while (hasMatches) {
      final matches = gridManager.checkMatches();
      if (matches.isEmpty) {
        hasMatches = false;
        break;
      }

      // Apply Effects
      for (final m in matches) {
        // print("Matched ${m.count} of ${m.type}");
        try {
          GetIt.I<AudioManager>().playSfx('match.wav');
        } catch (_) {}
        _applyEffect(m.type, m.count);
      }

      // Refill
      gridManager.refillGrid();

      // Render
      _spawnGrid();

      // Delay for visual (optional, but good for loop)
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void spawnFloatingText(String text, Vector2 position, Color color) {
    add(
      FloatingTextComponent(
        text: text,
        position: position,
        color: color,
        fontSize: 24,
      ),
    );
  }

  void _applyEffect(TileType type, int count) {
    if (_currentEnemy == null) return;

    // Mana gain instead of direct damage
    double manaGain = count * 8.0; // 3 -> 24, 4 -> 32

    // Spawn Particles (Visual Feedback)
    add(
      ParticleFactory.createMatchBurst(
        position: Vector2(size.x / 2, size.y / 2),
        color: _getColor(type),
      ),
    );

    // Gain mana based on tile type
    if (type != TileType.empty) {
      playerData.gainMana(type, manaGain);
      spawnFloatingText(
        '+${manaGain.toInt()}',
        Vector2(size.x / 2, size.y / 2 + 50),
        _getColor(type),
      );
      // print("Gained $manaGain $type mana. Current: ${playerData.mana[type]}");
    }
  }

  void spawnSkillEffect(SkillData skill) {
    if (_currentEnemy == null) return;

    add(
      SkillProjectile(
        type: skill.element,
        startPosition: Vector2(
          size.x / 2,
          size.y - 100,
        ), // Start from player area
        targetPosition: _currentEnemy!.position,
        onHit: () {
          // Visual impact effect
          add(
            ParticleFactory.createSkillExplosion(
              position: _currentEnemy!.position,
              color: _getColor(skill.element),
            ),
          );

          // Audio
          try {
            // scalable sfx based on element could go here
            GetIt.I<AudioManager>().playSfx(
              'explosion.wav',
              pitch: 1.0 + Random().nextDouble() * 0.5,
            );
          } catch (_) {}
        },
      ),
    );
  }

  Color _getColor(TileType type) {
    switch (type) {
      case TileType.fire:
        return Colors.redAccent;
      case TileType.water:
        return Colors.blueAccent;
      case TileType.earth:
        return Colors.greenAccent;
      case TileType.poison:
        return Colors.purpleAccent;
      case TileType.empty:
        return Colors.white;
    }
  }
}

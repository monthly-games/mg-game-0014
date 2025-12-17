import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'dart:math';
import 'components/simple_particle.dart';
import '../features/puzzle/grid_manager.dart';
import '../features/puzzle/tile_component.dart';
import '../features/player/player_data.dart';
import '../features/skill/skill_manager.dart';
import '../features/skill/skill_data.dart';
import '../features/stage/stage_manager.dart';
import 'components/enemy_component.dart';

class LabGame extends FlameGame {
  final GridManager gridManager = GridManager();
  final double tileSize = 50.0;
  final Vector2 gridOffset = Vector2(20, 100);

  // Roguelike Elements
  final PlayerData playerData = PlayerData();
  SkillManager? skillManager;
  StageManager? stageManager;
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
    _spawnGrid();
    _spawnEnemy();

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
      _playerHpText.text = "HP: ${playerData.hp.toInt()}/${playerData.maxHp.toInt()}";
      _manaText.text =
          "Mana: 🔥${playerData.mana[TileType.fire]!.toInt()} "
          "💧${playerData.mana[TileType.water]!.toInt()} "
          "☠${playerData.mana[TileType.poison]!.toInt()} "
          "🌿${playerData.mana[TileType.earth]!.toInt()}";
    });
  }

  void updateStageDisplay() {
    final stage = stageManager?.currentStage ?? 1;
    final emoji = stageManager?.getStageColor() ?? '🟢';
    _stageText.text = "$emoji Stage $stage";
  }

  @override
  void update(double dt) {
    super.update(dt);
    skillManager?.updateCooldowns(dt);
  }

  void _spawnEnemy() {
    if (_currentEnemy != null) _currentEnemy!.removeFromParent();

    final stage = stageManager?.currentStage ?? 1;
    final enemyHp = stageManager?.getEnemyHp(stage) ?? 50.0;
    final enemyDmg = stageManager?.getEnemyDamage(stage) ?? 10.0;
    final attackInterval = stageManager?.getEnemyAttackSpeed(stage) ?? 5.0;

    _currentEnemy = EnemyComponent(
      position: Vector2(size.x / 2, 80), // Top Center
      maxHp: enemyHp,
      damage: enemyDmg,
      attackInterval: attackInterval,
      onAttack: (dmg) {
        playerData.takeDamage(dmg);
        print("Player Stats: HP ${playerData.hp}/${playerData.maxHp}");
        if (playerData.isDead()) {
          stageManager?.onPlayerDeath();
        }
      },
      onDeath: () {
        print("Enemy Slain!");
        stageManager?.onEnemyDefeated();

        // Show reward screen after delay
        Future.delayed(const Duration(milliseconds: 500), () {
          stageManager?.showRewardScreen();
        });
      },
    );
    add(_currentEnemy!);
  }

  /// Respawn enemy for next stage
  void respawnEnemy() {
    updateStageDisplay();
    _spawnEnemy();
  }

  /// Reset game for new run
  void resetGame() {
    playerData.reset();
    updateStageDisplay();
    _spawnEnemy();
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

  void _applyEffect(TileType type, int count) {
    if (_currentEnemy == null) return;

    // Mana gain instead of direct damage
    double manaGain = count * 8.0; // 3 -> 24, 4 -> 32

    // Spawn Particles (Visual Feedback)
    final rand = Random();
    for (int i = 0; i < 10; i++) {
      add(
        SimpleParticle(
          position:
              Vector2(size.x / 2, size.y / 2) +
              Vector2(
                (rand.nextDouble() - 0.5) * 100,
                (rand.nextDouble() - 0.5) * 100,
              ),
          velocity: Vector2(
            (rand.nextDouble() - 0.5) * 200,
            (rand.nextDouble() - 0.5) * 200,
          ),
          color: _getColor(type),
        ),
      );
    }

    // Gain mana based on tile type
    if (type != TileType.empty) {
      playerData.gainMana(type, manaGain);
      print("Gained $manaGain $type mana. Current: ${playerData.mana[type]}");
    }
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

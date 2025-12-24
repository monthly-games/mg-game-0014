import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyComponent extends PositionComponent with HasGameRef {
  late double hp;
  final double maxHp;
  final double damage;

  double attackTimer = 0.0;
  final double attackInterval;

  final Function(double) onAttack;
  final VoidCallback onDeath;

  EnemyComponent({
    required this.onAttack,
    required this.onDeath,
    required Vector2 position,
    this.maxHp = 50.0,
    this.damage = 10.0,
    this.attackInterval = 5.0,
  }) : super(position: position, size: Vector2(80, 80), anchor: Anchor.center) {
    hp = maxHp;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (hp <= 0) return;

    attackTimer += dt;
    if (attackTimer >= attackInterval) {
      attackTimer = 0;
      onAttack(damage);
    }
  }

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _sprite = await gameRef.loadSprite('enemy_lab_monster.png');
    } catch (e) {
      print('Failed to load enemy sprite: $e');
    }
  }

  @override
  void render(Canvas canvas) {
    if (hp <= 0) return;

    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    } else {
      // Fallback
      canvas.drawCircle(
        Offset(width / 2, height / 2),
        width / 2,
        Paint()..color = Colors.deepPurple,
      );
    }

    // HP Bar
    final hpRatio = hp / maxHp;
    canvas.drawRect(
      Rect.fromLTWH(0, -15, width, 8),
      Paint()..color = Colors.black,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -15, width * hpRatio.clamp(0, 1), 8),
      Paint()..color = Colors.red,
    );

    // Attack Timer Bar
    final timerRatio = attackTimer / attackInterval;
    canvas.drawRect(
      Rect.fromLTWH(0, height + 5, width, 5),
      Paint()..color = Colors.black,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, height + 5, width * timerRatio.clamp(0, 1), 5),
      Paint()..color = Colors.orange,
    );
  }

  void takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) {
      onDeath();
      removeFromParent();
    }
  }
}

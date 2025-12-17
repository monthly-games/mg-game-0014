import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyComponent extends PositionComponent {
  double hp = 50.0;
  final double maxHp = 50.0;

  double attackTimer = 0.0;
  final double attackInterval = 5.0; // Attack every 5s

  final Function(double) onAttack;
  final VoidCallback onDeath;

  EnemyComponent({
    required this.onAttack,
    required this.onDeath,
    required Vector2 position,
  }) : super(position: position, size: Vector2(80, 80), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (hp <= 0) return;

    attackTimer += dt;
    if (attackTimer >= attackInterval) {
      attackTimer = 0;
      onAttack(10.0); // Deal 10 damage
    }
  }

  @override
  void render(Canvas canvas) {
    if (hp <= 0) return;

    // Body
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = Colors.deepPurple,
    );

    // Eyes
    canvas.drawCircle(
      Offset(width * 0.3, height * 0.4),
      5,
      Paint()..color = Colors.red,
    );
    canvas.drawCircle(
      Offset(width * 0.7, height * 0.4),
      5,
      Paint()..color = Colors.red,
    );

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

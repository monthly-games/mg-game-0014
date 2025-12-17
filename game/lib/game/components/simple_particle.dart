import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SimpleParticle extends PositionComponent {
  final Vector2 velocity;
  final double lifeTime;
  final Color color;
  final double radius;

  double _timer = 0;

  SimpleParticle({
    required Vector2 position,
    required this.velocity,
    this.lifeTime = 0.5,
    this.color = Colors.white,
    this.radius = 4.0,
  }) : super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= lifeTime) {
      removeFromParent();
      return;
    }

    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (_timer / lifeTime)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()..color = color.withOpacity(opacity),
    );
  }
}

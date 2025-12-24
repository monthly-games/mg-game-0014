import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../features/puzzle/grid_manager.dart';

class SkillProjectile extends PositionComponent {
  final TileType type;
  final Vector2 targetPosition;
  final VoidCallback? onHit;
  final double speed = 600.0;

  SkillProjectile({
    required this.type,
    required Vector2 startPosition,
    required this.targetPosition,
    this.onHit,
  }) : super(
         position: startPosition,
         size: Vector2(20, 20),
         anchor: Anchor.center,
       );

  @override
  void update(double dt) {
    super.update(dt);

    final direction = (targetPosition - position).normalized();
    position += direction * speed * dt;

    if (position.distanceTo(targetPosition) < 10) {
      onHit?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _getColor(type);

    if (type == TileType.fire) {
      // Triangle for Fire
      final path = Path()
        ..moveTo(width / 2, 0)
        ..lineTo(width, height)
        ..lineTo(0, height)
        ..close();
      canvas.drawPath(path, paint);
    } else if (type == TileType.earth) {
      // Square for Earth
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    } else {
      // Circle for others
      canvas.drawCircle(Offset(width / 2, height / 2), width / 2, paint);
    }

    // Core
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 4,
      Paint()..color = Colors.white,
    );
  }

  Color _getColor(TileType type) {
    switch (type) {
      case TileType.fire:
        return Colors.orange;
      case TileType.water:
        return Colors.blue;
      case TileType.earth:
        return Colors.green;
      case TileType.poison:
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}

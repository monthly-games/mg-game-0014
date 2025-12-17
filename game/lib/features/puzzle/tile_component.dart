import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'grid_manager.dart';

class TileComponent extends PositionComponent with TapCallbacks {
  final int row;
  final int col;
  final TileType type;
  final Function(int, int) onTapTile;

  final bool isSelected;

  TileComponent({
    required this.row,
    required this.col,
    required this.type,
    required this.onTapTile,
    required Vector2 position,
    required Vector2 size,
    this.isSelected = false,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    var paint = Paint()..color = _getColor(type);

    // Draw rounded rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, width - 4, height - 4),
        const Radius.circular(8),
      ),
      paint,
    );

    // Draw Border
    final borderColor = isSelected
        ? Colors.yellow
        : Colors.white.withOpacity(0.5);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4 : 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, width - 4, height - 4),
        const Radius.circular(8),
      ),
      borderPaint,
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
        return Colors.transparent;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapTile(row, col);
  }
}

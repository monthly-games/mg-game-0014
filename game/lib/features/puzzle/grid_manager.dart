import 'package:flutter/foundation.dart';
import 'dart:math';

enum TileType {
  fire, // Red
  water, // Blue
  earth, // Green
  poison, // Purple
  empty,
}

class GridManager extends ChangeNotifier {
  final int rows = 8;
  final int cols = 6;
  late List<List<TileType>> grid;

  GridManager() {
    _initGrid();
  }

  void _initGrid() {
    final rand = Random();
    grid = List.generate(
      rows,
      (y) => List.generate(cols, (x) {
        return TileType.values[rand.nextInt(4)]; // Exclude empty
      }),
    );
  }

  // Check for matches (horizontal and vertical)
  List<MatchResult> checkMatches() {
    List<MatchResult> matches = [];

    // Horizontal
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 2; c++) {
        final t = grid[r][c];
        if (t == TileType.empty) continue;
        if (grid[r][c + 1] == t && grid[r][c + 2] == t) {
          int len = 3;
          while (c + len < cols && grid[r][c + len] == t) {
            len++;
          }
          matches.add(MatchResult(type: t, count: len));
          // Mark for removal (simplified)
          for (int k = 0; k < len; k++) {
            grid[r][c + k] = TileType.empty;
          }
          c += len - 1;
        }
      }
    }

    // Vertical
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows - 2; r++) {
        final t = grid[r][c];
        if (t == TileType.empty) continue;
        if (grid[r + 1][c] == t && grid[r + 2][c] == t) {
          int len = 3;
          while (r + len < rows && grid[r + len][c] == t) {
            len++;
          }
          matches.add(MatchResult(type: t, count: len));
          for (int k = 0; k < len; k++) {
            grid[r + k][c] = TileType.empty;
          }
          r += len - 1;
        }
      }
    }

    return matches;
  }

  void refillGrid() {
    final rand = Random();
    // Drop down
    for (int c = 0; c < cols; c++) {
      for (int r = rows - 1; r >= 0; r--) {
        if (grid[r][c] == TileType.empty) {
          // Find nearest non-empty above
          int nr = r - 1;
          while (nr >= 0 && grid[nr][c] == TileType.empty) {
            nr--;
          }

          if (nr >= 0) {
            grid[r][c] = grid[nr][c];
            grid[nr][c] = TileType.empty;
          } else {
            // Fill new
            grid[r][c] = TileType.values[rand.nextInt(4)];
          }
        }
      }
    }
  }

  // Basic Swap Logic placeholder
  bool swap(int r1, int c1, int r2, int c2) {
    // Check adjacency
    if ((r1 - r2).abs() + (c1 - c2).abs() != 1) return false;

    final temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = temp;

    // In real match-3, check matches here. If no match, swap back.
    notifyListeners();
    return true;
  }
}

class MatchResult {
  final TileType type;
  final int count;
  MatchResult({required this.type, required this.count});
}

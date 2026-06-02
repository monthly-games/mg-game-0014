import 'dart:math';
import 'package:flutter/foundation.dart';
import '../features/puzzle/grid_manager.dart';
import 'package:mg_common_game/core/ui/components/floating_text_component.dart';
import 'package:flame/components.dart';

/// Combo chain data for tracking multi-match sequences.
class ComboChain {
  final int chainCount;
  final int totalMatches;
  final double chainMultiplier;
  final DateTime startTime;

  const ComboChain({
    required this.chainCount,
    required this.totalMatches,
    required this.chainMultiplier,
    required this.startTime,
  });

  /// Get duration since chain started.
  Duration get duration => DateTime.now().difference(startTime);
}

/// Combo rarity tier with visual and gameplay effects.
enum ComboRarity {
  common,
  rare,
  epic,
  legendary,
}

class ComboSystem extends ChangeNotifier {
  static const int _comboTimeoutMs = 2500; // 2.5 seconds to continue combo
  static const int _baseChainMultiplier = 10; // percent per chain level

  int _currentChain = 0;
  int _totalMatchesInChain = 0;
  DateTime? _lastMatchTime;
  int _highestChain = 0;
  int _totalCombosCompleted = 0;

  // Statistics
  int _totalMatchesAllTime = 0;
  Map<TileType, int> _typeMatches = {
    TileType.fire: 0,
    TileType.water: 0,
    TileType.earth: 0,
    TileType.poison: 0,
  };

  // Getters
  int get currentChain => _currentChain;
  double get chainMultiplier =>
      min(3.0, 1.0 + (_currentChain * _baseChainMultiplier / 100));
  bool get isChainActive => _lastMatchTime != null &&
      DateTime.now().difference(_lastMatchTime!).inMilliseconds < _comboTimeoutMs;
  int get highestChain => _highestChain;
  int get totalCombosCompleted => _totalCombosCompleted;
  Map<TileType, int> get typeMatches => Map.unmodifiable(_typeMatches);

  /// Get current combo rarity tier.
  ComboRarity get currentRarity {
    if (_currentChain >= 8) return ComboRarity.legendary;
    if (_currentChain >= 5) return ComboRarity.epic;
    if (_currentChain >= 3) return ComboRarity.rare;
    return ComboRarity.common;
  }

  /// Get color for combo rarity display.
  static String rarityEmoji(ComboRarity rarity) {
    switch (rarity) {
      case ComboRarity.common:
        return '⚪';
      case ComboRarity.rare:
        return '🔵';
      case ComboRarity.epic:
        return '🟣';
      case ComboRarity.legendary:
        return '🟡';
    }
  }

  /// Record a match and update combo chain.
  /// Returns the chain multiplier for this match.
  double recordMatch(TileType type, int matchCount) {
    final now = DateTime.now();

    // Check if chain expired
    if (!isChainActive) {
      _endChain();
      _currentChain = 0;
      _totalMatchesInChain = 0;
    }

    // Update chain state
    _currentChain++;
    _totalMatchesInChain += matchCount;
    _lastMatchTime = now;
    _totalMatchesAllTime += matchCount;
    _typeMatches[type] = (_typeMatches[type] ?? 0) + matchCount;

    // Track highest chain
    if (_currentChain > _highestChain) {
      _highestChain = _currentChain;
    }

    notifyListeners();
    return chainMultiplier;
  }

  /// End current combo chain and record statistics.
  void _endChain() {
    if (_currentChain > 0) {
      _totalCombosCompleted++;
    }
  }

  /// Manually end combo (e.g., when player dies or stage changes).
  void resetCombo() {
    _endChain();
    _currentChain = 0;
    _totalMatchesInChain = 0;
    _lastMatchTime = null;
    notifyListeners();
  }

  /// Get detailed combo chain info.
  ComboChain? get currentChainInfo {
    if (!isChainActive || _currentChain == 0) return null;

    return ComboChain(
      chainCount: _currentChain,
      totalMatches: _totalMatchesInChain,
      chainMultiplier: chainMultiplier,
      startTime: _lastMatchTime!,
    );
  }

  /// Get remaining time in combo window (seconds).
  double get remainingComboSeconds {
    if (_lastMatchTime == null) return 0.0;
    final elapsed = DateTime.now().difference(_lastMatchTime!).inMilliseconds;
    return ((_comboTimeoutMs - elapsed) / 1000).clamp(0.0, _comboTimeoutMs / 1000);
  }

  /// Reset all statistics (for new run).
  void reset() {
    resetCombo();
    _highestChain = 0;
    _totalCombosCompleted = 0;
    _totalMatchesAllTime = 0;
    _typeMatches.updateAll((key, value) => 0);
    notifyListeners();
  }
}
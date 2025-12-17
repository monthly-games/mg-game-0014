import 'package:flutter/foundation.dart';
import '../puzzle/grid_manager.dart';

class PlayerData extends ChangeNotifier {
  double hp = 100.0;
  final double maxHp = 100.0;

  // Mana for each element (0 to 100)
  Map<TileType, double> mana = {
    TileType.fire: 0,
    TileType.water: 0,
    TileType.earth: 0,
    TileType.poison: 0,
  };
  final double maxMana = 100.0;

  void takeDamage(double amount) {
    hp = (hp - amount).clamp(0, maxHp);
    notifyListeners();
  }

  void gainMana(TileType type, double amount) {
    if (mana.containsKey(type)) {
      mana[type] = (mana[type]! + amount).clamp(0, maxMana);
      notifyListeners();
    }
  }

  void consumeMana(TileType type, double amount) {
    if (mana.containsKey(type)) {
      mana[type] = (mana[type]! - amount).clamp(0, maxMana);
      notifyListeners();
    }
  }

  bool isDead() => hp <= 0;
}

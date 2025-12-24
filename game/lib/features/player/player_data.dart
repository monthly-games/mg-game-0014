import 'package:flutter/foundation.dart';
import '../puzzle/grid_manager.dart';
import '../meta/meta_manager.dart';

class PlayerData extends ChangeNotifier {
  double hp = 100.0;
  double maxHp = 100.0;

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

  void increaseMaxHp(double amount) {
    maxHp += amount;
    hp += amount; // Also heal
    notifyListeners();
  }

  void reset() {
    final meta = MetaManager();
    maxHp = 100.0 + meta.bonusMaxHp;
    hp = maxHp;

    final startMana = meta.bonusStartMana;
    mana = {
      TileType.fire: startMana,
      TileType.water: startMana,
      TileType.earth: startMana,
      TileType.poison: startMana,
    };
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

  // Persistence
  Map<String, dynamic> toJson() {
    return {
      'hp': hp,
      'maxHp': maxHp,
      'mana': mana.map((key, value) => MapEntry(key.index.toString(), value)),
    };
  }

  void load(Map<String, dynamic> json) {
    hp = (json['hp'] as num).toDouble();
    maxHp = (json['maxHp'] as num).toDouble();

    final manaJson = json['mana'] as Map<String, dynamic>;
    mana = manaJson.map(
      (key, value) =>
          MapEntry(TileType.values[int.parse(key)], (value as num).toDouble()),
    );

    notifyListeners();
  }
}

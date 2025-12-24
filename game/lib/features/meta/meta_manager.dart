import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetaManager extends ChangeNotifier {
  // Singleton
  static final MetaManager _instance = MetaManager._internal();
  factory MetaManager() => _instance;
  MetaManager._internal();

  // Currency
  int _researchPoints = 0;
  int get researchPoints => _researchPoints;

  // Unlocks (Node IDs)
  final Set<String> _unlockedNodes = {};
  Set<String> get unlockedNodes => Set.unmodifiable(_unlockedNodes);

  // Persistence Keys
  static const String _keyRP = 'meta_rp';
  static const String _keyUnlocks = 'meta_unlocks';

  // Stats (derived from unlocks)
  double get bonusMaxHp {
    int count = _unlockedNodes.where((id) => id.startsWith('hp_')).length;
    return count * 10.0; // +10 HP per node
  }

  double get bonusStartMana {
    int count = _unlockedNodes.where((id) => id.startsWith('mana_')).length;
    return count * 10.0; // +10 Mana per node
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _researchPoints = prefs.getInt(_keyRP) ?? 0;

    final unlocksList = prefs.getStringList(_keyUnlocks) ?? [];
    _unlockedNodes.clear();
    _unlockedNodes.addAll(unlocksList);

    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRP, _researchPoints);
    await prefs.setStringList(_keyUnlocks, _unlockedNodes.toList());
  }

  void addResearchPoints(int amount) {
    _researchPoints += amount;
    save();
    notifyListeners();
  }

  bool canPurchase(String nodeId, int cost) {
    if (_unlockedNodes.contains(nodeId)) return false; // Already owned
    return _researchPoints >= cost;
  }

  void purchaseUpgrade(String nodeId, int cost) {
    if (canPurchase(nodeId, cost)) {
      _researchPoints -= cost;
      _unlockedNodes.add(nodeId);
      save();
      notifyListeners();
    }
  }

  // Debug/Reset
  Future<void> resetProgress() async {
    _researchPoints = 0;
    _unlockedNodes.clear();
    await save();
    notifyListeners();
  }
}

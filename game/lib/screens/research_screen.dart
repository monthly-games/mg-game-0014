import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/meta/meta_manager.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0022),
      appBar: AppBar(
        title: const Text("RESEARCH LAB"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: MetaManager(),
        builder: (context, child) {
          final mm = MetaManager();
          return Column(
            children: [
              // Header (RP Display)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.science,
                      color: Colors.cyanAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${mm.researchPoints} RP",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24),

              // Upgrade Tree (Simple List for now)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildNode(
                      id: "hp_1",
                      title: "Vitality I",
                      desc: "Start with +10 Max HP.",
                      cost: 100,
                      icon: Icons.favorite,
                      color: Colors.redAccent,
                    ),
                    _buildNode(
                      id: "hp_2",
                      title: "Vitality II",
                      desc: "Start with +20 Max HP.",
                      cost: 250,
                      icon: Icons.favorite,
                      color: Colors.redAccent,
                    ),
                    _buildNode(
                      id: "mana_1",
                      title: "Mana Affinity I",
                      desc: "Start with +10 Mana in all elements.",
                      cost: 150,
                      icon: Icons.water_drop,
                      color: Colors.blueAccent,
                    ),
                    _buildNode(
                      id: "mana_2",
                      title: "Mana Affinity II",
                      desc: "Start with +20 Mana in all elements.",
                      cost: 300,
                      icon: Icons.water_drop,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              // Debug Buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => mm.addResearchPoints(100),
                      child: const Text("DEBUG: +100 RP"),
                    ),
                    TextButton(
                      onPressed: () => mm.resetProgress(),
                      child: const Text(
                        "DEBUG: RESET",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNode({
    required String id,
    required String title,
    required String desc,
    required int cost,
    required IconData icon,
    required Color color,
  }) {
    final mm = MetaManager();
    final isUnlocked = mm.unlockedNodes.contains(id);
    final canAfford = mm.canPurchase(id, cost);

    return Card(
      color: isUnlocked ? color.withOpacity(0.2) : Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isUnlocked
              ? color
              : (canAfford ? Colors.white54 : Colors.transparent),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked ? color : Colors.grey[800],
          child: Icon(icon, color: isUnlocked ? Colors.white : Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isUnlocked ? color : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(desc, style: const TextStyle(color: Colors.white70)),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? color : Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: canAfford
                    ? () => mm.purchaseUpgrade(id, cost)
                    : null,
                child: Text("$cost RP"),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../features/meta/meta_manager.dart';
import '../systems/run_save_manager.dart';
import 'game_screen.dart';
import 'research_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

bool _hasSave = false;

@override
void initState() {
  super.initState();
  _initFuture = _init();
}

Future<void> _init() async {
  await MetaManager().load();
  _hasSave = await RunSaveManager.checkSaveExists();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF1a0022),
    body: FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "WITCH'S LAB",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: Colors.purple,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Experimental Puzzle",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 80),
              if (_hasSave) ...[
                _MenuButton(
                  label: "CONTINUE EXPERIMENT",
                  color: Colors.green,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
              _MenuButton(
                label: _hasSave ? "NEW EXPERIMENT" : "START EXPERIMENT",
                color: Colors.purple,
                onPressed: () {
                  // Logic to clear save if exists?
                  // For now, GameScreen handles loading if save exists.
                  // To force new game, we should probably clear save here or pass flag.
                  // But simpler: just go to GameScreen, if they clicked NEW, we want to reset.
                  // Let's pass a flag to GameScreen or clear save here.
                  // Safest: Clear save here if New Game.
                  _startNewGame(context);
                },
              ),
              const SizedBox(height: 20),
              _MenuButton(
                label: "RESEARCH LAB",
                color: Colors.cyan[800]!, // Dark cyan
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ResearchScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _MenuButton(
                label: "SETTINGS",
                color: Colors.blueGrey,
                onPressed: () {
                  // TODO: Settings
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> _startNewGame(BuildContext context) async {
  if (_hasSave) {
    // Confirm overwrite
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Experiment?'),
        content: const Text('This will discard your current progress.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard & Start'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await RunSaveManager.checkSaveExists(); // Just helper? No, need clear.
    // We can't easily clear without instance or static clear.
    // Let's add static clear to RunSaveManager too.
    await RunSaveManager.clearSaveStatic();
  }

  if (!mounted) return;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const GameScreen()),
  );
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.white24),
          ),
          elevation: 8,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

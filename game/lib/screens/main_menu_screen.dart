import 'package:flutter/material.dart';

import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

import '../features/meta/meta_manager.dart';
import '../systems/run_save_manager.dart';
import 'game_screen.dart';
import 'research_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late final Future<void> _initFuture;
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
      backgroundColor: const Color(0xFF1A0022),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1A237E)),
                child: Text(
                  'Community',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text('Guild War'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/guild-war');
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Tournament'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/tournament');
                },
              ),
              ListTile(
                leading: const Icon(Icons.celebration),
                title: const Text('Seasonal Event'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/seasonal-event');
                },
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<void>(
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
                  'Experimental Puzzle',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 80),
                if (_hasSave) ...[
                  _MenuButton(
                    label: 'CONTINUE EXPERIMENT',
                    color: MGColors.success,
                    onPressed: () {
    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const GameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                _MenuButton(
                  label: _hasSave ? 'NEW EXPERIMENT' : 'START EXPERIMENT',
                  color: Colors.purple,
                  onPressed: () => _startNewGame(context),
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  label: 'RESEARCH LAB',
                  color: Colors.cyan[800]!,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ResearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _MenuButton(
                  label: 'SETTINGS',
                  color: Colors.blueGrey,
                  onPressed: null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _startNewGame(BuildContext ctx) async {
    if (_hasSave) {
      final confirm = await showDialog<bool>(
        context: ctx,
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

      if (confirm != true) {
        return;
      }

      await RunSaveManager.clearSaveStatic();
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

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
          foregroundColor: MGColors.textHighEmphasis,
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

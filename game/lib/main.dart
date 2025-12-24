import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'features/draft/draft_manager.dart';
import 'screens/main_menu_screen.dart';

import 'package:mg_common_game/core/systems/save_manager_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();

  // Unified Persistence
  await SaveManagerHelper.setupSaveManager(
    autoSaveEnabled: true,
    autoSaveIntervalSeconds: 30,
  );
  await SaveManagerHelper.legacyLoadAll();

  runApp(const WitchLabApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class WitchLabApp extends StatelessWidget {
  const WitchLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DraftManager())],
      child: MaterialApp(
        title: "Witch's Lab",
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1a0022),
          primaryColor: Colors.purple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}

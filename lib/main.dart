import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'ads/unity_ads_service.dart';
import 'game/audio/game_audio.dart';
import 'game/core/ricochet_game.dart';
import 'game/save/game_progress.dart';
import 'game/ui/hud.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false;
  await GameProgress.instance.load();
  await GameAudio.instance.initialize();
  await UnityAdsService.instance.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: '.SF UI Text',
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const HomeScreen(),
    ),
  );
}

class RicochetGameScreen extends StatelessWidget {
  const RicochetGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget<RicochetGame>.controlled(
      gameFactory: RicochetGame.new,
      overlayBuilderMap: {'hud': (context, game) => HudOverlay(game: game)},
      initialActiveOverlays: const ['hud'],
    );
  }
}

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/core/ricochet_game.dart';
import 'game/ui/hud.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameWidget<RicochetGame>.controlled(
        gameFactory: RicochetGame.new,
        overlayBuilderMap: {
          'hud': (context, game) => HudOverlay(game: game),
        },
        initialActiveOverlays: const ['hud'],
      ),
    ),
  );
}

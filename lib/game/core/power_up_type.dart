import 'dart:ui';

import 'constants.dart';

enum PowerUpType { multiBall, heavyBall, piercingBall }

extension PowerUpTypeLabel on PowerUpType {
  String get label => switch (this) {
    PowerUpType.multiBall => 'Multi-Ball',
    PowerUpType.heavyBall => 'Heavy Ball',
    PowerUpType.piercingBall => 'Piercing',
  };

  String get shortLabel => switch (this) {
    PowerUpType.multiBall => 'MULTI',
    PowerUpType.heavyBall => 'HEAVY',
    PowerUpType.piercingBall => 'PIERCE',
  };

  String get glyph => switch (this) {
    PowerUpType.multiBall => '2',
    PowerUpType.heavyBall => 'H',
    PowerUpType.piercingBall => 'P',
  };

  Color get color => switch (this) {
    PowerUpType.multiBall => GameColors.neonCyan,
    PowerUpType.heavyBall => GameColors.warning,
    PowerUpType.piercingBall => GameColors.danger,
  };
}

import 'dart:math';

import '../models/daily_challenge.dart';
import 'preferences_service.dart';

class DailyChallengeService {
  DailyChallenge getDailyChallenge() {
    final random = Random();
    final type =
        ChallengeType.values[random.nextInt(ChallengeType.values.length)];
    switch (type) {
      case ChallengeType.tSpins:
        return DailyChallenge(
          type: type,
          description: 'Clear 5 T-spins',
          target: 5,
        );
      case ChallengeType.linesInTime:
        return DailyChallenge(
          type: type,
          description: 'Reach 10 lines in under 30 seconds',
          target: 10,
        );
    }
  }

  void completeChallenge(DailyChallenge challenge) {
    challenge.isCompleted = true;
    final preferences = PreferencesService();
    final random = Random();
    if (random.nextBool()) {
      // Unlock a theme
      final themes = ['retroNeon', 'monochrome', 'cyberpunk'];
      preferences.unlockTheme(themes[random.nextInt(themes.length)]);
    } else {
      // Unlock a skin
      final skins = ['glossy', 'pixelArt'];
      preferences.unlockSkin(skins[random.nextInt(skins.length)]);
    }
  }
}

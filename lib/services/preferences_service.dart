import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  // High scores
  static const String highScoreClassicKey = 'highScore_classic';
  static const String highScoreSprintKey = 'highScore_sprint';
  static const String highScoreMarathonKey = 'highScore_marathon';
  static const String highScoreZenKey = 'highScore_zen';

  // Overall stats
  static const String totalLinesClearedKey = 'totalLinesCleared';
  static const String totalBlocksDroppedKey = 'totalBlocksDropped';
  static const String totalTimePlayedKey = 'totalTimePlayed';
  static const String totalGamesPlayedKey = 'totalGamesPlayed';
  static const String totalPerfectClearsKey = 'totalPerfectClears';
  static const String bestComboKey = 'bestCombo';
  static const String highestLevelKey = 'highestLevel';

  // Per-mode stats
  static const String gamesPlayedClassicKey = 'gamesPlayed_classic';
  static const String gamesPlayedSprintKey = 'gamesPlayed_sprint';
  static const String gamesPlayedMarathonKey = 'gamesPlayed_marathon';
  static const String gamesPlayedZenKey = 'gamesPlayed_zen';

  static const String avgScoreClassicKey = 'avgScore_classic';
  static const String avgScoreSprintKey = 'avgScore_sprint';
  static const String avgScoreMarathonKey = 'avgScore_marathon';
  static const String avgScoreZenKey = 'avgScore_zen';

  static const String bestLevelClassicKey = 'bestLevel_classic';
  static const String bestLevelSprintKey = 'bestLevel_sprint';
  static const String bestLevelMarathonKey = 'bestLevel_marathon';
  static const String bestLevelZenKey = 'bestLevel_zen';

  // Theme and skin
  static const String themeKey = 'theme';
  static const String skinKey = 'skin';

  // High scores
  int _highScoreClassic = 0;
  int _highScoreSprint = 0;
  int _highScoreMarathon = 0;
  int _highScoreZen = 0;

  // Overall stats
  int _totalLinesCleared = 0;
  int _totalBlocksDropped = 0;
  int _totalTimePlayed = 0;
  int _totalGamesPlayed = 0;
  int _totalPerfectClears = 0;
  int _bestCombo = 0;
  int _highestLevel = 0;

  // Per-mode stats
  int _gamesPlayedClassic = 0;
  int _gamesPlayedSprint = 0;
  int _gamesPlayedMarathon = 0;
  int _gamesPlayedZen = 0;

  int _avgScoreClassic = 0;
  int _avgScoreSprint = 0;
  int _avgScoreMarathon = 0;
  int _avgScoreZen = 0;

  int _bestLevelClassic = 0;
  int _bestLevelSprint = 0;
  int _bestLevelMarathon = 0;
  int _bestLevelZen = 0;

  String _currentTheme = 'pastel';

  // Getters - High Scores
  int get highScoreClassic => _highScoreClassic;
  int get highScoreSprint => _highScoreSprint;
  int get highScoreMarathon => _highScoreMarathon;
  int get highScoreZen => _highScoreZen;

  // Getters - Overall Stats
  int get totalLinesCleared => _totalLinesCleared;
  int get totalBlocksDropped => _totalBlocksDropped;
  int get totalTimePlayed => _totalTimePlayed;
  int get totalGamesPlayed => _totalGamesPlayed;
  int get totalPerfectClears => _totalPerfectClears;
  int get bestCombo => _bestCombo;
  int get highestLevel => _highestLevel;

  // Getters - Per-Mode Stats
  int get gamesPlayedClassic => _gamesPlayedClassic;
  int get gamesPlayedSprint => _gamesPlayedSprint;
  int get gamesPlayedMarathon => _gamesPlayedMarathon;
  int get gamesPlayedZen => _gamesPlayedZen;

  int get avgScoreClassic => _avgScoreClassic;
  int get avgScoreSprint => _avgScoreSprint;
  int get avgScoreMarathon => _avgScoreMarathon;
  int get avgScoreZen => _avgScoreZen;

  int get bestLevelClassic => _bestLevelClassic;
  int get bestLevelSprint => _bestLevelSprint;
  int get bestLevelMarathon => _bestLevelMarathon;
  int get bestLevelZen => _bestLevelZen;

  // Computed getters
  double get averageSpeed {
    if (_totalTimePlayed == 0) return 0.0;
    return (_totalLinesCleared / (_totalTimePlayed / 60.0));
  }

  String get currentTheme => _currentTheme;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();

    // Load high scores
    _highScoreClassic = preferences.getInt(highScoreClassicKey) ?? 0;
    _highScoreSprint = preferences.getInt(highScoreSprintKey) ?? 0;
    _highScoreMarathon = preferences.getInt(highScoreMarathonKey) ?? 0;
    _highScoreZen = preferences.getInt(highScoreZenKey) ?? 0;

    // Load overall stats
    _totalLinesCleared = preferences.getInt(totalLinesClearedKey) ?? 0;
    _totalBlocksDropped = preferences.getInt(totalBlocksDroppedKey) ?? 0;
    _totalTimePlayed = preferences.getInt(totalTimePlayedKey) ?? 0;
    _totalGamesPlayed = preferences.getInt(totalGamesPlayedKey) ?? 0;
    _totalPerfectClears = preferences.getInt(totalPerfectClearsKey) ?? 0;
    _bestCombo = preferences.getInt(bestComboKey) ?? 0;
    _highestLevel = preferences.getInt(highestLevelKey) ?? 0;

    // Load per-mode stats
    _gamesPlayedClassic = preferences.getInt(gamesPlayedClassicKey) ?? 0;
    _gamesPlayedSprint = preferences.getInt(gamesPlayedSprintKey) ?? 0;
    _gamesPlayedMarathon = preferences.getInt(gamesPlayedMarathonKey) ?? 0;
    _gamesPlayedZen = preferences.getInt(gamesPlayedZenKey) ?? 0;

    _avgScoreClassic = preferences.getInt(avgScoreClassicKey) ?? 0;
    _avgScoreSprint = preferences.getInt(avgScoreSprintKey) ?? 0;
    _avgScoreMarathon = preferences.getInt(avgScoreMarathonKey) ?? 0;
    _avgScoreZen = preferences.getInt(avgScoreZenKey) ?? 0;

    _bestLevelClassic = preferences.getInt(bestLevelClassicKey) ?? 0;
    _bestLevelSprint = preferences.getInt(bestLevelSprintKey) ?? 0;
    _bestLevelMarathon = preferences.getInt(bestLevelMarathonKey) ?? 0;
    _bestLevelZen = preferences.getInt(bestLevelZenKey) ?? 0;

    // Load theme
    _currentTheme = preferences.getString(themeKey) ?? 'pastel';

    notifyListeners();
  }

  Future<void> setHighScore(String mode, int score) async {
    final preferences = await SharedPreferences.getInstance();
    final key = 'highScore_$mode';
    await preferences.setInt(key, score);
    switch (mode) {
      case 'classic':
        _highScoreClassic = score;
        break;
      case 'sprint':
        _highScoreSprint = score;
        break;
      case 'marathon':
        _highScoreMarathon = score;
        break;
      case 'zen':
        _highScoreZen = score;
        break;
    }
    notifyListeners();
  }

  Future<void> incrementLinesCleared(int lines) async {
    final preferences = await SharedPreferences.getInstance();
    _totalLinesCleared += lines;
    await preferences.setInt(totalLinesClearedKey, _totalLinesCleared);
    notifyListeners();
  }

  Future<void> incrementBlocksDropped() async {
    final preferences = await SharedPreferences.getInstance();
    _totalBlocksDropped++;
    await preferences.setInt(totalBlocksDroppedKey, _totalBlocksDropped);
    notifyListeners();
  }

  Future<void> updateTotalTimePlayed(Duration time) async {
    final preferences = await SharedPreferences.getInstance();
    _totalTimePlayed += time.inSeconds;
    await preferences.setInt(totalTimePlayedKey, _totalTimePlayed);
    notifyListeners();
  }

  // Record a complete game session with all stats
  Future<void> recordGameSession({
    required String mode,
    required int score,
    required int level,
    required int linesCleared,
    required int blocksDropped,
    required Duration timePlayed,
    required int perfectClears,
    required int maxCombo,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    // Update total games played
    _totalGamesPlayed++;
    await preferences.setInt(totalGamesPlayedKey, _totalGamesPlayed);

    // Update overall stats
    _totalLinesCleared += linesCleared;
    _totalBlocksDropped += blocksDropped;
    _totalTimePlayed += timePlayed.inSeconds;
    _totalPerfectClears += perfectClears;

    if (maxCombo > _bestCombo) {
      _bestCombo = maxCombo;
      await preferences.setInt(bestComboKey, _bestCombo);
    }

    if (level > _highestLevel) {
      _highestLevel = level;
      await preferences.setInt(highestLevelKey, _highestLevel);
    }

    await preferences.setInt(totalLinesClearedKey, _totalLinesCleared);
    await preferences.setInt(totalBlocksDroppedKey, _totalBlocksDropped);
    await preferences.setInt(totalTimePlayedKey, _totalTimePlayed);
    await preferences.setInt(totalPerfectClearsKey, _totalPerfectClears);

    // Update per-mode stats
    await _updateModeStats(mode, score, level);

    notifyListeners();
  }

  Future<void> _updateModeStats(String mode, int score, int level) async {
    final preferences = await SharedPreferences.getInstance();

    switch (mode) {
      case 'classic':
        _gamesPlayedClassic++;
        _avgScoreClassic = ((_avgScoreClassic * (_gamesPlayedClassic - 1)) + score) ~/ _gamesPlayedClassic;
        if (level > _bestLevelClassic) _bestLevelClassic = level;

        await preferences.setInt(gamesPlayedClassicKey, _gamesPlayedClassic);
        await preferences.setInt(avgScoreClassicKey, _avgScoreClassic);
        await preferences.setInt(bestLevelClassicKey, _bestLevelClassic);
        break;

      case 'sprint':
        _gamesPlayedSprint++;
        _avgScoreSprint = ((_avgScoreSprint * (_gamesPlayedSprint - 1)) + score) ~/ _gamesPlayedSprint;
        if (level > _bestLevelSprint) _bestLevelSprint = level;

        await preferences.setInt(gamesPlayedSprintKey, _gamesPlayedSprint);
        await preferences.setInt(avgScoreSprintKey, _avgScoreSprint);
        await preferences.setInt(bestLevelSprintKey, _bestLevelSprint);
        break;

      case 'marathon':
        _gamesPlayedMarathon++;
        _avgScoreMarathon = ((_avgScoreMarathon * (_gamesPlayedMarathon - 1)) + score) ~/ _gamesPlayedMarathon;
        if (level > _bestLevelMarathon) _bestLevelMarathon = level;

        await preferences.setInt(gamesPlayedMarathonKey, _gamesPlayedMarathon);
        await preferences.setInt(avgScoreMarathonKey, _avgScoreMarathon);
        await preferences.setInt(bestLevelMarathonKey, _bestLevelMarathon);
        break;

      case 'zen':
        _gamesPlayedZen++;
        _avgScoreZen = ((_avgScoreZen * (_gamesPlayedZen - 1)) + score) ~/ _gamesPlayedZen;
        if (level > _bestLevelZen) _bestLevelZen = level;

        await preferences.setInt(gamesPlayedZenKey, _gamesPlayedZen);
        await preferences.setInt(avgScoreZenKey, _avgScoreZen);
        await preferences.setInt(bestLevelZenKey, _bestLevelZen);
        break;
    }
  }

  Future<void> incrementPerfectClears() async {
    final preferences = await SharedPreferences.getInstance();
    _totalPerfectClears++;
    await preferences.setInt(totalPerfectClearsKey, _totalPerfectClears);
    notifyListeners();
  }

  Future<void> updateBestCombo(int combo) async {
    if (combo > _bestCombo) {
      final preferences = await SharedPreferences.getInstance();
      _bestCombo = combo;
      await preferences.setInt(bestComboKey, _bestCombo);
      notifyListeners();
    }
  }

  Future<void> updateHighestLevel(int level) async {
    if (level > _highestLevel) {
      final preferences = await SharedPreferences.getInstance();
      _highestLevel = level;
      await preferences.setInt(highestLevelKey, _highestLevel);
      notifyListeners();
    }
  }

  Future<String> getTheme() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(themeKey) ?? 'pastel';
  }

  Future<void> setTheme(String theme) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(themeKey, theme);
    _currentTheme = theme;
    notifyListeners();
  }

  Future<String> getSkin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(skinKey) ?? 'flat';
  }

  Future<void> setSkin(String skin) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(skinKey, skin);
  }

  Future<List<String>> getUnlockedThemes() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList('unlockedThemes') ?? ['pastel'];
  }

  Future<void> unlockTheme(String theme) async {
    final preferences = await SharedPreferences.getInstance();
    final themes = await getUnlockedThemes();
    if (!themes.contains(theme)) {
      themes.add(theme);
      await preferences.setStringList('unlockedThemes', themes);
    }
  }

  Future<List<String>> getUnlockedSkins() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList('unlockedSkins') ?? ['flat'];
  }

  Future<void> unlockSkin(String skin) async {
    final preferences = await SharedPreferences.getInstance();
    final skins = await getUnlockedSkins();
    if (!skins.contains(skin)) {
      skins.add(skin);
      await preferences.setStringList('unlockedSkins', skins);
    }
  }
}

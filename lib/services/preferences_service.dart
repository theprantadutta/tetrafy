import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String highScoreClassicKey = 'highScore_classic';
  static const String highScoreSprintKey = 'highScore_sprint';
  static const String highScoreMarathonKey = 'highScore_marathon';
  static const String highScoreZenKey = 'highScore_zen';
  static const String totalLinesClearedKey = 'totalLinesCleared';
  static const String totalBlocksDroppedKey = 'totalBlocksDropped';
  static const String averageSpeedKey = 'averageSpeed';
  static const String totalTimePlayedKey = 'totalTimePlayed';
  static const String themeKey = 'theme';
  static const String skinKey = 'skin';

  int _highScoreClassic = 0;
  int _highScoreSprint = 0;
  int _highScoreMarathon = 0;
  int _highScoreZen = 0;
  int _totalLinesCleared = 0;
  int _totalBlocksDropped = 0;
  double _averageSpeed = 0.0;
  int _totalTimePlayed = 0;

  int get highScoreClassic => _highScoreClassic;
  int get highScoreSprint => _highScoreSprint;
  int get highScoreMarathon => _highScoreMarathon;
  int get highScoreZen => _highScoreZen;
  int get totalLinesCleared => _totalLinesCleared;
  int get totalBlocksDropped => _totalBlocksDropped;
  double get averageSpeed => _averageSpeed;
  int get totalTimePlayed => _totalTimePlayed;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    _highScoreClassic = preferences.getInt(highScoreClassicKey) ?? 0;
    _highScoreSprint = preferences.getInt(highScoreSprintKey) ?? 0;
    _highScoreMarathon = preferences.getInt(highScoreMarathonKey) ?? 0;
    _highScoreZen = preferences.getInt(highScoreZenKey) ?? 0;
    _totalLinesCleared = preferences.getInt(totalLinesClearedKey) ?? 0;
    _totalBlocksDropped = preferences.getInt(totalBlocksDroppedKey) ?? 0;
    _averageSpeed = preferences.getDouble(averageSpeedKey) ?? 0.0;
    _totalTimePlayed = preferences.getInt(totalTimePlayedKey) ?? 0;
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

  Future<void> updateAverageSpeed(int lines, Duration time) async {
    final preferences = await SharedPreferences.getInstance();
    final minutes = time.inSeconds / 60.0;
    if (minutes > 0) {
      _averageSpeed = (_totalLinesCleared + lines) / minutes;
      await preferences.setDouble(averageSpeedKey, _averageSpeed);
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

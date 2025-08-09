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
    final prefs = await SharedPreferences.getInstance();
    _highScoreClassic = prefs.getInt(highScoreClassicKey) ?? 0;
    _highScoreSprint = prefs.getInt(highScoreSprintKey) ?? 0;
    _highScoreMarathon = prefs.getInt(highScoreMarathonKey) ?? 0;
    _highScoreZen = prefs.getInt(highScoreZenKey) ?? 0;
    _totalLinesCleared = prefs.getInt(totalLinesClearedKey) ?? 0;
    _totalBlocksDropped = prefs.getInt(totalBlocksDroppedKey) ?? 0;
    _averageSpeed = prefs.getDouble(averageSpeedKey) ?? 0.0;
    _totalTimePlayed = prefs.getInt(totalTimePlayedKey) ?? 0;
    notifyListeners();
  }

  Future<void> setHighScore(String mode, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'highScore_$mode';
    await prefs.setInt(key, score);
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
    final prefs = await SharedPreferences.getInstance();
    _totalLinesCleared += lines;
    await prefs.setInt(totalLinesClearedKey, _totalLinesCleared);
    notifyListeners();
  }

  Future<void> incrementBlocksDropped() async {
    final prefs = await SharedPreferences.getInstance();
    _totalBlocksDropped++;
    await prefs.setInt(totalBlocksDroppedKey, _totalBlocksDropped);
    notifyListeners();
  }

  Future<void> updateTotalTimePlayed(Duration time) async {
    final prefs = await SharedPreferences.getInstance();
    _totalTimePlayed += time.inSeconds;
    await prefs.setInt(totalTimePlayedKey, _totalTimePlayed);
    notifyListeners();
  }

  Future<void> updateAverageSpeed(int lines, Duration time) async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = time.inSeconds / 60.0;
    if (minutes > 0) {
      _averageSpeed = (_totalLinesCleared + lines) / minutes;
      await prefs.setDouble(averageSpeedKey, _averageSpeed);
      notifyListeners();
    }
  }

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themeKey) ?? 'pastel';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, theme);
  }

  Future<String> getSkin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(skinKey) ?? 'flat';
  }

  Future<void> setSkin(String skin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(skinKey, skin);
  }

  Future<List<String>> getUnlockedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('unlockedThemes') ?? ['pastel'];
  }

  Future<void> unlockTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    final themes = await getUnlockedThemes();
    if (!themes.contains(theme)) {
      themes.add(theme);
      await prefs.setStringList('unlockedThemes', themes);
    }
  }

  Future<List<String>> getUnlockedSkins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('unlockedSkins') ?? ['flat'];
  }

  Future<void> unlockSkin(String skin) async {
    final prefs = await SharedPreferences.getInstance();
    final skins = await getUnlockedSkins();
    if (!skins.contains(skin)) {
      skins.add(skin);
      await prefs.setStringList('unlockedSkins', skins);
    }
  }
}
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String highScoreKey = 'highScore';

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(highScoreKey) ?? 0;
  }

  Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(highScoreKey, score);
  }
}
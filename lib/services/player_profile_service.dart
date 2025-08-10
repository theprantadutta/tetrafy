import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge.dart';
import '../models/player_profile.dart';

class PlayerProfileService {
  static const String levelKey = 'level';
  static const String xpKey = 'xp';
  static const String badgesKey = 'badges';

  Future<PlayerProfile> getProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final level = preferences.getInt(levelKey) ?? 1;
    final xp = preferences.getInt(xpKey) ?? 0;
    final badgeNames = preferences.getStringList(badgesKey) ?? [];
    final badges = badgeNames
        .map((name) => Badge(name: name, description: ''))
        .toList();
    return PlayerProfile(level: level, xp: xp, badges: badges);
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(levelKey, profile.level);
    await preferences.setInt(xpKey, profile.xp);
    await preferences.setStringList(
      badgesKey,
      profile.badges.map((b) => b.name).toList(),
    );
  }

  void addXp(PlayerProfile profile, int amount) {
    profile.xp += amount;
    if (profile.xp >= profile.level * 100) {
      profile.level++;
      profile.xp = 0;
    }
    saveProfile(profile);
  }

  void addBadge(PlayerProfile profile, Badge badge) {
    if (!profile.badges.any((b) => b.name == badge.name)) {
      profile.badges.add(badge);
      saveProfile(profile);
    }
  }
}

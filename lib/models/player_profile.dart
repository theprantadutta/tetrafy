import 'badge.dart';

class PlayerProfile {
  int level;
  int xp;
  List<Badge> badges;

  PlayerProfile({
    this.level = 1,
    this.xp = 0,
    this.badges = const [],
  });
}
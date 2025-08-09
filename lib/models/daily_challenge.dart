enum ChallengeType { tSpins, linesInTime }

class DailyChallenge {
  final ChallengeType type;
  final String description;
  final int target;
  bool isCompleted;

  DailyChallenge({
    required this.type,
    required this.description,
    required this.target,
    this.isCompleted = false,
  });
}
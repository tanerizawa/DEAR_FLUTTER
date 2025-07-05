import 'package:freezed_annotation/freezed_annotation.dart';

part 'tree_state.freezed.dart';

enum TreeStage {
  seed,    // 0-10 points
  sprout,  // 11-30 points  
  young,   // 31-60 points
  mature,  // 61-100 points
  wise,    // 100+ points
}

enum TreeActivity {
  moodCheckIn(5),
  breathingExercise(8),
  cbtActivity(10),
  educationRead(6),
  crisisResourceView(3),
  journalEntry(7),
  streakBonus(15),
  achievementUnlock(20);

  const TreeActivity(this.points);
  final int points;
}

@freezed
class TreeState with _$TreeState {
  const factory TreeState({
    @Default(0) int totalPoints,
    @Default(TreeStage.seed) TreeStage stage,
    @Default(1.0) double health, // 0.0 to 1.0
    DateTime? lastActivity,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default([]) List<String> unlockedDecorations,
    @Default(false) bool hasRecentGrowth,
    @Default(null) TreeActivity? lastEarnedActivity,
  }) = _TreeState;

  const TreeState._();

  String get stageDisplayName {
    switch (stage) {
      case TreeStage.seed:
        return 'Benih';
      case TreeStage.sprout:
        return 'Tunas';
      case TreeStage.young:
        return 'Pohon Muda';
      case TreeStage.mature:
        return 'Pohon Dewasa';
      case TreeStage.wise:
        return 'Pohon Bijak';
    }
  }

  String get healthStatus {
    if (health >= 0.9) return 'Sangat Sehat';
    if (health >= 0.7) return 'Sehat';
    if (health >= 0.4) return 'Perlu Perhatian';
    if (health >= 0.2) return 'Layu';
    return 'Tidur';
  }

  int get pointsToNextStage {
    switch (stage) {
      case TreeStage.seed:
        return 10 - totalPoints;
      case TreeStage.sprout:
        return 30 - totalPoints;
      case TreeStage.young:
        return 60 - totalPoints;
      case TreeStage.mature:
        return 100 - totalPoints;
      case TreeStage.wise:
        return 0; // Max stage
    }
  }

  double get stageProgress {
    switch (stage) {
      case TreeStage.seed:
        return totalPoints / 10;
      case TreeStage.sprout:
        return (totalPoints - 10) / 20;
      case TreeStage.young:
        return (totalPoints - 30) / 30;
      case TreeStage.mature:
        return (totalPoints - 60) / 40;
      case TreeStage.wise:
        return 1.0;
    }
  }
}

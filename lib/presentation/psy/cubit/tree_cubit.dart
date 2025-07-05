import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/tree_state.dart';

class TreeCubit extends Cubit<TreeState> {
  TreeCubit() : super(const TreeState()) {
    _loadTreeState();
    _startDailyHealthUpdate();
  }

  static const String _treeStateKey = 'tree_state';

  Future<void> _loadTreeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treeStateJson = prefs.getString(_treeStateKey);
      
      if (treeStateJson != null) {
        final Map<String, dynamic> treeStateMap = json.decode(treeStateJson);
        
        final loadedState = TreeState(
          totalPoints: treeStateMap['totalPoints'] ?? 0,
          stage: TreeStage.values[treeStateMap['stage'] ?? 0],
          health: treeStateMap['health'] ?? 1.0,
          lastActivity: treeStateMap['lastActivity'] != null 
              ? DateTime.parse(treeStateMap['lastActivity'])
              : DateTime.now(),
          currentStreak: treeStateMap['currentStreak'] ?? 0,
          longestStreak: treeStateMap['longestStreak'] ?? 0,
          unlockedDecorations: List<String>.from(treeStateMap['unlockedDecorations'] ?? []),
        );
        
        emit(loadedState);
        _updateHealthBasedOnLastActivity();
      }
    } catch (e) {
      // If loading fails, start with default state
      emit(const TreeState(lastActivity: null));
    }
  }

  Future<void> _saveTreeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treeStateMap = {
        'totalPoints': state.totalPoints,
        'stage': state.stage.index,
        'health': state.health,
        'lastActivity': state.lastActivity?.toIso8601String(),
        'currentStreak': state.currentStreak,
        'longestStreak': state.longestStreak,
        'unlockedDecorations': state.unlockedDecorations,
      };
      
      await prefs.setString(_treeStateKey, json.encode(treeStateMap));
    } catch (e) {
      // Handle save error silently
    }
  }

  void addActivity(TreeActivity activity) {
    final now = DateTime.now();
    final previousStage = state.stage;
    final newPoints = state.totalPoints + activity.points;
    final newStage = _calculateStage(newPoints);
    
    // Update streak if this is a daily activity
    int newCurrentStreak = state.currentStreak;
    int newLongestStreak = state.longestStreak;
    
    if (state.lastActivity != null) {
      final daysSinceLastActivity = now.difference(state.lastActivity!).inDays;
      if (daysSinceLastActivity == 1) {
        newCurrentStreak += 1;
      } else if (daysSinceLastActivity > 1) {
        newCurrentStreak = 1;
      }
    } else {
      newCurrentStreak = 1;
    }
    
    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }

    final hasGrowth = newStage != previousStage;

    emit(state.copyWith(
      totalPoints: newPoints,
      stage: newStage,
      health: 1.0, // Activity restores health
      lastActivity: now,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      hasRecentGrowth: hasGrowth,
      lastEarnedActivity: activity,
    ));

    _saveTreeState();

    // Clear recent growth after a delay
    if (hasGrowth) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) {
          emit(state.copyWith(hasRecentGrowth: false));
        }
      });
    }
  }

  void _updateHealthBasedOnLastActivity() {
    if (state.lastActivity == null) return;
    
    final health = _calculateHealth(state.lastActivity!);
    if (health != state.health) {
      emit(state.copyWith(health: health));
      _saveTreeState();
    }
  }

  void _startDailyHealthUpdate() {
    // Update health every hour to reflect current tree state
    Stream.periodic(const Duration(hours: 1)).listen((_) {
      if (!isClosed) {
        _updateHealthBasedOnLastActivity();
      }
    });
  }

  TreeStage _calculateStage(int totalPoints) {
    if (totalPoints < 10) return TreeStage.seed;
    if (totalPoints < 30) return TreeStage.sprout;
    if (totalPoints < 60) return TreeStage.young;
    if (totalPoints < 100) return TreeStage.mature;
    return TreeStage.wise;
  }

  double _calculateHealth(DateTime lastActivity) {
    final daysSinceLastActivity = DateTime.now().difference(lastActivity).inDays;
    
    if (daysSinceLastActivity == 0) return 1.0;      // 100% healthy
    if (daysSinceLastActivity <= 1) return 0.9;      // 90% healthy
    if (daysSinceLastActivity <= 3) return 0.7;      // 70% healthy
    if (daysSinceLastActivity <= 7) return 0.4;      // 40% healthy
    return 0.1;                                      // 10% healthy (dormant)
  }

  // Manual health update for testing or forced refresh
  void updateHealth() {
    _updateHealthBasedOnLastActivity();
  }

  // Reset tree for testing purposes
  void resetTree() {
    emit(const TreeState(
      totalPoints: 0,
      stage: TreeStage.seed,
      health: 1.0,
      lastActivity: null,
      currentStreak: 0,
      longestStreak: 0,
      unlockedDecorations: [],
    ));
    _saveTreeState();
  }

  // Add points for external integrations (like journal mood entries)
  void addPointsFromJournal(String mood) {
    if (mood.contains('Senang') || mood.contains('Happy')) {
      addActivity(TreeActivity.journalEntry);
    } else if (mood.contains('Sedih') || mood.contains('Sad')) {
      // Encourage breathing exercise for sad moods
      addActivity(TreeActivity.moodCheckIn);
    } else {
      addActivity(TreeActivity.moodCheckIn);
    }
  }

  // Weekly streak bonus
  void checkWeeklyStreak() {
    if (state.currentStreak >= 7) {
      addActivity(TreeActivity.streakBonus);
    }
  }
}

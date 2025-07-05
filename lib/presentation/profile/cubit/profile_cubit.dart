import 'package:dear_flutter/domain/usecases/get_user_profile_usecase.dart';
import 'package:dear_flutter/domain/usecases/logout_usecase.dart';
import 'package:dear_flutter/domain/usecases/delete_account_usecase.dart';
import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final AppDatabase _db;

  ProfileCubit(
      this._getUserProfileUseCase,
      this._logoutUseCase,
      this._deleteAccountUseCase,
      this._db,
      ) : super(const ProfileState()) {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _getUserProfileUseCase();
      
      // Fetch analytics data from local database
      final stats = await _calculateUserStats();
      final analyticsData = await _calculateAnalyticsData();
      final currentMood = await _getCurrentMood();
      
      emit(state.copyWith(
        status: ProfileStatus.success, 
        user: user,
        userStats: stats,
        analyticsData: analyticsData,
        currentMood: currentMood,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: 'Gagal memuat profil'));
    }
  }

  Future<Map<String, dynamic>> _calculateUserStats() async {
    final journals = await _db.journalDao.getAllJournals();
    
    // Calculate total entries
    final totalEntries = journals.length;
    
    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    DateTime checkDate = today;
    
    while (true) {
      final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final dayEnd = dayStart.add(Duration(days: 1));
      
      final hasEntryOnDay = journals.any((journal) {
        final entryDate = journal.createdAt;
        return entryDate.isAfter(dayStart) && entryDate.isBefore(dayEnd);
      });
      
      if (hasEntryOnDay) {
        currentStreak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    
    // Calculate total active days
    final uniqueDays = journals.map((journal) {
      final date = journal.createdAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet().length;
    
    // Calculate favorite mood
    final moodCounts = <String, int>{};
    for (final journal in journals) {
      final mood = journal.mood;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    
    String favoriteEmoji = '😊';
    if (moodCounts.isNotEmpty) {
      final sortedMoods = moodCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topMood = sortedMoods.first.key;
      favoriteEmoji = topMood.split(' ').length > 1 ? topMood.split(' ').last : '😊';
    }
    
    return {
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'totalDays': uniqueDays,
      'favoriteEmoji': favoriteEmoji,
    };
  }

  Future<Map<String, dynamic>> _calculateAnalyticsData() async {
    final journals = await _db.journalDao.getAllJournals();
    
    // Mood distribution
    final moodCounts = <String, int>{};
    for (final journal in journals) {
      final mood = journal.mood.split(' ').first; // Get mood without emoji
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    
    // Weekly progress (last 7 days)
    final weeklyData = <int>[];
    final today = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final dayStart = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final dayEnd = dayStart.add(Duration(days: 1));
      
      final entriesOnDay = journals.where((journal) {
        final entryDate = journal.createdAt;
        return entryDate.isAfter(dayStart) && entryDate.isBefore(dayEnd);
      }).length;
      
      weeklyData.add(entriesOnDay);
    }
    
    // Sample achievements (this could be expanded)
    final achievements = [
      {
        'name': 'Penulis Pemula',
        'description': 'Tulis jurnal pertama',
        'completed': journals.isNotEmpty,
        'icon': '✏️'
      },
      {
        'name': 'Konsisten 7 Hari',
        'description': 'Jurnal 7 hari berturut-turut',
        'completed': (await _calculateUserStats())['currentStreak'] >= 7,
        'icon': '🔥'
      },
      {
        'name': 'Penjelajah Mood',
        'description': 'Coba semua jenis mood',
        'completed': moodCounts.keys.length >= 5,
        'icon': '🎭'
      },
      {
        'name': 'Refleksi Mendalam',
        'description': 'Tulis 50 jurnal',
        'completed': journals.length >= 50,
        'icon': '📚'
      },
    ];
    
    return {
      'moodDistribution': moodCounts,
      'weeklyProgress': weeklyData,
      'achievements': achievements,
    };
  }

  Future<String?> _getCurrentMood() async {
    final journals = await _db.journalDao.getAllJournals();
    if (journals.isEmpty) return null;
    
    // Get the most recent journal entry's mood
    journals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return journals.first.mood;
  }

  Future<void> logout() async {
    await _logoutUseCase();
    await _db.clearAllData();
  }

  Future<void> deleteAccount() async {
    await _deleteAccountUseCase();
  }
}

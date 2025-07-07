// lib/core/theme/content_personalization_system.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

// User preference categories
enum ContentCategory {
  motivation,
  wisdom,
  success,
  happiness,
  mindfulness,
  productivity,
  relationships,
  health,
  creativity,
  spirituality,
}

// Interaction types for learning user preferences
enum InteractionType {
  view,
  copy,
  share,
  favorite,
  skip,
  longView, // Viewed for >3 seconds
  quickView, // Viewed for <1 second
}

/// Phase 4: Content Personalization System
/// 
/// Provides intelligent content recommendations and personalization
/// based on user behavior, preferences, and interaction patterns
class ContentPersonalizationSystem {
  
  static const String _userProfileKey = 'user_profile';
  static const String _interactionHistoryKey = 'interaction_history';
  static const int maxHistoryItems = 100;
  
  // User profile for personalization
  static UserProfile? _userProfile;
  static List<InteractionRecord> _interactionHistory = [];
  
  /// Initialize the personalization system
  static Future<void> initialize() async {
    await _loadUserProfile();
    await _loadInteractionHistory();
    _analyzePreferences();
  }
  
  /// Record user interaction for learning
  static Future<void> recordInteraction({
    required String contentId,
    required InteractionType type,
    required ContentCategory category,
    Map<String, dynamic>? metadata,
  }) async {
    final interaction = InteractionRecord(
      contentId: contentId,
      type: type,
      category: category,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _interactionHistory.add(interaction);
    
    // Maintain history size limit
    if (_interactionHistory.length > maxHistoryItems) {
      _interactionHistory.removeAt(0);
    }
    
    await _saveInteractionHistory();
    _updateUserProfile(interaction);
  }
  
  /// Get personalized content recommendations
  static List<String> getPersonalizedQuoteCategories() {
    if (_userProfile == null) {
      return ContentCategory.values.map((e) => e.name).toList();
    }
    
    final preferences = _userProfile!.categoryPreferences;
    final sortedCategories = preferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.take(5).map((e) => e.key).toList();
  }
  
  /// Get content diversity factor (0.0 = same, 1.0 = diverse)
  static double getContentDiversityFactor() {
    if (_userProfile == null) return 0.5;
    
    final recentInteractions = _interactionHistory
        .where((i) => DateTime.now().difference(i.timestamp).inDays < 7)
        .toList();
    
    if (recentInteractions.isEmpty) return 0.5;
    
    final uniqueCategories = recentInteractions
        .map((i) => i.category)
        .toSet()
        .length;
    
    final totalCategories = ContentCategory.values.length;
    return uniqueCategories / totalCategories;
  }
  
  /// Determine if user prefers visual content
  static bool prefersVisualContent() {
    if (_userProfile == null) return true;
    
    final longViews = _interactionHistory
        .where((i) => i.type == InteractionType.longView)
        .length;
    
    final quickViews = _interactionHistory
        .where((i) => i.type == InteractionType.quickView)
        .length;
    
    return longViews > quickViews;
  }
  
  /// Get optimal content timing based on user behavior
  static TimeOfDay getOptimalContentTime() {
    final interactions = _interactionHistory
        .where((i) => i.type == InteractionType.longView || 
                     i.type == InteractionType.favorite)
        .toList();
    
    if (interactions.isEmpty) {
      return const TimeOfDay(hour: 9, minute: 0); // Default morning
    }
    
    final hourCounts = <int, int>{};
    for (final interaction in interactions) {
      final hour = interaction.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final optimalHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return TimeOfDay(hour: optimalHour, minute: 0);
  }
  
  /// Get personalized quote mood based on time and preferences
  static String getPersonalizedMood() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Time-based mood suggestions
    String timeMood;
    if (hour >= 6 && hour < 12) {
      timeMood = 'motivation'; // Morning energy
    } else if (hour >= 12 && hour < 17) {
      timeMood = 'productivity'; // Afternoon focus
    } else if (hour >= 17 && hour < 21) {
      timeMood = 'wisdom'; // Evening reflection
    } else {
      timeMood = 'mindfulness'; // Night peace
    }
    
    // Blend with user preferences
    if (_userProfile != null) {
      final preferences = _userProfile!.categoryPreferences;
      final topPreference = preferences.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // 70% user preference, 30% time-based
      return math.Random().nextDouble() < 0.7 ? topPreference : timeMood;
    }
    
    return timeMood;
  }
  
  /// Get content freshness preference (0.0 = familiar, 1.0 = novel)
  static double getContentFreshnessPreference() {
    if (_userProfile == null) return 0.6; // Default to slightly novel
    
    final skipCount = _interactionHistory
        .where((i) => i.type == InteractionType.skip)
        .length;
    
    final viewCount = _interactionHistory
        .where((i) => i.type == InteractionType.view)
        .length;
    
    if (viewCount == 0) return 0.6;
    
    final skipRatio = skipCount / viewCount;
    
    // Higher skip ratio = wants more novelty
    return math.min(1.0, 0.3 + skipRatio * 1.4);
  }
  
  /// Generate personalized quote prompt for AI/backend
  static Map<String, dynamic> generatePersonalizedQuotePrompt() {
    return {
      'categories': getPersonalizedQuoteCategories(),
      'mood': getPersonalizedMood(),
      'diversity_factor': getContentDiversityFactor(),
      'freshness_preference': getContentFreshnessPreference(),
      'visual_preference': prefersVisualContent(),
      'optimal_time': '${getOptimalContentTime().hour}:${getOptimalContentTime().minute.toString().padLeft(2, '0')}',
      'user_language': _userProfile?.preferredLanguage ?? 'id',
      'complexity_level': _userProfile?.complexityLevel ?? 'medium',
    };
  }
  
  /// Check if content should be refreshed based on user behavior
  static bool shouldRefreshContent() {
    final lastInteraction = _interactionHistory.isNotEmpty 
        ? _interactionHistory.last.timestamp 
        : DateTime.now().subtract(const Duration(hours: 1));
    
    final timeSinceLastInteraction = DateTime.now().difference(lastInteraction);
    
    // Refresh if:
    // 1. No interaction for > 30 minutes
    // 2. Last interaction was skip
    // 3. User has high freshness preference
    return timeSinceLastInteraction.inMinutes > 30 ||
           (_interactionHistory.isNotEmpty && 
            _interactionHistory.last.type == InteractionType.skip) ||
           getContentFreshnessPreference() > 0.8;
  }
  
  /// Get engagement score for content optimization
  static double getEngagementScore() {
    if (_interactionHistory.isEmpty) return 0.5;
    
    final recentInteractions = _interactionHistory
        .where((i) => DateTime.now().difference(i.timestamp).inDays < 7)
        .toList();
    
    if (recentInteractions.isEmpty) return 0.5;
    
    double score = 0.0;
    for (final interaction in recentInteractions) {
      switch (interaction.type) {
        case InteractionType.favorite:
          score += 1.0;
          break;
        case InteractionType.share:
          score += 0.8;
          break;
        case InteractionType.copy:
          score += 0.6;
          break;
        case InteractionType.longView:
          score += 0.4;
          break;
        case InteractionType.view:
          score += 0.2;
          break;
        case InteractionType.quickView:
          score += 0.1;
          break;
        case InteractionType.skip:
          score -= 0.2;
          break;
      }
    }
    
    return math.max(0.0, math.min(1.0, score / recentInteractions.length));
  }
  
  /// Check if gesture hints should be shown to users
  /// Shows hints for new users or those who haven't used advanced gestures
  static bool shouldShowGestureHints() {
    if (_userProfile == null) return true;
    
    // Show hints for first 5 app launches
    if (_userProfile!.totalLaunches < 5) return true;
    
    // Show hints if user hasn't used advanced gestures
    final hasUsedGestures = _interactionHistory.any((interaction) => 
      interaction.type == InteractionType.longView ||
      interaction.type == InteractionType.share ||
      interaction.type == InteractionType.favorite
    );
    
    return !hasUsedGestures;
  }
  
  // Private methods
  static void _analyzePreferences() {
    if (_interactionHistory.isEmpty) return;
    
    final categoryScores = <String, double>{};
    
    for (final interaction in _interactionHistory) {
      final category = interaction.category.name;
      final weight = _getInteractionWeight(interaction.type);
      
      categoryScores[category] = (categoryScores[category] ?? 0.0) + weight;
    }
    
    _userProfile?.categoryPreferences.clear();
    _userProfile?.categoryPreferences.addAll(categoryScores);
  }
  
  static double _getInteractionWeight(InteractionType type) {
    switch (type) {
      case InteractionType.favorite:
        return 3.0;
      case InteractionType.share:
        return 2.5;
      case InteractionType.copy:
        return 2.0;
      case InteractionType.longView:
        return 1.5;
      case InteractionType.view:
        return 1.0;
      case InteractionType.quickView:
        return 0.5;
      case InteractionType.skip:
        return -1.0;
    }
  }
  
  static void _updateUserProfile(InteractionRecord interaction) {
    _userProfile ??= UserProfile();
    
    // Update category preferences
    final category = interaction.category.name;
    final currentScore = _userProfile!.categoryPreferences[category] ?? 0.0;
    final weight = _getInteractionWeight(interaction.type);
    _userProfile!.categoryPreferences[category] = currentScore + weight;
    
    // Update engagement metrics
    _userProfile!.totalInteractions++;
    _userProfile!.lastActive = DateTime.now();
    
    _saveUserProfile();
  }
  
  static Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);
      
      if (profileJson != null) {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        _userProfile = UserProfile.fromJson(profileMap);
      } else {
        _userProfile = UserProfile();
      }
    } catch (e) {
      _userProfile = UserProfile();
    }
  }
  
  static Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_userProfile!.toJson());
      await prefs.setString(_userProfileKey, profileJson);
    } catch (e) {
      // Handle error silently
    }
  }
  
  static Future<void> _loadInteractionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_interactionHistoryKey);
      
      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List<dynamic>;
        _interactionHistory = historyList
            .map((item) => InteractionRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _interactionHistory = [];
    }
  }
  
  static Future<void> _saveInteractionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _interactionHistory.map((item) => item.toJson()).toList()
      );
      await prefs.setString(_interactionHistoryKey, historyJson);
    } catch (e) {
      // Handle error silently
    }
  }
}

/// User profile for personalization
class UserProfile {
  Map<String, double> categoryPreferences = {};
  String preferredLanguage = 'id';
  String complexityLevel = 'medium'; // simple, medium, complex
  int totalInteractions = 0;
  DateTime lastActive = DateTime.now();
  int totalLaunches = 0;
  
  UserProfile();
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = UserProfile();
    profile.categoryPreferences = Map<String, double>.from(
      json['categoryPreferences'] ?? {}
    );
    profile.preferredLanguage = json['preferredLanguage'] ?? 'id';
    profile.complexityLevel = json['complexityLevel'] ?? 'medium';
    profile.totalInteractions = json['totalInteractions'] ?? 0;
    profile.lastActive = DateTime.parse(
      json['lastActive'] ?? DateTime.now().toIso8601String()
    );
    profile.totalLaunches = json['totalLaunches'] ?? 0;
    return profile;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'categoryPreferences': categoryPreferences,
      'preferredLanguage': preferredLanguage,
      'complexityLevel': complexityLevel,
      'totalInteractions': totalInteractions,
      'lastActive': lastActive.toIso8601String(),
      'totalLaunches': totalLaunches,
    };
  }
}

/// Interaction record for learning user preferences
class InteractionRecord {
  final String contentId;
  final InteractionType type;
  final ContentCategory category;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  InteractionRecord({
    required this.contentId,
    required this.type,
    required this.category,
    required this.timestamp,
    required this.metadata,
  });
  
  factory InteractionRecord.fromJson(Map<String, dynamic> json) {
    return InteractionRecord(
      contentId: json['contentId'],
      type: InteractionType.values.firstWhere(
        (e) => e.name == json['type']
      ),
      category: ContentCategory.values.firstWhere(
        (e) => e.name == json['category']
      ),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'type': type.name,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

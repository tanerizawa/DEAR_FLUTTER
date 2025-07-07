// 🤖 Personalized Theme Engine
// AI-driven theme personalization with user learning algorithms
// DEAR Flutter - Modern Theme UI/UX Phase 3

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

/// Intelligent theme personalization engine that learns from user behavior
/// and adapts themes based on usage patterns, preferences, and context
class PersonalizedThemeEngine {
  static const String _preferencesKey = 'personalized_theme_data';
  static const int _maxLearningData = 1000; // Limit data points for performance
  
  // Learning data storage
  UserPreferenceData _preferenceData = UserPreferenceData();
  final Map<String, ThemeUsagePattern> _usagePatterns = {};
  final List<ThemeInteraction> _interactionHistory = [];
  
  // Seasonal adaptation
  final Map<SeasonType, ThemePersonalization> _seasonalThemes = {};
  
  // Performance optimization
  Timer? _saveTimer;
  bool _isDirty = false;
  
  /// Initialize the personalization engine
  Future<void> initialize() async {
    await _loadUserPreferences();
    _initializeSeasonalThemes();
    _startPeriodicSave();
  }
  
  /// Dispose resources
  void dispose() {
    _saveTimer?.cancel();
    if (_isDirty) {
      _saveUserPreferences(); // Final save
    }
  }
  
  /// Record user interaction with theme
  void recordThemeInteraction({
    required String themeId,
    required InteractionType type,
    required DateTime timestamp,
    Map<String, dynamic>? context,
  }) {
    final interaction = ThemeInteraction(
      themeId: themeId,
      type: type,
      timestamp: timestamp,
      context: context ?? {},
    );
    
    _interactionHistory.add(interaction);
    _updateUsagePattern(interaction);
    _markDirty();
    
    // Limit history size for performance
    if (_interactionHistory.length > _maxLearningData) {
      _interactionHistory.removeAt(0);
    }
  }
  
  /// Get personalized theme recommendation
  Future<ThemeRecommendation> getPersonalizedRecommendation({
    DateTime? currentTime,
    Map<String, dynamic>? context,
  }) async {
    currentTime ??= DateTime.now();
    context ??= {};
    
    // Analyze current context
    final contextualFactors = _analyzeContext(currentTime, context);
    
    // Get base recommendation from usage patterns
    final patternRecommendation = _getPatternBasedRecommendation(contextualFactors);
    
    // Apply seasonal adaptation
    final seasonalAdaptation = _getSeasonalAdaptation(currentTime);
    
    // Calculate personalization score
    final personalizationScore = _calculatePersonalizationScore(
      patternRecommendation,
      seasonalAdaptation,
      contextualFactors,
    );
    
    return ThemeRecommendation(
      themeId: patternRecommendation.themeId,
      mood: patternRecommendation.mood,
      brightness: patternRecommendation.brightness,
      confidence: personalizationScore.confidence,
      reasoning: personalizationScore.reasoning,
      seasonalAdaptation: seasonalAdaptation,
      contextualFactors: contextualFactors,
      timestamp: currentTime,
    );
  }
  
  /// Learn from user feedback on recommendations
  void provideFeedback({
    required String recommendationId,
    required FeedbackType feedback,
    String? reason,
  }) {
    _preferenceData.addFeedback(FeedbackData(
      recommendationId: recommendationId,
      feedback: feedback,
      reason: reason,
      timestamp: DateTime.now(),
    ));
    
    _markDirty();
  }
  
  /// Get user's learned preferences summary
  UserPreferencesSummary getPreferencesSummary() {
    return UserPreferencesSummary(
      favoriteThemes: _getFavoriteThemes(),
      preferredBrightness: _getPreferredBrightness(),
      activeHours: _getActiveHours(),
      seasonalPreferences: _getSeasonalPreferences(),
      accessibilityNeeds: _getAccessibilityNeeds(),
      learningConfidence: _calculateLearningConfidence(),
    );
  }
  
  /// Reset personalization data (for privacy or testing)
  Future<void> resetPersonalization() async {
    _preferenceData = UserPreferenceData();
    _usagePatterns.clear();
    _interactionHistory.clear();
    await _saveUserPreferences();
  }
  
  // Private methods
  
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_preferencesKey);
      
      if (jsonString != null) {
        final jsonData = json.decode(jsonString);
        _preferenceData = UserPreferenceData.fromJson(jsonData);
      }
    } catch (e) {
      // Handle gracefully - start with empty data
      _preferenceData = UserPreferenceData();
    }
  }
  
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_preferenceData.toJson());
      await prefs.setString(_preferencesKey, jsonString);
      _isDirty = false;
    } catch (e) {
      // Handle save errors gracefully
    }
  }
  
  void _startPeriodicSave() {
    _saveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isDirty) {
        _saveUserPreferences();
      }
    });
  }
  
  void _markDirty() {
    _isDirty = true;
  }
  
  void _initializeSeasonalThemes() {
    _seasonalThemes[SeasonType.spring] = ThemePersonalization(
      primaryHue: 120, // Green
      saturation: 0.6,
      brightness: 0.8,
      mood: 'fresh',
      characteristics: ['vibrant', 'energetic', 'optimistic'],
    );
    
    _seasonalThemes[SeasonType.summer] = ThemePersonalization(
      primaryHue: 200, // Blue
      saturation: 0.8,
      brightness: 0.9,
      mood: 'energetic',
      characteristics: ['bright', 'cheerful', 'dynamic'],
    );
    
    _seasonalThemes[SeasonType.autumn] = ThemePersonalization(
      primaryHue: 30, // Orange
      saturation: 0.7,
      brightness: 0.6,
      mood: 'warm',
      characteristics: ['cozy', 'comfortable', 'grounded'],
    );
    
    _seasonalThemes[SeasonType.winter] = ThemePersonalization(
      primaryHue: 240, // Deep Blue
      saturation: 0.4,
      brightness: 0.5,
      mood: 'calm',
      characteristics: ['serene', 'contemplative', 'peaceful'],
    );
  }
  
  void _updateUsagePattern(ThemeInteraction interaction) {
    final patternKey = _generatePatternKey(interaction);
    
    if (!_usagePatterns.containsKey(patternKey)) {
      _usagePatterns[patternKey] = ThemeUsagePattern(
        patternKey: patternKey,
        themeId: interaction.themeId,
        usageCount: 0,
        lastUsed: interaction.timestamp,
        averageUsageDuration: Duration.zero,
        contextTags: {},
      );
    }
    
    final pattern = _usagePatterns[patternKey]!;
    pattern.usageCount++;
    pattern.lastUsed = interaction.timestamp;
    
    // Update context tags
    interaction.context.forEach((key, value) {
      pattern.contextTags[key] = (pattern.contextTags[key] ?? 0) + 1;
    });
  }
  
  String _generatePatternKey(ThemeInteraction interaction) {
    final hour = interaction.timestamp.hour;
    final dayOfWeek = interaction.timestamp.weekday;
    return '${interaction.themeId}_${_getTimeCategory(hour)}_${_getDayCategory(dayOfWeek)}';
  }
  
  String _getTimeCategory(int hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
  
  String _getDayCategory(int dayOfWeek) {
    return dayOfWeek <= 5 ? 'weekday' : 'weekend';
  }
  
  ContextualFactors _analyzeContext(DateTime time, Map<String, dynamic> context) {
    return ContextualFactors(
      timeOfDay: _getTimeCategory(time.hour),
      dayOfWeek: _getDayCategory(time.weekday),
      season: _getCurrentSeason(time),
      month: time.month,
      isWorkingHours: _isWorkingHours(time),
      batteryLevel: context['batteryLevel'] as double?,
      ambientLight: context['ambientLight'] as double?,
      location: context['location'] as String?,
      activity: context['activity'] as String?,
    );
  }
  
  SeasonType _getCurrentSeason(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return SeasonType.spring;
    if (month >= 6 && month <= 8) return SeasonType.summer;
    if (month >= 9 && month <= 11) return SeasonType.autumn;
    return SeasonType.winter;
  }
  
  bool _isWorkingHours(DateTime time) {
    final hour = time.hour;
    final isWeekday = time.weekday <= 5;
    return isWeekday && hour >= 9 && hour <= 17;
  }
  
  BaseThemeRecommendation _getPatternBasedRecommendation(ContextualFactors factors) {
    // Find matching patterns
    final matchingPatterns = _usagePatterns.values.where((pattern) {
      return pattern.patternKey.contains(factors.timeOfDay) &&
             pattern.patternKey.contains(factors.dayOfWeek);
    }).toList();
    
    if (matchingPatterns.isEmpty) {
      return _getDefaultRecommendation(factors);
    }
    
    // Sort by usage frequency and recency
    matchingPatterns.sort((a, b) {
      final aScore = a.usageCount * _getRecencyScore(a.lastUsed);
      final bScore = b.usageCount * _getRecencyScore(b.lastUsed);
      return bScore.compareTo(aScore);
    });
    
    final bestPattern = matchingPatterns.first;
    return BaseThemeRecommendation(
      themeId: bestPattern.themeId,
      mood: _inferMoodFromPattern(bestPattern),
      brightness: _inferBrightnessFromContext(factors),
    );
  }
  
  double _getRecencyScore(DateTime lastUsed) {
    final daysSince = DateTime.now().difference(lastUsed).inDays;
    return math.max(0.1, 1.0 - (daysSince / 30.0)); // Decay over 30 days
  }
  
  String _inferMoodFromPattern(ThemeUsagePattern pattern) {
    // Analyze context tags to infer mood
    const moodMappings = {
      'work': 'focus',
      'relax': 'calm',
      'exercise': 'energetic',
      'creative': 'creative',
      'social': 'cheerful',
    };
    
    for (final entry in moodMappings.entries) {
      if (pattern.contextTags.containsKey(entry.key)) {
        return entry.value;
      }
    }
    
    return 'calm'; // Default
  }
  
  Brightness _inferBrightnessFromContext(ContextualFactors factors) {
    if (factors.ambientLight != null) {
      return factors.ambientLight! < 0.3 ? Brightness.dark : Brightness.light;
    }
    
    // Time-based fallback
    final hour = DateTime.now().hour;
    if (hour >= 20 || hour <= 6) {
      return Brightness.dark;
    }
    
    return Brightness.light;
  }
  
  BaseThemeRecommendation _getDefaultRecommendation(ContextualFactors factors) {
    return BaseThemeRecommendation(
      themeId: 'default_${factors.timeOfDay}',
      mood: factors.isWorkingHours ? 'focus' : 'calm',
      brightness: _inferBrightnessFromContext(factors),
    );
  }
  
  ThemePersonalization? _getSeasonalAdaptation(DateTime time) {
    final season = _getCurrentSeason(time);
    return _seasonalThemes[season];
  }
  
  PersonalizationScore _calculatePersonalizationScore(
    BaseThemeRecommendation base,
    ThemePersonalization? seasonal,
    ContextualFactors factors,
  ) {
    double confidence = 0.5; // Base confidence
    final List<String> reasoning = [];
    
    // Pattern-based confidence
    final patternKey = '${base.themeId}_${factors.timeOfDay}_${factors.dayOfWeek}';
    if (_usagePatterns.containsKey(patternKey)) {
      final pattern = _usagePatterns[patternKey]!;
      confidence += math.min(0.3, pattern.usageCount / 50.0);
      reasoning.add('Based on ${pattern.usageCount} previous uses');
    }
    
    // Seasonal confidence
    if (seasonal != null) {
      confidence += 0.1;
      reasoning.add('Seasonal adaptation for ${_getCurrentSeason(DateTime.now()).name}');
    }
    
    // Context confidence
    if (factors.ambientLight != null) {
      confidence += 0.1;
      reasoning.add('Ambient light consideration');
    }
    
    return PersonalizationScore(
      confidence: math.min(1.0, confidence),
      reasoning: reasoning,
    );
  }
  
  List<String> _getFavoriteThemes() {
    final themeUsage = <String, int>{};
    
    for (final pattern in _usagePatterns.values) {
      themeUsage[pattern.themeId] = (themeUsage[pattern.themeId] ?? 0) + pattern.usageCount;
    }
    
    final sorted = themeUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((e) => e.key).toList();
  }
  
  Brightness? _getPreferredBrightness() {
    int lightCount = 0;
    int darkCount = 0;
    
    for (final interaction in _interactionHistory) {
      if (interaction.context['brightness'] == 'light') lightCount++;
      if (interaction.context['brightness'] == 'dark') darkCount++;
    }
    
    if (lightCount == 0 && darkCount == 0) return null;
    return lightCount > darkCount ? Brightness.light : Brightness.dark;
  }
  
  Map<String, int> _getActiveHours() {
    final hourUsage = <int, int>{};
    
    for (final interaction in _interactionHistory) {
      final hour = interaction.timestamp.hour;
      hourUsage[hour] = (hourUsage[hour] ?? 0) + 1;
    }
    
    return Map.fromEntries(
      hourUsage.entries.map((e) => MapEntry(e.key.toString(), e.value))
    );
  }
  
  Map<SeasonType, String> _getSeasonalPreferences() {
    // This would analyze seasonal usage patterns
    return {
      SeasonType.spring: 'fresh',
      SeasonType.summer: 'energetic', 
      SeasonType.autumn: 'warm',
      SeasonType.winter: 'calm',
    };
  }
  
  List<String> _getAccessibilityNeeds() {
    final needs = <String>[];
    
    // Analyze patterns to infer accessibility needs
    final highContrastUsage = _interactionHistory
        .where((i) => i.context['highContrast'] == true)
        .length;
    
    if (highContrastUsage > _interactionHistory.length * 0.3) {
      needs.add('high_contrast');
    }
    
    return needs;
  }
  
  double _calculateLearningConfidence() {
    if (_interactionHistory.length < 10) return 0.2;
    if (_interactionHistory.length < 50) return 0.5;
    if (_interactionHistory.length < 200) return 0.8;
    return 1.0;
  }
}

// Data classes and enums

enum InteractionType {
  themeSelection,
  brightnessToogle,
  moodChange,
  manualOverride,
  automaticSuggestion,
}

enum FeedbackType {
  positive,
  negative,
  neutral,
}

enum SeasonType {
  spring,
  summer,
  autumn,
  winter,
}

class ThemeInteraction {
  final String themeId;
  final InteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  
  ThemeInteraction({
    required this.themeId,
    required this.type,
    required this.timestamp,
    required this.context,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'themeId': themeId,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'context': context,
    };
  }
  
  factory ThemeInteraction.fromJson(Map<String, dynamic> json) {
    return ThemeInteraction(
      themeId: json['themeId'],
      type: InteractionType.values[json['type']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      context: Map<String, dynamic>.from(json['context']),
    );
  }
}

class ThemeUsagePattern {
  final String patternKey;
  final String themeId;
  int usageCount;
  DateTime lastUsed;
  Duration averageUsageDuration;
  final Map<String, int> contextTags;
  
  ThemeUsagePattern({
    required this.patternKey,
    required this.themeId,
    required this.usageCount,
    required this.lastUsed,
    required this.averageUsageDuration,
    required this.contextTags,
  });
}

class ContextualFactors {
  final String timeOfDay;
  final String dayOfWeek;
  final SeasonType season;
  final int month;
  final bool isWorkingHours;
  final double? batteryLevel;
  final double? ambientLight;
  final String? location;
  final String? activity;
  
  ContextualFactors({
    required this.timeOfDay,
    required this.dayOfWeek,
    required this.season,
    required this.month,
    required this.isWorkingHours,
    this.batteryLevel,
    this.ambientLight,
    this.location,
    this.activity,
  });
}

class BaseThemeRecommendation {
  final String themeId;
  final String mood;
  final Brightness brightness;
  
  BaseThemeRecommendation({
    required this.themeId,
    required this.mood,
    required this.brightness,
  });
}

class ThemePersonalization {
  final double primaryHue;
  final double saturation;
  final double brightness;
  final String mood;
  final List<String> characteristics;
  
  ThemePersonalization({
    required this.primaryHue,
    required this.saturation,
    required this.brightness,
    required this.mood,
    required this.characteristics,
  });
}

class PersonalizationScore {
  final double confidence;
  final List<String> reasoning;
  
  PersonalizationScore({
    required this.confidence,
    required this.reasoning,
  });
}

class ThemeRecommendation {
  final String themeId;
  final String mood;
  final Brightness brightness;
  final double confidence;
  final List<String> reasoning;
  final ThemePersonalization? seasonalAdaptation;
  final ContextualFactors contextualFactors;
  final DateTime timestamp;
  
  ThemeRecommendation({
    required this.themeId,
    required this.mood,
    required this.brightness,
    required this.confidence,
    required this.reasoning,
    required this.seasonalAdaptation,
    required this.contextualFactors,
    required this.timestamp,
  });
  
  bool get isHighConfidence => confidence > 0.7;
  
  String get confidenceDescription {
    if (confidence > 0.8) return 'Very High';
    if (confidence > 0.6) return 'High';
    if (confidence > 0.4) return 'Medium';
    return 'Low';
  }
}

class FeedbackData {
  final String recommendationId;
  final FeedbackType feedback;
  final String? reason;
  final DateTime timestamp;
  
  FeedbackData({
    required this.recommendationId,
    required this.feedback,
    this.reason,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'recommendationId': recommendationId,
      'feedback': feedback.index,
      'reason': reason,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      recommendationId: json['recommendationId'],
      feedback: FeedbackType.values[json['feedback']],
      reason: json['reason'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}

class UserPreferenceData {
  final List<FeedbackData> feedbackHistory = [];
  final Map<String, dynamic> customSettings = {};
  
  // Default constructor
  UserPreferenceData();
  
  void addFeedback(FeedbackData feedback) {
    feedbackHistory.add(feedback);
    
    // Limit history size
    if (feedbackHistory.length > 500) {
      feedbackHistory.removeAt(0);
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'feedbackHistory': feedbackHistory.map((f) => f.toJson()).toList(),
      'customSettings': customSettings,
    };
  }
  
  factory UserPreferenceData.fromJson(Map<String, dynamic> json) {
    final data = UserPreferenceData();
    
    if (json['feedbackHistory'] != null) {
      for (final item in json['feedbackHistory']) {
        data.feedbackHistory.add(FeedbackData.fromJson(item));
      }
    }
    
    if (json['customSettings'] != null) {
      data.customSettings.addAll(Map<String, dynamic>.from(json['customSettings']));
    }
    
    return data;
  }
}

class UserPreferencesSummary {
  final List<String> favoriteThemes;
  final Brightness? preferredBrightness;
  final Map<String, int> activeHours;
  final Map<SeasonType, String> seasonalPreferences;
  final List<String> accessibilityNeeds;
  final double learningConfidence;
  
  UserPreferencesSummary({
    required this.favoriteThemes,
    required this.preferredBrightness,
    required this.activeHours,
    required this.seasonalPreferences,
    required this.accessibilityNeeds,
    required this.learningConfidence,
  });
}

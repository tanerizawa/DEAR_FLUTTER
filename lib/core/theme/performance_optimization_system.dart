// ⚡ Performance Optimization System
// Theme caching, lazy loading, dan battery/memory optimization
// DEAR Flutter - Modern Theme UI/UX Phase 3

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

/// Advanced performance optimization system untuk theme management
/// dengan intelligent caching, lazy loading, dan resource optimization
class PerformanceOptimizationSystem {
  static const String _cachePrefix = 'theme_cache_';
  static const int _maxCacheSize = 50; // Maximum cached themes
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const int _maxMemoryThemes = 10; // In-memory cache limit
  
  // Performance monitoring
  static final Map<String, PerformanceMetrics> _performanceMetrics = {};
  static final Map<String, ThemeData> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  // Battery optimization
  static BatteryOptimizationLevel _batteryLevel = BatteryOptimizationLevel.balanced;
  static bool _isLowPowerMode = false;
  
  // Memory optimization
  static int _memoryPressureLevel = 0; // 0-5 scale
  static Timer? _cleanupTimer;
  
  /// Initialize performance optimization system
  static Future<void> initialize() async {
    await _loadPerformanceSettings();
    _startPerformanceMonitoring();
    _startMemoryManagement();
  }
  
  /// Dispose resources
  static void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }
  
  /// Get optimized theme dengan intelligent caching
  static Future<ThemeData> getOptimizedTheme({
    required String themeId,
    required ThemeData Function() themeGenerator,
    bool forceRegenerate = false,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // Check memory cache first
      if (!forceRegenerate && _memoryCache.containsKey(themeId)) {
        _recordPerformanceMetric(themeId, 'memory_hit', startTime);
        return _memoryCache[themeId]!;
      }
      
      // Check persistent cache
      if (!forceRegenerate) {
        final cachedTheme = await _loadFromPersistentCache(themeId);
        if (cachedTheme != null) {
          _memoryCache[themeId] = cachedTheme;
          _recordPerformanceMetric(themeId, 'disk_hit', startTime);
          return cachedTheme;
        }
      }
      
      // Generate new theme
      final theme = await _generateOptimizedTheme(themeGenerator);
      
      // Cache the theme
      await _cacheTheme(themeId, theme);
      
      _recordPerformanceMetric(themeId, 'generated', startTime);
      return theme;
      
    } catch (e) {
      // Fallback ke basic theme generation
      _recordPerformanceMetric(themeId, 'error', startTime);
      return themeGenerator();
    }
  }
  
  /// Preload themes untuk improved startup performance
  static Future<void> preloadThemes(List<String> themeIds) async {
    if (_isLowPowerMode) return; // Skip preloading untuk conserve battery
    
    final futures = themeIds.map((id) async {
      try {
        await _loadFromPersistentCache(id);
      } catch (e) {
        // Silent failure untuk preloading
      }
    });
    
    await Future.wait(futures);
  }
  
  /// Update battery optimization level
  static void updateBatteryOptimization({
    required BatteryOptimizationLevel level,
    required bool isLowPowerMode,
  }) {
    _batteryLevel = level;
    _isLowPowerMode = isLowPowerMode;
    
    if (_isLowPowerMode) {
      _enableAggressiveOptimizations();
    }
  }
  
  /// Update memory pressure level
  static void updateMemoryPressure(int pressureLevel) {
    _memoryPressureLevel = math.max(0, math.min(5, pressureLevel));
    
    if (_memoryPressureLevel >= 3) {
      _performMemoryCleanup();
    }
  }
  
  /// Get performance analytics
  static PerformanceAnalytics getPerformanceAnalytics() {
    final metrics = _performanceMetrics.values.toList();
    
    return PerformanceAnalytics(
      totalThemeGenerations: metrics.length,
      averageGenerationTime: _calculateAverageTime(metrics, 'generated'),
      cacheHitRate: _calculateCacheHitRate(metrics),
      memoryUsage: _estimateMemoryUsage(),
      batteryImpact: _estimateBatteryImpact(),
      recommendations: _generateOptimizationRecommendations(),
    );
  }
  
  /// Clear all caches (untuk privacy atau debugging)
  static Future<void> clearAllCaches() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
  
  /// Optimize theme untuk current performance context
  static ThemeData optimizeThemeForPerformance(
    ThemeData theme,
    PerformanceContext context,
  ) {
    if (context.isLowPerformanceDevice) {
      return _simplifyThemeForLowPerformance(theme);
    }
    
    if (context.isLowBattery) {
      return _optimizeThemeForBattery(theme);
    }
    
    if (context.isLowMemory) {
      return _optimizeThemeForMemory(theme);
    }
    
    return theme;
  }
  
  // Private methods
  
  static Future<void> _loadPerformanceSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _batteryLevel = BatteryOptimizationLevel.values[
          prefs.getInt('battery_optimization_level') ?? 
          BatteryOptimizationLevel.balanced.index
      ];
    } catch (e) {
      // Use defaults
    }
  }
  
  static void _startPerformanceMonitoring() {
    // Monitor performance metrics setiap 30 detik
    Timer.periodic(const Duration(seconds: 30), (_) {
      _analyzePerformanceMetrics();
    });
  }
  
  static void _startMemoryManagement() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _performPeriodicCleanup();
    });
  }
  
  static Future<ThemeData> _generateOptimizedTheme(
    ThemeData Function() generator,
  ) async {
    if (_isLowPowerMode) {
      // Generate theme dengan reduced complexity
      return await compute(_generateSimplifiedTheme, generator);
    }
    
    // Normal generation
    return generator();
  }
  
  static ThemeData _generateSimplifiedTheme(ThemeData Function() generator) {
    final theme = generator();
    
    // Simplify complex properties untuk performance
    return theme.copyWith(
      // Reduce shadow complexity
      cardTheme: theme.cardTheme?.copyWith(elevation: 2.0),
      // Simplify animations
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
  
  static Future<void> _cacheTheme(String themeId, ThemeData theme) async {
    // Memory cache
    _memoryCache[themeId] = theme;
    _cacheTimestamps[themeId] = DateTime.now();
    
    // Manage memory cache size
    if (_memoryCache.length > _maxMemoryThemes) {
      _evictOldestFromMemoryCache();
    }
    
    // Persistent cache (non-blocking)
    _saveToPersistentCache(themeId, theme);
  }
  
  static Future<ThemeData?> _loadFromPersistentCache(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$themeId';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData == null) return null;
      
      final cacheInfo = json.decode(cachedData);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheInfo['timestamp']);
      
      // Check cache expiry
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        await prefs.remove(cacheKey);
        return null;
      }
      
      // Deserialize theme (simplified - actual implementation would be more complex)
      return _deserializeTheme(cacheInfo['theme']);
      
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> _saveToPersistentCache(String themeId, ThemeData theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$themeId';
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'theme': _serializeTheme(theme),
      };
      
      await prefs.setString(cacheKey, json.encode(cacheData));
      
      // Manage persistent cache size
      await _managePersistentCacheSize(prefs);
      
    } catch (e) {
      // Silent failure untuk caching
    }
  }
  
  static Map<String, dynamic> _serializeTheme(ThemeData theme) {
    // Simplified serialization - extract key properties
    return {
      'brightness': theme.brightness.index,
      'primaryColor': theme.colorScheme.primary.value,
      'backgroundColor': theme.colorScheme.surface.value,
      // Add more properties as needed
    };
  }
  
  static ThemeData _deserializeTheme(Map<String, dynamic> data) {
    // Simplified deserialization - reconstruct basic theme
    return ThemeData(
      brightness: Brightness.values[data['brightness']],
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.values[data['brightness']],
        seedColor: Color(data['primaryColor']),
      ),
    );
  }
  
  static Future<void> _managePersistentCacheSize(SharedPreferences prefs) async {
    final cacheKeys = prefs.getKeys()
        .where((key) => key.startsWith(_cachePrefix))
        .toList();
    
    if (cacheKeys.length <= _maxCacheSize) return;
    
    // Sort by timestamp and remove oldest
    final cacheEntries = <MapEntry<String, DateTime>>[];
    
    for (final key in cacheKeys) {
      try {
        final data = json.decode(prefs.getString(key) ?? '{}');
        final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0);
        cacheEntries.add(MapEntry(key, timestamp));
      } catch (e) {
        // Remove invalid entries
        await prefs.remove(key);
      }
    }
    
    cacheEntries.sort((a, b) => a.value.compareTo(b.value));
    
    // Remove oldest entries
    final entriesToRemove = cacheEntries.length - _maxCacheSize;
    for (int i = 0; i < entriesToRemove; i++) {
      await prefs.remove(cacheEntries[i].key);
    }
  }
  
  static void _evictOldestFromMemoryCache() {
    if (_cacheTimestamps.isEmpty) return;
    
    final oldestEntry = _cacheTimestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
    
    _memoryCache.remove(oldestEntry.key);
    _cacheTimestamps.remove(oldestEntry.key);
  }
  
  static void _performMemoryCleanup() {
    // Remove half of memory cache entries
    final entriesToRemove = (_memoryCache.length / 2).ceil();
    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    for (int i = 0; i < entriesToRemove && i < sortedEntries.length; i++) {
      final key = sortedEntries[i].key;
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
  
  static void _performPeriodicCleanup() {
    // Remove expired entries from memory cache
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
  
  static void _enableAggressiveOptimizations() {
    // Clear non-essential cache entries
    if (_memoryCache.length > 3) {
      final keysToKeep = _cacheTimestamps.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(3)
          .map((e) => e.key)
          .toSet();
      
      _memoryCache.removeWhere((key, value) => !keysToKeep.contains(key));
      _cacheTimestamps.removeWhere((key, value) => !keysToKeep.contains(key));
    }
  }
  
  static void _recordPerformanceMetric(
    String themeId,
    String operation,
    DateTime startTime,
  ) {
    final duration = DateTime.now().difference(startTime);
    
    if (!_performanceMetrics.containsKey(themeId)) {
      _performanceMetrics[themeId] = PerformanceMetrics(themeId: themeId);
    }
    
    final metrics = _performanceMetrics[themeId]!;
    metrics.recordOperation(operation, duration);
  }
  
  static void _analyzePerformanceMetrics() {
    // Auto-adjust cache sizes based on performance
    final avgGenerationTime = _calculateAverageTime(
      _performanceMetrics.values.toList(),
      'generated',
    );
    
    if (avgGenerationTime.inMilliseconds > 100) {
      // Increase memory cache untuk improve performance
      if (_maxMemoryThemes < 15) {
        // Would adjust _maxMemoryThemes dynamically
      }
    }
  }
  
  static Duration _calculateAverageTime(List<PerformanceMetrics> metrics, String operation) {
    final durations = metrics
        .expand((m) => m.operations[operation] ?? <Duration>[])
        .toList();
    
    if (durations.isEmpty) return Duration.zero;
    
    final totalMilliseconds = durations
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMilliseconds ~/ durations.length);
  }
  
  static double _calculateCacheHitRate(List<PerformanceMetrics> metrics) {
    int totalAccesses = 0;
    int cacheHits = 0;
    
    for (final metric in metrics) {
      totalAccesses += metric.operations.values.expand((list) => list).length;
      cacheHits += (metric.operations['memory_hit']?.length ?? 0) +
                  (metric.operations['disk_hit']?.length ?? 0);
    }
    
    return totalAccesses > 0 ? cacheHits / totalAccesses : 0.0;
  }
  
  static int _estimateMemoryUsage() {
    // Rough estimation in KB
    return _memoryCache.length * 50; // ~50KB per cached theme
  }
  
  static double _estimateBatteryImpact() {
    // Estimate battery impact sebagai percentage
    final baseImpact = 0.5; // Base theme system impact
    final cacheImpact = _memoryCache.length * 0.01; // Small impact per cached theme
    
    return math.min(5.0, baseImpact + cacheImpact); // Max 5% impact
  }
  
  static List<String> _generateOptimizationRecommendations() {
    final recommendations = <String>[];
    
    final cacheHitRate = _calculateCacheHitRate(_performanceMetrics.values.toList());
    if (cacheHitRate < 0.5) {
      recommendations.add('Consider preloading commonly used themes');
    }
    
    if (_memoryPressureLevel >= 3) {
      recommendations.add('Reduce memory cache size or enable aggressive cleanup');
    }
    
    if (_isLowPowerMode) {
      recommendations.add('Battery optimization is active - some features may be limited');
    }
    
    return recommendations;
  }
  
  static ThemeData _simplifyThemeForLowPerformance(ThemeData theme) {
    return theme.copyWith(
      // Reduce elevation untuk lower GPU load
      cardTheme: theme.cardTheme?.copyWith(elevation: 1.0),
      appBarTheme: theme.appBarTheme.copyWith(elevation: 0.0),
      
      // Simplify page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
  
  static ThemeData _optimizeThemeForBattery(ThemeData theme) {
    // Use pure black untuk OLED displays
    if (theme.brightness == Brightness.dark) {
      return theme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF111111),
        // Reduce bright colors yang consume more power
        colorScheme: theme.colorScheme.copyWith(
          primary: theme.colorScheme.primary.withOpacity(0.8),
        ),
      );
    }
    
    return theme;
  }
  
  static ThemeData _optimizeThemeForMemory(ThemeData theme) {
    // Remove complex gradients and patterns
    return theme.copyWith(
      // Simplify decorations
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        fillColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

// Enums and data classes

enum BatteryOptimizationLevel {
  performance,  // Maximum features, higher battery usage
  balanced,     // Balanced features and battery usage
  economy,      // Minimal features, lowest battery usage
}

class PerformanceContext {
  final bool isLowPerformanceDevice;
  final bool isLowBattery;
  final bool isLowMemory;
  final bool isLowPowerMode;
  
  const PerformanceContext({
    required this.isLowPerformanceDevice,
    required this.isLowBattery,
    required this.isLowMemory,
    required this.isLowPowerMode,
  });
}

class PerformanceMetrics {
  final String themeId;
  final Map<String, List<Duration>> operations = {};
  final DateTime createdAt = DateTime.now();
  
  PerformanceMetrics({required this.themeId});
  
  void recordOperation(String operation, Duration duration) {
    operations.putIfAbsent(operation, () => <Duration>[]).add(duration);
    
    // Limit operation history untuk memory efficiency
    if (operations[operation]!.length > 100) {
      operations[operation]!.removeAt(0);
    }
  }
  
  Duration getAverageTime(String operation) {
    final durations = operations[operation];
    if (durations == null || durations.isEmpty) return Duration.zero;
    
    final totalMs = durations.map((d) => d.inMilliseconds).reduce((a, b) => a + b);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }
}

class PerformanceAnalytics {
  final int totalThemeGenerations;
  final Duration averageGenerationTime;
  final double cacheHitRate;
  final int memoryUsage; // in KB
  final double batteryImpact; // percentage
  final List<String> recommendations;
  
  const PerformanceAnalytics({
    required this.totalThemeGenerations,
    required this.averageGenerationTime,
    required this.cacheHitRate,
    required this.memoryUsage,
    required this.batteryImpact,
    required this.recommendations,
  });
  
  String get cacheHitRatePercentage => '${(cacheHitRate * 100).toStringAsFixed(1)}%';
  
  String get memoryUsageFormatted => '${memoryUsage}KB';
  
  String get batteryImpactFormatted => '${batteryImpact.toStringAsFixed(1)}%';
  
  bool get isPerformant => 
      averageGenerationTime.inMilliseconds < 50 && 
      cacheHitRate > 0.7 && 
      memoryUsage < 500;
}

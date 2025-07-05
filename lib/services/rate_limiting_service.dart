// lib/services/rate_limiting_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateLimitingService {
  static final RateLimitingService _instance = RateLimitingService._internal();
  factory RateLimitingService() => _instance;
  RateLimitingService._internal();

  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, Timer?> _cooldownTimers = {};
  
  // Rate limiting configuration
  static const Map<String, Map<String, int>> _rateLimits = {
    'music_fetch': {
      'requests_per_minute': 3,
      'requests_per_hour': 10,
      'cooldown_seconds': 30,
    },
    'youtube_search': {
      'requests_per_minute': 2,
      'requests_per_hour': 15,
      'cooldown_seconds': 45,
    },
    'profile_analysis': {
      'requests_per_minute': 5,
      'requests_per_hour': 20,
      'cooldown_seconds': 15,
    },
  };

  /// Check if we can make a request for the given operation
  Future<bool> canMakeRequest(String operation) async {
    final config = _rateLimits[operation];
    if (config == null) return true; // No limits configured

    final now = DateTime.now();
    
    // Initialize history if not exists
    _requestHistory[operation] ??= [];
    
    // Clean old requests
    _requestHistory[operation]!.removeWhere(
      (time) => now.difference(time).inHours >= 1
    );
    
    final recentRequests = _requestHistory[operation]!;
    
    // Check minute limit
    final requestsInLastMinute = recentRequests
        .where((time) => now.difference(time).inMinutes < 1)
        .length;
    
    if (requestsInLastMinute >= config['requests_per_minute']!) {
      debugPrint('[RateLimit] Minute limit exceeded for $operation');
      return false;
    }
    
    // Check hour limit
    if (recentRequests.length >= config['requests_per_hour']!) {
      debugPrint('[RateLimit] Hour limit exceeded for $operation');
      return false;
    }
    
    // Check if in cooldown
    if (_cooldownTimers[operation]?.isActive == true) {
      debugPrint('[RateLimit] In cooldown for $operation');
      return false;
    }
    
    return true;
  }

  /// Record a successful request
  void recordRequest(String operation) {
    final now = DateTime.now();
    _requestHistory[operation] ??= [];
    _requestHistory[operation]!.add(now);
    
    debugPrint('[RateLimit] Recorded request for $operation');
  }

  /// Record a failed request and potentially start cooldown
  void recordFailedRequest(String operation, {bool startCooldown = true}) {
    recordRequest(operation); // Still counts towards rate limit
    
    if (startCooldown) {
      startCooldownPeriod(operation);
    }
    
    debugPrint('[RateLimit] Recorded failed request for $operation');
  }

  /// Start cooldown period for an operation
  void startCooldownPeriod(String operation) {
    final config = _rateLimits[operation];
    if (config == null) return;
    
    final cooldownSeconds = config['cooldown_seconds']!;
    
    _cooldownTimers[operation]?.cancel();
    _cooldownTimers[operation] = Timer(
      Duration(seconds: cooldownSeconds),
      () {
        debugPrint('[RateLimit] Cooldown ended for $operation');
        _cooldownTimers[operation] = null;
      }
    );
    
    debugPrint('[RateLimit] Started ${cooldownSeconds}s cooldown for $operation');
  }

  /// Get remaining cooldown time
  Duration getRemainingCooldown(String operation) {
    final timer = _cooldownTimers[operation];
    if (timer?.isActive != true) return Duration.zero;
    
    final config = _rateLimits[operation];
    if (config == null) return Duration.zero;
    
    // This is an approximation since Timer doesn't provide remaining time
    return Duration(seconds: config['cooldown_seconds']!);
  }

  /// Get next available time for request
  DateTime? getNextAvailableTime(String operation) {
    final config = _rateLimits[operation];
    if (config == null) return null;
    
    final now = DateTime.now();
    _requestHistory[operation] ??= [];
    
    // Check if in cooldown
    if (_cooldownTimers[operation]?.isActive == true) {
      return now.add(getRemainingCooldown(operation));
    }
    
    // Check minute limit
    final requestsInLastMinute = _requestHistory[operation]!
        .where((time) => now.difference(time).inMinutes < 1)
        .toList();
    
    if (requestsInLastMinute.length >= config['requests_per_minute']!) {
      // Find oldest request in last minute and add 1 minute
      requestsInLastMinute.sort();
      return requestsInLastMinute.first.add(const Duration(minutes: 1));
    }
    
    return null; // Can make request now
  }

  /// Get request statistics for an operation
  Map<String, dynamic> getStats(String operation) {
    final config = _rateLimits[operation];
    final now = DateTime.now();
    _requestHistory[operation] ??= [];
    
    final requestsInLastMinute = _requestHistory[operation]!
        .where((time) => now.difference(time).inMinutes < 1)
        .length;
    
    final requestsInLastHour = _requestHistory[operation]!.length;
    
    return {
      'operation': operation,
      'requests_last_minute': requestsInLastMinute,
      'requests_last_hour': requestsInLastHour,
      'minute_limit': config?['requests_per_minute'] ?? 'No limit',
      'hour_limit': config?['requests_per_hour'] ?? 'No limit',
      'in_cooldown': _cooldownTimers[operation]?.isActive == true,
      'remaining_cooldown': getRemainingCooldown(operation).inSeconds,
      'next_available': getNextAvailableTime(operation)?.toIso8601String(),
    };
  }

  /// Get all statistics
  Map<String, dynamic> getAllStats() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'operations': _rateLimits.keys.map((op) => getStats(op)).toList(),
    };
  }

  /// Save rate limiting data to persistent storage
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save request history (last hour only)
      final now = DateTime.now();
      for (final entry in _requestHistory.entries) {
        final recentRequests = entry.value
            .where((time) => now.difference(time).inHours < 1)
            .map((time) => time.millisecondsSinceEpoch)
            .toList();
        
        await prefs.setStringList(
          'rate_limit_${entry.key}',
          recentRequests.map((ms) => ms.toString()).toList(),
        );
      }
      
      debugPrint('[RateLimit] Saved to storage');
    } catch (e) {
      debugPrint('[RateLimit] Failed to save: $e');
    }
  }

  /// Load rate limiting data from persistent storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final operation in _rateLimits.keys) {
        final stored = prefs.getStringList('rate_limit_$operation');
        if (stored != null) {
          _requestHistory[operation] = stored
              .map((ms) => DateTime.fromMillisecondsSinceEpoch(int.parse(ms)))
              .toList();
        }
      }
      
      debugPrint('[RateLimit] Loaded from storage');
    } catch (e) {
      debugPrint('[RateLimit] Failed to load: $e');
    }
  }

  /// Clear all rate limiting data
  void clear() {
    _requestHistory.clear();
    for (final timer in _cooldownTimers.values) {
      timer?.cancel();
    }
    _cooldownTimers.clear();
    debugPrint('[RateLimit] Cleared all data');
  }

  /// Dispose resources
  void dispose() {
    for (final timer in _cooldownTimers.values) {
      timer?.cancel();
    }
    _cooldownTimers.clear();
  }
}

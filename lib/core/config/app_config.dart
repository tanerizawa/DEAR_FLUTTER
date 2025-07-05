// lib/core/config/app_config.dart

import 'package:flutter/foundation.dart';

class AppConfig {
  // Environment detection
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  
  // Environment variables
  static const String _prodBaseUrl = 'https://server-qp6y.onrender.com/api/v1/';
  static const String _devBaseUrl = 'http://localhost:8000/api/v1/';
  
  // API Base URLs
  static String get baseUrl {
    // Check for custom environment variable first
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;
    
    // Check for debug mode flag
    const useLocalApi = bool.fromEnvironment('USE_LOCAL_API', defaultValue: false);
    if (useLocalApi) return _devBaseUrl;
    
    // Default: always use production unless explicitly told to use local
    return _prodBaseUrl;
  }
  
  // Debug-specific URLs
  static String get debugBaseUrl => _devBaseUrl;
  static String get prodBaseUrl => _prodBaseUrl;
  
  // Feature flags
  static bool get enableDebugEndpoints => isDebug;
  static bool get enableLocalBackend => !isRelease;
  
  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // Logging
  static bool get enableNetworkLogging => isDebug;
  static bool get enableDetailedLogging => isDebug;
}

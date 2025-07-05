// lib/data/datasources/remote/debug_api_service.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/core/config/app_config.dart';

@injectable
class DebugApiService {
  DebugApiService();

  /// Create a separate Dio instance for debug endpoints (always local)
  Dio get _debugDio {
    final debugDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.debugBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      ),
    );
    return debugDio;
  }

  /// Test backend connection
  Future<Map<String, dynamic>> ping() async {
    if (!AppConfig.enableDebugEndpoints) {
      throw Exception('Debug endpoints not available in release mode');
    }
    
    final response = await _debugDio.get('debug/ping');
    return response.data as Map<String, dynamic>;
  }

  /// Test database connection
  Future<Map<String, dynamic>> testDatabase() async {
    if (!AppConfig.enableDebugEndpoints) {
      throw Exception('Debug endpoints not available in release mode');
    }
    
    final response = await _debugDio.get('debug/db-test');
    return response.data as Map<String, dynamic>;
  }

  /// Get system info
  Future<Map<String, dynamic>> getSystemInfo() async {
    if (!AppConfig.enableDebugEndpoints) {
      throw Exception('Debug endpoints not available in release mode');
    }
    
    final response = await _debugDio.get('debug/info');
    return response.data as Map<String, dynamic>;
  }

  /// Check if local backend is reachable
  Future<bool> isLocalBackendReachable() async {
    try {
      await ping();
      return true;
    } catch (e) {
      return false;
    }
  }
}

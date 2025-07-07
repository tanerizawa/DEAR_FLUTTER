// lib/core/error/app_error_handler.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum ErrorType {
  network,
  timeout,
  rateLimit,
  serverError,
  unknown
}

class AppError implements Exception {
  final String message;
  final ErrorType type;
  final String? code;
  final dynamic originalError;
  final DateTime timestamp;
  
  AppError({
    required this.message,
    required this.type,
    this.code,
    this.originalError,
  }) : timestamp = DateTime.now();
  
  @override
  String toString() => 'AppError($type): $message';
}

class AppErrorHandler {
  static final List<AppError> _errorHistory = [];
  static final int _maxHistorySize = 50;
  
  /// Parse error from API response or exception
  static AppError parseError(dynamic error) {
    if (error is AppError) return error;
    
    // Handle HTTP errors
    if (error.toString().contains('429') || 
        error.toString().toLowerCase().contains('rate limit')) {
      return AppError(
        message: 'Terlalu banyak permintaan. Silakan tunggu beberapa saat.',
        type: ErrorType.rateLimit,
        code: 'RATE_LIMIT_EXCEEDED',
        originalError: error,
      );
    }
    
    if (error.toString().contains('timeout') ||
        error.toString().toLowerCase().contains('time out')) {
      return AppError(
        message: 'Koneksi timeout. Periksa koneksi internet Anda.',
        type: ErrorType.timeout,
        code: 'TIMEOUT',
        originalError: error,
      );
    }
    
    if (error.toString().contains('500') ||
        error.toString().toLowerCase().contains('server error')) {
      return AppError(
        message: 'Server sedang bermasalah. Coba lagi nanti.',
        type: ErrorType.serverError,
        code: 'SERVER_ERROR',
        originalError: error,
      );
    }
    
    if (error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection')) {
      return AppError(
        message: 'Masalah koneksi internet. Periksa koneksi Anda.',
        type: ErrorType.network,
        code: 'NETWORK_ERROR',
        originalError: error,
      );
    }
    
    // Default unknown error
    return AppError(
      message: 'Terjadi kesalahan yang tidak terduga.',
      type: ErrorType.unknown,
      code: 'UNKNOWN',
      originalError: error,
    );
  }
  
  /// Handle error with user-friendly message and actions
  static void handleError(
    BuildContext context, 
    dynamic error, {
    VoidCallback? onRetry,
    bool showSnackBar = true,
  }) {
    final appError = parseError(error);
    _recordError(appError);
    
    debugPrint('[AppErrorHandler] ${appError.toString()}');
    
    if (showSnackBar && context.mounted) {
      _showErrorSnackBar(context, appError, onRetry: onRetry);
    }
  }
  
  /// Record error for analytics and debugging
  static void _recordError(AppError error) {
    _errorHistory.add(error);
    
    // Keep history size manageable
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }
    
    // In production, send to crash analytics
    if (kReleaseMode) {
      // TODO: Send to Firebase Crashlytics or similar
    }
  }
  
  /// Show user-friendly error message
  static void _showErrorSnackBar(
    BuildContext context, 
    AppError error, {
    VoidCallback? onRetry,
  }) {
    Color backgroundColor;
    IconData icon;
    
    switch (error.type) {
      case ErrorType.rateLimit:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.timer_outlined;
        break;
      case ErrorType.timeout:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.timer_off_outlined;
        break;
      case ErrorType.network:
        backgroundColor = Colors.red.shade600;
        icon = Icons.wifi_off_outlined;
        break;
      case ErrorType.serverError:
        backgroundColor = Colors.purple.shade600;
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
        icon = Icons.warning_outlined;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: _getDurationForErrorType(error.type),
        action: onRetry != null && _shouldShowRetryAction(error.type)
            ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
  
  /// Get display duration based on error type
  static Duration _getDurationForErrorType(ErrorType type) {
    switch (type) {
      case ErrorType.rateLimit:
        return const Duration(seconds: 6);
      case ErrorType.timeout:
      case ErrorType.network:
        return const Duration(seconds: 5);
      default:
        return const Duration(seconds: 4);
    }
  }
  
  /// Check if retry action should be shown
  static bool _shouldShowRetryAction(ErrorType type) {
    switch (type) {
      case ErrorType.rateLimit:
        return false; // Don't encourage immediate retry for rate limits
      case ErrorType.timeout:
      case ErrorType.network:
      case ErrorType.serverError:
        return true;
      default:
        return false;
    }
  }
  
  /// Get recent errors for debugging
  static List<AppError> getRecentErrors({int limit = 10}) {
    return _errorHistory.reversed.take(limit).toList();
  }
  
  /// Clear error history
  static void clearErrorHistory() {
    _errorHistory.clear();
  }
  
  /// Check if we're experiencing rate limiting
  static bool isRateLimited() {
    final recentRateLimitErrors = _errorHistory
        .where((error) => 
            error.type == ErrorType.rateLimit &&
            DateTime.now().difference(error.timestamp).inMinutes < 5)
        .length;
    
    return recentRateLimitErrors >= 2;
  }
  
  /// Get suggested wait time for rate limited operations
  static Duration getRecommendedWaitTime() {
    if (isRateLimited()) {
      final lastRateLimit = _errorHistory
          .where((error) => error.type == ErrorType.rateLimit)
          .lastOrNull;
      
      if (lastRateLimit != null) {
        final timeSinceLastError = DateTime.now().difference(lastRateLimit.timestamp);
        const recommendedWait = Duration(minutes: 2);
        
        if (timeSinceLastError < recommendedWait) {
          return recommendedWait - timeSinceLastError;
        }
      }
    }
    
    return Duration.zero;
  }
}

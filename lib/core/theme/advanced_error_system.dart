// lib/core/theme/advanced_error_system.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/core/theme/home_layout_system.dart';
import 'package:dear_flutter/core/theme/home_typography_system.dart';

/// Error types for different handling strategies
enum ErrorType {
  network,
  timeout,
  server,
  parsing,
  permission,
  storage,
  unknown,
}

/// Error severity levels
enum ErrorSeverity {
  low,      // Non-blocking, informational
  medium,   // Degrades experience but app continues
  high,     // Blocks functionality but app remains stable
  critical, // Requires immediate attention
}

/// Phase 3: Advanced Error Handling System
/// 
/// Provides sophisticated error states with recovery actions and user-friendly messaging
class AdvancedErrorSystem {
  
  /// Create user-friendly error widget
  static Widget errorWidget({
    required ErrorType errorType,
    required String message,
    ErrorSeverity severity = ErrorSeverity.medium,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryText,
    String? dismissText,
    bool isDarkMode = false,
    bool showDetails = false,
    String? technicalDetails,
  }) {
    final errorConfig = _getErrorConfiguration(errorType, severity, isDarkMode);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      ),
      padding: EdgeInsets.all(FibonacciSpacing.lg),
      decoration: BoxDecoration(
        color: errorConfig.backgroundColor,
        borderRadius: BorderRadius.circular(FibonacciSpacing.lg),
        border: Border.all(
          color: errorConfig.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: errorConfig.shadowColor,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(FibonacciSpacing.xs),
                decoration: BoxDecoration(
                  color: errorConfig.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(FibonacciSpacing.sm),
                ),
                child: Icon(
                  errorConfig.icon,
                  color: errorConfig.iconColor,
                  size: 24,
                ),
              ),
              SizedBox(width: FibonacciSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorConfig.title,
                      style: HomeTypographySystem.sectionHeader(color: errorConfig.titleColor).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (errorConfig.subtitle != null) ...[
                      SizedBox(height: FibonacciSpacing.xs),
                      Text(
                        errorConfig.subtitle!,
                        style: HomeTypographySystem.caption(color: errorConfig.subtitleColor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: FibonacciSpacing.md),
          
          // Main message
          Text(
            message,
            style: HomeTypographySystem.bodyText(color: errorConfig.messageColor).copyWith(
              height: 1.4,
            ),
          ),
          
          // Technical details (expandable)
          if (showDetails && technicalDetails != null) ...[
            SizedBox(height: FibonacciSpacing.md),
            _buildTechnicalDetails(technicalDetails, errorConfig, isDarkMode),
          ],
          
          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            SizedBox(height: FibonacciSpacing.lg),
            _buildActionButtons(
              onRetry: onRetry,
              onDismiss: onDismiss,
              retryText: retryText,
              dismissText: dismissText,
              errorConfig: errorConfig,
            ),
          ],
        ],
      ),
    );
  }
  
  /// Quick error snackbar for non-critical errors
  static void showErrorSnackbar({
    required BuildContext context,
    required String message,
    ErrorType errorType = ErrorType.unknown,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
    String? retryText,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final errorConfig = _getErrorConfiguration(errorType, ErrorSeverity.low, isDarkMode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              errorConfig.icon,
              color: errorConfig.iconColor,
              size: 20,
            ),
            SizedBox(width: FibonacciSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: errorConfig.messageColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: errorConfig.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FibonacciSpacing.md),
        ),
        action: onRetry != null ? SnackBarAction(
          label: retryText ?? 'Retry',
          textColor: errorConfig.actionColor,
          onPressed: onRetry,
        ) : null,
      ),
    );
  }
  
  /// In-line error widget for forms and inputs
  static Widget inlineError({
    required String message,
    ErrorSeverity severity = ErrorSeverity.medium,
    bool isDarkMode = false,
  }) {
    final color = severity == ErrorSeverity.high 
        ? (isDarkMode ? Colors.red.shade300 : Colors.red.shade700)
        : (isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700);
    
    return Padding(
      padding: EdgeInsets.only(
        top: FibonacciSpacing.xs,
        left: FibonacciSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            severity == ErrorSeverity.high 
                ? Icons.error_outline 
                : Icons.warning_amber_outlined,
            color: color,
            size: 16,
          ),
          SizedBox(width: FibonacciSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: HomeTypographySystem.caption(color: color).copyWith(
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Empty state widget with error context
  static Widget emptyStateWithError({
    required String title,
    required String description,
    ErrorType errorType = ErrorType.unknown,
    VoidCallback? onRetry,
    String? retryText,
    bool isDarkMode = false,
  }) {
    final errorConfig = _getErrorConfiguration(errorType, ErrorSeverity.medium, isDarkMode);
    
    return Center(
      child: Container(
        padding: EdgeInsets.all(FibonacciSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(FibonacciSpacing.lg),
              decoration: BoxDecoration(
                color: errorConfig.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorConfig.icon,
                color: errorConfig.iconColor,
                size: 48,
              ),
            ),
            
            SizedBox(height: FibonacciSpacing.lg),
            
            Text(
              title,
              textAlign: TextAlign.center,
              style: HomeTypographySystem.sectionHeader(color: errorConfig.titleColor).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: FibonacciSpacing.md),
            
            Text(
              description,
              textAlign: TextAlign.center,
              style: HomeTypographySystem.bodyText(color: errorConfig.messageColor).copyWith(
                height: 1.4,
              ),
            ),
            
            if (onRetry != null) ...[
              SizedBox(height: FibonacciSpacing.xl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorConfig.actionColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: FibonacciSpacing.lg,
                    vertical: FibonacciSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FibonacciSpacing.md),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Get error configuration based on type and severity
  static _ErrorConfiguration _getErrorConfiguration(
    ErrorType type, 
    ErrorSeverity severity, 
    bool isDarkMode
  ) {
    switch (type) {
      case ErrorType.network:
        return _ErrorConfiguration(
          icon: Icons.wifi_off_outlined,
          title: 'Connection Issue',
          subtitle: 'Check your internet connection',
          backgroundColor: isDarkMode 
              ? Colors.blue.shade900.withOpacity(0.2) 
              : Colors.blue.shade50,
          borderColor: isDarkMode 
              ? Colors.blue.shade600 
              : Colors.blue.shade200,
          iconColor: isDarkMode 
              ? Colors.blue.shade300 
              : Colors.blue.shade700,
          iconBackgroundColor: isDarkMode 
              ? Colors.blue.shade800.withOpacity(0.3) 
              : Colors.blue.shade100,
          titleColor: isDarkMode 
              ? Colors.blue.shade200 
              : Colors.blue.shade800,
          subtitleColor: isDarkMode 
              ? Colors.blue.shade300 
              : Colors.blue.shade600,
          messageColor: isDarkMode 
              ? Colors.blue.shade100 
              : Colors.blue.shade700,
          actionColor: isDarkMode 
              ? Colors.blue.shade400 
              : Colors.blue.shade600,
          shadowColor: Colors.blue.withOpacity(0.1),
        );
        
      case ErrorType.timeout:
        return _ErrorConfiguration(
          icon: Icons.access_time_outlined,
          title: 'Request Timeout',
          subtitle: 'Taking longer than expected',
          backgroundColor: isDarkMode 
              ? Colors.orange.shade900.withOpacity(0.2) 
              : Colors.orange.shade50,
          borderColor: isDarkMode 
              ? Colors.orange.shade600 
              : Colors.orange.shade200,
          iconColor: isDarkMode 
              ? Colors.orange.shade300 
              : Colors.orange.shade700,
          iconBackgroundColor: isDarkMode 
              ? Colors.orange.shade800.withOpacity(0.3) 
              : Colors.orange.shade100,
          titleColor: isDarkMode 
              ? Colors.orange.shade200 
              : Colors.orange.shade800,
          subtitleColor: isDarkMode 
              ? Colors.orange.shade300 
              : Colors.orange.shade600,
          messageColor: isDarkMode 
              ? Colors.orange.shade100 
              : Colors.orange.shade700,
          actionColor: isDarkMode 
              ? Colors.orange.shade400 
              : Colors.orange.shade600,
          shadowColor: Colors.orange.withOpacity(0.1),
        );
        
      case ErrorType.server:
        return _ErrorConfiguration(
          icon: Icons.dns_outlined,
          title: 'Server Error',
          subtitle: 'Our servers are having issues',
          backgroundColor: isDarkMode 
              ? Colors.red.shade900.withOpacity(0.2) 
              : Colors.red.shade50,
          borderColor: isDarkMode 
              ? Colors.red.shade600 
              : Colors.red.shade200,
          iconColor: isDarkMode 
              ? Colors.red.shade300 
              : Colors.red.shade700,
          iconBackgroundColor: isDarkMode 
              ? Colors.red.shade800.withOpacity(0.3) 
              : Colors.red.shade100,
          titleColor: isDarkMode 
              ? Colors.red.shade200 
              : Colors.red.shade800,
          subtitleColor: isDarkMode 
              ? Colors.red.shade300 
              : Colors.red.shade600,
          messageColor: isDarkMode 
              ? Colors.red.shade100 
              : Colors.red.shade700,
          actionColor: isDarkMode 
              ? Colors.red.shade400 
              : Colors.red.shade600,
          shadowColor: Colors.red.withOpacity(0.1),
        );
        
      default:
        return _ErrorConfiguration(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          subtitle: null,
          backgroundColor: isDarkMode 
              ? Colors.grey.shade800.withOpacity(0.3) 
              : Colors.grey.shade100,
          borderColor: isDarkMode 
              ? Colors.grey.shade600 
              : Colors.grey.shade300,
          iconColor: isDarkMode 
              ? Colors.grey.shade300 
              : Colors.grey.shade700,
          iconBackgroundColor: isDarkMode 
              ? Colors.grey.shade700.withOpacity(0.3) 
              : Colors.grey.shade200,
          titleColor: isDarkMode 
              ? Colors.grey.shade200 
              : Colors.grey.shade800,
          subtitleColor: isDarkMode 
              ? Colors.grey.shade300 
              : Colors.grey.shade600,
          messageColor: isDarkMode 
              ? Colors.grey.shade100 
              : Colors.grey.shade700,
          actionColor: isDarkMode 
              ? Colors.grey.shade400 
              : Colors.grey.shade600,
          shadowColor: Colors.grey.withOpacity(0.1),
        );
    }
  }
  
  /// Build technical details section
  static Widget _buildTechnicalDetails(
    String details, 
    _ErrorConfiguration config, 
    bool isDarkMode
  ) {
    return Container(
      padding: EdgeInsets.all(FibonacciSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.grey.shade900.withOpacity(0.5) 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(FibonacciSpacing.sm),
        border: Border.all(
          color: isDarkMode 
              ? Colors.grey.shade700 
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report_outlined,
                size: 16,
                color: config.subtitleColor,
              ),
              SizedBox(width: FibonacciSpacing.xs),
              Text(
                'Technical Details',
                style: HomeTypographySystem.caption(color: config.subtitleColor).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: FibonacciSpacing.xs),
          Text(
            details,
            style: HomeTypographySystem.caption(color: config.subtitleColor).copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build action buttons
  static Widget _buildActionButtons({
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryText,
    String? dismissText,
    required _ErrorConfiguration errorConfig,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: Text(
              dismissText ?? 'Dismiss',
              style: TextStyle(color: errorConfig.subtitleColor),
            ),
          ),
        if (onRetry != null && onDismiss != null)
          SizedBox(width: FibonacciSpacing.sm),
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: 18),
            label: Text(retryText ?? 'Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorConfig.actionColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: FibonacciSpacing.md,
                vertical: FibonacciSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FibonacciSpacing.sm),
              ),
            ),
          ),
      ],
    );
  }
}

/// Error configuration data class
class _ErrorConfiguration {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color messageColor;
  final Color actionColor;
  final Color shadowColor;
  
  const _ErrorConfiguration({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.messageColor,
    required this.actionColor,
    required this.shadowColor,
  });
}

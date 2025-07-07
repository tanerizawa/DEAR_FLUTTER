// lib/core/theme/theme_validator.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Validates theme colors for accessibility compliance
class ThemeValidator {
  /// Minimum contrast ratios according to WCAG guidelines
  static const double _wcagAANormal = 4.5;
  static const double _wcagAAANormal = 7.0;
  static const double _wcagAALarge = 3.0;
  static const double _wcagAAALarge = 4.5;

  /// Calculate luminance of a color (0.0 to 1.0)
  static double _getLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final rs = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gs = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bs = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }

  /// Calculate contrast ratio between two colors
  static double getContrastRatio(Color foreground, Color background) {
    final lumForeground = _getLuminance(foreground);
    final lumBackground = _getLuminance(background);
    
    final lighter = max(lumForeground, lumBackground);
    final darker = min(lumForeground, lumBackground);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color combination meets WCAG AA standards
  static bool meetsWCAGAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= (isLargeText ? _wcagAALarge : _wcagAANormal);
  }

  /// Check if color combination meets WCAG AAA standards
  static bool meetsWCAGAAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= (isLargeText ? _wcagAAALarge : _wcagAAANormal);
  }

  /// Get compliance level description
  static String getComplianceLevel(Color foreground, Color background, {bool isLargeText = false}) {
    if (meetsWCAGAAA(foreground, background, isLargeText: isLargeText)) {
      return 'WCAG AAA (Excellent)';
    } else if (meetsWCAGAA(foreground, background, isLargeText: isLargeText)) {
      return 'WCAG AA (Good)';
    } else {
      return 'FAIL (Poor Contrast)';
    }
  }

  /// Validate all theme colors and log issues
  static Map<String, dynamic> validateTheme(ThemeData theme) {
    final issues = <String>[];
    final results = <String, double>{};

    // Define color combinations to test
    final testCombinations = [
      {
        'name': 'Primary on Surface',
        'foreground': theme.colorScheme.primary,
        'background': theme.colorScheme.surface,
      },
      {
        'name': 'OnSurface on Surface',
        'foreground': theme.colorScheme.onSurface,
        'background': theme.colorScheme.surface,
      },
      {
        'name': 'OnPrimary on Primary',
        'foreground': theme.colorScheme.onPrimary,
        'background': theme.colorScheme.primary,
      },
      {
        'name': 'Secondary on Surface',
        'foreground': theme.colorScheme.secondary,
        'background': theme.colorScheme.surface,
      },
    ];

    for (final combination in testCombinations) {
      final name = combination['name'] as String;
      final foreground = combination['foreground'] as Color;
      final background = combination['background'] as Color;
      
      final ratio = getContrastRatio(foreground, background);
      results[name] = ratio;
      
      if (!meetsWCAGAA(foreground, background)) {
        issues.add('$name: ${ratio.toStringAsFixed(2)}:1 (Below WCAG AA)');
      }
    }

    if (kDebugMode && issues.isNotEmpty) {
      debugPrint('🚨 THEME ACCESSIBILITY ISSUES:');
      for (final issue in issues) {
        debugPrint('  • $issue');
      }
    }

    return {
      'issues': issues,
      'results': results,
      'isCompliant': issues.isEmpty,
    };
  }

  /// Fix a color to meet minimum contrast requirements
  static Color fixContrast(Color foreground, Color background, {double targetRatio = 4.5}) {
    final currentRatio = getContrastRatio(foreground, background);
    
    if (currentRatio >= targetRatio) {
      return foreground; // Already meets requirements
    }

    final backgroundLum = _getLuminance(background);
    
    // Determine if we should make foreground lighter or darker
    if (backgroundLum > 0.5) {
      // Light background - make foreground darker
      return _adjustToTargetContrast(foreground, background, targetRatio, true);
    } else {
      // Dark background - make foreground lighter
      return _adjustToTargetContrast(foreground, background, targetRatio, false);
    }
  }

  static Color _adjustToTargetContrast(Color foreground, Color background, double targetRatio, bool makeDarker) {
    // This is a simplified approach - in practice, you might want more sophisticated color adjustment
    final backgroundLum = _getLuminance(background);
    
    if (makeDarker) {
      // Calculate required luminance for target ratio
      final targetLum = (backgroundLum + 0.05) / targetRatio - 0.05;
      return Color.fromARGB(
        foreground.alpha,
        (targetLum * 255).round().clamp(0, 255),
        (targetLum * 255).round().clamp(0, 255),
        (targetLum * 255).round().clamp(0, 255),
      );
    } else {
      // Make lighter
      final targetLum = (backgroundLum + 0.05) * targetRatio - 0.05;
      return Color.fromARGB(
        foreground.alpha,
        (targetLum * 255).round().clamp(0, 255),
        (targetLum * 255).round().clamp(0, 255),
        (targetLum * 255).round().clamp(0, 255),
      );
    }
  }
}

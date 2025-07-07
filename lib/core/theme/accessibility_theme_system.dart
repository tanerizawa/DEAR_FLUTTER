// ♿ Accessibility Theme System
// Advanced inclusive design features untuk semua pengguna
// DEAR Flutter - Modern Theme UI/UX Phase 3

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Comprehensive accessibility theme system yang mendukung berbagai kebutuhan
/// dan preferensi accessibility pengguna
class AccessibilityThemeSystem {
  // WCAG compliance levels
  static const double _contrastAA = 4.5;
  static const double _contrastAAA = 7.0;
  static const double _contrastLargeAA = 3.0;
  static const double _contrastLargeAAA = 4.5;
  
  // Touch target sizes (Material Design guidelines)
  static const double _minTouchTarget = 48.0;
  static const double _recommendedTouchTarget = 56.0;
  static const double _largeTouchTarget = 64.0;
  
  // Color blind friendly palettes
  static const Map<ColorBlindType, List<Color>> _colorBlindPalettes = {
    ColorBlindType.protanopia: [
      Color(0xFF0173B2), // Blue
      Color(0xFF029E73), // Green
      Color(0xFFCC78BC), // Pink
      Color(0xFFCA9161), // Orange
      Color(0xFF949494), // Gray
    ],
    ColorBlindType.deuteranopia: [
      Color(0xFF0173B2), // Blue
      Color(0xFFECE133), // Yellow
      Color(0xFF56B4E9), // Light Blue
      Color(0xFFCC79A7), // Pink
      Color(0xFF949494), // Gray
    ],
    ColorBlindType.tritanopia: [
      Color(0xFFE69F00), // Orange
      Color(0xFF009E73), // Green
      Color(0xFFF0E442), // Yellow
      Color(0xFFCC79A7), // Pink
      Color(0xFF999999), // Gray
    ],
  };
  
  /// Get accessibility-enhanced theme data
  static ThemeData generateAccessibleTheme({
    required ColorScheme baseColorScheme,
    required AccessibilityConfig config,
  }) {
    // Enhanced color scheme dengan accessibility improvements
    final accessibleColorScheme = _enhanceColorSchemeAccessibility(
      baseColorScheme,
      config,
    );
    
    // Responsive typography dengan accessibility considerations
    final accessibleTypography = _generateAccessibleTypography(config);
    
    // Enhanced component themes
    final componentThemes = _generateAccessibleComponentThemes(
      accessibleColorScheme,
      config,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: accessibleColorScheme,
      textTheme: accessibleTypography,
      
      // Button themes dengan larger touch targets
      elevatedButtonTheme: componentThemes.elevatedButtonTheme,
      textButtonTheme: componentThemes.textButtonTheme,
      outlinedButtonTheme: componentThemes.outlinedButtonTheme,
      
      // Input themes dengan accessibility enhancements
      inputDecorationTheme: componentThemes.inputDecorationTheme,
      
      // Navigation themes
      bottomNavigationBarTheme: componentThemes.bottomNavigationBarTheme,
      navigationBarTheme: componentThemes.navigationBarTheme,
      
      // Card dan surface themes
      cardTheme: componentThemes.cardTheme,
      
      // Focus indicators
      focusColor: _getFocusColor(accessibleColorScheme, config),
      
      // Visual density adjustment
      visualDensity: _getAccessibleVisualDensity(config),
      
      // Platform brightness
      brightness: accessibleColorScheme.brightness,
    );
  }
  
  /// Validate color contrast compliance
  static ContrastValidation validateContrast({
    required Color foreground,
    required Color background,
    required ContrastLevel targetLevel,
    bool isLargeText = false,
  }) {
    final contrast = calculateContrastRatio(foreground, background);
    final required = _getRequiredContrast(targetLevel, isLargeText);
    
    return ContrastValidation(
      actualContrast: contrast,
      requiredContrast: required,
      isCompliant: contrast >= required,
      level: targetLevel,
      isLargeText: isLargeText,
    );
  }
  
  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Get color blind friendly alternative
  static Color getColorBlindFriendly({
    required Color originalColor,
    required ColorBlindType type,
    required ColorRole role,
  }) {
    final palette = _colorBlindPalettes[type] ?? _colorBlindPalettes[ColorBlindType.protanopia]!;
    
    switch (role) {
      case ColorRole.primary:
        return palette[0];
      case ColorRole.secondary:
        return palette[1];
      case ColorRole.accent:
        return palette[2];
      case ColorRole.warning:
        return palette[3];
      case ColorRole.neutral:
        return palette[4];
    }
  }
  
  /// Get high contrast alternative
  static ColorScheme getHighContrastScheme(ColorScheme base) {
    final isDark = base.brightness == Brightness.dark;
    
    if (isDark) {
      return base.copyWith(
        surface: const Color(0xFF000000), // Pure black
        onSurface: const Color(0xFFFFFFFF), // Pure white
        primary: _adjustForHighContrast(base.primary, isDark),
        onPrimary: _getContrastingColor(base.primary),
        secondary: _adjustForHighContrast(base.secondary, isDark),
        onSecondary: _getContrastingColor(base.secondary),
        error: const Color(0xFFFF6B6B), // High contrast red
        onError: const Color(0xFF000000),
      );
    } else {
      return base.copyWith(
        surface: const Color(0xFFFFFFFF), // Pure white
        onSurface: const Color(0xFF000000), // Pure black
        primary: _adjustForHighContrast(base.primary, isDark),
        onPrimary: _getContrastingColor(base.primary),
        secondary: _adjustForHighContrast(base.secondary, isDark),
        onSecondary: _getContrastingColor(base.secondary),
        error: const Color(0xFFD32F2F), // High contrast red
        onError: const Color(0xFFFFFFFF),
      );
    }
  }
  
  /// Generate focus indicators untuk keyboard navigation
  static FocusIndicatorStyle getFocusIndicatorStyle(AccessibilityConfig config) {
    return FocusIndicatorStyle(
      borderWidth: config.enhancedFocus ? 3.0 : 2.0,
      borderColor: config.highContrast 
          ? (config.isDarkMode ? Colors.cyan : Colors.blue)
          : Colors.blue.shade700,
      borderRadius: BorderRadius.circular(config.reducedMotion ? 4.0 : 8.0),
      animationDuration: config.reducedMotion 
          ? const Duration(milliseconds: 150)
          : const Duration(milliseconds: 300),
    );
  }
  
  /// Get accessible touch target size
  static double getAccessibleTouchTarget(MotorAccessibilityLevel level) {
    switch (level) {
      case MotorAccessibilityLevel.standard:
        return _minTouchTarget;
      case MotorAccessibilityLevel.enhanced:
        return _recommendedTouchTarget;
      case MotorAccessibilityLevel.maximum:
        return _largeTouchTarget;
    }
  }
  
  /// Generate semantic labels untuk screen readers
  static Map<String, String> generateSemanticLabels({
    required String language,
    required AccessibilityVerbosity verbosity,
  }) {
    // Basis semantic labels (English)
    final baseLabels = {
      'button_primary': 'Primary action button',
      'button_secondary': 'Secondary action button',
      'navigation_home': 'Navigate to home',
      'navigation_back': 'Go back',
      'menu_open': 'Open navigation menu',
      'menu_close': 'Close navigation menu',
      'theme_toggle': 'Toggle between light and dark theme',
      'brightness_increase': 'Increase screen brightness',
      'brightness_decrease': 'Decrease screen brightness',
    };
    
    // Adjust verbosity
    if (verbosity == AccessibilityVerbosity.concise) {
      return baseLabels.map((key, value) => MapEntry(key, _makeConcise(value)));
    } else if (verbosity == AccessibilityVerbosity.detailed) {
      return baseLabels.map((key, value) => MapEntry(key, _makeDetailed(value)));
    }
    
    return baseLabels;
  }
  
  // Private helper methods
  
  static ColorScheme _enhanceColorSchemeAccessibility(
    ColorScheme base,
    AccessibilityConfig config,
  ) {
    if (config.highContrast) {
      return getHighContrastScheme(base);
    }
    
    if (config.colorBlindSupport != null) {
      return _applyColorBlindSupport(base, config.colorBlindSupport!);
    }
    
    // Standard accessibility enhancements
    return base.copyWith(
      primary: _ensureMinimumContrast(base.primary, base.surface, config),
      secondary: _ensureMinimumContrast(base.secondary, base.surface, config),
      error: _ensureMinimumContrast(base.error, base.surface, config),
    );
  }
  
  static ColorScheme _applyColorBlindSupport(
    ColorScheme base,
    ColorBlindType type,
  ) {
    return base.copyWith(
      primary: getColorBlindFriendly(
        originalColor: base.primary,
        type: type,
        role: ColorRole.primary,
      ),
      secondary: getColorBlindFriendly(
        originalColor: base.secondary,
        type: type,
        role: ColorRole.secondary,
      ),
      tertiary: getColorBlindFriendly(
        originalColor: base.tertiary ?? base.secondary,
        type: type,
        role: ColorRole.accent,
      ),
    );
  }
  
  static Color _ensureMinimumContrast(
    Color color,
    Color background,
    AccessibilityConfig config,
  ) {
    final targetContrast = config.contrastLevel == ContrastLevel.AAA ? _contrastAAA : _contrastAA;
    final currentContrast = calculateContrastRatio(color, background);
    
    if (currentContrast >= targetContrast) {
      return color;
    }
    
    // Adjust color untuk meet contrast requirement
    return _adjustColorForContrast(color, background, targetContrast);
  }
  
  static Color _adjustColorForContrast(
    Color color,
    Color background,
    double targetContrast,
  ) {
    final hsl = HSLColor.fromColor(color);
    
    // Try adjusting lightness
    for (double lightness = 0.0; lightness <= 1.0; lightness += 0.05) {
      final adjustedColor = hsl.withLightness(lightness).toColor();
      if (calculateContrastRatio(adjustedColor, background) >= targetContrast) {
        return adjustedColor;
      }
    }
    
    // Fallback ke high contrast color
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
  
  static Color _adjustForHighContrast(Color color, bool isDark) {
    final hsl = HSLColor.fromColor(color);
    
    if (isDark) {
      // Lighter dan more saturated untuk dark backgrounds
      return hsl.withLightness(math.max(hsl.lightness, 0.7))
                .withSaturation(math.max(hsl.saturation, 0.8))
                .toColor();
    } else {
      // Darker dan more saturated untuk light backgrounds
      return hsl.withLightness(math.min(hsl.lightness, 0.3))
                .withSaturation(math.max(hsl.saturation, 0.8))
                .toColor();
    }
  }
  
  static Color _getContrastingColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
  
  static TextTheme _generateAccessibleTypography(AccessibilityConfig config) {
    final baseSize = 16.0 * config.textScale;
    final scaleFactor = config.largeText ? 1.3 : 1.0;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: baseSize * 3.5 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: baseSize * 2.8 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: baseSize * 2.25 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: baseSize * 2.0 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: baseSize * 1.75 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: baseSize * 1.5 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: baseSize * 1.375 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      titleMedium: TextStyle(
        fontSize: baseSize * 1.0 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      titleSmall: TextStyle(
        fontSize: baseSize * 0.875 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      bodyLarge: TextStyle(
        fontSize: baseSize * 1.0 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: config.increasedLineHeight ? 1.6 : 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: baseSize * 0.875 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: config.increasedLineHeight ? 1.6 : 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: baseSize * 0.75 * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: config.increasedLineHeight ? 1.6 : 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: baseSize * 0.875 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      labelMedium: TextStyle(
        fontSize: baseSize * 0.75 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
      labelSmall: TextStyle(
        fontSize: baseSize * 0.6875 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: config.increasedLineHeight ? 1.4 : 1.2,
      ),
    );
  }
  
  static AccessibleComponentThemes _generateAccessibleComponentThemes(
    ColorScheme colorScheme,
    AccessibilityConfig config,
  ) {
    final touchTargetSize = getAccessibleTouchTarget(config.motorAccessibilityLevel);
    
    return AccessibleComponentThemes(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(touchTargetSize * 2, touchTargetSize),
          padding: EdgeInsets.symmetric(
            horizontal: config.increasedPadding ? 24.0 : 16.0,
            vertical: config.increasedPadding ? 16.0 : 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.reducedMotion ? 4.0 : 8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(touchTargetSize * 2, touchTargetSize),
          padding: EdgeInsets.symmetric(
            horizontal: config.increasedPadding ? 20.0 : 12.0,
            vertical: config.increasedPadding ? 12.0 : 8.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(touchTargetSize * 2, touchTargetSize),
          padding: EdgeInsets.symmetric(
            horizontal: config.increasedPadding ? 24.0 : 16.0,
            vertical: config.increasedPadding ? 16.0 : 12.0,
          ),
          side: BorderSide(
            width: config.highContrast ? 2.0 : 1.0,
            color: colorScheme.outline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(
          horizontal: config.increasedPadding ? 20.0 : 16.0,
          vertical: config.increasedPadding ? 20.0 : 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.reducedMotion ? 4.0 : 8.0),
          borderSide: BorderSide(
            width: config.highContrast ? 2.0 : 1.0,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: TextStyle(
          fontSize: 14 * config.textScale,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12 * config.textScale,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: touchTargetSize + 16,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12 * config.textScale,
            fontWeight: states.contains(WidgetState.selected) 
                ? FontWeight.w500 
                : FontWeight.w400,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: config.reducedMotion ? 2.0 : 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.reducedMotion ? 4.0 : 12.0),
        ),
        margin: EdgeInsets.all(config.increasedPadding ? 12.0 : 8.0),
      ),
    );
  }
  
  static Color _getFocusColor(ColorScheme colorScheme, AccessibilityConfig config) {
    if (config.highContrast) {
      return colorScheme.brightness == Brightness.dark
          ? Colors.cyan.shade300
          : Colors.blue.shade700;
    }
    
    return colorScheme.primary.withOpacity(0.3);
  }
  
  static VisualDensity _getAccessibleVisualDensity(AccessibilityConfig config) {
    if (config.motorAccessibilityLevel == MotorAccessibilityLevel.maximum) {
      return VisualDensity.comfortable;
    } else if (config.motorAccessibilityLevel == MotorAccessibilityLevel.enhanced) {
      return VisualDensity.standard;
    }
    
    return VisualDensity.compact;
  }
  
  static double _getRequiredContrast(ContrastLevel level, bool isLargeText) {
    switch (level) {
      case ContrastLevel.AA:
        return isLargeText ? _contrastLargeAA : _contrastAA;
      case ContrastLevel.AAA:
        return isLargeText ? _contrastLargeAAA : _contrastAAA;
    }
  }
  
  static String _makeConcise(String label) {
    return label.replaceAll(RegExp(r'\b(action|Navigate to|Go|Toggle between|and)\b'), '').trim();
  }
  
  static String _makeDetailed(String label) {
    return '$label. Double tap to activate.';
  }
}

// Enums and data classes

enum ColorBlindType {
  protanopia,    // Red-blind
  deuteranopia,  // Green-blind  
  tritanopia,    // Blue-blind
}

enum ColorRole {
  primary,
  secondary,
  accent,
  warning,
  neutral,
}

enum ContrastLevel {
  AA,   // 4.5:1 normal, 3:1 large
  AAA,  // 7:1 normal, 4.5:1 large
}

enum MotorAccessibilityLevel {
  standard,  // 48dp minimum
  enhanced,  // 56dp recommended
  maximum,   // 64dp large
}

enum AccessibilityVerbosity {
  concise,
  standard,
  detailed,
}

class AccessibilityConfig {
  final bool highContrast;
  final bool largeText;
  final double textScale;
  final bool increasedLineHeight;
  final bool increasedPadding;
  final bool reducedMotion;
  final bool enhancedFocus;
  final ContrastLevel contrastLevel;
  final MotorAccessibilityLevel motorAccessibilityLevel;
  final ColorBlindType? colorBlindSupport;
  final AccessibilityVerbosity verbosity;
  final bool isDarkMode;
  
  const AccessibilityConfig({
    this.highContrast = false,
    this.largeText = false,
    this.textScale = 1.0,
    this.increasedLineHeight = false,
    this.increasedPadding = false,
    this.reducedMotion = false,
    this.enhancedFocus = false,
    this.contrastLevel = ContrastLevel.AA,
    this.motorAccessibilityLevel = MotorAccessibilityLevel.standard,
    this.colorBlindSupport,
    this.verbosity = AccessibilityVerbosity.standard,
    this.isDarkMode = false,
  });
  
  AccessibilityConfig copyWith({
    bool? highContrast,
    bool? largeText,
    double? textScale,
    bool? increasedLineHeight,
    bool? increasedPadding,
    bool? reducedMotion,
    bool? enhancedFocus,
    ContrastLevel? contrastLevel,
    MotorAccessibilityLevel? motorAccessibilityLevel,
    ColorBlindType? colorBlindSupport,
    AccessibilityVerbosity? verbosity,
    bool? isDarkMode,
  }) {
    return AccessibilityConfig(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      textScale: textScale ?? this.textScale,
      increasedLineHeight: increasedLineHeight ?? this.increasedLineHeight,
      increasedPadding: increasedPadding ?? this.increasedPadding,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      enhancedFocus: enhancedFocus ?? this.enhancedFocus,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      motorAccessibilityLevel: motorAccessibilityLevel ?? this.motorAccessibilityLevel,
      colorBlindSupport: colorBlindSupport ?? this.colorBlindSupport,
      verbosity: verbosity ?? this.verbosity,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ContrastValidation {
  final double actualContrast;
  final double requiredContrast;
  final bool isCompliant;
  final ContrastLevel level;
  final bool isLargeText;
  
  const ContrastValidation({
    required this.actualContrast,
    required this.requiredContrast,
    required this.isCompliant,
    required this.level,
    required this.isLargeText,
  });
  
  String get complianceDescription {
    if (isCompliant) {
      return 'Compliant with WCAG ${level.name} (${actualContrast.toStringAsFixed(1)}:1)';
    } else {
      return 'Non-compliant: ${actualContrast.toStringAsFixed(1)}:1, requires ${requiredContrast.toStringAsFixed(1)}:1';
    }
  }
}

class FocusIndicatorStyle {
  final double borderWidth;
  final Color borderColor;
  final BorderRadius borderRadius;
  final Duration animationDuration;
  
  const FocusIndicatorStyle({
    required this.borderWidth,
    required this.borderColor,
    required this.borderRadius,
    required this.animationDuration,
  });
}

class AccessibleComponentThemes {
  final ElevatedButtonThemeData elevatedButtonTheme;
  final TextButtonThemeData textButtonTheme;
  final OutlinedButtonThemeData outlinedButtonTheme;
  final InputDecorationTheme inputDecorationTheme;
  final BottomNavigationBarThemeData bottomNavigationBarTheme;
  final NavigationBarThemeData navigationBarTheme;
  final CardThemeData cardTheme;
  
  const AccessibleComponentThemes({
    required this.elevatedButtonTheme,
    required this.textButtonTheme,
    required this.outlinedButtonTheme,
    required this.inputDecorationTheme,
    required this.bottomNavigationBarTheme,
    required this.navigationBarTheme,
    required this.cardTheme,
  });
}

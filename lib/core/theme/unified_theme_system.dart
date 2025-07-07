// lib/core/theme/unified_theme_system.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'mood_color_system.dart';
import 'golden_design_system.dart';
// Phase 2 imports - Advanced systems
import 'adaptive_brightness_system.dart';
// Phase 3 imports - Intelligence & Personalization
import 'personalized_theme_engine.dart';
import 'accessibility_theme_system.dart';
import 'performance_optimization_system.dart';

/// Unified Theme System - Central orchestrator untuk semua aspek theming
/// Mengintegrasikan Material Design 3, mood-adaptive colors, golden ratio,
/// psychological comfort engineering, Phase 2 advanced features, dan
/// Phase 3 personalization & intelligence systems
class UnifiedThemeSystem {
  // Theme Configuration
  static const String _defaultMood = 'calm';
  static bool _isDarkMode = false;
  static String _currentMood = _defaultMood;
  static double _contrastLevel = 1.0; // 0.5 = low, 1.0 = normal, 1.5 = high
  
  // Phase 2 - Advanced systems
  static AdaptiveBrightnessSystem? _brightnessSystem;
  
  // Phase 3 - Intelligence & Personalization
  static PersonalizedThemeEngine? _personalizationEngine;
  static AccessibilityConfig _accessibilityConfig = const AccessibilityConfig();
  static bool _performanceOptimizationEnabled = true;
  
  // Initialize advanced systems
  static Future<void> initializeAdvancedSystems() async {
    // Phase 2 systems
    _brightnessSystem = AdaptiveBrightnessSystem();
    await _brightnessSystem!.initialize();
    
    // Phase 3 systems
    if (_performanceOptimizationEnabled) {
      await PerformanceOptimizationSystem.initialize();
    }
    
    _personalizationEngine = PersonalizedThemeEngine();
    await _personalizationEngine!.initialize();
  }
  
  // Dispose advanced systems
  static void disposeAdvancedSystems() {
    _brightnessSystem?.dispose();
    _brightnessSystem = null;
    
    _personalizationEngine?.dispose();
    _personalizationEngine = null;
    
    if (_performanceOptimizationEnabled) {
      PerformanceOptimizationSystem.dispose();
    }
  }
  
  // Get brightness system for external use
  static AdaptiveBrightnessSystem? get brightnessSystem => _brightnessSystem;
  
  // Phase 3 - Getters for external access
  static PersonalizedThemeEngine? get personalizationEngine => _personalizationEngine;
  static AccessibilityConfig get accessibilityConfig => _accessibilityConfig;
  
  /// Update accessibility configuration
  static void updateAccessibilityConfig(AccessibilityConfig config) {
    _accessibilityConfig = config;
  }
  
  /// Enable/disable performance optimization
  static void setPerformanceOptimization(bool enabled) {
    _performanceOptimizationEnabled = enabled;
  }
  
  // Getters untuk current theme state
  static bool get isDarkMode => _isDarkMode;
  static String get currentMood => _currentMood;
  static double get contrastLevel => _contrastLevel;
  
  /// Generate complete ThemeData dengan mood-adaptive dan accessibility support
  static ThemeData generateTheme({
    String mood = _defaultMood,
    bool isDark = false,
    double contrast = 1.0,
    double textScaleFactor = 1.0,
  }) {
    _currentMood = mood;
    _isDarkMode = isDark;
    _contrastLevel = contrast;
    
    final moodTheme = MoodColorSystem.getMoodTheme(mood);
    final primaryColor = moodTheme['primary'] as Color;
    final secondaryColor = moodTheme['secondary'] as Color;
    
    // Generate Material Design 3 ColorScheme dari mood colors
    final colorScheme = _generateMaterial3ColorScheme(
      primary: primaryColor,
      secondary: secondaryColor,
      isDark: isDark,
      contrast: contrast,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography dengan golden ratio scaling
      textTheme: _generateTextTheme(colorScheme, textScaleFactor),
      
      // Elevated surfaces dengan golden ratio elevation
      elevatedButtonTheme: _generateElevatedButtonTheme(colorScheme),
      cardTheme: _generateCardTheme(colorScheme),
      appBarTheme: _generateAppBarTheme(colorScheme),
      bottomNavigationBarTheme: _generateBottomNavTheme(colorScheme),
      
      // Input styling
      inputDecorationTheme: _generateInputTheme(colorScheme),
      
      // Animation dan transitions
      pageTransitionsTheme: _generatePageTransitionsTheme(),
      
      // Spacing dan layout
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      
      // Platform adaptations
      platform: defaultTargetPlatform,
    );
  }
  
  /// Generate ColorScheme yang comply dengan Material Design 3
  static ColorScheme _generateMaterial3ColorScheme({
    required Color primary,
    required Color secondary,
    required bool isDark,
    required double contrast,
  }) {
    if (isDark) {
      return ColorScheme.dark(
        // Primary roles
        primary: _adjustContrast(primary, contrast),
        onPrimary: _getOptimalTextColor(primary, contrast),
        primaryContainer: _adjustContrast(primary.withOpacity(0.3), contrast),
        onPrimaryContainer: _getOptimalTextColor(primary.withOpacity(0.3), contrast),
        
        // Secondary roles  
        secondary: _adjustContrast(secondary, contrast),
        onSecondary: _getOptimalTextColor(secondary, contrast),
        secondaryContainer: _adjustContrast(secondary.withOpacity(0.3), contrast),
        onSecondaryContainer: _getOptimalTextColor(secondary.withOpacity(0.3), contrast),
        
        // Tertiary roles
        tertiary: _adjustContrast(_generateTertiaryColor(primary, secondary), contrast),
        onTertiary: Colors.white,
        tertiaryContainer: _adjustContrast(_generateTertiaryColor(primary, secondary).withOpacity(0.3), contrast),
        onTertiaryContainer: Colors.white70,
        
        // Surface roles (OLED optimized)
        surface: MoodColorSystem.surface,
        onSurface: _adjustContrast(MoodColorSystem.onSurface, contrast),
        surfaceVariant: MoodColorSystem.surfaceVariant,
        onSurfaceVariant: _adjustContrast(MoodColorSystem.onSurfaceVariant, contrast),
        
        // Error roles
        error: const Color(0xFFCF6679),
        onError: Colors.black,
        errorContainer: const Color(0xFFCF6679).withOpacity(0.3),
        onErrorContainer: Colors.white,
        
        // Background
        background: MoodColorSystem.surface,
        onBackground: _adjustContrast(MoodColorSystem.onSurface, contrast),
        
        // Outline
        outline: _adjustContrast(MoodColorSystem.outline, contrast),
        outlineVariant: _adjustContrast(MoodColorSystem.outline.withOpacity(0.5), contrast),
        
        // Brightness
        brightness: Brightness.dark,
      );
    } else {
      return ColorScheme.light(
        // Primary roles
        primary: _adjustContrast(primary, contrast),
        onPrimary: _getOptimalTextColor(primary, contrast),
        primaryContainer: _adjustContrast(primary.withOpacity(0.1), contrast),
        onPrimaryContainer: _adjustContrast(primary.withOpacity(0.8), contrast),
        
        // Secondary roles
        secondary: _adjustContrast(secondary, contrast),
        onSecondary: _getOptimalTextColor(secondary, contrast),
        secondaryContainer: _adjustContrast(secondary.withOpacity(0.1), contrast),
        onSecondaryContainer: _adjustContrast(secondary.withOpacity(0.8), contrast),
        
        // Tertiary roles
        tertiary: _adjustContrast(_generateTertiaryColor(primary, secondary), contrast),
        onTertiary: Colors.white,
        tertiaryContainer: _adjustContrast(_generateTertiaryColor(primary, secondary).withOpacity(0.1), contrast),
        onTertiaryContainer: _adjustContrast(_generateTertiaryColor(primary, secondary).withOpacity(0.8), contrast),
        
        // Surface roles
        surface: Colors.white,
        onSurface: _adjustContrast(Colors.black87, contrast),
        surfaceVariant: const Color(0xFFF5F5F5),
        onSurfaceVariant: _adjustContrast(Colors.black54, contrast),
        
        // Error roles
        error: const Color(0xFFB00020),
        onError: Colors.white,
        errorContainer: const Color(0xFFB00020).withOpacity(0.1),
        onErrorContainer: const Color(0xFFB00020),
        
        // Background
        background: Colors.white,
        onBackground: _adjustContrast(Colors.black87, contrast),
        
        // Outline
        outline: _adjustContrast(Colors.black26, contrast),
        outlineVariant: _adjustContrast(Colors.black12, contrast),
        
        // Brightness
        brightness: Brightness.light,
      );
    }
  }
  
  /// Generate typography theme dengan golden ratio scaling
  static TextTheme _generateTextTheme(ColorScheme colorScheme, double scaleFactor) {
    return TextTheme(
      // Display text (largest)
      displayLarge: TextStyle(
        fontSize: MoodColorSystem.text_3xl * scaleFactor,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      displayMedium: TextStyle(
        fontSize: MoodColorSystem.text_2xl * scaleFactor,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      displaySmall: TextStyle(
        fontSize: MoodColorSystem.text_xl * scaleFactor,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      
      // Headline text
      headlineLarge: TextStyle(
        fontSize: MoodColorSystem.text_xl * scaleFactor,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: MoodColorSystem.text_lg * scaleFactor,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: MoodColorSystem.text_base * scaleFactor,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      
      // Title text
      titleLarge: TextStyle(
        fontSize: MoodColorSystem.text_lg * scaleFactor,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      titleMedium: TextStyle(
        fontSize: MoodColorSystem.text_base * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      titleSmall: TextStyle(
        fontSize: MoodColorSystem.text_sm * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      
      // Label text (buttons, etc.)
      labelLarge: TextStyle(
        fontSize: MoodColorSystem.text_sm * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      labelMedium: TextStyle(
        fontSize: MoodColorSystem.text_xs * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      labelSmall: TextStyle(
        fontSize: MoodColorSystem.text_xs * 0.9 * scaleFactor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
        height: GoldenDesignSystem.phi * 0.8,
      ),
      
      // Body text
      bodyLarge: TextStyle(
        fontSize: MoodColorSystem.text_base * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.9,
      ),
      bodyMedium: TextStyle(
        fontSize: MoodColorSystem.text_sm * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
        height: GoldenDesignSystem.phi * 0.9,
      ),
      bodySmall: TextStyle(
        fontSize: MoodColorSystem.text_xs * scaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurfaceVariant,
        height: GoldenDesignSystem.phi * 0.9,
      ),
    );
  }
  
  /// Generate button theme dengan golden ratio proportions
  static ElevatedButtonThemeData _generateElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        padding: EdgeInsets.symmetric(
          horizontal: MoodColorSystem.space_md,
          vertical: MoodColorSystem.space_sm,
        ),
        minimumSize: Size(
          GoldenDesignSystem.space_7, // 55dp minimum width
          GoldenDesignSystem.space_6, // 34dp minimum height
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_large),
        ),
        elevation: GoldenDesignSystem.space_1,
        textStyle: TextStyle(
          fontSize: MoodColorSystem.text_sm,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
  
  /// Generate card theme dengan golden ratio elevations
  static CardThemeData _generateCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.1),
      elevation: GoldenDesignSystem.space_1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_large),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.all(MoodColorSystem.space_xs),
    );
  }
  
  /// Generate AppBar theme
  static AppBarTheme _generateAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: MoodColorSystem.text_lg,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: GoldenDesignSystem.space_5,
      ),
      systemOverlayStyle: _isDarkMode 
        ? SystemUiOverlayStyle.light 
        : SystemUiOverlayStyle.dark,
    );
  }
  
  /// Generate BottomNavigationBar theme
  static BottomNavigationBarThemeData _generateBottomNavTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: MoodColorSystem.text_xs,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: MoodColorSystem.text_xs,
        fontWeight: FontWeight.w400,
      ),
    );
  }
  
  /// Generate input decoration theme
  static InputDecorationTheme _generateInputTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: MoodColorSystem.space_md,
        vertical: MoodColorSystem.space_sm,
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: MoodColorSystem.text_sm,
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        fontSize: MoodColorSystem.text_sm,
      ),
    );
  }
  
  /// Generate page transitions theme dengan smooth animations
  static PageTransitionsTheme _generatePageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }
  
  // Enhanced theme generation dengan accessibility integration
  static ThemeData _generateCompleteTheme({
    required String mood,
    required bool isDark,
    required double contrast,
    required double textScaleFactor,
  }) {
    _currentMood = mood;
    _isDarkMode = isDark;
    _contrastLevel = contrast;
    
    final moodTheme = MoodColorSystem.getMoodTheme(mood);
    final primaryColor = moodTheme['primary'] as Color;
    final secondaryColor = moodTheme['secondary'] as Color;
    
    // Generate Material Design 3 ColorScheme dari mood colors
    var colorScheme = _generateMaterial3ColorScheme(
      primary: primaryColor,
      secondary: secondaryColor,
      isDark: isDark,
      contrast: contrast,
    );
    
    // Apply accessibility enhancements
    if (_accessibilityConfig.highContrast || 
        _accessibilityConfig.colorBlindSupport != null ||
        _accessibilityConfig.contrastLevel == ContrastLevel.AAA) {
      
      final accessibleTheme = AccessibilityThemeSystem.generateAccessibleTheme(
        baseColorScheme: colorScheme,
        config: _accessibilityConfig,
      );
      
      return accessibleTheme;
    }
    
    // Continue dengan standard theme generation jika no accessibility needs
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography dengan golden ratio scaling
      textTheme: _generateTextTheme(colorScheme, textScaleFactor),
      
      // Elevated surfaces dengan golden ratio elevation
      elevatedButtonTheme: _generateElevatedButtonTheme(colorScheme),
      // textButtonTheme: _generateTextButtonTheme(colorScheme), // TODO: Fix method resolution
      // outlinedButtonTheme: _generateOutlinedButtonTheme(colorScheme), // TODO: Fix method resolution
      inputDecorationTheme: _generateInputTheme(colorScheme),
      cardTheme: _generateCardTheme(colorScheme),
      appBarTheme: _generateAppBarTheme(colorScheme),
      bottomNavigationBarTheme: _generateBottomNavTheme(colorScheme),
      
      // Visual density berdasarkan accessibility needs
      visualDensity: _accessibilityConfig.motorAccessibilityLevel == MotorAccessibilityLevel.maximum
          ? VisualDensity.comfortable
          : VisualDensity.standard,
      
      // Focus color untuk keyboard navigation
      focusColor: AccessibilityThemeSystem.getFocusIndicatorStyle(_accessibilityConfig).borderColor.withOpacity(0.3),
      
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
  
  // Helper methods for theme ID generation
  static String _generateThemeId(String mood, bool isDark, double contrast, AccessibilityConfig config) {
    final brightness = isDark ? 'dark' : 'light';
    final accessibilityHash = config.hashCode.toString().substring(0, 4);
    return '${mood}_${brightness}_${contrast.toStringAsFixed(1)}_$accessibilityHash';
  }
  
  static String _generateCurrentThemeId() {
    return _generateThemeId(_currentMood, _isDarkMode, _contrastLevel, _accessibilityConfig);
  }
  
  // Helper Methods
  
  /// Adjust color contrast berdasarkan accessibility level
  static Color _adjustContrast(Color color, double contrast) {
    if (contrast == 1.0) return color;
    
    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = contrast > 1.0 
      ? (hsl.lightness * (2.0 - contrast)).clamp(0.0, 1.0)
      : (hsl.lightness / contrast).clamp(0.0, 1.0);
    
    return hsl.withLightness(adjustedLightness).toColor();
  }
  
  /// Get optimal text color for background dengan WCAG compliance
  static Color _getOptimalTextColor(Color background, double contrast) {
    final luminance = background.computeLuminance();
    final isLight = luminance > 0.5;
    
    Color textColor = isLight ? Colors.black87 : Colors.white;
    return _adjustContrast(textColor, contrast);
  }
  
  /// Generate tertiary color menggunakan color theory
  static Color _generateTertiaryColor(Color primary, Color secondary) {
    final primaryHsl = HSLColor.fromColor(primary);
    final secondaryHsl = HSLColor.fromColor(secondary);
    
    // Create analogous color (30 degrees from primary)
    final tertiaryHue = (primaryHsl.hue + 30.0) % 360.0;
    
    return HSLColor.fromAHSL(
      1.0,
      tertiaryHue,
      (primaryHsl.saturation + secondaryHsl.saturation) / 2,
      (primaryHsl.lightness + secondaryHsl.lightness) / 2,
    ).toColor();
  }
  
  /// Update theme dengan mood baru
  static void updateMood(String newMood) {
    _currentMood = newMood;
  }
  
  /// Toggle dark mode
  static void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
  }
  
  /// Update contrast level untuk accessibility
  static void updateContrastLevel(double newContrast) {
    _contrastLevel = newContrast.clamp(0.5, 2.0);
  }
  
  /// Get mood-based gradient untuk special effects
  static LinearGradient getMoodGradient({
    String? mood,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double opacity = 1.0,
  }) {
    return MoodColorSystem.createMoodGradient(
      mood ?? _currentMood,
      begin: begin,
      end: end,
      opacity: opacity,
    );
  }
  
  /// Get mood-based container decoration
  static BoxDecoration getMoodContainer({
    String? mood,
    double borderRadius = 16.0,
    double opacity = 0.1,
    bool hasBorder = true,
  }) {
    return MoodColorSystem.createMoodContainer(
      mood ?? _currentMood,
      borderRadius: borderRadius,
      opacity: opacity,
      hasBorder: hasBorder,
    );
  }
  
  /// Generate intelligent personalized theme dengan optimization
  static Future<ThemeData> generateIntelligentTheme({
    String? mood,
    bool? isDark,
    double? contrast,
    double? textScaleFactor,
    Map<String, dynamic>? context,
  }) async {
    // Get personalized recommendation
    ThemeRecommendation? recommendation;
    if (_personalizationEngine != null) {
      recommendation = await _personalizationEngine!.getPersonalizedRecommendation(
        context: context,
      );
    }
    
    // Use recommendation or fallback to provided params
    final finalMood = mood ?? recommendation?.mood ?? _defaultMood;
    final finalIsDark = isDark ?? (recommendation?.brightness == Brightness.dark ? true : false);
    final finalContrast = contrast ?? _contrastLevel;
    
    // Generate theme ID untuk caching
    final themeId = _generateThemeId(finalMood, finalIsDark, finalContrast, _accessibilityConfig);
    
    // Get optimized theme dengan caching
    if (_performanceOptimizationEnabled) {
      return await PerformanceOptimizationSystem.getOptimizedTheme(
        themeId: themeId,
        themeGenerator: () => _generateCompleteTheme(
          mood: finalMood,
          isDark: finalIsDark,
          contrast: finalContrast,
          textScaleFactor: textScaleFactor ?? 1.0,
        ),
      );
    } else {
      return _generateCompleteTheme(
        mood: finalMood,
        isDark: finalIsDark,
        contrast: finalContrast,
        textScaleFactor: textScaleFactor ?? 1.0,
      );
    }
  }
  
  /// Record user interaction untuk learning
  static void recordThemeInteraction({
    required InteractionType type,
    String? themeId,
    Map<String, dynamic>? context,
  }) {
    _personalizationEngine?.recordThemeInteraction(
      themeId: themeId ?? _generateCurrentThemeId(),
      type: type,
      timestamp: DateTime.now(),
      context: context,
    );
  }
  
  /// Provide feedback on theme recommendations
  static void provideFeedback({
    required String recommendationId,
    required FeedbackType feedback,
    String? reason,
  }) {
    _personalizationEngine?.provideFeedback(
      recommendationId: recommendationId,
      feedback: feedback,
      reason: reason,
    );
  }
}

/// Theme Provider untuk state management
class ThemeProvider extends ChangeNotifier {
  String _currentMood = 'calm';
  bool _isDarkMode = false;
  double _contrastLevel = 1.0;
  double _textScaleFactor = 1.0;
  
  // Getters
  String get currentMood => _currentMood;
  bool get isDarkMode => _isDarkMode;
  double get contrastLevel => _contrastLevel;
  double get textScaleFactor => _textScaleFactor;
  
  ThemeData get currentTheme => UnifiedThemeSystem.generateTheme(
    mood: _currentMood,
    isDark: _isDarkMode,
    contrast: _contrastLevel,
    textScaleFactor: _textScaleFactor,
  );
  
  // Theme update methods
  void updateMood(String newMood) {
    if (_currentMood != newMood) {
      _currentMood = newMood;
      UnifiedThemeSystem.updateMood(newMood);
      notifyListeners();
    }
  }
  
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    UnifiedThemeSystem.toggleDarkMode();
    notifyListeners();
  }
  
  void updateContrast(double newContrast) {
    if (_contrastLevel != newContrast) {
      _contrastLevel = newContrast;
      UnifiedThemeSystem.updateContrastLevel(newContrast);
      notifyListeners();
    }
  }
  
  void updateTextScale(double newScale) {
    if (_textScaleFactor != newScale) {
      _textScaleFactor = newScale.clamp(0.8, 1.6);
      notifyListeners();
    }
  }
  
  // Batch update untuk performance
  void updateThemeSettings({
    String? mood,
    bool? isDark,
    double? contrast,
    double? textScale,
  }) {
    bool hasChanges = false;
    
    if (mood != null && _currentMood != mood) {
      _currentMood = mood;
      hasChanges = true;
    }
    
    if (isDark != null && _isDarkMode != isDark) {
      _isDarkMode = isDark;
      hasChanges = true;
    }
    
    if (contrast != null && _contrastLevel != contrast) {
      _contrastLevel = contrast;
      hasChanges = true;
    }
    
    if (textScale != null && _textScaleFactor != textScale) {
      _textScaleFactor = textScale.clamp(0.8, 1.6);
      hasChanges = true;
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }
  
  // Additional Theme Generation Methods
  
  /// Generate TextButtonTheme  
  static TextButtonThemeData _generateTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: TextStyle(
          fontSize: MoodColorSystem.text_sm,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        ),
      ),
    );
  }
  
  /// Generate OutlinedButtonTheme
  static OutlinedButtonThemeData _generateOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        textStyle: TextStyle(
          fontSize: MoodColorSystem.text_sm,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        ),
      ),
    );
  }
}

// lib/core/theme/mood_color_system_v2.dart
// Enhanced Color Psychology System - Phase 2 Implementation

import 'package:flutter/material.dart';

/// Enhanced mood-based color system with accessibility focus and psychology
/// Implements Phase 2 Visual Design Enhancement
class MoodColorSystemV2 {
  
  // MARK: - Core Psychological Color Palettes
  
  /// Joyful/Happy mood colors - energizing and optimistic
  static const List<Color> joyfulPalette = [
    Color(0xFFFFD700), // Gold - wealth, success, luxury
    Color(0xFFFFA500), // Orange - enthusiasm, creativity
    Color(0xFFFFB347), // Peach - warmth, comfort
    Color(0xFFFFC857), // Warm Yellow - happiness, positivity
  ];
  
  /// Calm/Peaceful mood colors - soothing and balanced
  static const List<Color> calmPalette = [
    Color(0xFF4FC3F7), // Light Blue - tranquility, trust
    Color(0xFF29B6F6), // Sky Blue - peace, stability
    Color(0xFF81C784), // Soft Green - harmony, growth
    Color(0xFFAED581), // Light Green - balance, renewal
  ];
  
  /// Motivated/Energetic mood colors - drive and determination
  static const List<Color> motivatedPalette = [
    Color(0xFF66BB6A), // Green - growth, prosperity
    Color(0xFF43A047), // Forest Green - stability, endurance
    Color(0xFF26A69A), // Teal - sophistication, clarity
    Color(0xFF42A5F5), // Blue - trust, reliability
  ];
  
  /// Reflective/Contemplative mood colors - depth and wisdom
  static const List<Color> reflectivePalette = [
    Color(0xFF7E57C2), // Purple - creativity, wisdom
    Color(0xFF5C6BC0), // Indigo - intuition, perception
    Color(0xFF78909C), // Blue Grey - balance, neutrality
    Color(0xFF9575CD), // Light Purple - inspiration, mystery
  ];
  
  /// Evening/Relaxed mood colors - rest and recovery
  static const List<Color> eveningPalette = [
    Color(0xFF8D6E63), // Brown - earthiness, stability
    Color(0xFFA1887F), // Light Brown - comfort, reliability
    Color(0xFF90A4AE), // Blue Grey - calmness, sophistication
    Color(0xFFBCAAA4), // Warm Grey - neutrality, balance
  ];
  
  // MARK: - Dynamic Gradient System
  
  /// Adaptive gradients based on current mood and time of day
  static LinearGradient getAdaptiveGradient({
    String mood = 'default',
    bool isDarkMode = false,
    double timeOfDay = 12.0, // 24-hour format
  }) {
    final colors = _getMoodColors(mood, timeOfDay);
    
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }
  
  /// Get mood-specific colors with time-based adjustments
  static List<Color> _getMoodColors(String mood, double timeOfDay) {
    List<Color> basePalette;
    
    switch (mood.toLowerCase()) {
      case 'joyful':
      case 'happy':
      case 'excited':
        basePalette = joyfulPalette;
        break;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        basePalette = calmPalette;
        break;
      case 'motivated':
      case 'energetic':
      case 'determined':
        basePalette = motivatedPalette;
        break;
      case 'reflective':
      case 'contemplative':
      case 'thoughtful':
        basePalette = reflectivePalette;
        break;
      case 'evening':
      case 'tired':
      case 'winding_down':
        basePalette = eveningPalette;
        break;
      default:
        basePalette = _getTimeBasedPalette(timeOfDay);
    }
    
    return _adjustForTimeOfDay(basePalette, timeOfDay);
  }
  
  /// Automatic palette selection based on time of day
  static List<Color> _getTimeBasedPalette(double timeOfDay) {
    if (timeOfDay >= 6 && timeOfDay < 12) {
      // Morning - energetic
      return motivatedPalette;
    } else if (timeOfDay >= 12 && timeOfDay < 17) {
      // Afternoon - balanced
      return calmPalette;
    } else if (timeOfDay >= 17 && timeOfDay < 21) {
      // Evening - reflective
      return reflectivePalette;
    } else {
      // Night - relaxed
      return eveningPalette;
    }
  }
  
  /// Adjust color intensity based on time of day
  static List<Color> _adjustForTimeOfDay(List<Color> basePalette, double timeOfDay) {
    if (timeOfDay >= 22 || timeOfDay < 6) {
      // Night time - reduce saturation
      return basePalette.map((color) => Color.lerp(
        color,
        Colors.grey.shade800,
        0.3,
      )!).toList();
    } else if (timeOfDay >= 6 && timeOfDay < 8) {
      // Early morning - softer tones
      return basePalette.map((color) => Color.lerp(
        color,
        Colors.white,
        0.1,
      )!).toList();
    }
    
    return basePalette;
  }
  
  // MARK: - Enhanced Shadow System
  
  /// Multi-layered shadow system for proper depth perception
  static List<BoxShadow> getDepthShadows({
    required int depth, // 1-5 scale
    Color? color,
    bool isDarkMode = false,
  }) {
    final shadowColor = color ?? (isDarkMode ? Colors.black : Colors.grey.shade900);
    
    switch (depth) {
      case 1: // Subtle elevation
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ];
        
      case 2: // Card elevation
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ];
        
      case 3: // Modal elevation
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ];
        
      case 4: // Menu elevation
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ];
        
      case 5: // Maximum elevation
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ];
        
      default:
        return getDepthShadows(depth: 2, color: color, isDarkMode: isDarkMode);
    }
  }
  
  // MARK: - Accessibility Enhancements
  
  /// Get high contrast color for accessibility
  static Color getAccessibleColor({
    required Color background,
    required Color foreground,
    double targetContrast = 4.5, // WCAG AA standard
  }) {
    final contrast = _calculateContrast(background, foreground);
    
    if (contrast >= targetContrast) {
      return foreground;
    }
    
    // Adjust foreground color to meet contrast requirements
    return _adjustForContrast(background, foreground, targetContrast);
  }
  
  /// Calculate contrast ratio between two colors
  static double _calculateContrast(Color color1, Color color2) {
    final lum1 = _calculateLuminance(color1);
    final lum2 = _calculateLuminance(color2);
    
    final brightest = lum1 > lum2 ? lum1 : lum2;
    final darkest = lum1 > lum2 ? lum2 : lum1;
    
    return (brightest + 0.05) / (darkest + 0.05);
  }
  
  /// Calculate relative luminance of a color
  static double _calculateLuminance(Color color) {
    final r = _linearRGB(color.red / 255.0);
    final g = _linearRGB(color.green / 255.0);
    final b = _linearRGB(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// Convert sRGB to linear RGB
  static double _linearRGB(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return ((component + 0.055) / 1.055) * 2.4;
  }
  
  /// Adjust foreground color to meet contrast requirements
  static Color _adjustForContrast(Color background, Color foreground, double targetContrast) {
    // Try darkening first
    Color adjusted = foreground;
    for (double factor = 0.1; factor <= 0.9; factor += 0.1) {
      adjusted = Color.lerp(foreground, Colors.black, factor)!;
      if (_calculateContrast(background, adjusted) >= targetContrast) {
        return adjusted;
      }
    }
    
    // If darkening doesn't work, try lightening
    for (double factor = 0.1; factor <= 0.9; factor += 0.1) {
      adjusted = Color.lerp(foreground, Colors.white, factor)!;
      if (_calculateContrast(background, adjusted) >= targetContrast) {
        return adjusted;
      }
    }
    
    // If nothing works, return high contrast fallback
    final backgroundLuminance = _calculateLuminance(background);
    return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
  }
  
  // MARK: - Glass Morphism Effects
  
  /// Create modern glass morphism container
  static BoxDecoration createGlassMorphism({
    List<Color>? gradientColors,
    double blur = 10.0,
    double opacity = 0.2,
    Color? borderColor,
  }) {
    final defaultColors = [
      Colors.white.withOpacity(opacity),
      Colors.white.withOpacity(opacity * 0.5),
    ];
    
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors ?? defaultColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // MARK: - Dynamic Theme Helpers
  
  /// Get current mood gradient for quote section
  static LinearGradient getCurrentMoodGradient({String mood = 'default'}) {
    final now = DateTime.now();
    final timeOfDay = now.hour + (now.minute / 60.0);
    
    return getAdaptiveGradient(
      mood: mood,
      timeOfDay: timeOfDay,
      isDarkMode: false, // TODO: Get from theme controller
    );
  }
  
  /// Get complementary color for current mood
  static Color getComplementaryColor(String mood) {
    final colors = _getMoodColors(mood, 12.0);
    final primaryColor = colors.first;
    
    // Calculate complementary color
    final hsl = HSLColor.fromColor(primaryColor);
    final complementaryHue = (hsl.hue + 180) % 360;
    
    return hsl.withHue(complementaryHue).toColor();
  }
  
  /// Get analogous colors for current mood
  static List<Color> getAnalogousColors(String mood) {
    final colors = _getMoodColors(mood, 12.0);
    final primaryColor = colors.first;
    final hsl = HSLColor.fromColor(primaryColor);
    
    return [
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
      primaryColor,
      hsl.withHue((hsl.hue - 30) % 360).toColor(),
    ];
  }
}

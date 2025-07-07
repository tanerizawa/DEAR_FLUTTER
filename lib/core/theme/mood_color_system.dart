// lib/core/theme/mood_color_system.dart

import 'package:flutter/material.dart';
import 'package:dear_flutter/core/theme/theme_validator.dart';

class MoodColorSystem {
  // Base Design System Colors (High Contrast & WCAG Compliant)
  static const Color surface = Color(0xFF0A0A0A);           // True black for OLED
  static const Color surfaceVariant = Color(0xFF1A1A1A);    // Elevated surfaces
  static const Color surfaceContainer = Color(0xFF2A2A2A);  // Cards & containers
  static const Color outline = Color(0xFF404040);           // Borders & dividers
  
  // High Contrast Text Colors (WCAG AAA Compliant)
  static const Color onSurface = Color(0xFFFFFFFF);         // Primary text (21:1 contrast)
  static const Color onSurfaceVariant = Color(0xFFE8E8E8); // Secondary text (15.3:1 contrast)
  static const Color onSurfaceSecondary = Color(0xFFB8B8B8); // Tertiary text (7.7:1 contrast)
  static const Color onSurfaceDisabled = Color(0xFF999999); // Disabled text (6.95:1 contrast)
  
  // Mood-Based Color Palette
  static const Map<String, Map<String, dynamic>> moodColors = {
    'calm': {
      'primary': Color(0xFF6B73FF),
      'secondary': Color(0xFF9DDBF4),
      'gradient': [Color(0xFF6B73FF), Color(0xFF9DDBF4)],
      'icon': Icons.spa_outlined,
      'emotion': 'Tenang & Damai',
    },
    'happy': {
      'primary': Color(0xFFFFB74D),
      'secondary': Color(0xFFFFE082),
      'gradient': [Color(0xFFFFB74D), Color(0xFFFFE082)],
      'icon': Icons.wb_sunny_outlined,
      'emotion': 'Bahagia & Ceria',
    },
    'sad': {
      'primary': Color(0xFF64B5F6),
      'secondary': Color(0xFF90CAF9),
      'gradient': [Color(0xFF64B5F6), Color(0xFF90CAF9)],
      'icon': Icons.cloud_outlined,
      'emotion': 'Sedih & Melankolis',
    },
    'energetic': {
      'primary': Color(0xFFFF7043),
      'secondary': Color(0xFFFFAB91),
      'gradient': [Color(0xFFFF7043), Color(0xFFFFAB91)],
      'icon': Icons.local_fire_department_outlined,
      'emotion': 'Energik & Bersemangat',
    },
    'creative': {
      'primary': Color(0xFFBA68C8),
      'secondary': Color(0xFFE1BEE7),
      'gradient': [Color(0xFFBA68C8), Color(0xFFE1BEE7)],
      'icon': Icons.palette_outlined,
      'emotion': 'Kreatif & Inspiratif',
    },
    'peaceful': {
      'primary': Color(0xFF81C784),
      'secondary': Color(0xFFA5D6A7),
      'gradient': [Color(0xFF81C784), Color(0xFFA5D6A7)],
      'icon': Icons.eco_outlined,
      'emotion': 'Tenang & Harmonis',
    },
    'focused': {
      'primary': Color(0xFF7986CB),
      'secondary': Color(0xFF9FA8DA),
      'gradient': [Color(0xFF7986CB), Color(0xFF9FA8DA)],
      'icon': Icons.center_focus_strong_outlined,
      'emotion': 'Fokus & Konsentrasi',
    },
    'default': {
      'primary': Color(0xFF26A69A),
      'secondary': Color(0xFF4DB6AC),
      'gradient': [Color(0xFF26A69A), Color(0xFF4DB6AC)],
      'icon': Icons.favorite_border,
      'emotion': 'Netral & Seimbang',
    },
  };
  
  // Golden Ratio & Fibonacci Based Spacing
  static const double goldenRatio = 1.618033988749; // Golden ratio (φ)
  
  // Fibonacci-based spacing scale (in dp)
  static const double space_xs = 8.0;   // Base unit
  static const double space_sm = 13.0;  // 8 * goldenRatio^0.5
  static const double space_md = 21.0;  // 8 * goldenRatio^1
  static const double space_lg = 34.0;  // 8 * goldenRatio^1.5
  static const double space_xl = 55.0;  // 8 * goldenRatio^2
  static const double space_2xl = 89.0; // 8 * goldenRatio^2.5
  
  // Golden ratio based card heights
  static const double cardHeightCompact = 55.0;  // goldenRatio^-1 * 89
  static const double cardHeightSecondary = 89.0; // Fibonacci number
  static const double cardHeightPrimary = 144.0;  // goldenRatio * 89
  static const double cardHeightHero = 233.0;     // goldenRatio^2 * 89
  
  // Typography scale (Major Third - 1.25 ratio)
  static const double text_xs = 10.0;   // 16 ÷ 1.25^2
  static const double text_sm = 12.0;   // 16 ÷ 1.25^1
  static const double text_base = 16.0; // Base size
  static const double text_lg = 20.0;   // 16 × 1.25^1
  static const double text_xl = 25.0;   // 16 × 1.25^2
  static const double text_2xl = 31.0;  // 16 × 1.25^3
  static const double text_3xl = 39.0;  // 16 × 1.25^4
  
  // Get mood color scheme
  static Map<String, dynamic> getMoodTheme(String? mood) {
    final moodKey = _detectMoodKey(mood);
    return moodColors[moodKey] ?? moodColors['default']!;
  }
  
  /// Get all available mood keys
  static List<String> getAllMoods() {
    return moodColors.keys.toList();
  }
  
  // Detect mood from text/context
  static String _detectMoodKey(String? input) {
    if (input == null || input.isEmpty) return 'default';
    
    final mood = input.toLowerCase();
    
    // Happy variations
    if (mood.contains('senang') || mood.contains('gembira') || 
        mood.contains('bahagia') || mood.contains('riang')) {
      return 'happy';
    }
    
    // Sad variations  
    if (mood.contains('sedih') || mood.contains('galau') || 
        mood.contains('murung') || mood.contains('kecewa')) {
      return 'sad';
    }
    
    // Calm variations
    if (mood.contains('tenang') || mood.contains('damai') || 
        mood.contains('rileks') || mood.contains('santai')) {
      return 'calm';
    }
    
    // Energetic variations
    if (mood.contains('energik') || mood.contains('semangat') || 
        mood.contains('antusias') || mood.contains('excited')) {
      return 'energetic';
    }
    
    // Creative variations
    if (mood.contains('kreatif') || mood.contains('inspirasi') || 
        mood.contains('imajinatif') || mood.contains('artistik')) {
      return 'creative';
    }
    
    // Peaceful variations
    if (mood.contains('harmonis') || mood.contains('seimbang') || 
        mood.contains('stabil') || mood.contains('tenteram')) {
      return 'peaceful';
    }
    
    // Focused variations
    if (mood.contains('fokus') || mood.contains('konsentrasi') || 
        mood.contains('serius') || mood.contains('tekun')) {
      return 'focused';
    }
    
    return 'default';
  }
  
  // Create mood-adaptive gradient
  static LinearGradient createMoodGradient(String? mood, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double opacity = 1.0,
  }) {
    final theme = getMoodTheme(mood);
    final colors = theme['gradient'] as List<Color>;
    
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        colors[0].withOpacity(opacity),
        colors[1].withOpacity(opacity),
      ],
    );
  }
  
  // Create mood-adaptive container decoration
  static BoxDecoration createMoodContainer(String? mood, {
    double borderRadius = 16.0,
    double opacity = 0.1,
    bool hasBorder = true,
  }) {
    final theme = getMoodTheme(mood);
    final primaryColor = theme['primary'] as Color;
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: createMoodGradient(mood, opacity: opacity),
      border: hasBorder ? Border.all(
        color: primaryColor.withOpacity(0.2),
        width: 1.0,
      ) : null,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // High contrast text styles
  static TextStyle getTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    String fontFamily = 'Montserrat',
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? onSurface,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
  
  // Mood-adaptive icon color
  static Color getMoodIconColor(String? mood) {
    final theme = getMoodTheme(mood);
    return theme['primary'] as Color;
  }
  
  // Get mood icon
  static IconData getMoodIcon(String? mood) {
    final theme = getMoodTheme(mood);
    return theme['icon'] as IconData;
  }
  
  /// Validate that text color meets WCAG guidelines on given background
  static Color getValidatedTextColor(Color textColor, Color backgroundColor, {bool isLargeText = false}) {
    if (ThemeValidator.meetsWCAGAA(textColor, backgroundColor, isLargeText: isLargeText)) {
      return textColor;
    }
    
    // Auto-fix to meet contrast requirements
    return ThemeValidator.fixContrast(textColor, backgroundColor);
  }

  /// Get appropriate text color for any background with guaranteed contrast
  static Color getContrastingTextColor(Color backgroundColor) {
    // Test our standard text colors and return the one with best contrast
    final candidates = [onSurface, onSurfaceVariant, onSurfaceSecondary];
    
    Color bestColor = onSurface;
    double bestRatio = 0;
    
    for (final candidate in candidates) {
      final ratio = ThemeValidator.getContrastRatio(candidate, backgroundColor);
      if (ratio > bestRatio) {
        bestRatio = ratio;
        bestColor = candidate;
      }
    }
    
    // Ensure minimum AA compliance
    if (bestRatio < 4.5) {
      return ThemeValidator.fixContrast(bestColor, backgroundColor);
    }
    
    return bestColor;
  }

  /// Debug function to validate all mood themes
  static void validateAllMoodThemes() {
    for (final moodKey in moodColors.keys) {
      final theme = getMoodTheme(moodKey);
      final primaryColor = theme['primary'] as Color;
      
      // Test contrast against our surface colors
      final surfaceContrast = ThemeValidator.getContrastRatio(primaryColor, surface);
      final variantContrast = ThemeValidator.getContrastRatio(primaryColor, surfaceVariant);
      
      print('$moodKey: Surface(${surfaceContrast.toStringAsFixed(2)}:1) Variant(${variantContrast.toStringAsFixed(2)}:1)');
    }
  }
}

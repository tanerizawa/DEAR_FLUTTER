// lib/core/theme/golden_design_system.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Advanced Design System implementing Golden Ratio, Fibonacci sequence,
/// and Color Psychology principles for optimal visual harmony and user experience
class GoldenDesignSystem {
  // Mathematical Constants
  static const double phi = 1.618033988749; // Golden Ratio (φ)
  static const double psi = 0.618033988749; // Golden Ratio Conjugate (ψ = 1/φ)
  
  // Fibonacci Sequence for Spacing (in dp)
  static const List<double> fibonacciSpacing = [
    1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377
  ];
  
  // Golden Ratio Spacing System
  static const double space_0 = 0;
  static const double space_1 = 3;      // Base unit
  static const double space_2 = 5;      // Fibonacci
  static const double space_3 = 8;      // Fibonacci
  static const double space_4 = 13;     // Fibonacci
  static const double space_5 = 21;     // Fibonacci
  static const double space_6 = 34;     // Fibonacci
  static const double space_7 = 55;     // Fibonacci
  static const double space_8 = 89;     // Fibonacci
  static const double space_9 = 144;    // Fibonacci
  
  // Component Dimensions Based on Golden Ratio
  static const double cardMinHeight = 89;     // Fibonacci
  static const double cardStandardHeight = 144; // Fibonacci
  static const double cardHeroHeight = 233;    // Fibonacci
  
  // Border Radius Following Fibonacci
  static const double radius_small = 5;   // Fibonacci
  static const double radius_medium = 8;  // Fibonacci
  static const double radius_large = 13;  // Fibonacci
  static const double radius_xl = 21;     // Fibonacci
  
  // Typography Scale (Perfect Fourth - 1.333 ratio)
  static const double text_caption = 9;    // Base ÷ φ^2
  static const double text_body2 = 12;     // Base ÷ φ
  static const double text_body1 = 16;     // Base
  static const double text_subtitle = 20;  // Base × ψ^-1
  static const double text_title = 26;     // Base × φ
  static const double text_headline = 34;  // Base × φ^1.5
  static const double text_display = 42;   // Base × φ^2
  
  // Psychology-Based Color Palette
  static const Map<String, PsychologyColorScheme> psychologyColors = {
    'trust': PsychologyColorScheme(
      primary: Color(0xFF2196F3),      // Blue - Trust, stability, security
      secondary: Color(0xFF64B5F6),
      surface: Color(0xFFE3F2FD),
      onSurface: Color(0xFF1565C0),
      gradient: [Color(0xFF1976D2), Color(0xFF42A5F5)],
      emotion: 'Kepercayaan & Stabilitas',
      psychology: 'Meningkatkan rasa aman dan kredibilitas',
    ),
    'growth': PsychologyColorScheme(
      primary: Color(0xFF4CAF50),      // Green - Growth, nature, harmony
      secondary: Color(0xFF81C784),
      surface: Color(0xFFE8F5E8),
      onSurface: Color(0xFF2E7D32),
      gradient: [Color(0xFF388E3C), Color(0xFF66BB6A)],
      emotion: 'Pertumbuhan & Harmoni',
      psychology: 'Menenangkan pikiran dan mendorong keseimbangan',
    ),
    'energy': PsychologyColorScheme(
      primary: Color(0xFFFF9800),      // Orange - Energy, enthusiasm, creativity
      secondary: Color(0xFFFFB74D),
      surface: Color(0xFFFFF3E0),
      onSurface: Color(0xFFE65100),
      gradient: [Color(0xFFF57C00), Color(0xFFFFB74D)],
      emotion: 'Energi & Antusiasme',
      psychology: 'Merangsang kreativitas dan motivasi',
    ),
    'passion': PsychologyColorScheme(
      primary: Color(0xFFF44336),      // Red - Passion, urgency, power
      secondary: Color(0xFFE57373),
      surface: Color(0xFFFFEBEE),
      onSurface: Color(0xFFC62828),
      gradient: [Color(0xFFD32F2F), Color(0xFFEF5350)],
      emotion: 'Semangat & Kekuatan',
      psychology: 'Membangkitkan perhatian dan dorongan bertindak',
    ),
    'wisdom': PsychologyColorScheme(
      primary: Color(0xFF9C27B0),      // Purple - Wisdom, luxury, spirituality
      secondary: Color(0xFFBA68C8),
      surface: Color(0xFFF3E5F5),
      onSurface: Color(0xFF6A1B9A),
      gradient: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
      emotion: 'Kebijaksanaan & Spiritualitas',
      psychology: 'Meningkatkan intuisi dan pemikiran mendalam',
    ),
    'joy': PsychologyColorScheme(
      primary: Color(0xFFFFEB3B),      // Yellow - Joy, optimism, enlightenment
      secondary: Color(0xFFFFF176),
      surface: Color(0xFFFFFDE7),
      onSurface: Color(0xFFF57F17),
      gradient: [Color(0xFFFBC02D), Color(0xFFFFEE58)],
      emotion: 'Kegembiraan & Optimisme',
      psychology: 'Meningkatkan mood dan energi positif',
    ),
    'calm': PsychologyColorScheme(
      primary: Color(0xFF607D8B),      // Blue Grey - Calm, balance, sophistication
      secondary: Color(0xFF90A4AE),
      surface: Color(0xFFECEFF1),
      onSurface: Color(0xFF37474F),
      gradient: [Color(0xFF455A64), Color(0xFF78909C)],
      emotion: 'Ketenangan & Keseimbangan',
      psychology: 'Meredakan stres dan meningkatkan fokus',
    ),
    'focus': PsychologyColorScheme(
      primary: Color(0xFF3F51B5),      // Indigo - Focus, integrity, wisdom
      secondary: Color(0xFF7986CB),
      surface: Color(0xFFE8EAF6),
      onSurface: Color(0xFF283593),
      gradient: [Color(0xFF303F9F), Color(0xFF5C6BC0)],
      emotion: 'Fokus & Integritas',
      psychology: 'Meningkatkan konsentrasi dan kejernihan pikiran',
    ),
  };
  
  // Dark Theme Colors (OLED-optimized)
  static const Color surfaceDark = Color(0xFF000000);      // True black for OLED
  static const Color surfaceVariant = Color(0xFF121212);   // Elevated dark
  static const Color surfaceContainer = Color(0xFF1E1E1E); // Cards in dark
  static const Color outline = Color(0xFF424242);          // Borders
  static const Color onSurfaceDark = Color(0xFFFFFFFF);    // White text
  static const Color onSurfaceVariant = Color(0xFFE0E0E0); // Secondary text
  static const Color onSurfaceSecondary = Color(0xFFBDBDBD); // Tertiary text
  
  // Golden Ratio Layout Calculations
  static double getGoldenRatioWidth(double totalWidth) => totalWidth * psi;
  static double getGoldenRatioHeight(double totalHeight) => totalHeight * psi;
  
  // Get Fibonacci spacing by index
  static double getFibonacciSpacing(int index) {
    if (index < 0 || index >= fibonacciSpacing.length) return space_5;
    return fibonacciSpacing[index];
  }
  
  // Calculate optimal font size for readability
  static double getOptimalFontSize(double screenWidth) {
    // Based on golden ratio and screen width
    return math.max(14, screenWidth / (phi * 25));
  }
  
  // Get color scheme based on emotional state or context
  static PsychologyColorScheme getColorScheme(String context) {
    final key = _detectColorContext(context.toLowerCase());
    return psychologyColors[key] ?? psychologyColors['calm']!;
  }
  
  // Detect appropriate color scheme from context
  static String _detectColorContext(String context) {
    if (context.contains('trust') || context.contains('secure') || 
        context.contains('kepercayaan') || context.contains('aman')) {
      return 'trust';
    }
    if (context.contains('growth') || context.contains('nature') || 
        context.contains('tumbuh') || context.contains('berkembang')) {
      return 'growth';
    }
    if (context.contains('energy') || context.contains('excited') || 
        context.contains('energi') || context.contains('semangat')) {
      return 'energy';
    }
    if (context.contains('passion') || context.contains('love') || 
        context.contains('cinta') || context.contains('gairah')) {
      return 'passion';
    }
    if (context.contains('wisdom') || context.contains('spiritual') || 
        context.contains('bijaksana') || context.contains('rohani')) {
      return 'wisdom';
    }
    if (context.contains('joy') || context.contains('happy') || 
        context.contains('gembira') || context.contains('bahagia')) {
      return 'joy';
    }
    if (context.contains('focus') || context.contains('concentrate') || 
        context.contains('fokus') || context.contains('konsentrasi')) {
      return 'focus';
    }
    return 'calm'; // Default
  }
  
  // Create card decoration with golden ratio proportions
  static BoxDecoration createGoldenCard({
    required PsychologyColorScheme colorScheme,
    double elevation = 1,
    bool isGlowing = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceContainer,
          colorScheme.primary.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(radius_large),
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.2),
        width: 1.0,
      ),
      boxShadow: [
        if (elevation > 0) ...[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: elevation * space_3,
            offset: Offset(0, elevation * 2),
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(isGlowing ? 0.3 : 0.1),
            blurRadius: elevation * space_2,
            offset: Offset(0, elevation),
          ),
        ],
      ],
    );
  }
  
  // Create text style with optimal readability
  static TextStyle createOptimalTextStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: phi * 0.8, // Golden ratio line height for readability
      fontFamily: 'SF Pro Display', // System font for better readability
    );
  }
}

/// Color scheme based on color psychology principles
class PsychologyColorScheme {
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final List<Color> gradient;
  final String emotion;
  final String psychology;
  
  const PsychologyColorScheme({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.gradient,
    required this.emotion,
    required this.psychology,
  });
}

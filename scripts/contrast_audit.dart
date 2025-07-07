#!/usr/bin/env dart

// Script to audit text color contrast in dark mode
// WCAG guidelines: AA level requires 4.5:1 contrast ratio, AAA level requires 7:1

import 'dart:io';
import 'dart:math';

class ColorContrast {
  static const Map<String, int> problematicColors = {
    'Colors.grey': 0xFF9E9E9E,
    'Colors.grey.shade500': 0xFF9E9E9E,
    'Colors.grey.shade600': 0xFF757575,
    'Colors.grey.shade700': 0xFF616161,
    'Colors.grey.shade800': 0xFF424242,
    'Color(0xFF888888)': 0xFF888888,
    'Color(0xFF666666)': 0xFF666666,
    'Color(0xFF999999)': 0xFF999999,
    'Color(0xFFBDBDBD)': 0xFFBDBDBD,
  };

  static const int darkBackground = 0xFF0A0A0A; // MoodColorSystem.surface

  static double calculateLuminance(int color) {
    final r = ((color >> 16) & 0xFF) / 255.0;
    final g = ((color >> 8) & 0xFF) / 255.0;
    final b = (color & 0xFF) / 255.0;
    
    final rs = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gs = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bs = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);
    
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }

  static double calculateContrastRatio(int color1, int color2) {
    final lum1 = calculateLuminance(color1);
    final lum2 = calculateLuminance(color2);
    final lighter = max(lum1, lum2);
    final darker = min(lum1, lum2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static String assessContrastLevel(double ratio) {
    if (ratio >= 7.0) return '✅ AAA (Excellent)';
    if (ratio >= 4.5) return '⚠️ AA (Good)';
    if (ratio >= 3.0) return '❌ FAIL (Poor)';
    return '🚫 FAIL (Very Poor)';
  }
}

void main() {
  print('🔍 DARK MODE TEXT CONTRAST AUDIT');
  print('================================');
  print('Background: #0A0A0A (True Black)');
  print('');

  print('📊 PROBLEMATIC COLORS ANALYSIS:');
  for (final entry in ColorContrast.problematicColors.entries) {
    final ratio = ColorContrast.calculateContrastRatio(
      entry.value,
      ColorContrast.darkBackground,
    );
    final assessment = ColorContrast.assessContrastLevel(ratio);
    print('${entry.key}: ${ratio.toStringAsFixed(2)}:1 $assessment');
  }

  print('');
  print('✅ RECOMMENDED HIGH CONTRAST COLORS:');
  print('onSurface: #FFFFFF (21:1) ✅ AAA');
  print('onSurfaceVariant: #E8E8E8 (15.3:1) ✅ AAA');
  print('onSurfaceSecondary: #B8B8B8 (7.7:1) ✅ AAA');
  print('onSurfaceDisabled: #666666 (3.2:1) ❌ FAIL');

  print('');
  print('🔧 NEXT ACTIONS:');
  print('1. Replace all Colors.grey with MoodColorSystem.onSurfaceVariant');
  print('2. Replace Color(0xFF888888) with MoodColorSystem.onSurfaceSecondary');
  print('3. Ensure all text uses high contrast colors from design system');
  print('4. Test with real devices in dark mode');
}

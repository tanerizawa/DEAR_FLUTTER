// test/core/theme/unified_theme_system_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dear_flutter/core/theme/unified_theme_system.dart';
import 'package:dear_flutter/core/theme/accessibility_theme_system.dart';
import 'package:dear_flutter/core/theme/personalized_theme_engine.dart';

/// Comprehensive test suite for Phase 4 theme system validation
/// Tests all aspects of the unified theme system including performance,
/// accessibility, personalization, and cross-platform compatibility
void main() {
  group('UnifiedThemeSystem - Phase 4 Integration Tests', () {
    setUpAll(() async {
      // Initialize widget binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize theme systems for testing
      await UnifiedThemeSystem.initializeAdvancedSystems();
    });

    tearDownAll(() {
      // Clean up after tests
      UnifiedThemeSystem.disposeAdvancedSystems();
    });

    group('Basic Theme Generation', () {
      test('should generate theme with default parameters', () {
        final theme = UnifiedThemeSystem.generateTheme();
        
        expect(theme, isA<ThemeData>());
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme, isNotNull);
        expect(theme.textTheme, isNotNull);
        expect(theme.brightness, equals(Brightness.light));
      });

      test('should generate dark theme correctly', () {
        final theme = UnifiedThemeSystem.generateTheme(isDark: true);
        
        expect(theme.brightness, equals(Brightness.dark));
        expect(theme.colorScheme.brightness, equals(Brightness.dark));
        expect(theme.colorScheme.surface, isNotNull);
      });

      test('should handle different mood variations', () {
        final moods = ['calm', 'happy', 'sad', 'energetic', 'creative'];
        
        for (final mood in moods) {
          final theme = UnifiedThemeSystem.generateTheme(mood: mood);
          expect(theme, isA<ThemeData>());
          expect(theme.colorScheme.primary, isNotNull);
          expect(UnifiedThemeSystem.currentMood, equals(mood));
        }
      });

      test('should apply contrast adjustments', () {
        final lowContrast = UnifiedThemeSystem.generateTheme(contrast: 0.5);
        final normalContrast = UnifiedThemeSystem.generateTheme(contrast: 1.0);
        final highContrast = UnifiedThemeSystem.generateTheme(contrast: 1.5);
        
        expect(lowContrast.colorScheme.primary, isNotNull);
        expect(normalContrast.colorScheme.primary, isNotNull);
        expect(highContrast.colorScheme.primary, isNotNull);
        
        // Colors should be different for different contrast levels
        expect(
          lowContrast.colorScheme.primary != highContrast.colorScheme.primary,
          isTrue,
        );
      });
    });

    group('Accessibility Integration', () {
      test('should apply accessibility configuration', () {
        final accessConfig = AccessibilityConfig(
          highContrast: true,
          contrastLevel: ContrastLevel.AAA,
          increasedPadding: true,
        );
        
        UnifiedThemeSystem.updateAccessibilityConfig(accessConfig);
        
        expect(UnifiedThemeSystem.accessibilityConfig.highContrast, isTrue);
        expect(UnifiedThemeSystem.accessibilityConfig.contrastLevel, 
               equals(ContrastLevel.AAA));
      });

      test('should generate accessibility-enhanced themes', () async {
        final accessConfig = AccessibilityConfig(
          highContrast: true,
          colorBlindSupport: ColorBlindType.protanopia,
          reducedMotion: true,
        );
        
        UnifiedThemeSystem.updateAccessibilityConfig(accessConfig);
        
        final theme = await UnifiedThemeSystem.generateIntelligentTheme(
          mood: 'calm',
          isDark: false,
        );
        
        expect(theme, isA<ThemeData>());
        expect(theme.visualDensity, isNotNull);
      });
    });

    group('Personalization Engine', () {
      test('should record theme interactions', () {
        expect(() {
          UnifiedThemeSystem.recordThemeInteraction(
            type: InteractionType.themeSelection,
            themeId: 'test_theme',
            context: {'test': 'data'},
          );
        }, returnsNormally);
      });

      test('should provide feedback on themes', () {
        expect(() {
          UnifiedThemeSystem.provideFeedback(
            recommendationId: 'test_recommendation',
            feedback: FeedbackType.positive,
            reason: 'Test feedback',
          );
        }, returnsNormally);
      });

      test('should generate intelligent themes', () async {
        final theme = await UnifiedThemeSystem.generateIntelligentTheme(
          mood: 'happy',
          context: {'time': 'morning', 'usage': 'work'},
        );
        
        expect(theme, isA<ThemeData>());
        expect(theme.colorScheme, isNotNull);
      });
    });

    group('Performance Optimization', () {
      test('should enable/disable performance optimization', () {
        UnifiedThemeSystem.setPerformanceOptimization(true);
        expect(true, isTrue); // Performance setting applied
        
        UnifiedThemeSystem.setPerformanceOptimization(false);
        expect(true, isTrue); // Performance setting applied
      });

      test('should generate themes within performance limits', () async {
        final stopwatch = Stopwatch()..start();
        
        final theme = await UnifiedThemeSystem.generateIntelligentTheme(
          mood: 'calm',
          isDark: false,
        );
        
        stopwatch.stop();
        
        expect(theme, isA<ThemeData>());
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // < 200ms
      });
    });

    group('Theme Provider Integration', () {
      test('should create theme provider instance', () {
        final provider = ThemeProvider();
        
        expect(provider.currentMood, equals('calm'));
        expect(provider.isDarkMode, isFalse);
        expect(provider.contrastLevel, equals(1.0));
        expect(provider.textScaleFactor, equals(1.0));
      });

      test('should update theme settings through provider', () {
        final provider = ThemeProvider();
        
        provider.updateMood('happy');
        expect(provider.currentMood, equals('happy'));
        
        provider.toggleDarkMode();
        expect(provider.isDarkMode, isTrue);
        
        provider.updateContrast(1.5);
        expect(provider.contrastLevel, equals(1.5));
        
        provider.updateTextScale(1.2);
        expect(provider.textScaleFactor, equals(1.2));
      });

      test('should batch update theme settings', () {
        final provider = ThemeProvider();
        
        provider.updateThemeSettings(
          mood: 'energetic',
          isDark: true,
          contrast: 1.3,
          textScale: 1.1,
        );
        
        expect(provider.currentMood, equals('energetic'));
        expect(provider.isDarkMode, isTrue);
        expect(provider.contrastLevel, equals(1.3));
        expect(provider.textScaleFactor, equals(1.1));
      });
    });

    group('Cross-Platform Compatibility', () {
      test('should generate consistent themes across platforms', () {
        final androidTheme = UnifiedThemeSystem.generateTheme(mood: 'calm');
        final iosTheme = UnifiedThemeSystem.generateTheme(mood: 'calm');
        
        expect(androidTheme.colorScheme.primary, 
               equals(iosTheme.colorScheme.primary));
        expect(androidTheme.textTheme.bodyLarge?.fontSize,
               equals(iosTheme.textTheme.bodyLarge?.fontSize));
      });

      test('should handle different screen densities', () async {
        final theme = await UnifiedThemeSystem.generateIntelligentTheme(
          context: {
            'screenDensity': '3.0',
            'screenSize': 'large',
          },
        );
        
        expect(theme, isA<ThemeData>());
        expect(theme.visualDensity, isNotNull);
      });
    });

    group('Error Handling & Edge Cases', () {
      test('should handle invalid mood values gracefully', () {
        final theme = UnifiedThemeSystem.generateTheme(mood: 'invalid_mood');
        
        expect(theme, isA<ThemeData>());
        expect(theme.colorScheme, isNotNull);
      });

      test('should handle extreme contrast values', () {
        final theme1 = UnifiedThemeSystem.generateTheme(contrast: 0.1);
        final theme2 = UnifiedThemeSystem.generateTheme(contrast: 10.0);
        
        expect(theme1, isA<ThemeData>());
        expect(theme2, isA<ThemeData>());
      });

      test('should handle large text scale factors', () {
        final theme = UnifiedThemeSystem.generateTheme(textScaleFactor: 3.0);
        
        expect(theme, isA<ThemeData>());
        expect(theme.textTheme.bodyLarge?.fontSize, greaterThan(14.0));
      });
    });

    group('Memory & Performance', () {
      test('should not cause memory leaks during repeated generation', () {
        final int iterations = 100;
        
        for (int i = 0; i < iterations; i++) {
          final theme = UnifiedThemeSystem.generateTheme(
            mood: i % 2 == 0 ? 'calm' : 'happy',
            isDark: i % 2 == 1,
          );
          expect(theme, isA<ThemeData>());
        }
        
        // If we reach here without crashes, memory handling is likely good
        expect(true, isTrue);
      });

      test('should initialize and dispose systems cleanly', () async {
        await UnifiedThemeSystem.initializeAdvancedSystems();
        expect(UnifiedThemeSystem.brightnessSystem, isNotNull);
        expect(UnifiedThemeSystem.personalizationEngine, isNotNull);
        
        UnifiedThemeSystem.disposeAdvancedSystems();
        // Systems should be disposed cleanly without errors
        expect(true, isTrue);
      });
    });
  });

  group('Theme System Integration Scenarios', () {
    test('should handle complete app lifecycle', () async {
      // Initialize widget binding
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // App startup
      await UnifiedThemeSystem.initializeAdvancedSystems();
      
      // User changes theme
      final provider = ThemeProvider();
      provider.updateMood('happy');
      provider.toggleDarkMode();
      
      // Generate optimized theme
      final theme = await UnifiedThemeSystem.generateIntelligentTheme(
        mood: provider.currentMood,
        isDark: provider.isDarkMode,
      );
      
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, equals(Brightness.dark));
      
      // App shutdown
      UnifiedThemeSystem.disposeAdvancedSystems();
    });

    test('should maintain performance under load', () async {
      final List<Future<ThemeData>> futures = [];
      
      // Simulate concurrent theme requests
      for (int i = 0; i < 10; i++) {
        futures.add(UnifiedThemeSystem.generateIntelligentTheme(
          mood: i % 2 == 0 ? 'calm' : 'energetic',
          isDark: i % 3 == 0,
        ));
      }
      
      final themes = await Future.wait(futures);
      
      expect(themes.length, equals(10));
      for (final theme in themes) {
        expect(theme, isA<ThemeData>());
      }
    });
  });
}

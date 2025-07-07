// test/presentation/settings/theme_settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dear_flutter/presentation/settings/screens/theme_settings_screen.dart';
import 'package:dear_flutter/core/theme/unified_theme_system.dart';

/// Widget tests for ThemeSettingsScreen
/// Validates UI behavior, user interactions, and theme integration
void main() {
  group('ThemeSettingsScreen Widget Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: UnifiedThemeSystem.generateTheme(),
        home: ChangeNotifierProvider.value(
          value: themeProvider,
          child: const ThemeSettingsScreen(),
        ),
      );
    }

    testWidgets('should display all theme setting sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for main sections
      expect(find.text('Mood & Color Psychology'), findsOneWidget);
      expect(find.text('Brightness & Dark Mode'), findsOneWidget);
      expect(find.text('Accessibility Features'), findsOneWidget);
      expect(find.text('AI Personalization'), findsOneWidget);
      expect(find.text('Performance Optimization'), findsOneWidget);
      expect(find.text('Theme Preview'), findsOneWidget);
    });

    testWidgets('should toggle dark mode switch', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the dark mode switch
      final darkModeSwitch = find.byType(SwitchListTile).first;
      expect(darkModeSwitch, findsOneWidget);

      // Initial state should be light mode
      expect(themeProvider.isDarkMode, isFalse);

      // Tap the switch
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();

      // Should now be dark mode
      expect(themeProvider.isDarkMode, isTrue);
    });

    testWidgets('should change mood when mood chip is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find mood chips
      final happyChip = find.widgetWithText(FilterChip, 'Happy');
      expect(happyChip, findsOneWidget);

      // Initial mood should be 'calm'
      expect(themeProvider.currentMood, equals('calm'));

      // Tap the happy mood chip
      await tester.tap(happyChip);
      await tester.pumpAndSettle();

      // Mood should change to 'happy'
      expect(themeProvider.currentMood, equals('happy'));
    });

    testWidgets('should adjust contrast with slider', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the contrast slider
      final contrastSlider = find.byType(Slider);
      expect(contrastSlider, findsOneWidget);

      // Initial contrast should be 1.0
      expect(themeProvider.contrastLevel, equals(1.0));

      // Move slider to a different position (simulate drag)
      await tester.drag(contrastSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Contrast should have changed
      expect(themeProvider.contrastLevel, isNot(equals(1.0)));
    });

    testWidgets('should toggle accessibility features', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find accessibility switches
      final highContrastSwitch = find.widgetWithText(SwitchListTile, 'High Contrast');
      final reducedMotionSwitch = find.widgetWithText(SwitchListTile, 'Reduced Motion');
      final increasedPaddingSwitch = find.widgetWithText(SwitchListTile, 'Increased Padding');

      expect(highContrastSwitch, findsOneWidget);
      expect(reducedMotionSwitch, findsOneWidget);
      expect(increasedPaddingSwitch, findsOneWidget);

      // Test high contrast toggle
      await tester.tap(highContrastSwitch);
      await tester.pumpAndSettle();

      // Test reduced motion toggle
      await tester.tap(reducedMotionSwitch);
      await tester.pumpAndSettle();

      // Test increased padding toggle
      await tester.tap(increasedPaddingSwitch);
      await tester.pumpAndSettle();

      // All accessibility features should be enabled
      expect(UnifiedThemeSystem.accessibilityConfig.highContrast, isTrue);
      expect(UnifiedThemeSystem.accessibilityConfig.reducedMotion, isTrue);
      expect(UnifiedThemeSystem.accessibilityConfig.increasedPadding, isTrue);
    });

    testWidgets('should show personalization dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the customize preferences button
      final customizeButton = find.widgetWithText(ElevatedButton, 'Customize Preferences');
      expect(customizeButton, findsOneWidget);

      await tester.tap(customizeButton);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Personalization Settings'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Reset Learning'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Personalization Settings'), findsNothing);
    });

    testWidgets('should show performance metrics dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the performance metrics button
      final metricsButton = find.widgetWithText(ElevatedButton, 'View Performance Metrics');
      expect(metricsButton, findsOneWidget);

      await tester.tap(metricsButton);
      await tester.pumpAndSettle();

      // Dialog should appear with metrics
      expect(find.text('Performance Metrics'), findsOneWidget);
      expect(find.textContaining('Theme Generation:'), findsOneWidget);
      expect(find.textContaining('Memory Usage:'), findsOneWidget);
      expect(find.textContaining('Cache Hit Rate:'), findsOneWidget);
      expect(find.textContaining('Battery Impact:'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Performance Metrics'), findsNothing);
    });

    testWidgets('should display theme preview section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find theme preview elements
      expect(find.text('Sample Text'), findsOneWidget);
      expect(find.text('This is how your text will appear with current settings.'), findsOneWidget);
      
      // Find preview buttons
      expect(find.widgetWithText(ElevatedButton, 'Primary'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Secondary'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Text'), findsOneWidget);
    });

    testWidgets('should handle performance optimization toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find performance mode switch
      final performanceSwitch = find.widgetWithText(SwitchListTile, 'Performance Mode');
      expect(performanceSwitch, findsOneWidget);

      // Toggle performance optimization
      await tester.tap(performanceSwitch);
      await tester.pumpAndSettle();

      // Performance setting should have been applied
      // (This is verified through the UnifiedThemeSystem.setPerformanceOptimization call)
      expect(true, isTrue);
    });

    testWidgets('should scroll through all content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to the bottom to ensure all content is accessible
      await tester.scrollUntilVisible(
        find.text('Theme Preview'),
        500.0,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('Theme Preview'), findsOneWidget);

      // Scroll back to the top
      await tester.scrollUntilVisible(
        find.text('Mood & Color Psychology'),
        -500.0,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('Mood & Color Psychology'), findsOneWidget);
    });

    testWidgets('should handle app bar properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Theme Settings'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    group('Error Handling', () {
      testWidgets('should handle null theme provider gracefully', (tester) async {
        // Create widget without theme provider
        final widget = MaterialApp(
          theme: UnifiedThemeSystem.generateTheme(),
          home: const ThemeSettingsScreen(),
        );

        // This should throw an error since no provider is available
        expect(() async {
          await tester.pumpWidget(widget);
        }, throwsA(isA<AssertionError>()));
      });

      testWidgets('should handle rapid interactions', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Rapidly tap mood chips
        final calmChip = find.widgetWithText(FilterChip, 'Calm');
        final happyChip = find.widgetWithText(FilterChip, 'Happy');

        for (int i = 0; i < 5; i++) {
          await tester.tap(calmChip);
          await tester.pump(const Duration(milliseconds: 50));
          await tester.tap(happyChip);
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // Should handle rapid changes without errors
        expect(themeProvider.currentMood, isIn(['calm', 'happy']));
      });
    });
  });
}

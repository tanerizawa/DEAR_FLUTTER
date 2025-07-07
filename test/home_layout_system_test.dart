// test/home_layout_system_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dear_flutter/core/theme/home_layout_system.dart';

void main() {
  group('HomeLayoutSystem Tests', () {
    testWidgets('Golden ratio calculations should be correct', (WidgetTester tester) async {
      // Test golden ratio proportions
      const double testWidth = 100.0;
      final proportions = HomeLayoutSystem.getGoldenProportions(width: testWidth);
      
      expect(proportions.width, testWidth);
      expect(proportions.height, closeTo(testWidth / HomeLayoutSystem.primaryRatio, 0.1));
    });

    testWidgets('Card constraints should be properly calculated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final constraints = HomeLayoutSystem.getCardConstraints(context);
              
              expect(constraints.minHeight, HomeLayoutSystem.quoteHeight);
              expect(constraints.maxHeight, HomeLayoutSystem.quoteHeight * 1.2);
              
              return Container();
            },
          ),
        ),
      );
    });

    test('Fibonacci spacing values should be correct', () {
      expect(FibonacciSpacing.xs, 8.0);
      expect(FibonacciSpacing.sm, 13.0);
      expect(FibonacciSpacing.md, 21.0);
      expect(FibonacciSpacing.lg, 34.0);
      expect(FibonacciSpacing.xl, 55.0);
      expect(FibonacciSpacing.xxl, 89.0);
    });

    test('Media section flex ratios should follow golden ratio', () {
      final flexRatios = HomeLayoutSystem.getMediaSectionFlex();
      
      expect(flexRatios.length, 2);
      expect(flexRatios[0], 62); // 62% for music
      expect(flexRatios[1], 38); // 38% for radio
      expect(flexRatios[0] + flexRatios[1], 100);
    });
  });

  group('ResponsiveConstraints Tests', () {
    testWidgets('Should detect mobile screen correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(MaterialApp(home: Scaffold()));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveConstraints.isMobile(context), isTrue);
              expect(ResponsiveConstraints.isTablet(context), isFalse);
              expect(ResponsiveConstraints.isDesktop(context), isFalse);
              
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Should detect tablet screen correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(MaterialApp(home: Scaffold()));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveConstraints.isMobile(context), isFalse);
              expect(ResponsiveConstraints.isTablet(context), isTrue);
              expect(ResponsiveConstraints.isDesktop(context), isFalse);
              
              return Container();
            },
          ),
        ),
      );
    });
  });
}

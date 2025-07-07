// lib/core/theme/skeleton_loading_system.dart

import 'package:flutter/material.dart';
import 'package:dear_flutter/core/theme/home_layout_system.dart';

/// Phase 3: Advanced Skeleton Loading System
/// 
/// Provides sophisticated skeleton screens and loading states for enhanced UX
class SkeletonLoadingSystem {
  
  /// Skeleton configuration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 1200);
  static const Duration staggerDelay = Duration(milliseconds: 150);
  static const double shimmerOpacity = 0.6;
  
  /// Create skeleton for quote card
  static Widget quoteCardSkeleton({
    Color? baseColor,
    Color? highlightColor,
    bool isDarkMode = false,
  }) {
    final base = baseColor ?? (isDarkMode 
      ? Colors.grey.shade800 
      : Colors.grey.shade300);
    final highlight = highlightColor ?? (isDarkMode 
      ? Colors.grey.shade700 
      : Colors.grey.shade100);
    
    return Container(
      height: HomeLayoutSystem.quoteHeight,
      margin: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FibonacciSpacing.lg),
        color: base,
      ),
      child: Padding(
        padding: EdgeInsets.all(FibonacciSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon placeholder
            Row(
              children: [
                _shimmerBox(
                  width: 24,
                  height: 24,
                  baseColor: base,
                  highlightColor: highlight,
                ),
                SizedBox(width: FibonacciSpacing.sm),
                _shimmerBox(
                  width: 120,
                  height: 16,
                  baseColor: base,
                  highlightColor: highlight,
                ),
              ],
            ),
            
            SizedBox(height: FibonacciSpacing.md),
            
            // Quote text lines
            _shimmerBox(
              width: double.infinity,
              height: 20,
              baseColor: base,
              highlightColor: highlight,
            ),
            SizedBox(height: FibonacciSpacing.xs),
            _shimmerBox(
              width: double.infinity,
              height: 20,
              baseColor: base,
              highlightColor: highlight,
            ),
            SizedBox(height: FibonacciSpacing.xs),
            _shimmerBox(
              width: 200,
              height: 20,
              baseColor: base,
              highlightColor: highlight,
            ),
            
            const Spacer(),
            
            // Author line
            Row(
              children: [
                _shimmerBox(
                  width: 16,
                  height: 16,
                  baseColor: base,
                  highlightColor: highlight,
                ),
                SizedBox(width: FibonacciSpacing.xs),
                _shimmerBox(
                  width: 80,
                  height: 14,
                  baseColor: base,
                  highlightColor: highlight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Create skeleton for media section
  static Widget mediaCardSkeleton({
    Color? baseColor,
    Color? highlightColor,
    bool isDarkMode = false,
  }) {
    final base = baseColor ?? (isDarkMode 
      ? Colors.grey.shade800 
      : Colors.grey.shade300);
    final highlight = highlightColor ?? (isDarkMode 
      ? Colors.grey.shade700 
      : Colors.grey.shade100);
    
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FibonacciSpacing.lg),
        color: base,
      ),
      child: Padding(
        padding: EdgeInsets.all(FibonacciSpacing.md),
        child: Row(
          children: [
            // Album art placeholder
            _shimmerBox(
              width: 80,
              height: 80,
              borderRadius: FibonacciSpacing.sm,
              baseColor: base,
              highlightColor: highlight,
            ),
            
            SizedBox(width: FibonacciSpacing.md),
            
            // Content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _shimmerBox(
                    width: double.infinity,
                    height: 18,
                    baseColor: base,
                    highlightColor: highlight,
                  ),
                  SizedBox(height: FibonacciSpacing.xs),
                  
                  // Subtitle
                  _shimmerBox(
                    width: 150,
                    height: 14,
                    baseColor: base,
                    highlightColor: highlight,
                  ),
                  
                  const Spacer(),
                  
                  // Controls
                  Row(
                    children: [
                      _shimmerBox(
                        width: 32,
                        height: 32,
                        borderRadius: 16,
                        baseColor: base,
                        highlightColor: highlight,
                      ),
                      SizedBox(width: FibonacciSpacing.sm),
                      _shimmerBox(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                        baseColor: base,
                        highlightColor: highlight,
                      ),
                      SizedBox(width: FibonacciSpacing.sm),
                      _shimmerBox(
                        width: 32,
                        height: 32,
                        borderRadius: 16,
                        baseColor: base,
                        highlightColor: highlight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Progressive loading pattern
  static Widget progressiveLoader({
    required List<Widget> skeletons,
    Duration? staggerDelay,
    Duration? itemDuration,
  }) {
    return Column(
      children: List.generate(skeletons.length, (index) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: itemDuration ?? defaultAnimationDuration,
          child: Container(
            margin: EdgeInsets.only(
              top: index > 0 ? (staggerDelay ?? SkeletonLoadingSystem.staggerDelay).inMilliseconds / 1000 * index : 0,
            ),
            child: skeletons[index],
          ),
        );
      }),
    );
  }
  
  /// Smart loading state based on connection and content type
  static Widget smartLoadingState({
    required String contentType,
    String? loadingMessage,
    bool isSlowConnection = false,
    bool isDarkMode = false,
  }) {
    Widget skeleton;
    
    switch (contentType.toLowerCase()) {
      case 'quote':
        skeleton = quoteCardSkeleton(isDarkMode: isDarkMode);
        break;
      case 'media':
        skeleton = mediaCardSkeleton(isDarkMode: isDarkMode);
        break;
      default:
        skeleton = _genericSkeleton(isDarkMode: isDarkMode);
    }
    
    return Column(
      children: [
        skeleton,
        if (isSlowConnection) ...[
          SizedBox(height: FibonacciSpacing.md),
          _slowConnectionIndicator(
            message: loadingMessage ?? 'Loading $contentType...',
            isDarkMode: isDarkMode,
          ),
        ],
      ],
    );
  }
  
  /// Basic shimmer effect widget
  static Widget _shimmerBox({
    required double width,
    required double height,
    double? borderRadius,
    required Color baseColor,
    required Color highlightColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: defaultAnimationDuration,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.0),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * value, 0.0),
              end: Alignment(1.0 + 2.0 * value, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
  
  /// Generic skeleton for unknown content types
  static Widget _genericSkeleton({bool isDarkMode = false}) {
    final base = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100;
    
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FibonacciSpacing.md),
        color: base,
      ),
      child: Padding(
        padding: EdgeInsets.all(FibonacciSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(
              width: double.infinity,
              height: 16,
              baseColor: base,
              highlightColor: highlight,
            ),
            SizedBox(height: FibonacciSpacing.sm),
            _shimmerBox(
              width: 200,
              height: 14,
              baseColor: base,
              highlightColor: highlight,
            ),
            const Spacer(),
            _shimmerBox(
              width: 120,
              height: 12,
              baseColor: base,
              highlightColor: highlight,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Slow connection indicator
  static Widget _slowConnectionIndicator({
    required String message,
    bool isDarkMode = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      ),
      margin: EdgeInsets.symmetric(horizontal: FibonacciSpacing.md),
      decoration: BoxDecoration(
        color: (isDarkMode ? Colors.orange.shade900 : Colors.orange.shade100)
            .withOpacity(0.8),
        borderRadius: BorderRadius.circular(FibonacciSpacing.sm),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
              ),
            ),
          ),
          SizedBox(width: FibonacciSpacing.xs),
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

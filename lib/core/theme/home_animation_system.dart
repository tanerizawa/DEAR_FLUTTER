// lib/core/theme/home_animation_system.dart
// Enhanced Animation System - Phase 2 Implementation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced animation system with optimized performance and delightful micro-interactions
/// Implements Phase 2 Visual Design Enhancement
class HomeAnimationSystem {
  
  // MARK: - Animation Durations (Following Material Design 3)
  
  /// Ultra-fast micro-interactions (hover, touch feedback)
  static const Duration ultraFast = Duration(milliseconds: 100);
  
  /// Fast transitions (button states, small UI changes)
  static const Duration fast = Duration(milliseconds: 200);
  
  /// Standard transitions (card animations, page transitions)
  static const Duration standard = Duration(milliseconds: 300);
  
  /// Emphasized transitions (modal appears, important state changes)
  static const Duration emphasized = Duration(milliseconds: 500);
  
  /// Slow transitions (loading states, major layout changes)
  static const Duration slow = Duration(milliseconds: 700);
  
  // MARK: - Easing Curves (Material Design 3 Motion)
  
  /// Standard ease curve for most animations
  static const Curve standardEase = Curves.easeInOut;
  
  /// Emphasized ease for important transitions
  static const Curve emphasizedEase = Curves.fastOutSlowIn;
  
  /// Decelerated ease for entering content
  static const Curve deceleratedEase = Curves.fastOutSlowIn;
  
  /// Accelerated ease for exiting content
  static const Curve acceleratedEase = Curves.fastOutSlowIn;
  
  /// Bounce effect for delightful interactions
  static const Curve bounceEase = Curves.elasticOut;
  
  // MARK: - Quote Section Animations
  
  /// Animated quote card entrance
  static Widget animatedQuoteEntrance({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay.inMilliseconds / controller.duration!.inMilliseconds,
        1.0,
        curve: deceleratedEase,
      ),
    ));
    
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay.inMilliseconds / controller.duration!.inMilliseconds,
        1.0,
        curve: emphasizedEase,
      ),
    ));
    
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay.inMilliseconds / controller.duration!.inMilliseconds,
        1.0,
        curve: bounceEase,
      ),
    ));
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }
  
  /// Quote text reveal animation with typewriter effect
  static Widget animatedQuoteReveal({
    required String text,
    required AnimationController controller,
    TextStyle? textStyle,
    Duration delay = Duration.zero,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.value;
        final delayedProgress = ((progress * controller.duration!.inMilliseconds) - delay.inMilliseconds)
            / controller.duration!.inMilliseconds;
        final clampedProgress = delayedProgress.clamp(0.0, 1.0);
        
        final visibleCharacters = (text.length * clampedProgress).floor();
        final visibleText = text.substring(0, visibleCharacters);
        
        return TweenAnimationBuilder<double>(
          duration: ultraFast,
          tween: Tween(begin: 0.8, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Text(
                visibleText,
                style: textStyle,
              ),
            );
          },
        );
      },
    );
  }
  
  // MARK: - Interactive Animations
  
  /// Enhanced button press animation with haptic feedback
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    bool enableHapticFeedback = true,
    double scaleDownFactor = 0.95,
    Duration duration = fast,
  }) {
    return _AnimatedButtonState(
      child: child,
      onPressed: onPressed,
      enableHapticFeedback: enableHapticFeedback,
      scaleDownFactor: scaleDownFactor,
      duration: duration,
    );
  }
  
  /// Floating action button with enhanced animations
  static Widget animatedFAB({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    String? heroTag,
  }) {
    return _AnimatedFABState(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      heroTag: heroTag,
    );
  }
  
  // MARK: - Loading Animations
  
  /// Skeleton loading animation for quote cards
  static Widget skeletonQuoteCard({
    double? width,
    double? height,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _SkeletonLoaderState(
      width: width ?? double.infinity,
      height: height ?? 200,
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
    );
  }
  
  /// Pulsing dot animation for loading states
  static Widget pulsingDots({
    int dotCount = 3,
    Color? color,
    double size = 8.0,
  }) {
    return _PulsingDotsState(
      dotCount: dotCount,
      color: color ?? Colors.grey,
      size: size,
    );
  }
  
  // MARK: - Page Transition Animations
  
  /// Enhanced page route with custom transitions
  static PageRouteBuilder createPageRoute({
    required Widget page,
    RouteSettings? settings,
    TransitionType transitionType = TransitionType.slideFromRight,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: standard,
      reverseTransitionDuration: fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          transitionType: transitionType,
        );
      },
    );
  }
  
  /// Build different transition types
  static Widget _buildTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required TransitionType transitionType,
  }) {
    switch (transitionType) {
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: emphasizedEase,
          )),
          child: child,
        );
        
      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: emphasizedEase,
          )),
          child: child,
        );
        
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
        
      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: bounceEase,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
        
      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: emphasizedEase,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
  
  // MARK: - Performance Optimizations
  
  /// Create optimized animation controller with dispose management
  static AnimationController createOptimizedController({
    required TickerProvider vsync,
    Duration duration = standard,
    String? debugLabel,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
      debugLabel: debugLabel,
    );
  }
  
  /// Staggered animation helper for multiple elements
  static Animation<double> createStaggeredAnimation({
    required AnimationController parent,
    required int index,
    required int totalItems,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Curve curve = standardEase,
  }) {
    final startDelay = staggerDelay.inMilliseconds * index;
    final totalDuration = parent.duration!.inMilliseconds;
    final startInterval = startDelay / totalDuration;
    final endInterval = 1.0;
    
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(
        startInterval.clamp(0.0, 1.0),
        endInterval,
        curve: curve,
      ),
    ));
  }
}

// MARK: - Enums and Types

enum TransitionType {
  slideFromRight,
  slideFromBottom,
  fade,
  scale,
  rotation,
}

// MARK: - Private Stateful Widgets

class _AnimatedButtonState extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool enableHapticFeedback;
  final double scaleDownFactor;
  final Duration duration;
  
  const _AnimatedButtonState({
    required this.child,
    required this.onPressed,
    required this.enableHapticFeedback,
    required this.scaleDownFactor,
    required this.duration,
  });
  
  @override
  State<_AnimatedButtonState> createState() => __AnimatedButtonStateState();
}

class __AnimatedButtonStateState extends State<_AnimatedButtonState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: HomeAnimationSystem.acceleratedEase,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _AnimatedFABState extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;
  
  const _AnimatedFABState({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });
  
  @override
  State<_AnimatedFABState> createState() => __AnimatedFABStateState();
}

class __AnimatedFABStateState extends State<_AnimatedFABState>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: HomeAnimationSystem.emphasized,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: HomeAnimationSystem.fast,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 180 degrees
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: HomeAnimationSystem.bounceEase,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: HomeAnimationSystem.acceleratedEase,
    ));
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _onPressed() {
    _rotationController.forward().then((_) {
      _rotationController.reset();
    });
    
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: FloatingActionButton(
              heroTag: widget.heroTag,
              onPressed: _onPressed,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              child: Icon(widget.icon),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonLoaderState extends StatefulWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  
  const _SkeletonLoaderState({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
  });
  
  @override
  State<_SkeletonLoaderState> createState() => __SkeletonLoaderStateState();
}

class __SkeletonLoaderStateState extends State<_SkeletonLoaderState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class _PulsingDotsState extends StatefulWidget {
  final int dotCount;
  final Color color;
  final double size;
  
  const _PulsingDotsState({
    required this.dotCount,
    required this.color,
    required this.size,
  });
  
  @override
  State<_PulsingDotsState> createState() => __PulsingDotsStateState();
}

class __PulsingDotsStateState extends State<_PulsingDotsState>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) => 
      Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      ),
    ).toList();
    
    _startAnimations();
  }
  
  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_animations[index].value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

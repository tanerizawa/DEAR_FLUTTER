import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced Micro-Interactions System untuk Journal Tab
/// Menyediakan consistent animations dan haptic feedback
class JournalMicroInteractions {
  // === ANIMATION TIMINGS ===
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);
  
  // === ANIMATION CURVES ===
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeInOutBack;
  static const Curve smooth = Curves.easeInOutCubic;
  
  // === HAPTIC FEEDBACK METHODS ===
  
  /// Light tap untuk selections dan navigation
  static void lightTap() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium tap untuk important actions
  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy tap untuk confirmations dan completions
  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection click untuk mood selection
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
  
  /// Vibrate pattern untuk errors
  static void errorPattern() {
    HapticFeedback.vibrate();
  }
  
  // === ANIMATION BUILDERS ===
  
  /// Bounce animation untuk buttons dan interactive elements
  static Widget bounceOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = quick,
  }) {
    return _BounceAnimation(
      onTap: onTap,
      scale: scale,
      duration: duration,
      child: child,
    );
  }
  
  /// Scale animation untuk mood selections
  static Widget scaleOnSelect({
    required Widget child,
    required bool isSelected,
    double selectedScale = 1.1,
    Duration duration = normal,
  }) {
    return AnimatedScale(
      scale: isSelected ? selectedScale : 1.0,
      duration: duration,
      curve: bounce,
      child: child,
    );
  }
  
  /// Fade and slide animation untuk list items
  static Widget fadeSlideIn({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Offset beginOffset = const Offset(0, 20),
  }) {
    return _FadeSlideAnimation(
      delay: Duration(milliseconds: delay.inMilliseconds * index),
      beginOffset: beginOffset,
      child: child,
    );
  }
  
  /// Shimmer loading animation
  static Widget shimmerLoading({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return _ShimmerAnimation(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }
  
  /// Success check animation
  static Widget successCheck({
    double size = 64,
    Color color = Colors.green,
    Duration duration = slow,
  }) {
    return _SuccessCheckAnimation(
      size: size,
      color: color,
      duration: duration,
    );
  }
  
  /// Floating animation untuk FABs
  static Widget floatingPulse({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return _FloatingPulseAnimation(
      duration: duration,
      child: child,
    );
  }
  
  // === PAGE TRANSITIONS ===
  
  /// Slide transition untuk navigation
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    SlideDirection direction = SlideDirection.right,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case SlideDirection.up:
            begin = const Offset(0.0, 1.0);
            break;
          case SlideDirection.down:
            begin = const Offset(0.0, -1.0);
            break;
          case SlideDirection.left:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.right:
            begin = const Offset(1.0, 0.0);
            break;
        }
        
        const end = Offset.zero;
        final tween = Tween<Offset>(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: smooth),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  /// Fade scale transition untuk modals
  static PageRouteBuilder<T> fadeScaleTransition<T>({
    required Widget page,
    double beginScale = 0.8,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: beginScale,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: bounce,
        ));
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: enter,
        ));
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

enum SlideDirection { up, down, left, right }

// === PRIVATE ANIMATION WIDGETS ===

class _BounceAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  
  const _BounceAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
  });
  
  @override
  State<_BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<_BounceAnimation>
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
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: JournalMicroInteractions.bounce,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        JournalMicroInteractions.lightTap();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
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

class _FadeSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;
  
  const _FadeSlideAnimation({
    required this.child,
    required this.delay,
    required this.beginOffset,
  });
  
  @override
  State<_FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<_FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: JournalMicroInteractions.normal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: JournalMicroInteractions.enter,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: JournalMicroInteractions.smooth,
    ));
    
    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  
  const _ShimmerAnimation({
    required this.width,
    required this.height,
    required this.borderRadius,
  });
  
  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
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
      curve: Curves.linear,
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
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF3A3A3C),
                Color(0xFF48484A),
                Color(0xFF3A3A3C),
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuccessCheckAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  
  const _SuccessCheckAnimation({
    required this.size,
    required this.color,
    required this.duration,
  });
  
  @override
  State<_SuccessCheckAnimation> createState() => _SuccessCheckAnimationState();
}

class _SuccessCheckAnimationState extends State<_SuccessCheckAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              painter: _CheckPainter(_checkAnimation.value),
            ),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  
  _CheckPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final center = size.center(Offset.zero);
    final checkSize = size.width * 0.3;
    
    // Check mark path
    path.moveTo(center.dx - checkSize * 0.5, center.dy);
    path.lineTo(center.dx - checkSize * 0.1, center.dy + checkSize * 0.3);
    path.lineTo(center.dx + checkSize * 0.5, center.dy - checkSize * 0.3);
    
    // Draw partial path based on progress
    final pathMetrics = path.computeMetrics();
    final totalLength = pathMetrics.fold<double>(0, (prev, metric) => prev + metric.length);
    final currentLength = totalLength * progress;
    
    double currentPos = 0;
    for (final metric in pathMetrics) {
      if (currentPos + metric.length <= currentLength) {
        canvas.drawPath(metric.extractPath(0, metric.length), paint);
        currentPos += metric.length;
      } else {
        final remaining = currentLength - currentPos;
        if (remaining > 0) {
          canvas.drawPath(metric.extractPath(0, remaining), paint);
        }
        break;
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloatingPulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const _FloatingPulseAnimation({
    required this.child,
    required this.duration,
  });
  
  @override
  State<_FloatingPulseAnimation> createState() => _FloatingPulseAnimationState();
}

class _FloatingPulseAnimationState extends State<_FloatingPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

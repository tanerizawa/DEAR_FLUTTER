import 'package:flutter/material.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/theme/journal_theme.dart';
import 'dart:math';

/// Widget untuk thread/benang yang menghubungkan sticky notes dalam timeline
class TimelineThread extends StatefulWidget {
  final double height;
  final double width;
  final JournalEntry journal;
  final JournalEntry? nextJournal;
  final bool isAnimated;
  final bool moodTransition;

  const TimelineThread({
    super.key,
    required this.height,
    required this.width,
    required this.journal,
    this.nextJournal,
    this.isAnimated = false,
    this.moodTransition = false,
  });

  @override
  State<TimelineThread> createState() => _TimelineThreadState();
}

class _TimelineThreadState extends State<TimelineThread>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.isAnimated) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      // Start animation with slight delay for staggered effect
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnimated) {
      return AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: TimelineThreadPainter(
              journal: widget.journal,
              nextJournal: widget.nextJournal,
              progress: _progressAnimation.value,
              moodTransition: widget.moodTransition,
            ),
          );
        },
      );
    }
    
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: TimelineThreadPainter(
        journal: widget.journal,
        nextJournal: widget.nextJournal,
        progress: 1.0,
        moodTransition: widget.moodTransition,
      ),
    );
  }
}

/// Custom painter untuk menggambar thread/benang timeline
class TimelineThreadPainter extends CustomPainter {
  final JournalEntry journal;
  final JournalEntry? nextJournal;
  final double progress;
  final bool moodTransition;

  TimelineThreadPainter({
    required this.journal,
    this.nextJournal,
    required this.progress,
    this.moodTransition = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final currentMoodColor = JournalTheme.getMoodColor(journal.mood);
    final nextMoodColor = nextJournal != null 
        ? JournalTheme.getMoodColor(nextJournal!.mood)
        : currentMoodColor;

    // Main thread line
    _drawMainThread(canvas, size, currentMoodColor, nextMoodColor);
    
    // Decorative elements
    _drawThreadTexture(canvas, size, currentMoodColor);
    
    // Mood transition effect
    if (moodTransition && nextJournal != null) {
      _drawMoodTransition(canvas, size, currentMoodColor, nextMoodColor);
    }
    
    // Emotional intensity markers
    _drawEmotionalMarkers(canvas, size, currentMoodColor);
  }

  void _drawMainThread(Canvas canvas, Size size, Color startColor, Color endColor) {
    final paint = Paint()
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (moodTransition && nextJournal != null) {
      // Gradient thread untuk mood transition
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          startColor.withOpacity(0.8),
          startColor.withOpacity(0.6),
          endColor.withOpacity(0.6),
          endColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = startColor.withOpacity(0.7);
    }

    final path = Path();
    path.moveTo(size.width / 2, 0);
    
    // Animated line drawing
    final endY = size.height * progress;
    
    // Slight curve untuk natural look
    final controlX = size.width / 2 + sin(progress * pi) * 2;
    final controlY = endY / 2;
    
    path.quadraticBezierTo(controlX, controlY, size.width / 2, endY);
    
    canvas.drawPath(path, paint);
  }

  void _drawThreadTexture(Canvas canvas, Size size, Color baseColor) {
    final paint = Paint()
      ..color = baseColor.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw parallel lines untuk texture effect
    final numLines = 3;
    final spacing = size.width / (numLines + 1);
    
    for (int i = 1; i <= numLines; i++) {
      final x = spacing * i;
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x, size.height * progress);
      canvas.drawPath(path, paint);
    }
  }

  void _drawMoodTransition(Canvas canvas, Size size, Color startColor, Color endColor) {
    // Draw transition sparkles atau particles
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final transitionPoint = size.height * 0.6; // Where transition begins
    final numSparkles = 3;
    
    for (int i = 0; i < numSparkles; i++) {
      final sparkleY = transitionPoint + (i * 8);
      if (sparkleY > size.height * progress) continue;
      
      final sparkleX = size.width / 2 + sin(i * pi / 2) * 4;
      final sparkleSize = 2.0 - (i * 0.5);
      
      paint.color = Color.lerp(startColor, endColor, i / numSparkles)!.withOpacity(0.6);
      
      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        sparkleSize,
        paint,
      );
    }
  }

  void _drawEmotionalMarkers(Canvas canvas, Size size, Color moodColor) {
    // Draw markers berdasarkan intensitas emosi
    final emotionalIntensity = _getEmotionalIntensity(journal.mood);
    
    if (emotionalIntensity > 0.7) {
      // High intensity - draw pulsing markers
      final paint = Paint()
        ..color = moodColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      final markerY = size.height * 0.3;
      if (markerY <= size.height * progress) {
        canvas.drawCircle(
          Offset(size.width / 2, markerY),
          3.0,
          paint,
        );
      }
    }
  }

  double _getEmotionalIntensity(String mood) {
    final lowerMood = mood.toLowerCase();
    
    if (lowerMood.contains('sangat') || 
        lowerMood.contains('extremely') ||
        lowerMood.contains('overwhelming')) {
      return 1.0;
    } else if (lowerMood.contains('cukup') || 
               lowerMood.contains('moderately')) {
      return 0.7;
    } else if (lowerMood.contains('sedikit') || 
               lowerMood.contains('slightly')) {
      return 0.4;
    }
    
    return 0.5; // Default intensity
  }

  @override
  bool shouldRepaint(covariant TimelineThreadPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.journal != journal ||
           oldDelegate.nextJournal != nextJournal;
  }
}

/// Animated thread dengan effects tambahan
class AnimatedTimelineThread extends StatefulWidget {
  final double height;
  final double width;
  final JournalEntry journal;
  final JournalEntry? nextJournal;
  final Duration animationDuration;

  const AnimatedTimelineThread({
    super.key,
    required this.height,
    required this.width,
    required this.journal,
    this.nextJournal,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedTimelineThread> createState() => _AnimatedTimelineThreadState();
}

class _AnimatedTimelineThreadState extends State<AnimatedTimelineThread>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _pulseController;
  late Animation<double> _drawAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _drawController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _drawAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));
    
    // Start animations
    _drawController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_drawAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: AnimatedThreadPainter(
              journal: widget.journal,
              nextJournal: widget.nextJournal,
              drawProgress: _drawAnimation.value,
              pulseProgress: _pulseAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedThreadPainter extends CustomPainter {
  final JournalEntry journal;
  final JournalEntry? nextJournal;
  final double drawProgress;
  final double pulseProgress;

  AnimatedThreadPainter({
    required this.journal,
    this.nextJournal,
    required this.drawProgress,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final moodColor = JournalTheme.getMoodColor(journal.mood);
    
    // Main thread with pulsing effect
    final paint = Paint()
      ..color = moodColor.withOpacity(0.7 * pulseProgress)
      ..strokeWidth = size.width * pulseProgress
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height * drawProgress);
    
    canvas.drawPath(path, paint);
    
    // Energy particles
    _drawEnergyParticles(canvas, size, moodColor);
  }

  void _drawEnergyParticles(Canvas canvas, Size size, Color baseColor) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final numParticles = 5;
    for (int i = 0; i < numParticles; i++) {
      final particleY = (size.height * drawProgress) * (i / numParticles);
      final particleX = size.width / 2 + sin(drawProgress * pi * 2 + i) * 6;
      final particleSize = 1.5 * pulseProgress;
      
      paint.color = baseColor.withOpacity(0.4 * drawProgress);
      
      canvas.drawCircle(
        Offset(particleX, particleY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedThreadPainter oldDelegate) {
    return oldDelegate.drawProgress != drawProgress ||
           oldDelegate.pulseProgress != pulseProgress;
  }
}

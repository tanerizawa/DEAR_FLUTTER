// lib/presentation/home/widgets/smart_loading_section.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';

class SmartLoadingSection extends StatefulWidget {
  final String loadingText;
  final IconData icon;
  final Color? accentColor;
  
  const SmartLoadingSection({
    super.key,
    this.loadingText = 'Loading...',
    this.icon = Icons.music_note,
    this.accentColor,
  });

  @override
  State<SmartLoadingSection> createState() => _SmartLoadingSectionState();
}

class _SmartLoadingSectionState extends State<SmartLoadingSection> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _bounceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? const Color(0xFF1DB954);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF232526), 
              accentColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: accentColor.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon with pulse effect
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.2),
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -10 * _bounceAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withOpacity(0.15),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            size: 48,
                            color: accentColor,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Animated loading indicator
            SizedBox(
              width: 80,
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Loading text
            Text(
              widget.loadingText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SmartSkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SmartSkeletonCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MoodColorSystem.surfaceContainer,
      highlightColor: MoodColorSystem.surfaceVariant,
      child: Container(
        width: width,
        height: height ?? 80,
        decoration: BoxDecoration(
          color: MoodColorSystem.surfaceContainer,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class MusicSkeletonLoader extends StatelessWidget {
  const MusicSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF232526), 
            const Color(0xFF1DB954).withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Cover art skeleton
          SmartSkeletonCard(
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(60),
          ),
          
          const SizedBox(height: 16),
          
          // Title skeleton
          SmartSkeletonCard(
            width: 200,
            height: 20,
            borderRadius: BorderRadius.circular(10),
          ),
          
          const SizedBox(height: 8),
          
          // Artist skeleton
          SmartSkeletonCard(
            width: 150,
            height: 16,
            borderRadius: BorderRadius.circular(8),
          ),
          
          const SizedBox(height: 24),
          
          // Controls skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmartSkeletonCard(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(width: 20),
              SmartSkeletonCard(
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(28),
              ),
              const SizedBox(width: 20),
              SmartSkeletonCard(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

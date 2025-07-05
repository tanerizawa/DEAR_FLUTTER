import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tree_cubit.dart';
import '../models/tree_state.dart';
import 'dart:async';

class MindfulnessSection extends StatefulWidget {
  const MindfulnessSection({super.key});

  @override
  State<MindfulnessSection> createState() => _MindfulnessSectionState();
}

class _MindfulnessSectionState extends State<MindfulnessSection>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  Timer? _breathingTimer;
  bool _isBreathing = false;
  int _breathingSeconds = 0;
  String _breathingPhase = 'Inhale';

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _breathingTimer?.cancel();
    super.dispose();
  }

  void _startBreathingExercise() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBreathing = true;
      _breathingSeconds = 0;
      _breathingPhase = 'Inhale';
    });

    _breathingController.repeat(reverse: true);
    
    _breathingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _breathingSeconds += 4;
        _breathingPhase = _breathingPhase == 'Inhale' ? 'Exhale' : 'Inhale';
      });
    });
  }

  void _stopBreathingExercise() {
    HapticFeedback.lightImpact();
    
    // Award points if breathing exercise was done for at least 30 seconds
    if (_breathingSeconds >= 30) {
      final treeCubit = context.read<TreeCubit>();
      treeCubit.addActivity(TreeActivity.breathingExercise);
      
      // Show completion feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.eco, color: Colors.green),
              const SizedBox(width: 8),
              Text('Breathing exercise complete! Your tree earned ${TreeActivity.breathingExercise.points} points 🌿'),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.8),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    setState(() {
      _isBreathing = false;
    });
    _breathingController.stop();
    _breathingTimer?.cancel();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00CEC9).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00CEC9).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.spa,
                  color: Color(0xFF00CEC9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mindfulness',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Breathing exercises & meditation',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Breathing Exercise Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00CEC9).withOpacity(0.1),
                  const Color(0xFF74B9FF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Breathing Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isBreathing 
                      ? '$_breathingPhase - ${_formatTime(_breathingSeconds)}'
                      : '4-4-4-4 Breathing Pattern',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Breathing Animation Circle
                Center(
                  child: AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isBreathing ? _breathingAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00CEC9).withOpacity(0.8),
                                const Color(0xFF74B9FF).withOpacity(0.6),
                                const Color(0xFF6C5CE7).withOpacity(0.4),
                              ],
                            ),
                            boxShadow: _isBreathing
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00CEC9).withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Icon(
                            Icons.air,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Control Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isBreathing 
                        ? _stopBreathingExercise 
                        : _startBreathingExercise,
                    icon: Icon(
                      _isBreathing ? Icons.stop : Icons.play_arrow,
                      size: 20,
                    ),
                    label: Text(_isBreathing ? 'Stop Breathing' : 'Start Breathing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBreathing 
                          ? const Color(0xFFE17055)
                          : const Color(0xFF00CEC9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.self_improvement,
                  label: 'Meditation',
                  subtitle: '5-20 min',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to meditation sessions
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.bedtime,
                  label: 'Sleep Aid',
                  subtitle: 'Relaxation',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to sleep meditation
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00CEC9),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

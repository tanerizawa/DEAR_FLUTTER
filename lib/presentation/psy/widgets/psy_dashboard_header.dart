import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PsyDashboardHeader extends StatelessWidget {
  const PsyDashboardHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getWellnessMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'How are you feeling this morning?';
    if (hour < 17) return 'Take a moment to check in with yourself';
    return 'How has your day been emotionally?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3436),
            Color(0xFF636E72),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
              const Icon(
                Icons.self_improvement,
                color: Color(0xFF74B9FF),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWellnessMessage(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  icon: Icons.psychology,
                  label: 'Today\'s Mood',
                  value: 'Not Set',
                  color: const Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  icon: Icons.spa,
                  label: 'Mindfulness',
                  value: '0 min',
                  color: const Color(0xFF00CEC9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  icon: Icons.trending_up,
                  label: 'Progress',
                  value: '0%',
                  color: const Color(0xFF00B894),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // TODO: Navigate to mood check-in
              },
              icon: const Icon(Icons.mood, size: 20),
              label: const Text('Daily Mood Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74B9FF),
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
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tree_cubit.dart';
import '../models/tree_state.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B894).withOpacity(0.3),
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
                  color: const Color(0xFF00B894).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: Color(0xFF00B894),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mental Health Education',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Learn about psychology & mental wellness',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to full education library
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.library_books,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Featured Article
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00B894).withOpacity(0.1),
                  const Color(0xFF00CEC9).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: Color(0xFF00B894),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '5 min read',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Understanding Anxiety: Symptoms and Coping Strategies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn about different types of anxiety disorders and evidence-based techniques to manage anxiety symptoms in daily life.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: Navigate to article
                    },
                    icon: const Icon(Icons.article, size: 18),
                    label: const Text('Read Article'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Education Categories
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildEducationCategory(
                icon: Icons.mood,
                title: 'Depression',
                articleCount: '12 articles',
                color: const Color(0xFF74B9FF),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to depression articles
                },
              ),
              _buildEducationCategory(
                icon: Icons.favorite,
                title: 'Self-Care',
                articleCount: '8 articles',
                color: const Color(0xFFE17055),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to self-care articles
                },
              ),
              _buildEducationCategory(
                icon: Icons.group,
                title: 'Relationships',
                articleCount: '10 articles',
                color: const Color(0xFFFDCB6E),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to relationship articles
                },
              ),
              _buildEducationCategory(
                icon: Icons.work,
                title: 'Work Stress',
                articleCount: '6 articles',
                color: const Color(0xFF6C5CE7),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to work stress articles
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Resources
          Row(
            children: [
              Expanded(
                child: _buildQuickResource(
                  icon: Icons.quiz,
                  title: 'Take Quiz',
                  subtitle: 'Test knowledge',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to psychology quiz
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickResource(
                  icon: Icons.help_outline,
                  title: 'Myth Busters',
                  subtitle: 'Facts vs fiction',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to myth busting
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCategory({
    required IconData icon,
    required String title,
    required String articleCount,
    required Color color,
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
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              articleCount,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickResource({
    required IconData icon,
    required String title,
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
              color: const Color(0xFF00B894),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
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

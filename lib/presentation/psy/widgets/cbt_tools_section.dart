import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tree_cubit.dart';
import '../models/tree_state.dart';

class CBTToolsSection extends StatelessWidget {
  const CBTToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDCB6E).withOpacity(0.3),
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
                  color: const Color(0xFFFDCB6E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFFFDCB6E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CBT Tools',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cognitive behavioral therapy techniques',
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
                  // TODO: Navigate to CBT tools overview
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Featured Tool: Thought Record
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFDCB6E).withOpacity(0.1),
                  const Color(0xFFE17055).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit_note,
                      color: Color(0xFFFDCB6E),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Thought Record',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDCB6E).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          color: Color(0xFFFDCB6E),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Challenge negative thoughts and identify thinking patterns',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: Navigate to thought record
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDCB6E),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Thought Record',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // CBT Tools Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildCBTTool(
                icon: Icons.lightbulb_outline,
                title: 'Cognitive\nReframing',
                subtitle: 'Change perspective',
                color: const Color(0xFF74B9FF),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _handleCBTToolTap(context, 'Cognitive Reframing');
                },
              ),
              _buildCBTTool(
                icon: Icons.trending_up,
                title: 'Behavioral\nActivation',
                subtitle: 'Activity planning',
                color: const Color(0xFF00B894),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _handleCBTToolTap(context, 'Behavioral Activation');
                },
              ),
              _buildCBTTool(
                icon: Icons.quiz,
                title: 'Cognitive\nBias Check',
                subtitle: 'Identify distortions',
                color: const Color(0xFFE17055),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _handleCBTToolTap(context, 'Cognitive Bias Check');
                },
              ),
              _buildCBTTool(
                icon: Icons.format_list_bulleted,
                title: 'Exposure\nPlanning',
                subtitle: 'Face your fears',
                color: const Color(0xFF6C5CE7),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _handleCBTToolTap(context, 'Exposure Planning');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCBTTool({
    required IconData icon,
    required String title,
    required String subtitle,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleCBTToolTap(BuildContext context, String toolName) {
    // Add points to Tree of Life
    final treeCubit = context.read<TreeCubit>();
    treeCubit.addActivity(TreeActivity.cbtActivity);
    
    // Show completion feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.eco, color: Colors.green),
            const SizedBox(width: 8),
            Text('$toolName started! Your tree earned ${TreeActivity.cbtActivity.points} points 🌳'),
          ],
        ),
        backgroundColor: Colors.green.withOpacity(0.8),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // TODO: Navigate to specific CBT tool
  }
}

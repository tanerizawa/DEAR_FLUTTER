import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tree_cubit.dart';
import '../models/tree_state.dart';

class MoodAssessmentCard extends StatefulWidget {
  const MoodAssessmentCard({super.key});

  @override
  State<MoodAssessmentCard> createState() => _MoodAssessmentCardState();
}

class _MoodAssessmentCardState extends State<MoodAssessmentCard> {
  String? _selectedMood;
  final List<Map<String, dynamic>> _moods = [
    {'name': 'Very Happy', 'emoji': '😄', 'color': const Color(0xFF00B894)},
    {'name': 'Happy', 'emoji': '😊', 'color': const Color(0xFF00CEC9)},
    {'name': 'Neutral', 'emoji': '😐', 'color': const Color(0xFF74B9FF)},
    {'name': 'Sad', 'emoji': '😢', 'color': const Color(0xFFFDCB6E)},
    {'name': 'Very Sad', 'emoji': '😭', 'color': const Color(0xFFE17055)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.3),
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
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sentiment_satisfied,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood Assessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Track your emotional state',
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
                  // TODO: Navigate to detailed mood assessment
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'How are you feeling right now?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = _selectedMood == mood['name'];
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedMood = mood['name'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: index < _moods.length - 1 ? 12 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? mood['color'].withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? mood['color']
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood['emoji'],
                          style: TextStyle(
                            fontSize: isSelected ? 28 : 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['name'],
                          style: TextStyle(
                            color: isSelected 
                                ? mood['color']
                                : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedMood != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'You selected: $_selectedMood',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        
                        // Add points to Tree of Life
                        final treeCubit = context.read<TreeCubit>();
                        treeCubit.addActivity(TreeActivity.moodCheckIn);
                        
                        // Show completion feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.eco, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Mood check-in complete! Your tree earned ${TreeActivity.moodCheckIn.points} points 🌱'),
                              ],
                            ),
                            backgroundColor: Colors.green.withOpacity(0.8),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        
                        // Reset selection after completion
                        setState(() {
                          _selectedMood = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Complete Assessment',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

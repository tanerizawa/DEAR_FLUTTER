import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/tree_state.dart';
import '../cubit/tree_cubit.dart';
import 'tree_painter.dart';

class TreeOfLifeCard extends StatefulWidget {
  const TreeOfLifeCard({super.key});

  @override
  State<TreeOfLifeCard> createState() => _TreeOfLifeCardState();
}

class _TreeOfLifeCardState extends State<TreeOfLifeCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _growthController;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation for tree movement
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Growth celebration animation
    _growthController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _growthAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _growthController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _growthController.dispose();
    super.dispose();
  }

  void _onTreeTap(TreeState treeState) {
    HapticFeedback.lightImpact();
    _showTreeDetails(treeState);
  }

  void _showTreeDetails(TreeState treeState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTreeDetailsSheet(treeState),
    );
  }

  Widget _buildTreeDetailsSheet(TreeState treeState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Tree details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.park,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pohon Kehidupan Anda',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${treeState.stageDisplayName} - ${treeState.healthStatus}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Poin',
                        '${treeState.totalPoints}',
                        Icons.stars,
                        const Color(0xFFFFD700),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Kesehatan',
                        '${(treeState.health * 100).round()}%',
                        Icons.favorite,
                        const Color(0xFFE17055),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Streak Saat Ini',
                        '${treeState.currentStreak} hari',
                        Icons.local_fire_department,
                        const Color(0xFFFF6B35),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Streak Terbaik',
                        '${treeState.longestStreak} hari',
                        Icons.emoji_events,
                        const Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress to next stage
          if (treeState.stage != TreeStage.wise) ...[
            Text(
              'Progress ke ${_getNextStageName(treeState.stage)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: treeState.stageProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${treeState.pointsToNextStage} poin lagi',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Care actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Scroll to mood assessment
                  },
                  icon: const Icon(Icons.mood, size: 18),
                  label: const Text('Cek Mood'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Scroll to mindfulness section
                  },
                  icon: const Icon(Icons.spa, size: 18),
                  label: const Text('Meditasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CEC9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getNextStageName(TreeStage currentStage) {
    switch (currentStage) {
      case TreeStage.seed:
        return 'Tunas';
      case TreeStage.sprout:
        return 'Pohon Muda';
      case TreeStage.young:
        return 'Pohon Dewasa';
      case TreeStage.mature:
        return 'Pohon Bijak';
      case TreeStage.wise:
        return '';
    }
  }

  Color _getEnvironmentGradientStart(TreeState treeState) {
    if (treeState.health < 0.3) {
      return const Color(0xFF424242); // Gray for unhealthy
    }
    
    switch (treeState.stage) {
      case TreeStage.seed:
        return const Color(0xFF81C784);
      case TreeStage.sprout:
        return const Color(0xFF66BB6A);
      case TreeStage.young:
        return const Color(0xFF4CAF50);
      case TreeStage.mature:
        return const Color(0xFF2E7D32);
      case TreeStage.wise:
        return const Color(0xFF1B5E20);
    }
  }

  Color _getEnvironmentGradientEnd(TreeState treeState) {
    if (treeState.health < 0.3) {
      return const Color(0xFF616161); // Gray for unhealthy
    }
    
    switch (treeState.stage) {
      case TreeStage.seed:
        return const Color(0xFF4CAF50);
      case TreeStage.sprout:
        return const Color(0xFF388E3C);
      case TreeStage.young:
        return const Color(0xFF2E7D32);
      case TreeStage.mature:
        return const Color(0xFF1B5E20);
      case TreeStage.wise:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TreeCubit, TreeState>(
      listener: (context, state) {
        // Trigger growth animation on stage change
        if (state.hasRecentGrowth) {
          _growthController.forward().then((_) {
            _growthController.reverse();
          });
        }
      },
      builder: (context, treeState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getEnvironmentGradientStart(treeState),
                _getEnvironmentGradientEnd(treeState),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.park,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pohon Kehidupan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${treeState.stageDisplayName} - ${treeState.healthStatus}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (treeState.health < 0.4)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE17055).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Color(0xFFE17055),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Butuh Perhatian',
                            style: TextStyle(
                              color: Color(0xFFE17055),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Tree visualization
              AnimatedBuilder(
                animation: Listenable.merge([_animationController, _growthAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: treeState.hasRecentGrowth ? _growthAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: () => _onTreeTap(treeState),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: TreePainter(
                            stage: treeState.stage,
                            health: treeState.health,
                            animationValue: _animationController.value,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Quick stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${treeState.totalPoints}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Poin',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${treeState.currentStreak}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Hari Berturut',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${(treeState.health * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kesehatan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Care reminder or encouragement
              if (treeState.health < 0.4)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE17055).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Color(0xFFE17055),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pohon Anda butuh perhatian! Lakukan aktivitas mental health untuk memulihkannya.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          treeState.stage == TreeStage.wise
                              ? 'Selamat! Pohon Anda telah mencapai kebijaksanaan tertinggi!'
                              : 'Pohon Anda tumbuh subur! Terus lakukan aktivitas positif.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

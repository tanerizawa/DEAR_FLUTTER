import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/psy_dashboard_header.dart';
import '../widgets/mood_assessment_card.dart';
import '../widgets/mindfulness_section.dart';
import '../widgets/cbt_tools_section.dart';
import '../widgets/education_section.dart';
import '../widgets/progress_section.dart';
import '../widgets/crisis_resources_card.dart';
import '../widgets/tree_of_life_card.dart';
import '../cubit/tree_cubit.dart';

class PsyMainScreen extends StatefulWidget {
  const PsyMainScreen({super.key});

  @override
  State<PsyMainScreen> createState() => _PsyMainScreenState();
}

class _PsyMainScreenState extends State<PsyMainScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      HapticFeedback.lightImpact();
      
      // Simulate refresh delay for data loading
      await Future.delayed(const Duration(milliseconds: 800));
      
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Failed to refresh psy content: $e');
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: const Color(0xFF1E1E1E),
        color: const Color(0xFF6C5CE7),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6C5CE7),
                      Color(0xFF74B9FF),
                      Color(0xFF00CEC9),
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: const Text(
                    'Mental Wellness Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6C5CE7),
                          Color(0xFF74B9FF),
                          Color(0xFF00CEC9),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.psychology,
                        size: 40,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Header with daily check-in
                    const PsyDashboardHeader(),
                    
                    const SizedBox(height: 24),
                    
                    // Tree of Life Feature
                    BlocProvider(
                      create: (context) => TreeCubit(),
                      child: const TreeOfLifeCard(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Mood Assessment Card
                    const MoodAssessmentCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Mindfulness & Meditation Section
                    const MindfulnessSection(),
                    
                    const SizedBox(height: 24),
                    
                    // CBT Tools Section
                    const CBTToolsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Education Section
                    const EducationSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Progress & Analytics Section
                    const ProgressSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Crisis Resources Card (always accessible)
                    const CrisisResourcesCard(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

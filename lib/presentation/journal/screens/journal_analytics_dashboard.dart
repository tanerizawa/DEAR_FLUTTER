import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/theme/enhanced_journal_theme.dart';
import 'package:dear_flutter/presentation/journal/animations/journal_micro_interactions.dart';

/// Advanced Analytics Dashboard untuk Journal Tab
/// Menampilkan mood patterns, writing streaks, dan insights
class JournalAnalyticsDashboard extends StatefulWidget {
  final List<JournalEntry> journals;
  
  const JournalAnalyticsDashboard({
    super.key,
    required this.journals,
  });

  @override
  State<JournalAnalyticsDashboard> createState() => _JournalAnalyticsDashboardState();
}

class _JournalAnalyticsDashboardState extends State<JournalAnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedPeriod = 30; // Days
  bool _showDetailedView = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: JournalMicroInteractions.normal,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: JournalMicroInteractions.quick,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: JournalMicroInteractions.enter,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: JournalMicroInteractions.spring,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedJournalColors.backgroundPrimary,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildDashboard(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: EnhancedJournalColors.backgroundSecondary,
      elevation: 0,
      title: Text(
        'Analytics Jurnal',
        style: EnhancedJournalTypography.journalTitle(context),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: EnhancedJournalColors.textPrimary),
        onPressed: () {
          JournalMicroInteractions.lightTap();
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showDetailedView ? Icons.view_compact : Icons.view_module,
            color: EnhancedJournalColors.textSecondary,
          ),
          onPressed: () {
            JournalMicroInteractions.selectionClick();
            setState(() {
              _showDetailedView = !_showDetailedView;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    if (widget.journals.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(EnhancedJournalSpacing.lg(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          _buildOverviewCards(),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          _buildMoodChart(),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          _buildWritingStreakChart(),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          _buildInsights(),
          SizedBox(height: EnhancedJournalSpacing.xl(context)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: EnhancedJournalColors.textTertiary,
          ),
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          Text(
            'Belum Ada Data Analytics',
            style: EnhancedJournalTypography.journalTitle(context).copyWith(
              color: EnhancedJournalColors.textSecondary,
            ),
          ),
          SizedBox(height: EnhancedJournalSpacing.sm(context)),
          Text(
            'Mulai menulis jurnal untuk melihat\nanalisis mood dan pola menulis Anda',
            textAlign: TextAlign.center,
            style: EnhancedJournalTypography.bodyMediumStyle(context).copyWith(
              color: EnhancedJournalColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [7, 30, 90, 365];
    final labels = ['7 Hari', '30 Hari', '90 Hari', '1 Tahun'];

    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.xs(context)),
      decoration: BoxDecoration(
        color: EnhancedJournalColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = period == _selectedPeriod;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                JournalMicroInteractions.selectionClick();
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: EnhancedJournalSpacing.sm(context),
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? EnhancedJournalColors.accentPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
                    color: isSelected 
                        ? Colors.white
                        : EnhancedJournalColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final analytics = _calculateAnalytics();
    
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            title: 'Total Entri',
            value: analytics.totalEntries.toString(),
            icon: Icons.edit_note,
            color: EnhancedJournalColors.accentPrimary,
          ),
        ),
        SizedBox(width: EnhancedJournalSpacing.md(context)),
        Expanded(
          child: _buildOverviewCard(
            title: 'Streak',
            value: '${analytics.currentStreak} hari',
            icon: Icons.local_fire_department,
            color: EnhancedJournalColors.moodJoyful,
          ),
        ),
        SizedBox(width: EnhancedJournalSpacing.md(context)),
        Expanded(
          child: _buildOverviewCard(
            title: 'Mood Favorit',
            value: analytics.dominantMood,
            icon: Icons.mood,
            color: EnhancedJournalColors.getMoodColor(analytics.dominantMood),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.md(context)),
      decoration: BoxDecoration(
        color: EnhancedJournalColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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
                size: 20,
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          Text(
            value,
            style: EnhancedJournalTypography.analyticsValue(context),
          ),
          SizedBox(height: EnhancedJournalSpacing.xs(context)),
          Text(
            title,
            style: EnhancedJournalTypography.analyticsLabel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    final moodData = _getMoodDistribution();
    
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.lg(context)),
      decoration: BoxDecoration(
        color: EnhancedJournalColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Mood',
            style: EnhancedJournalTypography.journalTitle(context),
          ),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: moodData.entries.map((entry) {
                  final mood = entry.key;
                  final count = entry.value;
                  final total = moodData.values.reduce((a, b) => a + b);
                  final percentage = (count / total * 100).round();
                  
                  return PieChartSectionData(
                    value: count.toDouble(),
                    title: '$percentage%',
                    color: EnhancedJournalColors.getMoodColor(mood),
                    radius: 50,
                    titleStyle: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          _buildMoodLegend(moodData),
        ],
      ),
    );
  }

  Widget _buildMoodLegend(Map<String, int> moodData) {
    return Wrap(
      spacing: EnhancedJournalSpacing.sm(context),
      runSpacing: EnhancedJournalSpacing.xs(context),
      children: moodData.entries.map((entry) {
        final mood = entry.key;
        final count = entry.value;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: EnhancedJournalSpacing.sm(context),
            vertical: EnhancedJournalSpacing.xs(context),
          ),
          decoration: BoxDecoration(
            color: EnhancedJournalColors.getMoodColor(mood).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: EnhancedJournalColors.getMoodColor(mood).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: EnhancedJournalColors.getMoodColor(mood),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: EnhancedJournalSpacing.xs(context)),
              Text(
                '$mood ($count)',
                style: EnhancedJournalTypography.labelSmallStyle(context),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWritingStreakChart() {
    final streakData = _getWritingStreakData();
    
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.lg(context)),
      decoration: BoxDecoration(
        color: EnhancedJournalColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pola Menulis (${_selectedPeriod} Hari Terakhir)',
            style: EnhancedJournalTypography.journalTitle(context),
          ),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: EnhancedJournalColors.textTertiary.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: (_selectedPeriod / 7).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= streakData.length) return const SizedBox();
                        final date = DateTime.now().subtract(Duration(days: streakData.length - value.toInt() - 1));
                        return Text(
                          '${date.day}/${date.month}',
                          style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
                            color: EnhancedJournalColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0');
                        if (value == 1) return const Text('1');
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: streakData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: EnhancedJournalColors.accentPrimary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: EnhancedJournalColors.accentPrimary,
                          strokeWidth: 2,
                          strokeColor: EnhancedJournalColors.cardBackground,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: EnhancedJournalColors.accentPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    final analytics = _calculateAnalytics();
    
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.lg(context)),
      decoration: BoxDecoration(
        color: EnhancedJournalColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: EnhancedJournalColors.accentSecondary,
                size: 24,
              ),
              SizedBox(width: EnhancedJournalSpacing.sm(context)),
              Text(
                'Insights',
                style: EnhancedJournalTypography.journalTitle(context),
              ),
            ],
          ),
          SizedBox(height: EnhancedJournalSpacing.lg(context)),
          _buildInsightCard(
            title: 'Mood Dominan',
            description: 'Mood paling sering: ${analytics.dominantMood}',
            icon: Icons.trending_up,
            color: EnhancedJournalColors.getMoodColor(analytics.dominantMood),
          ),
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          _buildInsightCard(
            title: 'Konsistensi Menulis',
            description: analytics.currentStreak > 7 
                ? 'Hebat! Anda konsisten menulis ${analytics.currentStreak} hari berturut-turut'
                : 'Coba tingkatkan konsistensi menulis untuk streak yang lebih panjang',
            icon: Icons.emoji_events,
            color: analytics.currentStreak > 7 
                ? EnhancedJournalColors.success
                : EnhancedJournalColors.warning,
          ),
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          _buildInsightCard(
            title: 'Produktivitas',
            description: analytics.averageWordsPerEntry > 50
                ? 'Anda cenderung menulis dengan detail (${analytics.averageWordsPerEntry.round()} kata/entri)'
                : 'Coba ekspresikan lebih banyak dalam setiap entri jurnal',
            icon: Icons.create,
            color: EnhancedJournalColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.md(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(EnhancedJournalSpacing.sm(context)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: EnhancedJournalSpacing.md(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: EnhancedJournalTypography.bodyMediumStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: EnhancedJournalSpacing.xs(context)),
                Text(
                  description,
                  style: EnhancedJournalTypography.bodySmallStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === ANALYTICS CALCULATION METHODS ===

  JournalAnalytics _calculateAnalytics() {
    final filteredJournals = _getFilteredJournals();
    
    // Calculate streak
    int currentStreak = 0;
    DateTime currentDate = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = currentDate.subtract(Duration(days: i));
      final hasEntry = widget.journals.any((journal) => 
        journal.date.year == date.year &&
        journal.date.month == date.month &&
        journal.date.day == date.day
      );
      
      if (hasEntry) {
        currentStreak++;
      } else if (i > 0) { // Allow for today if no entry yet
        break;
      }
    }
    
    // Calculate dominant mood
    final moodCounts = <String, int>{};
    for (final journal in filteredJournals) {
      moodCounts[journal.mood] = (moodCounts[journal.mood] ?? 0) + 1;
    }
    
    String dominantMood = 'Netral';
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });
    
    // Calculate average words per entry
    double averageWords = 0;
    if (filteredJournals.isNotEmpty) {
      final totalWords = filteredJournals.fold<int>(0, (sum, journal) {
        return sum + journal.content.split(' ').length;
      });
      averageWords = totalWords / filteredJournals.length;
    }
    
    return JournalAnalytics(
      totalEntries: filteredJournals.length,
      currentStreak: currentStreak,
      dominantMood: dominantMood,
      averageWordsPerEntry: averageWords,
    );
  }

  Map<String, int> _getMoodDistribution() {
    final filteredJournals = _getFilteredJournals();
    final moodCounts = <String, int>{};
    
    for (final journal in filteredJournals) {
      moodCounts[journal.mood] = (moodCounts[journal.mood] ?? 0) + 1;
    }
    
    return moodCounts;
  }

  List<int> _getWritingStreakData() {
    final data = <int>[];
    final currentDate = DateTime.now();
    
    for (int i = _selectedPeriod - 1; i >= 0; i--) {
      final date = currentDate.subtract(Duration(days: i));
      final hasEntry = widget.journals.any((journal) => 
        journal.date.year == date.year &&
        journal.date.month == date.month &&
        journal.date.day == date.day
      );
      data.add(hasEntry ? 1 : 0);
    }
    
    return data;
  }

  List<JournalEntry> _getFilteredJournals() {
    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedPeriod));
    return widget.journals.where((journal) => journal.date.isAfter(cutoffDate)).toList();
  }
}

/// Data class untuk analytics
class JournalAnalytics {
  final int totalEntries;
  final int currentStreak;
  final String dominantMood;
  final double averageWordsPerEntry;

  const JournalAnalytics({
    required this.totalEntries,
    required this.currentStreak,
    required this.dominantMood,
    required this.averageWordsPerEntry,
  });
}

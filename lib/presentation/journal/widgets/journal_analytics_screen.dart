import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';

class JournalAnalytics {
  final Map<String, int> moodCounts;
  final List<MoodEntry> moodHistory;
  final int currentStreak;
  final int longestStreak;
  final int totalEntries;
  final double averageEntriesPerWeek;
  final String dominantMood;
  final List<String> insights;

  JournalAnalytics({
    required this.moodCounts,
    required this.moodHistory,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalEntries,
    required this.averageEntriesPerWeek,
    required this.dominantMood,
    required this.insights,
  });
}

class MoodEntry {
  final DateTime date;
  final String mood;
  final int moodScore;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.moodScore,
  });
}

class JournalAnalyticsScreen extends StatefulWidget {
  final List<JournalEntry> journals;

  const JournalAnalyticsScreen({
    super.key,
    required this.journals,
  });

  @override
  State<JournalAnalyticsScreen> createState() => _JournalAnalyticsScreenState();
}

class _JournalAnalyticsScreenState extends State<JournalAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late JournalAnalytics _analytics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _analytics = _calculateAnalytics(widget.journals);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  JournalAnalytics _calculateAnalytics(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return JournalAnalytics(
        moodCounts: {},
        moodHistory: [],
        currentStreak: 0,
        longestStreak: 0,
        totalEntries: 0,
        averageEntriesPerWeek: 0,
        dominantMood: 'Netral',
        insights: ['Mulai menulis jurnal untuk melihat analisis mood Anda!'],
      );
    }

    // Sort journals by date
    final sortedJournals = List<JournalEntry>.from(journals)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate mood counts
    final moodCounts = <String, int>{};
    final moodHistory = <MoodEntry>[];
    
    for (final journal in sortedJournals) {
      final moodLabel = journal.mood.split(' ').first;
      moodCounts[moodLabel] = (moodCounts[moodLabel] ?? 0) + 1;
      
      moodHistory.add(MoodEntry(
        date: journal.date,
        mood: moodLabel,
        moodScore: _getMoodScore(journal.mood),
      ));
    }

    // Calculate streaks
    final streaks = _calculateStreaks(sortedJournals);
    
    // Calculate average entries per week
    final firstEntry = sortedJournals.first.date;
    final lastEntry = sortedJournals.last.date;
    final weeksBetween = lastEntry.difference(firstEntry).inDays / 7;
    final averageEntriesPerWeek = weeksBetween > 0 ? journals.length / weeksBetween : journals.length.toDouble();

    // Find dominant mood
    final dominantMood = moodCounts.entries.isEmpty
        ? 'Netral'
        : moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Generate insights
    final insights = _generateInsights(journals, moodCounts, streaks, averageEntriesPerWeek);

    return JournalAnalytics(
      moodCounts: moodCounts,
      moodHistory: moodHistory,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      totalEntries: journals.length,
      averageEntriesPerWeek: averageEntriesPerWeek,
      dominantMood: dominantMood,
      insights: insights,
    );
  }

  Map<String, int> _calculateStreaks(List<JournalEntry> sortedJournals) {
    if (sortedJournals.isEmpty) return {'current': 0, 'longest': 0};

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final journal in sortedJournals.reversed) {
      final journalDate = DateTime(journal.date.year, journal.date.month, journal.date.day);
      
      if (lastDate == null) {
        // First entry
        if (journalDate.isAtSameMomentAs(today) || 
            journalDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
          currentStreak = 1;
          tempStreak = 1;
        } else {
          currentStreak = 0;
          tempStreak = 1;
        }
      } else {
        final daysDifference = lastDate.difference(journalDate).inDays;
        
        if (daysDifference == 1) {
          // Consecutive day
          tempStreak++;
          if (currentStreak > 0) currentStreak++;
        } else if (daysDifference == 0) {
          // Same day, don't break streak
          continue;
        } else {
          // Streak broken
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
          if (currentStreak > 0) currentStreak = 0;
        }
      }
      
      lastDate = journalDate;
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
    
    return {'current': currentStreak, 'longest': longestStreak};
  }

  int _getMoodScore(String mood) {
    if (mood.contains('Senang') || mood.contains('Bersyukur') || mood.contains('Bangga')) return 5;
    if (mood.contains('Netral')) return 3;
    if (mood.contains('Cemas') || mood.contains('Kecewa')) return 2;
    if (mood.contains('Sedih') || mood.contains('Marah') || mood.contains('Takut')) return 1;
    return 3; // default neutral
  }

  Color _getMoodColor(String mood) {
    if (mood.contains('Senang')) return const Color(0xFFFFD600);
    if (mood.contains('Sedih')) return const Color(0xFF64B5F6);
    if (mood.contains('Marah')) return const Color(0xFFE57373);
    if (mood.contains('Cemas')) return const Color(0xFFFFB300);
    if (mood.contains('Netral')) return const Color(0xFFB4B8C5);
    if (mood.contains('Bersyukur')) return const Color(0xFF81C784);
    if (mood.contains('Bangga')) return const Color(0xFFBA68C8);
    if (mood.contains('Takut')) return const Color(0xFF90A4AE);
    if (mood.contains('Kecewa')) return const Color(0xFF8D6E63);
    return const Color(0xFFB4B8C5);
  }

  List<String> _generateInsights(List<JournalEntry> journals, Map<String, int> moodCounts, 
      Map<String, int> streaks, double averageEntriesPerWeek) {
    final insights = <String>[];
    
    if (journals.length >= 7) {
      if (averageEntriesPerWeek >= 5) {
        insights.add('🌟 Konsistensi luar biasa! Anda menulis ${averageEntriesPerWeek.toStringAsFixed(1)} kali per minggu.');
      } else if (averageEntriesPerWeek >= 3) {
        insights.add('📝 Kebiasaan yang baik! Target 5 kali per minggu untuk hasil optimal.');
      } else {
        insights.add('💪 Coba tingkatkan frekuensi menulis untuk manfaat yang lebih besar.');
      }
    }

    if (streaks['current']! > 0) {
      insights.add('🔥 Streak saat ini: ${streaks['current']} hari! Pertahankan momentum ini.');
    }

    if (streaks['longest']! >= 7) {
      insights.add('🏆 Record terbaik: ${streaks['longest']} hari berturut-turut! Sangat menginspirasi.');
    }

    final positiveMoods = ['Senang', 'Bersyukur', 'Bangga'];
    final negativeMoods = ['Sedih', 'Marah', 'Takut', 'Kecewa'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final entry in moodCounts.entries) {
      if (positiveMoods.contains(entry.key)) {
        positiveCount += entry.value;
      } else if (negativeMoods.contains(entry.key)) {
        negativeCount += entry.value;
      }
    }

    final positivePercentage = (positiveCount / journals.length * 100).round();
    if (positivePercentage >= 70) {
      insights.add('😊 $positivePercentage% mood positif - kesehatan mental Anda sangat baik!');
    } else if (positivePercentage >= 50) {
      insights.add('🌈 $positivePercentage% mood positif - terus jaga keseimbangan emosi.');
    } else {
      insights.add('🌱 Fokus pada aktivitas yang membuat Anda bahagia untuk meningkatkan mood.');
    }

    // Weekly pattern analysis
    final recentEntries = journals.where((j) => 
        DateTime.now().difference(j.date).inDays <= 7).toList();
    if (recentEntries.length >= 3) {
      final recentAvgMood = recentEntries.map((j) => _getMoodScore(j.mood)).reduce((a, b) => a + b) / recentEntries.length;
      if (recentAvgMood >= 4) {
        insights.add('📈 Minggu ini mood Anda sangat baik! Apa rahasianya?');
      } else if (recentAvgMood <= 2) {
        insights.add('💙 Minggu ini terasa berat. Ingat, ini hanya sementara dan Anda kuat.');
      }
    }

    if (insights.isEmpty) {
      insights.add('📊 Terus menulis untuk mendapatkan insights personal yang lebih mendalam!');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF232526);
    const cardColor = Color(0xFF2C2F34);
    const accentColor = Color(0xFF1DB954);
    const textColor = Colors.white;
    const secondaryText = Color(0xFFB4B8C5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Analytics Jurnal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.insights), text: 'Ringkasan'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trend Mood'),
            Tab(icon: Icon(Icons.emoji_emotions), text: 'Distribusi'),
          ],
          indicatorColor: accentColor,
          labelColor: accentColor,
          unselectedLabelColor: secondaryText,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(bgColor, cardColor, accentColor, textColor, secondaryText),
          _buildTrendTab(bgColor, cardColor, accentColor, textColor, secondaryText),
          _buildDistributionTab(bgColor, cardColor, accentColor, textColor, secondaryText),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(Color bgColor, Color cardColor, Color accentColor, 
      Color textColor, Color secondaryText) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Streak Saat Ini',
                  '${_analytics.currentStreak}',
                  'hari berturut-turut',
                  Icons.local_fire_department,
                  Colors.orange,
                  cardColor,
                  textColor,
                  secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Record Terbaik',
                  '${_analytics.longestStreak}',
                  'hari berturut-turut',
                  Icons.emoji_events,
                  Colors.amber,
                  cardColor,
                  textColor,
                  secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total entries and frequency
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Jurnal',
                  '${_analytics.totalEntries}',
                  'entries',
                  Icons.book,
                  accentColor,
                  cardColor,
                  textColor,
                  secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Rata-rata',
                  '${_analytics.averageEntriesPerWeek.toStringAsFixed(1)}',
                  'per minggu',
                  Icons.calendar_today,
                  Colors.blue,
                  cardColor,
                  textColor,
                  secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Insights section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: accentColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Insights Personal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._analytics.insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dominant mood
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getMoodColor(_analytics.dominantMood).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getMoodEmoji(_analytics.dominantMood),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Dominan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _analytics.dominantMood,
                        style: TextStyle(
                          color: _getMoodColor(_analytics.dominantMood),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Paling sering muncul dalam jurnal',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTab(Color bgColor, Color cardColor, Color accentColor, 
      Color textColor, Color secondaryText) {
    if (_analytics.moodHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: secondaryText.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Belum ada data trend',
              style: TextStyle(color: secondaryText, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Tulis lebih banyak jurnal untuk melihat trend mood',
              style: TextStyle(color: secondaryText.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Prepare data for the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentHistory = _analytics.moodHistory
        .where((entry) => entry.date.isAfter(thirtyDaysAgo))
        .toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < recentHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), recentHistory[i].moodScore.toDouble()));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Mood (30 Hari Terakhir)',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: secondaryText.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        String label = '';
                        switch (value.toInt()) {
                          case 1:
                            label = 'Sedih';
                            break;
                          case 2:
                            label = 'Cemas';
                            break;
                          case 3:
                            label = 'Netral';
                            break;
                          case 4:
                            label = 'Senang';
                            break;
                          case 5:
                            label = 'Sangat\nSenang';
                            break;
                        }
                        return Text(
                          label,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: spots.length > 10 ? (spots.length / 5).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < recentHistory.length) {
                          final entry = recentHistory[value.toInt()];
                          return Text(
                            '${entry.date.day}/${entry.date.month}',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: secondaryText.withOpacity(0.2)),
                ),
                minX: 0,
                maxX: spots.isNotEmpty ? spots.length.toDouble() - 1 : 0,
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [accentColor.withOpacity(0.8), accentColor],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: accentColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.1),
                          accentColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionTab(Color bgColor, Color cardColor, Color accentColor, 
      Color textColor, Color secondaryText) {
    if (_analytics.moodCounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 64, color: secondaryText.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Belum ada data distribusi',
              style: TextStyle(color: secondaryText, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Tulis lebih banyak jurnal untuk melihat distribusi mood',
              style: TextStyle(color: secondaryText.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sections = _analytics.moodCounts.entries.map((entry) {
      final percentage = (entry.value / _analytics.totalEntries * 100);
      return PieChartSectionData(
        color: _getMoodColor(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Mood',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Mood legend
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Mood',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._analytics.moodCounts.entries.map((entry) {
                  final percentage = (entry.value / _analytics.totalEntries * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getMoodColor(entry.key),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getMoodEmoji(entry.key),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value}x',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: _getMoodColor(entry.key),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon,
      Color iconColor, Color cardColor, Color textColor, Color secondaryText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: secondaryText.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Senang':
        return '😊';
      case 'Sedih':
        return '😢';
      case 'Marah':
        return '😡';
      case 'Cemas':
        return '😰';
      case 'Netral':
        return '😐';
      case 'Bersyukur':
        return '🙏';
      case 'Bangga':
        return '😎';
      case 'Takut':
        return '😱';
      case 'Kecewa':
        return '😞';
      default:
        return '😐';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileAnalyticsWidget extends StatelessWidget {
  final Map<String, dynamic>? analyticsData;

  const ProfileAnalyticsWidget({
    super.key,
    this.analyticsData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Analitik Personal'),
        const SizedBox(height: 16),
        
        // Mood Distribution Card
        _buildAnalyticsCard(
          title: 'Distribusi Mood',
          icon: Icons.psychology_outlined,
          color: Color(0xFF4F46E5),
          child: _buildMoodDistribution(),
        ),
        
        const SizedBox(height: 16),
        
        // Weekly Progress Card
        _buildAnalyticsCard(
          title: 'Progress Mingguan',
          icon: Icons.trending_up_outlined,
          color: Color(0xFF1DB954),
          child: _buildWeeklyProgress(),
        ),
        
        const SizedBox(height: 16),
        
        // Achievement Progress Card
        _buildAnalyticsCard(
          title: 'Pencapaian',
          icon: Icons.emoji_events_outlined,
          color: Color(0xFFFF6B35),
          child: _buildAchievements(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Icon(
          Icons.analytics_outlined,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    const cardColor = Color(0xFF2C2F34);
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistribution() {
    final moodData = analyticsData?['moodDistribution'] as Map<String, dynamic>? ?? {
      'Senang': 35,
      'Netral': 25,
      'Sedih': 15,
      'Bersyukur': 20,
      'Cemas': 5,
    };

    final totalEntries = moodData.values.fold<num>(0, (sum, value) => sum + value);
    
    return Column(
      children: [
        // Mood bars
        ...moodData.entries.map((entry) {
          final mood = entry.key;
          final count = entry.value as num;
          final percentage = totalEntries > 0 ? (count / totalEntries) : 0.0;
          final color = _getMoodColor(mood);
          final emoji = _getMoodEmoji(mood);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(emoji, style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mood,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ],
            ),
          );
        }).toList(),
        
        const SizedBox(height: 8),
        
        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights,
                color: Color(0xFF4F46E5),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mood dominan: ${_getDominantMood(moodData)}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    final weeklyData = analyticsData?['weeklyProgress'] as List<dynamic>? ?? [3, 5, 2, 6, 4, 7, 3];
    final weeklyInts = weeklyData.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
    final maxEntries = weeklyInts.isNotEmpty ? weeklyInts.reduce((a, b) => a > b ? a : b) : 7;
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    
    return Column(
      children: [
        // Weekly chart
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final entries = weeklyInts.length > index ? weeklyInts[index] : 0;
            final height = maxEntries > 0 ? (entries / maxEntries) * 60 : 0.0;
            final isToday = index == DateTime.now().weekday - 1;
            
            return Column(
              children: [
                Container(
                  width: 24,
                  height: 60,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1DB954).withOpacity(0.7),
                          Color(0xFF1DB954),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isToday ? [
                        BoxShadow(
                          color: Color(0xFF1DB954).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  days[index],
                  style: TextStyle(
                    color: isToday ? Color(0xFF1DB954) : Colors.white60,
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entries.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            );
          }),
        ),
        
        const SizedBox(height: 16),
        
        // Weekly summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Color(0xFF1DB954),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Minggu ini: ${weeklyData.fold<num>(0, (sum, value) => sum + value)} entri',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final achievements = analyticsData?['achievements'] as List<dynamic>? ?? [
      {'name': 'Penulis Pemula', 'description': 'Tulis jurnal pertama', 'completed': true, 'icon': '✏️'},
      {'name': 'Konsisten 7 Hari', 'description': 'Jurnal 7 hari berturut-turut', 'completed': true, 'icon': '🔥'},
      {'name': 'Penjelajah Mood', 'description': 'Coba semua jenis mood', 'completed': false, 'icon': '🎭'},
      {'name': 'Refleksi Mendalam', 'description': 'Tulis 50 jurnal', 'completed': false, 'icon': '📚'},
    ];
    
    return Column(
      children: [
        ...achievements.take(3).map<Widget>((achievement) {
          final isCompleted = achievement['completed'] as bool;
          final name = achievement['name'] as String;
          final description = achievement['description'] as String;
          final icon = achievement['icon'] as String;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Show achievement details
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted 
                    ? Color(0xFFFF6B35).withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted 
                      ? Color(0xFFFF6B35).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted 
                          ? Color(0xFFFF6B35).withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: isCompleted ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        
        // View all achievements button
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to full achievements screen
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lihat Semua Pencapaian',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFFF6B35),
                size: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Senang': return const Color(0xFFFFD700);
      case 'Sedih': return const Color(0xFF64B5F6);
      case 'Marah': return const Color(0xFFE57373);
      case 'Cemas': return const Color(0xFFFFB74D);
      case 'Netral': return const Color(0xFFB4B8C5);
      case 'Bersyukur': return const Color(0xFF81C784);
      case 'Bangga': return const Color(0xFFBA68C8);
      case 'Takut': return const Color(0xFF90A4AE);
      case 'Kecewa': return const Color(0xFF8D6E63);
      default: return const Color(0xFFB4B8C5);
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Senang': return '😊';
      case 'Sedih': return '😢';
      case 'Marah': return '😡';
      case 'Cemas': return '😰';
      case 'Netral': return '😐';
      case 'Bersyukur': return '🙏';
      case 'Bangga': return '😎';
      case 'Takut': return '😱';
      case 'Kecewa': return '😞';
      default: return '😐';
    }
  }

  String _getDominantMood(Map<String, dynamic> moodData) {
    if (moodData.isEmpty) return 'Belum ada data';
    
    final sortedMoods = moodData.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    return sortedMoods.first.key;
  }
}

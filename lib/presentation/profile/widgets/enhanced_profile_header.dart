import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/domain/entities/user.dart';

class EnhancedProfileHeader extends StatelessWidget {
  final User user;
  final Map<String, dynamic>? stats;
  final String? currentMood;

  const EnhancedProfileHeader({
    super.key,
    required this.user,
    this.stats,
    this.currentMood,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF232526);
    const cardColor = Color(0xFF2C2F34);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar and Basic Info
            Row(
              children: [
                _buildProfileAvatar(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (currentMood != null) ...[
              const SizedBox(height: 20),
              _buildCurrentMoodIndicator(),
            ],
            
            const SizedBox(height: 24),
            
            // Quick Stats
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final avatarColor = _getMoodBasedColor();
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Add avatar customization
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              avatarColor.withOpacity(0.8),
              avatarColor.withOpacity(0.6),
            ],
          ),
          border: Border.all(
            color: avatarColor.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: avatarColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCurrentMoodIndicator() {
    final moodColor = _getMoodBasedColor();
    final moodEmoji = _getCurrentMoodEmoji();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.1),
        border: Border.all(color: moodColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            moodEmoji,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            'Mood saat ini: ${_getCurrentMoodLabel()}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalEntries = stats?['totalEntries'] ?? 0;
    final currentStreak = stats?['currentStreak'] ?? 0;
    final totalDays = stats?['totalDays'] ?? 0;
    final favoriteEmoji = stats?['favoriteEmoji'] ?? '😊';

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.book_outlined,
            label: 'Entri',
            value: totalEntries.toString(),
            color: Color(0xFF1DB954),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            icon: Icons.local_fire_department_outlined,
            label: 'Streak',
            value: '$currentStreak hari',
            color: Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            icon: Icons.calendar_today_outlined,
            label: 'Aktif',
            value: '$totalDays hari',
            color: Color(0xFF4F46E5),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            icon: null,
            label: 'Mood',
            value: favoriteEmoji,
            color: Color(0xFFEC4899),
            isEmoji: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    IconData? icon,
    required String label,
    required String value,
    required Color color,
    bool isEmoji = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (isEmoji)
            Text(
              value,
              style: TextStyle(fontSize: 24),
            )
          else
            Icon(
              icon,
              color: color,
              size: 24,
            ),
          const SizedBox(height: 8),
          Text(
            isEmoji ? label : value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isEmoji ? 12 : 16,
              fontWeight: isEmoji ? FontWeight.normal : FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          if (!isEmoji) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi!';
    } else if (hour < 17) {
      return 'Selamat Siang!';
    } else if (hour < 20) {
      return 'Selamat Sore!';
    } else {
      return 'Selamat Malam!';
    }
  }

  Color _getMoodBasedColor() {
    if (currentMood == null) return const Color(0xFF1DB954);
    
    if (currentMood!.contains('Senang')) return const Color(0xFFFFD700);
    if (currentMood!.contains('Sedih')) return const Color(0xFF64B5F6);
    if (currentMood!.contains('Marah')) return const Color(0xFFE57373);
    if (currentMood!.contains('Cemas')) return const Color(0xFFFFB74D);
    if (currentMood!.contains('Netral')) return const Color(0xFFB4B8C5);
    if (currentMood!.contains('Bersyukur')) return const Color(0xFF81C784);
    if (currentMood!.contains('Bangga')) return const Color(0xFFBA68C8);
    if (currentMood!.contains('Takut')) return const Color(0xFF90A4AE);
    if (currentMood!.contains('Kecewa')) return const Color(0xFF8D6E63);
    
    return const Color(0xFF1DB954);
  }

  String _getCurrentMoodEmoji() {
    if (currentMood == null) return '😊';
    return currentMood!.split(' ').last;
  }

  String _getCurrentMoodLabel() {
    if (currentMood == null) return 'Belum diset';
    return currentMood!.split(' ').first;
  }
}

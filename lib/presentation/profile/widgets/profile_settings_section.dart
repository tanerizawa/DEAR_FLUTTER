import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileSettingsSection extends StatelessWidget {
  final Function()? onLogout;
  final Function()? onDeleteAccount;
  final Function()? onDebugPanel;
  final bool showDebugPanel;

  const ProfileSettingsSection({
    super.key,
    this.onLogout,
    this.onDeleteAccount,
    this.onDebugPanel,
    this.showDebugPanel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Pengaturan'),
        const SizedBox(height: 16),
        
        // Settings Categories
        _buildSettingsCard(
          title: 'Personalisasi',
          icon: Icons.palette_outlined,
          color: Color(0xFF4F46E5),
          items: [
            _buildSettingsItem(
              icon: Icons.dark_mode_outlined,
              title: 'Tema Aplikasi',
              subtitle: 'Mode gelap aktif',
              onTap: () => _showThemeSettings(context),
            ),
            _buildSettingsItem(
              icon: Icons.color_lens_outlined,
              title: 'Warna Aksen',
              subtitle: 'Kustomisasi warna',
              onTap: () => _showColorPicker(context),
            ),
            _buildSettingsItem(
              icon: Icons.text_fields_outlined,
              title: 'Ukuran Font',
              subtitle: 'Medium',
              onTap: () => _showFontSettings(context),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildSettingsCard(
          title: 'Notifikasi',
          icon: Icons.notifications_outlined,
          color: Color(0xFF1DB954),
          items: [
            _buildSettingsItem(
              icon: Icons.schedule_outlined,
              title: 'Pengingat Jurnal',
              subtitle: 'Setiap hari 20:00',
              onTap: () => _showReminderSettings(context),
            ),
            _buildSettingsItem(
              icon: Icons.auto_awesome_outlined,
              title: 'Quote Harian',
              subtitle: 'Aktif',
              onTap: () => _showQuoteSettings(context),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Color(0xFF1DB954),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildSettingsCard(
          title: 'Data & Privasi',
          icon: Icons.security_outlined,
          color: Color(0xFFFF6B35),
          items: [
            _buildSettingsItem(
              icon: Icons.download_outlined,
              title: 'Ekspor Data',
              subtitle: 'Unduh semua jurnal',
              onTap: () => _showExportOptions(context),
            ),
            _buildSettingsItem(
              icon: Icons.backup_outlined,
              title: 'Backup Otomatis',
              subtitle: 'Tidak aktif',
              onTap: () => _showBackupSettings(context),
            ),
            _buildSettingsItem(
              icon: Icons.analytics_outlined,
              title: 'Analitik',
              subtitle: 'Izinkan pengumpulan data',
              onTap: () => _showAnalyticsSettings(context),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildSettingsCard(
          title: 'Tentang',
          icon: Icons.info_outlined,
          color: Color(0xFFEC4899),
          items: [
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Bantuan & FAQ',
              subtitle: 'Panduan penggunaan',
              onTap: () => _showHelp(context),
            ),
            _buildSettingsItem(
              icon: Icons.feedback_outlined,
              title: 'Kirim Feedback',
              subtitle: 'Bantu kami berkembang',
              onTap: () => _showFeedback(context),
            ),
            _buildSettingsItem(
              icon: Icons.info_outlined,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi 1.0.0',
              onTap: () => _showAbout(context),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        if (showDebugPanel) ...[
          _buildActionButton(
            icon: Icons.bug_report,
            title: 'Debug Panel',
            color: Colors.orange.shade600,
            backgroundColor: Colors.orange.shade100,
            onTap: onDebugPanel,
          ),
          const SizedBox(height: 12),
        ],
        
        _buildActionButton(
          icon: Icons.logout,
          title: 'Logout',
          color: Colors.red.shade700,
          backgroundColor: Colors.red.shade50,
          onTap: onLogout,
        ),
        
        const SizedBox(height: 12),
        
        _buildActionButton(
          icon: Icons.delete_forever,
          title: 'Hapus Akun',
          color: Colors.red.shade900,
          backgroundColor: Colors.red.shade100,
          isDestructive: true,
          onTap: () => _showDeleteConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Icon(
          Icons.settings_outlined,
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

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
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
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.4),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isDestructive ? Border.all(
            color: color.withOpacity(0.3),
          ) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Methods
  void _showThemeSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Pengaturan Tema');
  }

  void _showColorPicker(BuildContext context) {
    _showComingSoonDialog(context, 'Pemilih Warna');
  }

  void _showFontSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Pengaturan Font');
  }

  void _showReminderSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Pengaturan Pengingat');
  }

  void _showQuoteSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Pengaturan Quote');
  }

  void _showExportOptions(BuildContext context) {
    _showComingSoonDialog(context, 'Ekspor Data');
  }

  void _showBackupSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Pengaturan Backup');
  }

  void _showAnalyticsSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Pengaturan Analitik');
  }

  void _showHelp(BuildContext context) {
    _showComingSoonDialog(context, 'Bantuan');
  }

  void _showFeedback(BuildContext context) {
    _showComingSoonDialog(context, 'Feedback');
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2C2F34),
        title: Text(
          'Tentang Dear Flutter',
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi: 1.0.0',
              style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 8),
            Text(
              'Dear Flutter adalah aplikasi jurnal digital yang membantu Anda mencatat perjalanan emosi dan refleksi harian.',
              style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF1DB954), fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2C2F34),
        title: Text(
          'Hapus Akun',
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus akun?',
              style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 8),
            Text(
              '⚠️ Tindakan ini tidak dapat dibatalkan dan akan menghapus semua data Anda secara permanen.',
              style: TextStyle(color: Colors.red.shade300, fontFamily: 'Montserrat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteAccount?.call();
            },
            child: Text(
              'Hapus Akun',
              style: TextStyle(color: Colors.red.shade400, fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2C2F34),
        title: Text(
          feature,
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        content: Text(
          'Fitur ini akan segera hadir dalam update mendatang!',
          style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Color(0xFF1DB954), fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }
}

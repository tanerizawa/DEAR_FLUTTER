import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_cubit.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_state.dart';
import 'package:dear_flutter/presentation/profile/widgets/enhanced_profile_header.dart';
import 'package:dear_flutter/presentation/profile/widgets/profile_analytics_widget.dart';
import 'package:dear_flutter/presentation/profile/widgets/profile_settings_section.dart';
import 'package:dear_flutter/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>(),
      child: Scaffold(
        backgroundColor: Color(0xFF232526),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.failure) {
              _showErrorSnackBar(context, state.errorMessage ?? 'Gagal memuat profil');
            }
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return _buildLoadingState();
            }
            
            if (state.status == ProfileStatus.failure) {
              return _buildErrorState(context, state.errorMessage);
            }
            
            if (state.user == null) {
              return _buildEmptyState();
            }

            return _buildSuccessState(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(isLoading: true),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat profil...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal Memuat Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<ProfileCubit>().fetchUserProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.refresh),
                    label: Text(
                      'Coba Lagi',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Colors.white60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Data Pengguna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan login kembali untuk melanjutkan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, ProfileState state) {
    final user = state.user!;
    
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Enhanced Profile Header
              EnhancedProfileHeader(
                user: user,
                stats: state.userStats,
                currentMood: state.currentMood,
              ),
              
              const SizedBox(height: 32),
              
              // Analytics Section
              ProfileAnalyticsWidget(
                analyticsData: state.analyticsData,
              ),
              
              const SizedBox(height: 32),
              
              // Settings Section
              ProfileSettingsSection(
                showDebugPanel: AppConfig.enableDebugEndpoints,
                onDebugPanel: () => context.push('/debug'),
                onLogout: () => _handleLogout(context),
                onDeleteAccount: () => _handleDeleteAccount(context),
              ),
              
              const SizedBox(height: 40),
              
              // Footer
              _buildFooter(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar({bool isLoading = false}) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF232526),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF232526),
                Color(0xFF2C2F34),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (!isLoading)
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<ProfileCubit>().fetchUserProfile();
            },
            tooltip: 'Refresh Data',
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: Color(0xFF1DB954),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Terima kasih telah menjadi bagian dari perjalanan ini! 💚',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Dear Flutter v1.0.0',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await _showLogoutConfirmation(context);
    if (shouldLogout == true) {
      await context.read<ProfileCubit>().logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  void _handleDeleteAccount(BuildContext context) async {
    await context.read<ProfileCubit>().deleteAccount();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2C2F34),
        title: Text(
          'Konfirmasi Logout',
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: TextStyle(color: Color(0xFF1DB954), fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
  }
}

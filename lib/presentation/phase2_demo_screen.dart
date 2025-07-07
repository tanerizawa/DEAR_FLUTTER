// 🎯 Phase 2 Advanced Systems Demo
// Demonstrasi integrasi Adaptive Brightness, Responsive Layout, dan Motion Design
// DEAR Flutter - Modern Theme UI/UX Phase 2

import 'package:flutter/material.dart';
import '../core/theme/responsive_layout_system.dart';
import '../core/theme/motion_design_system.dart';

class Phase2DemoScreen extends StatefulWidget {
  const Phase2DemoScreen({super.key});

  @override
  State<Phase2DemoScreen> createState() => _Phase2DemoScreenState();
}

class _Phase2DemoScreenState extends State<Phase2DemoScreen> {
  bool _isDarkMode = false;
  bool _isCardExpanded = false;
  String _currentMood = 'calm';
  
  final List<String> _availableMoods = [
    'calm', 'energetic', 'focus', 'creative', 'peaceful'
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, config) {
        final spacing = ResponsiveLayoutSystem.getSpacing(context);
        final fontSizes = ResponsiveLayoutSystem.getFontSizes(context);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Phase 2 Advanced Systems Demo',
              style: TextStyle(fontSize: fontSizes.titleLarge),
            ),
            actions: [
              _buildBrightnessToggle(),
              const SizedBox(width: 8),
            ],
          ),
          body: ResponsiveLayout(
            mobile: _buildMobileLayout(spacing, fontSizes, config),
            tablet: _buildTabletLayout(spacing, fontSizes, config),
            desktop: _buildDesktopLayout(spacing, fontSizes, config),
            fallback: _buildMobileLayout(spacing, fontSizes, config),
          ),
          floatingActionButton: MotionDesignSystem.createPressableButton(
            onPressed: _showMotionDemo,
            child: FloatingActionButton(
              onPressed: null, // Handled by PressableButton
              child: const Icon(Icons.play_arrow),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes, ResponsiveConfig config) {
    return SingleChildScrollView(
      padding: ResponsiveLayoutSystem.getSafeAreaAwarePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSystemStatusCard(spacing, fontSizes),
          SizedBox(height: spacing.lg),
          _buildMoodSelectorCard(spacing, fontSizes),
          SizedBox(height: spacing.lg),
          _buildResponsiveInfoCard(spacing, fontSizes, config),
          SizedBox(height: spacing.lg),
          _buildMotionDemoCard(spacing, fontSizes),
          SizedBox(height: spacing.lg),
          _buildAdvancedFeaturesCard(spacing, fontSizes),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes, ResponsiveConfig config) {
    final columns = ResponsiveLayoutSystem.getOptimalColumns(context, minItemWidth: 300);
    
    return SingleChildScrollView(
      padding: ResponsiveLayoutSystem.getSafeAreaAwarePadding(context),
      child: Column(
        children: [
          _buildSystemStatusCard(spacing, fontSizes),
          SizedBox(height: spacing.lg),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: spacing.md,
            crossAxisSpacing: spacing.md,
            children: [
              _buildMoodSelectorCard(spacing, fontSizes),
              _buildResponsiveInfoCard(spacing, fontSizes, config),
              _buildMotionDemoCard(spacing, fontSizes),
              _buildAdvancedFeaturesCard(spacing, fontSizes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes, ResponsiveConfig config) {
    final contentWidth = ResponsiveLayoutSystem.getOptimalContentWidth(context);
    
    return Center(
      child: SizedBox(
        width: contentWidth,
        child: SingleChildScrollView(
          padding: ResponsiveLayoutSystem.getContentPadding(context),
          child: Column(
            children: [
              _buildSystemStatusCard(spacing, fontSizes),
              SizedBox(height: spacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildMoodSelectorCard(spacing, fontSizes)),
                  SizedBox(width: spacing.lg),
                  Expanded(child: _buildResponsiveInfoCard(spacing, fontSizes, config)),
                ],
              ),
              SizedBox(height: spacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildMotionDemoCard(spacing, fontSizes)),
                  SizedBox(width: spacing.lg),
                  Expanded(child: _buildAdvancedFeaturesCard(spacing, fontSizes)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚀 Phase 2 Systems Status',
              style: TextStyle(
                fontSize: fontSizes.headlineSmall,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing.md),
            _buildStatusItem('Adaptive Brightness System', true, spacing, fontSizes),
            _buildStatusItem('Responsive Layout System', true, spacing, fontSizes),
            _buildStatusItem('Motion Design System', true, spacing, fontSizes),
            _buildStatusItem('Unified Theme Integration', true, spacing, fontSizes),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isActive, ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.error,
            color: isActive ? Colors.green : Colors.red,
            size: fontSizes.bodyMedium,
          ),
          SizedBox(width: spacing.sm),
          Text(
            title,
            style: TextStyle(fontSize: fontSizes.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelectorCard(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎨 Mood-Adaptive Theme',
              style: TextStyle(
                fontSize: fontSizes.titleMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Current Mood: $_currentMood',
              style: TextStyle(fontSize: fontSizes.bodyMedium),
            ),
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.sm,
              children: _availableMoods.map((mood) {
                return MotionDesignSystem.createPressableButton(
                  onPressed: () => _changeMood(mood),
                  child: Chip(
                    label: Text(mood),
                    backgroundColor: _currentMood == mood 
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveInfoCard(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes, ResponsiveConfig config) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📱 Responsive Info',
              style: TextStyle(
                fontSize: fontSizes.titleMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.md),
            _buildInfoRow('Device Type', config.deviceType.name, spacing, fontSizes),
            _buildInfoRow('Screen Size', '${config.screenSize.width.toInt()} x ${config.screenSize.height.toInt()}', spacing, fontSizes),
            _buildInfoRow('Orientation', config.orientation.name, spacing, fontSizes),
            _buildInfoRow('Pixel Ratio', config.devicePixelRatio.toStringAsFixed(1), spacing, fontSizes),
            _buildInfoRow('Text Scale', config.textScaleFactor.toStringAsFixed(1), spacing, fontSizes),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: fontSizes.bodySmall),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSizes.bodySmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotionDemoCard(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return MotionDesignSystem.createExpandableCard(
      isExpanded: _isCardExpanded,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🎭 Motion Demo',
              style: TextStyle(
                fontSize: fontSizes.titleMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            MotionDesignSystem.createPressableButton(
              onPressed: () => setState(() => _isCardExpanded = !_isCardExpanded),
              child: Icon(_isCardExpanded ? Icons.expand_less : Icons.expand_more),
            ),
          ],
        ),
      ),
      expandedChild: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motion Design Features:',
              style: TextStyle(
                fontSize: fontSizes.bodyLarge,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text('• Golden ratio timing (100ms - 785ms)', style: TextStyle(fontSize: fontSizes.bodySmall)),
            Text('• Psychological comfort curves', style: TextStyle(fontSize: fontSizes.bodySmall)),
            Text('• Haptic feedback integration', style: TextStyle(fontSize: fontSizes.bodySmall)),
            Text('• Smooth card expansion', style: TextStyle(fontSize: fontSizes.bodySmall)),
            Text('• Pressable button effects', style: TextStyle(fontSize: fontSizes.bodySmall)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFeaturesCard(ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Advanced Features',
              style: TextStyle(
                fontSize: fontSizes.titleMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.md),
            _buildFeatureItem('🌞 Intelligent Dark Mode', 'Ambient light adaptation', spacing, fontSizes),
            _buildFeatureItem('📐 Golden Ratio Layout', 'Mathematical precision', spacing, fontSizes),
            _buildFeatureItem('🎨 OLED Optimization', 'Battery efficiency', spacing, fontSizes),
            _buildFeatureItem('♿ Accessibility Ready', 'WCAG AA+ compliance', spacing, fontSizes),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, ResponsiveSpacing spacing, ResponsiveFontSizes fontSizes) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSizes.bodyMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: fontSizes.bodySmall,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessToggle() {
    return MotionDesignSystem.createPressableButton(
      onPressed: _toggleBrightness,
      child: IconButton(
        onPressed: null, // Handled by PressableButton
        icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
      ),
    );
  }

  void _toggleBrightness() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    
    // Update theme through provider (would be implemented in actual app)
    // ThemeProvider.of(context).updateTheme(
    //   mood: _currentMood,
    //   isDark: _isDarkMode,
    // );
    
    _showSnackBar('Theme switched to ${_isDarkMode ? 'Dark' : 'Light'} mode');
  }

  void _changeMood(String mood) {
    setState(() {
      _currentMood = mood;
    });
    
    _showSnackBar('Mood changed to $mood');
  }

  void _showMotionDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎭 Motion Design Demo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Motion design features are active throughout this demo:'),
            const SizedBox(height: 16),
            MotionDesignSystem.createLoadingSkeleton(
              width: 200,
              height: 20,
            ),
            const SizedBox(height: 8),
            MotionDesignSystem.createLoadingSkeleton(
              width: 150,
              height: 20,
            ),
            const SizedBox(height: 8),
            MotionDesignSystem.createLoadingSkeleton(
              width: 180,
              height: 20,
            ),
          ],
        ),
        actions: [
          MotionDesignSystem.createPressableButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TextButton(
              onPressed: null,
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

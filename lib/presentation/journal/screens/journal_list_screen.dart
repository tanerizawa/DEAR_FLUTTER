import 'dart:async';
import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/widgets/timeline/sticky_note_timeline.dart';
import 'package:dear_flutter/presentation/journal/widgets/timeline/timeline_empty_state.dart' as sticky_timeline;
import 'package:dear_flutter/presentation/journal/theme/enhanced_journal_theme.dart';
import 'package:dear_flutter/presentation/journal/animations/journal_micro_interactions.dart';
import 'package:dear_flutter/presentation/journal/screens/sticky_note_journal_editor.dart';
import 'package:dear_flutter/presentation/journal/screens/journal_detail_screen.dart';
import 'package:dear_flutter/presentation/journal/screens/journal_analytics_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Journal loading states
enum JournalLoadingState {
  initial,
  loading,
  loaded,
  error,
  refreshing,
}

/// Clean Journal List Screen - hanya dengan Sticky Notes Timeline
class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  List<JournalEntry> _allJournals = [];
  JournalLoadingState _loadingState = JournalLoadingState.initial;
  String? _errorMessage;
  Timer? _debounceTimer;
  
  // Performance: Cache for expensive operations
  final Map<String, Widget> _widgetCache = {};

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Load journals with enhanced error handling and debouncing
  Future<void> _loadJournals({bool isRefresh = false}) async {
    // Debounce rapid calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performLoadJournals(isRefresh: isRefresh);
    });
  }

  Future<void> _performLoadJournals({bool isRefresh = false}) async {
    if (!mounted) return;
    
    setState(() {
      _loadingState = isRefresh 
          ? JournalLoadingState.refreshing 
          : JournalLoadingState.loading;
      _errorMessage = null;
    });

    try {
      // Timeout untuk network requests
      final list = await JournalRepository()
          .getAll()
          .timeout(const Duration(seconds: 30));
      
      if (!mounted) return;
      
      list.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _allJournals = list;
        _loadingState = JournalLoadingState.loaded;
        _errorMessage = null;
      });
      
      // Clear cache when data updates
      _widgetCache.clear();
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _loadingState = JournalLoadingState.error;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  /// Convert exceptions to user-friendly messages
  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Koneksi timeout. Periksa jaringan internet Anda.';
    } else if (error.toString().contains('SocketException')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    } else if (error.toString().contains('FormatException')) {
      return 'Data rusak. Coba refresh kembali.';
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

  /// Retry loading with exponential backoff
  Future<void> _retryLoad({int retryCount = 0}) async {
    final delay = Duration(seconds: (retryCount + 1) * 2);
    await Future.delayed(delay);
    await _loadJournals();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = EnhancedJournalColors.accentPrimary;
    const textColor = EnhancedJournalColors.textPrimary;

    return Container(
      decoration: const BoxDecoration(
        gradient: EnhancedJournalColors.primaryGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(EnhancedJournalSpacing.xxl(context)),
          child: AppBar(
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(EnhancedJournalSpacing.xs(context)),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: EnhancedJournalSpacing.sm(context)),
                Text(
                  'Jurnal Saya',
                  style: EnhancedJournalTypography.journalTitle(context).copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: textColor,
            actions: [
              // Analytics button
              IconButton(
                onPressed: () async {
                  JournalMicroInteractions.lightTap();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JournalAnalyticsDashboard(
                        journals: _allJournals,
                      ),
                    ),
                  );
                },
                icon: Container(
                  padding: EdgeInsets.all(EnhancedJournalSpacing.xs(context)),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                tooltip: 'Analitik Jurnal',
              ),
              SizedBox(width: EnhancedJournalSpacing.xs(context)),
            ],
          ),
        ),
        body: _buildBody(),
        // Subtle FAB
        floatingActionButton: JournalMicroInteractions.bounceOnTap(
          onTap: () async {
            JournalMicroInteractions.mediumTap();
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StickyNoteJournalEditor(),
              ),
            );
            if (result == true || result == 'refresh') {
              _loadJournals();
            }
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EnhancedJournalColors.accentPrimary,
                  EnhancedJournalColors.accentPrimary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: EnhancedJournalColors.accentPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  /// Build body content based on current state
  Widget _buildBody() {
    const accentColor = EnhancedJournalColors.accentPrimary;
    const secondaryText = EnhancedJournalColors.textSecondary;

    switch (_loadingState) {
      case JournalLoadingState.initial:
      case JournalLoadingState.loading:
        return _buildLoadingState(accentColor, secondaryText);
        
      case JournalLoadingState.error:
        return _buildErrorState();
        
      case JournalLoadingState.refreshing:
      case JournalLoadingState.loaded:
        if (_allJournals.isEmpty) {
          return _buildEmptyState();
        }
        return _buildTimelineState(accentColor);
    }
  }

  Widget _buildLoadingState(Color accentColor, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: accentColor,
              strokeWidth: 2.0,
            ),
          ),
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          Text(
            'Memuat jurnal...',
            style: EnhancedJournalTypography.bodySmallStyle(context).copyWith(
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Jurnal',
              style: EnhancedJournalTypography.titleLargeStyle(context).copyWith(
                color: EnhancedJournalColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
              style: EnhancedJournalTypography.bodySmallStyle(context).copyWith(
                color: EnhancedJournalColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _retryLoad(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnhancedJournalColors.accentPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => _loadJournals(isRefresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return sticky_timeline.TimelineEmptyState(
      onCreateFirst: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const StickyNoteJournalEditor(),
          ),
        );
        if (result == true || result == 'refresh') {
          _loadJournals();
        }
      },
    );
  }

  Widget _buildTimelineState(Color accentColor) {
    return RefreshIndicator(
      color: accentColor,
      onRefresh: () => _loadJournals(isRefresh: true),
      child: StickyNoteTimeline(
        journals: _allJournals,
        onRefresh: () => _loadJournals(isRefresh: true),
        onJournalTap: (journal) async {
          HapticFeedback.lightImpact();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JournalDetailScreen(entry: journal),
            ),
          );
        },
        onJournalEdit: (journal) async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StickyNoteJournalEditor(initialEntry: journal),
            ),
          );
          if (result == true || result == 'refresh') {
            _loadJournals();
          }
        },
        onJournalDelete: (journal) async {
          final confirmed = await _showDeleteConfirmation(journal);
          if (confirmed == true) {
            await _deleteJournal(journal);
          }
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(JournalEntry journal) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EnhancedJournalColors.cardBackground,
        title: Text(
          'Hapus Jurnal',
          style: EnhancedJournalTypography.titleLargeStyle(context).copyWith(
            color: EnhancedJournalColors.textPrimary,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus jurnal ini? Tindakan ini tidak dapat dibatalkan.',
          style: EnhancedJournalTypography.bodyMediumStyle(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: EnhancedJournalTypography.bodyMediumStyle(context).copyWith(
                color: EnhancedJournalColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.withValues(alpha: 0.8),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteJournal(JournalEntry journal) async {
    try {
      await JournalRepository().delete(journal.id);
      _loadJournals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jurnal berhasil dihapus'),
            backgroundColor: EnhancedJournalColors.cardBackground,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus jurnal: $e'),
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
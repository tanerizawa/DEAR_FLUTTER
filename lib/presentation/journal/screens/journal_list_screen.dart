import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/widgets/enhanced_journal_search.dart';
import 'package:dear_flutter/presentation/journal/widgets/journal_analytics_screen.dart';
import 'journal_editor_screen.dart';
import 'journal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  List<JournalEntry> _allJournals = [];
  List<JournalEntry> _filteredJournals = [];
  bool _loading = true;
  JournalSearchFilters _currentFilters = const JournalSearchFilters();

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() => _loading = true);
    final list = await JournalRepository().getAll();
    list.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _allJournals = list;
      _filteredJournals = list; // Initially show all journals
      _loading = false;
    });
  }

  void _onFiltersChanged(List<JournalEntry> filteredJournals, JournalSearchFilters filters) {
    setState(() {
      _filteredJournals = filteredJournals;
      _currentFilters = filters;
    });
  }

  Color _moodColor(String mood) {
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

  Widget _buildEmptyState(Color accentColor, Color secondaryText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentFilters.hasActiveFilters ? Icons.search_off : Icons.book_outlined,
              size: 80,
              color: accentColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              _currentFilters.hasActiveFilters
                  ? 'Tidak ada jurnal yang sesuai'
                  : 'Belum ada jurnal',
              style: TextStyle(
                fontSize: 20,
                color: secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilters.hasActiveFilters
                  ? 'Coba ubah filter atau kriteria pencarian'
                  : 'Mulai menulis jurnal harianmu!',
              style: TextStyle(
                fontSize: 14,
                color: secondaryText.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (!_currentFilters.hasActiveFilters) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.15),
                      accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_stories,
                        color: accentColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mulai Perjalanan Jurnal Anda',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dokumentasikan momen berharga, refleksikan pengalaman,\ndan pantau perkembangan emosi Anda',
                      style: TextStyle(
                        color: secondaryText.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTipItem(Icons.schedule, 'Rutin Harian', secondaryText),
                        _buildTipItem(Icons.favorite, 'Emosi Sehat', secondaryText),
                        _buildTipItem(Icons.trending_up, 'Berkembang', secondaryText),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(
    BuildContext context,
    JournalEntry journal,
    int index,
    Animation<double> animation,
    bool isFirst,
    bool isLast,
    Color accentColor,
    Color cardColor,
    Color textColor,
    Color secondaryText,
  ) {
    final moodColor = _moodColor(journal.mood);
    final words = journal.content.trim().split(' ');
    final title = words.length >= 7 
        ? words.take(7).join(' ') 
        : (journal.content.trim().isEmpty ? 'Jurnal tanpa judul' : journal.content.trim());
    final snippet = words.length > 7 ? words.skip(7).join(' ') : '';
    final now = DateTime.now();
    final isToday = journal.date.year == now.year && 
                    journal.date.month == now.month && 
                    journal.date.day == now.day;
    final timeStr = isToday 
        ? '${journal.date.hour.toString().padLeft(2, '0')}:${journal.date.minute.toString().padLeft(2, '0')}' 
        : null;

    return SizeTransition(
      sizeFactor: animation,
      child: Stack(
        children: [
          // Timeline line
          Positioned(
            left: 36,
            top: isFirst ? 48 : 0,
            bottom: isLast ? 48 : 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [moodColor.withOpacity(0.5), accentColor.withOpacity(0.18)],
                ),
              ),
            ),
          ),
          // Card & node
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood node
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: moodColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: moodColor.withOpacity(0.18),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          journal.mood.split(' ').last,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: Colors.transparent,
                      ),
                  ],
                ),
                const SizedBox(width: 18),
                // Card content
                Expanded(
                  child: Slidable(
                    key: ValueKey(journal.date.toIso8601String()),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.5,
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            final removed = journal;
                            await JournalRepository().delete(journal.id);
                            setState(() {
                              _allJournals.removeWhere((j) => j.id == journal.id);
                              _filteredJournals.removeAt(index);
                            });
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Jurnal dihapus'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async {
                                      await JournalRepository().add(removed);
                                      _loadJournals();
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Hapus',
                        ),
                        SlidableAction(
                          onPressed: (_) async {
                            HapticFeedback.mediumImpact();
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JournalEditorScreen(initialEntry: journal),
                              ),
                            );
                            if (result == 'refresh') {
                              _loadJournals();
                            }
                          },
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        color: isToday ? accentColor.withOpacity(0.18) : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: moodColor.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border(
                          left: BorderSide(color: moodColor, width: 4),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => JournalDetailScreen(entry: journal),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 13, color: moodColor.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(journal.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: moodColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (timeStr != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(Icons.access_time, size: 13, color: moodColor.withOpacity(0.7)),
                                    const SizedBox(width: 2),
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: moodColor.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (snippet.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    snippet,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryText.withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Kemarin';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Widget _buildTipItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color.withOpacity(0.8), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_stories,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Jurnal Saya'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.insights, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JournalAnalyticsScreen(journals: _allJournals),
                  ),
                );
              },
              tooltip: 'Analitik Jurnal',
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : Column(
              children: [
                // Enhanced Search Component
                EnhancedJournalSearch(
                  allJournals: _allJournals,
                  initialFilters: _currentFilters,
                  onFiltersChanged: _onFiltersChanged,
                ),
                
                // Journal List or Empty State
                Expanded(
                  child: _filteredJournals.isEmpty
                      ? _buildEmptyState(accentColor, secondaryText)
                      : RefreshIndicator(
                          color: accentColor,
                          backgroundColor: bgColor,
                          onRefresh: _loadJournals,
                          child: AnimatedList(
                            key: ValueKey(_filteredJournals.length),
                            initialItemCount: _filteredJournals.length,
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 80),
                            itemBuilder: (context, i, animation) {
                              final journal = _filteredJournals[i];
                              final isFirst = i == 0;
                              final isLast = i == _filteredJournals.length - 1;
                              return _buildJournalCard(
                                context, journal, i, animation, isFirst, isLast,
                                accentColor, cardColor, textColor, secondaryText,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

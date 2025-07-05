import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'journal_editor_screen.dart';
import 'journal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  List<JournalEntry> _allJournals = [];
  List<JournalEntry> _journals = [];
  bool _loading = true;
  String _searchQuery = '';

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
      _journals = _filterJournals(_searchQuery, list);
      _loading = false;
    });
  }

  List<JournalEntry> _filterJournals(String query, List<JournalEntry> source) {
    if (query.isEmpty) return List<JournalEntry>.from(source);
    final q = query.toLowerCase();
    return source.where((j) => j.content.toLowerCase().contains(q) || j.mood.toLowerCase().contains(q)).toList();
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

  @override
  Widget build(BuildContext context) {
    // Warna konsisten dengan Home
    const bgColor = Color(0xFF232526); // dark
    const cardColor = Color(0xFF2C2F34); // dark card
    const accentColor = Color(0xFF1DB954); // green accent
    const textColor = Colors.white;
    const secondaryText = Color(0xFFB4B8C5);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Jurnal Saya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : _journals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/empty_timeline.png', width: 120, height: 120, color: accentColor.withOpacity(0.7)),
                      const SizedBox(height: 14),
                      Text('Belum ada jurnal', style: TextStyle(fontSize: 17, color: secondaryText)),
                      const SizedBox(height: 6),
                      Text('Tulis jurnal harianmu!', style: TextStyle(fontSize: 14, color: accentColor)),
                      const SizedBox(height: 18),
                      // Empty state improvement: tips
                      Text('Tips: Menulis jurnal secara rutin membantu kesehatan mental.',
                        style: TextStyle(fontSize: 13, color: secondaryText.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: accentColor,
                  backgroundColor: bgColor,
                  onRefresh: _loadJournals,
                  child: Column(
                    children: [
                      // Search/filter bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari jurnal atau filter mood…',
                            prefixIcon: Icon(Icons.search, color: secondaryText),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          ),
                          onChanged: (q) {
                            setState(() {
                              _searchQuery = q;
                              _journals = _filterJournals(q, _allJournals);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: AnimatedList(
                          key: ValueKey(_journals.length),
                          initialItemCount: _journals.length,
                          padding: const EdgeInsets.fromLTRB(0, 24, 0, 80),
                          itemBuilder: (context, i, animation) {
                            final journal = _journals[i];
                            final isFirst = i == 0;
                            final isLast = i == _journals.length - 1;
                            final moodColor = _moodColor(journal.mood);
                            final words = journal.content.trim().split(' ');
                            final title = words.length >= 7 ? words.take(7).join(' ') : (journal.content.trim().isEmpty ? 'Jurnal tanpa judul' : journal.content.trim());
                            final snippet = words.length > 7 ? words.skip(7).join(' ') : '';
                            final now = DateTime.now();
                            final isToday = journal.date.year == now.year && journal.date.month == now.month && journal.date.day == now.day;
                            final timeStr = isToday ? '${journal.date.hour.toString().padLeft(2, '0')}:${journal.date.minute.toString().padLeft(2, '0')}' : null;
                            return SizeTransition(
                              sizeFactor: animation,
                              child: Stack(
                                children: [
                                  // Garis timeline gradient
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
                                        // Node mood
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
                                        // Card
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
                                                    final removedIndex = i;
                                                    await JournalRepository().delete(journal.id);
                                                    setState(() {
                                                      _allJournals.removeWhere((j) => j.id == journal.id);
                                                      _journals.removeAt(i);
                                                    });
                                                    AnimatedList.of(context).removeItem(
                                                      i,
                                                      (context, animation) => SizeTransition(
                                                        sizeFactor: animation,
                                                        child: Container(),
                                                      ),
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text('Jurnal dihapus'),
                                                        action: SnackBarAction(
                                                          label: 'Undo',
                                                          onPressed: () async {
                                                            await JournalRepository().add(removed);
                                                            setState(() {
                                                              _allJournals.insert(removedIndex, removed);
                                                              _journals = _filterJournals(_searchQuery, _allJournals);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: 'Hapus',
                                                ),
                                                SlidableAction(
                                                  onPressed: (_) async {
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
                                                  await Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => JournalDetailScreen(entry: journal),
                                                    ),
                                                  );
                                                  _loadJournals();
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
                                                          color: textColor,
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
                          },
                        ),
                      ),
                    ],
                  ),
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
}

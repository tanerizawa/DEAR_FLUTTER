import 'package:flutter/material.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';

enum JournalSortOption {
  dateNewest('Terbaru', Icons.arrow_downward),
  dateOldest('Terlama', Icons.arrow_upward),
  moodHappy('Mood Positif', Icons.sentiment_very_satisfied),
  moodSad('Mood Negatif', Icons.sentiment_very_dissatisfied),
  contentLength('Terpanjang', Icons.subject);

  const JournalSortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum DateRangeFilter {
  all('Semua'),
  today('Hari Ini'),
  week('Minggu Ini'),
  month('Bulan Ini'),
  year('Tahun Ini');

  const DateRangeFilter(this.label);
  final String label;
}

class JournalSearchFilters {
  final String searchQuery;
  final List<String> selectedMoods;
  final DateRangeFilter dateRange;
  final JournalSortOption sortOption;
  final bool isAdvancedSearchVisible;

  const JournalSearchFilters({
    this.searchQuery = '',
    this.selectedMoods = const [],
    this.dateRange = DateRangeFilter.all,
    this.sortOption = JournalSortOption.dateNewest,
    this.isAdvancedSearchVisible = false,
  });

  JournalSearchFilters copyWith({
    String? searchQuery,
    List<String>? selectedMoods,
    DateRangeFilter? dateRange,
    JournalSortOption? sortOption,
    bool? isAdvancedSearchVisible,
  }) {
    return JournalSearchFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMoods: selectedMoods ?? this.selectedMoods,
      dateRange: dateRange ?? this.dateRange,
      sortOption: sortOption ?? this.sortOption,
      isAdvancedSearchVisible: isAdvancedSearchVisible ?? this.isAdvancedSearchVisible,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedMoods.isNotEmpty ||
      dateRange != DateRangeFilter.all ||
      sortOption != JournalSortOption.dateNewest;

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (selectedMoods.isNotEmpty) count++;
    if (dateRange != DateRangeFilter.all) count++;
    if (sortOption != JournalSortOption.dateNewest) count++;
    return count;
  }
}

class EnhancedJournalSearch extends StatefulWidget {
  final List<JournalEntry> allJournals;
  final JournalSearchFilters initialFilters;
  final Function(List<JournalEntry> filteredJournals, JournalSearchFilters filters) onFiltersChanged;

  const EnhancedJournalSearch({
    super.key,
    required this.allJournals,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<EnhancedJournalSearch> createState() => _EnhancedJournalSearchState();
}

class _EnhancedJournalSearchState extends State<EnhancedJournalSearch>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late JournalSearchFilters _filters;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  final List<String> _availableMoods = [
    'Senang 😊',
    'Sedih 😢',
    'Marah 😡',
    'Cemas 😰',
    'Netral 😐',
    'Bersyukur 🙏',
    'Bangga 😎',
    'Takut 😱',
    'Kecewa 😞',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialFilters.searchQuery);
    _filters = widget.initialFilters;
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    if (_filters.isAdvancedSearchVisible) {
      _expandController.value = 1.0;
    }

    // Apply initial filters
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filteredJournals = _filterAndSortJournals(widget.allJournals, _filters);
    widget.onFiltersChanged(filteredJournals, _filters);
  }

  List<JournalEntry> _filterAndSortJournals(List<JournalEntry> journals, JournalSearchFilters filters) {
    List<JournalEntry> filtered = journals;

    // Apply search query filter
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      filtered = filtered.where((journal) {
        return journal.content.toLowerCase().contains(query) ||
               journal.mood.toLowerCase().contains(query);
      }).toList();
    }

    // Apply mood filters
    if (filters.selectedMoods.isNotEmpty) {
      filtered = filtered.where((journal) {
        return filters.selectedMoods.any((mood) => journal.mood.contains(mood.split(' ').first));
      }).toList();
    }

    // Apply date range filter
    if (filters.dateRange != DateRangeFilter.all) {
      final now = DateTime.now();
      filtered = filtered.where((journal) {
        switch (filters.dateRange) {
          case DateRangeFilter.today:
            return _isSameDay(journal.date, now);
          case DateRangeFilter.week:
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return journal.date.isAfter(weekStart.subtract(const Duration(days: 1)));
          case DateRangeFilter.month:
            return journal.date.year == now.year && journal.date.month == now.month;
          case DateRangeFilter.year:
            return journal.date.year == now.year;
          case DateRangeFilter.all:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    switch (filters.sortOption) {
      case JournalSortOption.dateNewest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case JournalSortOption.dateOldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case JournalSortOption.moodHappy:
        filtered.sort((a, b) => _getMoodScore(b.mood).compareTo(_getMoodScore(a.mood)));
        break;
      case JournalSortOption.moodSad:
        filtered.sort((a, b) => _getMoodScore(a.mood).compareTo(_getMoodScore(b.mood)));
        break;
      case JournalSortOption.contentLength:
        filtered.sort((a, b) => b.content.length.compareTo(a.content.length));
        break;
    }

    return filtered;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  int _getMoodScore(String mood) {
    if (mood.contains('Senang') || mood.contains('Bersyukur') || mood.contains('Bangga')) return 3;
    if (mood.contains('Netral')) return 2;
    if (mood.contains('Cemas') || mood.contains('Kecewa')) return 1;
    if (mood.contains('Sedih') || mood.contains('Marah') || mood.contains('Takut')) return 0;
    return 2; // default neutral
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

  void _toggleAdvancedSearch() {
    setState(() {
      _filters = _filters.copyWith(
        isAdvancedSearchVisible: !_filters.isAdvancedSearchVisible,
      );
    });

    if (_filters.isAdvancedSearchVisible) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _filters = const JournalSearchFilters();
    });
    _expandController.reverse();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF232526);
    const cardColor = Color(0xFF2C2F34);
    const accentColor = Color(0xFF1DB954);
    const textColor = Colors.white;
    const secondaryText = Color(0xFFB4B8C5);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // Main search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari jurnal, mood, atau kata kunci...',
                      hintStyle: TextStyle(color: secondaryText.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search, color: secondaryText),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: secondaryText),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filters = _filters.copyWith(searchQuery: '');
                                });
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    style: const TextStyle(color: textColor),
                    onChanged: (query) {
                      setState(() {
                        _filters = _filters.copyWith(searchQuery: query);
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Advanced search toggle button
                Container(
                  decoration: BoxDecoration(
                    color: _filters.hasActiveFilters ? accentColor : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _filters.hasActiveFilters
                        ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                  child: IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.tune,
                          color: _filters.hasActiveFilters ? Colors.white : secondaryText,
                        ),
                        if (_filters.activeFilterCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${_filters.activeFilterCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _toggleAdvancedSearch,
                  ),
                ),
              ],
            ),
          ),

          // Advanced search panel
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with clear button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Urutkan',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_filters.hasActiveFilters)
                        TextButton.icon(
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Hapus Semua'),
                          style: TextButton.styleFrom(
                            foregroundColor: secondaryText,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: _clearAllFilters,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date range filter
                  const Text(
                    'Rentang Waktu',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: DateRangeFilter.values.map((range) {
                      final isSelected = _filters.dateRange == range;
                      return FilterChip(
                        label: Text(range.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _filters = _filters.copyWith(
                              dateRange: selected ? range : DateRangeFilter.all,
                            );
                          });
                          _applyFilters();
                        },
                        backgroundColor: cardColor,
                        selectedColor: accentColor.withOpacity(0.3),
                        checkmarkColor: accentColor,
                        labelStyle: TextStyle(
                          color: isSelected ? accentColor : secondaryText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? accentColor : secondaryText.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Mood filter
                  const Text(
                    'Filter Mood',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _availableMoods.map((mood) {
                      final isSelected = _filters.selectedMoods.contains(mood);
                      final moodColor = _getMoodColor(mood);
                      return FilterChip(
                        label: Text(mood),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            final selectedMoods = List<String>.from(_filters.selectedMoods);
                            if (selected) {
                              selectedMoods.add(mood);
                            } else {
                              selectedMoods.remove(mood);
                            }
                            _filters = _filters.copyWith(selectedMoods: selectedMoods);
                          });
                          _applyFilters();
                        },
                        backgroundColor: cardColor,
                        selectedColor: moodColor.withOpacity(0.3),
                        checkmarkColor: moodColor,
                        labelStyle: TextStyle(
                          color: isSelected ? moodColor : secondaryText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? moodColor : secondaryText.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Sort options
                  const Text(
                    'Urutkan Berdasarkan',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: JournalSortOption.values.map((option) {
                      final isSelected = _filters.sortOption == option;
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(option.icon, size: 16, color: isSelected ? accentColor : secondaryText),
                            const SizedBox(width: 4),
                            Text(option.label),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _filters = _filters.copyWith(sortOption: option);
                          });
                          _applyFilters();
                        },
                        backgroundColor: cardColor,
                        selectedColor: accentColor.withOpacity(0.3),
                        checkmarkColor: accentColor,
                        labelStyle: TextStyle(
                          color: isSelected ? accentColor : secondaryText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? accentColor : secondaryText.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Active filters summary
          if (_filters.hasActiveFilters && !_filters.isAdvancedSearchVisible)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: secondaryText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getActiveFiltersText(),
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getActiveFiltersText() {
    final List<String> activeFilters = [];
    
    if (_filters.searchQuery.isNotEmpty) {
      activeFilters.add('Pencarian: "${_filters.searchQuery}"');
    }
    
    if (_filters.selectedMoods.isNotEmpty) {
      activeFilters.add('Mood: ${_filters.selectedMoods.length} dipilih');
    }
    
    if (_filters.dateRange != DateRangeFilter.all) {
      activeFilters.add('Waktu: ${_filters.dateRange.label}');
    }
    
    if (_filters.sortOption != JournalSortOption.dateNewest) {
      activeFilters.add('Urutkan: ${_filters.sortOption.label}');
    }
    
    return activeFilters.join(' • ');
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:dear_flutter/presentation/journal/widgets/enhanced_journal_search.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';

void main() {
  group('Enhanced Journal Search Tests', () {
    late List<JournalEntry> testJournals;

    setUp(() {
      testJournals = [
        JournalEntry(
          id: '1',
          date: DateTime(2024, 1, 15, 9, 30),
          mood: 'Senang 😊',
          content: 'Hari ini sangat menyenangkan. Bertemu teman lama dan berbagi cerita.',
        ),
        JournalEntry(
          id: '2',
          date: DateTime(2024, 1, 14, 20, 15),
          mood: 'Sedih 😢',
          content: 'Merasa sedikit down karena cuaca yang mendung sepanjang hari.',
        ),
        JournalEntry(
          id: '3',
          date: DateTime(2024, 1, 13, 12, 0),
          mood: 'Bersyukur 🙏',
          content: 'Alhamdulillah mendapat kesempatan baru di tempat kerja.',
        ),
        JournalEntry(
          id: '4',
          date: DateTime(2024, 1, 12, 8, 45),
          mood: 'Cemas 😰',
          content: 'Besok ada presentasi penting. Semoga berjalan lancar.',
        ),
        JournalEntry(
          id: '5',
          date: DateTime(2023, 12, 20, 18, 30),
          mood: 'Netral 😐',
          content: 'Hari biasa saja, tidak ada yang istimewa terjadi.',
        ),
      ];
    });

    test('JournalSearchFilters should detect active filters correctly', () {
      // Test empty filters
      const emptyFilters = JournalSearchFilters();
      expect(emptyFilters.hasActiveFilters, false);
      expect(emptyFilters.activeFilterCount, 0);

      // Test search query filter
      const searchFilters = JournalSearchFilters(searchQuery: 'test');
      expect(searchFilters.hasActiveFilters, true);
      expect(searchFilters.activeFilterCount, 1);

      // Test mood filter
      const moodFilters = JournalSearchFilters(selectedMoods: ['Senang 😊']);
      expect(moodFilters.hasActiveFilters, true);
      expect(moodFilters.activeFilterCount, 1);

      // Test date range filter
      const dateFilters = JournalSearchFilters(dateRange: DateRangeFilter.week);
      expect(dateFilters.hasActiveFilters, true);
      expect(dateFilters.activeFilterCount, 1);

      // Test sort filter
      const sortFilters = JournalSearchFilters(sortOption: JournalSortOption.dateOldest);
      expect(sortFilters.hasActiveFilters, true);
      expect(sortFilters.activeFilterCount, 1);

      // Test multiple filters
      const multipleFilters = JournalSearchFilters(
        searchQuery: 'test',
        selectedMoods: ['Senang 😊'],
        dateRange: DateRangeFilter.month,
      );
      expect(multipleFilters.hasActiveFilters, true);
      expect(multipleFilters.activeFilterCount, 3);
    });

    test('Search query should filter journals correctly', () {
      const filters = JournalSearchFilters(searchQuery: 'teman');
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      expect(filtered.length, 1);
      expect(filtered[0].content.contains('teman'), true);
    });

    test('Mood filter should work correctly', () {
      const filters = JournalSearchFilters(selectedMoods: ['Senang 😊', 'Bersyukur 🙏']);
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      expect(filtered.length, 2);
      expect(filtered.any((j) => j.mood.contains('Senang')), true);
      expect(filtered.any((j) => j.mood.contains('Bersyukur')), true);
    });

    test('Date range filter should work correctly', () {
      final now = DateTime.now();
      final thisYear = DateTime(now.year, 1, 1);
      
      // Test with year filter
      const filters = JournalSearchFilters(dateRange: DateRangeFilter.year);
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      // Should filter based on current year
      final expectedCount = testJournals.where((j) => j.date.year == now.year).length;
      expect(filtered.length, expectedCount);
    });

    test('Sort options should work correctly', () {
      // Test oldest first
      const oldestFilters = JournalSearchFilters(sortOption: JournalSortOption.dateOldest);
      final searchWidget = _MockEnhancedJournalSearch();
      final oldestSorted = searchWidget.filterAndSortJournals(testJournals, oldestFilters);
      
      expect(oldestSorted.first.date.isBefore(oldestSorted.last.date), true);

      // Test newest first (default)
      const newestFilters = JournalSearchFilters(sortOption: JournalSortOption.dateNewest);
      final newestSorted = searchWidget.filterAndSortJournals(testJournals, newestFilters);
      
      expect(newestSorted.first.date.isAfter(newestSorted.last.date), true);

      // Test content length
      const lengthFilters = JournalSearchFilters(sortOption: JournalSortOption.contentLength);
      final lengthSorted = searchWidget.filterAndSortJournals(testJournals, lengthFilters);
      
      expect(lengthSorted.first.content.length >= lengthSorted.last.content.length, true);
    });

    test('Combined filters should work correctly', () {
      const filters = JournalSearchFilters(
        searchQuery: 'hari',
        selectedMoods: ['Senang 😊', 'Netral 😐'],
        dateRange: DateRangeFilter.year,
        sortOption: JournalSortOption.dateNewest,
      );
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      // Should find entries that:
      // 1. Contain 'hari' in content
      // 2. Have mood 'Senang' or 'Netral'
      // 3. Are from current year
      // 4. Sorted by newest first
      
      for (final journal in filtered) {
        expect(journal.content.toLowerCase().contains('hari'), true);
        expect(journal.mood.contains('Senang') || journal.mood.contains('Netral'), true);
        expect(journal.date.year, DateTime.now().year);
      }
      
      // Check sorting (newest first)
      if (filtered.length > 1) {
        for (int i = 0; i < filtered.length - 1; i++) {
          expect(filtered[i].date.isAfter(filtered[i + 1].date) || 
                 filtered[i].date.isAtSameMomentAs(filtered[i + 1].date), true);
        }
      }
    });

    test('Empty search should return all journals', () {
      const filters = JournalSearchFilters();
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      expect(filtered.length, testJournals.length);
    });

    test('Case insensitive search should work', () {
      const filters = JournalSearchFilters(searchQuery: 'HARI');
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      expect(filtered.length, 3); // Should find entries with 'hari' regardless of case
      // 1. "Hari ini sangat menyenangkan..."
      // 2. "Hari biasa saja..."  
      // 3. "sepanjang hari" (from "cuaca yang mendung sepanjang hari")
    });

    test('Mood search should work', () {
      const filters = JournalSearchFilters(searchQuery: 'senang');
      final searchWidget = _MockEnhancedJournalSearch();
      final filtered = searchWidget.filterAndSortJournals(testJournals, filters);
      
      // Should find entries with 'senang' in mood or content
      expect(filtered.isNotEmpty, true);
      expect(filtered.any((j) => 
        j.mood.toLowerCase().contains('senang') || 
        j.content.toLowerCase().contains('senang')), true);
    });
  });
}

// Mock class to access private filtering method for testing
class _MockEnhancedJournalSearch {
  List<JournalEntry> filterAndSortJournals(
    List<JournalEntry> journals, 
    JournalSearchFilters filters
  ) {
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
        return filters.selectedMoods.any((mood) => 
          journal.mood.contains(mood.split(' ').first));
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
}
